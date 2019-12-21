MACRO (FINDISNAN)
  GET_PROPERTY(source_dir_set GLOBAL PROPERTY MYPACKAGE_SOURCE_DIR SET)
  IF (NOT ${source_dir_set})
    MESSAGE (WARNING "Cannot check inline, property MYPACKAGE_SOURCE_DIR is not set")
  ELSE ()
    IF (NOT C_ISNAN_SINGLETON)
      GET_PROPERTY(source_dir GLOBAL PROPERTY MYPACKAGE_SOURCE_DIR)
      SET (_C_ISNAN_FOUND FALSE)
      #
      # We depend on math.h
      #
      INCLUDE (CheckIncludeFile)
      CHECK_INCLUDE_FILE ("math.h" HAVE_MATH_H)
      IF (HAVE_MATH_H)
        SET (_HAVE_MATH_H 1)
      ELSE ()
        SET (_HAVE_MATH_H 0)
      ENDIF ()
      #
      # Test
      #
      FOREACH (KEYWORD "isnan" "_isnan" "__isnan")
        MESSAGE(STATUS "Looking for ${KEYWORD}")
        TRY_COMPILE (C_HAS_${KEYWORD} ${CMAKE_CURRENT_BINARY_DIR}
          ${source_dir}/isnan.c
          COMPILE_DEFINITIONS -DC_ISNAN=${KEYWORD} -DHAVE_MATH_H=${_HAVE_MATH_H})
        IF (C_HAS_${KEYWORD})
          MESSAGE(STATUS "Looking for ${KEYWORD} - found")
          SET (_C_ISNAN ${KEYWORD})
          SET (_C_ISNAN_FOUND TRUE)
          BREAK ()
        ENDIF ()
      ENDFOREACH ()
    ENDIF ()
    IF (_C_ISNAN_FOUND)
      SET (C_ISNAN "${_C_ISNAN}" CACHE STRING "C isnan implementation")
      MARK_AS_ADVANCED (C_ISNAN)
    ENDIF ()
    SET (C_ISNAN_SINGLETON TRUE CACHE BOOL "C isnan check singleton")
    MARK_AS_ADVANCED (C_ISNAN_SINGLETON)
  ENDIF ()
ENDMACRO()
