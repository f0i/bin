#!/bin/bash
#
# Edit markdown file in project folder
#
# example:
#   md index
#   md f0i mdstart
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

if [[ "$file" == "ls" ]]
then
  cd "$MD_FILE_PATH"
  tree
  exit $?
fi

file="$MD_FILE_PATH/$folder/${file}.md"

mkdir -p `dirname $file` || exit 1
vim "$file"

wq
