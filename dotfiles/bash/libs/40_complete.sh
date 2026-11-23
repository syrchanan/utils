# tab completion for bin/ scripts and the dotfiles command

_NOTES_COMMANDS="today show grep topics recap tags todo done undone edit where help"

# notes root, honoring -d/--dir or -g/--global earlier on the line, then the
# nearest project .notes/ (same order as notes_root in lib/notes.sh)
_notes_root() {
	local root="" dir="$PWD" i
	while [ -n "$dir" ]; do
		if [ "$dir" != "$HOME" ] && [ -d "$dir/.notes" ]; then root="${dir%/}/.notes"; break; fi
		[ "$dir" = / ] && break
		dir="${dir%/*}"; dir="${dir:-/}" # parent, without forking dirname
	done
	[ -n "$root" ] || root="${NOTES_DIR:-$HOME/.notes}"
	for ((i = 1; i < COMP_CWORD; i++)); do
		case "${COMP_WORDS[i]}" in
			-d | --dir) root="${COMP_WORDS[i + 1]}" ;;
			-g | --global) root="${NOTES_DIR:-$HOME/.notes}" ;;
		esac
	done
	printf '%s\n' "${root/#\~/$HOME}"
}

# topic folders under the notes root, any depth, relative (work, work/clientA).
# Hidden folders inside the root are skipped; the root itself is usually .notes
_notes_topics() {
	local root
	root="$(_notes_root)"
	[ -d "$root" ] || return 0
	find "$root/" -mindepth 1 -name '.*' -prune -o -type d -printf '%P\n' 2>/dev/null | sort
}

# if the word being typed ends in "#ta", complete it from tags already used.
# Works inside an open quote too: note "fixed it #b<TAB>
_notes_tag_complete() {
	local cur="$1" word last pre t notes_bin
	word="${cur#[\"\']}"
	[[ "$word" == *"#"* ]] || return 1
	last="#${word##*#}"
	[[ "$last" =~ ^#[A-Za-z0-9_/-]*$ ]] || return 1
	pre="${word%"$last"}"
	notes_bin="$(command -v notes || printf '%s' "${DOTFILES_DIR:-}/bin/notes")"
	[ -x "$notes_bin" ] || return 0
	while IFS= read -r t; do
		[[ "$t" == "$last"* ]] && COMPREPLY+=("$pre$t")
	done < <(NOTES_DIR="$(_notes_root)" "$notes_bin" tags --tsv 2>/dev/null | cut -f1)
	compopt -o nospace 2>/dev/null
	return 0
}

_notes_complete() {
	local cur="${COMP_WORDS[COMP_CWORD]}" prev="${COMP_WORDS[COMP_CWORD - 1]}" t w i opts
	COMPREPLY=()
	case "$prev" in
		-t | --topic)
			while IFS= read -r t; do
				[[ "$t" == "$cur"* ]] && COMPREPLY+=("$t")
			done < <(_notes_topics)
			return
			;;
		-d | --dir)
			mapfile -t COMPREPLY < <(compgen -d -- "$cur")
			return
			;;
		-s | -u | -D | -T | -n | --since | --until | --line) return ;;
	esac

	_notes_tag_complete "$cur" && return

	if [ "${COMP_WORDS[0]##*/}" = note ]; then
		opts="-t -D -T -x -u -e -d -g -h --help"
		[[ "$cur" == -* ]] && mapfile -t COMPREPLY < <(compgen -W "$opts" -- "$cur")
		return
	fi

	# notes: offer a command until one is on the line
	opts="-s --since -u --until -t --topic -d --dir -g --global --md --tsv -h --help"
	for ((i = 1; i < COMP_CWORD; i++)); do
		w="${COMP_WORDS[i]}"
		case " $_NOTES_COMMANDS " in
			*" $w "*)
				case "$w" in
					help)
						[ "$i" -eq $((COMP_CWORD - 1)) ] && mapfile -t COMPREPLY < <(compgen -W "$_NOTES_COMMANDS" -- "$cur")
						return
						;;
					recap) opts="$opts -n" ;;
					todo) opts="$opts -a --all" ;;
					done | undone | edit) opts="$opts --line" ;;
				esac
				[[ "$cur" == -* ]] && mapfile -t COMPREPLY < <(compgen -W "$opts" -- "$cur")
				return
				;;
		esac
	done
	if [[ "$cur" == -* ]]; then
		mapfile -t COMPREPLY < <(compgen -W "$opts" -- "$cur")
	else
		mapfile -t COMPREPLY < <(compgen -W "$_NOTES_COMMANDS" -- "$cur")
	fi
}

# dotfiles: subcommands, then for "list" the names it would show
_dotfiles_complete() {
	local cur="${COMP_WORDS[COMP_CWORD]}"
	COMPREPLY=()
	if [ "$COMP_CWORD" -eq 1 ]; then
		mapfile -t COMPREPLY < <(compgen -W "update list help" -- "$cur")
	elif [ "$COMP_CWORD" -eq 2 ] && [ "${COMP_WORDS[1]}" = list ]; then
		mapfile -t COMPREPLY < <(compgen -W "$(_dotfiles_rows 2>/dev/null | cut -f2)" -- "$cur")
	fi
}

if command -v complete >/dev/null 2>&1; then
	complete -F _notes_complete note notes
	complete -F _dotfiles_complete dotfiles
fi

# keep the file's exit status clean when the last guard is false
true
