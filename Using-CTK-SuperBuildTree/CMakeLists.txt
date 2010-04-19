CMAKE_MINIMUM_REQUIRED(VERSION 2.8)

FOREACH(policy CMP0003)
  IF(POLICY ${policy})
    CMAKE_POLICY(SET ${policy} NEW)
  ENDIF()
ENDFOREACH()

PROJECT(CTKBSTESTS)

#-----------------------------------------------------------------------------
# Output directories.
#
IF(NOT LIBRARY_OUTPUT_PATH)
  SET(LIBRARY_OUTPUT_PATH ${CTKBSTESTS_BINARY_DIR}/bin CACHE INTERNAL "Single output directory for building all libraries.")
ENDIF(NOT LIBRARY_OUTPUT_PATH)
IF(NOT EXECUTABLE_OUTPUT_PATH)
  SET(EXECUTABLE_OUTPUT_PATH ${CTKBSTESTS_BINARY_DIR}/bin CACHE INTERNAL "Single output directory for building all executables.")
ENDIF(NOT EXECUTABLE_OUTPUT_PATH)
SET(CTKBSTESTS_LIBRARY_PATH ${LIBRARY_OUTPUT_PATH}/${CMAKE_CFG_INTDIR})
SET(CTKBSTESTS_EXECUTABLE_PATH ${EXECUTABLE_OUTPUT_PATH}/${CMAKE_CFG_INTDIR})

#-----------------------------------------------------------------------------
# Install directories, used for install rules.
#
SET(CTKBSTESTS_INSTALL_BIN_DIR "bin")
SET(CTKBSTESTS_INSTALL_LIB_DIR "lib")
SET(CTKBSTESTS_INSTALL_INCLUDE_DIR "include")
SET(CTKBSTESTS_INSTALL_DOC_DIR "doc")

#-----------------------------------------------------------------------------
# Update CMake module path
# Note: FindXXX.cmake script specific to utility should be copied into Utilities/CMake
#
SET(CMAKE_MODULE_PATH
#  "${CMAKE_CURRENT_SOURCE_DIR}/Utilities/CMake"
  "${CMAKE_CURRENT_SOURCE_DIR}/CMake"
  "${CMAKE_CURRENT_BINARY_DIR}/CMake"
  ${CMAKE_MODULE_PATH})

#-----------------------------------------------------------------------------
# Clear CTKBSTESTS_BASE_INCLUDE_DIRS and CTKBSTESTS_BASE_LIBRARIES
#
SET(CTKBSTESTS_BASE_LIBRARIES CACHE INTERNAL "CTKBSTESTS libraries" FORCE)
SET(CTKBSTESTS_BASE_INCLUDE_DIRS CACHE INTERNAL "CTKBSTESTS includes" FORCE)

#-----------------------------------------------------------------------------
# CMake Macro(s)
#
INCLUDE(CMake/ctkbstestsMacroParseArguments.cmake)
INCLUDE(CMake/ctkbstestsMacroBuildQtLib.cmake)

