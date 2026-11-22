# Julia: use the nearest Project.toml (R needs nothing: renv activates via .Rprofile)
export JULIA_PROJECT="@."

# --- venv auto-activate ---
# Runs from PROMPT_COMMAND rather than wrapping cd, so pushd/popd and other
# directory changes are covered too. Off with DOTFILES_AUTOVENV=0, or per
# project with a .noautovenv file in the project root.

_autovenv_find() {
	local dir="$PWD"
	while [ -n "$dir" ]; do
		if [ -f "$dir/.venv/bin/activate" ] || [ -f "$dir/.venv/Scripts/activate" ]; then
			printf '%s\n' "$dir"
			return 0
		fi
		[ "$dir" = "/" ] && break
		dir="${dir%/*}"; dir="${dir:-/}" # parent, without forking dirname
	done
	return 1
}

_autovenv() {
	[ "${DOTFILES_AUTOVENV:-1}" = "0" ] && return

	local root=""
	root="$(_autovenv_find)" || root=""
	[ -n "$root" ] && [ -e "$root/.noautovenv" ] && root=""

	# leaving the venv we activated (never touch one activated by hand)
	if [ -n "${_AUTOVENV_ROOT:-}" ] && [ "$root" != "$_AUTOVENV_ROOT" ]; then
		if [ "${VIRTUAL_ENV:-}" = "$_AUTOVENV_ROOT/.venv" ] && command -v deactivate >/dev/null 2>&1; then
			deactivate
		fi
		unset _AUTOVENV_ROOT
	fi

	# entering a project whose venv isn't already active
	if [ -n "$root" ] && [ -z "${VIRTUAL_ENV:-}" ]; then
		if [ -f "$root/.venv/bin/activate" ]; then
			source "$root/.venv/bin/activate"
		else
			source "$root/.venv/Scripts/activate"
		fi
		_AUTOVENV_ROOT="$root"
	fi
}

case ";${PROMPT_COMMAND:-};" in
	*";_autovenv;"*) ;;
	*) PROMPT_COMMAND="_autovenv${PROMPT_COMMAND:+;$PROMPT_COMMAND}" ;;
esac
