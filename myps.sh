#!/bin/bash
NPROCESSES=10
ps axr -o %cpu -o %mem -o comm|head -n$((NPROCESSES+1))|tail -n$NPROCESSES >/tmp/pstmp
echo "  CPU  MEM  CMD"
while read line;do
  cpu=`echo ${line[*]}|cut -d' ' -f1`
  mem=`echo ${line[*]}|cut -d' ' -f2`
  cmd=`echo ${line[*]}|cut -d' ' -f3-`
  if echo ${cmd[*]}|grep -q "/";then
    cmd=`echo ${cmd[*]} |awk -F, '{n=split($1,tmp,"/")}{print tmp[n]}'`
  fi
  printf "%5s%5s %s\n" $cpu $mem $cmd
done < /tmp/pstmp
rm -r /tmp/pstmp
