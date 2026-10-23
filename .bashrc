# Sourced from ~/.bashrc, which mise bootstrap points here (see mise.toml).

source "$DOTFILES/.shrc"

if command -v brew > /dev/null && [ -f "$(brew --prefix)/etc/bash_completion.d/git-completion.bash" ]; then
    . "$(brew --prefix)/etc/bash_completion.d/git-completion.bash"
    __git_complete g __git_main
fi

if command -v direnv > /dev/null; then
    eval "$(direnv hook bash)"
fi

if command -v mise > /dev/null; then
    eval "$(mise activate bash)"
fi
