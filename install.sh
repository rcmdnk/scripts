#!/usr/bin/env bash
exclude=('.' '..' 'LICENSE' 'README.md' 'install.sh' 'updateGIT.sh' \
  'linux_setup.sh')
sm_files=("submodules/evernote_mail/bin/evernote_mail"\
          "submodules/trash/bin/trash"\
          "submodules/stow_reset/bin/stow_reset"\
          "submodules/multi_clipboard/bin/multi_clipboard"\
          "submodules/escape_sequence/bin/colcheck"\
          "submodules/escape_sequence/bin/escseqcheck"\
          "submodules/gtask/bin/gtask"\
          "submodules/sentaku/bin/sentaku"\
          "submodules/sentaku/bin/ddv"\
          "submodules/kk/bin/kk"\
          "submodules/shell-explorer/bin/se"\
          "submodules/gcalcli/gcalcli"\
          "submodules/ParallelOperation/bin/po"\
          "submodules/gcp-tools/bin/gce_util"\
          "submodules/gcp-tools/bin/gce_ssh"\
          "submodules/gcp-tools/bin/gce_start"\
          "submodules/gcp-tools/bin/gce_stop"\
          "submodules/gcp-tools/bin/gce_delete"\
          "submodules/gcp-tools/bin/gce_list"\
          "submodules/gmail_filter_manager/bin/gfm_extract"\
          "submodules/gmail_filter_manager/bin/gfm_make"\
  )
if [[ "$OSTYPE" =~ cygwin ]] && ! type -a busybox >& /dev/null;then
  sm_files=("${sm_files[@]}" "external/apt-cyg/apt-cyg")
fi
sm_files_etc=("submodules/sd_cl/etc/sd_cl"\
              "submodules/shell-logger/etc/shell-logger.sh"\
  )

backup=""
overwrite=1
relative=0
dryrun=0
newlink=()
exist=()
curdir=$(pwd -P)
prefix=$HOME/usr

# help
HELP="Usage: $0 [-ndsh] [-b <backup file postfix>] [-e <exclude file>] [-i <install dir>]

Make links of scripts (default:in $prefix/bin, $prefix/etc)

Arguments:
      -b  Set backup postfix, like \"bak\" (default: \"\": no back up is made)
      -e  Set additional exclude file (default: ${exclude[*]})
      -p  Set install directory prefix (default: $prefix)
      -r  Use relative path (default: absolute path)
      -n  Don't overwrite if file is already exist
      -d  Dry run, don't install anything
      -s  Use 'pwd' instead of 'pwd -P' to make a symbolic link
      -h  Print Help (this message) and exit
"
while getopts b:e:p:rndsh OPT;do
  case $OPT in
    "b" ) backup=$OPTARG ;;
    "e" ) exclude=("${exclude[@]}" "$OPTARG") ;;
    "p" ) prefix="$OPTARG" ;;
    "r" ) relative=1 ;;
    "n" ) overwrite=0 ;;
    "d" ) dryrun=1 ;;
    "s" ) curdir=$(pwd) ;;
    "h" ) echo "$HELP" 1>&2; exit ;;
    * ) echo "$HELP" 1>&2; exit 1;;
  esac
done

if [[ "$OSTYPE" =~ cygwin ]];then
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
      link=$(basename "$target")
    else
      echo "usage: ln [-s] <target> [<link>]"
      echo "       -s for symbolic link, otherwise make hard link"
      return
    fi
    t_winpath=$(cygpath -w -a "$target")
    t_link=$(cygpath -w -a "$link")
    cmd /c mklink $opt "$t_link" "$t_winpath" > /dev/null
  }
# }}}
fi

# make a link ~/usr/share/git to /path/to/Git, for cronjob
if [ $relative -eq 1 ];then
  curdir=$(pwd)
