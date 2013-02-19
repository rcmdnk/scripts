#!/bin/bash
scex=$HOMOE/.screen-exchange
if [ "$SCREENEXCHANGE" != "" ];then
  scex=$SCREENEXCHANGE
fi
if [ "$CLIPBOARD" != "" ];then
  clb=$CLIPBOARD
fi
if [ "$1" != "-n" ];then
  myClPop
fi
cp $clb/clb.0 $scex
screen -X readbuf
