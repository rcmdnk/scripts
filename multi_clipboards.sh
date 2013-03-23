#!/bin/bash

# Multi (Manage) Clipboards for GNU screen!
# *** Utility to keep multiple clipboards ***
# *** and manage screen's clipboard.      ***


# Usage {{{
#
# $ multi_clipboards.sh -i [arg]
# # Push arg to the clipboard list
#
# $ multi_clipboards.sh -I
# # Push the screen's clipboard to the clipboard list
#
# $ multi_clipboards.sh -o
# # Will show the clipboard list, then select one, which will be placed
# # the top of the clipboard list.
#
# $ multi_clipboards.sh -O
# # Same as "-o", in addition, sent it to the screen's clipboard
#
# $ multi_clipboards.sh -s
# # Push the arguments to the clipboard of screen
#
# $ multi_clipboards.sh -x
# # Send the last clipboard to the clipboard of OS (X server)
# # Even if CLX is not set, it uses CLXOS, is available
#
#
# # For all case,
# # f CLX is set, a selected clipboard is sent to the clipboard of OS (X server)
#
# See also settings for screen and variables which can be set in .bashrc below
# }}}

# Settings for screen {{{
#
# To use in screen, put this script where
# PATH is set (or make alias), and write in .screenrc:
#
# ----------.screenrc---------
# bufferfile "$SCREENEXCHANGE"
# bindkey -m ' ' eval 'stuff \040' 'writebuf' 'exec !!! multi_clipboards -I'
# bindkey -m Y eval 'stuff Y' 'writebuf' 'exec !!! multi_clipboards -I'
# bindkey -m W eval 'stuff W' 'writebuf' 'exec !!! multi_clipboards -I'
# bind a eval "!bash -c 'multi_clipboards -O;echo -n \"$SCREEN_PS1\"'"
# bind ^a eval "!bash -c 'multi_clipboards -O;echo -n \"$SCREEN_PS1\"'"
# ----------.screenrc---------
#
# These settings enable that a clipboard copied by SPACE, Y and  W
# in the copy mode will be sent to the clipboard list.
# If CLX is set, it is also sent to the OS's (X server's) clipboard.
#
# C-a a (C-a) can be used to select a clipboard from the list,
# instead of using multi_clipboards.sh -O
#
# Note: To use C-a a (C-a), it is better to set
# "SCREEN_PS1" which should be as simialr as PS1 in .bashrc
# (because after C-a a, it stops w/o prompt)
#
# }}}

# Set valuse {{{
# Following variables can be set in .bashrc or else
#
# CLIPBOARD, SCREENEXCHANGE, CLMAXHIST, CLX, CLXOS, CLSEP
# (Refer default values below)

# File to keep clipboards
clb=${CLIPBOARD:-$HOMOE/.clipboard}

# File for screen's clipboard
scex=${SCREENEXCHANGE:-$HOME/.screen-exchange}

# Max number of clipboards to keep
max=${CLMAXHIST:-10}

# Application to sent the clipboard to the OS's clipboard
# If blank, don't copy the clipboard to the OS's clipboard
# other than when "-x" is given
clx=${CLX:-""}

# Application to sent the clipboard to the OS's clipboard
# to be used for "-x" option
if [ "$CLXOS" != "" ];then
  clxos=${CLXOS}
elif [[ "$OSTYPE" =~ "linux" ]];then
  if which -s xsel;then
    export clxos="xsel"
  elif which -s xsel;then
    export clxos="xclip"
  fi
elif [[ "$OSTYPE" =~ "cygwin" ]];then
  if which -s putclip;then
    export clxos="putclip"
  elif which -s xsel;then
    export clxos="xsel"
  elif which -s xsel;then
    export clxos="xclip"
  fi
elif [[ "$OSTYPE" =~ "darwin" ]];then
  if which -s pbcopy;then
    export clxos="pbcopy"
  fi
fi

# Separator of clipboards in the file
cls="${CLSEP:-}"

