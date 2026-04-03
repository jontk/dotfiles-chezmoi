# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [1.0.0] - 2026-04-03

### Added
- Initial public release
- Five profiles: minimal, personal, work, server, experimental
- Platform support: macOS, Fedora/RHEL, Ubuntu/Debian, NixOS
- chezmoi template-driven configuration with feature flags
- Comprehensive git pre-commit hook (secrets, large files, binary detection, linting)
- Shell aliases and functions for Docker, Kubernetes, and general use
- Desktop environment configs (Sway, Waybar, Wofi, Dunst)
- Terminal configs (Alacritty, Kitty, Foot, Ghostty)
- User-space tool installation (cargo, uv, eget, starship, etc.)
- GitHub Actions CI pipeline (shellcheck, template validation, Docker apply test)
- Secrets management via age encryption and 1Password integration
