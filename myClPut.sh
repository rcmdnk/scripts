#!/bin/bash

#default values
clb=$HOME/.clipboard
max=10
mycl=

#values from environment settings
if [ "$CLIPBOARD" != "" ];then
  clb=$CLIPBOARD
fi
if [ "$CLMAXHIST" != "" ];then
  max=$CLMAXHIST
fi
if [ "$MYCL" != "" ];then
  mycl=$MYCL
fi

#check new words
mkdir -p $clb
touch $clb/clb.0
old=`cat $clb/clb.0`
new=`echo $*`
if [ "$old" != "$new" ];then
  #add new words
  i=$(($max-2))
  while [ $i -ge 0 ];do
    j=$(($i+1))
    touch $clb/clb.$i
    mv $clb/clb.$i $clb/clb.$j
    i=$(($i-1))
  done
  echo -n $* > $clb/clb.0
fi

#copy to clipboard
if [ "$mycl" != "" ];then
  #echo "echo -n $* | $mycl"
  echo -n $* | $mycl
fi
