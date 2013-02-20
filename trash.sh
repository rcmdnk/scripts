#!/bin/bash
. ~/.bashrc
if [ "$TRASH" = "" ];then
  echo "please set TRASH"
  exit
fi
if [ "$#" -lt 1 ]
then
  echo "enter junk files or directories"
else
  if [ ! -d $TRASH ];
  then
    mkdir -p $TRASH
  fi

  while [ "$#" -gt 0 ];do
    NAME=`echo $1 | sed -e "s|/$||" | sed -e "s|.*/||"`
    TRASH_HEAD=${TRASH}/${NAME}
    TRASH_NAME=${TRASH_HEAD}
    i=1
    while true;do
      if [ -s ${TRASH_NAME} ];then
        TRASH_NAME=${TRASH_HEAD}.${i}
        i=`expr ${i} + 1`
      else
        break
      fi
    done

    mv -i $1 ${TRASH_NAME}
    echo $1 was moved to ${TRASH_NAME}
    shift
  done
fi
