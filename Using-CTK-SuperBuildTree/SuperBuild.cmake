SET(cmake_version_required "2.8")
SET(cmake_version_required_dash "2-8")

CMAKE_MINIMUM_REQUIRED(VERSION ${cmake_version_required})

#-----------------------------------------------------------------------------
# Enable and setup External project global properties
#
INCLUDE(ExternalProject)

SET(ep_base "${CMAKE_BINARY_DIR}/CMakeExternals")
SET_PROPERTY(DIRECTORY PROPERTY EP_BASE ${ep_base})

SET(ep_install_dir ${ep_base}/Install)
SET(ep_build_dir ${ep_base}/Build)
SET(ep_source_dir ${ep_base}/Source)
#SET(ep_parallelism_level)
SET(ep_build_shared_libs ON)
SET(ep_build_testing OFF)

SET(ep_common_args
  -DCMAKE_INSTALL_PREFIX:PATH=${ep_install_dir}
  -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
  -DBUILD_TESTING:BOOL=${ep_build_testing}
  )

# Compute -G arg for configuring external projects with the same CMake generator:
IF(CMAKE_EXTRA_GENERATOR)
  SET(gen "${CMAKE_EXTRA_GENERATOR} - ${CMAKE_GENERATOR}")
ELSE()
  SET(gen "${CMAKE_GENERATOR}")
ENDIF()

# Use this value where semi-colons are needed in ep_add args:
set(sep "^^")

#-----------------------------------------------------------------------------
# Qt is expected to be setup by CTKBSTESTS/CMakeLists.txt just before it includes the SuperBuild script
#

#-----------------------------------------------------------------------------
# KWStyle
#
SET (kwstyle_DEPENDS)
IF (CTKBSTESTS_USE_KWSTYLE)
  IF (NOT DEFINED CTKBSTESTS_KWSTYLE_EXECUTABLE)
    SET(proj KWStyle-CVSHEAD)
    SET(kwstyle_DEPENDS ${proj})
    ExternalProject_Add(${proj}
      LIST_SEPARATOR ${sep}
      CVS_REPOSITORY ":pserver:anoncvs:@public.kitware.com:/cvsroot/KWStyle"
      CVS_MODULE "KWStyle"
      CMAKE_GENERATOR ${gen}
      CMAKE_ARGS
        ${ep_common_args}
      )
    SET(CTKBSTESTS_KWSTYLE_EXECUTABLE ${ep_install_dir}/bin/KWStyle)
  ENDIF()
ENDIF()

#-----------------------------------------------------------------------------
# CTK
#
set(proj ctk)
ExternalProject_Add(${proj}
  GIT_REPOSITORY "git@github.com:pieper/CTK.git"
  CMAKE_GENERATOR ${gen}
  CMAKE_ARGS
    -DCMAKE_CXX_FLAGS:STRING=${CMAKE_CXX_FLAGS}
    -DCMAKE_C_FLAGS:STRING=${CMAKE_C_FLAGS}
    -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
    -DBUILD_TESTING:BOOL=OFF
    -DQT_QMAKE_EXECUTABLE:FILEPATH=${QT_QMAKE_EXECUTABLE}
  INSTALL_COMMAND ""
  )

#-----------------------------------------------------------------------------
# CTKBSTESTS Utilities
#
set(proj CTKBSTESTS-Utilities)
ExternalProject_Add(${proj}
  DOWNLOAD_COMMAND ""
  CONFIGURE_COMMAND ""
  BUILD_COMMAND ""
  INSTALL_COMMAND ""
  DEPENDS
    ${kwstyle_DEPENDS}
    ctk
)

#-----------------------------------------------------------------------------
# Convenient macro allowing to define superbuild arg
#
MACRO(set_superbuild_boolean_arg cmake_var)
  SET(superbuild_${cmake_var} ON)
  IF(DEFINED ${cmake_var} AND NOT ${cmake_var})
    SET(superbuild_${cmake_var} OFF)
  ENDIF()
ENDMACRO()

#-----------------------------------------------------------------------------
# Set superbuild boolean args
#

SET(ctk_cmake_boolean_args
  BUILD_TESTING
  CTKBSTESTS_USE_KWSTYLE
  )

SET(superbuild_boolean_args)
FOREACH(cmake_arg ${cmake_boolean_args})
  set_superbuild_boolean_arg(${cmake_arg})
  LIST(APPEND superbuild_boolean_args -D${cmake_arg}:BOOL=${superbuild_${cmake_arg}})
ENDFOREACH()

#-----------------------------------------------------------------------------
# CTKBSTESTS Configure
#
SET(proj CTKBSTESTS-Configure)

ExternalProject_Add(${proj}
  DOWNLOAD_COMMAND ""
  CMAKE_GENERATOR ${gen}
  CMAKE_ARGS
    ${superbuild_boolean_args}
    -DCTKBSTESTS_SUPERBUILD:BOOL=OFF
    -DCMAKE_INSTALL_PREFIX:PATH=${ep_install_dir}
    -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
    -DQT_QMAKE_EXECUTABLE:FILEPATH=${QT_QMAKE_EXECUTABLE}
    -DCTKBSTESTS_KWSTYLE_EXECUTABLE:FILEPATH=${CTKBSTESTS_KWSTYLE_EXECUTABLE}
  SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}
  BINARY_DIR ${CMAKE_BINARY_DIR}/CTKBSTESTS-build
  BUILD_COMMAND ""
  INSTALL_COMMAND ""
  DEPENDS
    "CTKBSTESTS-Utilities"
  )

#-----------------------------------------------------------------------------
# CTKBSTESTS
#
set(proj CTKBSTESTS-build)
ExternalProject_Add(${proj}
  DOWNLOAD_COMMAND ""
  CMAKE_GENERATOR ${gen}
  SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}
  BINARY_DIR ${proj}
  #BUILD_COMMAND ""
  INSTALL_COMMAND ""
  DEPENDS
    "CTKBSTESTS-Configure"
  )

