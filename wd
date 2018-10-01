#!/usr/bin/env bash

# pwd wrapper
dir=$(command pwd "$@")
ret=$?
echo "$dir"
if [[ $ret -eq 0 ]];then
  type multi_clipboard >&/dev/null &&  multi_clipboard -s "$dir"
fi
exit $ret
