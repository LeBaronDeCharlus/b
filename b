#!/bin/bash

export BW_CLIENTID=''
export BW_CLIENTSECRET=''
export BW_PASSWORD=''

export LOCK="$HOME/.bw.lock"

# is unlock ?
if test -f "${LOCK}"; then
  BW_SESSION=$(bw unlock --passwordenv BW_PASSWORD | grep export | cut -d '"' -f 2 | tr -d '"' && bw sync)
else
  bw login --apikey && touch "${LOCK}"
fi

# is inside tmux ?
if [ -z "${TMUX}" ] ;  then
  FZF="fzf"
else 
  FZF="fzf-tmux"
fi

if [ "${1}" = "--sync" ]; then
  bw sync
  exit
fi

bw list items --search "${1}" --session "${BW_SESSION}" | jq -j '.[] | [.name, .login.password]' | tr -d '\n["'| tr ']' '\n'| tr ',' ':' | sed 's/^\ \ //g' | "${FZF}" --layout=reverse | tail -1 | tr -d '"' | cut -d ':' -f 2 | sed 's/^\ \ //g'| cat | xclip -se c > /dev/null 2> /dev/null
