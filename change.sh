#!/bin/bash
case $# in
  0)
    echo "enter file name and words of before and after"
  ;;
  1)
    echo "enter words of before and after"
  ;;
  2)
    sed -i s!"$2"!!g "$1"
    #sed s!"$2"!!g "$1" > "$1".tmp
    #mv "$1".tmp "$1"
  ;;
  3)
    sed -i s!$2!$3!g "$1"
    #echo "sed -i s!$2!$3!g "$1""
    #sed s!$2!$3!g "$1" > "$1".tmp
    #mv "$1".tmp "$1"
  ;;
  *)
    echo "enter file name and words of before and after"
  ;;
esac
