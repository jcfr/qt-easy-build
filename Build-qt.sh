#!/bin/bash
set -ex
set -o pipefail

script_dir=$(cd $(dirname $0) || exit 1; pwd)


#
# Configuration
#

# Qt version (major.minor.revision)
QT_VERSION=5.15.18

# OpenSSL version
OPENSSL_VERSION=1.1.1w

# Checksums
OPENSSL_SHA256="cf3098950cb4d853ad95c0841f1f9c6d3dc102dccfcacd521d93925208b76ac8"
QT_MD5="51d97438bd33f8f0042593cf6cc4490c"

QT_SRC_ARCHIVE_EXT="tar.xz"

#
# Generated configuration
#

QT_MAJOR_MINOR_VERSION=$(echo $QT_VERSION | awk -F . '{ print $1"."$2 }')

# Defaults
clean=0
nbthreads=1
confirmed=0
qt_targets=

# Check if building on MacOS or Linux
SYSTEM="Linux"
if [ "$(uname)" == "Darwin" ]
then
  SYSTEM="Darwin"
fi

export CFLAGS=""
export CXXFLAGS=""

die() {
  printf >&2 "$1\n"
  exit 1
}

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
  -j             Number of threads for parallel build. [default: $nbthreads]
  -m             Path for cmake.
  -q             Installation directory for Qt. [default: qt-everywhere-build-$QT_VERSION]
  -t             Specific Qt targets to build (e.g -t "module-qtbase module-qtbase-install_subtargets")

Environment variables:

  CFLAGS   [${CFLAGS}]
  CXXFLAGS [${CXXFLAGS}]

EOF

if [ $SYSTEM == "Darwin" ]
then
  cat << EOF
Options (macOS):
  -a             Set OSX architectures. (expected values: x86_64 or i386) [default: x86_64]
  -d             OSX deployment target. [default: 10.12]
  -s             OSX sysroot. [default: macosx10.13]

EOF
fi
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
    -t)
      qt_targets=$2
      shift
      ;;
    *)
      show_help >&2
      exit 1
      ;;
  esac
  shift
done

command_not_found_install_hint="\n=> Consider installing the program using a package manager (apt-get, yum, homebrew, ...)"

openssl_archive=openssl-$OPENSSL_VERSION.tar.gz
openssl_download_url=https://www.openssl.org/source/old/1.1.1/$openssl_archive

#qt_archive=qt-everywhere-src-$QT_VERSION.${QT_SRC_ARCHIVE_EXT}
qt_archive=qt-everywhere-opensource-src-$QT_VERSION.${QT_SRC_ARCHIVE_EXT}
#qt_download_url=https://download.qt.io/official_releases/qt/$QT_MAJOR_MINOR_VERSION/$QT_VERSION/single/$qt_archive
qt_download_url=https://download.qt.io/archive/qt/$QT_MAJOR_MINOR_VERSION/$QT_VERSION/single/$qt_archive
echo "qt_download_url [$qt_download_url]"

cwd=$(pwd)

# Dependencies directory
deps_dir="$cwd/qt-everywhere-deps-$QT_VERSION"

# Source and Build directory
src_dir="$cwd/qt-everywhere-src-$QT_VERSION"

# Install directory
if [[ -z $install_dir ]]
then
  install_dir="$cwd/qt-everywhere-build-$QT_VERSION"
fi

# If cmake path was not given, verify that it is available on the system
# CMake is required to configure zlib
if [[ -z "$cmake" ]]
then
  cmake=`which cmake`
  if [ $? -ne 0 ]
  then
    die "error: 'cmake' not found ! ${command_not_found_install_hint}"
  fi
fi

if ! command -v curl &> /dev/null; then
  die "error: 'curl' not found ! ${command_not_found_install_hint}"
fi

if ! command -v git &> /dev/null; then
  die "error: 'git' not found ! ${command_not_found_install_hint}"
fi

# Set macOS options
if [ $SYSTEM == "Darwin" ]
then
  # MacOS
  if [[ -z $osx_deployment_target ]]
  then
    osx_deployment_target=10.13
  fi
  if [[ -z $osx_sysroot ]]
  then
    osx_sysroot=macosx10.15
  fi
  if [[ -z $osx_architecture ]]
  then
    osx_architecture=x86_64
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
 -j Number of threads for parallel build.......... $nbthreads

Download URLs:
* Qt      : $qt_download_url
* OpenSSL : $openssl_download_url

Environment variables:

  CFLAGS   [${CFLAGS}]
  CXXFLAGS [${CXXFLAGS}]

