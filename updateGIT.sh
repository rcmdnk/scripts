#!/usr/bin/env bash
. ~/.bashrc
cd $(dirname $0)

for dir in dotfiles scripts;do
  if [ -d $dir ];then
    cd $dir
    git submodule -q foreach --recursive git update
    git update
    ./install.sh -b "" >& /dev/null
    cd ../
  fi
done
