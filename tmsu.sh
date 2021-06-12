#!/usr/bin/env bash
#
# Find video files and update tmsu tags for these files
#
# Dependencies
# * tmsu     for managing taggs
# * rlwrap   for tab completion
# * mplayer  for playing media
# * wq       for clearing the console (optional)
#
# Init:
#   tmsu init # initialize tmsu
#
# Example:
#   tmsu.sh # show all untagged files
#   tmsu.sh re # show same list of files again
#   tmsu.sh "summer" # show all files containing the tag "summer"
#   tmsu.sh "year < 2000" # show all files containing the tag "year" with a value smaller than 2000
#
#  Tag commands:
#    "": go to next video (aliases: "n", "next", ">")
#    "re": replay video (aliases: "repeat", "again")
#    "back": go to previous video (aliases: "b", "<", "p", "prev")
#    "goto 123": go to video 123. exit if number doesn't exist
#    "wq": execute the shell command wq and exit
#    "rm foo bar": remove the tags "foo" and "bar" from the last played file 
#    anything else will be stored as tags for the last played file
#
# Interaction:
#   $ tmsu.sh                    <-- shell command
#   Files: 1 pl/tmsu.pl
#
#   -----------------
#   1/5 45M  ./test/testvideo.mkv
#   Tags (blank to skip):
#   re                           <-- User input: "re", "repeat" or "again" to play file again, "wq" to exit
#
#   -----------------
#   1/5 45M  ./test/testvideo.mkv
#   Tags (blank to skip):
#   music year=2020              <-- User input: tags seperated by space, values for tags with "=".  Prefix with "rm " or "untag " to remove tags
#   tmsu: new tag 'music'
#   tmsu: new tag 'year'
#   tmsu: new value '2020'
#
#   -----------------
#   1/5 45M  ./test/testvideo.mkv
#   music  year=2020
#   Tags (blank to skip):
#                                <-- Press return key to go to next file
#   -----------------
#   2/5 45M  ./test/othervideo.mp4
#   movie  year=2021
#   Tags (blank to skip):
#   back
#
##
# Copyright (c) Martin Sigloch <copyright@f0i.de>
# This file is part of github:f0i/bin
# As long as you retain this notice you can do whatever you want with it.
# This code and information are provided without warranty of any kind.
##

if [ "$#" -eq 0 ]; then
  # if query is empty, show all untagged files
  query=untagged
else
  # otherwise filter by query
  # see `tmsu help files`
  query="files $*"
fi

if [[ "$1" == "init" ]]
then
  ask "Init tmsu and create ./pl/ directory" \
    && tmsu init \
    && mkdir -p pl \
    && touch '.tmsu/history'
  exit $?
fi

if [[ "$1" != "re" ]]
then
  # run new query, filter videos, shuffle and save as playlist
  tmsu $query \
    | grep -i -e "mp4$" -e "flv$" -e "mpg$" -e "avi$" -e "wmv$" -e "webm$" -e "mov$" -e "mkv$" \
    | sort --random-sort \
    > pl/tmsu.pl
    # other options to order files:
    # reverse:
    #| tac \
    # sorted by name:
    #| sort \
    # shuffled:
    #| sort --random-sort \
    # deterministic shuffle:
    #| sort --random-sort --random-source=/dev/zero \

  echo "query: $query" >> pl/query

elif [[ "$2" == "shuffle" ]]
then
  # shuffle playlist from previous query
  sort --random-sort -o pl/tmsu.pl pl/tmsu.pl || exit 1
fi

# print file count
tail -n 1 pl/query
echo -n "Files: "
wc -l pl/tmsu.pl

# create tag file containing existing tags for tab completion
sqlite3 .tmsu/db  "select count(*), tag.name, value.name from file_tag inner join tag on tag_id=tag.id left join value on value_id=value.id group by tag.name, value.name;" \
  | grep -v "|width|" \
  | grep -v "|height|" \
  | grep -v "|duration|" \
  | grep -v "|size|" \
  | grep -v "|time|" \
  | grep -v "|date|" \
  | sort -h \
  | sed "s/^[0-9]*|//" | sed "s/|$//" | sed "s/|/=/" \
  | cat > "./.tmsu/tags"

# alternative implementation treats tags and values as seperate words
#tmsu tags > "./.tmsu/tags"
#tmsu values | grep -v "^[0-9]" >> "./.tmsu/tags"

mplayeroptions="-fs -screen 0"
#mplayeroptions="$mplayeroptions -nosound"

line=1
lines=`wc -l pl/tmsu.pl | awk '{print $1;}'`

while [ "$lines" -ge "$line" ]
do
  file=`sed "${line}q;d" pl/tmsu.pl`
  echo
  echo "-----------------"
  echo -n "$line/$lines: "
  du -hs "$file"
  tmsu tags "$file"

  mplayer -really-quiet $mplayeroptions "$file"

  if [ "$line" -eq "0" ]
  then
    let line+=1
    continue
  fi

  echo "Tags (blank to skip):"

  chown $USER .tmsu/history # hack to prevent permision errors
  tags=$(rlwrap -H .tmsu/history --break-chars=";" -f .tmsu/tags -o cat )



  case "$tags" in
    ""|">"|"next"|"n") let line+=1 ;;
    "wq") wq ; exit ;;
    "repeat"|"again"|"re") ;;
    "untag "*|"rm "*) tmsu untag "$file" $tags ;;
    "b"|"back"|"p"|"prev"|"<") let line-=1 ;;
    "goto "*) line=$(echo " $tags" | awk '{print $2}') ;;
    *) tmsu tag "$file" $tags ;;
  esac
done
