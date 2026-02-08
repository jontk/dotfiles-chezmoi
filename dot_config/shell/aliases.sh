# Shared shell aliases
# This file is sourced by both bash and zsh

# Core utilities - safe enhancements only
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias df='df -h'
alias du='du -h'
alias free='free -h'

# Explicit aliases for common flags (don't override defaults)
alias mkdirp='mkdir -pv'
alias cpi='cp -i'
alias mvi='mv -i'
alias rmi='rm -i'
alias psa='ps aux'

# Platform-specific aliases
case "$(uname -s)" in
    Darwin*)
        # macOS specific
        alias ls='ls -G'
        alias localip='ipconfig getifaddr en0'
        alias ports='lsof -iTCP -sTCP:LISTEN -n -P'
        alias updatedb='sudo /usr/libexec/locate.updatedb'
        alias flushdns='sudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder'
        alias showfiles='defaults write com.apple.finder AppleShowAllFiles YES && killall Finder'
        alias hidefiles='defaults write com.apple.finder AppleShowAllFiles NO && killall Finder'
        ;;
    Linux*)
        # Linux specific
        alias ls='ls --color=auto'
        alias localip='hostname -I | awk "{print \$1}"'
        alias ports='ss -tulanp'
        # Clipboard - Wayland or X11
        if [[ -n "$WAYLAND_DISPLAY" ]]; then
            alias pbcopy='wl-copy'
            alias pbpaste='wl-paste'
        else
            alias pbcopy='xclip -selection clipboard'
            alias pbpaste='xclip -selection clipboard -o'
        fi
        ;;
esac

# Directory navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd ~'
alias -- -='cd -'

# Git aliases (if git is available)
if command -v git >/dev/null 2>&1; then
    alias gst='git status'
    alias ga='git add'
    alias gcm='git commit'
    alias gp='git push'
    alias glog='git log --oneline --graph --decorate'
    alias gd='git diff'
    alias gb='git branch'
    alias gco='git checkout'
    alias gsw='git switch'
    alias grs='git restore'
fi

# Docker aliases loaded from ~/.config/docker/aliases.sh

# Network aliases (ports and localip defined in platform-specific section above)
alias myip='curl -s ifconfig.me'
alias ping5='ping -c 5'
alias wgetc='wget -c'
