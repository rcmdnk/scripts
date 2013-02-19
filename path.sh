#!/bin/bash
if [ $# -eq 0 ];then
  echo "usage: path file/directory"
fi
curdir=`pwd`
godir=`dirname $1`
name=`basename $1`
cd $godir
fullpath=`pwd -P`/$name
cd $curdir
echo $fullpath
