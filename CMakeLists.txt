################################################################################
##
## The University of Illinois/NCSA
## Open Source License (NCSA)
##
## Copyright (c) 2014-2018, Advanced Micro Devices, Inc. All rights reserved.
##
## Developed by:
##
##                 AMD Research and AMD HSA Software Development
##
##                 Advanced Micro Devices, Inc.
##
##                 www.amd.com
##
## Permission is hereby granted, free of charge, to any person obtaining a copy
## of this software and associated documentation files (the "Software"), to
## deal with the Software without restriction, including without limitation
## the rights to use, copy, modify, merge, publish, distribute, sublicense,
## and#or sell copies of the Software, and to permit persons to whom the
## Software is furnished to do so, subject to the following conditions:
##
##  - Redistributions of source code must retain the above copyright notice,
##    this list of conditions and the following disclaimers.
##  - Redistributions in binary form must reproduce the above copyright
##    notice, this list of conditions and the following disclaimers in
##    the documentation and#or other materials provided with the distribution.
##  - Neither the names of Advanced Micro Devices, Inc,
##    nor the names of its contributors may be used to endorse or promote
##    products derived from this Software without specific prior written
##    permission.
##
## THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
## IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
## FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
## THE CONTRIBUTORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
## OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
## ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
## DEALINGS WITH THE SOFTWARE.
##
################################################################################

cmake_minimum_required( VERSION 3.16 )
set( CORE_TARGET "rocm-core" )

project( ${CORE_TARGET} CXX )

## Verbose output.
set( CMAKE_VERBOSE_MAKEFILE on )

include( utils.cmake )
include( GNUInstallDirs )

set( CPACK_PACKAGING_INSTALL_PREFIX "/opt/rocm" CACHE PATH "default cpack directory" )
set( BUILD_SHARED_LIBS ON CACHE BOOL "Build shared library (.so) or not." )
set( CPACK_GENERATOR "TGZ;DEB;RPM" CACHE STRING "package types to be produced " )
set( COPYRIGHT_FILE "${CMAKE_CURRENT_SOURCE_DIR}/copyright"  )
set( BUILD_DIR ${CMAKE_CURRENT_BINARY_DIR} )

if( EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/rocm_version.h.in )
  file( READ "${CMAKE_CURRENT_SOURCE_DIR}/rocm_version.h.in" VER )

  string( REGEX MATCH "ROCM_VERSION_MAJOR   ([0-9]*)" _ ${VER} )
  set( ROCM_VERSION ${CMAKE_MATCH_1} )
  string( REGEX MATCH "ROCM_VERSION_MINOR   ([0-9]*)" _ ${VER} )
  set( ROCM_VERSION "${ROCM_VERSION}.${CMAKE_MATCH_1}" )
  string( REGEX MATCH "ROCM_VERSION_PATCH   ([0-9]*)" _ ${VER} )
  set( ROCM_VERSION "${ROCM_VERSION}.${CMAKE_MATCH_1}" )
  message( STATUS "ROCM_VERSION = ${ROCM_VERSION}" )
else()
  message( FATAL_ERROR "${CMAKE_CURRENT_SOURCE_DIR}/rocm_version.h.in does not exists." )
endif()

## Set the version
parse_rocm_version( ${ROCM_VERSION} )
set_variables()

if( NOT DEFINED BUILD_ID )
  set( BUILD_ID "9999")
endif()

set( PACKAGE_BUILD_INFO "${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_PATCH}.${VERSION_COMMIT_COUNT}-${BUILD_ID}-${VERSION_HASH}" )

configure_file( ${CMAKE_CURRENT_SOURCE_DIR}/rocmmod.in ${BUILD_DIR}/rocmmod @ONLY )
configure_file( ${CMAKE_CURRENT_SOURCE_DIR}/rocm-core.postinst ${BUILD_DIR}/postinst @ONLY )
configure_file( ${CMAKE_CURRENT_SOURCE_DIR}/rocm-core.prerm ${BUILD_DIR}/prerm @ONLY )

#Generate BUILD_INFO
configure_file( ${CMAKE_CURRENT_SOURCE_DIR}/rocm_version.h.in ${BUILD_DIR}/rocm_version.h @ONLY )

#Make the rocmlib
set( SRCS rocm_version.cpp )
add_library( ${CORE_TARGET} ${SRCS} )

