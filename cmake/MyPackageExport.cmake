MACRO (MYPACKAGEEXPORT)

  IF (MYPACKAGE_DEBUG)
    MESSAGE (STATUS "[${PROJECT_NAME}-EXPORT-DEBUG] Creating target ${PROJECT_NAME}Export with export file ${INCLUDE_OUTPUT_PATH}/${PROJECT_NAME}/export.h")
  ENDIF ()
  INCLUDE (GenerateExportHeader)
  SET (_EXPORT_FILE_NAME "${INCLUDE_OUTPUT_PATH}/${PROJECT_NAME}/export.h")
  GENERATE_EXPORT_HEADER(${PROJECT_NAME}
    BASE_NAME ${PROJECT_NAME}
    EXPORT_MACRO_NAME ${PROJECT_NAME}_EXPORT
    EXPORT_FILE_NAME ${_EXPORT_FILE_NAME}
    STATIC_DEFINE ${PROJECT_NAME}_STATIC)
  #
  # We know this is a very bad practice, but I need to find a way to say
  # what is the calling convention, and this can be done only in export.h
  #
  FILE(APPEND ${_EXPORT_FILE_NAME} "\n")
  FILE(APPEND ${_EXPORT_FILE_NAME} "#ifndef ${PROJECT_NAME}_FASTCALL_H\n")
  FILE(APPEND ${_EXPORT_FILE_NAME} "#  define ${PROJECT_NAME}_FASTCALL_H\n")
  IF (C_FASTCALL)
    FILE(APPEND ${_EXPORT_FILE_NAME} "#  ifdef ${PROJECT_NAME}_STATIC\n")
    FILE(APPEND ${_EXPORT_FILE_NAME} "#    define ${PROJECT_NAME}_FASTCALL ${C_FASTCALL}\n")
    FILE(APPEND ${_EXPORT_FILE_NAME} "#  else\n")
    FILE(APPEND ${_EXPORT_FILE_NAME} "     /* No fastcall if not in a static library */\n")
    FILE(APPEND ${_EXPORT_FILE_NAME} "#    define ${PROJECT_NAME}_FASTCALL\n")
    FILE(APPEND ${_EXPORT_FILE_NAME} "#  endif\n")
  ELSE ()
    #
    # No fastcall -;
    #
    FILE(APPEND ${_EXPORT_FILE_NAME} "   /* fastcall is not available */\n")
    FILE(APPEND ${_EXPORT_FILE_NAME} "#  define ${PROJECT_NAME}_FASTCALL /* fastcall is not available */\n")
  ENDIF ()
  FILE(APPEND ${_EXPORT_FILE_NAME} "#endif /* ${PROJECT_NAME}_FASTCALL_H */\n")
  ADD_CUSTOM_TARGET(${PROJECT_NAME}Export SOURCES "${INCLUDE_OUTPUT_PATH}/${PROJECT_NAME}/export.h")
  INSTALL (FILES ${INCLUDE_OUTPUT_PATH}/${PROJECT_NAME}/export.h DESTINATION include/${PROJECT_NAME}/ COMPONENT HeaderComponent)
  SET (_HAVE_HEADERCOMPONENT TRUE CACHE INTERNAL "Have HeaderComponent" FORCE)
ENDMACRO()
