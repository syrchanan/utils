# tab completion for bin/ scripts

_NOTES_COMMANDS="today show grep topics recap tags todo done undone help"

# notes root, honoring -d/--dir earlier on the line
_notes_root() {
	local root="${NOTES_DIR:-$HOME/notes}" i
	for ((i = 1; i < COMP_CWORD; i++)); do
		case "${COMP_WORDS[i]}" in -d | --dir) root="${COMP_WORDS[i + 1]}" ;; esac
	done
	printf '%s\n' "${root/#\~/$HOME}"
}

# topic folders under the notes root, any depth, relative (work, work/clientA)
_notes_topics() {
	local root
	root="$(_notes_root)"
	[ -d "$root" ] || return 0
	find "$root" -mindepth 1 -type d ! -path '*/.*' -printf '%P\n' 2>/dev/null
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
		opts="-t -D -T -x -u -d -h --help"
		[[ "$cur" == -* ]] && mapfile -t COMPREPLY < <(compgen -W "$opts" -- "$cur")
		return
	fi

	# notes: offer a command until one is on the line
	opts="-s --since -u --until -t --topic -d --dir --md --tsv -h --help"
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
					done | undone) opts="$opts --line" ;;
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

if command -v complete >/dev/null 2>&1; then
	complete -F _notes_complete note notes
fi

# keep the file's exit status clean when the last guard is false
true
