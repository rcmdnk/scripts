#!/bin/sh
backup="bak"
exclude=('.' '..' 'README.md' 'install.sh')
instdir=$HOME/usr/bin
curdir=`pwd -P`
# help

HELP="Usage: $0 [-b <backup file postfix>] [-e <exclude file>] [-i <install dir>]

Arguments:
      -b  Set backup postfix (default: make *.bak file)
          Set \"\" if backups are not necessary
      -e  Set additional exclude file (default: ${exclude[@]})
      -i  Set install directory (default: $instdir)
      -h  Print Help (this message) and exit
"
while getopts b:e:i:h OPT;do
  OPTNUM=`expr $OPTNUM + 1`
  case $OPT in
    "b" ) backup=$OPTARG ;;
    "e" ) exclude=(${exclude[@]} $OPTARG) ;;
    "i" ) instdir=$OPTARG ;;
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
  if [ "`ls $instdir/$name 2>/dev/null`" != "" ];then
    if [ "$backup" != "" ];then
      echo "$name exists, make backup ${name}.$backup"
      mv $instdir/$name $HOME/${name}.$backup
    else
      echo "$name exists, replace it"
      rm $instdir/$name
    fi
  fi
  ln -s $curdir/$f $instdir/$name
done
