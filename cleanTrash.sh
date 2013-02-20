#!/bin/bash
. ~/.bashrc
if [ "$TRASH" = "" ];then
  echo "please set TRASH"
  exit
fi
FLAG="FALSE"
while [ $FLAG = "FALSE" ];do
  TRASH_BOX_SIZE=`du -ms ${TRASH} |awk '{print $1}'`
  if [ ${TRASH_BOX_SIZE} -gt ${MAXTRASHSIZE} ];then
    DELETE_DIR=`ls ${TRASH_BOX_DIR} | head -1`
    rm -rf ${TRASH}/${DELETE_DIR}
  else
    FLAG="TRUE"
  fi
done
