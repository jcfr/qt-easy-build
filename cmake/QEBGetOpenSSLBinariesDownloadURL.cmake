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
# * qt_platform    : win32-msvc2013, win32-msvc2015 or win32-msvc2017
# * openssl_version: 1.0.2k
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
#  qeb_get_openssl_binaries_download_url(64 "win32-msvc2017" "1.0.2k" OPENSSL_URL OPENSSL_MD5)
#  message("OPENSSL_URL: ${OPENSSL_URL}")
#  message("OPENSSL_MD5: ${OPENSSL_MD5}")
#
# will display:
#
#  OPENSSL_URL: http://packages.kitware.com/download/bitstream/10378/OpenSSL_1_0_2k-install-msvc1910-64.tar.gz
#  OPENSSL_MD5: 8b49bb670f8b12444a502cd2e954f5d3
#
#
# Notes:
#
# OpenSSL archives are downloaded from http://packages.kitware.com and have been
# built using script https://gist.github.com/jamesobutler/f29a8edfe70cbdf7c3d94d25c20e1dce.
#
function(qeb_get_openssl_binaries_download_url bits qt_platform openssl_version url_var md5_var)

  set(_error_msg "No [$bits]-bit OpenSSL v${openssl_version} binaries available for qt_platform [$qt_platform]")

  # XXX If more than one version of OpenSSL should effectively be supported, the
  #     following code should be refactored.
  if(NOT openssl_version STREQUAL "1.0.2k")
    message(FATAL_ERROR "${_error_msg}")
  endif()

  if(QT_PLATFORM STREQUAL "win32-msvc2017")
    if(BITS EQUAL 64)
      set(OPENSSL_URL "http://packages.kitware.com/download/bitstream/10378/OpenSSL_1_0_2k-install-msvc1910-64.tar.gz")
      set(OPENSSL_MD5 "8b49bb670f8b12444a502cd2e954f5d3")
    else()
      set(OPENSSL_URL "http://packages.kitware.com/download/bitstream/10377/OpenSSL_1_0_2k-install-msvc1910-32.tar.gz")
      set(OPENSSL_MD5 "26de05c7743b4eddd3a36700e69b3f53")
    endif()
  elseif(QT_PLATFORM STREQUAL "win32-msvc2015")
    if(BITS EQUAL 64)
      set(OPENSSL_URL "http://packages.kitware.com/download/bitstream/10379/OpenSSL_1_0_2k-install-msvc1900-64.tar.gz")
      set(OPENSSL_MD5 "757e9e54dbf114074f4f625fba501112")
    else()
      set(OPENSSL_URL "http://packages.kitware.com/download/bitstream/10380/OpenSSL_1_0_2k-install-msvc1900-32.tar.gz")
      set(OPENSSL_MD5 "24f29cdb2e82e4a3f439dc46361ee5a1")
    endif()
  elseif(QT_PLATFORM STREQUAL "win32-msvc2013")
    if(BITS EQUAL 64)
      set(OPENSSL_URL "http://packages.kitware.com/download/bitstream/10381/OpenSSL_1_0_2k-install-msvc1800-64.tar.gz")
      set(OPENSSL_MD5 "969a28cb20407feb274a3eccdf0d1c40")
    else()
      set(OPENSSL_URL "http://packages.kitware.com/download/bitstream/10382/OpenSSL_1_0_2k-install-msvc1800-32.tar.gz")
      set(OPENSSL_MD5 "79c42146295b4dbfd4dbc53fff0b6fb3")
    endif()
  else()
    message(FATAL_ERROR "${_error_msg}")
  endif()
  set(${url_var} ${OPENSSL_URL} PARENT_SCOPE)
  set(${md5_var} ${OPENSSL_MD5} PARENT_SCOPE)
endfunction()
