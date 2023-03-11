MACRO (MYPACKAGEEXPORT)

  SET (_export_h ${INCLUDE_OUTPUT_PATH}/${PROJECT_NAME}/export.h)
  IF (MYPACKAGE_DEBUG)
    MESSAGE (STATUS "[${PROJECT_NAME}-EXPORT-DEBUG] Creating target ${PROJECT_NAME}_export with export file ${_export_h}")
  ENDIF ()
  INCLUDE (GenerateExportHeader)
  GENERATE_EXPORT_HEADER(${PROJECT_NAME}
    BASE_NAME ${PROJECT_NAME}
    EXPORT_MACRO_NAME ${PROJECT_NAME}_EXPORT
    EXPORT_FILE_NAME ${_export_h}
    STATIC_DEFINE ${PROJECT_NAME}_STATIC)
  ADD_CUSTOM_TARGET(${PROJECT_NAME}_export SOURCES ${_export_h})
  INSTALL (FILES ${INCLUDE_OUTPUT_PATH}/${PROJECT_NAME}/export.h DESTINATION include/${PROJECT_NAME}/ COMPONENT HeaderComponent)
  SET (${PROJECT_NAME}_HAVE_HEADERCOMPONENT TRUE CACHE INTERNAL "Have HeaderComponent" FORCE)

ENDMACRO()
