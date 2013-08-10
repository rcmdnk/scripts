#!/bin/sh

# Variables
package=""
stowdir="."
targetdir=".."
simulation=0
curdir=`pwd`

# Help
HELP="Usage: $0 [-nh] [-d <stow dir>] [-t <target dir>] package

Arguments:
      -d <stow dir>    Set stow dir to DIR (default is current dir)
      -t <target dir>  Set target to DIR (default is parent of stow dir)
      -n               Do not actually make any filesystem changes
      -h               Print Help (this message) and exit
"
# Get Options
OPTNUM=0
while getopts d:t:nh OPT;do
  OPTNUM=`expr $OPTNUM + 1`
  case $OPT in
    "d" ) stowdir="$OPTARG" ;;
    "t" ) targetdir="$OPTARG" ;;
    "n" ) simulation=1 ;;
    "h" ) echo "$HELP" >&2 ; exit ;;
    * ) echo "$HELP" >&2 ; exit ;;
  esac
done
shift $(($OPTIND - 1))

# Get package name
package=${1%/}
if [ "$package" = "" ];then
  echo "$HELP" >&2
  exit
fi
flist="${curdir}"/.${package}.list
echo "########################"
echo "# Check $package"
echo "########################"
echo

# Check first directories
fdirs=`ls "$stowdir"/"$package"/`

if type tac >/dev/null 2>&1;then
  revlines="tac"
elif ! tail --version 2>/dev/null |grep -q GNU;then
  revlines="tail -r"
else
  echo Neither tac nor BSD tail was found.
  echo You may need to run $0 again to remove directories.
  revlines="cat"
fi

# Make file/directory list
rm -f "$flist"
cd "$stowdir"/"$package"
for d in ${fdirs[@]};do
  find "$d" >> "$flist"
done
cd "$curdir"

# Show files/directories
if [ $simulation -eq 1 ];then
  echo "############################################"
  echo "# Following files/directories were found."
  echo "############################################"
  echo
  cat "$flist"
  rm -f "$flist"
  exit
fi

# Remove files/directories
while read f;do
  if [ -f "$targetdir"/"$f" ];then
    echo rm -f "$targetdir"/"$f"
    rm -f "$targetdir"/"$f"
  elif [ -d "$f" ];then
    if [ "$(ls "$targetdir"/"$f")" = "" ];then
      echo rm -rf "$targetdir"/"$f"
      rm -rf "$targetdir"/"$f"
    fi
  else
    echo "$targetdir"/"$f" doesn\'t exist
  fi
done <"$flist"
rm -f "$flist"
