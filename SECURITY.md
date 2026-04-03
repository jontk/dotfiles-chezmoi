# Security Policy

## Scope

This repository manages shell configurations, SSH/GPG settings, git hooks, and development tool configurations. Security issues in these dotfiles could affect:

- SSH key handling and agent configuration
- GPG key management and commit signing
- Git pre-commit hooks (which execute on every commit)
- Shell environment variables and PATH manipulation
- Secrets management (age encryption, 1Password integration)

## Reporting a Vulnerability

If you discover a security issue, please report it responsibly:

**Email**: git@jontk.com

Please include:
- Description of the vulnerability
- Steps to reproduce
- Which files/templates are affected
- Potential impact

I will acknowledge receipt within 48 hours and aim to provide a fix or mitigation within 7 days for critical issues.

## What Qualifies as a Security Issue

- Secrets or credentials accidentally committed (even in templates)
- Shell injection vulnerabilities in scripts or aliases
- Unsafe file permissions set by chezmoi templates
- Pre-commit hook bypasses that could miss sensitive data
- Unsafe handling of user input in shell functions
- PATH manipulation that could lead to command hijacking

## What Does NOT Qualify

- Issues requiring local root access (dotfiles run as the current user)
- Personal preference disagreements about security defaults
- Vulnerabilities in upstream tools (chezmoi, shellcheck, etc.) -- report those upstream

## Security Practices in This Repo

- The pre-commit hook scans for secrets, API keys, private keys, and credentials
- Sensitive directories (`private_dot_gnupg/`, `private_dot_ssh/`) use chezmoi's private file mode
- No secrets are stored in plaintext; age encryption or 1Password references are used
- Shell scripts are linted with shellcheck in CI
- Destructive operations (namespace deletion, container removal) require confirmation prompts
