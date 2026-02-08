# Sway Desktop Development Environment (Fedora)
# Provides a full Wayland desktop accessible via browser (noVNC)

FROM registry.fedoraproject.org/fedora:41

ARG USERNAME=dev
ARG USER_UID=1000
ARG USER_GID=$USER_UID

ENV WLR_BACKENDS=headless
ENV WLR_LIBINPUT_NO_DEVICES=1
ENV WLR_RENDERER=pixman
ENV XDG_RUNTIME_DIR=/run/user/${USER_UID}
ENV XDG_CONFIG_HOME=/home/${USERNAME}/.config
ENV XDG_DATA_HOME=/home/${USERNAME}/.local/share
ENV XDG_CACHE_HOME=/home/${USERNAME}/.cache
ENV WAYLAND_DISPLAY=wayland-1
ENV MOZ_ENABLE_WAYLAND=1
ENV QT_QPA_PLATFORM=wayland

# System packages
RUN dnf install -y \
    # Sway and Wayland ecosystem
    sway swaylock swayidle swaybg waybar wofi \
    wayvnc novnc python3-websockify \
    # Terminals
    foot kitty alacritty \
    # Wayland utilities
    wl-clipboard grim slurp mako kanshi \
    # Browser
    firefox \
    # Dev tools (curl, sudo already in base image)
    git wget unzip \
    gcc gcc-c++ cmake ninja-build \
    zsh tmux neovim \
    ripgrep fd-find fzf bat eza zoxide \
    # Python
    python3 python3-pip \
    # Fonts
    google-noto-sans-fonts jetbrains-mono-fonts \
    # Cursor theme
    adwaita-cursor-theme \
    # DBus (needed for waybar and other apps)
    dbus dbus-daemon dbus-tools dbus-x11 \
    # Process tools
    procps-ng \
    # Misc
    langpacks-en \
    && dnf clean all

# Set default cursor
ENV XCURSOR_THEME=Adwaita
ENV XCURSOR_SIZE=24

# Starship config
ENV STARSHIP_CONFIG=/home/dev/.config/starship/starship.toml

# Create user
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m -s /bin/zsh $USERNAME \
    && echo "$USERNAME ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# Create XDG runtime directory
RUN mkdir -p /run/user/${USER_UID} \
    && chown ${USERNAME}:${USERNAME} /run/user/${USER_UID} \
    && chmod 700 /run/user/${USER_UID}

# Desktop start script
COPY start-desktop.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/start-desktop.sh

# Default sway config
COPY sway-default-config /etc/sway/config.default

# Install starship prompt
RUN curl -sS https://starship.rs/install.sh | sh -s -- -y

# Install chezmoi
RUN sh -c "$(curl -fsLS get.chezmoi.io)" -- -b /usr/local/bin

# Create directories with correct ownership before switching user
RUN mkdir -p /home/${USERNAME}/.config /home/${USERNAME}/.cache /home/${USERNAME}/.local/bin /home/${USERNAME}/.local/share \
    && chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}

# Switch to user
USER $USERNAME
WORKDIR /home/$USERNAME

# Create config directories
RUN mkdir -p ~/.config/{sway,waybar,foot,wofi,kitty,alacritty} ~/.cache ~/.local/bin ~/.local/share/chezmoi

EXPOSE 6080 5900

CMD ["/usr/local/bin/start-desktop.sh"]
