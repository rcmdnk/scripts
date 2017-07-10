#!/usr/bin/env bash
. ~/.bashrc

# calendars
calHolidays=()
calExclude=()

OPTNUM=0
while getopts h:e: OPT;do
  OPTNUM=$((OPTNUM + 1))
  case $OPT in
    "h" ) calHolidays=("${calHolidays[@]}" "$OPTARG") ;;
    "e" ) calExclude=("${calExclude[@]}" "$OPTARG") ;;
  esac
done
shift $((OPTIND - 1))

# date files
gcalDays=~/.gcalDays
gcalTasks=~/.gcalTasks
gcalHolidays=~/.gcalHolidays
gcalCalDays=~/.gcalCalDays
gcalCal=~/.gcalCal
touch "$gcalDays"
touch "$gcalTasks"
touch "$gcalHolidays"
touch "$gcalCalDays"

# calendar function
myCal (){

  # gcalCal tmp
  tmpfile=$(mktemp 2>/dev/null||mktemp -t tmp)

  # this month
  date +"      %b %Y" > "$tmpfile"
  echo Su Mo Tu We Th Fr Sa >> "$tmpfile"

  w=0
  while read -r d;do
    if echo "$d"|grep -q "'";then
      printf "%b" "$d" >> "$tmpfile"
    else
      printf "%b" "$d " >> "$tmpfile"
    fi
    w=$((w+1))
    if [ $w -eq 7 ];then
      echo "" >> "$tmpfile"
      w=0
    fi
  done < "$gcalCalDays"

  if [ "$(wc -l < "$tmpfile")" -ge 3 ];then
    cp "$tmpfile" "$gcalCal"
  fi
  rm -f "$tmpfile"
  cat "$gcalCal"

}

# date configuration
gcalFormat="%a %b %d"
gcalSEFormat="%m/%d/%Y"
today=$(date +"$gcalFormat")
startDateCur=$(date -v1d +"$gcalSEFormat") #first date of this month
#endDateCur=$(date -v1d -v+1m -v-1d +"$gcalSEFormat") #end date of this month
#endDatePrev=$(date -v1d -v-1d +"$gcalSEFormat") #end date of previous month
startDayCur=$(date -v1d +%a) #first day of this month
endDayCur=$(date -v1d -v+1m -v-1d +%a) #end day of this month

if [ "$startDayCur" = "Sun" ];then
  prevDays=0
elif [ "$startDayCur" = "Mon" ];then
  prevDays=1
elif [ "$startDayCur" = "Tue" ];then
  prevDays=2
elif [ "$startDayCur" = "Wed" ];then
  prevDays=3
elif [ "$startDayCur" = "Thu" ];then
  prevDays=4
elif [ "$startDayCur" = "Fri" ];then
  prevDays=5
elif [ "$startDayCur" = "Sat" ];then
  prevDays=6
fi
if [ "$endDayCur" = "Sun" ];then
  nextDays=6
elif [ "$endDayCur" = "Mon" ];then
  nextDays=5
elif [ "$endDayCur" = "Tue" ];then
  nextDays=4
elif [ "$endDayCur" = "Wed" ];then
  nextDays=3
elif [ "$endDayCur" = "Thu" ];then
  nextDays=2
elif [ "$endDayCur" = "Fri" ];then
  nextDays=1
elif [ "$endDayCur" = "Sat" ];then
  nextDays=0
fi

# number of days in this month
nDaysCur=$(date -v1d -v+1m -v-1d +%d)

# make day list
rm -f $gcalDays
startDateCal=$(date -v1d -v-${prevDays}d +"$gcalSEFormat")
i=${prevDays}
while [ $i -gt 0 ];do
  date -v1d -v-${i}d +"$gcalFormat" >> $gcalDays
  ((i--))
done
for i in $(seq 1 "$nDaysCur");do
  date -v"${i}"d +"$gcalFormat" >> "$gcalDays"
done
endDateCal=$(date -v+1m -v1d -v+$((nextDays))d +"$gcalSEFormat")
if [ "$nextDays" -gt 0 ];then
  for i in $(seq 1 $nextDays);do
    date -v+1m -v1d -v+"$((i-1))"d +"$gcalFormat" >> "$gcalDays"
  done
fi

# get days with tasks and holidays
orig_ifs=$IFS
IFS=$'\t\n'
lines=($(gcalcli --military --nocolor --details=calendar agenda "$startDateCal" "$endDateCal"|grep -v "^$"))
ret=$?
IFS=$orig_ifs

if [ $ret -eq 0 ];then
  rm -f $gcalTasks $gcalHolidays
  touch $gcalTasks $gcalHolidays
  for line in "${lines[@]}";do
    if [ "${line:0:1}" = " " ];then
      l=$(echo $line)
    else
      date=$(echo "$line"|awk '{for(i=1;i<3;i++){printf("%s ",$i)}print $3}')
      l=$(echo "$line"|awk '{for(i=4;i<NF;i++){printf("%s ",$i)}print $NF}')
    fi
    if [[ "${l}" =~ Calendar ]];then
      cal=$(echo "$l"|awk '{for(i=2;i<NF;i++){printf("%s ",$i)}print $NF}')
      exclude=0
      for h in "${calExclude[@]}";do
        if [[ "$cal" =~ $h ]];then
          exclude=1
          break
        fi
      done
      if [ $exclude -eq 1 ];then
        continue
      fi
      isholiday=0
      for h in "${calHolidays[@]}";do
        if [[ "$cal" =~ $h ]];then
          isholiday=1
          break
        fi
      done
      if [ $isholiday -eq 1 ];then
        echo "$date $task" >> $gcalHolidays
      else
        echo "$date $task" >> $gcalTasks
      fi
    else
      task=$l
    fi
  done

  # make day list for calendar
  rm -f $gcalCalDays
  w=0
  totalDay=0
  while read -r d;do
    # check holidays
    if grep -q "$d" $gcalHolidays;then hFlag=1;
    else hFlag=0;fi
    # check Sunday or Saturday
    if [ $w -eq 0 ] || [ $w -eq 6 ];then
      hFlag=1
    fi
    #echo "holiday?" $hFlag

    # check previous month or next month
    notCur=0
    if [ $totalDay -lt $prevDays ] || [ $totalDay -ge $((prevDays+nDaysCur)) ];then
      notCur=1
    fi
    #echo "notCur?" $notCur

    # check tasks
    task=" "
    if grep -q "$d" $gcalTasks;then task="'";fi;
    #echo "task?" $task

    # get only date
    dOnly=$(echo "$d"|cut -d" " -f 3|sed "s/^0/ /g")

    # check today
    if [ "$d" = "$today" ];then
      #echo "today!"
      att='\e[7;30m'
      if [ $hFlag -eq 1 ];then
        att=$att'\e[22;4m'
      fi
      echo "${att}${dOnly}"'\e[0m'"$task" >> "$gcalCalDays"
    # other dates
    else
      att='\e[1m'
      if [ $hFlag -eq 1 ];then
        att=$att'\e[4m'
      fi
      if [ $notCur -eq 1 ];then
        att=$att'\e[22m'
      fi
      echo "${att}${dOnly}"'\e[0m'"$task" >> "$gcalCalDays"
    fi
    w=$((w+1))
    if [ $w -eq 7 ];then
      w=0
    fi
    totalDay=$((totalDay+1))
  done < $gcalDays
fi

# redo with new information
#clear
myCal
