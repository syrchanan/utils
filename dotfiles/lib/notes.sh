# Shared helpers for bin/note and bin/notes. Sourced, not executed.
# Callers set NOTES_PROG (used in messages) before sourcing.

NOTES_DATE_HELP='Date specs:
  today, yesterday, -N (N days ago), YYYY-MM-DD, or anything `date -d` reads
  ("last monday", "2 weeks ago")'

notes_die() {
	printf '%s: %s\n' "${NOTES_PROG:-notes}" "$*" >&2
	exit 1
}

notes_usage_error() {
	printf "%s: %s\ntry '%s --help'\n" "${NOTES_PROG:-notes}" "$*" "${NOTES_PROG:-notes}" >&2
	exit 1
}

# notes_root [dir] -> notes root without a trailing slash
notes_root() {
	local root="${1:-${NOTES_DIR:-$HOME/notes}}"
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
