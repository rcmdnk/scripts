#!/usr/bin/env bash

# decompression

file="$1"
if [[ ! -f "$file" ]];then
  echo "Usage: dec <file>"
fi

if [[ "$file" == *tar.gz ]];then
    tar zxf "$file"
elif [[ "$file" == *tgz ]];then
  tar zxf "$file"
elif [[ "$file" == *gz ]];then
  gzip -d "$file"
elif [[ "$file" == *tar.xz ]];then
  tar Jxf "$file"
elif [[ "$file" == *tar.bz2 ]];then
  tar jxf "$file"
elif [[ "$file" == *tar.Z ]];then
  tar zxf "$file"
elif [[ "$file" == *tar ]];then
  tar xf "$file"
elif [[ "$file" == *zip ]];then
  unzip "$file"
else
  echo "$1 is not supported."
  return 1
fi
