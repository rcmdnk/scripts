#!/bin/bash
for c in {0..255};do
  echo -n $'\e[38;5;'${c}"m"`printf " %03d" ${c}`$'\e['"m"
  echo -n $'\e[48;5;'${c}"m"`printf " %03d" ${c}`$'\e['"m"
  if [ $(($c%8)) -eq 7 ];then
    echo
  fi
done
