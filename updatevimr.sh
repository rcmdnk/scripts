#!/usr/bin/env bash

plugins=(_libly.js multi_requester.js caret-hint.js)

if [ ! -d vimperator-plugins ];then
  git clone git@github.com:vimpr/vimperator-plugins
fi
cd vimperator-plugins/
git pull --rebase
cd ../
mkdir -p vimperator/plugin
cd vimperator/plugin
for p in "${plugins[@]}";do
  if [ ! -f $p ];then
    cp ../../vimperator-plugins/$p $p
  fi
done
