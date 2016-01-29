#!/usr/bin/env bash

function tmuxStatus {
  printf "\e]2;$(hostname -s)\e\\"
}

function tmuxWindowName {
  IFS_ORIG=$IFS
  IFS=$'\n'
  wins=($(tmux list-windows -F "#I #{window_active}"))
  IFS=$IFS_ORIG
  noview=0
  for line in "${wins[@]}";do
    iw=$(printf "$line"|cut -d' ' -f1)
    fw=$(printf "$line"|cut -d' ' -f2)
    IFS_ORIG=$IFS
    IFS=$'\n'
    panes=($(tmux list-panes -t $iw -F "#D #{pane_active} #{pane_current_path}"))
    IFS=$IFS_ORIG
    first=1
    status=""
    for line in "${panes[@]}";do
      ip=$(echo "$line"|cut -d' ' -f1|sed 's/%//')
      fp=$(echo "$line"|cut -d' ' -f2)
      pp=$(echo "$line"|cut -d' ' -f3)
      if [ $first -eq 1 ];then
        first=0
      else
        status="$status#[bg=colour238] #[bg=colour008]"
      fi
      if [ $fw -eq 1 ] && [ $fp -eq 1 ];then
        status="$status#[bg=colour255]"
      else
        status="$status#[bg=colour008]"
      fi
      status="$status${ip}:$(hostname -s) $(basename $pp)"
    done
    status="$status#[bg=colour236] #[bg=colour008]"
    tmux rename-window -t :$iw "${status}"
  done
}

function tmuxLeftStatus {
  IFS_ORIG=$IFS
  IFS=$'\n'
  wins=($(tmux list-windows -F "#I #{window_active}"))
  IFS=$IFS_ORIG
  status=""
  noview=0
  for line in "${wins[@]}";do
    iw=$(printf "$line"|cut -d' ' -f1)
    fw=$(printf "$line"|cut -d' ' -f2)
    IFS_ORIG=$IFS
    IFS=$'\n'
    panes=($(tmux list-panes -t $iw -F "#D #{pane_active} #T"))
    IFS=$IFS_ORIG
    first=1
    for line in "${panes[@]}";do
      ip=$(echo "$line"|cut -d' ' -f1|sed 's/%//')
      fp=$(echo "$line"|cut -d' ' -f2)
      tp=$(echo "$line"|cut -d' ' -f3)
      pp=$(echo "$line"|cut -d' ' -f4)
      if [ $first -eq 1 ];then
        first=0
      else
        status="$status#[bg=colour238] #[bg=colour008]"
        noview=$((noview+30))
      fi
      if [ $fw -eq 1 ] && [ $fp -eq 1 ];then
        status="$status#[bg=colour255]"
        noview=$((noview+15))
      else
        status="$status#[bg=colour008]"
        noview=$((noview+15))
      fi
      status="$status${ip}@${tp} $(basename $pp)"
      #status="$status${iw}.${ip}:#h $(basename $pp)"
      #noview=$((noview-15))
    done
    status="$status#[bg=colour000]..#[bg=colour008]"
    noview=$((noview+30))
  done
  echo -n ${status: 0: $(($(tput cols)+noview-32))}
}

