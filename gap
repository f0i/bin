#!/bin/bash
#
# Add some newlines and clear screen (without deleting console output)
#
##
# Copyright (c) Martin Sigloch <copyright@f0i.de>
# This file is part of github:f0i/bin
# As long as you retain this notice you can do whatever you want with it.
# This code and information are provided without warranty of any kind.
##

LINES=`tput lines`

for i in `seq -20 $LINES`
do
  echo ""
done

clear