EOF

if [ $SYSTEM == "Darwin" ]
then
  cat << EOF
Script options (macOS):

 -a OSX architectures ............................ $osx_architecture
 -d OSX deployment target ........................ $osx_deployment_target
 -s OSX sysroot .................................. $osx_sysroot

EOF
  fi
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
    die "Aborting ..."
  fi
fi

# If "clean", remove all directories and temporary files
# that are downloaded and used in this script.
if [ $clean -eq 1 ]
then
  echo "Remove previous files and directories"
  rm -rf $deps_dir
  rm -rf $src_dir
  rm -rf $install_dir
fi

mkdir -p $deps_dir
pushd $deps_dir

# Download archives
echo "Download openssl"
if ! [ -f $openssl_archive ]
then
  curl -# -OL $openssl_download_url
else
  echo "  skipping (found $openssl_archive)"
fi
echo "Download Qt"
if ! [ -f $qt_archive ]
then
  curl -# -OL $qt_download_url
else
  echo "  skipping (found $qt_archive)"
fi

# Check if building on MacOS or Linux
# And verifies downloaded archives accordingly
if [ $SYSTEM == "Darwin" ]
then
  # MacOS
  zlib_macos_options="-DCMAKE_OSX_ARCHITECTURES=$osx_architecture
                -DCMAKE_OSX_SYSROOT=$osx_sysroot
                -DCMAKE_OSX_DEPLOYMENT_TARGET=$osx_deployment_target"
  export KERNEL_BITS=64
  qt_macos_options="-sdk $osx_sysroot"

  sha256_openssl=`shasum -a 256 ./$openssl_archive | awk '{ print $1 }'`
  md5_qt=`md5 ./$qt_archive | awk '{ print $4 }'`
else
  # Linux
  sha256_openssl=`sha256sum ./$openssl_archive | awk '{ print $1 }'`
  md5_qt=`md5sum ./$qt_archive | awk '{ print $1 }'`
fi
if [ "$sha256_openssl" != "$OPENSSL_SHA256" ]
then
  die "SHA256 mismatch. Problem downloading OpenSSL"
fi
if [ "$md5_qt" != "$QT_MD5" ]
then
  die "MD5 mismatch. Problem downloading Qt"
fi

# Build zlib
echo "Build zlib"

cwd=$(pwd)

mkdir -p zlib-install
mkdir -p zlib-build
if [[ ! -d zlib ]]
then
  git clone https://github.com/commontk/zlib.git
fi
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

if [[ ! -d openssl-$OPENSSL_VERSION ]]
then
  tar --no-same-owner -xf $openssl_archive
fi
cd openssl-$OPENSSL_VERSION/
LDFLAGS="-Wl,-headerpad_max_install_names" \
./config zlib -I$cwd/zlib-install/include -L$cwd/zlib-install/lib shared
make -j 1 build_libs
# If MacOS, install openssl libraries
if [ "$(uname)" == "Darwin" ]
then
  install_name_tool -id $cwd/openssl-$OPENSSL_VERSION/libcrypto.dylib $cwd/openssl-$OPENSSL_VERSION/libcrypto.dylib
  install_name_tool                                                                            \
          -change /usr/local/ssl/lib/libcrypto.1.0.0.dylib $cwd/openssl-$OPENSSL_VERSION/libcrypto.dylib \
          -id $cwd/openssl-$OPENSSL_VERSION/libssl.dylib $cwd/openssl-$OPENSSL_VERSION/libssl.dylib
fi
cd ..

# Build Python 2.7: required to build QtWebEngine and QtPdf in Qt 5.15.x
echo "Build Python 2.7"

cwd=$(pwd)

mkdir -p python-cmake-buildsystem-build
if [[ ! -d python-cmake-buildsystem ]]
then
  git clone https://github.com/python-cmake-buildsystem/python-cmake-buildsystem.git
fi
# Checkout an older python-cmake-buildsystem commit that is compatible with Python 2.7
(cd python-cmake-buildsystem; git checkout 39d95fd6f6bc78f4d7fa4217093281aa736517c9)
cd python-cmake-buildsystem-build
$cmake \
  -DCMAKE_BUILD_TYPE:STRING=Release \
  -DCMAKE_INSTALL_PREFIX:PATH=$cwd/python-cmake-buildsystem-install \
  -DPYTHON_VERSION:STRING=2.7.15 \
  -DBUILD_LIBPYTHON_SHARED:BOOL=ON \
  -DENABLE_SSL:BOOL=OFF \
  ../python-cmake-buildsystem

