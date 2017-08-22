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
  -t "sub-tools-bootstrap-all-ordered sub-moc-all-ordered sub-rcc-all-ordered sub-uic-all-ordered sub-corelib-all-ordered sub-gui-all-ordered install_subtargets install_qmake"
else
  $script_dir/../Build-qt.sh \
  -c \
  -j 4 \
  -y \
  -t "sub-tools-bootstrap-all-ordered sub-moc-all-ordered sub-rcc-all-ordered sub-uic-all-ordered sub-corelib-all-ordered sub-gui-all-ordered install_subtargets install_qmake"
fi

die() {
  echo "Error: $@" 1>&2
  exit 1;
}

expected_qt_version="4.8.7"

./qt-everywhere-opensource-build-$expected_qt_version/bin/qmake --version | grep "Using Qt version $expected_qt_version" || die "Could not run Qt $expected_qt_version"

popd

