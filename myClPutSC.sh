#!/bin/bash
scex=$HOME/.screen-exchange
if [ "$SCREENEXCHANGE" != "" ];then
  scex=$SCREENEXCHANGE
fi
c=`cat $scex`
myClPut $c
