#!/bin/bash
for h in `cat ~/.hostForScreen`;do
  echo "checking $h..."
  ping $h -c 2 -w2 >/dev/null 2>&1
  if [ $? -eq 0 ];then
    checklog="$(ssh -x $h "screen -ls")"
    echo $checklog
    if ! echo $checklog|grep -q "No Sockets found";then
      echo $h >> ~/.hostForScreen.tmp
    fi
  else
    echo $h seems not available
  fi
done
touch ~/.hostForScreen.tmp
mv ~/.hostForScreen.tmp ~/.hostForScreen
