#!/bin/bash

bg=40
if [ "$1" != "" ];then
  if [ "$1" = "white" ] || [ "$1" = "w" ];then
    bg=47
  fi
fi

for i in {0..255}; do
  num=`printf "%03d" $i`
  printf " \e[${bg};38;05;${i}m${num}\e[m"
  if [ $((${i}%16)) -eq 15 ];then
    echo
  fi
done
