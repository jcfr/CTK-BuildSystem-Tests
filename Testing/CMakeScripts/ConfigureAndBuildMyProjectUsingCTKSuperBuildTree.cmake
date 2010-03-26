#
# 
#

SET(bin_dir ${CTKBuildSystemTests_BINARY_DIR}/Using-CTK-SuperBuildTree)
SET(src_dir ${CTKBuildSystemTests_SOURCE_DIR}/Using-CTK-SuperBuildTree)

EXECUTE_PROCESS(
  COMMAND ${CMAKE_COMMAND} -E make_directory ${bin_dir}
  RESULT_VARIABLE error_code
  )
IF(error_code)
  MESSAGE(FATAL_ERROR "error: Failed to create directory ${bin_dir}")
ENDIF()

# Write initial cache.
file(WRITE "${bin_dir}/CMakeCache.txt" "
QT_QMAKE_EXECUTABLE:FILEPATH=${QT_QMAKE_EXECUTABLE}
")

EXECUTE_PROCESS(
  COMMAND ${CMAKE_COMMAND} ${src_dir}
  WORKING_DIRECTORY ${bin_dir}
  RESULT_VARIABLE error_code
  OUTPUT_QUIET
  )
IF(error_code)
  MESSAGE(FATAL_ERROR "error: Failed to configure project ${src_dir}")
ENDIF()

EXECUTE_PROCESS(
  COMMAND ${CMAKE_COMMAND} --build ${bin_dir}
  WORKING_DIRECTORY ${bin_dir}
  RESULT_VARIABLE error_code
  )
IF(error_code)
  MESSAGE(FATAL_ERROR "error: Failed to build project ${src_dir}")
ENDIF()

