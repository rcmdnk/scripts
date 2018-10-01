#!/usr/bin/env bash

###########################
#   cron tab example
#  ------------------------
#  # settings
#  SHELL=/bin/bash
#  PATH=$HOME/usr/bin:$PATH
#  MAILTO=xxx@yyy.zzz
#  # min hour day/month month day/week machine command
#  #########################
#  # weekly
#  10 1 * * 0 cronWrapper echo weekly at 1:10 Sunday!
#  # daily
#  00 15 * * * cronWrapper echo daily at 15:00!

# mail setting
mailto=""
if [ -f ~/.mailto ];then
  mailto=$(grep "^MAILTO" ~/.mailto|head -n1|cut -d= -f2)
  mailto=$(eval echo "$mailto")
fi

crontmp=.cron.$HOSTNAME.$PPID
"$@" >"$crontmp" 2>&1
if [ -s "$crontmp" ];then
  #node=$(hostname)
  exe=$(basename "$1")
  shift
  if [ "$mailto" != "" ];then
    mail -s "$exe $* at $HOSTNAME CRONINFORMATION" "$mailto" < "$crontmp"
  else
    cat "$crontmp"
  fi
fi
rm -f "$crontmp"
