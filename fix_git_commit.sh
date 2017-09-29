#!/bin/sh

if [ "$#" -lt 3 ];then
  echo "usage: $0 <fix_word> <correct_name> <correct_email>"
  exit
fi
FIX_WORD="$1"
CORRECT_NAME="$2"
CORRECT_EMAIL="$3"

if ! git log --pretty=format:"%an %ae %cn %cn"|grep -q "$FIX_WORD";then
  exit
fi

git filter-branch -f --env-filter "
if ( echo \"\$GIT_COMMITTER_EMAIL\"|grep -i -q \"$FIX_WORD\" ) || ( echo \"\$GIT_COMMITTER_NAME\"|grep -i -q \"$FIX_WORD\" );then
    export GIT_COMMITTER_NAME=\"$CORRECT_NAME\"
    export GIT_COMMITTER_EMAIL=\"$CORRECT_EMAIL\"
fi
if ( echo \"\$GIT_AUTHOR_EMAIL\"|grep -i -q \"$FIX_WORD\" ) || ( echo \"\$GIT_AUTHOR_NAME\"|grep -i -q \"$FIX_WORD\" );then
    export GIT_AUTHOR_NAME=\"$CORRECT_NAME\"
    export GIT_AUTHOR_EMAIL=\"$CORRECT_EMAIL\"
fi
" --tag-name-filter cat -- --branches --tags
git push -f

# @ Other place already cloned:
#git pull --allow-unrelated-histories
