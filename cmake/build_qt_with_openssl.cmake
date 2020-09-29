message(STATUS "---------------------------------")

# Include helper CMake modules
list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR})
include(QEBGetOpenSSLBinariesDownloadURL)

# Set default for value for script options
if(NOT DEFINED CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE "Release")
  message(STATUS "Setting build type to '${CMAKE_BUILD_TYPE}' as none was specified.")
endif()

# Sanity checks
if(NOT CMAKE_BUILD_TYPE MATCHES "^(Debug|Release)$")
  message(FATAL_ERROR "CMAKE_BUILD_TYPE incorrectly set to [${CMAKE_BUILD_TYPE}].
Hint: 'Release' or 'Debug' value is expected.")
endif()
if(NOT DEST_DIR)
  message(FATAL_ERROR "DEST_DIR has not been set !")
endif()
if(NOT QT_PLATFORM)
  message(FATAL_ERROR "QT_PLATFORM has not been set !")
endif()
if(NOT QT_VERSION)
  message(FATAL_ERROR "QT_VERSION has not been set !")
endif()
if(NOT BITS MATCHES "^(32|64)$")
  message(FATAL_ERROR "BITS incorrectly set to [${BITS}].
Hint: '32' or '64' value is expected.")
endif()
if(NOT EXISTS "${JOM_EXECUTABLE}")
    message(FATAL_ERROR "JOM_EXECUTABLE incorrectly set to an invalid path [${JOM_EXECUTABLE}]")
endif()
message(STATUS "JOM_EXECUTABLE:${JOM_EXECUTABLE}")

# Set compiler name
if(QT_PLATFORM STREQUAL "win32-msvc2017")
  set(_compiler_name "vs2017")
elseif(QT_PLATFORM STREQUAL "win32-msvc2015")
  set(_compiler_name "vs2015")
elseif(QT_PLATFORM STREQUAL "win32-msvc2013")
  set(_compiler_name "vs2013")
else()
  message(FATAL_ERROR "Unknown qtPlatform: [${QT_PLATFORM}]")
endif()


# Get OpenSSL binaries download URL and MD5
qeb_get_openssl_binaries_download_url(${BITS} ${QT_PLATFORM} "1.0.2k" OPENSSL_URL OPENSSL_MD5)

set(QT_URL "http://download.qt.io/official_releases/qt/${QT_MAJOR_VERSION}.${QT_MINOR_VERSION}/${QT_VERSION}/single/qt-everywhere-src-${QT_VERSION}.zip")
set(QT_MD5 "db6a623759cdf9399bac95802742e40b")
set(_version_string ${QT_VERSION})

string(TOLOWER ${CMAKE_BUILD_TYPE} qt_build_type)
string(SUBSTRING ${qt_build_type} 0 3 _short_build_type)
set(QT_BUILD_DIR "${DEST_DIR}/qt-${_version_string}-${BITS}-${_compiler_name}-${_short_build_type}")

# Set OpenSSL variables
get_filename_component(_archive_name ${OPENSSL_URL} NAME)
set(OPENSSL_FILE ${DEST_DIR}/${_archive_name})
string(REGEX REPLACE "(\\.|=)(bz2|tar\\.gz|tgz|zip)$" "" _archive_basename "${_archive_name}")
set(OPENSSL_INSTALL_DIR ${DEST_DIR}/${_archive_basename})
set(OPENSSL_INCLUDE_DIR "${OPENSSL_INSTALL_DIR}/${CMAKE_BUILD_TYPE}/include")
set(OPENSSL_LIBRARY_DIR "${OPENSSL_INSTALL_DIR}/${CMAKE_BUILD_TYPE}/lib")
message(STATUS "OPENSSL_INCLUDE_DIR: ${OPENSSL_INCLUDE_DIR}")
message(STATUS "OPENSSL_LIBRARY_DIR: ${OPENSSL_LIBRARY_DIR}")

# Set Qt variables
get_filename_component(_archive_name ${QT_URL} NAME)
set(QT_FILE "${DEST_DIR}/${_archive_name}")
message(STATUS "QT_BUILD_DIR: ${QT_BUILD_DIR}")

if(NOT EXISTS ${DEST_DIR})
  message(STATUS "making dir='${DEST_DIR}'")
  file(MAKE_DIRECTORY ${DEST_DIR})
endif()

function(_download_file remote local md5)
  message(STATUS "---------------------------------")
  set(msg "downloading...")
  set(step_file "${local}.download.ok")
  message(STATUS "downloading...\n  src='${remote}'\n  dst='${local}")
  if(NOT EXISTS ${step_file})
    file(DOWNLOAD "${remote}" "${local}" EXPECTED_MD5 ${md5}
      SHOW_PROGRESS
      STATUS status
      )
    list(GET status 0 error_code)
    list(GET status 1 error_msg)
    if(NOT error_code)
      file(WRITE ${step_file} "")
      message(STATUS "${msg} - ok")
    else()
      message(STATUS "${msg} - error")
    endif()
  else()
    message(STATUS "${msg} - already done")
  endif()
endfunction()

_download_file(${QT_URL} ${QT_FILE} ${QT_MD5})
_download_file(${OPENSSL_URL} ${OPENSSL_FILE} ${OPENSSL_MD5})

# Adapted from '_ep_write_extractfile_script' available in ExternalProject.cmake
function(_extract_archive filename directory)
  message(STATUS "---------------------------------")
  message(STATUS "extracting...\n  src='${filename}'\n  dst='${directory}'")
  if(NOT EXISTS "${filename}")
    message(FATAL_ERROR "error: file to extract does not exist: '${filename}'")
  endif()

  set(step_file "${directory}.extract.ok")

  if(EXISTS ${step_file})
    message(STATUS "extracting - already done")
    return()
  endif()

  # Prepare a space for extracting:
  get_filename_component(name ${filename} NAME)
  set(i 1234)
  while(EXISTS "${directory}/../ex-${name}${i}")
    math(EXPR i "${i} + 1")
  endwhile()
  set(ut_dir "${directory}/../ex-${name}${i}")
  file(MAKE_DIRECTORY "${ut_dir}")

  # Extract it:
  set(args "xfz")
  message(STATUS "extracting... [tar ${args}]")
  execute_process(COMMAND ${CMAKE_COMMAND} -E tar ${args} ${filename}
    WORKING_DIRECTORY ${ut_dir}
    RESULT_VARIABLE rv)

  if(NOT rv EQUAL 0)
    message(STATUS "extracting... [error clean up]")
    file(REMOVE_RECURSE "${ut_dir}")
    message(FATAL_ERROR "error: extract of '${filename}' failed")
  endif()

  # Analyze what came out of the tar file:
  message(STATUS "extracting... [analysis]")
  file(GLOB contents "${ut_dir}/*")
  list(LENGTH contents n)
  if(NOT n EQUAL 1 OR NOT IS_DIRECTORY "${contents}")
    set(contents "${ut_dir}")
  endif()

  # Move "the one" directory to the final directory:
  message(STATUS "extracting... [rename]")
  file(REMOVE_RECURSE ${directory})
  get_filename_component(contents ${contents} ABSOLUTE)
  file(RENAME ${contents} ${directory})

  # Clean up:
  message(STATUS "extracting... [clean up]")
  file(REMOVE_RECURSE "${ut_dir}")

  file(WRITE "${step_file}" "")
  message(STATUS "extracting... - done")
endfunction()

# Extract packages.
_extract_archive(${QT_FILE} ${QT_BUILD_DIR})
_extract_archive(${OPENSSL_FILE} ${OPENSSL_INSTALL_DIR})

# Options common to configure and build steps
set(common_options
  -DUSE_STEP_FILE=1
  )

# Configure Qt
execute_process(
  COMMAND ${CMAKE_COMMAND}
    -DMODE=configure
    ${common_options}
    -DQT_PLATFORM=${QT_PLATFORM}
    -DQT_BUILD_TYPE=${qt_build_type}
    -DOPENSSL_INCLUDE_DIR=${OPENSSL_INCLUDE_DIR}
    -DOPENSSL_LIBRARY_DIR=${OPENSSL_LIBRARY_DIR}
    -DQT_BUILD_DIR=${QT_BUILD_DIR}
    -P ${CMAKE_CURRENT_LIST_DIR}/QEBQt5ExternalProjectCommand.cmake
  RESULT_VARIABLE result_var
  )
if(NOT result_var EQUAL 0)
  message(FATAL_ERROR "")
endif()

# Build Qt
execute_process(
  COMMAND ${CMAKE_COMMAND}
    -DMODE=build
    ${common_options}
    -DQT_BUILD_DIR=${QT_BUILD_DIR}
    -DJOM_EXECUTABLE=${JOM_EXECUTABLE}
    -P ${CMAKE_CURRENT_LIST_DIR}/QEBQt5ExternalProjectCommand.cmake
  RESULT_VARIABLE result_var
  )
if(NOT result_var EQUAL 0)
  message(FATAL_ERROR "")
endif()
