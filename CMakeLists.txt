################################################################################
##
## MIT License
##
## Copyright (c) 2017 - 2023 Advanced Micro Devices, Inc. All rights Reserved.
##
## Permission is hereby granted, free of charge, to any person obtaining a copy
## of this software and associated documentation files (the "Software"), to deal
## in the Software without restriction, including without limitation the rights
## to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
## copies of the Software, and to permit persons to whom the Software is
## furnished to do so, subject to the following conditions:
##
## The above copyright notice and this permission notice shall be included in all
## copies or substantial portions of the Software.
##
## THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
## IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
## FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
## AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
## LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
## OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
## SOFTWARE.
##
################################################################################

cmake_minimum_required( VERSION 3.16 )
set( CORE_TARGET "rocm-core" )

project( ${CORE_TARGET} CXX )

## Verbose output.
set( CMAKE_VERBOSE_MAKEFILE on )

include( utils.cmake )
include( GNUInstallDirs )

#Parse Version
message( STATUS "ROCM_VERSION = ${ROCM_VERSION}" )
parse_rocm_version( ${ROCM_VERSION} )

set( CPACK_PACKAGING_INSTALL_PREFIX "/opt/rocm" CACHE PATH "default cpack directory" )
set( BUILD_SHARED_LIBS ON CACHE BOOL "Build shared library (.so) or not." )
set( CPACK_GENERATOR "TGZ;DEB;RPM" CACHE STRING "package types to be produced " )
set( COPYRIGHT_FILE "${CMAKE_CURRENT_SOURCE_DIR}/copyright"  )
set( BUILD_DIR ${CMAKE_CURRENT_BINARY_DIR} )

if(NOT ENABLE_ASAN_PACKAGING)
    option(FILE_REORG_BACKWARD_COMPATIBILITY "Enable File Reorg with backward compatibility" OFF)
endif()

## Set variables
set_variables()

set( SO_MAJOR "1")
set( SO_MINOR "0" )

if( NOT DEFINED BUILD_ID )
  set( BUILD_ID "9999")
endif()

set( PACKAGE_BUILD_INFO "${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_PATCH}.${VERSION_COMMIT_COUNT}-${BUILD_ID}-${VERSION_HASH}" )

configure_file( ${CMAKE_CURRENT_SOURCE_DIR}/rocmmod.in ${BUILD_DIR}/rocmmod @ONLY )
configure_file( ${CMAKE_CURRENT_SOURCE_DIR}/rocm-core.postinst ${BUILD_DIR}/postinst @ONLY )
configure_file( ${CMAKE_CURRENT_SOURCE_DIR}/rocm-core.prerm ${BUILD_DIR}/prerm @ONLY )

#Generate BUILD_INFO
configure_file( ${CMAKE_CURRENT_SOURCE_DIR}/rocm_version.h.in ${BUILD_DIR}/rocm_version.h @ONLY )

#File reorg Backward compatibility function
if(NOT WIN32)
    if(FILE_REORG_BACKWARD_COMPATIBILITY)
    # To enabe/disable #error in wrapper header files
        if(NOT DEFINED ROCM_HEADER_WRAPPER_WERROR)
            if(DEFINED ENV{ROCM_HEADER_WRAPPER_WERROR})
                set(ROCM_HEADER_WRAPPER_WERROR "$ENV{ROCM_HEADER_WRAPPER_WERROR}"
                    CACHE STRING "Header wrapper warnings as errors.")
            else()
                set(ROCM_HEADER_WRAPPER_WERROR "OFF" CACHE STRING "Header wrapper warnings as errors.")
            endif()
        endif()

        if(ROCM_HEADER_WRAPPER_WERROR)
            set(deprecated_error 1)
        else()
            set(deprecated_error 0)
        endif()

        include(rocm-core-backward-compat.cmake)
    endif() #FILE_REORG_BACKWARD_COMPATIBILITY
endif()

#Make the rocmlib
set( SRCS rocm_version.cpp )
add_library( ${CORE_TARGET} ${SRCS} )

set( CXX_FLAGS ${CXX_FLAGS} -g -fPIC -fvisibility=hidden -W -Wall -Wextra -Wno-unused-parameter -Wformat-security -Wundef -Wshadow -Wpointer-arith -Wcast-qual -Wmissing-declarations -Wredundant-decls -Wunreachable-code -std=c++11 )
set( CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS}  -Wl,-z,nodelete -Wl,-no-undefined" )
target_include_directories( ${CORE_TARGET} PRIVATE ${BUILD_DIR} )

## Set the VERSION and SOVERSION values
set( SO_VERSION_STRING "${SO_MAJOR}.${SO_MINOR}.${ROCM_LIBPATCH_VERSION}" )
set_property( TARGET ${CORE_TARGET} PROPERTY VERSION "${SO_VERSION_STRING}" )
set_property( TARGET ${CORE_TARGET} PROPERTY SOVERSION "${SO_MAJOR}" )

if(ENABLE_ASAN_PACKAGING)
  # Only libraries required for ASAN Package
  set( CPACK_COMPONENTS_ALL asan )
  set( COMP_TYPE "asan" )
  set( PKG_DESCRIPTION "Radeon Open Compute (ROCm) AddressSanitizer Instrumented Runtime software stack" )
else()
  set( CPACK_COMPONENTS_ALL runtime )
  set( COMP_TYPE "runtime" )
  set( PKG_DESCRIPTION "Radeon Open Compute (ROCm) Runtime software stack" )
endif()

