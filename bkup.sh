#!/usr/bin/env bash

if [ $# -ne 2 ];then
  echo "usage: bkup origDir bkupDir"
  exit
fi

logfile=$(mktemp 2>/dev/null||mktemp -t tmp)

checkdir() {
  #echo $1
  for file in `ls "${1}"`;do
    #echo -n ${1}/${file}" "
    if [ ! -e "${1}/${file}" ];then
      #echo "does not exist (maybe including space in name)"
      :
    else
      if [ -L "${1}/${file}" ];then
        #echo is symbolic link
        if [ -e "${2}/${file}" ];then
          #echo "there are file in target to link"
          :
        else
          ln -sf "${1}/${file}" "${2}/${file}"
          #echo "ln -sf" "${1}/${file}" "${2}/${file}"
        fi
      elif [ -d "${1}/${file}" ];then
        #echo is dir
        mkdir -p "${2}/${file}"
        checkdir "${1}/${file}" "${2}/${file}"
      else
        SIZE=`du -ks "${1}/${file}" |awk '{print $1}'`
        if [ $SIZE -gt 1000 ];then
          #echo is over 1000kb
          if [ -e "${2}/${file}" ];then
            #echo "there are file in target to link"
            :
          else
            #ln -fs "${1}/${file}" "${2}/${file}"
            touch "${2}/${file}"
            #echo "ln -fs" "${1}/${file}" "${2}/${file}"
          fi
        else
          #echo is file for copy
          cp -au "${1}/${file}" "${2}/${file}"
          #echo "cp -au" "${1}/${file}" "${2}/${file}"
        fi
      fi
    fi
  done
}

#echo backup $1 to $2
checkdir "$1" "$2" >> $logfile 2>&1
