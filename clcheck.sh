#!/bin/bash

OPTNUM=0
LIST=0
CHOICE=0
NTH=1
while getopts cln:h OPT;do
  OPTNUM=`expr $OPTNUM + 1`
  case $OPT in
    "c" ) CHOICE=1 ;;
    "l" ) LIST=1 ;;
    "n" ) NTH="$OPTARG" ;;
    "h" ) echo -1; exit ;;
    * ) echo -1; exit ;;
  esac
done

if [ ${OPTNUM} -eq 0 ];then
  if [ "$#" -ne 0 ];then
    echo -1
  else
    echo 1
  fi
elif [ ${OPTNUM} -ne 1 ];then
  echo -1
elif [ $LIST -eq 1 ];then
  echo -2
elif [ $CHOICE -eq 1 ];then
  echo -3
else
  echo $NTH
fi

