#!/usr/bin/env zsh
# ZSH plugin loading mechanism
# Portable plugin loader that works without Nix or plugin managers

# Only run if we're in zsh
[[ -n "$ZSH_VERSION" ]] || return 0

# Plugin directory configuration
ZSH_PLUGINS_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/plugins"
mkdir -p "$ZSH_PLUGINS_DIR"

# Function to load a plugin
load_plugin() {
    local plugin_name="$1"
    local plugin_dir="$ZSH_PLUGINS_DIR/$plugin_name"
    
    # Skip if plugin directory doesn't exist
    [[ -d "$plugin_dir" ]] || return 1
    
    # Try common plugin file patterns
    local plugin_files=(
        "$plugin_dir/$plugin_name.plugin.zsh"
        "$plugin_dir/$plugin_name.zsh"
        "$plugin_dir/${plugin_name}.plugin.zsh"
        "$plugin_dir/plugin.zsh"
        "$plugin_dir/init.zsh"
        "$plugin_dir/$plugin_name.sh"
    )
    
    for file in "${plugin_files[@]}"; do
        if [[ -f "$file" ]]; then
            source "$file"
            return 0
        fi
    done
    
    return 1
}

# Function to install a plugin from GitHub
install_plugin() {
    local repo="$1"
    local plugin_name="${repo##*/}"
    local plugin_dir="$ZSH_PLUGINS_DIR/$plugin_name"
    
    if [[ -z "$repo" ]]; then
        echo "Usage: install_plugin <github_repo>"
        echo "Example: install_plugin zsh-users/zsh-syntax-highlighting"
        return 1
    fi
    
    if [[ -d "$plugin_dir" ]]; then
        echo "Plugin '$plugin_name' already exists. Use update_plugin to update."
        return 0
    fi
    
    if ! command -v git >/dev/null 2>&1; then
        echo "Error: git is required to install plugins"
        return 1
    fi
    
    echo "Installing plugin: $plugin_name"
    if git clone --depth=1 "https://github.com/$repo.git" "$plugin_dir"; then
        echo "Plugin '$plugin_name' installed successfully"
        load_plugin "$plugin_name"
    else
        echo "Failed to install plugin: $plugin_name"
        return 1
    fi
}

# Function to update a plugin
update_plugin() {
    local plugin_name="$1"
    local plugin_dir="$ZSH_PLUGINS_DIR/$plugin_name"
    
    if [[ -z "$plugin_name" ]]; then
        echo "Usage: update_plugin <plugin_name>"
        return 1
    fi
    
    if [[ ! -d "$plugin_dir" ]]; then
        echo "Plugin '$plugin_name' is not installed"
        return 1
    fi
    
    if [[ ! -d "$plugin_dir/.git" ]]; then
        echo "Plugin '$plugin_name' is not a git repository"
        return 1
    fi
    
    echo "Updating plugin: $plugin_name"
    if (cd "$plugin_dir" && git pull); then
        echo "Plugin '$plugin_name' updated successfully"
    else
        echo "Failed to update plugin: $plugin_name"
        return 1
    fi
}

# Function to remove a plugin
remove_plugin() {
    local plugin_name="$1"
    local plugin_dir="$ZSH_PLUGINS_DIR/$plugin_name"
    
    if [[ -z "$plugin_name" ]]; then
        echo "Usage: remove_plugin <plugin_name>"
        return 1
    fi
    
    if [[ ! -d "$plugin_dir" ]]; then
        echo "Plugin '$plugin_name' is not installed"
        return 1
    fi
    
    echo "Removing plugin: $plugin_name"
    if rm -rf "$plugin_dir"; then
        echo "Plugin '$plugin_name' removed successfully"
    else
        echo "Failed to remove plugin: $plugin_name"
        return 1
    fi
}

# Function to list installed plugins
list_plugins() {
    if [[ ! -d "$ZSH_PLUGINS_DIR" ]]; then
        echo "No plugins directory found"
        return 0
    fi
    
    echo "Installed plugins:"
    for plugin_dir in "$ZSH_PLUGINS_DIR"/*; do
        if [[ -d "$plugin_dir" ]]; then
            local plugin_name="${plugin_dir##*/}"
            local status="✓"
            
            # Check if plugin has a git repo and show status
            if [[ -d "$plugin_dir/.git" ]]; then
                local git_status
                git_status=$(cd "$plugin_dir" && git status --porcelain 2>/dev/null)
                if [[ -n "$git_status" ]]; then
                    status="⚠"
                fi
            else
                status="📁"
            fi
            
            echo "  $status $plugin_name"
        fi
    done
}

# Function to update all plugins
update_all_plugins() {
    echo "Updating all plugins..."
    for plugin_dir in "$ZSH_PLUGINS_DIR"/*; do
        if [[ -d "$plugin_dir" ]]; then
            local plugin_name="${plugin_dir##*/}"
            update_plugin "$plugin_name"
        fi
    done
}

# Auto-install essential plugins if they don't exist
auto_install_plugins() {
    local essential_plugins=(
        "zsh-users/zsh-syntax-highlighting"
        "zsh-users/zsh-autosuggestions"
        "zsh-users/zsh-completions"
    )
    
    for repo in "${essential_plugins[@]}"; do
        local plugin_name="${repo##*/}"
        local plugin_dir="$ZSH_PLUGINS_DIR/$plugin_name"
        
        if [[ ! -d "$plugin_dir" ]]; then
            echo "Auto-installing essential plugin: $plugin_name"
            install_plugin "$repo" >/dev/null 2>&1
        fi
    done
}

# Load plugins in correct order
load_plugins() {
    # Load completions first
    load_plugin "zsh-completions" 2>/dev/null
    
    # Load syntax highlighting (should be loaded before autosuggestions)
    load_plugin "zsh-syntax-highlighting" 2>/dev/null
    
    # Load autosuggestions
    load_plugin "zsh-autosuggestions" 2>/dev/null
    
    # Load any other plugins
    for plugin_dir in "$ZSH_PLUGINS_DIR"/*; do
        if [[ -d "$plugin_dir" ]]; then
            local plugin_name="${plugin_dir##*/}"
            # Skip already loaded plugins
            case "$plugin_name" in
                zsh-completions|zsh-syntax-highlighting|zsh-autosuggestions)
                    continue
                    ;;
                *)
                    load_plugin "$plugin_name" 2>/dev/null
                    ;;
            esac
        fi
    done
}

# Initialize plugins if in interactive shell
if [[ -o interactive ]]; then
    # Auto-install essential plugins if git is available and we're not in a restricted environment
    if command -v git >/dev/null 2>&1 && [[ -w "$ZSH_PLUGINS_DIR" ]]; then
        # Only auto-install if we don't have any plugins yet
        if [[ ! -d "$ZSH_PLUGINS_DIR/zsh-syntax-highlighting" ]]; then
            auto_install_plugins
        fi
    fi
    
    # Load all available plugins
    load_plugins
fi

# Plugin configuration
if [[ -d "$ZSH_PLUGINS_DIR/zsh-autosuggestions" ]]; then
    # Configure autosuggestions
    ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
    ZSH_AUTOSUGGEST_STRATEGY=(history completion)
    ZSH_AUTOSUGGEST_USE_ASYNC=1
    
    # Key bindings for autosuggestions
    bindkey '^I' complete-word              # Tab for completion
    bindkey '^[[Z' autosuggest-accept       # Shift-Tab to accept suggestion
fi