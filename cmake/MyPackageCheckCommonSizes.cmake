MACRO (MYPACKAGECHECKCOMMONSIZES)
  INCLUDE (CheckIncludeFile)
  INCLUDE (CheckTypeSize)

  SET (CMAKE_EXTRA_INCLUDE_FILES_BACKUP ${CMAKE_EXTRA_INCLUDE_FILES}) # backup
  SET (CMAKE_EXTRA_INCLUDE_FILES) # reset
  CHECK_INCLUDE_FILE ("stdint.h"       HAVE_STDINT_H)
  IF (HAVE_STDINT_H)
    LIST (APPEND CMAKE_EXTRA_INCLUDE_FILES "stdint.h")
  ENDIF ()
  CHECK_INCLUDE_FILE ("inttypes.h"     HAVE_INTTYPES_H)
  IF (HAVE_INTTYPES_H)
    LIST (APPEND CMAKE_EXTRA_INCLUDE_FILES "inttypes.h")
  ENDIF ()
  CHECK_INCLUDE_FILE ("sys/inttypes.h" HAVE_SYS_INTTYPES_H)
  IF (HAVE_SYS_INTTYPES_H)
    LIST (APPEND CMAKE_EXTRA_INCLUDE_FILES "sys/inttypes.h")
  ENDIF ()

  CHECK_TYPE_SIZE("char" SIZEOF_CHAR)
  CHECK_TYPE_SIZE("short" SIZEOF_SHORT)
  CHECK_TYPE_SIZE("int" SIZEOF_INT)
  CHECK_TYPE_SIZE("long" SIZEOF_LONG)
  CHECK_TYPE_SIZE("long long" SIZEOF_LONG_LONG)
  CHECK_TYPE_SIZE("float" SIZEOF_FLOAT)
  CHECK_TYPE_SIZE("double" SIZEOF_DOUBLE)
  CHECK_TYPE_SIZE("long double" SIZEOF_LONG_DOUBLE)
  CHECK_TYPE_SIZE("unsigned char" SIZEOF_UNSIGNED_CHAR)
  CHECK_TYPE_SIZE("unsigned short" SIZEOF_UNSIGNED_SHORT)
  CHECK_TYPE_SIZE("unsigned int" SIZEOF_UNSIGNED_INT)
  CHECK_TYPE_SIZE("unsigned long" SIZEOF_UNSIGNED_LONG)
  CHECK_TYPE_SIZE("unsigned long long" SIZEOF_UNSIGNED_LONG_LONG)
  CHECK_TYPE_SIZE("size_t" SIZEOF_SIZE_T)
  CHECK_TYPE_SIZE("void *" SIZEOF_VOID_STAR)
  #
  # Special types
  #
  FOREACH (_sign "" "u")
    #
    # Remember that CHAR_BIT minimum value is 8 -;
    #
    FOREACH (_size 8 16 32 64)
      MATH(EXPR  _sizeof "${_size} / ${C_CHAR_BIT}")
      SET (_ctype    ${_sign}int${_size}_t)
      STRING (TOUPPER ${_ctype} _CTYPE)
      SET (_mytype    MYPACKAGE_${_sign}int${_size})
      STRING (TOUPPER ${_mytype} _MYTYPE)
      SET (_MYTYPEDEF ${_MYTYPE}_TYPEDEF)

      SET (HAVE_${_MYTYPE} FALSE)
      SET (${_MYTYPE} "")
      SET (${_MYTYPEDEF} "")

      SET (_found_type FALSE)
      FOREACH (_underscore "" "_" "__")
        SET (_type ${_underscore}${_sign}int${_size}_t)
        STRING (TOUPPER ${_type} _TYPE)
        CHECK_TYPE_SIZE (${_type} ${_TYPE})
        IF (HAVE_${_TYPE})
          SET (HAVE_${_MYTYPE} TRUE)
          SET (SIZEOF_${_MYTYPE} ${${_TYPE}})
          SET (${_MYTYPEDEF} ${_type})
          IF (${_type} STREQUAL ${_ctype})
            SET (HAVE_${_CTYPE} TRUE)
          ELSE ()
            SET (HAVE_${_CTYPE} FALSE)
          ENDIF ()
          BREAK ()
        ENDIF ()
      ENDFOREACH ()
      # IF (NOT HAVE_${_MYTYPE})
      IF (TRUE)
        #
        # Try with C types
        #
        FOREACH (_c "char" "short" "int" "long" "long long")
          IF ("${_sign}" STREQUAL "u")
            SET (_c "unsigned ${_c}")
          ENDIF ()
          STRING (TOUPPER ${_c} _C)
          STRING (REPLACE " " "_" _C "${_C}")
          IF (HAVE_SIZEOF_${_C})
            IF (${SIZEOF_${_C}} EQUAL ${_sizeof})
              SET (HAVE_${_MYTYPE} TRUE)
              SET (SIZEOF_${_MYTYPE} ${${_TYPE}})
              SET (${_MYTYPEDEF} ${_c})
              BREAK ()
            ENDIF ()
          ENDIF ()
        ENDFOREACH ()
      ENDIF ()
      MARK_AS_ADVANCED (
        HAVE_${_MYTYPE}
        SIZEOF_${_MYTYPE}
        HAVE_${_CTYPE}
        ${_MYTYPEDEF})
    ENDFOREACH ()
  ENDFOREACH ()

  SET (CMAKE_EXTRA_INCLUDE_FILES ${CMAKE_EXTRA_INCLUDE_FILES_BACKUP}) # restore
ENDMACRO()