# }}}

function mcpush { # {{{
  # Set input
  input="$*"

  # Ignore blank
  if [ "$*" = "" ];then
    return
  fi

  # Get old words
  touch $clb
  orig_ifs=$IFS
  IFS="$cls"
  touch $clb
  clbs=(`cat $clb`)
  IFS=$orig_ifs
  nclbs=${#clbs[*]}

  #echo
  #printf "input: $input"
  #echo
  # Renew words
  i=0
  j=1
  printf "$input$cls" > $clb
  while [ $i -lt $nclbs ] && [ $j -lt $((CLMAXHIST)) ] ;do
    iuse=$i
    i=$((i+1))

    #echo "try $iuse, ${clbs[$iuse]}"
    # Remove duplications
    if [ "$input" = "${clbs[$iuse]}" ];then
      #echo
      #echo "$iuse      : no use"
      #echo "\$\*    : $input"
      #echo "clbs[$iuse]: ${clbs[$iuse]}"
      continue
    fi
    printf "${clbs[$iuse]}$cls" >> $clb
    j=$((j+1))
  done

  # Copy to clipboard of X
  if [ "$clx" != "" ];then
    printf "$*" | $clx
  fi
} # }}}

function mcpushsc { # {{{
  mcpush "$(cat $scex)"
} # }}}

function mcpop { # {{{
  ## Show stored words
  orig_ifs=$IFS
  IFS="$cls"
  touch $clb
  clbs=(`cat $clb`)
  IFS=$orig_ifs
  nclbs=${#clbs[*]}
  i=$((nclbs-1))
  while [ $i -ge 0 ];do
    clbshow=`echo "${clbs[$i]}" |perl -pe 's/\n/\a/g' |perl -pe 's/\a/\n   /g' |perl -pe 's/   $//g'`
    printf "%2d: $clbshow\n" $i
    i=$((i-1))
  done

  # Choose buffer
  printf "\nchoose buffer:"
  read n
  if ! echo $n|grep -q "^[0-9]\+$" || [ "$n" -ge "$nclbs" ];then
    echo "$f is not valid"
    echo "Use mcpop [0-$((nclbs-1))]"
    return 1
  fi
  c="${clbs[$n]}"

  # Align clipboards
  printf "$c$cls" > $clb
  i=0
  while [ $i -lt $nclbs ];do
    if [ ! $i -eq $n ];then
      printf "${clbs[$i]}$cls" >> $clb
    fi
    i=$((i+1))
  done

  # Copy to clipboard of X
  if [ "$clx" ];then
    printf "$c" | $clx
  fi
} # }}}

function mcpopsc { # {{{
  mcpop
  local ret=$?
  if [ $ret -ne 0 ];then
    return $ret
  fi
  local orig_ifs=$IFS
  IFS="$cls"
  touch $clb
  local clbs=(`cat $clb`)
  IFS=$orig_ifs
  printf "${clbs[0]}" > $scex
  screen -X readbuf
} # }}}

function mcpushx { # {{{
  clx=${clx:-${clxos}}
  if [ ! "$clx" ];then
    echo "No clip board application is assigned!"
    return
  fi
  orig_ifs=$IFS
  IFS="$cls"
  touch $clb
  clbs=(`cat $clb`)
  IFS=$orig_ifs
  printf "${clbs[0]}" | $clx
} # }}}

# Check arguments and execute commands{{{
if [ "$1" = "-s" ];then
  # pushpopsc
  shift
  mcpush "$*"
  mcpopsc
elif [ "$1" = "-x" ];then
  # pushpopsc
  mcpushx
elif [ "$1" = "-i" ];then
  # push
  shift
  mcpush "$*"
elif [ "$1" = "-I" ];then
  # pushsc
  mcpushsc
elif [ "$1" = "-o" ];then
  # pop
  mcpop
else # -O or else
  # popsc"
  mcpopsc
fi # }}}
