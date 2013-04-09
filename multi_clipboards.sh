#!/bin/bash

# Multi (Manage) Clipboards for GNU screen!
# *** Utility to keep multiple clipboards ***
# *** and manage screen's clipboard.      ***


# Usage {{{
#
# $ multi_clipboards.sh -i [args]
# # Push [args]to the clipboard list
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
# $ multi_clipboards.sh -s [args]
# # Send [args] to the screen's clipboard
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
# PATH is set , and write in .screenrc:
#
# ----------.screenrc---------
# bufferfile "$SCREENEXCHANGE" # SCREENEXCHANGE must be set in .bashrc !!!
# bindkey -m ' ' eval 'stuff \040' 'writebuf' 'exec !!! multi_clipboards.sh -I'
# bindkey -m Y eval 'stuff Y' 'writebuf' 'exec !!! multi_clipboards.sh -I'
# bindkey -m W eval 'stuff W' 'writebuf' 'exec !!! multi_clipboards.sh -I'
# bind a eval "!bash -c 'multi_clipboards.sh -O;echo -n \"$SCREEN_PS1\"'"
# bind ^a eval "!bash -c 'multi_clipboards.sh -O;echo -n \"$SCREEN_PS1\"'"
# ----------.screenrc---------
#
# These settings enable that a clipboard copied by SPACE, Y and  W
# in the copy mode will be sent to the clipboard list.
# If CLX is set, it is also sent to the OS's (X server's) clipboard.
#
# C-a a (C-a) can be used to select a clipboard from the list,
# instead of using multi_clipboards.sh -O
#
#
# And set environmental variables in .bashrc
# ----------.bashrc---------
# export SCREENEXCHANGE=$HOME/.screen-exchange
# export SCREEN_PS1='printf "\e]0;%s@%s:%s\a" "${USER}" "${HOSTNAME%%.*}" "${PWD/#$HOME/~}"'
# export CLIPBOARD=$HOME/.clipboard
# export CLMAXHIST=20
# export CLSEP="" # "" was inserted with "C-v C-g", use bell as a separator
# export CLX="" #xsel/xclip
# if [[ "$OSTYPE" =~ "linux" ]];then
#   if which -s xsel;then
#     export CLXOS="xsel"
#   elif which -s xsel;then
#     export CLXOS="xclip"
#   fi
# elif [[ "$OSTYPE" =~ "cygwin" ]];then
#   if which -s putclip;then
#     export CLXOS="putclip"
#   elif which -s xsel;then
#     export CLXOS="xsel"
#   elif which -s xsel;then
#     export CLXOS="xclip"
#   fi
# elif [[ "$OSTYPE" =~ "darwin" ]];then
#   if which -s pbcopy;then
#     export CLXOS="pbcopy"
#   fi
# fi
# ----------.bashrc---------
#
#
# Note 1): SCREENEXCHANGE must be set in .bashrc
#          or you must remove the bufferfile definition line from .screenrc
#          In the later case, /tmp/screen-exchange will be used.
#
# Note 2): It is better to set "SCREEN_PS1", which should be similar as PS1
#          (though it is not possible to change interactively.),
#          because after C-a a, it stops w/o prompt.
#          If you prefer not to show a bit wrong prompt
#          and prefer show nothing, don't need to set this value.
#          Or you can just use multi_clipboards.sh -O instead of
#          screen's binding (alias may be useful)
# }}}

# Set valuse {{{
# Following variables can be set in .bashrc or else
#
# CLIPBOARD, SCREENEXCHANGE, CLMAXHIST, CLX, CLXOS, CLSEP
# (Refer default values below)

# File to keep clipboards
clb=${CLIPBOARD:-$HOMOE/.clipboard}
touch $clb

# File for screen's clipboard
scex=${SCREENEXCHANGE:-/tmp/screen-exchange}
touch $scex

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
  if which xsel >/dev/null 2>&1;then
    export clxos="xsel"
  elif which xsel >/dev/null 2>&1;then
    export clxos="xclip"
  fi
elif [[ "$OSTYPE" =~ "cygwin" ]];then
  if which putclip >/dev/null 2>&1;then
    export clxos="putclip"
  elif which xsel >/dev/null 2>&1;then
    export clxos="xsel"
  elif which xsel >/dev/null 2>&1;then
    export clxos="xclip"
  fi
elif [[ "$OSTYPE" =~ "darwin" ]];then
  if which pbcopy >/dev/null 2>&1;then
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
  orig_ifs=$IFS
  IFS="$cls"
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
  clbs=(`cat $clb`)
  IFS=$orig_ifs
  nclbs=${#clbs[*]}
  i=$((nclbs-1))
  echo
  while [ $i -ge 0 ];do
    clbshow=`echo "${clbs[$i]}" |perl -pe 's/\n/\a/g' |perl -pe 's/\a/\n    /g' |perl -pe 's/    $//g'`
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
  local orig_ifs=$IFS
  IFS="$cls"
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
  shift
  mcpushx
elif [ "$1" = "-i" ];then
  # push
  shift
  mcpush "$*"
elif [ "$1" = "-I" ];then
  # pushsc
  shift
  mcpushsc
elif [ "$1" = "-o" ];then
  # pop
  shift
  mcpop
else # -O or else
  # popsc"
  mcpop
  ret=$?
  if [ $ret -ne 0 ];then
    exit $ret
  fi
  mcpopsc
fi # }}}
