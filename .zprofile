# Login-shell PATH additions (zsh). Interactive config lives in .zshrc.
export PATH="$PATH:$HOME/.docker/bin"

# OrbStack command-line tools and integration
source "$HOME/.orbstack/shell/init.zsh" 2>/dev/null || :
