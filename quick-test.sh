#!/bin/bash
# quick-test.sh - Test dotfiles in Docker with local source

DOTFILES_DIR="/home/jontk/src/github.com/jontk/dotfiles-chezmoi"

docker run --rm -it \
  -v "$DOTFILES_DIR":/dotfiles:ro \
  ubuntu:22.04 bash -c '
    set -e
    apt update -qq && apt install -y -qq git curl sudo vim zsh

    # Install chezmoi to ~/bin
    sh -c "$(curl -fsLS get.chezmoi.io)" -- -b ~/bin
    export PATH="$HOME/bin:$PATH"

    # Apply dotfiles
    chezmoi init --apply --source /dotfiles

    # Run tests
    echo ""
    echo "=== Running Tests ==="
    echo ""

    # Git fsck
    if [ "$(git config --get transfer.fsckObjects)" = "true" ]; then
        echo "✓ Git fsck enabled"
    else
        echo "✗ Git fsck NOT enabled"
        exit 1
    fi

    # GREP_OPTIONS
    if [ -z "$GREP_OPTIONS" ]; then
        echo "✓ GREP_OPTIONS not set"
    else
        echo "✗ GREP_OPTIONS still set: $GREP_OPTIONS"
        exit 1
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
    test -f ~/.bash_profile && echo "✓ .bash_profile exists" || echo "✗ .bash_profile missing"

    # Git config modern features
    test "$(git config --get feature.manyFiles)" = "true" && echo "✓ Git feature.manyFiles enabled" || echo "⚠ Git feature.manyFiles not enabled"
    test "$(git config --get index.version)" = "4" && echo "✓ Git index.version = 4" || echo "⚠ Git index.version not set"

    echo ""
    echo "=== All critical tests passed! ==="
    echo ""
    echo "Starting interactive shell for manual testing..."
    echo ""
    echo "Try these commands:"
    echo "  - source ~/.bashrc      # Load bash config"
    echo "  - git status            # Check git prompt (create a repo first)"
    echo "  - cat ~/.ssh/config     # View SSH config"
    echo "  - cat ~/.gitconfig      # View git config"
    echo ""

    exec bash
'
