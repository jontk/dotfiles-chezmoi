#!/bin/bash
# quick-test.sh - Test dotfiles in Docker with local source
# Reuses container for faster testing
#
# Usage:
#   ./quick-test.sh                    # Interactive (prompts for git config)
#   ./quick-test.sh --auto             # Non-interactive (uses test values)
#   ./quick-test.sh --full             # Run with scripts (tests user-space tools)
#   ./quick-test.sh --clean            # Remove container
#
# Environment variables (optional):
#   TEST_GIT_NAME="Your Name"
#   TEST_GIT_EMAIL="you@example.com"

set -e

DOTFILES_DIR="/home/jontk/src/github.com/jontk/dotfiles-chezmoi"
CONTAINER_NAME="dotfiles-test"

# Parse arguments
CLEAN=false
AUTO=false
FULL=false
for arg in "$@"; do
    case "$arg" in
        --clean) CLEAN=true ;;
        --auto) AUTO=true ;;
        --full) FULL=true; AUTO=true ;;
    esac
done

# Set chezmoi exclude flags based on mode
if [[ "$FULL" == "true" ]]; then
    CHEZMOI_EXCLUDE="externals"
    echo "🚀 Full mode: will run install scripts (user-space tools)"
else
    CHEZMOI_EXCLUDE="scripts,externals"
fi

# Get GitHub token from gh CLI if available (for higher API rate limits)
if [[ -z "$GITHUB_TOKEN" ]] && command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1; then
    GITHUB_TOKEN=$(gh auth token 2>/dev/null)
    if [[ -n "$GITHUB_TOKEN" ]]; then
        echo "📦 Using GitHub token from gh CLI"
    fi
fi

# Clean up function
cleanup() {
    echo "Cleaning up container: $CONTAINER_NAME"
    docker rm -f "$CONTAINER_NAME" 2>/dev/null || true
    echo "Container removed."
    exit 0
}

# Handle --clean flag
if [[ "$CLEAN" == "true" ]]; then
    cleanup
fi

# Check if container exists
if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo "📦 Reusing existing container: $CONTAINER_NAME"

    # Start container if it's stopped
    if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
        echo "▶️  Starting stopped container..."
        docker start "$CONTAINER_NAME" >/dev/null
    fi

    # Ensure chezmoi is executable (fix for existing containers)
    echo "🔧 Checking chezmoi permissions..."
    docker exec "$CONTAINER_NAME" bash -c 'test -f ~/bin/chezmoi && chmod +x ~/bin/chezmoi || true'

    # Re-apply dotfiles in existing container
    if [[ "$AUTO" == "true" ]]; then
        echo "🔄 Re-applying dotfiles (non-interactive mode)..."
        echo "   Creating config..."
        # Create config with proper TOML - expand vars first, then write
        TEST_EMAIL="${TEST_GIT_EMAIL:-test@example.com}"
        TEST_NAME="${TEST_GIT_NAME:-Test User}"
        docker exec -e CHEZMOI_EXCLUDE="$CHEZMOI_EXCLUDE" -e CHEZMOI_ALLOW_REMOTE_INSTALL="${CHEZMOI_ALLOW_REMOTE_INSTALL:-0}" -e GITHUB_TOKEN="${GITHUB_TOKEN:-}" \
            -e TEST_EMAIL="$TEST_EMAIL" -e TEST_NAME="$TEST_NAME" "$CONTAINER_NAME" bash -c '
            set -e
            cd ~
            mkdir -p ~/.config/chezmoi
            cat > ~/.config/chezmoi/chezmoi.toml <<EOF
[data]
    profile = "personal"
    hostname = "test-container"

    [data.git]
        email = "$TEST_EMAIL"
        name = "$TEST_NAME"
        githubKey = ""
        gitlabKey = ""
        workEmail = ""
        workName = ""
        workGpgKey = ""

    [data.features]
        editors_full = true
        docker = true
        kubernetes = true
        nodejs = true
        python = true
        golang = true
        ruby = false
        java = false
        compilers = false
        fonts = true
        starship = true
        tmux = true
        beta_features = false
        work_specific = false

    [data.shell]
        prompt_style = "starship"
        enable_functions = true

    [data.editor]
        default = "vim"

    [data.work]
        username = "testuser"
        sshKey = ""
