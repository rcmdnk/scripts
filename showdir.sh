#!/bin/bash
maxlen=20
dir="${PWD/#$HOME/~}"
if [ ${#dir} -gt $maxlen ];then
  dir=!`echo $dir | cut -b $((${#dir}-$maxlen+2))-${#dir}`
fi
if [[ "$TERM" =~ "screen" ]]; then
  printf "\ek$dir\e\\"
  #printf "\eP\e]0;%s@%s:%s\a\e\\" "${USER}" "${HOSTNAME%%.*}" "${PWD/#$HOME/~}"
else
  printf "$dir\n"
fi
