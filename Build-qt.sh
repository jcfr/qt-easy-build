#!/bin/bash
set -e
set -o pipefail

#
# Configuration
#

# Qt version (major.minor.revision)
QT_VERSION=4.8.7

# OpenSSL version
OPENSSL_VERSION=1.0.1h

# MD5 checksums
OPENSSL_MD5="8d6d684a9430d5cc98a62a5d8fbda8cf"
QT_MD5="d990ee66bf7ab0c785589776f35ba6ad"

#
# Generated configuration
#

QT_MAJOR_MINOR_VERSION=$(echo $QT_VERSION | awk -F . '{ print $1"."$2 }')

# Defaults
clean=0
nbthreads=1
confirmed=0

show_help() {
cat << EOF
Usage: ${0##*/} [-h] [-c] [-j] [-s SYSROOT] [-d DEPLOYMENT_TARGET] [-a ARCHITECTURES] [-q QT_INSTALL_DIR] [-m CMAKE]

This script is a convenience script to install Qt on the system. It:

- Auto-detect if running on MacOS or Linux
- Compiles zlib.
- Compiles openssl.
- Compiles and install qt.

Options:

  -y             Do not prompt user and skip confirmation.
  -c             Clean directories that are going to be used. [default: $clean]
  -h             Display this help and exit.
  -j             Number of threads for compile tools. [default: $nbthreads]
  -m             Path for cmake.
  -q             Installation directory for Qt. [default: qt-everywhere-opensource-build-$QT_VERSION]

MacOS only:
  -a             Set OSX architectures. (expected values: x86_64 or i386) [default: x86_64]
  -d             OSX deployment target. [default: 10.6]
  -s             OSX sysroot. [default: result of 'xcrun --show-sdk-path']
EOF
}

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
    -y)
      confirmed=1
      ;;
    *)
      show_help >&2
      exit 1
      ;;
  esac
  shift
done

openssl_download_url=https://packages.kitware.com/download/item/6173/openssl-$OPENSSL_VERSION.tar.gz
qt_download_url=https://download.qt.io/official_releases/qt/$QT_MAJOR_MINOR_VERSION/$QT_VERSION/qt-everywhere-opensource-src-$QT_VERSION.tar.gz

# Install directory
cwd=$(pwd)
if [[ -z $install_dir ]]
then
  install_dir="$cwd/qt-everywhere-opensource-build-$QT_VERSION"
fi

# Check if building on MacOS or Linux
# And verifies downloaded archives accordingly
SYSTEM="Linux"
if [ "$(uname)" == "Darwin" ]
then
  SYSTEM="Darwin"
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
fi

show_summary() {
cat << EOF

This script will build Qt for $SYSTEM system

QT_VERSION      : $QT_VERSION
OPENSSL_VERSION : $OPENSSL_VERSION

Script options:

 -c Clean directories that are going to be used .. $clean
 -q Installation directory for Qt ................ $install_dir
 -m Path to cmake ................................ $cmake
 -j Number of threads for build tool ............. $nbthreads

Download URLs:
* Qt      : $qt_download_url
* OpenSSL : $openssl_download_url

EOF
}

# Show summary and prompt user
show_summary
if [ $confirmed -eq 0 ]
then
  read -p "Do you want to continue [y/N] ? " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]
  then
    confirmed=1
  else
    echo "Aborting ..."
    exit 1
  fi
fi

# If "clean", remove all directories and temporary files
# that are downloaded and used in this script.
if [ $clean -eq 1 ]
then
  echo "Remove previous files and directories"
  rm -rf zlib*
  rm -f openssl-$OPENSSL_VERSION.tar.gz
  rm -rf openssl-$OPENSSL_VERSION
  rm -f qt-everywhere-opensource-src-$QT_VERSION.tar.gz
  rm -rf qt-everywhere-opensource-src-$QT_VERSION
  rm -rf qt-everywhere-opensource-build-$QT_VERSION
fi

# Download archives (Qt, and openssl
echo "Download openssl"
if ! [ -f openssl-$OPENSSL_VERSION.tar.gz ]
then
  curl -OL $openssl_download_url
fi
echo "Download Qt"
if ! [ -f qt-everywhere-opensource-src-$QT_VERSION.tar.gz ]
then
  curl -OL $qt_download_url
fi

# Check if building on MacOS or Linux
# And verifies downloaded archives accordingly
if [ $SYSTEM == "Darwin" ]
then
  # MacOS
  if [[ -z $osx_deployment_target ]]
  then
    osx_deployment_target=10.6
  fi
  if [[ -z $osx_sysroot ]]
  then
    osx_sysroot=$(xcrun --show-sdk-path)
  fi
  if [[ -z $osx_sysroot ]]
  then
    osx_sysroot=/Developer/SDKs/MacOSX10.6.sdk
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

  md5_openssl=`md5 ./openssl-$OPENSSL_VERSION.tar.gz | awk '{ print $4 }'`
  md5_qt=`md5 ./qt-everywhere-opensource-src-$QT_VERSION.tar.gz | awk '{ print $4 }'`
else
  # Linux
  md5_openssl=`md5sum ./openssl-$OPENSSL_VERSION.tar.gz | awk '{ print $1 }'`
  md5_qt=`md5sum ./qt-everywhere-opensource-src-$QT_VERSION.tar.gz | awk '{ print $1 }'`
fi
if [ "$md5_openssl" != "$OPENSSL_MD5" ]
then
  echo "MD5 mismatch. Problem downloading OpenSSL"
  exit 1
fi
if [ "$md5_qt" != "$QT_MD5" ]
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

tar -xzf openssl-$OPENSSL_VERSION.tar.gz
cd openssl-$OPENSSL_VERSION/
./config zlib -I$cwd/zlib-install/include -L$cwd/zlib-install/lib shared
make -j $nbthreads build_libs
# If MacOS, install openssl libraries
if [ "$(uname)" == "Darwin" ]
then
  install_name_tool -id $cwd/openssl-$OPENSSL_VERSION/libcrypto.dylib $cwd/openssl-$OPENSSL_VERSION/libcrypto.dylib
  install_name_tool                                                                            \
          -change /usr/local/ssl/lib/libcrypto.1.0.0.dylib $cwd/openssl-$OPENSSL_VERSION/libcrypto.dylib \
          -id $cwd/openssl-$OPENSSL_VERSION/libssl.dylib $cwd/openssl-$OPENSSL_VERSION/libssl.dylib
fi
cd ..

# Build Qt
echo "Build Qt"

cwd=$(pwd)

mkdir -p $install_dir
qt_install_dir_options="-prefix $install_dir"

tar -xzf qt-everywhere-opensource-src-$QT_VERSION.tar.gz
cd qt-everywhere-opensource-src-$QT_VERSION
# If MacOS, patch linked from thread: https://github.com/Homebrew/legacy-homebrew/issues/40585
if [ "$(uname)" == "Darwin" ]
then
  curl https://gist.githubusercontent.com/ejtttje/7163a9ced64f12ae9444/raw | patch -p1
fi
./configure $qt_install_dir_options                           \
  -release -opensource -confirm-license -no-qt3support        \
  -webkit -nomake examples -nomake demos                      \
  -silent                                                     \
  -no-phonon                                                  \
  -openssl -I $cwd/openssl-$OPENSSL_VERSION/include           \
  ${qt_macos_options}                                         \
  -L $cwd/openssl-$OPENSSL_VERSION
make -j $nbthreads
make install

