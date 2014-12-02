#!/usr/bin/env bash
NPROCESSES=10
echo "  CPU  MEM  CMD"
ps axr -o %cpu -o %mem -o comm|head -n$((NPROCESSES+1))|tail -n$NPROCESSES| while read line;do
  cpu=$(echo "${line[*]}"|awk '{print $1}')
  mem=$(echo "${line[*]}"|awk '{print $2}')
  cmd=$(echo "${line[*]}"|awk '{for(i=3;i<NF;i++){printf("%s ",$i,OFS=" ")}print $NF}')
  if echo "${cmd[*]}"|grep -q "/";then
    cmd=$(echo "${cmd[*]}" |awk -F, '{n=split($1,tmp,"/")}{print tmp[n]}')
  fi
  printf "%5s%5s %s\n" "$cpu" "$mem" "$cmd"
done