$cmake --build $cwd/python-cmake-buildsystem-build --config Release --target install -- -j$nbthreads
cd ..

popd

# Build Qt
echo "Build Qt"

cwd=$(pwd)

mkdir -p $install_dir
qt_install_dir_options="-prefix $install_dir"

if [[ ! -d $src_dir ]]
then
  tar --no-same-owner -xf $deps_dir/$qt_archive

  # Collect patches
  # - Adapted in part from https://github.com/macports/macports-ports/tree/master/aqua/qt5/files
  patches=(
    0004-qtbase-tahoe-no-agl-framework.patch

    # TODO: remove when updating to 5.15.19
    CVE-2025-4211-qtbase-5.15.diff
    CVE-2025-5455-qtbase-5.15.patch
    CVE-2025-30348-qtbase-5.15.diff
    CVE-2025-23050-qtconnectivity-5.15.diff
  )
  qtlocation_patches=(
    # 0001-qtlocation-clang16.patch
    patch-qtlocation-mbgl-unique_any.hpp.diff
    patch-qtlocation-narrowing-const-reference.diff # https://trac.macports.org/ticket/73016
  )

  qtwebengine_patches=(
    # 0002-qtwebengine-ninja1.12.patch
    # 0003-qtwebengine-clang16.patch
    patch-qtwebengine-patch-zlib.diff # Backport fix for https://bugreports.qt.io/browse/QTBUG-138486
    patch-qtwebengine-crc32c-arm64.diff
  )

  if [ "$(uname)" == "Darwin" ]
  then
    qtwebengine_patches+=(
      patch-qtwebengine-libc++19.diff
      patch-qtwebengine-src_3rdparty_chromium_third__party_perfetto_include_perfetto_tracing_internal_track__event__data__source.h.diff
      patch-qtwebengine-src_3rdparty_chromium_third__party_blink_renderer_platform_wtf_hash__table.h.diff
    )
  fi

  # Apply patches
  pushd $src_dir

  qtlocation_patch_count=${#qtlocation_patches[@]}
  echo "Found $qtlocation_patch_count qtlocation patches"

  if [ $qtlocation_patch_count != 0 ]
  then
    echo "Found $qtwebengine_patch_count qtlocation patches"

    echo "Cloning qtlocation so that patches can be applied with git"
    rm -r qtlocation
    git clone \
      --recurse-submodules \
      --single-branch \
      --depth 1 \
      --shallow-submodules \
      --filter=blob:none \
      https://github.com/qt/qtlocation.git -b v5.15.18-lts-lgpl qtlocation

    for patch_file in "${qtlocation_patches[@]}"; do
      echo "Applying $patch_file"
      git apply --verbose --ignore-whitespace $script_dir/patches/${patch_file}
    done
  fi

  qtwebengine_patch_count=${#qtwebengine_patches[@]}
  echo "Found $qtwebengine_patch_count qtwebengine patches"

  if [ $qtwebengine_patch_count != 0 ]
  then
    echo "Cloning qtwebengine so that patches can be applied with git"
    rm -r qtwebengine
    git clone \
      --recurse-submodules \
      --single-branch \
      --depth 1 \
      --shallow-submodules \
      --filter=blob:none \
      https://github.com/qt/qtwebengine.git -b v5.15.19-lts qtwebengine

    for patch_file in "${qtwebengine_patches[@]}"; do
      echo "Applying $patch_file"
      git apply --verbose --ignore-whitespace $script_dir/patches/${patch_file}
    done

  fi

  patch_count=${#patches[@]}
  echo "Found $patch_count patches"

  for patch_file in "${patches[@]}"; do
      echo "Applying $patch_file"
    git apply --verbose --ignore-whitespace $script_dir/patches/${patch_file}
  done

  popd

fi
cd $src_dir

export PATH=$deps_dir/python-cmake-buildsystem-install/bin:$PATH

# NOTE:  C++14 is needed to support QtWebEngine from chromium
./configure $qt_install_dir_options                           \
  -release -opensource -confirm-license \
  -c++std c++14 \
  -nomake examples \
  -nomake tests \
  -no-rpath \
  -silent \
  -openssl -I $deps_dir/openssl-$OPENSSL_VERSION/include           \
  ${qt_macos_options}                                         \
  -L $deps_dir/openssl-$OPENSSL_VERSION

if [[ -z $qt_targets ]]
then
  make -j $nbthreads
  make install
else
  for target in $qt_targets; do
    make $target -j $nbthreads
  done
fi