#intallation directive
file ( WRITE "${CMAKE_CURRENT_BINARY_DIR}/version" "${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_PATCH}-${BUILD_ID}\n" )
install ( FILES ${CMAKE_CURRENT_BINARY_DIR}/version DESTINATION .info COMPONENT runtime )
install ( TARGETS ${CORE_TARGET} DESTINATION ${CMAKE_INSTALL_LIBDIR}
          PERMISSIONS OWNER_WRITE OWNER_READ OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE
          COMPONENT ${COMP_TYPE} )
install ( FILES ${BUILD_DIR}/rocm_version.h DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/rocm-core COMPONENT runtime )
install ( FILES ${CMAKE_CURRENT_BINARY_DIR}/rocmmod DESTINATION ${CMAKE_INSTALL_LIBDIR} COMPONENT runtime )

# License file
install(FILES ${COPYRIGHT_FILE} DESTINATION ${CMAKE_INSTALL_DOCDIR} RENAME LICENSE.txt COMPONENT runtime)
install(FILES ${COPYRIGHT_FILE} DESTINATION ${CMAKE_INSTALL_DOCDIR}-asan RENAME LICENSE.txt COMPONENT asan)

## Packaging directives
set ( CPACK_PACKAGE_VENDOR "Advanced Micro Devices, Inc." )
set ( CPACK_PACKAGE_VERSION_MAJOR ${VERSION_MAJOR} )
set ( CPACK_PACKAGE_VERSION_MINOR ${VERSION_MINOR} )
set ( CPACK_PACKAGE_VERSION_PATCH ${VERSION_PATCH} )
set ( CPACK_PACKAGE_VERSION "${CPACK_PACKAGE_VERSION_MAJOR}.${CPACK_PACKAGE_VERSION_MINOR}.${CPACK_PACKAGE_VERSION_PATCH}" )
set ( CPACK_PACKAGE_CONTACT "ROCm Dev Support <rocm-dev.support@amd.com>" )
set ( CPACK_PACKAGE_DESCRIPTION_SUMMARY "${PKG_DESCRIPTION}" )
set ( CPACK_RESOURCE_FILE_LICENSE "${COPYRIGHT_FILE}" )
## packaging variables
if ( DEFINED ROCM_LIBPATCH_VERSION )
  set ( CPACK_PACKAGE_VERSION "${CPACK_PACKAGE_VERSION}.${ROCM_LIBPATCH_VERSION}" )
  message ( STATUS "Using CPACK_PACKAGE_VERSION ${CPACK_PACKAGE_VERSION}" )
endif()

## Debian package specific variables
set ( CPACK_DEB_COMPONENT_INSTALL ON )
set ( CPACK_DEBIAN_RUNTIME_PACKAGE_NAME "${CORE_TARGET}" )
# ASAN package name
set ( CPACK_DEBIAN_ASAN_PACKAGE_NAME ${CORE_TARGET}-asan )
message ( STATUS "Using CPACK_DEBIAN_PACKAGE_RELEASE ${CPACK_DEBIAN_PACKAGE_RELEASE}" )
set ( CPACK_DEBIAN_FILE_NAME "DEB-DEFAULT" )

## RPM package specific variables
set ( CPACK_RPM_COMPONENT_INSTALL ON )
set ( CPACK_RPM_RUNTIME_PACKAGE_NAME "${CORE_TARGET}" )
# ASAN package name
set ( CPACK_RPM_ASAN_PACKAGE_NAME ${CORE_TARGET}-asan )

## 'dist' breaks manual builds on debian systems due to empty Provides
execute_process( COMMAND rpm --eval %{?dist}
                 RESULT_VARIABLE PROC_RESULT
                 OUTPUT_VARIABLE EVAL_RESULT
                 OUTPUT_STRIP_TRAILING_WHITESPACE )

if ( PROC_RESULT EQUAL "0" AND NOT EVAL_RESULT STREQUAL "" )
  string ( APPEND CPACK_RPM_PACKAGE_RELEASE "%{?dist}" )
endif()
message(STATUS "Using CPACK_RPM_PACKAGE_RELEASE: ${CPACK_RPM_PACKAGE_RELEASE}")
set ( CPACK_RPM_FILE_NAME "RPM-DEFAULT" )

# Debian package specific variables
set ( CPACK_DEBIAN_PACKAGE_DEPENDS ${DEB_DEPENDS_STRING} )
set ( CPACK_DEBIAN_ASAN_PACKAGE_DEPENDS ${CORE_TARGET} )
set ( CPACK_DEBIAN_PACKAGE_HOMEPAGE "https://github.com/RadeonOpenCompute/ROCm" )
set ( CPACK_DEBIAN_RUNTIME_PACKAGE_CONTROL_EXTRA "${BUILD_DIR}/postinst;${BUILD_DIR}/prerm" )

## RPM package specific variables
set ( CPACK_RPM_PACKAGE_REQUIRES ${RPM_DEPENDS_STRING} )
set ( CPACK_RPM_ASAN_PACKAGE_REQUIRES ${CORE_TARGET} )
set ( CPACK_RPM_PACKAGE_LICENSE "MIT" )
set ( CPACK_RPM_RUNTIME_POST_INSTALL_SCRIPT_FILE "${CMAKE_CURRENT_BINARY_DIR}/postinst" )
set ( CPACK_RPM_RUNTIME_POST_UNINSTALL_SCRIPT_FILE "${CMAKE_CURRENT_BINARY_DIR}/prerm" )

if ( DEFINED CPACK_PACKAGING_INSTALL_PREFIX )
    set ( CPACK_RPM_EXCLUDE_FROM_AUTO_FILELIST_ADDITION "${CPACK_PACKAGING_INSTALL_PREFIX} ${CPACK_PACKAGING_INSTALL_PREFIX}/.info" )
endif ( )

## Include packaging
include ( CPack )
