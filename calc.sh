#!/bin/bash

HELP="  usage: calc num1 (add, sub, mul or div) num2
  or   : calc num1 rem num2 (num1%num2)
  or   : calc num1 sqrt (root num1)
  or   : calc num1 sqr (num1*num1)
  or   : calc num1 comp num2 (retun->num1>num2:1,num1=num2:0,num1<num2:-1)
  or   : calc num1 to num2 (num1^num2)
  or   : calc num1 (+, -, \* or /) num2
  notice: you must use \"*\" or \* instead of asterisk  only
"
if [ "$#" -lt 2 ];then
  echo "$HELP"
  exit
fi

case $2 in
  "add")
     echo -n '$xx = '$1' + '$3';print "$xx \n"'|perl
  ;;
  "+")
     echo -n '$xx = '$1' + '$3';print "$xx \n"'|perl
  ;;
  "sub")
     echo -n '$xx = '$1' - '$3';print "$xx \n"'|perl
  ;;
  "-")
     echo -n '$xx = '$1' - '$3';print "$xx \n"'|perl
  ;;
  "mul")
     echo -n '$xx = '$1' * '$3';print "$xx \n"'|perl
  ;;
  "*")
     echo -n '$xx = '$1' * '$3';print "$xx \n"'|perl
  ;;
  "div")
     echo -n '$xx = '$1' / '$3';print "$xx \n"'|perl
  ;;
  "/")
     echo -n '$xx = '$1' / '$3';print "$xx \n"'|perl
  ;;
  "sqrt")
     flag=`echo '$xx = '$1' <=> 0;print "$xx \n"'|perl`
     if [ $flag -eq -1 ];then
       echo -n 0
     else
       echo -n '$xx = sqrt '$1';print "$xx \n"'|perl
     fi
  ;;
  "sqr")
     echo -n '$xx = '$1' ** '2';print "$xx \n"'|perl
  ;;
  "comp")
     echo -n '$xx = '$1' <=> '$3';print "$xx \n"'|perl
  ;;
  "to")
     echo -n '$xx = '$1' ** '$3';print "$xx \n"'|perl
  ;;
  "rem")
     echo -n '$xx = '$1' % '$3';print "$xx \n"'|perl
  ;;
  *)
     echo "$HELP"
  ;;
esac
