#!/usr/bin/env bash

# Get full path

if [[ $# -eq 0 ]];then
    echo "usage: path file/directory"
    return 1
fi
fullpath="$(cd "$(dirname "$1")";pwd)/$(basename "$1")"
echo $fullpath

[[ "$TERM" =~ screen ]] && [[ -n "$STY" ]] && type multi_clipboard >&/dev/null && multi_clipboard -s "$fullpath"
