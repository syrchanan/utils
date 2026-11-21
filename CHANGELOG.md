# Changelog

All notable changes to this project will be documented in this file (via AI, minimally reviewed by a human).

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.4.2] - 2026-11-21
### Added
- `dotfiles/bash/libs/10_tools.sh`: `dotfiles list [regex]` lists every script in `bin/` (with the description from its header comment), every alias and function from `bash/libs/` and `~/.bashrc.local` (aliases show their current value, or that they are not set in this shell), filtered by a regex on name or description (smart case). `dotfiles -h` / `--help` prints usage.
- `dotfiles/bash/libs/40_complete.sh`: completion for `dotfiles` subcommands and the names `dotfiles list` shows.
- `dotfiles/ai/AGENTS.md`: rule against file trees in documentation.

### Changed
- `README.md`, `dotfiles/README.md`, `.devcontainer/README.md`: removed file-by-file listings, per the new rule; kept what a listing can't show (how the loader orders and overrides things, where new scripts, aliases and tools go) and pointed to `dotfiles list`.

### Fixed
- `dotfiles/install.sh`: `--dry-run` no longer prints past-tense results ("Linked …", "Wrote …", "Done!") for changes it didn't make; it prints only the `[dry-run]` lines and ends with "Dry run: nothing was changed." `--tools --dry-run` says "Would install" instead of "Installing".

## [0.4.1] - 2026-11-21
### Added
- `dotfiles/bin/notes`: read notes written by `note`. Commands: `today` (default), `show <when>`, `grep <pattern>` (smart case, whole multi-line notes), `topics` (tree with counts), `recap [-n N]` (last N days, default 2), `tags` (`#tag` counts), `todo [-a]`, `done <pattern>` / `undone <pattern>` (mark the single matching todo `[x]` or back to `[ ]`; lists candidates with `--line file:line` when several match), `help [command]`. Filters `-s`/`-u`/`-t`; `--md` (markdown lists and tables, for pasting) and `--tsv` output; colors on terminals (`NO_COLOR` respected); output taller than the terminal goes through `less -RFX` (`NOTES_PAGER` to change, `cat` to turn off); exit 1 when nothing matches, with a hint on what to try.
  - `todo` shows each open todo's age (`3d`, `2w`, `4mo`), highlighted from a week old; `recap` ends with the open-todo count and the oldest one's age.
- `dotfiles/lib/notes.sh`: shared date-spec parsing (`today`, `yesterday`, `-N`, `YYYY-MM-DD`, `YYYY-MM`, `YYYY`, `A..B`, anything `date -d` reads) and topic validation for `note` and `notes`.
- `dotfiles/bash/libs/40_complete.sh`: tab completion for `note` and `notes` (commands, options, nested topic paths, and `#tags` already used, also inside quotes).

### Changed
- `dotfiles/bin/note`: topics nest to any depth (`-t work/clientA/q4`) and are validated; `-x` adds a todo (`- [ ] HH:MM text`); `-D when` writes to another day; `-T HH:MM` sets the time; `-u` removes the last entry; opening the editor on a new file and leaving it empty no longer leaves a header-only file (or empty topic folders) behind; `$EDITOR` may carry flags (`code --wait`); repairs a missing trailing newline before appending; new files' header includes the topic; prints the path relative to the notes root; `--help` and fuller help text.
- `README.md`, `dotfiles/README.md`: documented the above.

### Fixed
- `dotfiles/ai/AGENTS.md`: the PR commentary rule had malformed closing tags (`<summary/>`, `<details/>`), so the block didn't collapse; it now shows the exact `<details>` layout to use.

## [0.4.0] - 2026-11-21
### Added
- `dotfiles/bin/` on PATH (via `loader.sh`, which now also exports `DOTFILES_DIR`), with scripts:
  - `gclean`: delete local branches whose remote is gone, plus their worktrees; keeps dirty worktrees; dry run unless `--yes`.
  - `tolf`: convert CRLF to LF in files or recursively; skips `.git` and binaries; dry run unless `--yes`.
  - `gi`: append `.gitignore` templates from `dotfiles/gitignore/` (python, r, julia, node from toptal; quarto hand-written); safe to rerun.
  - `note`: timestamped notes in `$NOTES_DIR/[topic/]YYYY-MM-DD.md`.
  - `mkvenv`: `uv venv` plus `uv sync` or `uv pip install -r requirements.txt`.
- `dotfiles/bash/libs/30_env.sh`: venv auto-activate (off via `.noautovenv` or `DOTFILES_AUTOVENV=0`) and `JULIA_PROJECT=@.`.
- `dotfiles/bash/libs/10_tools.sh`: `dotfiles update` (pull and reload).
- `dotfiles/bash/libs/20_alias.sh`: `py` (`uv run python`), `ll` via eza, `fd`/`bat` for Debian binary names, each only when the tool exists.
- `dotfiles/install.sh`: `--dry-run`, `--uninstall` and `--tools` (apt install from `dotfiles/tools.txt`).
- `dotfiles/install.sh`: `--ai` also links Goose (`~/.config/goose/.goosehints`) and writes a Cursor rule (`~/.cursor/rules/global-agents.mdc`).
- `dotfiles/tools.txt`: CLI tool list with apt and choco package names.
- `dotfiles/bash/.bashrc.local.example`: template for machine-local settings.

### Changed
- `dotfiles/ai/CLAUDE.md` renamed to `dotfiles/ai/AGENTS.md` as the single source for all agents; `~/.claude/CLAUDE.md` now links to it.
- `dotfiles/bash/libs/20_alias.sh`: `here` and `resu` are only defined when `explorer.exe` / `sudo` exist.
- `README.md`, `dotfiles/README.md`: documented the above.

