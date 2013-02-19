#/bin/bash
if [ $# -ne 1 ]
then
  echo "enter one tex file name"
  echo "(enter \"name\" for file \"name.tex\")"
else
  NAME=`echo $1|awk '{split($1,tmp,".tex$")}{print tmp[1]}'`
  if [ -z $NAME ];then
    NAME=$1
  fi
  platex $NAME
  platex $NAME
  bibtex $NAME
  bibtex $NAME
  platex $NAME
  platex $NAME
#  pdvips $NAME -o $NAME.ps
#  ps2pdf $NAME.ps $NAME.pdf
  dvipdfm $NAME.dvi
  #rm -f $NAME.dvi $NAME.log $NAME.aux $NAME.ps
fi
