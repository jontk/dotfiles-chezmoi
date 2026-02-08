#!/usr/bin/env bash
# Enable user-level systemd services managed by chezmoi
# Run this script once after chezmoi apply to activate the services

set -e

echo "Enabling user-level systemd services..."

# Reload systemd user daemon
systemctl --user daemon-reload

# Enable and start gpg-agent sockets
echo "Enabling gpg-agent..."
systemctl --user enable --now gpg-agent.socket
systemctl --user enable --now gpg-agent-ssh.socket

# Enable and start dunst (if in graphical session)
if [[ -n "$DISPLAY" ]] || [[ -n "$WAYLAND_DISPLAY" ]]; then
    echo "Enabling dunst notification daemon..."
    systemctl --user enable --now dunst.service
fi

echo ""
echo "✅ Services enabled successfully!"
echo ""
echo "To check status:"
echo "  systemctl --user status gpg-agent.socket"
echo "  systemctl --user status gpg-agent-ssh.socket"
echo "  systemctl --user status dunst.service"
echo ""
echo "SSH_AUTH_SOCK should be:"
echo "  export SSH_AUTH_SOCK=\$(gpgconf --list-dirs agent-ssh-socket)"
