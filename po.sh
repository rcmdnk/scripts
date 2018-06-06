#!/bin/bash
## Description {{{
#
# Parallel operations using tmux.
#
PO_VERSION=v0.0.1
PO_DATE="06/Jun/2018"
#
# }}}

## License {{{
#
#The MIT License (MIT)
#
#Copyright (c) 2018 rcmdnk
#
#Permission is hereby granted, free of charge, to any person obtaining a copy of
#this software and associated documentation files (the "Software"), to deal in
#the Software without restriction, including without limitation the rights to
#use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
#the Software, and to permit persons to whom the Software is furnished to do so,
#subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in all
#copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
#FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
#COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
#IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
#CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
# }}}

# Help
HELP="Usage: $(basename "$0") [-ukh] <host1> [<host2> [<host3>...]]

Arguments:
  -l <user> Set user
  -i <key>  Set ssh key
  -h        Print Help (this message) and exit

hostX can be given with any ssh options, e.g.:

    $ $(basename "$0") user1@example1.com \"-i ~/.ssh/my_key example2.com\"

If '-l' or '-i' is given, it will be applied for all hosts.
"

# Default values
user=""
key=""

# Check arguments
while getopts l:i:h OPT;do
  case $OPT in
    "l" ) user="$OPTARG";;
    "i" ) key="$OPTARG";;
    "h" ) echo "$HELP";exit 0;;
    * ) echo "$HELP"; exit 1;;
  esac
done
shift $((OPTIND - 1))

if [ $# -eq 0 ];then
  echo "$HELP"; exit 1;
fi

hosts=($@)
ssh_opt=""

if [ -n "$user" ];then
  ssh_opt="$ssh_opt -l $user"
fi
if [ -n "$key" ];then
  ssh_opt="$ssh_opt -i $key"
fi

# Make session
session=po-`date +%s`

tmux new-session -d -n po -s $session

# Connect to the first server
tmux send-keys "ssh $ssh_opt  ${hosts[0]}" C-m
shift

# Connect to remaining servers
for i in $(seq 1 $((${#hosts[@]}-1)));do
  tmux split-window
  tmux select-layout tiled
  tmux send-keys "ssh $ssh_opt ${hosts[$i]}" C-m
done

# Select first pane
tmux select-pane -t 0

# Set synchronize option
tmux set-window-option synchronize-panes on

# Send user/host check command
tmux send-keys "echo \$USER@\$HOSTNAME" C-m

# Start operations
tmux attach-session -t $session
