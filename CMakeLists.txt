# Copyright (c) 2014-2023, The Monero Project
#
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without modification, are
# permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice, this list of
#    conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright notice, this list
#    of conditions and the following disclaimer in the documentation and/or other
#    materials provided with the distribution.
#
# 3. Neither the name of the copyright holder nor the names of its contributors may be
#    used to endorse or promote products derived from this software without specific
#    prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY
# EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
# THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
# STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
# THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# Parts of this file are originally copyright (c) 2012-2013 The Cryptonote developers
list(INSERT CMAKE_MODULE_PATH 0 "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

cmake_minimum_required(VERSION 3.23)
message(STATUS "CMake version ${CMAKE_VERSION}")

set(VERSION "0.18.3.3")
project(monero VERSION ${VERSION})
enable_language(C ASM)

set(CMAKE_VERBOSE_MAKEFILE on)
set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_C_EXTENSIONS ON)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS ON)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fPIC -ftemplate-depth=900")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -maes")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -maes")

option(STATIC "Link libraries statically" off)
option(ARM "ARM build" OFF)
option(IOS "iOS build" OFF)
option(BUILD_DEBUG_UTILITIES "Build debug utilities." OFF)
option(USE_READLINE "Build with GNU readline support." OFF)
option(STACK_TRACE "Install a hook that dumps stack on exception" OFF)
option(NO_OPTIMIZED_MULTIPLY_ON_ARM "Compute multiply using generic C implementation instead of ARM ASM" OFF)

if(STATIC)
  set(BUILD_SHARED_LIBS OFF)
  set(MINIUPNPC_USE_STATIC_LIBS ON)
  set(Boost_USE_STATIC_LIBS ON)
  set(Boost_USE_STATIC_RUNTIME ON)
  set(sodium_USE_STATIC_LIBS ON)
  set(OPENSSL_USE_STATIC_LIBS ON)
  set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -static -static-libgcc -static-libstdc++")
  set(CMAKE_FIND_LIBRARY_SUFFIXES .a ${CMAKE_FIND_LIBRARY_SUFFIXES})
endif()

set(THREADS_PREFER_PTHREAD_FLAG ON)
set(USE_LTO_DEFAULT false)
set(PER_BLOCK_CHECKPOINT 1)

include(FindPythonInterp)
include(ExternalProject)
include(FindCcache)
include(FetchContent)
include(functions)

# CMake build type
if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Release CACHE STRING "Build type" FORCE)
  message(STATUS "Setting default build type: ${CMAKE_BUILD_TYPE}")
endif()
string(TOLOWER ${CMAKE_BUILD_TYPE} CMAKE_BUILD_TYPE_LOWER)

set(ARCH_WIDTH "64")
if(NOT CMAKE_SIZEOF_VOID_P EQUAL "8")
  set(ARCH_WIDTH "32")
endif()

find_package(Git)
find_package(Threads)
find_package(Backtrace)
find_package(PythonInterp)
find_package(miniupnpc REQUIRED)
find_package(ZMQ REQUIRED)
find_package(Libunbound 1.12 REQUIRED)
find_package(sodium REQUIRED)
find_package(OpenSSL REQUIRED)
find_package(Boost 1.58 REQUIRED COMPONENTS system filesystem thread date_time chrono regex serialization program_options locale)

include(ExternalProject)
ExternalProject_Add(generate_translations_header
  SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/translations"
  BINARY_DIR "${CMAKE_CURRENT_BINARY_DIR}/translations"
  STAMP_DIR ${LRELEASE_PATH}
  CMAKE_ARGS -DLRELEASE_PATH=${LRELEASE_PATH}
  INSTALL_COMMAND ${CMAKE_COMMAND} -E echo "")

add_subdirectory(external)
add_subdirectory(contrib)
add_subdirectory(src)

# copy cmake/*.cmake files to the module folder
install(DIRECTORY "${CMAKE_SOURCE_DIR}/cmake/"
        DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/monero/modules"
        FILES_MATCHING PATTERN "*.cmake")

# CMake version config
write_basic_package_version_file(
    MoneroConfigVersion.cmake
    VERSION ${PACKAGE_VERSION}
    COMPATIBILITY AnyNewerVersion)
install(FILES "${CMAKE_CURRENT_BINARY_DIR}/MoneroConfigVersion.cmake"
        DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/monero")

# CMake targets file
install(EXPORT MoneroTargets
  FILE MoneroTargets.cmake
  NAMESPACE monero::
  DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/monero")

# generate CMake config file
configure_package_config_file("${CMAKE_SOURCE_DIR}/cmake/MoneroConfig.cmake.in"
  "${CMAKE_CURRENT_BINARY_DIR}/MoneroConfig.cmake"
  INSTALL_DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/monero")

# install CMake config file
install(FILES
  "${CMAKE_CURRENT_BINARY_DIR}/MoneroConfig.cmake"
  DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/monero"
)

print_cmake_summary()