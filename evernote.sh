#!/bin/bash
# evernote.sh
# send note to ever note by email

# constant values
TAGMARK="#"
NOTEBOOKMARK="@"

# set default values
ATTACH=false
INPUTFILE=""
ADDRESS=xxxxxx@m.evernote.com
ADDRESSOTHER=xxx@xxxxxx
DEFTITLE="By email"
TITLE="$DEFTITLE"
TAG=""
NOTEBOOK=""

# check evernote setting
if [ -f ~/.evetnote ];then
  addresstmp=`grep ADDRESS ~/.evetnote|cut -d= -f2`
  addressothertmp=`grep ADDRESSOTHER ~/.evetnote|cut -d= -f2`
  if [ "$addresstmp" != "" ];then
    ADDRESS=$addresstmp
  fi
  if [ "$addressothertmp" != "" ];then
    ADDRESSOTHER=$addressothertmp
  fi
fi

# help
HELP="Usage: $0 [-uh] [-f <input file>] [-a <email address>] [-o <other mail address>] [-t <title>] [-T <tag>] [-n <notebook>] message...

Arguments:
      -u  If an input file is sent as attachment or not (default: ${ATTACH})
      -f  Set input file, in which the contents is sent (default: ${INPUTFILE})
      -a  Set email adress (default: ${ADDRESS})
      -o  Set other email adress for check (default: ${ADDRESSOTHER})
      -t  Set title (default: ${TITLE} or inputFile if available)
      -T  Set tag (default: ${TAG} ) + email (always added)
          To put multiple tags, use like -T \"#tag1 #tag2 #tag3\"
      -n  Set notebook (default: ${NOTEBOOK} )
 message  Be sent as a message
      -h  Print Help (this message) and exit
"

# check arguments
if [ $# -eq 0 ];then
  echo "$HELP" 1>&2
  exit
fi

OPTNUM=0
while getopts uf:a:t:T:n:h OPT;do
  OPTNUM=`expr $OPTNUM + 1`
  case $OPT in
    "u" ) ATTACH=true ;;
    "f" ) INPUTFILE="$OPTARG" ;;
    "a" ) ADDRESS="$OPTARG" ;;
    "t" ) TITLE="$OPTARG" ;;
    "T" ) TAG="$OPTARG" ;;
    "n" ) NOTEBOOK="$OPTARG" ;;
    "h" ) echo "$HELP" 1>&2; exit ;;
    * ) echo "$HELP" 1>&2; exit ;;
  esac
done
shift $(($OPTIND - 1))

# set title if necessary
message="$*"
if [ "$TITLE" = "$DEFTITLE" ] && [ "$INPUTFILE" != "" ];then
  TITLE=$INPUTFILE
fi

# tag check
tagCheck=`echo "$TAG"|cut -c1`
if [ "$TAG" != "" ] && [ "$tagCheck" != "$TAGMARK" ];then
  TAG="$TAGMARK""$TAG"
fi
TAG="$TAG #email"

# notebook check
notebookCheck=`echo "$NOTEBOOK"|cut -c1`
if [ "$NOTEBOOK" != "" ] && [ "$notebookCheck" != "$NOTEBOOKMARK" ];then
  NOTEBOOK="$NOTEBOOKMARK""$NOTEBOOK"
fi

# check input file and send message
if $ATTACH;then
  if [ "$INPUTFILE" != "" ];then
    (echo $message;uuencode $INPUTFILE `basename $INPUTFILE`)|mail -s "$TITLE $NOTEBOOK $TAG" $ADDRESS
  else
    (echo $message)|mail -s "$TITLE $NOTEBOOK $TAG" $ADDRESS
  fi
else
  if [ "$INPUTFILE" != "" ];then
    (echo $message;cat $INPUTFILE)|mail -s "$TITLE $NOTEBOOK $TAG" $ADDRESS
  else
    (echo $message)|mail -s "$TITLE $NOTEBOOK $TAG" $ADDRESS
  fi
fi

