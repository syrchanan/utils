# utils

This repository is a personal grab-bag of utilities: dotfiles and shell helpers, devcontainers, AI agent configuration and workflows, and machine setup scripts. It is designed for extensibility and maintainability, with a focus on reproducible environments.

The devcontainer supports Python, R, and Julia for multi-language AI development, with optional Goose and Claude Code CLIs (opt-in via `.devcontainer/config.json`). The `dotfiles/` folder holds shell config and global agent instructions for the host machine. See below for details.

## Contents

### `dotfiles/`
Shell config, scripts and global AI agent instructions for WSL/Linux. `install.sh` sets them up (`-h` for options, `--dry-run` to preview); every step is idempotent and backs up anything it replaces. Once installed, `dotfiles list` shows every script, alias and function it adds. See the [Dotfiles README](./dotfiles/README.md).

### `.devcontainer/`
A reproducible dev container for Python, R and Julia, with optional Goose and Claude Code CLIs. Languages and tools are opt-in via `config.json` (all off by default), and on start it installs the dependencies it detects in workspace projects. See the [Devcontainer README](./.devcontainer/README.md).

### `ralph/`
Agent workflow scripts and Goose recipes for iterative, cross-model development, based on the [tutorial at goose](https://block.github.io/goose/docs/tutorials/ralph-loop).

#### Ralph Loop

The Ralph Loop enables iterative agent development with strict review, using different models for work and review phases. Each iteration is stateless (fresh context), and the workflow is managed via state files in `.goose/ralph/`. The loop continues until the reviewer ships the work or the max iteration count is reached.

- Usage: `./ralph-loop.sh "your task description"` or `./ralph-loop.sh /path/to/task.md`
- Environment variables allow customization of models, providers, and iteration limits.
- See `ralph-loop.sh` for details.

### Agent Rules

`dotfiles/ai/AGENTS.md` is a working doc which contains my personal rules on agent behavior, code style, and collaboration.

### Changelog

`CHANGELOG.md` has a history of changes and updates.