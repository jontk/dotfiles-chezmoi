## Commits and Pull Requests

- No AI attribution: no `Co-Authored-By` trailers for Claude, Codex or any
  other agent, and no "Generated with ..." footers.
- Don't mention Claude, Codex or AI in commit messages, PR titles, PR
  descriptions or branch names.
- Don't @-mention people in PRs, issues or commits unless asked; put roles,
  placeholders and package names in backticks.
{{- if eq .profile "work" }}
- Name branches `jon/<short-kebab-topic>` unless the repo uses another
  convention.
{{- end }}
