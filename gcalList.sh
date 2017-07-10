#!/usr/bin/env bash
. ~/.bashrc

# max lines
maxline=20

# gcal list file
gcallist=~/.gcallist
tmpfile=$(mktemp 2>/dev/null||mktemp -t tmp)

# List of calenders
cals="--cal=gmail --cal=Time"
# gmail   : Main calendar
# Facebook: Calendars of Facebook (including birthdays)
# Time    : Calendars for each location (JapanTime, etc...)
if [ -f ~/.gcallistcals ];then
  cals=""
  while read -r c;do
    cals="$cals --cal=$c"
  done < ~/.gcallistcals
fi

# set time
start=$(date +"%m/%d/%y") #today
end=$(date -v +2m +"%m/%d/%y") #two months later

# get tasks
cur_day=""
cur_day_show=0
events=("")
lines=()
echo gcalcli --military --nocolor ${cals} agenda "$start" "$end"
gcalcli --military --nocolor ${cals} agenda "$start" "$end" > "$tmpfile"
IFS_ORIG=$IFS
IFS=$'\n'
while read -r line;do
  if [ "$line" != "" ];then
    lines=("${lines[@]}" "$line")
  fi
done < "$tmpfile"


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
    echo "${cur_day}:"
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
done > "$tmpfile"
if [ "$(wc -l < "$tmpfile")" -gt 0 ];then
  mv "$tmpfile" "$gcallist"
fi
rm -f "$tmpfile"

# show the list
cat $gcallist
