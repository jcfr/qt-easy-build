message(STATUS "---------------------------------")

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
if(NOT BITS MATCHES "^(32|64)$")
  message(FATAL_ERROR "BITS incorrectly set to [${BITS}].
Hint: '32' or '64' value is expected.")
endif()

# Set compiler name based on Qt platform
if(QT_PLATFORM STREQUAL "win32-msvc2012")
  set(_compiler_name "vs2012")
elseif(QT_PLATFORM STREQUAL "win32-msvc2010")
  set(_compiler_name "vs2010")
elseif(QT_PLATFORM STREQUAL "win32-msvc2008")
  set(_compiler_name "vs2008")
else()
  message(FATAL_ERROR "Specified QT_PLATFORM:${QT_PLATFORM} is not supported !")
endif()


if(QT_PLATFORM STREQUAL "win32-msvc2012")
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
endif()
set(QT_URL "http://packages.kitware.com/download/item/6174/qt-everywhere-opensource-src-4.8.6.zip")
set(QT_MD5 "61f7d0ebe900ed3fb64036cfdca55975")
string(TOLOWER ${CMAKE_BUILD_TYPE} qt_build_type)
string(SUBSTRING ${qt_build_type} 0 3 _short_build_type)
set(QT_BUILD_DIR "${DEST_DIR}/qt-4.8.6-${BITS}-${_compiler_name}-${_short_build_type}")

# Set OpenSSL variables
get_filename_component(_archive_name ${OPENSSL_URL} NAME)
set(OPENSSL_FILE ${DEST_DIR}/${_archive_name})
string(REGEX REPLACE "(\\.|=)(bz2|tar\\.gz|tgz|zip)$" "" _archive_basename "${_archive_name}")
set(OPENSSL_INSTALL_DIR ${DEST_DIR}/${_archive_basename})
set(OPENSSL_INCLUDE_DIR "${OPENSSL_INSTALL_DIR}/${CMAKE_BUILD_TYPE}/include")
set(OPENSSL_LIB_DIR "${OPENSSL_INSTALL_DIR}/${CMAKE_BUILD_TYPE}/lib")
message(STATUS "OPENSSL_INCLUDE_DIR: ${OPENSSL_INCLUDE_DIR}")
message(STATUS "OPENSSL_LIB_DIR: ${OPENSSL_LIB_DIR}")

# Set Qt variables
get_filename_component(_archive_name ${QT_URL} NAME)
set(QT_FILE "${DEST_DIR}/${_archive_name}")
message(STATUS "QT_BUILD_DIR: ${QT_BUILD_DIR}")
find_program(JOM_EXECUTABLE jom)
message(STATUS "JOM_EXECUTABLE:${JOM_EXECUTABLE}")

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

# Configure Qt
set(msg "Configuring Qt")
set(step_file "${QT_BUILD_DIR}.configure.ok")
message(STATUS "---------------------------------")
message(STATUS "${msg}")
if(NOT EXISTS ${step_file})
  execute_process(
    COMMAND ${QT_BUILD_DIR}/configure.exe
      -opensource -confirm-license
      -shared
      -platform ${QT_PLATFORM} -${qt_build_type}
      -webkit
      -openssl -I ${OPENSSL_INCLUDE_DIR} -L ${OPENSSL_LIB_DIR}
      -nomake examples
      -nomake demos
    WORKING_DIRECTORY ${QT_BUILD_DIR}
    RESULT_VARIABLE result_var
    )
  if(result_var EQUAL 0)
    file(WRITE ${step_file} "")
    message(STATUS "${msg} - ok")
  else()
    message(FATAL_ERROR "${msg} - error")
  endif()
else()
  message(STATUS "${msg} - already done")
endif()

# Build Qt
set(msg "Building Qt")
set(step_file "${QT_BUILD_DIR}.build.ok")
message(STATUS "---------------------------------")
message(STATUS "${msg}")
if(NOT EXISTS ${step_file})
  execute_process(
    COMMAND ${JOM_EXECUTABLE} -j4
    WORKING_DIRECTORY ${QT_BUILD_DIR}
    RESULT_VARIABLE result_var
    )
  if(result_var EQUAL 0)
    file(WRITE ${step_file} "")
    message(STATUS "${msg} - ok")
  else()
    message(FATAL_ERROR "${msg} - error")
  endif()
else()
  message(STATUS "${msg} - already done")
endif()