#-----------------------------------------------------------------------------
# Testing
#
OPTION(BUILD_TESTING "Test the project" ON)
IF(BUILD_TESTING)
  ENABLE_TESTING()
  INCLUDE(CTest)
  SET(CXX_TEST_PATH ${EXECUTABLE_OUTPUT_PATH})
  MARK_AS_ADVANCED(TCL_TCLSH DART_ROOT)
    
  # Setup file for setting custom ctest vars
  CONFIGURE_FILE(
    CMake/CTestCustom.cmake.in
    ${CMAKE_CURRENT_BINARY_DIR}/CTestCustom.cmake
    @ONLY
    )

  # Configuration for the CMake-generated test driver
  SET(CMAKE_TESTDRIVER_EXTRA_INCLUDES "#include <stdexcept>")
  SET(CMAKE_TESTDRIVER_BEFORE_TESTMAIN "
    try
      {")
  SET(CMAKE_TESTDRIVER_AFTER_TESTMAIN "    }
      catch( std::exception & excp )
        {
        fprintf(stderr,\"%s\\n\",excp.what());
        return EXIT_FAILURE;
        }
      catch( ... )
        {
        printf(\"Exception caught in the test driver\\n\");
        return EXIT_FAILURE;
        }
      ")
ENDIF()

#-----------------------------------------------------------------------------
# To make options show up in both CTKBSTESTS-SuperBuild and CTKBSTESTS regular build, let's add them
# before the SuperBuild script is included
#

# Let's mark as advanced some default properties
MARK_AS_ADVANCED(CMAKE_INSTALL_PREFIX)
MARK_AS_ADVANCED(DART_TESTING_TIMEOUT)

# KWStyle
#OPTION(CTK_USE_KWSTYLE     "Enable sourcecode-based style tests." OFF)
#MARK_AS_ADVANCED(CTK_USE_KWSTYLE)

#-----------------------------------------------------------------------------
# Convenient macro allowing to download a file
#
MACRO(downloadFile url dest)
  FILE(DOWNLOAD ${url} ${dest} STATUS status)
  LIST(GET status 0 error_code)
  LIST(GET status 1 error_msg)
  IF(error_code)
    MESSAGE(FATAL_ERROR "error: Failed to download ${url} - ${error_msg}")
  ENDIF()
ENDMACRO()

#-----------------------------------------------------------------------------
# Prerequisites
#
set(git_repo http://github.com/pieper/CTK/raw/master/)

set(file CMake/ExternalProject.cmake)
downloadFile(${git_repo}/${file} ${CTKBSTESTS_BINARY_DIR}/${file})

set(file Utilities/CMake/FindCTK.cmake)
downloadFile(${git_repo}/${file} ${CTKBSTESTS_BINARY_DIR}/CMake/FindCTK.cmake)

#-----------------------------------------------------------------------------
# QT
#
SET(minimum_required_qt_version "4.6")
 
FIND_PACKAGE(Qt4)
# This option won't show up in the main CMake configure panel
MARK_AS_ADVANCED(QT_QMAKE_EXECUTABLE)

IF(QT4_FOUND)
  IF(NOT "${QT_VERSION_MAJOR}.${QT_VERSION_MINOR}" STREQUAL "${minimum_required_qt_version}")
    MESSAGE(FATAL_ERROR "error: ${PROJECT_NAME} requires Qt >= ${minimum_required_qt_version} -- you cannot use Qt ${QT_VERSION_MAJOR}.${QT_VERSION_MINOR}.${QT_VERSION_PATCH}.")
  ENDIF()

  SET(QT_USE_QTNETWORK ON)
  INCLUDE(${QT_USE_FILE})

  #SET(CTK_BASE_LIBRARIES ${CTK_BASE_LIBRARIES} ${QT_LIBRARIES} CACHE INTERNAL "CTK libraries" FORCE)
  #SET(CTK_QMAKE_EXECUTABLE ${QT_QMAKE_EXECUTABLE})
ELSE()
  MESSAGE(FATAL_ERROR "error: Qt4 was not found on your system. You probably need to set the QT_QMAKE_EXECUTABLE variable")
ENDIF()

# Update CTKBSTESTS_BASE_LIBRARIES with QT libraries
IF(QT4_FOUND)
  SET(CTKBSTESTS_BASE_LIBRARIES ${CTKBSTESTS_BASE_LIBRARIES} ${QT_LIBRARIES} CACHE INTERNAL "CTKBSTESTS libraries" FORCE)
ENDIF()

#-----------------------------------------------------------------------------
# Superbuild is used by default
#
OPTION(CTKBSTESTS_SUPERBUILD "Build CTKBSTESTS and the projects it depends on via SuperBuild.cmake." ON)
MARK_AS_ADVANCED(CTKBSTESTS_SUPERBUILD)

IF(CTKBSTESTS_SUPERBUILD)
  INCLUDE("${CMAKE_CURRENT_SOURCE_DIR}/SuperBuild.cmake")
  RETURN()
ENDIF()

#-----------------------------------------------------------------------------
# CTK
#
FIND_PACKAGE(CTK REQUIRED)

IF(CTK_FOUND)
  INCLUDE(${CTK_USE_FILE})
  
  # Update CTKBSTESTS_BASE_LIBRARIES with CTK libraries
  SET(CTKBSTESTS_BASE_LIBRARIES ${CTKBSTESTS_BASE_LIBRARIES} ${CTK_LIBRARIES} CACHE INTERNAL "CTKBSTESTS libraries" FORCE)
ENDIF()

#-----------------------------------------------------------------------------
# Add subdirectories
#
ADD_SUBDIRECTORY(Base)

#-----------------------------------------------------------------------------
# Style Checking configuration
#
#INCLUDE(Utilities/KWStyle/KWStyle.cmake)

