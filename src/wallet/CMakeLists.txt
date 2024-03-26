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

set(wallet_sources
    wallet2.cpp
    wallet_args.cpp
    ringdb.cpp
    node_rpc_proxy.cpp
    message_store.cpp
    message_transporter.cpp)

set(wallet_headers
    api/pending_transaction.h
    api/wallet.h
    api/wallet2_api.h
    wallet2.h
    api/address_book.h
    api/common_defines.h
    api/subaddress.h
    api/subaddress_account.h
    api/transaction_history.h
    api/transaction_info.h
    api/unsigned_transaction.h
    api/wallet_manager.h
    message_store.h
    message_transporter.h
    node_rpc_proxy.h
    ringdb.h
    wallet_args.h
    wallet_errors.h
    wallet_rpc_server.h
    wallet_rpc_server_commands_defs.h
    wallet_rpc_server_error_codes.h)

add_library(wallet ${wallet_sources})
target_sources(wallet
    PRIVATE
        ${wallet_sources}
    )

target_link_libraries(wallet
  PUBLIC
    rpc_base
    multisig
    common
    cryptonote_core
    mnemonics
    net
    lmdb
    Boost::chrono
    Boost::serialization
    Boost::filesystem
    Boost::system
    Boost::thread
    Boost::regex
    OpenSSL::SSL)

target_include_directories(wallet
        PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
        PUBLIC $<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/external/>
        PUBLIC $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/monero/>
        PRIVATE ${OPENSSL_INCLUDE_DIR}
        )

monero_install_library(wallet
        INCLUDE_DIR "${CMAKE_INSTALL_INCLUDEDIR}/monero/wallet/"
        HEADERS "${wallet_headers}")

# == rpc server

add_executable(wallet_rpc_server wallet_rpc_server.cpp)
target_link_libraries(wallet_rpc_server
  PRIVATE
    wallet
    rpc_base
    cryptonote_core
    cncrypto
    common
    version
    daemonizer
    Boost::chrono
    Boost::program_options
    Boost::filesystem
    Boost::thread
    Threads::Threads
    OpenSSL::SSL
    OpenSSL::Crypto)

target_include_directories(wallet_rpc_server
        PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
        PUBLIC $<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/external/>
        PUBLIC $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/monero/>
        PRIVATE ${OPENSSL_INCLUDE_DIR}
        )

set_property(TARGET wallet_rpc_server PROPERTY OUTPUT_NAME "monero-wallet-rpc")

install(TARGETS wallet_rpc_server
    EXPORT walletRpcServerTargets
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}/monero/
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}/monero/
    INCLUDES DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/monero/
    PUBLIC_HEADER DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/monero/
    )

add_subdirectory(api)
