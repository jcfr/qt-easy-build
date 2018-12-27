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
      -j 4 -c -q "5.12.0" \
      -t "module-qtbase module-qtbase-install_subtargets"