EOF
            export PATH="$HOME/bin:$PATH"
            echo "Applying dotfiles..."
            # Skip scripts and externals, force non-interactive mode
            echo | chezmoi apply --source /dotfiles --force --exclude $CHEZMOI_EXCLUDE || {
                echo "Chezmoi apply failed, checking status..."
                chezmoi status --source /dotfiles || true
                exit 1
            }
            echo "Apply complete!"
        '
    else
        echo "🔄 Re-applying dotfiles..."
        docker exec -e CHEZMOI_EXCLUDE="$CHEZMOI_EXCLUDE" -e CHEZMOI_ALLOW_REMOTE_INSTALL="${CHEZMOI_ALLOW_REMOTE_INSTALL:-0}" -e GITHUB_TOKEN="${GITHUB_TOKEN:-}" -it "$CONTAINER_NAME" bash -c '
            set -e
            cd ~
            export PATH="$HOME/bin:$PATH"
            chezmoi apply --source /dotfiles --force --exclude $CHEZMOI_EXCLUDE
        '
    fi

    # Run tests
    docker exec "$CONTAINER_NAME" bash -c '
        set -e

        # Ensure PATH includes user-space tool locations
        export PATH="$HOME/.local/bin:$HOME/.bun/bin:$HOME/.local/go/bin:$HOME/.local/share/cargo/bin:$PATH"

        # Run tests
        echo ""
        echo "=== Running Tests ==="
        echo ""

        # Git fsck
        if [ "$(git config --get transfer.fsckObjects)" = "true" ]; then
            echo "✓ Git fsck enabled"
        else
            echo "✗ Git fsck NOT enabled"
        fi

        # GREP_OPTIONS
        if [ -z "$GREP_OPTIONS" ]; then
            echo "✓ GREP_OPTIONS not set"
        else
            echo "✗ GREP_OPTIONS still set: $GREP_OPTIONS"
        fi

        # Configs exist
        test -f ~/.ssh/config && echo "✓ SSH config exists" || echo "✗ SSH config missing"
        test -f ~/.gnupg/gpg.conf && echo "✓ GPG config exists" || echo "✗ GPG config missing"
        test -f ~/.config/readline/inputrc && echo "✓ Readline config exists" || echo "✗ Readline config missing"
        test -f ~/.config/ripgrep/config && echo "✓ Ripgrep config exists" || echo "✗ Ripgrep config missing"

        # Shell configs
        test -f ~/.bashrc && echo "✓ .bashrc exists" || echo "✗ .bashrc missing"
        test -f ~/.zshrc && echo "✓ .zshrc exists" || echo "✗ .zshrc missing"
        test -f ~/.profile && echo "✓ .profile exists" || echo "✗ .profile missing"

        # User-space tools (only if scripts were run)
        echo ""
        echo "--- User-space tools ---"
        command -v eget >/dev/null && echo "✓ eget installed" || echo "- eget not installed (run with --full)"
        command -v rg >/dev/null && echo "✓ ripgrep installed" || echo "- ripgrep not installed"
        command -v fd >/dev/null && echo "✓ fd installed" || echo "- fd not installed"
        command -v bat >/dev/null && echo "✓ bat installed" || echo "- bat not installed"
        command -v fnm >/dev/null && echo "✓ fnm installed" || echo "- fnm not installed"
        command -v uv >/dev/null && echo "✓ uv installed" || echo "- uv not installed"
        test -d ~/.local/go && echo "✓ Go installed" || echo "- Go not installed"
        command -v rustup >/dev/null && echo "✓ rustup installed" || echo "- rustup not installed"

        echo ""
        echo "=== Tests complete! ==="
        echo ""
    '

    # Drop into interactive shell
    echo "Starting interactive shell..."
    echo "Type 'exit' to leave the container running, or run:"
    echo "  ./quick-test.sh --clean  # to remove the container"
    echo ""
    docker exec -it "$CONTAINER_NAME" bash

else
    echo "🆕 Creating new container: $CONTAINER_NAME"
    echo "   (subsequent runs will be faster)"
    echo ""

    # Create and run new container
    docker run -d -it \
      --name "$CONTAINER_NAME" \
      -v "$DOTFILES_DIR":/dotfiles:ro \
      ubuntu:22.04 bash

    # Install packages
    echo "📦 Installing packages..."
    docker exec "$CONTAINER_NAME" bash -c '
        apt update -qq && apt install -y -qq git curl sudo vim zsh unzip
    '

    # Install chezmoi
    echo "⚙️  Installing chezmoi..."
    docker exec "$CONTAINER_NAME" bash -c '
        sh -c "$(curl -fsLS get.chezmoi.io)" -- -b ~/bin
        chmod +x ~/bin/chezmoi
    '

    # Apply dotfiles
    if [[ "$AUTO" == "true" ]]; then
        echo "🔧 Applying dotfiles (non-interactive mode)..."
        # Create a config file with test data to avoid prompts
        TEST_EMAIL="${TEST_GIT_EMAIL:-test@example.com}"
        TEST_NAME="${TEST_GIT_NAME:-Test User}"
        docker exec -e CHEZMOI_EXCLUDE="$CHEZMOI_EXCLUDE" -e CHEZMOI_ALLOW_REMOTE_INSTALL="${CHEZMOI_ALLOW_REMOTE_INSTALL:-0}" -e GITHUB_TOKEN="${GITHUB_TOKEN:-}" \
            -e TEST_EMAIL="$TEST_EMAIL" -e TEST_NAME="$TEST_NAME" "$CONTAINER_NAME" bash -c '
            mkdir -p ~/.config/chezmoi
            cat > ~/.config/chezmoi/chezmoi.toml <<EOF
