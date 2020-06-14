#!/usr/bin/env bash

if [ "$#" -eq 0 ]; then
  query=untagged
else
  query="files $*"
fi

if [[ "$1" != "re" ]]
then
  tmsu $query \
    | grep -i -e "mp4$" -e "flv$" -e "mpg$" -e "avi$" -e "wmv$" -e "webm$" -e "mov$" \
    | tac \
    | sort --random-sort \
    > pl/tmsu.pl
    #| sort \
    #| sort --random-sort \
    #| sort --random-sort --random-source=/dev/zero \
fi

echo -n "Files: "
wc -l pl/tmsu.pl
read

ofs=$IFS
IFS=$'\n'
for file in `cat pl/tmsu.pl`
do
  while true
  do
    echo
    echo "-----------------"
    du -hs "$file"
    tmsu tags "$file"
    mplayer -really-quiet "$file"
    
    echo "Existing tags:"
    tmsu tags "$file"
    echo "Tags (blank to skip):"
    
    IFS="$ofs"
    read tags

    case "$tags" in
      "") break ;;
      "repeat"|"again"|"re") continue ;;
      "untag "*|"rm "*) tmsu untag "$file" $tags; continue ;;
      *) tmsu tag "$file" $tags; continue ;;
    esac
  done
done
