#!/usr/bin/env bash

ONLY_CHECK=0
DESTINATION=~/usr/local
STOWDIR="$DESTINATION/stow"
FORCE_GIT=1
FORCE_SCREEN=1
FORCE_VIM=1
FORCE_PYTHON=0
SHAREDIR=~/usr/share

if [ "$1" = "-c" ];then
  ONLY_CHECK=1
fi

unset TMPDOWNLOAD
trap '[[ $TMPDOWNLOAD ]] && rm -rf $TMPDOWNLOAD' 1 2 3 15
TMPDOWNLOAD=$(mktemp -d)

# helper function {{{
function mycd {
  cd "$1" || exit 2
}

function find_lib {
  if [ "$1" = "" ];then
    return 3
  fi
  for d in $(echo "$LD_LIBRARY_PATH"|tr : " ");do
    if [ -f "$d/$1".a ] || [ -f "$d/$1".so ];then
      return 0
    fi
  done
  return 1
}

function make_install {
    make "$2"
    make install
    mycd "$STOWDIR"
    stow "$1"
}

function configure_install {
  mycd "$1"
  ./configure --prefix="$STOWDIR/$1"
  make_install "$1"
}

function targz_configure_install {
  tar xzf "$v.tar.gz"
  configure_install "$v"
}

