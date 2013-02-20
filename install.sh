#!/bin/sh
backup="bak"
exclude=('.' '..' 'README.md' 'install.sh')
overwrite=1
notinstalled=()
instdir=$HOME/usr/bin
curdir=`pwd -P`
# help
HELP="Usage: $0 [-n] [-b <backup file postfix>] [-e <exclude file>] [-i <install dir>]

Arguments:
      -b  Set backup postfix (default: make *.bak file)
          Set \"\" if backups are not necessary
      -e  Set additional exclude file (default: ${exclude[@]})
      -i  Set install directory (default: $instdir)
      -n  Don't overwrite if file is already exist
      -h  Print Help (this message) and exit
"
while getopts b:e:i:nh OPT;do
  OPTNUM=`expr $OPTNUM + 1`
  case $OPT in
    "b" ) backup=$OPTARG ;;
    "e" ) exclude=(${exclude[@]} $OPTARG) ;;
    "i" ) instdir=$OPTARG ;;
    "n" ) overwrite=0 ;;
    "h" ) echo "$HELP" 1>&2; exit ;;
    * ) echo "$HELP" 1>&2; exit ;;
  esac
done

mkdir -p $instdir
for f in *.sh;do
  for e in ${exclude[*]};do
    flag=0
    if [ "$f" = "$e" ];then
      flag=1
      break
    fi
  done
  if [ $flag = 1 ];then
    continue
  fi
  name=${f%.sh}
  echo "install $f to $instdir, as $name"
  install=1
  if [ "`ls $instdir/$name 2>/dev/null`" != "" ];then
    if [ $overwrite -eq 0 ];then
      echo "$f exists, don't install"
      notinstalled=(${notinstalled[@]} $f)
      install=0
    elif [ "$backup" != "" ];then
      echo "$name exists, make backup ${name}.$backup"
      mv $instdir/$name $instdir/${name}.$backup
    else
      echo "$name exists, replace it"
      rm $instdir/$name
    fi
  fi
  if [ $install -eq 1 ];then
    ln -s $curdir/$f $instdir/$name
  fi
done
if [ $overwrite -eq 0 ];then
  if [ ${#notinstalled[@]} != 0 ];then
    echo "following files were not installed: ${notinstalled[@]}"
  fi
fi
