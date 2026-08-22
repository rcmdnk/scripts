#!/usr/bin/env bash
exclude=()
sm_files=( \
  "submodules/ec2/bin/ec2" \
  "submodules/ec2/etc/bash_completion.d/ec2" \
  "submodules/ec2/share/zsh/site-functions/_ec2" \
  "submodules/escape_sequence/bin/256colors" \
  "submodules/escape_sequence/bin/colcheck" \
  "submodules/escape_sequence/bin/escseqcheck" \
  "submodules/git-gpt-commit/bin/git-gpt-commit" \
  "submodules/homebrew-file/bin/brew-file" \
  "submodules/homebrew-file/etc/bash_completion.d/brew-file" \
  "submodules/homebrew-file/etc/brew-wrap" \
  "submodules/homebrew-file/etc/brew-wrap.fish" \
  "submodules/homebrew-file/share/zsh/site-functions/_brew-file" \
  "submodules/kk/bin/kk" \
  "submodules/multi_clipboard/bin/multi_clipboard" \
  "submodules/sd_cl/etc/sd_cl" \
  "submodules/sentaku/bin/ddv" \
  "submodules/sentaku/bin/sentaku" \
  "submodules/shell-explorer/bin/se" \
  "submodules/shell-logger/etc/shell-logger" \
  "submodules/trash/bin/trash" \
)
sm_files_bin=( \
)
sm_files_etc=( \
)
sm_files_share=(
)
if [[ "$OSTYPE" =~ cygwin ]] && ! type -a busybox >& /dev/null;then
  sm_files_bin=("${sm_files[@]}" "external/apt-cyg/apt-cyg")
fi


backup=""
overwrite=1
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
      -n  Don't overwrite if file is already exist
      -d  Dry run, don't install anything
      -s  Use 'pwd' instead of 'pwd -P' to make a symbolic link
      -h  Print Help (this message) and exit
"
while getopts b:e:p:ndsh OPT;do
  case $OPT in
    "b" ) backup=$OPTARG ;;
    "e" ) exclude=("${exclude[@]}" "$OPTARG") ;;
    "p" ) prefix="$OPTARG" ;;
    "n" ) overwrite=0 ;;
    "d" ) dryrun=1 ;;
    "s" ) curdir=$(pwd) ;;
    "h" ) echo "$HELP" 1>&2; exit;;
    * ) echo "$HELP" 1>&2; exit 1;;
  esac
done

#echo "**********************************************"
#echo "Update submodules"
#echo "**********************************************"
#echo
#if which git >&/dev/null;then
#  git submodule update --init
#else
#  echo "git is not installed, please install git or get following submodules directly:"
#  grep url .gitmodules
#fi
#echo

make_link () {
  if [ $# -lt 2 ];then
    echo "ERROR: Use make_link <orig> <dest>"
  fi
  local orig=$1
  local dest=$2
  local name=$(basename "$orig")
  if echo " ${exclude[*]} "|grep -q " $name ";then
    return
  fi
  local install=1
  if [ $dryrun -eq 1 ];then
    install=0
  fi
  if [ -e "$dest" ] || [ -L "$dest" ];then
    exist=("${exist[@]}" "$name")
    if [ $dryrun -eq 1 ];then
      echo -n ""
    elif [ $overwrite -eq 0 ];then
      install=0
    elif [ "$backup" != "" ];then
      mv "$dest" "${dest}.$backup"
    else
      rm "$dest"
    fi
  else
    newlink=("${newlink[@]}" "$name")
  fi
  if [ $install -eq 1 ];then
    mkdir -p "$(dirname "$dest")"
    ln -s "$orig" "$dest"
  fi
}

echo "*************************************************"
echo "Install X(.sh) to $prefix/bin/X, $prefix/etc/X or $prefix/share/X"
echo "*************************************************"
echo
if [ $dryrun -eq 1 ];then
  echo "*** This is dry run, not install anything ***"
fi
for d in bin etc;do
  cd "$curdir" || exit
  for f in $(find "$d"/* 2>/dev/null);do
    if [ ! -f "$f" ];then
      continue
    fi
    orig="$curdir/$f"
    dest="$prefix/$f"
    make_link "$orig" "$dest"
  done
done

for sm_f in "${sm_files[@]}";do
  if [ -e "$sm_f" ];then
    f="$(echo "$sm_f"|cut -d "/" -f3-)"
    make_link "$curdir/$sm_f" "$prefix/$f"
  else
    echo "WARNING: $sm_f is not found"
  fi
done

for sm_f in "${sm_files_bin[@]}";do
  if [ -e "$sm_f" ];then
    make_link "$curdir/$sm_f" "$prefix/bin/$(basename "$sm_f")"
  else
    echo "WARNING: $sm_f is not found"
  fi
done

for sm_f in "${sm_files_etc[@]}";do
  if [ -e "$sm_f" ];then
    make_link "$curdir/$sm_f" "$prefix/etc/$(basename "$sm_f")"
  else
    echo "WARNING: $sm_f is not found"
  fi
done

for sm_f in "${sm_files_share[@]}";do
  if [ -e "$sm_f" ];then
    make_link "$curdir/$sm_f" "$prefix/share/$(basename "$sm_f")"
  else
    echo "WARNING: $sm_f is not found"
  fi
done

# Check dead link
deadlink=()
for f in "$prefix/bin/"* "$prefix/etc/"*;do
  if  [ ! -L "$f" ];then
    continue
  fi
  if [ ! -e "$f" ];then
    if [ $dryrun -ne 1 ];then
      rm -f "$f"
    fi
    deadlink=("${deadlink[@]}" "$(basename "$f")")
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
if [ "${#deadlink[@]}" -gt 0 ];then
  echo "Followings are dead link"
  if [ $dryrun -eq 1 ];then
    echo ":"
  else
    echo ", removed:"
  fi
  echo "  ${deadlink[*]}"
fi
echo