## [0.3.1] - 2026-11-13
### Changed
- Repository renamed from `ai_tooling` to `utils` to reflect its broader scope as a general personal utilities repo.
- `.devcontainer/Dockerfile`: Ralph sparse checkout now clones `syrchanan/utils`.
- `README.md`: Retitled and rescoped the intro for the rename.
- `dotfiles/README.md`: Retitled from `utils` to `dotfiles` to avoid confusion with the repo name.
- Line endings normalized to LF repo-wide via new `.gitattributes` (`* text=auto eol=lf`).

## [0.3.0] - 2026-11-13
### Added
- `dotfiles/install.sh`: Installer that appends `loader.sh` to `~/.bashrc` (backing it up first). Takes `--bash`, `--ai`, `--all` and `-h`, and runs everything when no flags are given.
- `dotfiles/install.sh`: `--ai` symlinks `dotfiles/ai/CLAUDE.md` to `~/.claude/CLAUDE.md`, backing up any existing file. Idempotent.
- `dotfiles/bash/loader.sh`: Sources every `bash/libs/*.sh`, then `~/.bashrc.local` if present.
- `dotfiles/bash/libs/10_tools.sh`, `dotfiles/bash/libs/20_alias.sh`: Shell helpers and aliases.
- `dotfiles/ai/CLAUDE.md`: Global Claude Code preferences.

### Changed
- `utils/` renamed to `dotfiles/`; `utils/alias.sh` replaced by `dotfiles/bash/libs/`.
- `dotfiles/README.md`: Documented install flags.
- `README.md`: Replaced the stale `.github/` section with `dotfiles/`, pointed Agent Rules at `dotfiles/ai/CLAUDE.md`, described Goose and Claude Code as optional devcontainer CLIs, removed the stale health-check mention, and fixed the `config.json` list formatting.

### Fixed
- `dotfiles/bash/loader.sh`: Fixed relative symlink resolution (missing `$` in `$_DOTFILES_SOURCE`).

### Removed
- `.github/AGENTS.md`: Superseded by `dotfiles/ai/CLAUDE.md`.

## [0.2.0] - 2026-02-03
### Added
- `ralph/ralph-loop.sh`: Bash script for running the Ralph Loop (multi-model, iterative agent workflow).
- `ralph/ralph-work.yaml`: Goose recipe for Ralph work phase (single iteration, fresh context).
- `ralph/ralph-review.yaml`: Goose recipe for Ralph review phase (cross-model review, SHIP/REVISE decision).
- `.devcontainer/config.json`: Devcontainer configuration file, enabling custom languages/platforms (all default to false).
- `.devcontainer/README`: Devcontainer specific configuration instructions.

### Changed
- `.devcontainer/Dockerfile`: Improved Julia install (added permissions and symlink for Julia binary), updated Ralph recipe move to use `mv ralph/*` instead of `mv ralph`, added claude code as an option, removed healthcheck script for now.
- `.devcontainer/devcontainer.json`: Updated `postStartCommand` to pipe output to `/tmp/poststart.log` for easier debugging and troubleshooting of dependency installation.
- `.devcontainer/poststart.sh`: Refactored to use a `process_files` function for each dependency type, added command existence checks before running actions, and improved output messages.

### Fixed
- `.devcontainer/Dockerfile`: Fixed environment variable syntax for Docker ENV.
- `.devcontainer/Dockerfile`: Fixed `export` for PROMPT_COMMAND in bashrc.
- `.devcontainer/Dockerfile`: Fixed `chown` to recursively set ownership for developer home.
- `.devcontainer/poststart.sh`: Fixed workspace path from `/workspace` to `/workspaces` for correct recursive search.

## [0.1.1] - 2026-01-12
### Added
- `.devcontainer/poststart.sh`: Post-start script to auto-install detected Python, R, and Julia dependencies for all projects in the workspace.

### Changed
- `.devcontainer/Dockerfile`: Added container labels, improved welcome banner, and clarified goose install steps. Now recommends using `uv` for Python package management. General cleanup and documentation improvements.
- `.devcontainer/devcontainer.json`: Added `postStartCommand` to run `poststart.sh` after container start. Cleaned up comments.

### Removed
- `notes.md`: Removed as content was migrated or completed.
- `WIP_get_creds.sh`: Removed obsolete credentials helper script.

## [0.1.0] - 2026-01-11
### Added
- `WIP_get_creds.sh`: Toy script working towards copying existing goose credentials into the devcontainer for seamless authentication.

### Changed
- `.devcontainer/Dockerfile`: R (latest) and Julia (latest via `juliaup`) now included in the devcontainer for multi-language support.
- `.devcontainer/devcontainer.json`: Julia extension for VS Code/Positron added to the recommended list.
- `README.md`: Updated to reflect the addition of R and Julia in the devcontainer setup.
- `notes.md`: Removed notes on completed TODOs.

### Removed
- `upgrades.md`: Planned upgrades completed.

## [0.0.1] - 2025-12-16
### Added
- `.devcontainer/Dockerfile`: Python devcontainer with Goose CLI, common dev tools, and Python packages.
- `.devcontainer/devcontainer.json`: VS Code/Positron devcontainer config with Python, Goose, and recommended extensions.
- `.github/AGENTS.md`: Global agent rules and standards for code, naming, and collaboration.
- `notes.md`: Implementation notes, platform caveats, and TODOs for devcontainer and agent setup.

### Changed
- Expanded `README.md` to document new devcontainer and agent configuration files, usage, and standards.