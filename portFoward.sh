#!/usr/bin/env bash
if [ $# -lt 2 ];then
  echo "usage: port_forward <host> <port>"
  exit 1
fi
host=$1
port=$2

pid=""
while [ 1 ];do
  ret=$(ssh -x $host netstat -a|grep $port 2>&1) >& /dev/null
  if [ $? -ne 0 ];then
    # Could be offline
    #echo "Cound not resolve hostname $host
    exit
  fi
  if echo "$ret"|grep -q "LISTEN";then
    exit 0
  fi
  if [ "$pid" != "" ];then
    kill -kill $pid >& /dev/null
  fi
  ssh -x -N -R $port:localhost:22 $host >& /dev/null &
  pid=$!
done
