#!/bin/bash

show_help() {
cat << EOF
Usage: ${0##*/} [-h] [-c] [-j] [-s SYSROOT] [-d DEPLOYMENT_TARGET] [-a ARCHITECTURES] [-q QT_INSTALL_DIR] [-m CMAKE]

This script is a convenience script to install Qt on the system. It:

- Auto-detect if running on MacOS or Linux
- Compiles zlib.
- Compiles openssl.
- Compiles and install qt.

Options:

  -c             Clean directories that are going to be used.
  -h             Display this help and exit.
  -j             Number of threads to compile tools. [default: 1]
  -m             Path for cmake.
  -q             Installation directory for Qt. [default: qt-everywhere-opensource-build-4.8.7]

MacOS only:
  -a             Set OSX architectures. (expected values: x86_64 or i386) [default: x86_64]
  -d             OSX deployment target. [default: 10.6]
  -s             OSX sysroot. [default: /Developer/SDKs/MacOSX10.6.sdk]
EOF
}
clean=0
nbthreads=1
while [ $# -gt 0 ]; do
  case "$1" in
    -h)
      show_help
      exit 0
      ;;
    -c)
      clean=1
      ;;
    -q)
      install_dir=$2
      shift
      ;;
    -m)
      cmake=$2
      shift
      ;;
    -j)
      nbthreads=$2
      shift
      ;;
    -a)
      osx_architecture=$2
      shift
      ;;
    -d)
      osx_deployment_target=$2
      shift
      ;;
    -s)
      osx_sysroot=$2
      shift
      ;;
    *)
      show_help >&2
      exit 1
      ;;
  esac
  shift
done

# If "clean", remove all directories and temporary files
# that are downloaded and used in this script.
if [ $clean -eq 1 ]
then
  echo "Remove previous files and directories"
  rm -rf zlib*
  rm -f openssl-1.0.1h.tar.gz
  rm -rf openssl-1.0.1h
  rm -f qt-everywhere-opensource-src-4.8.7.tar.gz
  rm -rf qt-everywhere-opensource-src-4.8.7
  rm -rf qt-everywhere-opensource-build-4.8.7
fi
# If cmake path was not given, verify that it is available on the system
# CMake is required to configure zlib
if [[ -z "$cmake" ]]
then
  cmake=`which cmake`
  if [ $? -ne 0 ]
  then
    echo "cmake not found"
    exit 1
  fi
  echo "Using cmake found here: $cmake"
fi

# Download archives (Qt, and openssl
echo "Download openssl"
curl -OL https://packages.kitware.com/download/item/6173/openssl-1.0.1h.tar.gz
echo "Download Qt"
curl -OL http://download.qt.io/official_releases/qt/4.8/4.8.7/qt-everywhere-opensource-src-4.8.7.tar.gz

# Check if building on MacOS or Linux
# And verifies downloaded archives accordingly
if [ "$(uname)" == "Darwin" ]
then
  # MacOS
  if [[ -z $osx_deployment_target ]]
  then
    osx_deployment_target=10.6
  fi
  if [[ -z $osx_sysroot ]]
  then
    sysroot=/Developer/SDKs/MacOSX10.6.sdk
  fi
  if [[ -z $osx_architecture ]]
  then
    osx_architecture=x86_64
  fi
  zlib_macos_options="-DCMAKE_OSX_ARCHITECTURES=$osx_architecture
                -DCMAKE_OSX_SYSROOT=$osx_sysroot
                -DCMAKE_OSX_DEPLOYMENT_TARGET=$osx_deployment_target"
  export KERNEL_BITS=64
  qt_macos_options="-arch $osx_architecture -sdk $osx_sysroot"

  md5_openssl=`md5 ./openssl-1.0.1h.tar.gz | awk '{ print $4 }'`
  md5_qt=`md5 ./qt-everywhere-opensource-src-4.8.7.tar.gz | awk '{ print $4 }'`
else
  # Linux
  md5_openssl=`md5sum ./openssl-1.0.1h.tar.gz | awk '{ print $1 }'`
  md5_qt=`md5sum ./qt-everywhere-opensource-src-4.8.7.tar.gz | awk '{ print $1 }'`
fi
if [ "$md5_openssl" != "8d6d684a9430d5cc98a62a5d8fbda8cf" ]
then
  echo "MD5 mismatch. Problem downloading OpenSSL"
  exit 1
fi
if [ "$md5_qt" != "d990ee66bf7ab0c785589776f35ba6ad" ]
then
  echo "MD5 mismatch. Problem downloading Qt"
  exit 1
fi

# Build zlib
echo "Build zlib"

cwd=$(pwd)

mkdir zlib-install
mkdir zlib-build
git clone git://github.com/commontk/zlib.git
cd zlib-build
$cmake -DCMAKE_BUILD_TYPE:STRING=Release             \
       -DZLIB_MANGLE_PREFIX:STRING=slicer_zlib_      \
       -DCMAKE_INSTALL_PREFIX:PATH=$cwd/zlib-install \
       $zlib_macos_options                           \
       ../zlib
make -j $nbthreads
make install
cd ..
cp zlib-install/lib/libzlib.a zlib-install/lib/libz.a

# Build OpenSSL
echo "Build OpenSSL"

cwd=$(pwd)

tar -xzvf openssl-1.0.1h.tar.gz
cd openssl-1.0.1h/
./config zlib -I$cwd/zlib-install/include -L$cwd/zlib-install/lib shared
make -j $nbthreads build_libs
# If MacOS, install openssl libraries
if [ "$(uname)" == "Darwin" ]
then
  install_name_tool -id $cwd/openssl-1.0.1h/libcrypto.dylib $cwd/openssl-1.0.1h/libcrypto.dylib
  install_name_tool                                                                            \
          -change /usr/local/ssl/lib/libcrypto.1.0.0.dylib $cwd/openssl-1.0.1h/libcrypto.dylib \
          -id $cwd/openssl-1.0.1h/libssl.dylib $cwd/openssl-1.0.1h/libssl.dylib
fi
cd ..

# Build Qt
echo "Build Qt"

cwd=$(pwd)

if [[ -z $install_dir ]]
then
  install_dir="$cwd/qt-everywhere-opensource-build-4.8.7"
  mkdir $install_dir
fi
qt_install_dir_options="-prefix $install_dir"

tar -xzvf qt-everywhere-opensource-src-4.8.7.tar.gz
cd qt-everywhere-opensource-src-4.8.7
# If MacOS, patch linked from thread: https://github.com/Homebrew/legacy-homebrew/issues/40585
if [ "$(uname)" == "Darwin" ]
then
  curl https://gist.githubusercontent.com/ejtttje/7163a9ced64f12ae9444/raw | patch -p1
fi
./configure $qt_install_dir_options                           \
  -release -opensource -confirm-license -no-qt3support        \
  -webkit -nomake examples -nomake demos                      \
  -openssl -I $cwd/openssl-1.0.1h/include                     \
  ${qt_macos_options}                                         \
  -L $cwd/openssl-1.0.1h
make -j $nbthreads
make install

