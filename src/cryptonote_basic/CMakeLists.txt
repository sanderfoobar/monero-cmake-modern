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

file(GLOB CN_BASIC_SOURCES *.cpp *.c *.cc)
set(CN_BASIC_HEADERS
    account.h
    account_boost_serialization.h
    blobdatatype.h
    connection_context.h
    cryptonote_basic.h
    cryptonote_basic_impl.h
    cryptonote_boost_serialization.h
    cryptonote_format_utils.h
    difficulty.h
    events.h
    fwd.h
    hardfork.h
    merge_mining.h
    miner.h
    subaddress_index.h
    tx_extra.h
    verification_context.h)

# cryptonote_format_utils_basic
add_library(cryptonote_format_utils_basic)
target_sources(cryptonote_format_utils_basic
    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/cryptonote_format_utils_basic.cpp
    )

target_link_libraries(cryptonote_format_utils_basic PUBLIC cncrypto)
target_include_directories(cryptonote_format_utils_basic
        PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/..>
        PUBLIC $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
        PUBLIC $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/monero/>
        )

# cryptonote_basic
add_library(cryptonote_basic)
target_sources(cryptonote_basic
    PRIVATE
        ${CN_BASIC_SOURCES}
    )

target_link_libraries(cryptonote_basic
  PUBLIC
    common
    cncrypto
    checkpoints
    device
    Boost::date_time
    Boost::program_options
    Boost::serialization
    Boost::filesystem
    Boost::system
    Boost::thread)

target_include_directories(cryptonote_basic
        PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/..>
        PUBLIC $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
        PUBLIC $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/monero/>
        PUBLIC $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/monero/cryptonote_basic>
        )

monero_install_library(cryptonote_format_utils_basic)
monero_install_library(cryptonote_basic
        INCLUDE_DIR "${CMAKE_INSTALL_INCLUDEDIR}/monero/cryptonote_basic/"
        HEADERS ${CN_BASIC_HEADERS})