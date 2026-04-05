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
├── .chezmoi.toml.tmpl              # Profile selection and feature flags
├── .chezmoidata/
│   ├── profiles.yaml               # Profile definitions
│   └── tools.yaml                  # Version pinning for all user-space tools
├── .chezmoiexternal.toml           # External dependencies (vim-plug, TPM, shell completions)
├── .chezmoiignore                  # OS/profile-specific file exclusions
│
├── run_once_before_10-install-packages.sh.tmpl  # System packages (apt/dnf/nix)
├── run_onchange_15-install-user-tools.sh.tmpl   # User-space CLI tools
├── run_onchange_20-setup-shell.sh.tmpl          # Post-install shell setup
│
├── dot_bashrc.tmpl                 # Bash configuration
├── dot_zshrc.tmpl                  # Zsh configuration
├── dot_gitconfig.tmpl              # Git configuration
├── dot_tmux.conf.tmpl              # Tmux configuration
├── dot_vimrc                       # Vim configuration
│
├── dot_config/
│   ├── shell/                      # Shared aliases, functions, environment
│   ├── nvim/                       # Neovim (init.lua + keymaps)
│   ├── starship.toml               # Starship prompt
│   ├── alacritty/                  # Alacritty terminal
│   ├── kitty/                      # Kitty terminal
│   ├── ghostty/                    # Ghostty terminal
│   ├── docker/                     # Docker config
│   ├── kubernetes/                 # Kubernetes config
│   └── ...                         # sway, waybar, dunst, gtk, etc.
│
├── private_dot_ssh/                # SSH configuration
└── private_dot_gnupg/              # GPG agent configuration
```

## User-Space Tools

For **personal**, **work**, and **experimental** profiles, a comprehensive set of CLI tools is installed to `~/.local/bin/` and language-specific directories. Tool versions are pinned in `.chezmoidata/tools.yaml`.

### Installation Pipeline

The installation runs in three stages:

1. **System packages** (`run_once_before_10-install-packages.sh.tmpl`) — OS package manager installs (apt, dnf, or nix-darwin)
2. **User-space tools** (`run_onchange_15-install-user-tools.sh.tmpl`) — binary downloads and language toolchains
3. **Shell setup** (`run_onchange_20-setup-shell.sh.tmpl`) — fzf keybindings, tmux plugins, Node.js LTS

### CLI Tools (via eget)

[eget](https://github.com/zyedidia/eget) downloads pre-built binaries from GitHub releases:

| Tool | Description |
|------|-------------|
| ripgrep | Fast recursive search |
| fd | Fast file finder |
| bat | Cat with syntax highlighting |
| eza | Modern ls replacement |
| fzf | Fuzzy finder |
| delta | Git diff viewer |
| lazygit | Terminal UI for git |
| jq / yq | JSON/YAML processors |
| zoxide | Smarter cd |
| gh | GitHub CLI |
| starship | Cross-shell prompt |
| buf | Protobuf toolchain |
| vhs | Terminal GIF recorder |
| cilium-cli | Cilium networking CLI |

### Language Toolchains

| Tool | Purpose | Install method |
|------|---------|----------------|
| fnm | Node.js version manager | eget binary |
| bun | JavaScript runtime/package manager | Official installer |
| uv | Python package/version manager | Official installer |
| Go | Go toolchain | Direct download from go.dev |
| rustup | Rust toolchain manager | Official installer |
| rbenv | Ruby version manager | Git clone |
| SDKMAN | JVM version manager | Official installer |
| Spack | Compiler package manager | Git clone |

### Go Development Tools (via `go install`)

Installed when the `golang` feature is enabled:

- **Linters**: golangci-lint, staticcheck, gosec, revive, gocyclo, ineffassign, unconvert, misspell
- **Testing**: mockgen, mockery, ginkgo
- **Code generation**: sqlc, gqlgen, goverter, oapi-codegen, controller-gen
- **Protobuf**: protoc-gen-go, protoc-gen-go-grpc, protoc-gen-grpc-gateway, protoc-gen-openapiv2, protoc-gen-doc
- **Release**: goreleaser

### AI Coding Assistants (via `bun install -g`)

| Package | Command |
|---------|---------|
| @anthropic-ai/claude-code | `claude` |
| @google/gemini-cli | `gemini` |
| @openai/codex | `codex` |
| @playwright/cli | `playwright-cli` |

### Nerd Fonts

JetBrainsMono, FiraCode, and Hack Nerd Fonts are installed to the system font directory.

### Adding or Updating a Tool

1. Add or update the version in `.chezmoidata/tools.yaml`
2. If it's a new tool, add the install logic to `run_onchange_15-install-user-tools.sh.tmpl`
3. Run `chezmoi apply` — the version hash change triggers re-installation

### External Dependencies

`.chezmoiexternal.toml` manages git repos and remote files that chezmoi fetches automatically:

| Dependency | Path | Refresh |
|------------|------|---------|
| vim-plug | `~/.vim/autoload/plug.vim` | Weekly |
| TPM (tmux plugin manager) | `~/.config/tmux/plugins/tpm` | Weekly |
| git-prompt.sh | `~/.config/shell/git-prompt.sh` | Monthly |
| git-completion.bash | `~/.config/shell/git-completion.bash` | Monthly |
| zsh git completion | `~/.config/shell/_git` | Monthly |

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
- **macOS**: nix-darwin for system packages; user-space tools installed independently
- **Fedora/RHEL/Rocky/AlmaLinux**: DNF package management
- **Ubuntu/Debian**: APT package management
- **NixOS**: System packages managed declaratively; user-space tools installed independently

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
