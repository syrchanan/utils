# Global Preferences

## Communication
- Be concise and direct. Skip pleasantries and high-level summaries unless asked.
- If a task has ambiguous requirements or architectural trade-offs, ask questions before writing code.
- For large changes spanning multiple files, use plan mode to draft a comprehensive roadmap before beginning.

## Engineering
- Keep changes minimal and scoped strictly to the ask; do not refactor or reformat unrelated code.
- Favor simple, explicit, readable implementations over heavy abstractions.
- Write comments only to explain non-obvious "why" decisions, not what code does.

## Workflow and verification
- Prefer modern CLI tools when available (`rg` over `grep`, `fd` over `find`, `uv` over `pip`).
- Always work inside a reproducible environment, such as venv, renv, Pkg, etc.
- When creating a PR, put your commentary inside a collapsible `<details>` block, with the model name as the summary; the user may add their own note above it. Keep the blank line after `</summary>` so the markdown inside renders:
  ```html
  <details>
  <summary>MODEL NAME</summary>

  REST OF CONTENT

  </details>
  ```

## Hard Boundaries (Never Do Without Asking)
- Never run destructive git commands (`push --force`, `reset --hard`, `clean -fd`).
- Never read, echo, or commit `.env` files or any other secret.
- Never install new global packages or modify system-level configurations.
- Never go through any one-way doors; ensure that whatever you do is undo-able.
- Never write file trees in documentation, that information is the same as running `ls` and therefore adds nothing.

