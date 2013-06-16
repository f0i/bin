#!/bin/bash
# 
# Script to send html mails with the mutt mail client.
#
# The alternative html message must be included as an atachment of the mail
# with the filename defined in $altfile.
#
# Inspired by script of David Leadbeater
# https://dgl.cx/2009/03/html-mail-with-mutt-using-markdown
#
##
# Copyright (c) Martin Sigloch <copyright@f0i.de>
# This file is part of github:f0i/bin
# As long as you retain this notice you can do whatever you want with it.
# This code and information are provided without warranty of any kind.
##

altfile="html-markdown-alternative.html"

# read content
mail=`cat`

# split into header and body
header=`echo "$mail" | egrep "^$" -m 1 -B 999`
body=`echo "$mail" | egrep "^$" -A 9999999999`

# Check if html file is attached
if echo "$body" | grep -q -m 1 'filename="'$altfile
then
  # Detect boundary
  # (if the file exists it has to be a multipart message)
  bound=`echo "$header" | \
    egrep "^Content-Type: multipart" | \
    sed 's/.*boundary="\([^"]*\).*/\1/'`

  # Count boundaries in body
  count=`echo "$body" | grep -c "$bound"`

  # If the boundry exist more than ? times,
  # the message also has other attachments
  echo "count: $count" >&2
  if [ $count -gt 3 ]
  then
    # Create new boundry for content
    delim=`tr -dc "a-zA-Z0-9" < /dev/urandom | head -c 16`
    mkdir -p /tmp/mutt-$delim
    cd /tmp/mutt-$delim

    # Split the message into the original files
    echo "$body" > body
    csplit -k -f ./bodypart ./body /$bound/ '{*}' > /dev/null

    # 00 is empty, 01 is message as text/plain
    # Start multipart/alternative block with 01
    cat bodypart00 > body
    echo "--$bound" >> body
    echo -e 'Content-Type: multipart/alternative; boundary="'$delim'"' >> body
    echo "" >> body
    echo "--$delim" >> body
    cat bodypart01 | tail -n +2 >> body

    # if files don't exist, something went wront
    rm bodypart00 bodypart01 || exit 1

    # find the part with alternative html message
    # give priority to the latest file
    find ./bodypart* | sort -r | \
      while read file
      do
        echo $file >&2
        if egrep "^$" -m1 -B 99 $file | grep -q 'filename="'$altfile
        then
          echo "html message is in $file" >&2
          echo "--$delim" >> body
          cat $file | tail -n +2 >> body
          echo "--$delim--" >> body
          echo "" >> body
          rm $file
          break
        fi
      done

    #append other files
    cat bodypart* >> body
    rm bodypart*
    body=`cat body`
  else
    header=`echo "$header" | sed 's/^\(Content-Type: multipart.\)mixed/\1alternative/'`
  fi
  body=`echo "$body" | sed 's/;.filename="html-markdown-alternative.html"//'`
else
  echo "No alternativ html message" >&2 
fi

# Send the mail
(echo "$header" && echo "$body") | /usr/bin/msmtp -a cube

exit $?
