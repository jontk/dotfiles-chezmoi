# Contributing

Thanks for your interest in contributing to these dotfiles! Whether you're fixing a bug, adding a feature, or improving documentation, contributions are welcome.

## Getting Started

### Prerequisites

- [chezmoi](https://www.chezmoi.io/install/) installed
- [shellcheck](https://www.shellcheck.net/) for linting shell scripts
- Docker (optional, for testing in isolation)

### Local Development Setup

```bash
# Fork and clone the repository
git clone git@github.com:YOUR_USERNAME/dotfiles-chezmoi.git
cd dotfiles-chezmoi

# Test template rendering without applying
chezmoi init --source "$PWD" --destination /tmp/chezmoi-test \
  --exclude scripts,externals --no-tty --force --dry-run
```

### Testing Locally

#### Quick lint check

```bash
shellcheck -x dot_git_template/hooks/executable_pre-commit
shellcheck -x dot_config/shell/aliases.sh
shellcheck -x dot_config/docker/aliases.sh
shellcheck -x dot_config/kubernetes/kubectl-aliases.sh
```

#### Test a specific profile in Docker

```bash
docker run --rm -v "$PWD":/dotfiles:ro ubuntu:22.04 bash -c '
  apt-get update -qq && apt-get install -y -qq git curl sudo vim zsh unzip
  sh -c "$(curl -fsLS get.chezmoi.io)" -- -b ~/bin
  export PATH="$HOME/bin:$PATH"

  mkdir -p ~/.config/chezmoi
  cat > ~/.config/chezmoi/chezmoi.toml <<EOF
[data]
    profile = "minimal"
    hostname = "test"
    github_username = "testuser"
    [data.git]
        email = "test@example.com"
        name = "Test User"
        githubKey = ""
        gitlabKey = ""
        workEmail = ""
        workName = ""
        workGpgKey = ""
    [data.features]
        editors_full = false
        docker = false
        kubernetes = false
        nodejs = false
        python = false
        golang = false
        ruby = false
        java = false
        compilers = false
        fonts = false
        starship = false
        tmux = false
        beta_features = false
        work_specific = false
    [data.shell]
        prompt_style = "simple"
        enable_functions = true
    [data.editor]
        default = "vim"
    [data.work]
        username = ""
        sshKey = ""
EOF

  chezmoi init --apply --source /dotfiles --exclude scripts,externals --force
  echo "Applied successfully."
'
```

Replace `"minimal"` with any profile (`personal`, `work`, `server`, `experimental`) and adjust the feature flags to match (see `.chezmoi.toml.tmpl` for the mapping).

## Making Changes

### Workflow

1. Create a branch from `main`
2. Make your changes
3. Run `shellcheck` on any modified shell scripts
4. Test with at least the `minimal` and `personal` profiles
5. Open a pull request

### Adding a New Profile

1. Add the profile definition to `.chezmoidata/profiles.yaml`
2. Add the feature flag block to `.chezmoi.toml.tmpl`
3. Add shell/editor settings for the profile in `.chezmoi.toml.tmpl`
4. Add any profile-specific ignore rules to `.chezmoiignore`
5. Test with `chezmoi apply --dry-run`

### Adding a New Configuration File

```bash
# For static files
chezmoi add ~/.config/myapp/config.toml

# For templated files (needs chezmoi variables)
chezmoi add --template ~/.config/myapp/config.toml
```

Then commit the resulting file in the chezmoi source directory.

### Modifying Shell Scripts

All shell scripts must pass `shellcheck`. Key conventions:

- Add `# shellcheck shell=bash` at the top of sourced files (not executed directly)
- Use `command -v` instead of `which` for checking tool availability
- Quote all variables: `"$var"` not `$var`
- Separate `local` declarations from assignments: `local var; var=$(cmd)`
- Use `[[ ]]` for conditionals (bash/zsh), not `[ ]`

### Modifying Templates

chezmoi templates use Go's `text/template` syntax. Key patterns used in this repo:

```
{{- if .features.docker }}       # Feature flag conditional
{{ .git.email | quote }}          # Data interpolation
{{- if eq .chezmoi.os "darwin" }} # OS-specific logic
```

When modifying templates, strip directives and lint the output:

```bash
sed -E 's/\{\{[^}]*\}\}//g' your_file.tmpl | shellcheck -s bash -
```

## Pull Request Guidelines

- Keep PRs focused on a single concern
- Include the profile(s) and OS(es) you tested on
- Follow [Conventional Commits](https://www.conventionalcommits.org/) for commit messages
- CI must pass before merge

## Questions?

Open an issue if something is unclear or you need help getting started.
