# Setup fzf
# ---------
if [[ ! "$PATH" == */home/gabri/.fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}/home/gabri/.fzf/bin"
fi

eval "$(fzf --bash)"
