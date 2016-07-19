#!/bin/sh

script_dir="`cd $(dirname $0); pwd`"

docker build -t fbudin69500/qt-easy-build-test $script_dir
