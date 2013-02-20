#!/bin/bash
for c in {0..255};do
  num=`printf " %03d" $c`
  printf "\e[38;5;${c}m$num\e[m"
  printf "\e[48;5;${c}m$num\e[m"
  if [ $(($c%8)) -eq 7 ];then
    echo
  fi
done
