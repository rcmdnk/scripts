#!/bin/bash
maxlen=15
dir=$'\ek'
dir=`pwd | sed "s|${HOME}|~|"`
if [ ${#dir} -gt $maxlen ];then
  dir=!`echo $dir | cut -b $((${#dir}-$maxlen+2))-${#dir}`
fi
if [[ "$TERM" =~ "screen" ]]; then
  printf "\ek$dir\e\\"
else
  printf "$dir\n"
fi
