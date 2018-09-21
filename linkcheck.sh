#!/usr/bin/env bash

# Find the original file for the symbolic link
if [[ "$#" -ne 1 ]];then
  echo "Usage: linkcheck file/directory" >&2
  exit 1
fi

link="$1"
prelink="$1"
curdir=$PWD
while :;do
  if [[ -L "$link" ]];then
    echo "$link ->"
    prelink=$link
    link=$(readlink "$link")
    dir="$(dirname "$prelink")"
    if [[ -d "$dir" ]];then
      cd "$dir"
    fi
  elif [[ -e "$link" ]];then
    echo "$link"
    exit 0
  else
    echo "$link does not exist!" >&2
    cd "$curdir"
    exit 2
  fi
done
cd "$curdir"
