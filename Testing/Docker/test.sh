#!/bin/bash

# This is a script to test that qt compiled
# Docker container.

show_help() {
cat << EOF
Usage: ${0##*/} [-h] [-c] [-j] [-q QT_INSTALL_DIR] [-m CMAKE]

This script is to test qt-easy-build in
a docker image.

Options:

  -h             Display this help and exit.
  -j             Number of threads to compile tools
EOF
}

nbthreads=1
while [ $# -gt 0 ]; do
  case "$1" in
    -h)
      show_help
      exit 0
      ;;
    -j)
      nbthreads=$2
      shift
      ;;
    *)
      show_help >&2
      exit 1
      ;;
  esac
  shift
done


die() {
  echo "Error: $@" 1>&2
  exit 1;
}

/usr/src/qt-easy-build/Build-qt.sh -c -j ${nbthreads}
/usr/local/Trolltech/Qt-4.8.7/bin/qmake --version |grep 'Using Qt version 4.8.7' || die "Could not run Qt 4.8.7"

