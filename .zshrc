autoload -U select-word-style
select-word-style bash

zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*'
if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH
fi
autoload -U compinit && compinit


if command -v direnv > /dev/null; then
    eval "$(direnv hook zsh)"
fi

export PROMPT="[%1~]$ "

source ~/.bashrc