set( CXX_FLAGS ${CXX_FLAGS} -g -fPIC -fvisibility=hidden -W -Wall -Wextra -Wno-unused-parameter -Wformat-security -Wundef -Wshadow -Wpointer-arith -Wcast-qual -Wmissing-declarations -Wredundant-decls -Wunreachable-code -std=c++11 )
set( CMAKE_SHARED_LINKER_FLAGS ${CMAKE_SHARED_LINKER_FLAGS} "-Wl,-z,nodelete -Wl,-no-undefined" )
target_include_directories( ${CORE_TARGET} PRIVATE ${BUILD_DIR} )

## Set the VERSION and SOVERSION values
set( PATCH_STRING "${VERSION_PATCH}.${ROCM_LIBPATCH_VERSION}" )
set( SO_VERSION_STRING "${VERSION_MAJOR}.${VERSION_MINOR}.${PATCH_STRING}" )
set_property( TARGET ${CORE_TARGET} PROPERTY VERSION "${SO_VERSION_STRING}" )
set_property( TARGET ${CORE_TARGET} PROPERTY SOVERSION "${VERSION_MAJOR}" )


#intallation directive
file ( WRITE "${CMAKE_CURRENT_BINARY_DIR}/version" "${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_PATCH}-${BUILD_ID}\n" )
install ( FILES ${CMAKE_CURRENT_BINARY_DIR}/version DESTINATION .info )
install ( TARGETS ${CORE_TARGET} DESTINATION ${CMAKE_INSTALL_LIBDIR} PERMISSIONS OWNER_WRITE OWNER_READ OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE )
install ( FILES ${BUILD_DIR}/rocm_version.h DESTINATION ${CMAKE_INSTALL_INCLUDEDIR} )
install ( FILES ${CMAKE_CURRENT_BINARY_DIR}/rocmmod DESTINATION ${CMAKE_INSTALL_LIBDIR} )


## Packaging directives
set ( CPACK_PACKAGE_NAME ${CORE_TARGET} )
set ( CPACK_PACKAGE_VENDOR "Advanced Micro Devices, Inc." )
set ( CPACK_PACKAGE_VERSION_MAJOR ${VERSION_MAJOR} )
set ( CPACK_PACKAGE_VERSION_MINOR ${VERSION_MINOR} )
set ( CPACK_PACKAGE_VERSION_PATCH ${VERSION_PATCH} )
set ( CPACK_PACKAGE_VERSION "${CPACK_PACKAGE_VERSION_MAJOR}.${CPACK_PACKAGE_VERSION_MINOR}.${CPACK_PACKAGE_VERSION_PATCH}" )
set ( CPACK_PACKAGE_CONTACT "ROCm Dev Support <rocm-dev.support@amd.com>" )
set ( CPACK_PACKAGE_DESCRIPTION_SUMMARY "Radeon Open Compute (ROCm) Runtime software stack" )
set ( CPACK_RESOURCE_FILE_LICENSE "${COPYRIGHT_FILE}" )

## packaging variables
if ( DEFINED ROCM_LIBPATCH_VERSION )
  set ( CPACK_PACKAGE_VERSION "${CPACK_PACKAGE_VERSION}.${ROCM_LIBPATCH_VERSION}" )
  message ( STATUS "Using CPACK_PACKAGE_VERSION ${CPACK_PACKAGE_VERSION}" )
endif()

## Debian package specific variables
message ( STATUS "Using CPACK_DEBIAN_PACKAGE_RELEASE ${CPACK_DEBIAN_PACKAGE_RELEASE}" )
set ( CPACK_DEBIAN_FILE_NAME "DEB-DEFAULT" )

## RPM package specific variables

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
set ( CPACK_DEBIAN_PACKAGE_HOMEPAGE "https://github.com/RadeonOpenCompute/ROCm" )
set ( CPACK_DEBIAN_PACKAGE_CONTROL_EXTRA "${BUILD_DIR}/postinst;${BUILD_DIR}/prerm" )

## RPM package specific variables
set ( CPACK_RPM_PACKAGE_REQUIRES ${RPM_DEPENDS_STRING} )
set ( CPACK_RPM_POST_INSTALL_SCRIPT_FILE "${CMAKE_CURRENT_BINARY_DIR}/postinst" )
set ( CPACK_RPM_POST_UNINSTALL_SCRIPT_FILE "${CMAKE_CURRENT_BINARY_DIR}/prerm" )

if ( DEFINED CPACK_PACKAGING_INSTALL_PREFIX )
    set ( CPACK_RPM_EXCLUDE_FROM_AUTO_FILELIST_ADDITION "${CPACK_PACKAGING_INSTALL_PREFIX} ${CPACK_PACKAGING_INSTALL_PREFIX}/.info" )
endif ( )

## Include packaging
include ( CPack )
