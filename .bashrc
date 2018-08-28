alias g="git"
alias be="bundle exec"

export RUST_BACKTRACE=1

if command -v brew > /dev/null && [ -f `brew --prefix`/etc/bash_completion.d/git-completion.bash ]; then
    . `brew --prefix`/etc/bash_completion.d/git-completion.bash
    __git_complete g __git_main
fi

if command -v rbenv > /dev/null; then
    eval "$(rbenv init -)"
fi

if command -v direnv > /dev/null; then
    eval "$(direnv hook bash)"
fi

OS="$(uname -s)"
if test "$OS" = "Darwin"; then
    export PATH="$HOME/.cargo/bin:$PATH"
    export PATH="$HOME/Library/Application Support/itch/bin:$PATH"
fi
