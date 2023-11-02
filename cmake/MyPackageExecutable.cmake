MACRO (MYPACKAGEEXECUTABLE name)
  IF (MYPACKAGE_DEBUG)
    FOREACH (_source ${ARGN})
      MESSAGE (STATUS "[${PROJECT_NAME}-EXECUTABLE-DEBUG] Source: ${_source}")
    ENDFOREACH ()
  ENDIF ()

  FOREACH (_name ${name} ${name}_static)
    IF (MYPACKAGE_DEBUG)
      MESSAGE (STATUS "[${PROJECT_NAME}-EXECUTABLE-DEBUG] Adding ${_name}")
    ENDIF ()
    LIST (APPEND ${PROJECT_NAME}_EXECUTABLE ${_name})
    ADD_EXECUTABLE (${_name} ${ARGN})
    IF (MYPACKAGE_DEBUG)
      MESSAGE (STATUS "[${PROJECT_NAME}-EXECUTABLE-DEBUG] SET_TARGET_PROPERTIES (${_name} PROPERTIES RUNTIME_OUTPUT_DIRECTORY ${LIBRARY_OUTPUT_PATH})")
    ENDIF ()
    SET_TARGET_PROPERTIES (${_name} PROPERTIES RUNTIME_OUTPUT_DIRECTORY ${LIBRARY_OUTPUT_PATH})
    INSTALL (
      TARGETS ${_name}
      EXPORT ${PROJECT_NAME}-targets
      RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
      COMPONENT ApplicationComponent
    )
    SET (${PROJECT_NAME}_HAVE_APPLICATIONCOMPONENT TRUE CACHE INTERNAL "Have ApplicationComponent" FORCE)
 
    IF (${_name} STREQUAL ${name})
      IF (TARGET ${PROJECT_NAME})
        IF (TARGET ${PROJECT_NAME}_shared)
          IF (MYPACKAGE_DEBUG)
            MESSAGE (STATUS "[${PROJECT_NAME}-EXECUTABLE-DEBUG] TARGET_LINK_LIBRARIES(${_name} PUBLIC ${PROJECT_NAME}_shared)")
          ENDIF ()
          TARGET_LINK_LIBRARIES(${_name} PUBLIC ${PROJECT_NAME}_shared)
        ELSE ()
          IF (MYPACKAGE_DEBUG)
            MESSAGE (STATUS "[${PROJECT_NAME}-EXECUTABLE-DEBUG] TARGET_LINK_LIBRARIES(${_name} INTERFACE ${PROJECT_NAME})")
          ENDIF ()
          TARGET_LINK_LIBRARIES(${_name} INTERFACE ${PROJECT_NAME})
        ENDIF ()
      ELSE ()
        #
        # Current project does not define a library
        #
        FOREACH (_include_directory ${CMAKE_CURRENT_BINARY_DIR}/output/include ${PROJECT_SOURCE_DIR}/include)
          IF (MYPACKAGE_DEBUG)
            MESSAGE (STATUS "[${PROJECT_NAME}-EXECUTABLE-DEBUG] TARGET_INCLUDE_DIRECTORIES(${_name} PUBLIC ${_include_directory})")
          ENDIF ()
	  TARGET_INCLUDE_DIRECTORIES(${_name} PUBLIC ${_include_directory})
        ENDFOREACH ()
      ENDIF ()
    ENDIF ()

    IF (${_name} STREQUAL ${name}_static)
      IF (TARGET ${PROJECT_NAME}_static)
        IF (MYPACKAGE_DEBUG)
          MESSAGE (STATUS "[${PROJECT_NAME}-EXECUTABLE-DEBUG] TARGET_LINK_LIBRARIES(${_name} PUBLIC ${PROJECT_NAME}_static)")
        ENDIF ()
        TARGET_LINK_LIBRARIES(${_name} PUBLIC ${PROJECT_NAME}_static)
      ELSE ()
        IF (MYPACKAGE_DEBUG)
          MESSAGE (STATUS "[${PROJECT_NAME}-EXECUTABLE-DEBUG] TARGET_COMPILE_DEFINITIONS(${_name} PUBLIC -D${PROJECT_NAME}_STATIC)")
        ENDIF ()
        TARGET_COMPILE_DEFINITIONS(${_name} PUBLIC -D${PROJECT_NAME}_STATIC)
        #
        # Current project does not define a static library
        #
        FOREACH (_include_directory ${CMAKE_CURRENT_BINARY_DIR}/output/include ${PROJECT_SOURCE_DIR}/include)
          IF (MYPACKAGE_DEBUG)
            MESSAGE (STATUS "[${PROJECT_NAME}-EXECUTABLE-DEBUG] TARGET_INCLUDE_DIRECTORIES(${_name} PUBLIC ${_include_directory})")
          ENDIF ()
	  TARGET_INCLUDE_DIRECTORIES(${_name} PUBLIC ${_include_directory})
        ENDFOREACH ()
      ENDIF ()
    ENDIF ()
  ENDFOREACH ()
ENDMACRO()
