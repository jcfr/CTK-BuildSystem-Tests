PROJECT(CTKBSTESTSCore)
             
#
# See SRC_DIR/CMake/ctkbstestsMacroBuildQtLib.cmake for details
#

SET(KIT_export_directive "CTKBSTESTS_CORE_EXPORT")

# Additional directories to include
SET(KIT_include_directories
  )
  
# Source files
SET(KIT_SRCS
  ctkbstestsMyCore.cxx
  ctkbstestsMyCore.h
  )

# Headers that should run through moc
SET(KIT_MOC_SRCS
  )

# UI files
SET(KIT_UI_FORMS
)

# Resources
SET(KIT_resources
)

SET(KIT_target_libraries
  CTKCore
  )


ctkbstestsMacroBuildQtLib(
  NAME ${PROJECT_NAME}
  EXPORT_DIRECTIVE ${KIT_export_directive}
  INCLUDE_DIRECTORIES ${KIT_include_directories}
  SRCS ${KIT_SRCS}
  MOC_SRCS ${KIT_MOC_SRCS}
  UI_FORMS ${KIT_UI_FORMS}
  TARGET_LIBRARIES ${KIT_target_libraries}
  RESOURCES ${KIT_resources}
  LIBRARY_TYPE ${CTKBSTESTS_LIBRARY_MODE}
  )

# Plugins
#ADD_SUBDIRECTORY(Plugins)

# Testing
IF(BUILD_TESTING)
  #ADD_SUBDIRECTORY(Testing)
ENDIF(BUILD_TESTING)
