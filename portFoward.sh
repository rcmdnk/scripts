#!/usr/bin/env bash
if [ $# -lt 2 ];then
  echo "usage: port_forward <host> <port>"
  exit 1
fi
host=$1
port=$2

while [ 1 ];do
  ret=$(ssh -x $host netstat -a 2>/dev/null)
  if [ $? -ne 0 ];then
    # Could be offline
    #echo "Cound not resolve hostname $host"
    exit
  fi
  if echo "$ret"|grep $port|grep -q "LISTEN";then
    exit 0
  fi
  pids=$(ps -u$USER|grep "ssh -x -N -R ${port}:localhost:22 ${host}"|grep -v grep|awk '{print $2}')
  if [ "$pids" != "" ];then
    kill -kill $pids >& /dev/null
  fi
  ssh -x -N -R $port:localhost:22 $host >& /dev/null &
done