#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ "$(uname)" == "Darwin" ]
then
  # MacOS
  $DIR/../Build-qt.sh \
  -c \
  -j 2 \
  -d /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.9.sdk \
  -a x86_64 \
  -s 10.9
else
  $DIR/../Build-qt.sh \
  -c \
  -j 2 > log.txt 2>&1
fi
