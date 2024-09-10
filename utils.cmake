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

    if ( ${VERSION_COUNT} GREATER 3 )
        list ( GET VERSIONS 3 POINT )
        set ( VERSION_POINT ${POINT} PARENT_SCOPE )
        set ( TEMP_VERSION_STRING "${TEMP_VERSION_STRING}.${POINT}" )
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

    #set libpatch version
    if(NOT DEFINED ENV{ROCM_LIBPATCH_VERSION})
      set(ROCM_LIBPATCH_VERSION "${VERSION_MAJOR}")
      string(LENGTH ${VERSION_MINOR} LENSTR)
      if(LENSTR EQUAL 1) # length of version cannot be zero hence it would be 1 or greater
         set(ROCM_LIBPATCH_VERSION "${ROCM_LIBPATCH_VERSION}0${VERSION_MINOR}")
      else() # length is greater than 1
         set(ROCM_LIBPATCH_VERSION "${ROCM_LIBPATCH_VERSION}${VERSION_MINOR}")
      endif()

      string(LENGTH ${VERSION_PATCH} LENSTR)
      if(LENSTR EQUAL 1) # length of version cannot be zero hence it would be 1 or greater
         set(ROCM_LIBPATCH_VERSION "${ROCM_LIBPATCH_VERSION}0${VERSION_PATCH}")
      else() # length is greater than 1
         set(ROCM_LIBPATCH_VERSION "${ROCM_LIBPATCH_VERSION}${VERSION_PATCH}")
      endif()

      set(ROCM_LIBPATCH_VERSION "${ROCM_LIBPATCH_VERSION}" PARENT_SCOPE )
    else()
      set (ROCM_LIBPATCH_VERSION $ENV{ROCM_LIBPATCH_VERSION} PARENT_SCOPE )
    endif()

    if ( DEFINED ENV{CPACK_RPM_PACKAGE_RELEASE} )
      set ( CPACK_RPM_PACKAGE_RELEASE ${CPACK_RPM_PACKAGE_RELEASE} PARENT_SCOPE )
    else()
      set ( CPACK_RPM_PACKAGE_RELEASE "local" PARENT_SCOPE )
    endif()

    if ( DEFINED ENV{CPACK_DEBIAN_PACKAGE_RELEASE} )
      set ( CPACK_DEBIAN_PACKAGE_RELEASE ${CPACK_DEBIAN_PACKAGE_RELEASE} PARENT_SCOPE )
    else()
      set ( CPACK_DEBIAN_PACKAGE_RELEASE "local" PARENT_SCOPE )
    endif()

    set( VERSION_COMMIT_COUNT "${VERSION_COMMIT_COUNT}" PARENT_SCOPE )
    set( VERSION_HASH "${VERSION_HASH}" PARENT_SCOPE )
    set( VERSION_BUILD  "${VERSION_BUILD}" PARENT_SCOPE )

    message(STATUS "VERSION_MAJOR : ${VERSION_MAJOR}" )
    message(STATUS "VERSION_MINOR : ${VERSION_MINOR}" )
    message(STATUS "VERSION_PATCH : ${VERSION_PATCH}" )
    message(STATUS "VERSION_POINT : ${VERSION_POINT}" )
    message(STATUS "ROCM_LIBPATCH_VERSION : ${ROCM_LIBPATCH_VERSION}" )
    message(STATUS "VERSION_COMMIT_COUNT : ${VERSION_COMMIT_COUNT}" )
    message(STATUS "VERSION_HASH : ${VERSION_HASH}" )
    message(STATUS "VERSION_BUILD : ${VERSION_BUILD}" )
    message(STATUS "CPACK_DEBIAN_PACKAGE_RELEASE : ${CPACK_DEBIAN_PACKAGE_RELEASE}" )
    message(STATUS "CPACK_RPM_PACKAGE_RELEASE : ${CPACK_RPM_PACKAGE_RELEASE}" )

endfunction()


