#!/bin/bash
#
# Edit markdown file in project folder
#
# example:
#   md index
#   md f0i mdstart
#   md --help
#
##
# Copyright (c) Martin Sigloch <copyright@f0i.de>
# This file is part of github:f0i/bin
# As long as you retain this notice you can do whatever you want with it.
# This code and information are provided without warranty of any kind.
##

folder="$1"
file="$2"

[[ "$file" == "" ]] && folder="."
[[ "$file" == "" ]] && file="$1"

if [[ "$file" == "" ]]
then
  echo "usage: md [category] filename"
  exit 1
fi

file="$MD_FILE_PATH/$folder/${file}.md"

cd "$MD_FILE_PATH"

case "$1" in
  "ls"|"list")
    tree
    ;;
  "commit")
    git add . \
      && git commit -v \
      && git push
    ;;
  "push")
    git push
    ;;
  "publish"|"deploy")
    ssh f0i "cd /var/www/servers/projects.f0i.de/pages/ && git pull"
    ;;
  "--help"|"help")
    echo "usage:"
    echo " md [<category>] <name>"
    echo " md ls|commit|deploy|help"
    ;;
  *)
    mkdir -p `dirname $file` \
      && vim "$file" \
      && wq
    ;;
esac

exit $?
