#!/bin/bash
. ~/.bashrc

# holiday calendar
calHolidays="Holidays"

# date files
gcalDays=~/.gcalDays
gcalTasks=~/.gcalTasks
gcalHolidays=~/.gcalHolidays
gcalCalDays=~/.gcalCalDays
gcalHead=~/.gcalHead
touch $gcalDays
touch $gcalTasks
touch $gcalHolidays
touch $gcalCalDays
touch $gcalHead

# calendar function
myCal (){
  cat $gcalHead
  w=0
  while read -r d;do
    if echo $d|grep -q "'";then
      printf "$d"
    else
      printf "$d "
    fi
    w=$(($w+1))
    if [ $w -eq 7 ];then
      echo ""
      w=0
    fi
  done < $gcalCalDays
}

# fist display
#myCal


# this month
date +"      %b %Y" > $gcalHead
echo Su Mo Tu We Th Fr Sa >> $gcalHead


# date configuration
gcalFormat="%d(%a)/%b/%Y:"
gcalSEFormat="%m/%d/%Y"
today=`date +"$gcalFormat"`
startDateCur=`date -v1d +"$gcalSEFormat"` #first date of this month
endDateCur=`date -v1d -v+1m -v-1d +"$gcalSEFormat"` #end date of this month
endDatePrev=`date -v1d -v-1d +"$gcalSEFormat"` #end date of previous month
startDayCur=`date -v1d +%a` #first day of this month
endDayCur=`date -v1d -v+1m -v-1d +%a` #end day of this month

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
nDaysCur=`date -v1d -v+1m -v-1d +%d`

# make day list
rm -f $gcalDays
if [ $prevDays -eq 0 ];then
  startDateCal=$startDateCur
else
  startDateCal=`date -v1d -v-${prevDays}d +"$gcalSEFormat"`
  i=${prevDays}
  while [ $i -gt 0 ];do
    date -v1d -v-${i}d +"$gcalFormat" >> $gcalDays
    i=$(($i-1))
  done
fi
i=1
while [ $i -le $nDaysCur ];do
  date -v${i}d +"$gcalFormat" >> $gcalDays
  i=$(($i+1))
done
if [ $nextDays -eq 0 ];then
  endDateCal=endDateCur
elif [ $nextDays -eq 1 ];then
  endDateCal=`date -v1d -v+1m +"$gcalSEFormat"`
  date -v1d -v+1m +"$gcalFormat" >> $gcalDays
else
  endDateCal=`date -v1d -v+1m -v+${nextDays}d +"$gcalSEFormat"`
  date -v1d -v+1m +"$gcalFormat" >> $gcalDays
  i=1
  while [ $i -lt $nextDays ];do
    date -v1d -v+1m -v+${i}d +"$gcalFormat" >> $gcalDays
    i=$(($i+1))
  done
fi

# get the list of my google calendars
gcals=(`gcalcli --nocolor list|grep owner|sed -e 's/  owner  //'`)

# make cal argument w/o holidays
cals=""
for l in ${gcals[*]};do
  if ! echo "$l"| grep -q "$calHolidays";then
    cals="$cals --cal=$l"
  fi
done

# check if there are more than 1 calendars
if [ "$cals" = "" ];then
  echo "no cals!"
  exit
fi

# get days with tasks and holidays
gcalcli --military --nocolor $cals agenda $startDateCal $endDateCal\
  |grep "^[0-9]"> $gcalTasks
gcalcli --military --nocolor --cal=$calHolidays\
  agenda $startDateCal $endDateCal\
  |grep "^[0-9]"> $gcalHolidays

# make day list for calendar
rm -f $gcalCalDays
w=0
totalDay=0
while read d;do
  # check holidays
  if grep -q $d $gcalHolidays;then hFlag=1;
  else hFlag=0;fi
  # check Sunday or Saturday
  if [ $w -eq 0 ] || [ $w -eq 6 ];then
    hFlag=1
  fi
  #echo "holiday?" $hFlag

  # check previous month or next month
  notCur=0
  if [ $totalDay -lt $prevDays ] || [ $totalDay -ge $(($prevDays+$nDaysCur)) ];then
    notCur=1
  fi
  #echo "notCur?" $notCur

  # check tasks
  task=" "
  if grep -q $d $gcalTasks;then task="'";fi;
  #echo "task?" $task

  # get only date
  dOnly=`echo ${d%(*}|sed -e 's/^0/ /'`

  # check today
  if [ $d = $today ];then
    #echo "today!"
    att='\e[7;30m'
    if [ $hFlag -eq 1 ];then
      att=$att'\e[22;4m'
    fi
    echo ${att}${dOnly}'\e[0m'"$task" >> $gcalCalDays
  # other dates
  else
    att='\e[1m'
    if [ $hFlag -eq 1 ];then
      att=$att'\e[4m'
    fi
    if [ $notCur -eq 1 ];then
      att=$att'\e[22m'
    fi
    echo ${att}${dOnly}'\e[0m'"$task" >> $gcalCalDays
  fi
  w=$(($w+1))
  if [ $w -eq 7 ];then
    w=0
  fi
  totalDay=$(($totalDay+1))
done < $gcalDays

# redo with new information
#clear
myCal
