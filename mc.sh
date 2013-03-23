#!/bin/sh

# Multi (Manage) Clipboards!
# *** Utility to keep multiple clipboards ***
# *** and manage screen's clipboard.      ***

# Set valuse {{{
# Following variables should be set in .bashrc or else

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
else
  if [[ "$OSTYPE" =~ "linux" ]];then
    clxos="xsel"
  elif [[ "$OSTYPE" =~ "cygwin" ]];then
    clxos="putclip"
  elif [[ "$OSTYPE" =~ "darwin" ]];then
    clxos="pbcopy"
  fi
fi

# Separator of clipboards in the file
cls="${CLSEP:-}"
# }}}

# Mode {{{
# -i (mcpush)  : Push in arguments to the clipboard list
#
# -I (mcpushsc): Push in screen's clipboard to the clipboard list
#
# -o (mcpop)   : Pop out one clipboard from the clipboard list
#
# -O (mcpopsc) : Pop out one clipboard from the clipboard list
#              : and put it to the screen's clipboard
#
# -s (mcpush)  : Push the arguments to screen's clipboard list
#    (+mcpop)  : and put it to the screen's clipboard
#
# -x           : Put the newest clipboard to the OS's clipboard
#              : using CLX  or CLXOS, if CLX is not set
#              : (need X connection)
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
