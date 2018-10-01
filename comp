#!/usr/bin/env bash

# Compression

remove=0
HELP="
usage: comp [-r] directory_name [package_name]

       -r for remove original directory
       if package_name is not given, it makes file:
       directory_name.tar.gz"

if [[ $# -eq 0 ]];then
  echo "$HELP"
elif [[ "$1" = "-d" ]];then
  remove=1
  shift
fi
dir=${1%/*}
case "$#" in
        0)
  echo "$HELP"
  ;;
        1)
  echo "${dir}"
  tar czf "${dir}.tar.gz" "${dir}"
  ;;
        2)
  tar czf "${2}" "${dir}"
  ;;
esac
if [[ $remove -eq 1 ]];then
  rm -rf "${dir}"
fi
