#!/bin/sh

script_dir="`cd $(dirname $0); pwd`"

docker run \
  --rm \
  -v $script_dir/../..:/usr/src/qt-easy-build \
    fbudin69500/qt-easy-build-test \
      /usr/src/qt-easy-build/Testing/Docker/test.sh
