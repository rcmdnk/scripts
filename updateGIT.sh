#!/usr/bin/env bash
. ~/.bashrc
cd "$(dirname "$0")"

function execute_check () {
  output=$($* 2>&1)
  if [ $? != 0 ];then
    echo "Error at the directory: $pwd"
    echo "---"
    echo "\$ $*"
    echo "$output"
  fi
}

for dir in dotfiles scripts;do
  if [ -d $dir ];then
    cd $dir
    #git submodule -q foreach --recursive git update
    if [ -d external ];then
      for d in external/*;do
        cd $d
        execute_check git pull
        cd -
      done
    fi
    if [ -d submodules ];then
      for d in submodules/*;do
        cd $d
        execute_check git update
        cd -
      done
    fi
    execute_check git update
    execute_check ./install.sh -b
    cd ../
  fi
done

# update vim plugins by NeoBundle
execute_check vim  -c "silent call dein#update()" -c "quit"
