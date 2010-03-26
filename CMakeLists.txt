CMAKE_MINIMUM_REQUIRED(VERSION 2.8)

FOREACH(policy CMP0003)
  IF(POLICY ${policy})
    CMAKE_POLICY(SET ${policy} NEW)
  ENDIF()
ENDFOREACH()

PROJECT(CTKBuildSystemTests)

#-----------------------------------------------------------------------------
# QT
#
SET(minimum_required_qt_version "4.6")
 
FIND_PACKAGE(Qt4)

IF(QT4_FOUND)
  IF(NOT "${QT_VERSION_MAJOR}.${QT_VERSION_MINOR}" STREQUAL "${minimum_required_qt_version}")
    MESSAGE(FATAL_ERROR "error: ${PROJECT_NAME} requires Qt >= ${minimum_required_qt_version} -- you cannot use Qt ${QT_VERSION_MAJOR}.${QT_VERSION_MINOR}.${QT_VERSION_PATCH}.")
  ENDIF()

  SET(QT_USE_QTNETWORK ON)
  INCLUDE(${QT_USE_FILE})

ELSE()
  MESSAGE(FATAL_ERROR "error: Qt4 was not found on your system. You probably need to set the QT_QMAKE_EXECUTABLE variable")
ENDIF()

#-----------------------------------------------------------------------------
# Configure Testing
#
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

#-----------------------------------------------------------------------------
# Testing
#
ADD_SUBDIRECTORY(Testing)

