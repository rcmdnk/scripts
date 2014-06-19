#!/usr/bin/env bash
. ~/.bashrc
cd $(dirname $0)

for dir in dotfiles scripts;do
  if [ -d $dir ];then
    cd $dir
    cd submodules
    git submodule foreach git update
    git update
    ./install -b ""
    cd ../
  fi
done
