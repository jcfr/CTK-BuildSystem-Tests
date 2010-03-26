
SET(test_scripts
  ConfigureAndBuildMyProjectUsingCTKSuperBuildTree.cmake
  )


FOREACH(script ${test_scripts})
  GET_FILENAME_COMPONENT(test_name ${script} NAME_WE)
  ADD_TEST(cmake_${test_name} ${CMAKE_COMMAND} 
    -DQT_QMAKE_EXECUTABLE:FILEPATH=${QT_QMAKE_EXECUTABLE}
    -DCTKBuildSystemTests_BINARY_DIR:PATH=${CTKBuildSystemTests_BINARY_DIR}
    -DCTKBuildSystemTests_SOURCE_DIR:PATH=${CTKBuildSystemTests_SOURCE_DIR}
    -P ${CMAKE_CURRENT_SOURCE_DIR}/${script}
    )
ENDFOREACH()

