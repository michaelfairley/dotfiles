alias g="git"
alias be="bundle exec"

export EDITOR="emacs -nw"

export RUST_BACKTRACE=1

if command -v brew > /dev/null && [ -f `brew --prefix`/etc/bash_completion.d/git-completion.bash ] && [ -n "$BASH" ]; then
    . `brew --prefix`/etc/bash_completion.d/git-completion.bash
    __git_complete g __git_main
fi

if command -v rbenv > /dev/null; then
    eval "$(rbenv init -)"
fi

if command -v direnv > /dev/null; then
    eval "$(direnv hook bash)"
fi

export PATH="$HOME/.cargo/bin:$PATH"

OS="$(uname -s)"
if test "$OS" = "Darwin"; then
    export PATH="$HOME/Library/Application Support/itch/bin:$PATH"
fi

export PATH="$HOME/.node_modules/bin:$PATH"
export npm_config_prefix=~/.node_modules
