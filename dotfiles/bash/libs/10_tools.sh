help() {
	"$@" --help 2>&1
}

# manage this dotfiles repo; subcommands can be added as cases
dotfiles() {
	case "${1:-}" in
		update)
			git -C "$DOTFILES_DIR" pull --ff-only && source ~/.bashrc
			;;
		*)
			echo "Usage: dotfiles update" >&2
			return 1
			;;
	esac
}
