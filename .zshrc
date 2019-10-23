autoload -U select-word-style
select-word-style bash

autoload -U compinit
if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH
fi


source .bashrc
