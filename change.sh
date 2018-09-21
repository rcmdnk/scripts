#!/usr/bin/env bash

# Change words in file by sed
case $# in
  0)
    echo "enter file name and words of before and after"
  ;;
  1)
    echo "enter words of before and after"
  ;;
  2)
    sed -i.bak "s!$2!!g" "$1"
    rm -f "$1".bak
  ;;
  3)
    sed -i.bak "s!$2!$3!g" "$1"
    rm -f "$1".bak
  ;;
  *)
    echo "enter file name and words of before and after"
  ;;
esac
