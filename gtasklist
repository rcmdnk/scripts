#!/usr/bin/env bash

. ~/.bashrc

# File
fgtasklist=~/.gtasklist

# get tasks
tmpfile=$(mktemp)
gtask -l 00_Inbox > "$tmpfile"
ret=$?
if [ $ret -eq 0 ];then
  cp "$tmpfile" "$fgtasklist"
fi
rm -f "$tmpfile"
cat "$fgtasklist"
