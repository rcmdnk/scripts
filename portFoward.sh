#!/usr/bin/env bash
if [ $# -lt 2 ];then
  echo "usage: port_forward <host> <port> [<host only on which to be run>]"
  exit 1
fi
host=$1
port=$2

if ps -A|grep $(basename $0)|grep $host|grep -q $port;then
  exit 0
fi

while :;do
  ret=$(ssh -x "$host" netstat -a 2>/dev/null)
  if [ $? -ne 0 ];then
    # Could be offline
    #echo "Cound not resolve hostname $host"
    exit 0
  fi
  if echo "$ret"|grep "$port"|grep -q "LISTEN";then
    #echo "Already running"
    exit 0
  fi
  cmd="ssh -S none -x -N -R ${port}:localhost:22 ${host}"
  if [ $? -ne 0 ];then
    exit 1
  fi
  pids=($(pgrep -u"$USER" -f "$cmd"))
  if [ "${#pids[@]}" -ne 0 ];then
    #echo "kill -kill ${pids[@]}"
    kill -kill "${pids[@]}" >& /dev/null
  fi
  #echo $cmd
  eval "$cmd" >& /dev/null &
  sleep 1
done
