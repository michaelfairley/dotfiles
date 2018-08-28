alias g="git"
alias be="bundle exec"

export RUST_BACKTRACE=1

if command -v brew && [ -f `brew --prefix`/etc/bash_completion.d/git-completion.bash ]; then
    . `brew --prefix`/etc/bash_completion.d/git-completion.bash
    __git_complete g __git_main
fi

if command -v rbenv; then
    eval "$(rbenv init -)"
fi

if command -v direnv; then
    eval "$(direnv hook bash)"
fi

OS="$(uname -s)"
if test "$OS" = "Darwin"; then
    export PATH="$HOME/.cargo/bin:$PATH"
    export PATH="$HOME/Library/Application Support/itch/bin:$PATH"
fi
