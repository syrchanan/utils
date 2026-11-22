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

## how it loads

`~/.bashrc` sources `bash/loader.sh`, which exports `DOTFILES_DIR`, puts `bin/` on PATH, sources `bash/libs/*.sh` in filename order (the number prefixes set the order), and sources `~/.bashrc.local` last, so machine-only settings and secrets there override everything else. Start that file from `bash/.bashrc.local.example`; it is never committed.

`dotfiles list [regex]` shows every script, alias and function this adds (including `~/.bashrc.local`), and whether each alias is set in the current shell: some only exist where their tool does (`here`, `resu`, eza's `ll`, Debian's `fd`/`bat`). `dotfiles update` pulls this repo and reloads.

## adding things

- something that must change the current shell (alias, function, env var): `bash/libs/`
- anything else: an executable script in `bin/`; make its second line a `# description` comment (shown by `dotfiles list`) and give it `-h`
- code shared by `bin/` scripts: `lib/`, which is sourced, not on PATH
- a CLI tool to install: `tools.txt`, read by `--tools`

## scripts (`bin/`)

| command | what it does |
| --- | --- |
| `gclean [--yes]` | delete local branches whose remote is gone, and their worktrees (dirty worktrees are kept); the dry run shows each branch's last commit and whether it's merged |
| `tolf [--yes] [--] [path...]` | convert CRLF to LF, recursively; skips `.git` and binary files |
| `gi [-l] [--stdout] [name...]` | append `.gitignore` templates (default: python r julia node quarto); safe to rerun |
| `note [-t topic] [-D when] [-T HH:MM] [-x] [-u] [text]` | append a timestamped note to `<root>/[topic/]YYYY-MM-DD.md` (see notes root below); topics nest (`work/clientA`); `-x` todo, `-D` another day, `-T` set the time, `-u` undo last; no text opens `$EDITOR` |
| `notes [command] [-s/-u when] [-t topic] [--md\|--tsv]` | read notes: `today` (default), `show <when>`, `grep <pattern>`, `topics`, `recap [-n N]`, `tags`, `todo [-a]` (with ages), `done`/`undone <pattern>` (tick a todo's box), `where` (the notes root in use, and why), `help [command]`; long output pages through `less` (`NOTES_PAGER`) |
| `mkvenv` | `uv venv`, then `uv sync` or `uv pip install -r requirements.txt` |

`gclean` and `tolf` are dry runs unless given `--yes`.

## notes root

Notes live in a `.notes/` folder, topics as subfolders. `note` and `notes` use the first of: `-d dir`; the nearest `.notes/` in the current folder or one above it (a project's); `$NOTES_DIR`; `~/.notes` (the global one).

- keep a project's notes in that project: `mkdir .notes` in its root. The `gi` templates don't ignore it, so commit it to share the notes, or add it to `.gitignore` to keep them local
- global notes somewhere else: `export NOTES_DIR=...` (e.g. in `~/.bashrc.local`); `~/.notes` then no longer counts as a project folder
- the global notes from inside a project: `-g` (`notes` also takes `--global`)

## venv auto-activate

entering a folder with a `.venv` (or any subfolder) activates it; leaving deactivates it. venvs you activate yourself are never touched.

- off for one project: `touch .noautovenv` in the project root
- off everywhere: `export DOTFILES_AUTOVENV=0` (e.g. in `~/.bashrc.local`)

## agents

`ai/AGENTS.md` is linked to `~/.claude/CLAUDE.md` and `~/.config/goose/.goosehints`. Cursor rule files need frontmatter, so `--ai` writes a generated copy to `~/.cursor/rules/global-agents.mdc`; rerun `--ai` after editing `AGENTS.md`. Cursor's support for that folder is inconsistent, so its Settings → Rules page remains the reliable global option.
