#!/usr/bin/env bash

# Delete trailing white space
if sed --version 2>/dev/null |grep -q GNU;then
  sed -i"" 's/ *$//g' "$1"
else
  sed -i "" 's/ *$//g' "$1"
fi
