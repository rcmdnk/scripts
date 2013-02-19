#!/bin/bash
DIR=`echo $1|awk '{split($1,tmp,"/")}{print tmp[1]}'`
case "$#" in

        0)
  echo "usage::press directory_name (+ package_name)"
  ;;

        1)
  echo ${DIR}
  tar czf ${DIR}.tar.gz ${DIR}
  #rm -rf ${1}
  ;;

        2)
  tar czf ${2} ${DIR}
  #rm -rf ${1}
  ;;

esac
