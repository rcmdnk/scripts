#!/bin/bash
exclude=('.' '..' 'LICENSE' 'README.md' 'install.sh')
sm_files=("submodules/evernote_mail/bin/evernote_mail"\
          "submodules/trash/bin/trash"\
          "submodules/stowReset/bin/stowReset"\
          "submodules/multi_clipboard/bin/multi_clipboard"\
          "submodules/escape_sequence/bin/colcheck"\
          "submodules/escape_sequence/bin/escseqcheck"\
          "submodules/gtask/bin/gtask"\
          "submodules/apt-cyg/apt-cyg"\
  )
instdir="$HOME/usr/bin"

backup="bak"
overwrite=1
dryrun=0
newlink=()
exist=()
curdir=`pwd -P`
# help
HELP="Usage: $0 [-nd] [-b <backup file postfix>] [-e <exclude file>] [-i <install dir>]

Make links of scripts (default:in $instdir)

Arguments:
      -b  Set backup postfix (default: make *.bak file)
          Set \"\" if backups are not necessary
      -e  Set additional exclude file (default: ${exclude[@]})
      -i  Set install directory (default: $instdir)
      -n  Don't overwrite if file is already exist
      -d  Dry run, don't install anything
      -h  Print Help (this message) and exit
"
while getopts b:e:i:ndh OPT;do
  case $OPT in
    "b" ) backup=$OPTARG ;;
    "e" ) exclude=(${exclude[@]} "$OPTARG") ;;
    "i" ) instdir="$OPTARG" ;;
    "n" ) overwrite=0 ;;
    "d" ) dryrun=1 ;;
    "h" ) echo "$HELP" 1>&2; exit ;;
    * ) echo "$HELP" 1>&2; exit ;;
  esac
done

if [[ "$OSTYPE" =~ "cygwin" ]];then
  # ln wrapper{{{
  function ln {
    opt="/H"
    if [ "$1" = "-s" ];then
      opt=""
      shift
    fi
    target="$1"
    if [ -d "$target" ];then
      opt="/D $opt"
    fi
    if [ $# -eq 2 ];then
      link="$2"
    elif [ $# -eq 1 ];then
      link=`basename "$target"`
    else
      echo "usage: ln [-s] <target> [<link>]"
      echo "       -s for symbolic link, otherwise make hard link"
      return
    fi
    t_winpath=$(cygpath -w -a "$target")
    t_link=$(cygpath -w -a "$link")
    echo "cmd /c mklink $opt $t_link $t_winpath"
    cmd /c mklink $opt "$t_link" "$t_winpath"
  }
# }}}
fi

echo "**********************************************"
echo "Update submodules"
echo "**********************************************"
echo
if which git >&/dev/null;then
  git submodule update --init
else
  echo "git is not installed, please install git or get following submodules directly:"
  grep url .gitmodules
fi
echo

echo "**********************************************"
echo "Install X.sh to $instdir/X"
echo "**********************************************"
echo
if [ $dryrun -ne 1 ];then
  mkdir -p $instdir
else
  echo "*** This is dry run, not install anything ***"
fi
files=(`ls *.sh *.py *rb 2>/dev/null`)
for sm_f in "${sm_files[@]}";do
  if [ -f "$sm_f" ];then
    files=("${files[@]}" "$sm_f")
  fi
done

for f in "${files[@]}";do
  for e in ${exclude[@]};do
    flag=0
    if [ "$f" = "$e" ];then
      flag=1
      break
    fi
  done
  if [ $flag = 1 ];then
    continue
  fi
  name=$(basename $f)
  name=${name%.sh}
  name=${name%.py}
  name=${name%.rb}

  install=1
  if [ $dryrun -eq 1 ];then
    install=0
  fi
  if [ "`ls "$instdir/$name" 2>/dev/null`" != "" ];then
    exist=(${exist[@]} "$name")
    if [ $dryrun -eq 1 ];then
      echo -n ""
    elif [ $overwrite -eq 0 ];then
      install=0
    elif [ "$backup" != "" ];then
      mv "$instdir/$name" "$instdir/${name}.$backup"
    else
      rm "$instdir/$name"
    fi
  else
    newlink=(${newlink[@]} "$name")
  fi
  if [ $install -eq 1 ];then
    chmod 755 "$curdir/$f"
    ln -s "$curdir/$f" "$instdir/$name"
  fi
done
echo ""
if [ $dryrun -eq 1 ];then
  echo "Following files don't exist:"
else
  echo "Following files were newly installed:"
fi
echo "  ${newlink[@]}"
echo
echo -n "Following files existed"
if [ $dryrun -eq 1 ];then
  echo "Following files exist:"
elif [ $overwrite -eq 0 ];then
  echo "Following files exist, remained as is:"
elif [ "$backup" != "" ];then
  echo "Following files existed, backups (*.$backup) were made:"
else
  echo "Following files existed, replaced old one:"
fi
echo "  ${exist[@]}"
echo

# check gcalcli
if ! type gcalcli >& /dev/null;then
  echo "If you need gcalcli (for gcalCal or gcalList), do:"
  echo "   $ cd external/gcalcli"
  echo "   $ pip install ."
fi
