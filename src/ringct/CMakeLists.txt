# Copyright (c) 2016-2025, The Monero Project
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

set(ringct_basic_sources
    rctOps.cpp
    rctTypes.cpp
    rctCryptoOps.c
    multiexp.cc
    bulletproofs.cc
    bulletproofs_plus.cc)

set(ringct_basic_headers
    rctOps.h
    rctTypes.h
    rctCryptoOps.h
    multiexp.h
    bulletproofs.h
    bulletproofs_plus.h)


add_library(ringct_basic)
target_sources(ringct_basic
    PRIVATE
        ${ringct_basic_sources}
    )

target_link_libraries(ringct_basic
  PUBLIC
    common
    cncrypto
    OpenSSL::SSL
    OpenSSL::Crypto)

target_include_directories(ringct_basic
        PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/..>
        PUBLIC $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
        PUBLIC $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/monero/>
        PRIVATE ${OPENSSL_INCLUDE_DIR}
        )

add_library(ringct)
target_sources(ringct
    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/rctSigs.cpp
    )

target_link_libraries(ringct
  PUBLIC
    common
    cncrypto
    cryptonote_basic
    device
    OpenSSL::SSL)

target_include_directories(ringct
        PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/..>
        PUBLIC $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
        PUBLIC $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/monero/>
        PRIVATE ${OPENSSL_INCLUDE_DIR}
        )

monero_install_library(ringct_basic
        INCLUDE_DIR "${CMAKE_INSTALL_INCLUDEDIR}/monero/ringct/"
        HEADERS ${ringct_basic_headers})

monero_install_library(ringct
        INCLUDE_DIR "${CMAKE_INSTALL_INCLUDEDIR}/monero/ringct/"
        HEADERS rctSigs.h)
