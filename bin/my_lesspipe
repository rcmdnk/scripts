#!/usr/bin/env bash
for source in "$@"; do
  case $source in
    *ChangeLog|*changelog)
      source-highlight --failsafe -f esc --lang-def=changelog.lang --style-file=esc.style -i "$source" ;;
    *Makefile|*makefile)
      source-highlight --failsafe -f esc --lang-def=makefile.lang --style-file=esc.style -i "$source" ;;
    *.tar|*.tgz|*.gz|*.bz2|*.xz)
      if type -a lesspipe.sh >& /dev/null;then
        lesspipe.sh "$source"
      elif type -a lesspipe >& /dev/null;then
        lesspipe "$source"
      fi
      ;;
    *) source-highlight --failsafe --infer-lang -f esc --style-file=esc.style -i "$source" ;;
  esac
done
