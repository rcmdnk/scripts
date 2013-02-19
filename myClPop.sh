#!/bin/bash
clb=$HOMOE/.clipboard
max=10
mycl=
if [ "$CLIPBOARD" != "" ];then
  clb=$CLIPBOARD
fi
if [ "$CLMAXHIST" != "" ];then
  max=$CLMAXHIST
fi
if [ "$MYCL" != "" ];then
  mycl=$MYCL
fi
i=$(($max-1))
while [ $i -ge 0 ];do
  printf "%4d: " $i
  touch $clb/clb.$i
  cat $clb/clb.$i
  echo
  i=$(($i-1))
done
echo ""
echo -n "choose buffer:"
read n
f="$clb/clb.$n"
j=$(($max-1))
if [ ! -f $f ];then
  echo "$f doesn't exist"
  echo "use myClPop <0-$j>"
  exit
fi
c=`cat $f`

i=$(($n-1))
while [ $i -ge 0 ];do
  j=$(($i+1))
  touch $clb/clb.$i
  mv $clb/clb.$i $clb/clb.$j
  i=$(($i-1))
done
echo -n $c > $clb/clb.0
if [ "$mycl" != "" ];then
  cat $clb/clb.0 | $mycl
fi
