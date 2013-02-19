#!/bin/bash
MAXTRASHSIZE=1000
TRASH_BOX_DIR="$HOME/.trash/"
FLAG="FALSE"
while [ $FLAG = "FALSE" ];do
  TRASH_BOX_SIZE=`du -ms ${TRASH_BOX_DIR} |awk '{print $1}'`
  if [ ${TRASH_BOX_SIZE} -gt ${MAXTRASHSIZE} ];then
    DELETE_DIR=`ls ${TRASH_BOX_DIR} | head -1`
    rm -rf ${TRASH_BOX_DIR}/${DELETE_DIR}
  else
    FLAG="TRUE"
  fi
done