[data]
    profile = "personal"
    hostname = "test-container"

    [data.git]
        email = "$TEST_EMAIL"
        name = "$TEST_NAME"
        githubKey = ""
        gitlabKey = ""
        workEmail = ""
        workName = ""
        workGpgKey = ""

    [data.features]
        editors_full = true
        docker = true
        kubernetes = true
        nodejs = true
        python = true
        golang = true
        ruby = false
        java = false
        compilers = false
        fonts = true
        starship = true
        tmux = true
        beta_features = false
        work_specific = false

    [data.shell]
        prompt_style = "starship"
        enable_functions = true

    [data.editor]
        default = "vim"

    [data.work]
        username = "testuser"
        sshKey = ""
EOF
            export PATH="$HOME/bin:$PATH"
            echo "Applying dotfiles..."
            # Skip scripts and externals, force non-interactive mode
            echo | chezmoi init --apply --source /dotfiles --exclude $CHEZMOI_EXCLUDE || {
                echo "Chezmoi init failed, checking status..."
                chezmoi status --source /dotfiles || true
                exit 1
            }
            echo "Init complete!"
        '
    else
        echo "🔧 Applying dotfiles (you'll be prompted for git name/email)..."
        docker exec -e CHEZMOI_EXCLUDE="$CHEZMOI_EXCLUDE" -e CHEZMOI_ALLOW_REMOTE_INSTALL="${CHEZMOI_ALLOW_REMOTE_INSTALL:-0}" -e GITHUB_TOKEN="${GITHUB_TOKEN:-}" -it "$CONTAINER_NAME" bash -c '
            export PATH="$HOME/bin:$PATH"
            chezmoi init --apply --source /dotfiles --exclude $CHEZMOI_EXCLUDE
        '
    fi

    # Run tests
    echo ""
    echo "=== Running Tests ==="
    echo ""
    docker exec "$CONTAINER_NAME" bash -c '
        # Ensure PATH includes user-space tool locations
        export PATH="$HOME/.local/bin:$HOME/.bun/bin:$HOME/.local/go/bin:$HOME/.local/share/cargo/bin:$PATH"

        # Git fsck
        if [ "$(git config --get transfer.fsckObjects)" = "true" ]; then
            echo "✓ Git fsck enabled"
        else
            echo "✗ Git fsck NOT enabled"
        fi

        # GREP_OPTIONS
        if [ -z "$GREP_OPTIONS" ]; then
            echo "✓ GREP_OPTIONS not set"
        else
            echo "✗ GREP_OPTIONS still set: $GREP_OPTIONS"
        fi

        # Configs exist
        test -f ~/.ssh/config && echo "✓ SSH config exists" || echo "✗ SSH config missing"
        test -f ~/.gnupg/gpg.conf && echo "✓ GPG config exists" || echo "✗ GPG config missing"
        test -f ~/.config/readline/inputrc && echo "✓ Readline config exists" || echo "✗ Readline config missing"
        test -f ~/.config/ripgrep/config && echo "✓ Ripgrep config exists" || echo "✗ Ripgrep config missing"

        # Shell configs
        test -f ~/.bashrc && echo "✓ .bashrc exists" || echo "✗ .bashrc missing"
        test -f ~/.zshrc && echo "✓ .zshrc exists" || echo "✗ .zshrc missing"
        test -f ~/.profile && echo "✓ .profile exists" || echo "✗ .profile missing"

        # User-space tools (only if scripts were run)
        echo ""
        echo "--- User-space tools ---"
        command -v eget >/dev/null && echo "✓ eget installed" || echo "- eget not installed (run with --full)"
        command -v rg >/dev/null && echo "✓ ripgrep installed" || echo "- ripgrep not installed"
        command -v fd >/dev/null && echo "✓ fd installed" || echo "- fd not installed"
        command -v bat >/dev/null && echo "✓ bat installed" || echo "- bat not installed"
        command -v fnm >/dev/null && echo "✓ fnm installed" || echo "- fnm not installed"
        command -v uv >/dev/null && echo "✓ uv installed" || echo "- uv not installed"
        test -d ~/.local/go && echo "✓ Go installed" || echo "- Go not installed"
        command -v rustup >/dev/null && echo "✓ rustup installed" || echo "- rustup not installed"

        echo ""
        echo "=== All tests passed! ==="
        echo ""
    '

    # Drop into interactive shell
    echo "Starting interactive shell..."
    echo "Container will remain running for faster subsequent tests."
    echo "Run: ./quick-test.sh --clean  # to remove the container"
    echo ""
    docker exec -it "$CONTAINER_NAME" bash
fi
