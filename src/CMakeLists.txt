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

include(Version)
add_library(version)
target_sources(version
    PRIVATE
        ${CMAKE_BINARY_DIR}/version.cpp
    )

target_include_directories(version
        PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
        PUBLIC $<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/external>
        PUBLIC $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
        PUBLIC $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/monero/>
        )

monero_install_library(version
        INCLUDE_DIR "${CMAKE_INSTALL_INCLUDEDIR}/monero/"
        HEADERS version.h)

add_subdirectory(common)
add_subdirectory(crypto)
add_subdirectory(ringct)
add_subdirectory(checkpoints)
add_subdirectory(cryptonote_basic)
add_subdirectory(cryptonote_core)
add_subdirectory(lmdb)
add_subdirectory(multisig)
add_subdirectory(net)
add_subdirectory(hardforks)
add_subdirectory(blockchain_db)
add_subdirectory(mnemonics)
add_subdirectory(rpc)
#add_subdirectory(test)
if(NOT IOS)
  add_subdirectory(serialization)
endif()
add_subdirectory(wallet)
if(NOT IOS)
  add_subdirectory(p2p)
endif()
add_subdirectory(cryptonote_protocol)
if(NOT IOS)
  add_subdirectory(simplewallet)
  add_subdirectory(daemonizer)
  add_subdirectory(daemon)
endif()

if(BUILD_DEBUG_UTILITIES OR CMAKE_BUILD_TYPE STREQUAL "Debug")
  add_subdirectory(debug_utilities)
  add_subdirectory(blockchain_utilities)
  add_subdirectory(gen_multisig)
  add_subdirectory(gen_ssl_cert)
endif()

if(PER_BLOCK_CHECKPOINT)
  add_subdirectory(blocks)
endif()

add_subdirectory(device)
#add_subdirectory(device_trezor)

install(FILES cryptonote_config.h
        DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}/monero/")