#!/usr/bin/env bash

source ~/.bashrc

debug=0
if [ "$1" = "-d" ];then
  debug=1
fi

cd "$(dirname "$0")" || exit 1

function execute_check () {
  if [ "$debug" -eq 1 ];then
    echo
    echo "#################################################################"
    echo "# $(pwd)"
    echo "# $ $*"
    echo "#################################################################"
    echo
    "$@"
  elif ! output=$("$@" 2>&1);then
    echo "Error at the directory: $(pwd)"
    echo "---"
    echo "\$ $*"
    echo "$output"
  fi
}

for dir in dotfiles scripts;do
  if [ -d $dir ];then
    cd $dir || exit 1
    if [ -d external ];then
      for d in external/*;do
        cd "$d" || exit 1
        execute_check git pull
        cd - || exit 1
      done
    fi
    if [ -d submodules ];then
      for d in submodules/*;do
        cd "$d" || exit 1
        execute_check git update
        cd - || exit 1
      done
    fi
    execute_check git update
    execute_check ./install.sh -b ""
    cd ../ || exit 1
  fi
done

# update vim plugins by dein
execute_check vim  -c "silent call dein#update()" -c "quit"
