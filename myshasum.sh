#!/usr/bin/env bash

alg=256
if [ "$1" = "-a" ];then
  shift
  alg=$1
  shift
fi

if [ $# -eq 0 ];then
  echo "usage: $0 [-a <alg (default=256)>] file [file2 [file3...]]"
  exit
fi

for f in "$@";do
  if [[ "$f" =~ http* ]];then
    d=$(mktemp -d)
    trap 'rm -rf $d' HUP INT QUIT ABRT SEGV TERM
    cd "$d"
    log=$(wget --no-check-certificate "$f" 2>&1)
    ret=$?
    if [ $ret -ne 0 ];then
      echo "failed: wget --no-check-certificate $f"
      echo ""
      echo "$log"
      exit $ret
    fi
    f=$(basename "$f")
  fi
  shasum -a "$alg" "$f"
  if [ -n "$d" ];then
    rm -rf "$d"
  fi
done
