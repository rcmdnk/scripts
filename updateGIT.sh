#!/usr/bin/env bash
. ~/.bashrc
cd "$(dirname "$0")"

for dir in dotfiles scripts;do
  if [ -d $dir ];then
    cd $dir
    #git submodule -q foreach --recursive git update
    for d in external/*;do
      cd $d
      git pull
    done
    for d in submodules/*;do
      cd $d
      git update
    done
    git update
    ./install.sh -b "" >& /dev/null
    cd ../
  fi
done

# update vim plugins by NeoBundle
vim  -c "silent NeoBundleUpdate" -c "quit"  >&/dev/null
