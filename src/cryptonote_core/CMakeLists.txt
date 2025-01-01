# Copyright (c) 2014-2025, The Monero Project
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

file(GLOB CN_CORE_SOURCES *.cpp *.c *.cc)
set(CN_CORE_HEADERS
  blockchain.h
  blockchain_storage_boost_serialization.h
  cryptonote_core.h
  cryptonote_tx_utils.h
  i_core_events.h
  tx_pool.h
  tx_sanity_check.h
  tx_verification_utils.h)

add_library(cryptonote_core)
target_link_libraries(cryptonote_core
  PUBLIC
    version
    common
    cncrypto
    blockchain_db
    ringct
    device
    hardforks
    Boost::date_time
    Boost::program_options
    Boost::serialization
    Boost::filesystem
    Boost::system
    Boost::thread)

target_include_directories(cryptonote_core PRIVATE
        PUBLIC $<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/external>
        PUBLIC $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
        PUBLIC $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/monero/>
        )

if(PER_BLOCK_CHECKPOINT)
  target_compile_definitions(cryptonote_core PUBLIC PER_BLOCK_CHECKPOINT=1)
endif()

target_sources(cryptonote_core
    PRIVATE
        ${CN_CORE_SOURCES}
    )

target_include_directories(cryptonote_core
        PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
        PUBLIC $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
        PUBLIC $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/monero/>
        )

monero_install_library(cryptonote_core
        INCLUDE_DIR "${CMAKE_INSTALL_INCLUDEDIR}/monero/cryptonote_core/"
        HEADERS ${CN_CORE_HEADERS})