#!/bin/bash
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
gcalcli --military $cals agenda $start $end > $gcallist

# show the list
#clear
cat $gcallist
