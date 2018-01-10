alias g="git"
alias be="bundle exec"

if [ -f `brew --prefix`/etc/bash_completion.d/git-completion.bash ]; then
    . `brew --prefix`/etc/bash_completion.d/git-completion.bash
    __git_complete g __git_main
fi

if which rbenv > /dev/null; then
    eval "$(rbenv init -)"
fi

export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/Library/Application Support/itch/bin:$PATH"
export RUST_BACKTRACE=1
