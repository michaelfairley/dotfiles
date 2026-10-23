# Sourced from ~/.zshrc, which mise bootstrap points here (see mise.toml).

# Drop duplicate PATH entries, keeping the first occurrence.
typeset -U PATH path

autoload -U select-word-style
select-word-style bash

zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*'
if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH
fi
autoload -U compinit && compinit

export PROMPT="[%1~]$ "

source "$DOTFILES/.shrc"

if command -v direnv > /dev/null; then
    eval "$(direnv hook zsh)"
fi
