#!/bin/bash
echo -en '\033k'
sdir=$(pwd | sed s#${HOME}#~#)
#dirlen=$(echo $sdir | wc -c)
dirlen=`echo ${#sdir}`
if [ $dirlen -gt 19 ] ; then
  #ssdir="$(echo $sdir | cut -b 1-9)~$(echo $sdir | cut -b $(($dirlen-8))-$dirlen)"
  ssdir="~$(echo $sdir | cut -b $(($dirlen-19))-$dirlen)"
else
  ssdir="$(echo $sdir)"
fi
echo $ssdir
echo -en '\033\\'
