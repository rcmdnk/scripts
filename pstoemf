#!/usr/bin/env bash
if [ $# -eq 1 ];then
  epsfile=${1%.eps}
  emffile=$epsfile
elif [ $# -eq 2 ];then
  epsfile=${1%.eps}
  emffile=${1%.emf}
else
  echo "usage: pstoemf epsfile [emffile]"
  exit
fi
pstoedit -f emf "$epsfile.eps" "$emffile.emf"
