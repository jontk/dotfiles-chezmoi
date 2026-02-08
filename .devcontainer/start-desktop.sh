#!/bin/bash
# Start Sway desktop with VNC access
set -e

echo "=== Sway Desktop Environment ==="
echo "Starting headless Wayland desktop..."

# Fix permissions on mounted volumes FIRST (they may be owned by root)
echo "Checking volume permissions..."
for dir in ~/.config ~/.cache ~/.local; do
    if [[ -d "$dir" ]]; then
        sudo chown -R $(id -u):$(id -g) "$dir" 2>/dev/null || true
    fi
done

# Create required directories
mkdir -p ~/.config/{sway,waybar,foot,wofi,kitty,alacritty,chezmoi}
mkdir -p ~/.cache/{kitty,mesa_shader_cache,chezmoi}
mkdir -p ~/.local/{bin,share}

# Ensure runtime dir exists with correct permissions
if [[ ! -d "$XDG_RUNTIME_DIR" ]]; then
    sudo mkdir -p "$XDG_RUNTIME_DIR"
    sudo chown $(id -u):$(id -g) "$XDG_RUNTIME_DIR"
    sudo chmod 700 "$XDG_RUNTIME_DIR"
fi

# Start dbus session bus
echo "Starting dbus..."
if command -v dbus-launch &> /dev/null; then
    eval $(dbus-launch --sh-syntax)
    export DBUS_SESSION_BUS_ADDRESS
    echo "DBus started: $DBUS_SESSION_BUS_ADDRESS"
else
    echo "WARNING: dbus-launch not found, some apps may not work"
fi

# Apply dotfiles with chezmoi
if [[ -d "$CHEZMOI_SOURCE" ]] || [[ -d "/home/dev/dotfiles" ]]; then
    DOTFILES_DIR="${CHEZMOI_SOURCE:-/home/dev/dotfiles}"
    echo ""
    echo "Applying dotfiles with chezmoi..."
    echo "Source: $DOTFILES_DIR"

    # Create chezmoi config for container testing
    mkdir -p ~/.config/chezmoi
    cat > ~/.config/chezmoi/chezmoi.toml << 'EOF'
[data]
    profile = "personal"

[data.features]
    fonts = true
    docker = true
    kubernetes = false
    nodejs = true
    python = true
    golang = true
    ruby = false
    java = false
    compilers = false
    beta_features = false
    starship = true
    tmux = true
    editors_full = true
    work_specific = false

[data.git]
    name = "Dev User"
    email = "dev@container.local"
    signingKey = ""
    githubKey = ""
    gitlabKey = ""
    workEmail = ""
    workName = ""
    workGpgKey = ""

[data.shell]
    prompt_style = "starship"
    enable_functions = true

[data.editor]
    default = "nvim"

[data.work]
    username = ""
    sshKey = ""
EOF

    # Create symlink so chezmoi finds the source
    mkdir -p ~/.local/share
    ln -sfn "$DOTFILES_DIR" ~/.local/share/chezmoi
    echo "Chezmoi source linked: $(ls -la ~/.local/share/chezmoi)"

    # Apply dotfiles
    # --force: overwrite without prompting
    # --no-tty: don't wait for TTY input
    # --exclude: skip scripts (may hang), externals (cross-device links), encrypted
    timeout 60 chezmoi apply --force --no-tty --exclude=encrypted,externals,scripts || {
        echo "WARNING: chezmoi apply had errors or timed out, some configs may be missing"
    }

    echo "Dotfiles applied!"
else
    echo "No dotfiles source found, using defaults"
fi

# Determine sway config to use
if [[ -f "$HOME/.config/sway/config" ]]; then
    echo "Using chezmoi-applied sway config"
    SWAY_CONFIG="$HOME/.config/sway/config"
else
    echo "Using default sway config"
    SWAY_CONFIG="/etc/sway/config.default"
fi

echo ""
echo "Config file: $SWAY_CONFIG"
echo ""

# Start Sway
echo "Starting Sway..."
sway -c "$SWAY_CONFIG" 2>&1 &
SWAY_PID=$!

# Wait for Sway to create Wayland socket
echo "Waiting for Wayland socket..."
for i in {1..30}; do
    if [[ -S "$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY" ]]; then
        echo "Wayland socket ready"
        break
    fi
    sleep 0.5
done

if [[ ! -S "$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY" ]]; then
    echo "ERROR: Wayland socket not created"
    exit 1
fi

# Give sway a moment to fully initialize
sleep 2

# Check if sway is still running
if ! kill -0 $SWAY_PID 2>/dev/null; then
    echo "ERROR: Sway crashed"
    exit 1
fi

echo "Sway is running (PID: $SWAY_PID)"

# Start VNC server
echo "Starting wayvnc..."
if wayvnc --output=HEADLESS-1 0.0.0.0 5900 2>/tmp/wayvnc.log & then
    WAYVNC_PID=$!
    sleep 2
    if ! kill -0 $WAYVNC_PID 2>/dev/null; then
        echo "wayvnc with input failed, trying without input..."
        cat /tmp/wayvnc.log
        wayvnc --output=HEADLESS-1 --disable-input 0.0.0.0 5900 &
        WAYVNC_PID=$!
        echo "NOTE: Running in view-only mode (no mouse/keyboard)"
    fi
else
    echo "wayvnc failed to start, trying without input..."
    wayvnc --output=HEADLESS-1 --disable-input 0.0.0.0 5900 &
    WAYVNC_PID=$!
    echo "NOTE: Running in view-only mode (no mouse/keyboard)"
fi

sleep 1

# Start noVNC web interface
echo "Starting noVNC..."
NOVNC_PATH="/usr/share/novnc"
[[ -d "/usr/share/webapps/novnc" ]] && NOVNC_PATH="/usr/share/webapps/novnc"
websockify --web "$NOVNC_PATH" 6080 localhost:5900 &
NOVNC_PID=$!

echo ""
echo "========================================"
echo "Desktop ready!"
echo "========================================"
echo ""
echo "Browser access: http://localhost:6080/vnc.html"
echo "VNC direct:     localhost:5900"
echo ""
echo "To re-apply dotfiles after editing:"
echo "  chezmoi apply"
echo ""
echo "Keybindings:"
echo "  Mod+Return     - Open terminal (foot)"
echo "  Mod+Shift+t    - Open kitty"
echo "  Mod+Ctrl+t     - Open alacritty"
echo "  Mod+d          - App launcher (wofi)"
echo "  Mod+Shift+q    - Close window"
echo "  Mod+Shift+c    - Reload sway config"
echo "  Mod+1/2/3      - Switch workspace"
echo "  Mod+h/j/k/l    - Focus direction"
echo ""
echo "========================================"

# Handle shutdown
cleanup() {
    echo "Shutting down..."
    kill $NOVNC_PID 2>/dev/null || true
    kill $WAYVNC_PID 2>/dev/null || true
    kill $SWAY_PID 2>/dev/null || true
    exit 0
}
trap cleanup SIGTERM SIGINT

# Keep running
wait $SWAY_PID
