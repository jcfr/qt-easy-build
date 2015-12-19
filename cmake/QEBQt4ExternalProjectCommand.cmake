#
# QEBQt4ExternalProjectCommands
#

set(usage
"This script is indented to be invoked specifying a `mode`:

  cmake [-DOPT=<value> [...]] -DMODE=<mode> -P ${CMAKE_CURRENT_LIST_FILE}

where `mode` is either configure or build.
")

# Describe parameters expected with each mode
set(configure_options QT_PLATFORM QT_BUILD_TYPE QT_BUILD_DIR OPENSSL_INCLUDE_DIR OPENSSL_LIBRARY_DIR)
set(build_options JOM_EXECUTABLE QT_BUILD_DIR)

# Check if all option associated with the given are set.
function(_check_mode_options mode)
  foreach(opt IN LISTS ${mode}_options)
    if("${opt}" STREQUAL "")
      message(FATAL_ERROR "Mode ${mode} expects option ${opt} to be specified.")
    endif()
  endforeach()
endfunction()

# Sanity checks
set(_has_mode FALSE)
set(_valid_modes "configure" "build" "install")
foreach(_mode IN LISTS _valid_modes)
  if(_mode STREQUAL "${MODE}")
    set(_has_mode TRUE)
  endif()
endforeach()

# If no mode is specified, display usage
if(NOT _has_mode)
  message(${usage})
  return()
endif()

if("${MODE}" STREQUAL "configure")

  #-----------------------------------------------------------------------------
  # Configure Qt
  #-----------------------------------------------------------------------------
  _check_mode_options(${MODE})

  set(msg "Configuring Qt")
  set(step_file "${QT_BUILD_DIR}.configure.ok")
  if(EXISTS ${step_file})
    message(STATUS "${msg} - already done")
    return()
  endif()
  message(STATUS "---------------------------------")
  message(STATUS "${msg}")

  execute_process(
    COMMAND ${QT_BUILD_DIR}/configure.exe
      -opensource -confirm-license
      -shared
      -platform ${QT_PLATFORM} -${QT_BUILD_TYPE}
      -webkit
      -openssl -I ${OPENSSL_INCLUDE_DIR} -L ${OPENSSL_LIBRARY_DIR}
      -nomake examples
      -nomake demos
    WORKING_DIRECTORY ${QT_BUILD_DIR}
    RESULT_VARIABLE result_var
    )
  if(result_var EQUAL 0)
    file(WRITE ${step_file} "")
    message(STATUS "${msg} - ok")
  else()
    message(FATAL_ERROR "Problem configuring Qt")
  endif()

elseif("${MODE}" STREQUAL "build")

  #-----------------------------------------------------------------------------
  # Build Qt
  #-----------------------------------------------------------------------------
  _check_mode_options(${MODE})

  set(msg "Building Qt")
  set(step_file "${QT_BUILD_DIR}.build.ok")
  if(EXISTS ${step_file})
    message(STATUS "${msg} - already done")
    return()
  endif()
  message(STATUS "---------------------------------")
  message(STATUS "${msg}")

  execute_process(
    COMMAND ${JOM_EXECUTABLE} -j4
    WORKING_DIRECTORY ${QT_BUILD_DIR}
    RESULT_VARIABLE result_var
    )
  if(result_var EQUAL 0)
    file(WRITE ${step_file} "")
    message(STATUS "${msg} - ok")
  else()
    message(FATAL_ERROR "Problem building Qt")
  endif()

endif()
