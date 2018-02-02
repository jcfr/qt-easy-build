#!/bin/bash

set -e
set -o pipefail

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

pushd $script_dir

targets="sub-tools-bootstrap-make_default-ordered \
sub-moc-make_default-ordered \
sub-rcc-make_default-ordered \
sub-uic-make_default-ordered \
sub-corelib-make_default-ordered \
sub-xml-make_default-ordered \
sub-network-make_default-ordered \
sub-sql-make_default-ordered \
sub-testlib-make_default-ordered \
sub-gui-make_default-ordered \
sub-opengl-make_default-ordered \
sub-xmlpatterns-make_default-ordered \
sub-multimedia-make_default-ordered \
sub-svg-make_default-ordered \
sub-script-make_default-ordered \
sub-declarative-make_default-ordered \
sub-webkit-make_default-ordered \
sub-scripttools-make_default-ordered \
sub-plugins-make_default-ordered \
sub-imports-make_default-ordered \
sub-tools-make_default-ordered \
sub-translations-make_default-ordered \
install_subtargets \
install_qmake"

if [ "$(uname)" == "Darwin" ]
then
  # MacOS
  $script_dir/../Build-qt.sh \
  -c \
  -j 4 \
  -y \
  -d 10.9 \
  -t "${targets}"
else
  $script_dir/../Build-qt.sh \
  -c \
  -j 4 \
  -y \
    -t "${targets}"
fi

die() {
  echo "Error: $@" 1>&2
  exit 1;
}

expected_qt_version="4.8.7"

./qt-everywhere-opensource-build-$expected_qt_version/bin/qmake --version | grep "Using Qt version $expected_qt_version" || die "Could not run Qt $expected_qt_version"

popd