function tmuxAlign {
  wins=($(tmux list-windows -F "#I"))
  if [ ${#wins[@]} -lt 2 ];then
    return
  fi
  flag=$(tmux list-windows -F "#{window_active} #I"|grep ^1|sed 's/^1 //')
  if [ "$flag" -ne 0 ];then
    tmux swap-window -t:+
  fi
  local i
  local j
  for i in $(seq 2 $((${#wins[@]}-1)));do
    panes=($(tmux list-panes -t ${wins[$i]} -F "#P"))
    for j in $(seq 0 $((${#panes[@]}-1)));do
      tmux join-pane -d -s :${wins[$i]}.${panes[$j]} -t :${wins[1]}.bottom
    done
  done
}

function tmuxCreate {
  wins=($(tmux list-windows -F "#I"))
  if [ ${#wins[@]} -eq 1 ];then
    tmux new-window -d
    tmux swap-pane -d -s :+
  else
    tmux split-window -d -t :+.bottom
    tmux swap-pane -s :+.bottom
  fi
  tmuxAlign
}

function tmuxSplit {
  wins=($(tmux list-windows -F "#I"))
  if [ ${#wins[@]} -eq 1 ];then
    tmux split-window -v
  else
    tmux join-pane -v -s :+.top
  fi
}

function tmuxVSplit {
  wins=($(tmux list-windows -F "#I"))
  if [ ${#wins[@]} -eq 1 ];then
    tmux split-window -h
  else
    tmux join-pane -h -s :+.top
  fi
}

function tmuxOnly {
  wins=($(tmux list-windows -F "#I"))
  if [ ${#wins[@]} -eq 1 ];then
    tmux break-pane
  else
    IFS_ORIG=$IFS
    IFS=$'\n'
    panes=($(tmux list-panes -F "#D #{pane_active}"))
    IFS=$IFS_ORIG
    for line in "${panes[@]}";do
      ip=$(echo "$line"|cut -d' ' -f1)
      fp=$(echo "$line"|cut -d' ' -f2)
      if [ $fp -ne 1 ];then
        tmux move-pane -d -s ${ip} -t :+
      fi
    done
  fi
  tmuxAlign
}

function tmuxFour {
  tmuxOnly
  npanes=1
  wins=($(tmux list-windows -F "#I"))
  if [ ${#wins[@]} -ne 1 ];then
    npanes=$((npanes+$(tmux list-panes -t:+|wc -l)))
  fi
  while [ $npanes -lt 4 ];do
    tmuxCreate
    ((npanes++))
  done
  tmuxVSplit
  tmux select-pane -L
  tmuxSplit
  tmux select-pane -U
  tmux select-pane -R
  tmuxSplit
  tmux select-pane -U
  tmux select-pane -L
}

function tmuxMove {
  wins=($(tmux list-windows -F "#I"))
  if [ ${#wins[@]} -eq 1 ];then
    tmux break-pane
    tmux select-window -t:+
  else
    IFS_ORIG=$IFS
    IFS=$'\n'
    panes=($(tmux list-panes -F "#D #{pane_active}"))
    IFS=$IFS_ORIG
    for line in "${panes[@]}";do
      ip=$(echo "$line"|cut -d' ' -f1)
      fp=$(echo "$line"|cut -d' ' -f2)
      if [ $fp -eq 1 ];then
        tmux move-pane -d -s ${ip} -t :+
      fi
    done
    tmuxAlign
  fi
}

function tmuxPaneInfo {
  paneinfo=$(tmux list-panes -F "#{pane_active} #D@#T"|grep ^1|sed 's/^1 %//')
  tmux display-message "$paneinfo"
}

function tmuxNext {
  tmux swap-pane -s :+.top
  tmux rotate-window -U -t :+
  tmuxPaneInfo
}

function tmuxPrev {
  tmux swap-pane -s :+.bottom
  tmux rotate-window -D -t :+
  tmuxPaneInfo
}

function tmuxLeft {
  tmux select-pane -L
  tmuxPaneInfo
}

function tmuxDown {
  tmux select-pane -D
  tmuxPaneInfo
}

function tmuxUp {
  tmux select-pane -U
  tmuxPaneInfo
}

function tmuxRight {
  tmux select-pane -R
  tmuxPaneInfo
}

function tmuxChoose {
  if ! type -a sentaku >& /dev/null;then
    tmux display-message "Install sentaku (https://github.com/rcmdnk/sentaku) first."
    return
  fi
  tmuxAlign
  all=()
  IFS_ORIG=$IFS
  IFS=$'\n'
  wins=($(tmux list-windows -F "#I #{window_active}"))
  IFS=$IFS_ORIG
  for line in "${wins[@]}";do
    iw=$(printf "$line"|cut -d' ' -f1)
    fw=$(printf "$line"|cut -d' ' -f2)
    IFS_ORIG=$IFS
    IFS=$'\n'
    panes=($(tmux list-panes -t $iw -F "#D #P #{pane_active} #{pane_current_path} #T"))
    IFS=$IFS_ORIG
    first=1
    for line in "${panes[@]}";do
      ip=$(echo "$line"|cut -d' ' -f1|sed 's/%//')
      Ip=$(echo "$line"|cut -d' ' -f2)
      fp=$(echo "$line"|cut -d' ' -f3)
      pp=$(echo "$line"|cut -d' ' -f4)
      tp=$(echo "$line"|cut -d' ' -f5)
      all=("${all[@]}" "${iw}.${Ip} $((fp * fw)) $fw $ip@$tp $pp")
    done
  done
  target=$(for l in "${all[@]}";do echo $l;done|sentaku -N -s line)
  if [ "$target" != "" ];then
    i=$(echo "$target"|cut -d' ' -f1)
    tmux swap-pane -d -s :${i}
  fi
}

function tmuxClipborad {
  if [ "$CLX" = "" ];then
    if [[ "$OSTYPE" =~ linux ]];then
      if which -s xsel;then
        CLX="xsel"
      elif which -s xsel;then
        CLX="xclip"
      fi
    elif [[ "$OSTYPE" =~ cygwin ]];then
      if which -s putclip;then
        CLX="putclip"
      elif which -s xsel;then
        CLX="xsel"
      elif which -s xsel;then
        CLX="xclip"
      fi
    elif [[ "$OSTYPE" =~ darwin ]];then
      if which -s pbcopy;then
        CLX="pbcopy"
      fi
    fi
  fi
  if [ "$CLX" != "" ];then
    tmux save-buffer -| $CLX
    tmux display-message "clipboard: $(tmux save-buffer -)"
  else
    tmux display-message "No clipboard software is found."
  fi
}

if [ "$1" = "status" ];then
  tmuxStatus
elif [ "$1" = "winname" ];then
  tmuxWindowName
elif [ "$1" = "leftstatus" ];then
  tmuxLeftStatus
elif [ "$1" = "create" ];then
  tmuxCreate
elif [ "$1" = "align" ];then
  tmuxAlign
elif [ "$1" = "split" ];then
  tmuxSplit
elif [ "$1" = "vsplit" ];then
  tmuxVSplit
elif [ "$1" = "only" ];then
  tmuxOnly
elif [ "$1" = "four" ];then
  tmuxFour
elif [ "$1" = "move" ];then
  tmuxMove
elif [ "$1" = "next" ];then
  tmuxNext
elif [ "$1" = "prev" ];then
  tmuxPrev
elif [ "$1" = "left" ];then
  tmuxLeft
elif [ "$1" = "down" ];then
  tmuxDown
elif [ "$1" = "up" ];then
  tmuxUp
elif [ "$1" = "right" ];then
  tmuxRight
elif [ "$1" = "choose" ];then
  tmuxChoose
elif [ "$1" = "clip" ];then
  tmuxClipborad
fi
