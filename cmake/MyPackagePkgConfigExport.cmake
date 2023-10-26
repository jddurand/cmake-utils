cmake_minimum_required(VERSION 3.15 FATAL_ERROR) # For list(PREPEND ...)
#
# Based on https://stackoverflow.com/questions/44292462/how-to-auto-generate-pkgconfig-files-from-cmake-targets
#
function(auto_pc TARGET)
  IF (MYPACKAGE_DEBUG)
    MESSAGE (STATUS "[${PROJECT_NAME}-PKGCONFIG-DEBUG] Running on target ${TARGET}")
  ENDIF ()

  set(_package_dependencies ${${TARGET}_package_dependencies})
  file(CONFIGURE OUTPUT "pc.${TARGET}/CMakeLists.txt"
       CONTENT [[
cmake_minimum_required(VERSION 3.16)
project(pc_@TARGET@)

message(STATUS "[pc.@TARGET@/CMakeLists.txt] Starting")

message(STATUS "[pc.@TARGET@/CMakeLists.txt] Initializing CMAKE_PREFIX_PATH with: $ENV{CMAKE_MODULE_ROOT_PATH}/@TARGET@")
set(CMAKE_PREFIX_PATH "$ENV{CMAKE_MODULE_ROOT_PATH}/@TARGET@")
foreach(_package_dependency @_package_dependencies@)
  message(STATUS "[pc.@TARGET@/CMakeLists.txt] Appending CMAKE_PREFIX_PATH with: $ENV{CMAKE_MODULE_ROOT_PATH}/${_package_dependency}")
  list(APPEND CMAKE_PREFIX_PATH "$ENV{CMAKE_MODULE_ROOT_PATH}/${_package_dependency}")
endforeach()

message(STATUS "[pc.@TARGET@/CMakeLists.txt] Requiring @TARGET@")
find_package(@TARGET@ REQUIRED)
message(STATUS "[pc.@TARGET@/CMakeLists.txt] @TARGET@ Version: ${@TARGET@_VERSION}")
message(STATUS "[pc.@TARGET@/CMakeLists.txt] @TARGET@ Package dependencies: ${@TARGET@_PACKAGE_DEPENDENCIES}")
set(_target_computed_package_dependencies)
FOREACH(_package_dependency ${@TARGET@_PACKAGE_DEPENDENCIES})
  message(STATUS "[pc.@TARGET@/CMakeLists.txt] @TARGET@ Package dependency: ${_package_dependency}, Version: ${@TARGET@_PACKAGE_DEPENDENCY_${_package_dependency}_VERSION}")
  list(APPEND _target_computed_package_dependencies "${_package_dependency} = ${@TARGET@_PACKAGE_DEPENDENCY_${_package_dependency}_VERSION}")
ENDFOREACH()
if(_target_computed_package_dependencies)
  SET_TARGET_PROPERTIES(@TARGET@::@TARGET@ PROPERTIES COMPUTED_PACKAGE_DEPENDENCIES ${_target_computed_package_dependencies})
endif()
#
# I do not know why $<IF:$<BOOL:$<TARGET_PROPERTY:INTERFACE_LINK_LIBRARIES>>,$<JOIN:$<LIST:TRANSFORM,$<TARGET_PROPERTY:INTERFACE_LINK_LIBRARIES>,REPLACE,".*::","">,>,>
# do not work
#
GET_TARGET_PROPERTY(_interface_link_libraries @TARGET@::@TARGET@ INTERFACE_LINK_LIBRARIES)
SET(_target_computed_dependencies)
FOREACH(_target ${_interface_link_libraries})
  IF (TARGET ${_target})
    GET_TARGET_PROPERTY(_target_location ${_target} LOCATION)
    GET_TARGET_PROPERTY(_target_version ${_target} VERSION)
    MESSAGE(STATUS "[@TARGET@::@TARGET@/${_target}] Location: ${_target_location}, Version: ${_target_version}")
    cmake_path(GET _target_location FILENAME _target_filename)
    get_filename_component(_target_filename_we ${_target_filename} NAME_WE)
    if(NOT ("x${CMAKE_SHARED_LIBRARY_PREFIX}" STREQUAL "x"))
      string(REGEX REPLACE "^${CMAKE_SHARED_LIBRARY_PREFIX}" "" _target_filename_we ${_target_filename_we})
    endif()
    IF(_target_version)
      SET(_target_computed_dependency "${_target_filename_we} = ${_target_version}")
    ELSE()
      SET(_target_computed_dependency ${_target_filename_we})
    ENDIF()
    LIST(APPEND _target_computed_dependencies ${_target_computed_dependency})
  ENDIF ()
ENDFOREACH()
IF (_target_computed_dependencies)
  MESSAGE (STATUS "[pc.@TARGET@/CMakeLists.txt] Setting @TARGET@::@TARGET@ computed dependencies: ${_target_computed_dependencies}")
  SET_TARGET_PROPERTIES(@TARGET@::@TARGET@ PROPERTIES COMPUTED_DEPENDENCIES ${_target_computed_dependencies})
ENDIF ()

GET_TARGET_PROPERTY(_interface_link_libraries @TARGET@::@TARGET@_static INTERFACE_LINK_LIBRARIES)
SET(_target_computed_dependencies_static)
FOREACH(_target ${_interface_link_libraries})
  IF (TARGET ${_target})
    GET_TARGET_PROPERTY(_target_location ${_target} LOCATION)
    GET_TARGET_PROPERTY(_target_version ${_target} VERSION)
    MESSAGE(STATUS "[@TARGET@::@TARGET@_static/${_target}] Location: ${_target_location}, Version: ${_target_version}")
    cmake_path(GET _target_location FILENAME _target_filename)
    get_filename_component(_target_filename_we ${_target_filename} NAME_WE)
    if(NOT ("x${CMAKE_STATIC_LIBRARY_PREFIX}" STREQUAL "x"))
      string(REGEX REPLACE "^${CMAKE_STATIC_LIBRARY_PREFIX}" "" _target_filename_we ${_target_filename_we})
    endif()
    IF(_target_version)
      SET(_target_computed_dependency "${_target_filename_we} = ${_target_version}")
    ELSE()
      SET(_target_computed_dependency ${_target_filename_we})
    ENDIF()
    LIST(APPEND _target_computed_dependencies_static ${_target_computed_dependency})
  ENDIF ()
ENDFOREACH()
IF (_target_computed_dependencies_static)
  MESSAGE (STATUS "[pc.@TARGET@/CMakeLists.txt] Setting @TARGET@::@TARGET@ static computed dependencies: ${_target_computed_dependencies_static}")
  SET_TARGET_PROPERTIES(@TARGET@::@TARGET@ PROPERTIES COMPUTED_DEPENDENCIES_STATIC ${_target_computed_dependencies_static})
ENDIF ()

SET_TARGET_PROPERTIES(@TARGET@::@TARGET@ PROPERTIES COMPUTED_VERSION ${@TARGET@_VERSION})

message(STATUS "[pc.@TARGET@/CMakeLists.txt] Generating ${CMAKE_CURRENT_BINARY_DIR}/@TARGET@.pc")
file(GENERATE OUTPUT @TARGET@.pc
     CONTENT [=[
prefix=${pcfiledir}/../..
exec_prefix=${prefix}
bindir=${exec_prefix}/@CMAKE_INSTALL_BINDIR@
includedir=${prefix}/@CMAKE_INSTALL_INCLUDEDIR@
docdir=${prefix}/@CMAKE_INSTALL_DOCDIR@
libdir=${exec_prefix}/@CMAKE_INSTALL_LIBDIR@
mandir=${prefix}/@CMAKE_INSTALL_MANDIR@
man1dir=${prefix}/@CMAKE_INSTALL_MANDIR@1
man2dir=${prefix}/@CMAKE_INSTALL_MANDIR@2

Name: @TARGET@
Version: $<TARGET_PROPERTY:COMPUTED_VERSION>
Requires: $<IF:$<BOOL:$<TARGET_PROPERTY:COMPUTED_DEPENDENCIES>>,$<JOIN:$<TARGET_PROPERTY:COMPUTED_DEPENDENCIES>,>,>
Requires.private: $<IF:$<BOOL:$<TARGET_PROPERTY:COMPUTED_DEPENDENCIES_STATIC>>,$<JOIN:$<TARGET_PROPERTY:COMPUTED_DEPENDENCIES_STATIC>,>,>
Cflags: -I${includedir} $<IF:$<BOOL:$<TARGET_PROPERTY:INTERFACE_COMPILE_DEFINITIONS>>,-D$<JOIN:$<TARGET_PROPERTY:INTERFACE_COMPILE_DEFINITIONS>, -D>,>
Cflags.private: -D@TARGET@_STATIC -I${includedir} $<IF:$<BOOL:$<TARGET_PROPERTY:INTERFACE_COMPILE_DEFINITIONS>>,-D$<JOIN:$<TARGET_PROPERTY:INTERFACE_COMPILE_DEFINITIONS>, -D>,>
Libs: -L${libdir} -l@TARGET@
Libs.private: ${libdir}/$<TARGET_LINKER_FILE_NAME:@TARGET@::@TARGET@_static>

Name: @TARGET@_static
Version: $<TARGET_PROPERTY:COMPUTED_VERSION>
Requires: $<IF:$<BOOL:$<TARGET_PROPERTY:COMPUTED_DEPENDENCIES_STATIC>>,$<JOIN:$<TARGET_PROPERTY:COMPUTED_DEPENDENCIES_STATIC>,>,>
Cflags: -D@TARGET@_STATIC -I${includedir} $<IF:$<BOOL:$<TARGET_PROPERTY:INTERFACE_COMPILE_DEFINITIONS>>,-D$<JOIN:$<TARGET_PROPERTY:INTERFACE_COMPILE_DEFINITIONS>, -D>,>
Libs: ${libdir}/$<TARGET_LINKER_FILE_NAME:@TARGET@::@TARGET@_static>
]=] TARGET "@TARGET@::@TARGET@")
]] @ONLY NEWLINE_STYLE LF)

  file(CONFIGURE OUTPUT "pc.${TARGET}/post-install.cmake"
    CONTENT [[
set(AUTO_PC_PKGCONFIG_DIR "$ENV{DESTDIR}$ENV{CMAKE_INSTALL_PREFIX_ENV}/$ENV{CMAKE_INSTALL_LIBDIR_ENV}/pkgconfig")
set(proj "@CMAKE_CURRENT_BINARY_DIR@/pc.@TARGET@")
execute_process(COMMAND "@CMAKE_COMMAND@" -G "@CMAKE_GENERATOR@" -S "${proj}" -B "${proj}/build")
message(STATUS "[pc.@TARGET@/post-install.cmake] Creating ${AUTO_PC_PKGCONFIG_DIR}/@TARGET@.pc")
file(COPY "${proj}/build/@TARGET@.pc" DESTINATION ${AUTO_PC_PKGCONFIG_DIR})
]] @ONLY NEWLINE_STYLE LF)

  SET (FIRE_POST_INSTALL_CMAKE_PATH ${CMAKE_CURRENT_BINARY_DIR}/fire_post_install.cmake)
  FILE(WRITE  ${FIRE_POST_INSTALL_CMAKE_PATH} "set(CMAKE_INSTALL_PREFIX \"\$ENV{CMAKE_INSTALL_PREFIX_ENV}\")\n")
  FILE(APPEND ${FIRE_POST_INSTALL_CMAKE_PATH} "set(CMAKE_INSTALL_LIBDIR \"\$ENV{CMAKE_INSTALL_LIBDIR_ENV}\")\n")
  FILE(APPEND ${FIRE_POST_INSTALL_CMAKE_PATH} "set(ENV{CMAKE_MODULE_ROOT_PATH} \"\$ENV{DESTDIR}\${CMAKE_INSTALL_PREFIX}/\${CMAKE_INSTALL_LIBDIR}/cmake\")\n")
  FILE(APPEND ${FIRE_POST_INSTALL_CMAKE_PATH} "\n")
  FILE(APPEND ${FIRE_POST_INSTALL_CMAKE_PATH} "message(STATUS \"[fire_post_install.cmake] Firing ${PROJECT_NAME} post-install\")\n")
  FILE(APPEND ${FIRE_POST_INSTALL_CMAKE_PATH} "include(${CMAKE_CURRENT_BINARY_DIR}/pc.${PROJECT_NAME}/post-install.cmake)\n")
  #
  # At each install we decrement the number of remaining post installs, and fire all of them when the number is 0
  # We CANNOT use CMAKE_INSTALL_PREFIX variable contrary to what is posted almost everywhere on the net: CPack will
  # will have a CMAKE_INSTALL_PREFIX different, the real and only way to know exactly where we install things is to
  # set the current working directory to ${DESTDIR}${CMAKE_INSTALL_PREFIX}, and use WORKING_DIRECTORY as the full install prefix dir.
  #
  INSTALL(CODE "
    set(CPACK_IS_RUNNING \$ENV{CPACK_IS_RUNNING})
    #
    # We do not want to run this when it is CPack
    #
    if (NOT CPACK_IS_RUNNING)
      # We need to re-evaluate GNUInstallDirs to get CMAKE_INSTALL_LIBDIR
      set(CMAKE_SYSTEM_NAME \"${CMAKE_SYSTEM_NAME}\")
      set(CMAKE_SIZEOF_VOID_P \"${CMAKE_SIZEOF_VOID_P}\")
      include(GNUInstallDirs)
      message(STATUS \"\\\$ENV{DESTDIR} is: \\\"\$ENV{DESTDIR}\\\"\")
      message(STATUS \"CMAKE_INSTALL_PREFIX is: \\\"\${CMAKE_INSTALL_PREFIX}\\\"\")
      message(STATUS \"CMAKE_INSTALL_LIBDIR is: \\\"\${CMAKE_INSTALL_LIBDIR}\\\"\")
      set(ENV{CMAKE_INSTALL_PREFIX_ENV} \"\${CMAKE_INSTALL_PREFIX}\") # Variable may be empty
      set(ENV{CMAKE_INSTALL_LIBDIR_ENV} \"\${CMAKE_INSTALL_LIBDIR}\") # Variable may be empty
      execute_process(COMMAND \"${CMAKE_COMMAND}\" -G \"${CMAKE_GENERATOR}\" -P \"${FIRE_POST_INSTALL_CMAKE_PATH}\" WORKING_DIRECTORY \${CMAKE_INSTALL_PREFIX})
    endif()
  "
  COMPONENT LibraryComponent
  )

  SET (CPACK_PRE_BUILD_SCRIPT_PC_PATH ${CMAKE_CURRENT_BINARY_DIR}/cpack_pre_build_script_pc_${TARGET}.cmake)
  FILE (WRITE  ${CPACK_PRE_BUILD_SCRIPT_PC_PATH} "# Content of this file is overwriten at cpack install using CPACK_INSTALL_SCRIPT\n")
  LIST (APPEND CPACK_PRE_BUILD_SCRIPTS ${CPACK_PRE_BUILD_SCRIPT_PC_PATH})
  SET (CPACK_PRE_BUILD_SCRIPTS ${CPACK_PRE_BUILD_SCRIPTS} PARENT_SCOPE)
endfunction()

MACRO (MYPACKAGEPKGCONFIGEXPORT)
  IF (NOT ${PROJECT_NAME}_NO_CONFIGEXPORT)
    #
    # We depend on CMake exports
    #
    IF (NOT CMAKE_VERSION VERSION_LESS "3.27")
      MYPACKAGECMAKEEXPORT()
      auto_pc(${PROJECT_NAME})
      # Clean up install path
      install(CODE [[ file(REMOVE_RECURSE "${CMAKE_INSTALL_PREFIX}/_auto_pc") ]])
    ELSE ()
      MESSAGE (AUTHOR_WARNING "Pkgconfig export requires version >= 3.26")
    ENDIF ()
  ENDIF ()
ENDMACRO ()
