#!/bin/bash
. ~/.bashrc

# max lines
maxline=20

# gcal list file
gcallist=~/.gcallist

# List of calenders
cals="--cal=gmail --cal=Facebook --cal=Time"
# gmail   : Main calendar
# Facebook: Calendars of Facebook (including birthdays)
# Time    : Calendars for each location (JapanTime, etc...)

# set time
start=`date +"%m/%d/%y"` #today
end=`date -v +2m +"%m/%d/%y"` #two months later

# get tasks
cur_day=""
cur_day_show=0
events=("")
lines=()
gcalcli --military --nocolor $cals agenda $start $end > ${gcallist}.tmp
IFS_ORIG=$IFS
IFS=$'\n'
while read line;do
  if [ "$line" != "" ];then
    lines=("${lines[@]}" "$line")
  fi
done < ${gcallist}.tmp
rm -f ${gcallist}.tmp
IFS=$IFS_ORIG
nline=0
for line in "${lines[@]}";do
  if [ "$line" = "" ];then
    continue
  fi
  d=${line:0:10}
  t=${line:12:5}
  e=${line:19}
  if [ "$d" != "          " ];then
    cur_day=$d
    cur_day_show=0
  fi
  dup=0
  for pre_e in "${events[@]}";do
    if [ "$e" = "$pre_e" ];then
      dup=1
      break
    fi
  done
  if [ $dup -eq 1 ];then
    continue
  fi
  events=("${events[@]}" "$e")
  if [ $cur_day_show -eq 0 ];then
    echo ${cur_day}":"
    cur_day_show=1
  fi
  if [ "$t" = "     " ];then
    t=""
  else
    t="${t} "
  fi
  echo " ${t}${e}"
  nline=$((nline+1))
  if [ $nline -ge $maxline ];then
    break
  fi
done > $gcallist

# show the list
#clear
cat $gcallist
