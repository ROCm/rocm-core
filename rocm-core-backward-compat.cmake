# Copyright (c) 2023 Advanced Micro Devices, Inc. All Rights Reserved.
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

cmake_minimum_required(VERSION 3.16.8)

set(ROCM_CORE_BUILD_DIR ${CMAKE_CURRENT_BINARY_DIR})
set(ROCM_CORE_WRAPPER_DIR ${ROCM_CORE_BUILD_DIR}/wrapper_dir)
set(ROCM_CORE_WRAPPER_INC_DIR ${ROCM_CORE_WRAPPER_DIR}/include)
set(headerfile_dir "rocm-core")

#Function to set actual file contents in wrapper files
#Some components grep for the contents in the file
function(set_file_contents input_file)
    set(hashzero_check "#if 0
/* The following is a copy of the original file for the benefit of build systems which grep for values
 * in this file rather than preprocess it. This is just for backward compatibility */")

    file(READ ${input_file} file_contents)
    set(hash_endif "#endif")
    get_filename_component(file_name ${input_file} NAME)
    configure_file(${CMAKE_CURRENT_SOURCE_DIR}/header_template.hpp.in ${ROCM_CORE_WRAPPER_INC_DIR}/${file_name})
endfunction()

#use header template file and generate wrapper header files
function(generate_wrapper_header)
  file(MAKE_DIRECTORY ${ROCM_CORE_WRAPPER_INC_DIR})

  #find all header files
  file(GLOB include_files ${ROCM_CORE_BUILD_DIR}/*.h)
  #Create wrapper files
  foreach(header_file ${include_files})
    # set include guard
    get_filename_component(INC_GAURD_NAME ${header_file} NAME_WE)
    string(TOUPPER ${INC_GAURD_NAME} INC_GAURD_NAME)
    set(include_guard "ROCM_CORE_WRAPPER_INCLUDE_${INC_GAURD_NAME}_H")
    #set #include statement
    get_filename_component(file_name ${header_file} NAME)
    set(include_statements "#include \"${headerfile_dir}/${file_name}\"\n")
    set_file_contents(${header_file})
  endforeach()

endfunction()

#Use template header file and generater wrapper header files
generate_wrapper_header()
install(DIRECTORY ${ROCM_CORE_WRAPPER_INC_DIR} DESTINATION . COMPONENT runtime)

