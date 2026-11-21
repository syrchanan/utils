alias \
\
c="clear" \
..="cd .." \
...="cd ../.." \
....="cd ../../.." \
ll="ls -lah --color=auto --group-directories-first" \
grep="grep --color=auto" \
reload="source ~/.bashrc" \
hg="history | grep -i" \
psg="ps aux | grep -v grep | grep -i" \
df="df -h" \
du="du -h -d 1"

# OS guards: only define aliases whose commands exist here
command -v sudo >/dev/null 2>&1 && alias resu='sudo $(fc -ln -1)'
command -v explorer.exe >/dev/null 2>&1 && alias here="explorer.exe ."

# modern tools, when installed
command -v eza >/dev/null 2>&1 && alias ll="eza -lah --group-directories-first"
# Debian/Ubuntu ship these under other binary names
command -v fd >/dev/null 2>&1 || { command -v fdfind >/dev/null 2>&1 && alias fd="fdfind"; }
command -v bat >/dev/null 2>&1 || { command -v batcat >/dev/null 2>&1 && alias bat="batcat"; }
command -v uv >/dev/null 2>&1 && alias py="uv run python"

# keep the file's exit status clean when the last guard is false
true