function get_from_gnuorg {
  v=automake-$(wget "http://ftp.gnu.org/gnu/$1/?C=M;O=A" -O -  2>/dev/null\
    |grep "${1}-"|grep tar.gz|grep -v tar.gz.sig|grep -v latest|tail -n1\
    |awk -v p="$1" '{split($0, tmp, p"-")}{split(tmp[2], tmp2, ".tar.gz")}
          {print tmp2[1]}')
  wget "http://ftp.gnu.org/gnu/$1/${v}.tar.gz" >&/dev/null
  echo "$v"
}

# }}}

# stow, package manager {{{
if ! type -a stow >& /dev/null;then
  echo "### Install stow ###"
  if [ $ONLY_CHECK -eq 0 ];then
    mycd "$TMPDOWNLOAD"
    v=$(get_from_gnuorg stow)
    tar xzf "$v.tar.gz"
    mycd "$v"
    ./configure --prefix="$STOWDIR/$v"
    make && make install
    mycd "$STOWDIR"
    "./$v/bin/stow" "$v"
  fi
fi
# }}}

# git related {{{
if [ "$FORCE_GIT" -eq 1 ] || ! type -a git >& /dev/null;then
  ## autoconf {{{
  if ! type -a autoconf >& /dev/null;then
    echo "### Install autoconf ###"
    if [ $ONLY_CHECK -eq 0 ];then
      mycd "$TMPDOWNLOAD"
      v=$(get_from_gnuorg autoconf)
      targz_configure_install "$v"
    fi
  fi
  ## }}}

  ## libcurl, for https protocol of git
  if ! find_lib libcurl >&/dev/null;then
    echo "### Install curl ###"
    if [ $ONLY_CHECK -eq 0 ];then
      mycd "$TMPDOWNLOAD"
      v=curl-$(wget http://curl.haxx.se/download.html -O - 2>/dev/null\
        |grep download|grep tar.gz|grep "curl-"|head -n1\
        |awk '{split($0, tmp, "curl-")}{split(tmp[2], tmp2, ".tar.gz")}
              {print tmp2[1]}')
      wget "http://curl.haxx.se/download/${v}.tar.gz"
      targz_configure_install "$v"
    fi
  fi

  ## libexpat, for https protocol of git push
  if ! find_lib libexpat >&/dev/null;then
    echo "### Install expat ###"
    if [ $ONLY_CHECK -eq 0 ];then
      mycd "$TMPDOWNLOAD"
      v=expat-$(wget http://sourceforge.net/projects/expat/files/ -O - \
        2>/dev/null|grep title|grep tar.gz|grep "expat-"|head -n1\
        |awk '{split($0, tmp, "expat-")}{split(tmp[2], tmp2, ".tar.gz")}
              {print tmp2[1]}')
      wget "http://sourceforge.net/projects/expat/files/${v}.tar.gz"
      targz_configure_install "$v"
    fi
  fi
  ## }}}

  ## gettext, to install msgfmt
  if ! type -a msgfmt >& /dev/null;then
    echo "### Install gettext ###"
    if [ $ONLY_CHECK -eq 0 ];then
      mycd "$TMPDOWNLOAD"
      v=$(get_from_gnuorg gettext)
      targz_configure_install "$v"
    fi
  fi

  ## git {{{
  echo "### Install git ###"
  if [ $ONLY_CHECK -eq 0 ];then
    mycd "$TMPDOWNLOAD"
    wget -O master.tar.gz https://github.com/git/git/archive/master.tar.gz
    tar xzf master.tar.gz
    mycd git-master
    make configure
    v=git-$(grep 'PACKAGE_VERSION=' configure|cut -d"'" -f2|sed s/.GIT//)
    ./configure CFLAGS="-I$DESTINATION/include" LDFLAGS="-L$DESTINATION/lib" \
      --prefix="$STOWDIR/$v"
    make_install "$v" all
  fi
  ## }}}
fi
# }}}

# screen related {{{
if [ "$FORCE_SCREEN" -eq 1 ] || ! type -a screen >& /dev/null;then
  ## automake {{{
  if ! type -a autmake >& /dev/null;then
    echo "### Install automake ###"
    if [ $ONLY_CHECK -eq 0 ];then
      if ! type -a automake >& /dev/null;then
        mycd "$TMPDOWNLOAD"
        v=$(get_from_gnuorg automake)
        targz_configure_install "$v"
      fi
    fi
  fi
  ## }}}

  ## libncurses {{{
  if ! find_lib libncurses >&/dev/null;then
    echo "### Install ncurses ###"
    if [ $ONLY_CHECK -eq 0 ];then
      mycd "$TMPDOWNLOAD"
      v=$(get_from_gnuorg ncurses)
      targz_configure_install "$v"
    fi
  fi
  ## }}}

  echo "### Install screen ###"
  if [ $ONLY_CHECK -eq 0 ];then
    mycd "$TMPDOWNLOAD"
    git clone git://git.sv.gnu.org/screen.git
    mycd screen
    wget https://gist.github.com/raw/626040/be6a04f0e64c56185ba5850415ac59dad4cd62a0/screen-utf8-nfd.patch
    #wget http://zuse.jp/misc/screen-utf8-osc.diff
    wget https://gist.githubusercontent.com/rcmdnk/143cb56d31335dbccf70/raw/4b3e175946f2366b4076088c1c8f2bbe65b32e16/screen-utf8-osc.diff
    patch -p1 < screen-utf8-nfd.patch
    patch -p1 < screen-utf8-osc.diff
    mycd src
    v=screeen-$(grep Version ChangeLog |head -n1|cut -d' ' -f2)
    ./autogen.sh
    CFLAGS="-L$DESTINATION/lib" LDFLAGS="-L$DESTINATION/lib" ./configure \
      --prefix="$STOWDIR/$v"  --enable-colors256
    make_install "$v"
  fi
fi
# }}}

# vim related {{{
if [ "$FORCE_VIM" -eq 1 ] || ! type -a vim >& /dev/null;then
  ## libbz2, for Python to install Mercurial {{{
  if ! find_lib libbz2 >&/dev/null;then
    echo "### Install bzip2 ###"
    if [ $ONLY_CHECK -eq 0 ];then
      mycd "$TMPDOWNLOAD"
      n=$(wget "http://www.bzip.org/downloads.html" -O - \
        2>/dev/null|grep bzip2|grep tar.gz|head -n1\
        |awk '{split($0, tmp, "bzip2-")}{split(tmp[2], tmp2, ".tar.gz")}
              {print tmp2[1]}')
      v=bzip2-$n
      wget "http://www.bzip.org/$n/${v}.tar.gz"
      tar xzf "${v}.tar.gz"
      mycd "$v"
      make -f Makefile-libbz2_so
      make install PREFIX="$STOWDIR/$v"
      mycd "$STOWDIR"
      stow "$v"
    fi
  fi
  ## }}}

  ## readline {{{
  if ! find_lib libreadline >&/dev/null;then
    echo "### Install readline ###"
    if [ $ONLY_CHECK -eq 0 ];then
      mycd "$TMPDOWNLOAD"
      v=readline-$(wget ftp://ftp.cwru.edu/pub/bash/ -O - \
        2>/dev/null|grep readline|grep tar.gz|grep -v doc|grep -v beta\
        |grep -v alpha|grep -v tar.gz.sig|tail -n1\
        |awk '{split($0, tmp, "readline-")}{split(tmp[2], tmp2, ".tar.gz")}
              {print tmp2[1]}')
      wget "ftp://ftp.cwru.edu/pub/bash/${v}.tar.gz"
      targz_configure_install "$v"
    fi
  fi
  ## }}}

  ## python, the latest v2 {{{
  if [ "$FORCE_PYTHON" -eq 1 ] || ! type -a python >& /dev/null;then
    echo "### Install python ###"
    if [ $ONLY_CHECK -eq 0 ];then
      mycd "$TMPDOWNLOAD"
      versions=$(wget https://www.python.org/ftp/python/ -O - \
        2>/dev/null|grep ">2\."|cut -d">" -f2|cut -d"/" -f1)
      n2=$(echo "$versions"|cut -d"." -f1,2)
      n=$n2.$(echo "$versions"|grep "^$n2"|cut -d"." -f3|sort -n|tail -n1)
      v=Python-$n
      wget --no-check-certificate "http://www.python.org/ftp/python/$n/${v}.tgz"
      tar xzf "${v}.tgz"
      mycd "$v"
      LDFLAGS="-L$DESTINATION/lib" CPPFLAGS="-I$DESTINATION/include" \
        ./configure --prefix="$STOWDIR/$v"
      make_install "$v"
    fi
  fi
  ## }}}

  ## libtermcap for Lua {{{
  if ! find_lib libtermcap >&/dev/null;then
    echo "### Install termcap ###"
    if [ $ONLY_CHECK -eq 0 ];then
      mycd "$TMPDOWNLOAD"
      v=$(get_from_gnuorg termcap)
      targz_configure_install "$v"
    fi
  fi
  ## }}}

  ## Lua {{{
  if ! find_lib liblua >&/dev/null;then
    echo "### Install Lua ###"
    if [ $ONLY_CHECK -eq 0 ];then
      mycd "$TMPDOWNLOAD"
      v=$(wget http://www.lua.org/ftp/ -O - 2>/dev/null|grep tar.gz|grep -v all\
        |head -n1|cut -d'"' -f4|sed 's/.tar.gz//')
      wget "http://www.lua.org/ftp/${v}.tar.gz"
      tar xzf "${v}.tar.gz"
      mycd "$v"
      make linux  MYLIBS=" -ltermcap" MYLDFLAGS=" -L$DESTINATION/lib" \
        MYCFLAGS=" -I$DESTINATION/include"
      make install INSTALL_TOP="$STOWDIR/$v"
      mycd "$STOWDIR"
      stow "$v"
    fi
  fi
  ## }}}

  ## vim {{{
  echo "### Install vim ###"
  if [ $ONLY_CHECK -eq 0 ];then
    mycd "$TMPDOWNLOAD"
    git clone https://github.com/vim/vim
    mycd vim
    v=vim-$(tail -n1 .hgtags|cut -d' ' -f2)
    ./configure LDFLAGS="-L$DESTINATION/lib/" --prefix="$STOWDIR/$v" \
      --with-lua-prefix="$DESTINATION" --with-local-dir="$DESTINATION" \
      --enable-luainterp=yes --enable-perlinterp=yes --enable-pythoninterp=yes \
      --enable-python3interp=yes --enable-rubyinterp=yes --enable-cscope \
      --enable-multibyte --enable-gui=no
    make && make install
  fi
  ## }}}
fi
# }}}

# My files {{{
for r in dotfiles scripts;do
  if [ ! -d "$SHAREDIR/git/$r" ];then
    echo "### Install rcmdnk/$r ###"
    if [ $ONLY_CHECK -eq 0 ];then
      mkdir -p "$SHAREDIR/git"
      mycd "$SHAREDIR/git"
      git clone git@github.com:rcmdnk/$r
      mycd $r
      ./install.sh
    fi
  fi
done
#}}}
