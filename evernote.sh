#!/bin/bash
# evernote.sh
# Send note to Evernote by email

# Constant values
TAGMARK="#"
NOTEBOOKMARK="@"

# Default values
def_attach=false
def_inputfile=""
def_address=""
def_addressother=""
def_title="By email"
def_tag=""
def_notebook=""

# set default values
attach=$def_attach
inputfile=$def_inputfile
address=$def_address
addressother=$def_addressother
title=$def_title
tag=$def_tag
notebook=$def_notebook

# check evernote setting
if [ -f ~/.evernote ];then
  addresstmp=`grep ADDRESS ~/.evernote|cut -d= -f2`
  addressothertmp=`grep ADDRESSOTHER ~/.evernote|cut -d= -f2`
  if [ "$addresstmp" != "" ];then
    address=$addresstmp
  fi
  if [ "$addressothertmp" != "" ];then
    addressother=$addressothertmp
  fi
fi

# help
HELP="Usage: $0 [-uh] [-f <input file>] [-a <email address>]
                [-o <other mail address>] [-t <title>] [-T <tag>]
                [-n <notebook>] message...

Arguments:
      -u  Send an input file as attachment
          (default: file's content is sent as an inline text)
      -f  Set an input file, in which the contents is sent
          (default: ${def_inputfile})
      -a  Set an email adress (default: ${def_address})
      -o  Set other email adress for check (default: ${def_addressother})
      -t  Set a title (default: ${def_title} or inputFile if available)
      -T  Set a tag (default: ${def_tag} ) + email (always added)
          To put multiple tags, use like -T \"#tag1 #tag2 #tag3\"
      -n  Set a notebook (default: ${def_notebook} )
      -h  Print Help (this message) and exit

 message  Be sent as a message

Setting file:
      ~/.evernote
          ADDRESS=xxxx@m.evernote.com
          ADDRESSOTHER=xxxx@YYY.ZZZ

ADRESS for evernote is mandatory.
Please specify it in .evernote or use -a.

Note: 50 mails can be sent as a standard user.
     250 mails can be sent as a premium user.
"

# check arguments
if [ $# -eq 0 ];then
  echo "$HELP" 1>&2
  exit
fi

OPTNUM=0
while getopts uf:a:o:t:T:n:h OPT;do
  OPTNUM=`expr $OPTNUM + 1`
  case $OPT in
    "u" ) attach=true ;;
    "f" ) inputfile="$OPTARG" ;;
    "a" ) address="$OPTARG" ;;
    "o" ) addressother="$OPTARG" ;;
    "t" ) title="$OPTARG" ;;
    "T" ) tag="$OPTARG" ;;
    "n" ) notebook="$OPTARG" ;;
    "h" ) echo "$HELP" 1>&2; exit ;;
    * ) echo "$HELP" 1>&2; exit ;;
  esac
done
shift $(($OPTIND - 1))

# Check address
if [ "$address" = "" ];then
  echo "$HELP" 1>&2
  exit
fi
if [ "$addressother" != "" ];then
  address=${address},${addressother}
fi

# Set title if necessary
message="$*"
if [ "$title" = "$def_title" ] && [ "$inputfile" != "" ];then
  title=$inputfile
fi

# Tag check
tagCheck=`echo "$tag"|cut -c1`
if [ "$tag" != "" ] && [ "$tagCheck" != "$TAGMARK" ];then
  tag="$TAGMARK""$tag"
fi
tag="$tag #email"

# Notebook check
notebookCheck=`echo "$notebook"|cut -c1`
if [ "$notebook" != "" ] && [ "$notebookCheck" != "$NOTEBOOKMARK" ];then
  notebook="$NOTEBOOKMARK""$notebook"
fi

# Check input file and send message
if $attach;then
  if [ "$inputfile" != "" ];then
    (echo $message;uuencode $inputfile `basename $inputfile`)|mail -s "$title $notebook $tag" $address
  else
    (echo $message)|mail -s "$title $notebook $tag" $address
  fi
else
  if [ "$inputfile" != "" ];then
    (echo $message;cat $inputfile)|mail -s "$title $notebook $tag" $address
  else
    (echo $message)|mail -s "$title $notebook $tag" $address
  fi
fi

