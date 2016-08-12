#!/usr/bin/env bash
if [ $# -lt 2 ];then
  echo "usage: port_forward <host> <port> [<host only on which to be run>]"
  exit 1
fi
host=$1
port=$2

maxtry=10
i=0
while [ $i -lt $maxtry ];do
  ret=$(ssh -x "$host" netstat -a>/dev/null)
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
  if [ "${#pids[@]}" -ne 0 ];then
    #echo "kill -kill ${pids[@]}"
    kill -kill "${pids[@]}" >& /dev/null
  fi
  #echo $cmd
  eval "$cmd" >& /dev/null & 2>/dev/null
  ((i++))
  sleep 1
done
