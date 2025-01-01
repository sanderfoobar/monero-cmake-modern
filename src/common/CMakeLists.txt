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

file(GLOB COMMON_SOURCES "*.cpp" "*.c")
set(COMMON_HEADERS
    aligned.h
    apply_permutation.h
    base58.h
    combinator.h
    command_line.h
    common_fwd.h
    data_cache.h
    dns_utils.h
    download.h
    error.h
    expect.h
    http_connection.h
    i18n.h
    json_util.h
    notify.h
    password.h
    perf_timer.h
    pod-class.h
    powerof.h
    pruning.h
    rpc_client.h
    scoped_message_writer.h
    sfinae_helpers.h
    spawn.h
    stack_trace.h
    threadpool.h
    timings.h
    unordered_containers_boost_serialization.h
    updates.h
    utf8.h
    util.h
    varint.h)

add_library(common)
target_sources(common
    PRIVATE
        ${COMMON_SOURCES}
    )

target_link_libraries(common
  PUBLIC
    cncrypto
    easylogging
    Boost::chrono
    Boost::date_time
    Boost::filesystem
    Boost::thread
    Boost::regex
    Boost::system
    OpenSSL::SSL
    OpenSSL::Crypto
    Libunbound::Libunbound)

target_include_directories(common
        PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/../>
        PRIVATE $<BUILD_INTERFACE:${CMAKE_BINARY_DIR}/translations>
        PUBLIC $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
        PUBLIC $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/monero/>
        )

if(STATIC)
    target_compile_definitions(common PUBLIC STATICLIB=1)
endif()

add_dependencies(common generate_translations_header)

monero_install_library(common
        INCLUDE_DIR "${CMAKE_INSTALL_INCLUDEDIR}/monero/common/"
        HEADERS ${COMMON_HEADERS})
