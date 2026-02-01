# Shared shell aliases
# This file is sourced by both bash and zsh

# Core utilities
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias mkdir='mkdir -pv'
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'
alias df='df -h'
alias du='du -h'
alias free='free -h'
alias ps='ps aux'
alias top='top -o cpu'

# Platform-specific aliases
case "$(uname -s)" in
    Darwin*)
        # macOS specific
        alias ls='ls -G'
        alias updatedb='sudo /usr/libexec/locate.updatedb'
        alias flushdns='sudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder'
        alias showfiles='defaults write com.apple.finder AppleShowAllFiles YES && killall Finder'
        alias hidefiles='defaults write com.apple.finder AppleShowAllFiles NO && killall Finder'
        ;;
    Linux*)
        # Linux specific
        alias ls='ls --color=auto'
        alias pbcopy='xclip -selection clipboard'
        alias pbpaste='xclip -selection clipboard -o'
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
    alias gs='git status'
    alias ga='git add'
    alias gc='git commit'
    alias gp='git push'
    alias gl='git log --oneline --graph --decorate'
    alias gd='git diff'
    alias gb='git branch'
    alias gco='git checkout'
fi

# Docker aliases (if docker is available)
if command -v docker >/dev/null 2>&1; then
    alias dps='docker ps'
    alias dpa='docker ps -a'
    alias di='docker images'
    alias dex='docker exec -it'
    alias dlog='docker logs'
fi

# Network and system aliases
alias ports='netstat -tulanp'
alias myip='curl -s ifconfig.me'
alias localip='hostname -I | awk "{print \$1}"'
alias ping='ping -c 5'
alias wget='wget -c'

# Function-based aliases
alias extract='_extract'
alias backup='_backup'
alias search='_search'
