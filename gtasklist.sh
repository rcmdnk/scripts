#!/usr/bin/env bash

# File
fgtasklist=~/.gtasklist

# get tasks
tmpfile=$(mktemp 2>/dev/null||mktemp -t tmp)
gtask -l 00_Inbox -i IMPORTANT |sed 's/IMPORTANT//g' > "$tmpfile"
ret=$?
if [ $ret -eq 0 ];then
  cp "$tmpfile" "$fgtasklist"
fi
rm -f "$tmpfile"
cat "$fgtasklist"
