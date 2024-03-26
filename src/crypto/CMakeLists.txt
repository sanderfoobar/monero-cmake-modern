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

set(crypto_sources
    aesb.c
    blake256.c
    chacha.c
    crypto-ops-data.c
    crypto-ops.c
    crypto.cpp
    groestl.c
    hash-extra-blake.c
    hash-extra-groestl.c
    hash-extra-jh.c
    hash-extra-skein.c
    hash.c
    hmac-keccak.c
    jh.c
    keccak.c
    oaes_lib.c
    random.c
    skein.c
    slow-hash.c
    rx-slow-hash.c
    CryptonightR_JIT.c
    tree-hash.c)

set(crypto_headers
    CryptonightR_JIT.h
    CryptonightR_template.h
    blake256.h
    c_threads.h
    chacha.h
    crypto-ops.h
    crypto.h
    duration.h
    generic-ops.h
    groestl.h
    groestl_tables.h
    hash-ops.h
    hash.h
    hmac-keccak.h
    initializer.h
    jh.h
    keccak.h
    oaes_config.h
    oaes_lib.h
    random.h
    skein.h
    skein_port.h
    variant2_int_sqrt.h
    variant4_random_math.h)

if(NOT ARM)
  list(APPEND crypto_sources CryptonightR_template.S)
endif()

add_library(cncrypto)
target_sources(cncrypto
    PRIVATE
        ${crypto_sources}
    )

target_link_libraries(cncrypto
  PUBLIC
    epee
    randomx
    Boost::system
    ${sodium_LIBRARY_RELEASE}
    OpenSSL::SSL
    OpenSSL::Crypto
    ${CMAKE_DL_LIBS})

target_include_directories(cncrypto
        PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/..>
        PUBLIC $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
        PUBLIC $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/monero/>
        PUBLIC ${sodium_INCLUDE_DIR}
        )

if (ARM AND NO_OPTIMIZED_MULTIPLY_ON_ARM)
  message(STATUS "Using generic C implementation for multiply")
  set_property(SOURCE slow-hash.c
    PROPERTY COMPILE_DEFINITIONS "NO_OPTIMIZED_MULTIPLY_ON_ARM")
endif()

# Because of the way Qt works on android with JNI, the code does not live in the main android thread
# So this code runs with a 1 MB default stack size.
# This will force the use of the heap for the allocation of the scratchpad
if (ANDROID OR IOS)
    add_definitions(-DFORCE_USE_HEAP=1)
endif()

# cheat because cmake and ccache hate each other
set_property(SOURCE CryptonightR_template.S PROPERTY LANGUAGE ASM)
set_property(SOURCE CryptonightR_template.S PROPERTY XCODE_EXPLICIT_FILE_TYPE sourcecode.asm)

# Must be done last, because it references libraries in this directory
add_subdirectory(wallet)

monero_install_library(cncrypto
        INCLUDE_DIR "${CMAKE_INSTALL_INCLUDEDIR}/monero/crypto/"
        HEADERS ${crypto_headers})