# Shared helpers for bin/note and bin/notes. Sourced, not executed.
# Callers set NOTES_PROG (used in messages) before sourcing.

NOTES_DATE_HELP='Date specs:
  today, yesterday, -N (N days ago), YYYY-MM-DD, or anything `date -d` reads
  ("last monday", "2 weeks ago")'

NOTES_ROOT_HELP='Notes root (first that applies):
  -d dir; else the nearest .notes/ folder in the current directory or one
  above it (mkdir .notes to keep a project'"'"'s notes in that project); else
  $NOTES_DIR; else ~/.notes. -g skips the project lookup (the global notes).'

notes_die() {
	printf '%s: %s\n' "${NOTES_PROG:-notes}" "$*" >&2
	exit 1
}

notes_usage_error() {
	printf "%s: %s\ntry '%s --help'\n" "${NOTES_PROG:-notes}" "$*" "${NOTES_PROG:-notes}" >&2
	exit 1
}

# notes_global_dir -> the notes root outside a project, and for -g
notes_global_dir() {
	printf '%s\n' "${NOTES_DIR:-$HOME/.notes}"
}

# notes_project_dir -> nearest .notes/ folder at or above $PWD. ~/.notes is
# skipped: it is the global default, and must not shadow $NOTES_DIR.
notes_project_dir() {
	local dir="$PWD"
	while [ -n "$dir" ]; do
		if [ "$dir" != "$HOME" ] && [ -d "$dir/.notes" ]; then
			printf '%s\n' "${dir%/}/.notes"
			return 0
		fi
		[ "$dir" = / ] && break
		dir="${dir%/*}"; dir="${dir:-/}" # parent, without forking dirname
	done
	return 1
}

# notes_root [dir] -> notes root without a trailing slash
# order: dir argument (-d, or the global root for -g), nearest project .notes/,
# $NOTES_DIR, ~/.notes
notes_root() {
	local root="${1:-}"
	[ -n "$root" ] || root="$(notes_project_dir)" || root="$(notes_global_dir)"
	[ "$root" = / ] || root="${root%/}"
	printf '%s\n' "$root"
}

# resolve_date SPEC -> YYYY-MM-DD
resolve_date() {
	local spec="$1" out
	case "$spec" in
		today) date +%F; return ;;
		yesterday) date -d yesterday +%F; return ;;
	esac
	if [[ "$spec" =~ ^-([0-9]+)$ ]]; then
		date -d "${BASH_REMATCH[1]} days ago" +%F
		return
	fi
	[ -n "$spec" ] || notes_die "empty date"
	out="$(date -d "$spec" +%F 2>/dev/null)" || notes_die "bad date '$spec'"
	printf '%s\n' "$out"
}

# resolve_range SPEC -> "SINCE UNTIL"
# adds YYYY, YYYY-MM and A..B (either side may be empty) on top of resolve_date
resolve_range() {
	local spec="$1" lo hi
	if [[ "$spec" == *..* ]]; then
		lo="${spec%%..*}" hi="${spec#*..}"
		if [ -n "$lo" ]; then lo="$(resolve_range "$lo")" || return 1; lo="${lo% *}"; else lo=0000-00-00; fi
		if [ -n "$hi" ]; then hi="$(resolve_range "$hi")" || return 1; hi="${hi#* }"; else hi=9999-99-99; fi
		[[ "$lo" < "$hi" || "$lo" == "$hi" ]] || notes_die "range '$spec' ends before it starts"
		printf '%s %s\n' "$lo" "$hi"
		return
	fi
	if [[ "$spec" =~ ^[0-9]{4}$ ]]; then
		printf '%s-01-01 %s-12-31\n' "$spec" "$spec"
		return
	fi
	if [[ "$spec" =~ ^[0-9]{4}-[0-9]{2}$ ]]; then
		hi="$(date -d "$spec-01 +1 month -1 day" +%F 2>/dev/null)" || notes_die "bad month '$spec'"
		printf '%s-01 %s\n' "$spec" "$hi"
		return
	fi
	lo="$(resolve_date "$spec")" || return 1
	printf '%s %s\n' "$lo" "$lo"
}

# validate_topic PATH: any depth (a/b/c), no empty, '.' or '..' segments
validate_topic() {
	local t="$1" seg
	local -a segs
	[ -n "$t" ] || notes_die "empty topic"
	case "$t" in
		/* | */ | *//*) notes_die "bad topic '$t' (no leading, trailing or double '/')" ;;
	esac
	[[ "$t" != *[[:cntrl:]]* ]] || notes_die "bad topic '$t' (control characters)"
	IFS=/ read -ra segs <<<"$t"
	for seg in "${segs[@]}"; do
		case "$seg" in
			. | ..) notes_die "bad topic '$t' ('.' and '..' are not allowed)" ;;
		esac
	done
}

# run_editor FILE [LINE]: like git, the editor may carry flags or quotes
# ("code --wait"): $VISUAL, then $EDITOR, then vim, then vi
run_editor() {
	local ed="${VISUAL:-${EDITOR:-}}" goto=()
	if [ -z "$ed" ]; then
		if command -v vim >/dev/null 2>&1; then ed=vim; else ed=vi; fi
	fi
	# +N (jump to line) is understood by these; others just open the file
	if [ -n "${2:-}" ]; then
		case "$(basename -- "${ed%% *}")" in
			vi | vim | nvim | view | nano | emacs | micro) goto=("+$2") ;;
		esac
	fi
	sh -c "$ed \"\$@\"" editor "${goto[@]}" "$1"
}
