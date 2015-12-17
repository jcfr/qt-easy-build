
#
# qeb_get_openssl_binaries_download_url(bits qt_platform url_var md5_var)
#
# Given `bits`, `qt_platform` this function will respectively set variables
# identified by `url_var` and `md5_var` to the OpenSSL binaries download URL
# and MD5.
#
#
# Acceptable input values:
#
# * bits           : 32 or 64
# * qt_platform    : win32-msvc2008, win32-msvc2010, win32-msvc2012 or win32-msvc2013
# * openssl_version: 1.0.1h
#
#
# Archive layout:
#
# The downloaded archive will contain both Debug and Release <config> for
# OpenSSL executable and shared libraries and has the following organization:
#
# <root>/<config>/bin/libeay32.dll
# <root>/<config>/bin/openssl.exe
# <root>/<config>/bin/ssleay32.dll
# <root>/<config>/include/openssl/aes.h
# [...]
# <root>/<config>/include/openssl/x509v3.h
# <root>/<config>/lib/engines/4758cca.dll
# [...]
# <root>/<config>/lib/engines/ubsec.dll
# <root>/<config>/lib/libeay32.lib
# <root>/<config>/lib/ssleay32.lib
# <root>/<config>/ssl/openssl.cnf
#
#
# Usage:
#
# For example, calling the following:
#
#  qeb_get_openssl_binaries_download_url(64 "win32-msvc2008" "1.0.1h" OPENSSL_URL OPENSSL_MD5)
#  message("OPENSSL_URL: ${OPENSSL_URL}")
#  message("OPENSSL_MD5: ${OPENSSL_MD5}")
#
# will display:
#
#  OPENSSL_URL: http://packages.kitware.com/download/item/6090/OpenSSL_1_0_1h-install-msvc1500-64.tar.gz
#  OPENSSL_MD5: dab0c026ab56fd0fbfe2843d14218fad
#
#
# Notes:
#
# OpenSSL archives are downloaded from http://packages.kitware.com and have been
# built using script https://gist.github.com/jcfr/6030240.
#
function(qeb_get_openssl_binaries_download_url bits qt_platform openssl_version url_var md5_var)

  set(_error_msg "No [$bits]-bit OpenSSL v${openssl_version} binaries available for qt_platform [$qt_platform]")

  # XXX If more than one version of OpenSSL should effectively be supported, the
  #     following code should be refactored.
  if(NOT openssl_version STREQUAL "1.0.1h")
    message(FATAL_ERROR "${_error_msg}")
  endif()

  if(QT_PLATFORM STREQUAL "win32-msvc2013")
    if(BITS EQUAL 64)
      set(OPENSSL_URL "http://packages.kitware.com/download/bitstream/8915/OpenSSL_1_0_1h-install-msvc1800-64.tar.gz")
      set(OPENSSL_MD5 "7aefdd94babefbe603cca48ff86da768")
    else()
      set(OPENSSL_URL "http://packages.kitware.com/download/bitstream/8918/OpenSSL_1_0_1h-install-msvc1800-32.tar.gz")
      set(OPENSSL_MD5 "f10ceb422ab37f2b0bd5e225c74fd1d4")
    endif()
  elseif(QT_PLATFORM STREQUAL "win32-msvc2012")
    if(BITS EQUAL 64)
      set(OPENSSL_URL "http://packages.kitware.com/download/item/6099/OpenSSL_1_0_1h-install-msvc1600-64.tar.gz")
      set(OPENSSL_MD5 "b54a0a4b396397fdf96e55f0f7345dd1")
    else()
      set(OPENSSL_URL "http://packages.kitware.com/download/item/6096/OpenSSL_1_0_1h-install-msvc1600-32.tar.gz")
      set(OPENSSL_MD5 "e80269ae7969276977a342cccc1df5c5")
    endif()
  elseif(QT_PLATFORM STREQUAL "win32-msvc2010")
    if(BITS EQUAL 64)
      set(OPENSSL_URL "http://packages.kitware.com/download/item/6099/OpenSSL_1_0_1h-install-msvc1600-64.tar.gz")
      set(OPENSSL_MD5 "b54a0a4b396397fdf96e55f0f7345dd1")
    else()
      set(OPENSSL_URL "http://packages.kitware.com/download/item/6096/OpenSSL_1_0_1h-install-msvc1600-32.tar.gz")
      set(OPENSSL_MD5 "e80269ae7969276977a342cccc1df5c5")
    endif()
  elseif(QT_PLATFORM STREQUAL "win32-msvc2008")
    if(BITS EQUAL 64)
      set(OPENSSL_URL "http://packages.kitware.com/download/item/6090/OpenSSL_1_0_1h-install-msvc1500-64.tar.gz")
      set(OPENSSL_MD5 "dab0c026ab56fd0fbfe2843d14218fad")
    else()
      set(OPENSSL_URL "http://packages.kitware.com/download/item/6093/OpenSSL_1_0_1h-install-msvc1500-32.tar.gz")
      set(OPENSSL_MD5 "8b110bb48063223c3b9f3a99f1fa9067")
    endif()
  else()
    message(FATAL_ERROR "${_error_msg}")
  endif()
  set(${url_var} ${OPENSSL_URL} PARENT_SCOPE)
  set(${md5_var} ${OPENSSL_MD5} PARENT_SCOPE)
endfunction()
