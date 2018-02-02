#!/bin/bash

set -e
set -o pipefail

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

pushd $script_dir

if [ "$(uname)" == "Darwin" ]
then
  # MacOS
  $script_dir/../Build-qt.sh \
  -c \
  -j 4 \
  -y \
  -s macosx10.11 \
  -a x86_64 \
  -d 10.9 \
  -t "module-qtbase module-qtbase-install_subtargets"
else
  $script_dir/../Build-qt.sh \
  -c \
  -j 4 \
  -y \
  -t "module-qtbase module-qtbase-install_subtargets"
fi

die() {
  echo "Error: $@" 1>&2
  exit 1;
}

expected_qt_version="5.10.0"

./qt-everywhere-opensource-build-$expected_qt_version/bin/qmake --version | grep "Using Qt version $expected_qt_version" || die "Could not run Qt $expected_qt_version"

popd

