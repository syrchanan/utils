# dotfiles

Shell config, snippets and shorthands I rely on in WSL/linux, plus global AI agent instructions (`ai/`).

## usage

run install.sh to set things up; with no flags it installs `--bash` and `--ai`

```bash
./install.sh                # --bash and --ai
./install.sh --bash         # append loader.sh to ~/.bashrc
./install.sh --ai           # link ai/AGENTS.md into Claude Code, Goose and Cursor
./install.sh --tools        # sudo apt install everything in tools.txt (not part of the default)
./install.sh --dry-run      # print what would change, change nothing
./install.sh --uninstall    # undo --bash and --ai (combine with a step flag to undo just that)
./install.sh -h             # help
```

every step is idempotent and backs up anything it would replace; uninstall leaves the backups in place

## layout

- `bash/loader.sh` — sourced from `~/.bashrc`; exports `DOTFILES_DIR`, puts `bin/` on PATH, sources `bash/libs/*.sh` in order, then `~/.bashrc.local`
- `bash/libs/` — shell functions and aliases (things that must change the current shell)
  - `10_tools.sh` — `help`, `dotfiles update` (pull this repo, reload)
  - `20_alias.sh` — aliases; OS-specific ones (`here`, `resu`) only where their command exists; `ll`/`fd`/`bat`/`py` adapt to installed tools
  - `30_env.sh` — `JULIA_PROJECT=@.` and venv auto-activate
  - `40_complete.sh` — tab completion for `note` / `notes` (commands, options, nested topics, `#tags` already used)
- `bash/.bashrc.local.example` — template for machine-only settings and secrets (never committed)
- `bin/` — standalone scripts, on PATH; each takes `-h`
- `lib/` — helpers sourced by `bin/` scripts (`notes.sh`: date specs, topic checks); not on PATH
- `gitignore/` — templates used by `gi`
- `tools.txt` — CLI tools by package manager (apt, choco)
- `ai/AGENTS.md` — global agent rules, the single source for every agent

## scripts (`bin/`)

| command | what it does |
| --- | --- |
| `gclean [--yes]` | delete local branches whose remote is gone, and their worktrees (dirty worktrees are kept) |
| `tolf [--yes] [path...]` | convert CRLF to LF, recursively; skips `.git` and binary files |
| `gi [-l] [--stdout] [name...]` | append `.gitignore` templates (default: python r julia node quarto); safe to rerun |
| `note [-t topic] [-D when] [-T HH:MM] [-x] [-u] [text]` | append a timestamped note to `$NOTES_DIR/[topic/]YYYY-MM-DD.md`; topics nest (`work/clientA`); `-x` todo, `-D` another day, `-T` set the time, `-u` undo last; no text opens `$EDITOR` |
| `notes [command] [-s/-u when] [-t topic] [--md\|--tsv]` | read notes: `today` (default), `show <when>`, `grep <pattern>`, `topics`, `recap [-n N]`, `tags`, `todo [-a]` (with ages), `done`/`undone <pattern>` (tick a todo's box), `help [command]`; long output pages through `less` (`NOTES_PAGER`) |
| `mkvenv` | `uv venv`, then `uv sync` or `uv pip install -r requirements.txt` |

`gclean` and `tolf` are dry runs unless given `--yes`.

## venv auto-activate

entering a folder with a `.venv` (or any subfolder) activates it; leaving deactivates it. venvs you activate yourself are never touched.

- off for one project: `touch .noautovenv` in the project root
- off everywhere: `export DOTFILES_AUTOVENV=0` (e.g. in `~/.bashrc.local`)

## agents

`ai/AGENTS.md` is linked to `~/.claude/CLAUDE.md` and `~/.config/goose/.goosehints`. Cursor rule files need frontmatter, so `--ai` writes a generated copy to `~/.cursor/rules/global-agents.mdc`; rerun `--ai` after editing `AGENTS.md`. Cursor's support for that folder is inconsistent, so its Settings → Rules page remains the reliable global option.
