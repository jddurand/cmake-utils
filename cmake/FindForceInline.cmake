# Inspired from /usr/share/autoconf/autoconf/c.m4
#
MACRO (FINDFORCEINLINE)
  GET_PROPERTY(source_dir_set GLOBAL PROPERTY MYPACKAGE_SOURCE_DIR SET)
  IF (NOT ${source_dir_set})
    MESSAGE (WARNING "Cannot check forceinline, property MYPACKAGE_SOURCE_DIR is not set")
  ELSE ()
    IF (NOT C_FORCEINLINE_SINGLETON)
      GET_PROPERTY(source_dir GLOBAL PROPERTY MYPACKAGE_SOURCE_DIR)
      SET (_C_FORCEINLINE_FOUND FALSE)
      FOREACH (KEYWORD "forceinline" "__forceinline__" "forceinline__" "__forceinline")
        MESSAGE(STATUS "Looking for ${KEYWORD}")
        TRY_COMPILE (C_HAS_${KEYWORD} ${CMAKE_CURRENT_BINARY_DIR}
          ${source_dir}/forceinline.c
          COMPILE_DEFINITIONS -DC_FORCEINLINE=${KEYWORD})
        IF (C_HAS_${KEYWORD})
          MESSAGE(STATUS "Looking for ${KEYWORD} - found")
          SET (_C_FORCEINLINE ${KEYWORD})
          SET (_C_FORCEINLINE_FOUND TRUE)
          BREAK ()
        ENDIF ()
      ENDFOREACH ()
    ENDIF ()
    IF (_C_FORCEINLINE_FOUND)
      SET (C_FORCEINLINE "${_C_FORCEINLINE}" CACHE STRING "C forceinline keyword")
      MARK_AS_ADVANCED (C_FORCEINLINE)
    ENDIF ()
    SET (C_FORCEINLINE_SINGLETON TRUE CACHE BOOL "C forceinline check singleton")
    MARK_AS_ADVANCED (C_FORCEINLINE_SINGLETON)
  ENDIF ()
ENDMACRO()