fi
gitdirname=$(basename "$(dirname "$curdir")")
gitdir="$prefix/share/git"
if echo "$gitdirname"| grep -q -i git;then
  if ! echo "$curdir"|grep -q "$gitdir";then
    if [ ! -L "$gitdir" ] && [ ! -d "$gitdir" ];then
      mkdir -p "$(dirname "$gitdir")"
      ln -s "$(dirname "$curdir")" "$gitdir"
    fi
  fi
  if [ ! -f "$gitdir/updateGIT.sh" ];then
    ln -s "$curdir/updateGIT.sh" "$gitdir/updateGIT.sh"
    chmod 755 "$gitdir/updateGIT.sh"
  fi
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

echo "*************************************************"
echo "Install X(.sh) to $prefix/bin/X or $prefix/etc/X"
echo "*************************************************"
echo
if [ $dryrun -ne 1 ];then
  mkdir -p "$prefix/bin"
  mkdir -p "$prefix/etc"
else
  echo "*** This is dry run, not install anything ***"
fi
files=($(ls *.sh *.py *rb 2>/dev/null))
for sm_f in "${sm_files[@]}";do
  if [ -f "$sm_f" ];then
    files=("${files[@]}" "$sm_f")
  else
    echo "WARNING: $sm_f is not found"
  fi
done

for f in "${files[@]}";do
  for e in "${exclude[@]}";do
    flag=0
    if [ "$f" = "$e" ];then
      flag=1
      break
    fi
  done
  if [ $flag = 1 ];then
    continue
  fi
  name=$(basename "$f")
  name=${name%.sh}
  name=${name%.py}
  name=${name%.rb}

  install=1
  if [ $dryrun -eq 1 ];then
    install=0
  fi
  if [ "$(ls "$prefix/bin/$name" 2>/dev/null)" != "" ];then
    exist=(${exist[@]} "$name")
    if [ $dryrun -eq 1 ];then
      echo -n ""
    elif [ $overwrite -eq 0 ];then
      install=0
    elif [ "$backup" != "" ];then
      mv "$prefix/bin/$name" "$prefix/bin/${name}.$backup"
    else
      rm "$prefix/bin/$name"
    fi
  else
    newlink=(${newlink[@]} "$name")
  fi
  if [ $install -eq 1 ];then
    chmod 755 "$curdir/$f"
    ln -s "$curdir/$f" "$prefix/bin/$name"
  fi
done


# etc
files=()
for sm_f in "${sm_files_etc[@]}";do
  if [ -f "$sm_f" ];then
    files=("${files[@]}" "$sm_f")
  else
    echo "WARNING: $sm_f is not found"
  fi
done

for f in "${files[@]}";do
  for e in "${exclude[@]}";do
    flag=0
    if [ "$f" = "$e" ];then
      flag=1
      break
    fi
  done
  if [ $flag = 1 ];then
    continue
  fi
  name=$(basename "$f")
  name=${name%.sh}
  name=${name%.py}
  name=${name%.rb}

  install=1
  if [ $dryrun -eq 1 ];then
    install=0
  fi
  if [ "$(ls "$prefix/etc/$name" 2>/dev/null)" != "" ];then
    exist=(${exist[@]} "$name")
    if [ $dryrun -eq 1 ];then
      echo -n ""
    elif [ $overwrite -eq 0 ];then
      install=0
    elif [ "$backup" != "" ];then
      mv "$prefix/etc/$name" "$prefix/etc/${name}.$backup"
    else
      rm "$prefix/etc/$name"
    fi
  else
    newlink=(${newlink[@]} "$name")
  fi
  if [ $install -eq 1 ];then
    ln -s "$curdir/$f" "$prefix/etc/$name"
  fi
done
echo ""
echo ""
if [ $dryrun -eq 1 ];then
  echo "Following files don't exist:"
else
  echo "Following files were newly installed:"
fi
echo "  ${newlink[*]}"
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
echo "  ${exist[*]}"
echo

# check gcalcli
if ! type gcalcli >& /dev/null;then
  echo "If you need gcalcli (for gcalCal or gcalList), do:"
  echo "   $ cd external/gcalcli"
  echo "   $ pip install ."
fi
