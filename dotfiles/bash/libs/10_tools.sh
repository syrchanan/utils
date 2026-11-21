# show a command's --help output
help() {
	"$@" --help 2>&1
}

# manage this dotfiles repo: update, list [regex]
dotfiles() {
	case "${1:-}" in
		update)
			git -C "$DOTFILES_DIR" pull --ff-only && source ~/.bashrc
			;;
		list)
			shift
			[ $# -le 1 ] || { echo "dotfiles: list takes one regex (quote it)" >&2; return 1; }
			_dotfiles_list "${1:-}"
			;;
		-h | --help | help)
			_dotfiles_usage
			;;
		*)
			[ -z "${1:-}" ] || echo "dotfiles: unknown command '$1'" >&2
			_dotfiles_usage >&2
			return 1
			;;
	esac
}

_dotfiles_usage() {
	cat <<'EOF'
Usage: dotfiles <command>

  update         pull this repo (fast-forward only) and reload the shell
  list [regex]   scripts, aliases and functions this repo and ~/.bashrc.local
                 add; regex filters on name or description (smart case:
                 ignores case unless the regex has an uppercase letter)

Examples:
  dotfiles list
  dotfiles list git
  dotfiles list '^n'
  dotfiles list 'note|venv'
EOF
}

# alias names defined in FILE...: "alias \" blocks of name=... lines, plus any "alias name="
_dotfiles_alias_names() {
	awk '
		/^[ \t]*#/ { next }
		/^alias[ \t]*\\$/ { block = 1; next }
		block {
			if (match($0, /^[A-Za-z0-9_.:-]+=/)) print substr($0, 1, RLENGTH - 1)
			if ($0 !~ /\\$/) block = 0
			next
		}
		{
			s = $0
			while (match(s, /(^|[^A-Za-z0-9_])alias[ \t]+[A-Za-z0-9_.:-]+=/)) {
				t = substr(s, RSTART, RLENGTH - 1); sub(/^.*alias[ \t]+/, "", t); print t
				s = substr(s, RSTART + RLENGTH)
			}
		}
	' "$@" 2>/dev/null | awk '!seen[$0]++'
}

# top-level functions in FILE... (not _private ones) as "name<TAB>comment just above it"
_dotfiles_functions() {
	awk '
		/^[ \t]*#/ { c = $0; sub(/^[ \t]*#[ \t]?/, "", c); next }
		match($0, /^(function[ \t]+)?[A-Za-z][A-Za-z0-9_:-]*[ \t]*\(\)/) {
			n = substr($0, RSTART, RLENGTH); sub(/^function[ \t]+/, "", n); sub(/[ \t]*\(\)$/, "", n)
			print n "\t" c
		}
		{ c = "" }
	' "$@" 2>/dev/null
}

# aliases (with their current value) and functions from FILE... under SECTION
_dotfiles_section() {
	local section="$1" name val
	shift
	while IFS= read -r name; do
		if val="$(alias "$name" 2>/dev/null)"; then
			val="${val#alias "$name"=}"
			val="${val#\'}"
			val="${val%\'}"
		else
			val="(not set in this shell)"
		fi
		printf '%s aliases\t%s\t%s\n' "$section" "$name" "$val"
	done < <(_dotfiles_alias_names "$@")
	_dotfiles_functions "$@" | awk -v s="$section functions" '{ print s "\t" $0 }'
}

# every entry as "section<TAB>name<TAB>description"
_dotfiles_rows() {
	local f libs=("$DOTFILES_DIR"/bash/libs/*.sh) rc="$HOME/.bashrc.local"
	for f in "$DOTFILES_DIR"/bin/*; do
		[ -f "$f" ] && [ -x "$f" ] || continue
		printf 'scripts (bin/)\t%s\t%s\n' "${f##*/}" "$(sed -n '2s/^#[[:space:]]\{0,1\}//p' "$f")"
	done
	_dotfiles_section "shell" "${libs[@]}"
	if [ -r "$rc" ]; then _dotfiles_section "local (~/.bashrc.local)" "$rc"; fi
}

_dotfiles_list() {
	local color=0
	[ -t 1 ] && [ -z "${NO_COLOR:-}" ] && color=1
	[ -n "${DOTFILES_DIR:-}" ] || { echo "dotfiles: DOTFILES_DIR is not set (is loader.sh sourced?)" >&2; return 1; }
	_dotfiles_rows | DOTFILES_RE="$1" awk -v color="$color" '
		BEGIN {
			FS = "\t"; re = ENVIRON["DOTFILES_RE"]; ic = (re !~ /[A-Z]/)
			if (color) { B = "\033[1m"; D = "\033[2m"; R = "\033[0m" }
		}
		{
			hay = $2 " " $3
			if (re != "" && (ic ? tolower(hay) : hay) !~ re) next
			n++; s[n] = $1; nm[n] = $2; ds[n] = $3
			if (length($2) > w) w = length($2)
		}
		END {
			if (n == 0) { print "dotfiles: nothing matches \047" re "\047" > "/dev/stderr"; exit 1 }
			for (i = 1; i <= n; i++) {
				if (s[i] != last) { if (i > 1) print ""; print B s[i] R; last = s[i] }
				d = ds[i]; if (d ~ /^\(not set/) d = D d R
				printf "  %-" w "s  %s\n", nm[i], d
			}
		}
	'
}
