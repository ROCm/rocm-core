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

## Parses the VERSION_STRING variable and places
## the first, second and third number values in
## the major, minor and patch variables.
function( parse_rocm_version VERSION_STRING )

    string ( FIND ${VERSION_STRING} "-" STRING_INDEX )

    if ( ${STRING_INDEX} GREATER -1 )
        math ( EXPR STRING_INDEX "${STRING_INDEX} + 1" )
        string ( SUBSTRING ${VERSION_STRING} ${STRING_INDEX} -1 VERSION_BUILD )
    endif ()

    string ( REGEX MATCHALL "[0123456789]+" VERSIONS ${VERSION_STRING} )
    list ( LENGTH VERSIONS VERSION_COUNT )

    if ( ${VERSION_COUNT} GREATER 0)
        list ( GET VERSIONS 0 MAJOR )
        set ( VERSION_MAJOR ${MAJOR} PARENT_SCOPE )
        set ( TEMP_VERSION_STRING "${MAJOR}" )
    endif ()

    if ( ${VERSION_COUNT} GREATER 1 )
        list ( GET VERSIONS 1 MINOR )
        set ( VERSION_MINOR ${MINOR} PARENT_SCOPE )
        set ( TEMP_VERSION_STRING "${TEMP_VERSION_STRING}.${MINOR}" )
    endif ()

    if ( ${VERSION_COUNT} GREATER 2 )
        list ( GET VERSIONS 2 PATCH )
        set ( VERSION_PATCH ${PATCH} PARENT_SCOPE )
        set ( TEMP_VERSION_STRING "${TEMP_VERSION_STRING}.${PATCH}" )
    endif ()

    if ( DEFINED VERSION_BUILD )
        set ( VERSION_BUILD "${VERSION_BUILD}" PARENT_SCOPE )
    endif ()

    set ( VERSION_STRING "${TEMP_VERSION_STRING}" PARENT_SCOPE )

endfunction ()


## Sets cmake variables which can be derived from existing
function( set_variables )
    set( VERSION_COMMIT_COUNT 0 )
    set( VERSION_HASH "unknown" )

    find_program( GIT NAMES git )

    if( GIT )
        # Get branch commit (common ancestor) of current branch and master branch.
        execute_process(COMMAND git merge-base HEAD origin/HEAD
                        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
                        OUTPUT_VARIABLE GIT_MERGE_BASE
                        OUTPUT_STRIP_TRAILING_WHITESPACE
                        RESULT_VARIABLE RESULT )

        if( ${RESULT} EQUAL 0 )
            # Count commits from branch point.
            execute_process(COMMAND git rev-list --count ${GIT_MERGE_BASE}..HEAD
                            WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
                            OUTPUT_VARIABLE VERSION_COMMIT_COUNT
                            OUTPUT_STRIP_TRAILING_WHITESPACE
                            RESULT_VARIABLE RESULT )
            if(NOT ${RESULT} EQUAL 0 )
                set( VERSION_COMMIT_COUNT 0 )
            endif()
        endif()

        # Get current short hash.
        execute_process(COMMAND git rev-parse --short HEAD
                        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
                        OUTPUT_VARIABLE VERSION_HASH
                        OUTPUT_STRIP_TRAILING_WHITESPACE
                        RESULT_VARIABLE RESULT )
        if( ${RESULT} EQUAL 0 )
            # Check for dirty workspace.
            execute_process(COMMAND git diff --quiet
                            WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
                            RESULT_VARIABLE RESULT )
            if(${RESULT} EQUAL 1)
                set(VERSION_HASH "${VERSION_HASH}-dirty")
            endif()
        else()
            set( VERSION_HASH "unknown" )
        endif()
    endif()

    if ( DEFINED CPACK_RPM_PACKAGE_RELEASE )
      set ( CPACK_RPM_PACKAGE_RELEASE ${CPACK_RPM_PACKAGE_RELEASE} PARENT_SCOPE )
    else()
      set ( CPACK_RPM_PACKAGE_RELEASE "local" PARENT_SCOPE )
    endif()

    if ( DEFINED CPACK_DEBIAN_PACKAGE_RELEASE )
      set ( CPACK_DEBIAN_PACKAGE_RELEASE ${CPACK_DEBIAN_PACKAGE_RELEASE} PARENT_SCOPE )
    else()
      set ( CPACK_DEBIAN_PACKAGE_RELEASE "local" PARENT_SCOPE )
    endif()

    set( VERSION_COMMIT_COUNT "${VERSION_COMMIT_COUNT}" PARENT_SCOPE )
    set( VERSION_HASH "${VERSION_HASH}" PARENT_SCOPE )

    message(STATUS "VERSION_MAJOR : ${VERSION_MAJOR}" )
    message(STATUS "VERSION_MINOR : ${VERSION_MINOR}" )
    message(STATUS "VERSION_PATCH : ${VERSION_PATCH}" )
    message(STATUS "VERSION_COMMIT_COUNT : ${VERSION_COMMIT_COUNT}" )
    message(STATUS "VERSION_HASH : ${VERSION_HASH}" )
    message(STATUS "CPACK_DEBIAN_PACKAGE_RELEASE : ${CPACK_DEBIAN_PACKAGE_RELEASE}" )
    message(STATUS "CPACK_RPM_PACKAGE_RELEASE : ${CPACK_RPM_PACKAGE_RELEASE}" )

endfunction()


