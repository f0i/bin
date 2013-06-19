#!/bin/bash
# 
# Convert message in markdown to html for the mutt mail client.
#
# Destination file is definde in $file.
#
# Dependencies: markdown
#
# Inspired by script of David Leadbeater (github:dgl)
# https://dgl.cx/2009/03/html-mail-with-mutt-using-markdown
#
##
# Copyright (c) Martin Sigloch <copyright@f0i.de>
# This file is part of github:f0i/bin
# As long as you retain this notice you can do whatever you want with it.
# This code and information are provided without warranty of any kind.
##

file="/tmp/html-markdown-alternative.html"
preview='chromium'

# Create hader with style
cat > $file <<EOF
<html>
<head>
  <meta name="generator" content="markdown.sh">
  <meta name="author" content="f0i">
  <style>
    code {
      font-family: 'Andale Mono', 'Lucida Console', 'Bitstream Vera Sans Mono', 'Courier New', monospace;
    }
    pre {
      border-left: 20px solid #ddd; margin-left: 10px; padding-left: 5px;
    }
  </style>
</head>
<body>
EOF

# get body of message and generate html
cat $1 | egrep "^$" -A 99999 | markdown >> $file

cat >> $file <<EOF
</body>
</html>
EOF

# Preview the file
($preview $file &)

