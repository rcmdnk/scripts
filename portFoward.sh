#!/usr/bin/env bash
if [ $# -lt 2 ];then
  echo "usage: port_forward <host> <port>"
  exit 1
fi
host=$1
port=$2

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
  pids=($(pgrep -u"$USER" -f "$cmd"))
  if [ "$pids" != "" ];then
    #echo "kill -kill ${pids[@]}"
    kill -kill "${pids[@]}" >& /dev/null
  fi
  #echo $cmd
  eval "$cmd" >& /dev/null &
  sleep 1
done
