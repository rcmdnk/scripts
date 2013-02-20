CLCHECK=$HOME/usr/bin/clcheck
if [ "$LASTDIRFILE" = "" ];then
  LASTDIRFILE=$HOME/.lastDir
fi
CLCHECKNUM=`$CLCHECK $@`
touch $LASTDIRFILE
case $CLCHECKNUM in
  -1)
    echo "Usage: cl [-l] [-n <number> ]"
    echo "If there are no arguments, you move to the last saved dirctory"
    echo ""
    echo "Arguments:"
    echo "   -l              Show saved directories"
    echo "   -c              Show saved directories and choose a directory"
    echo "   -n              Move to <number>-th last directory"
    echo "   -h              Print Help (this message) and exit"
    ;;
  -2|-3)
    LINENUM=`wc $LASTDIRFILE|awk '{print $1}'`
    while read dir;do
      printf "%4d %s %4d\n" $LINENUM $dir $LINENUM
      LINENUM=`expr $LINENUM - 1`
    done < $LASTDIRFILE
    if [ $CLCHECKNUM -eq -3 ];then
      echo "choose directory number"
      read NDIR
      LASTDIR=`tail -n${NDIR} $LASTDIRFILE|head -n1`
      cd $LASTDIR
    fi
    ;;
  *)
    LASTDIR=`tail -n${CLCHECKNUM} $LASTDIRFILE|head -n1`
    cd $LASTDIR
    ;;
esac
