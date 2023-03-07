MACRO (MYPACKAGECMAKEEXPORT)
  SET (_export_targets ${PROJECT_NAME}-targets)
  SET (_namespace ${PROJECT_NAME}::)
  IF (MYPACKAGE_DEBUG)
    MESSAGE(STATUS "[${PROJECT_NAME}-CMAKEEXPORT-DEBUG] Exporting ${_export_targets}")
  ENDIF ()
  SET (TARGET_CMAKE_IN ${CMAKE_CURRENT_BINARY_DIR}/${_export_targets}.cmake.in)
  IF (MYPACKAGE_DEBUG)
    MESSAGE (STATUS "[${PROJECT_NAME}-CMAKEEXPORT-DEBUG] Generating ${TARGET_CMAKE_IN}")
  ENDIF ()
  SET (_target_cmake_in [[
@PACKAGE_INIT@

]])
  #
  # Explicit public dependencies
  #
  FOREACH (_public_dependency ${${PROJECT_NAME}_public_dependencies})
    STRING (APPEND _target_cmake_in "find_package(${_public_dependency} REQUIRED)")
    STRING (APPEND _target_cmake_in [[

]])
  ENDFOREACH ()
  STRING (APPEND _target_cmake_in "include(\"\${CMAKE_CURRENT_LIST_DIR}/${_export_targets}.cmake\"\)")
  STRING (APPEND _target_cmake_in [[

]])
  FILE (WRITE ${TARGET_CMAKE_IN} ${_target_cmake_in})
  install(EXPORT ${_export_targets}
          NAMESPACE ${_namespace}
          DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/${PROJET_NAME}
          COMPONENT Devel)
  INCLUDE (CMakePackageConfigHelpers)
  CONFIGURE_PACKAGE_CONFIG_FILE(${TARGET_CMAKE_IN}
    ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}Config.cmake
    INSTALL_DESTINATION lib/cmake/${PROJET_NAME}
    NO_SET_AND_CHECK_MACRO
    NO_CHECK_REQUIRED_COMPONENTS_MACRO
  )
  WRITE_BASIC_PACKAGE_VERSION_FILE (
    ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}ConfigVersion.cmake
    VERSION "${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}"
   COMPATIBILITY AnyNewerVersion
  )
  INSTALL (FILES
    ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}Config.cmake
    ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}ConfigVersion.cmake
    DESTINATION lib/cmake/${PROJET_NAME}
  )
  FILE (REMOVE ${TARGET_CMAKE_IN} ${_target_cmake_in})
ENDMACRO()
