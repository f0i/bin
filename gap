#!/bin/bash
#
# Add some newlines
#
##
# Copyright (c) Martin Sigloch <copyright@f0i.de>
# This file is part of github:f0i/bin
# As long as you retain this notice you can do whatever you want with it.
# This code and information are provided without warranty of any kind.
##

count=20
if [ "$1" != "" ]
then
  count=$1
fi

for i in `seq 0 "$count"`
do
  echo
done
