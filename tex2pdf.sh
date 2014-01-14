#!/usr/bin/env bash
if [ $# -ne 1 ]
then
  echo "enter one tex file name"
  echo "(enter \"name\" for file \"name.tex\")"
else
  name=`echo $1|awk '{split($1,tmp,".tex$")}{print tmp[1]}'`
  if [ -z $name ];then
    name=$1
  fi
  echo $name.aux
  rm -f $name.aux
  rm -f $name.bbl
  rm -f $name.blg
  platex $name
  platex $name
  bibtex $name
  bibtex $name
  platex $name
  platex $name
  #pdvips $name -o $name.ps
  #ps2pdf $name.ps $name.pdf
  dvipdfm $name.dvi
  #rm -f $name.dvi $name.log $name.aux $name.ps
fi
