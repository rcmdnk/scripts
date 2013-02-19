#!/bin/bash

HELP="  usage: calc num1 (add, sub, mul or div) num2
  or   : calc num1 (+, -, \* or /) num2
  notice: you must use \"*\" or \* instead of asterisk  only
"
if [ "$#" -ne 3 ];then
  echo "$HELP"
  exit
fi
formnum() {
  NUM=$1
  ISE=`echo $NUM|awk '{split($1,tmpf,"E")} {print tmpf[2]}'`
  if [ ! -z $ISE ];then
    ISE1=`echo $NUM|awk '{split($1,tmpf,"E")} {print tmpf[1]}'`
    ISPLUS=`echo $ISE|awk '{split($1,tmpf,"+")} {print tmpf[2]}'`
    if [ ! -z $ISPLUS ];then
      NUM=`echo ${ISE1} "* 10^" ${ISPLUS}|bc -l`
    else
      ISMINUS=`echo $ISE|awk '{split($1,tmpf,"-")} {print tmpf[2]}'`
      NUM=`echo ${ISE1} "* 10^-" ${ISMINUS}|bc -l`
    fi
  fi
  ISe=`echo $NUM|awk '{split($1,tmpf,"e")} {print tmpf[2]}'`
  if [ ! -z $ISe ];then
    ISe1=`echo $NUM|awk '{split($1,tmpf,"e")} {print tmpf[1]}'`
    ISPLUS=`echo $ISe|awk '{split($1,tmpf,"+")} {print tmpf[2]}'`
    if [ ! -z $ISPLUS ];then
      NUM=`echo ${ISe1} "* 10^" ${ISPLUS}|bc -l`
    else
      ISMINUS=`echo $ISe|awk '{split($1,tmpf,"-")} {print tmpf[2]}'`
      NUM=`echo ${ISe1} "* 10^-" ${ISMINUS}|bc -l`
    fi
  fi
  echo $NUM
}
NUM1=`formnum $1`
NUM2=`formnum $3`
#echo $NUM1
#echo $NUM2
#echo $2

case $2 in
  "add")
     echo $NUM1 + $NUM2|bc -l
  ;;
  "+")
     echo $NUM1 + $NUM2|bc -l
  ;;
  "sub")
     echo $NUM1 - $NUM2|bc -l
  ;;
  "-")
     echo $NUM1 - $NUM2|bc -l
  ;;
  "mul")
     echo $NUM1 "*" $NUM2|bc -l
  ;;
  "*")
     echo $NUM1 "*" $NUM2|bc -l
  ;;
  "div")
     echo $NUM1 / $NUM2|bc -l
  ;;
  "/")
     echo $NUM1 / $NUM2|bc -l
  ;;
  *)
     echo "$HELP"
  ;;
esac
