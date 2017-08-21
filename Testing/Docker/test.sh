#!/bin/bash

set -e
set -o pipefail

# This is a script to test that qt compiled
# Docker container.

show_help() {
cat << EOF
Usage: ${0##*/} [-h] [-j] [-c] -q X.Y.Z

This script is to test qt-easy-build in a docker image.

Required parameters:

  -q             Expected Qt version (e.g X.Y.Z)

Options:

  -h             Display this help and exit.
  -c             Clean directories that are going to be used.
  -j             Number of threads to use for parallel build
  -t             Specific Qt targets to build (e.g -t "module-qtbase module-qtbase-install_subtargets")
EOF
}

# Defaults
clean_arg=
nbthreads=1
expected_qt_version=
qt_targets=

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
    -c)
      clean_arg="-c"
      ;;
    -q)
      expected_qt_version=$2
      shift
      ;;
    -t)
      qt_targets="$2"
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

if [ -z $expected_qt_version ]; then
  die "Specify expected Qt version"
fi

if [[ -z $qt_targets ]]
then
  /usr/src/qt-easy-build/Build-qt.sh -y $clean_arg -j ${nbthreads}
else
  /usr/src/qt-easy-build/Build-qt.sh -y $clean_arg -j ${nbthreads} -t "$qt_targets"
fi

/usr/src/qt-easy-build-build/qt-everywhere-opensource-build-$expected_qt_version/bin/qmake --version | grep "Using Qt version $expected_qt_version" || die "Could not run Qt $expected_qt_version"

