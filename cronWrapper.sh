#!/bin/sh

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
#  00 15 * * * cronWrapper.sh echo daily at 15:00!

# mail setting
mailto=""
if [ -f ~/.mailto ];then
  mailto=`grep MAILTO ~/.mailto|cut -d= -f2`
fi

crontmp=cron.$PPID
$@ >$crontmp 2>&1
if [ -s $crontmp ];then
  node=`hostname`
  sed -i'' -e "1s/^/working at $HOSTNAME\n\n/" $crontmp
  if [ "$MAILTO" != "" ];then
    cat $crontmp | mail -s "$@" $MAILTO
  else
    cat $crontmp
  fi
fi
rm -f $crontmp
