# Dotfiles (chezmoi)

Modern, reproducible dotfiles management using [chezmoi](https://www.chezmoi.io/).

## Overview

This repository contains my personal dotfiles, migrated from a custom bash-based system to chezmoi for better:
- **Reproducibility**: Single command setup on new machines
- **Multi-machine support**: Profile-based configuration for different environments
- **Secrets management**: Encrypted files with age or integration with password managers
- **Template-driven**: Dynamic configuration based on machine/OS/profile

## Profiles

Five profiles are available to suit different environments:

| Profile | Description | Modules |
|---------|-------------|---------|
| **minimal** | Basic shell and git only | shell, git |
| **personal** | Full-featured dev environment | shell, git, editors, tmux, starship, nodejs, python, golang |
| **work** | Professional environment with company-specific settings | Same as personal + work-specific configurations |
| **server** | Lightweight for remote/server environments | shell, git, editors (minimal) |
| **experimental** | Cutting-edge tools and beta features | Full stack + neovim, latest versions |

## Quick Start

### First-Time Setup

On a **new machine**:

```bash
# Install chezmoi and apply dotfiles in one command
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply jontk/dotfiles-chezmoi
```

You'll be prompted for:
- Profile selection (minimal/personal/work/server/experimental)
- Git name and email
- Work-specific Git credentials (if work profile selected)

### Existing Machine

If you already have chezmoi installed:

```bash
# Initialize from this repository
chezmoi init jontk/dotfiles-chezmoi

# Preview changes
chezmoi diff

# Apply dotfiles
chezmoi apply
```

## Usage

### Common Commands

```bash
# Check what changes would be made
chezmoi diff

# Apply changes
chezmoi apply

# Edit a file (automatically updates repository)
chezmoi edit ~/.bashrc

# Add a new file to chezmoi
chezmoi add ~/.myconfig

# Update from remote repository
chezmoi update

# Check for problems
chezmoi doctor
```

### Profile Switching

To switch profiles, reinitialize chezmoi:

```bash
# Reinitialize and select a different profile
chezmoi init

# Apply the new configuration
chezmoi apply
```

## Directory Structure

```
~/.local/share/chezmoi/          # Chezmoi source directory
├── .chezmoi.toml.tmpl           # Machine-specific configuration prompts
├── .chezmoidata/                # Shared data
│   └── profiles.yaml            # Profile definitions
├── .chezmoiignore               # OS/profile-specific ignores
├── dot_bashrc.tmpl              # Bash configuration template
├── dot_zshrc.tmpl               # Zsh configuration template
├── dot_gitconfig.tmpl           # Git configuration template
├── dot_gitignore_global         # Global gitignore
├── dot_tmux.conf.tmpl           # Tmux configuration
├── dot_config/
│   ├── shell/
│   │   ├── aliases.sh           # Shared shell aliases
│   │   └── functions.sh.tmpl    # Shell functions (profile-aware)
│   └── starship.toml            # Starship prompt configuration
├── run_once_before_10-install-packages.sh.tmpl  # One-time package install
└── run_onchange_20-setup-shell.sh.tmpl          # Shell setup script
```

## Features by Profile

### Minimal
- Basic shell configuration (bash/zsh)
- Git with aliases
- Simple prompt
- Core aliases and utilities

### Personal
- Everything in minimal
- Starship prompt with git integration
- Tmux with custom configuration
- Node.js, Python, Go development tools
- Docker and Kubernetes tools
- Full function library
- Custom welcome message

### Work
- Everything in personal
- Work-specific git configuration
- GPG commit signing support
- Company registry/mirror support
- Enhanced validation and logging
- Work-specific command aliases

### Server
- Lightweight configuration
- No fancy prompts (simple prompt)
- Minimal dependencies
- Essential tools only
- Fast shell startup

### Experimental
- Everything in personal
- Neovim instead of vim
- Latest versions of tools
- Beta features enabled
- Debug mode
- Experimental commands

## Platform Support

Tested on:
- **macOS**: Homebrew package management
- **Fedora/RHEL/Rocky/AlmaLinux**: DNF package management
- **Ubuntu/Debian**: APT package management
- **NixOS**: System packages managed declaratively; user-space tools (cargo, uv, eget, starship, etc.) installed independently

Platform-specific configurations are handled automatically through chezmoi templates.

## Secrets Management

### Using age (Recommended)

```bash
# Generate age key
age-keygen -o ~/.config/chezmoi/key.txt

# Edit .chezmoi.toml to add age configuration
chezmoi edit-config

# Add these lines:
# [age]
#     identity = "~/.config/chezmoi/key.txt"
#     recipient = "age1..."  # Your public key from key.txt

# Encrypt a file
chezmoi add --encrypt ~/.ssh/config
```

### Using 1Password

```bash
# In templates, reference secrets:
{{ onepasswordRead "op://Private/GitHub Token/credential" }}
```

## Customization

### Local Overrides

Create these files for local customizations (not managed by chezmoi):

- `~/.bashrc.local` - Local bash configuration
- `~/.zshrc.local` - Local zsh configuration
- `~/.gitconfig_work` - Work-specific git config
- `~/.tmux.conf.local` - Local tmux configuration

These files are sourced automatically but ignored by chezmoi.

### Adding New Files

```bash
# Add a file to chezmoi
chezmoi add ~/mynewfile

# Add as a template (if it needs variable substitution)
chezmoi add --template ~/mynewfile
```

## Migration from Old Dotfiles

If you're migrating from the old bash-based dotfiles repository:

1. **Backup your current setup**:
   ```bash
   cd ~/dotfiles
   ./install.sh --dry-run  # Verify current state
   ```

2. **Initialize chezmoi** (this repository):
   ```bash
   chezmoi init --apply jontk/dotfiles-chezmoi
   ```

3. **Verify**:
   ```bash
   chezmoi diff
   ```

4. **Keep old repo as reference**:
   ```bash
   mv ~/dotfiles ~/dotfiles.old
   ```

The old repository remains unchanged and can serve as a reference or fallback.

## Troubleshooting

### Check for issues
```bash
chezmoi doctor
```

### View what chezmoi would do
```bash
chezmoi apply --dry-run --verbose
```

### Reset to repository state
```bash
chezmoi init --apply --force
```

### Debug template rendering
```bash
chezmoi execute-template < ~/.local/share/chezmoi/dot_bashrc.tmpl
```

## Development

### Testing on a Fresh System

Use Docker or a VM to test:

```bash
docker run -it ubuntu:latest bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply jontk/dotfiles-chezmoi
```

### Adding a New Profile

1. Edit `.chezmoi.toml.tmpl` to add profile option
2. Update `.chezmoidata/profiles.yaml` with profile definition
3. Add profile-specific conditionals to templates
4. Test with `chezmoi apply --dry-run`

## Resources

- [chezmoi Documentation](https://www.chezmoi.io/)
- [chezmoi Quick Start](https://www.chezmoi.io/quick-start/)
- [Template Syntax](https://www.chezmoi.io/user-guide/templating/)
- [Original dotfiles repository](https://github.com/jontk/dotfiles) (archived)

## License

MIT License - See LICENSE file for details

## Author

Jon Thor Kristinsson - [GitHub](https://github.com/jontk)

---

**Note**: This is a migration of my [original bash-based dotfiles](https://github.com/jontk/dotfiles) to chezmoi for better reproducibility and multi-machine management.
