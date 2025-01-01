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

# rpc base
set(RPC_BASE_HEADERS
    rpc_args.h
    rpc_payment_signature.h
    rpc_handler.h)

add_library(rpc_base)
target_sources(rpc_base
    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/rpc_args.cpp
        ${CMAKE_CURRENT_SOURCE_DIR}/rpc_payment_signature.cpp
        ${CMAKE_CURRENT_SOURCE_DIR}/rpc_handler.cpp
    )

target_link_libraries(rpc_base
  PUBLIC
    common
    epee
    Boost::regex
    Boost::thread
    Boost::program_options)

target_include_directories(rpc_base
        PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/../>
        PUBLIC $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/monero>
        PRIVATE ${ZMQ_INCLUDE_DIRS}
        PRIVATE ${OPENSSL_INCLUDE_DIR}
        )

monero_install_library(rpc_base
        INCLUDE_DIR "${CMAKE_INSTALL_INCLUDEDIR}/monero/rpc_base/"
        HEADERS "${RPC_BASE_HEADERS}")

# rpc
set(RPC_HEADERS
    rpc_version_str.h
    rpc_handler.h
    bootstrap_daemon.h
    core_rpc_server.h
    rpc_payment.h
    core_rpc_server_commands_defs.h
    core_rpc_server_error_codes.h)

add_library(rpc)
target_sources(rpc
    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/bootstrap_daemon.cpp
        ${CMAKE_CURRENT_SOURCE_DIR}/bootstrap_node_selector.cpp
        ${CMAKE_CURRENT_SOURCE_DIR}/core_rpc_server.cpp
        ${CMAKE_CURRENT_SOURCE_DIR}/rpc_payment.cpp
        ${CMAKE_CURRENT_SOURCE_DIR}/rpc_version_str.cpp
        ${CMAKE_CURRENT_SOURCE_DIR}/instanciations.cpp
    )

target_link_libraries(rpc
  PUBLIC
    rpc_base
    common
    cryptonote_core
    cryptonote_protocol
    net
    version
    Boost::regex
    Boost::thread)

target_include_directories(rpc
        PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/..>
        PUBLIC $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
        PUBLIC $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/monero/>
        PRIVATE ${ZMQ_INCLUDE_DIRS}
        PRIVATE ${OPENSSL_INCLUDE_DIR}
        )

monero_install_library(rpc
        INCLUDE_DIR "${CMAKE_INSTALL_INCLUDEDIR}/monero/rpc/"
        HEADERS "${RPC_HEADERS}")

# rpc pub
set(RPC_PUB_HEADERS
    zmq_pub.h)

add_library(rpc_pub)
target_sources(rpc_pub
    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/zmq_pub.cpp
    )

target_link_libraries(rpc_pub
  PUBLIC
    epee
    net
    cryptonote_basic
    serialization
    Boost::thread)

target_include_directories(rpc_pub
        PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/..>
        PUBLIC $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
        PUBLIC $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/monero/>
        PRIVATE ${ZMQ_INCLUDE_DIRS}
        PRIVATE ${OPENSSL_INCLUDE_DIR}
        )

monero_install_library(rpc_pub
    INCLUDE_DIR "${CMAKE_INSTALL_INCLUDEDIR}/monero/rpc_pub/"
    HEADERS "${RPC_PUB_HEADERS}")

# daemon messages
set(DAEMON_MESSAGES_HEADERS
    message.h
    daemon_messages.h)

add_library(daemon_messages
  message.cpp
  daemon_messages.cpp)

target_link_libraries(daemon_messages
  LINK_PRIVATE
    cryptonote_core
    cryptonote_protocol
    version
    serialization)

# daemon rpc server

add_library(daemon_rpc_server
  daemon_handler.cpp
  zmq_pub.cpp
  zmq_server.cpp
  message.h
  daemon_messages.h
  daemon_handler.h
  zmq_server.h)

target_link_libraries(daemon_rpc_server
  LINK_PRIVATE
    rpc
    rpc_pub
    cryptonote_core
    cryptonote_protocol
    version
    daemon_messages
    serialization
    Boost::chrono
    Boost::regex
    Boost::system
    Boost::thread
    ${ZMQ_LIBRARIES})

target_include_directories(daemon_rpc_server
        PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/../
        PRIVATE ${ZMQ_INCLUDE_DIRS}
        PRIVATE ${OPENSSL_INCLUDE_DIR})
