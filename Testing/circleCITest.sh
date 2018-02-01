#!/bin/bash

set -e
set -o pipefail

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

root_dir=${script_dir}/..

mkdir -p ${root_dir}/qt-easy-build-build

docker run \
    -v ${root_dir}:/usr/src/qt-easy-build \
    -v ${root_dir}/qt-easy-build-build:/usr/src/qt-easy-build-build \
  fbudin69500/qt-easy-build-test \
    /usr/src/qt-easy-build/Testing/Docker/test.sh \
      -j 4 -c -q "4.8.7" \
      -t "sub-tools-bootstrap-make_default-ordered \
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

