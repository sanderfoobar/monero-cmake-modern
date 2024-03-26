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

file(GLOB DAEMON_SOURCES
    *.cpp
    *.c
    *.cc
    *.h)

add_executable(daemon ${DAEMON_SOURCES})

target_link_libraries(daemon
  PRIVATE
    rpc
    blockchain_db
    cryptonote_core
    cncrypto
    common
    p2p
    cryptonote_protocol
    daemonizer
    serialization
    daemon_rpc_server
    version
    Boost::chrono
    Boost::program_options
    Boost::filesystem
    Boost::system
    Boost::thread
    Boost::regex
    Threads::Threads
    ${ZMQ_LIBRARIES}
    blocks)

target_include_directories(daemon
        PRIVATE ${ZMQ_INCLUDE_DIRS}
        PRIVATE ${OPENSSL_INCLUDE_DIR})

if(PER_BLOCK_CHECKPOINT)
  target_compile_definitions(daemon PUBLIC PER_BLOCK_CHECKPOINT=1)
endif()

set_property(TARGET daemon
  PROPERTY
    OUTPUT_NAME "monerod")

install(TARGETS daemon DESTINATION ${CMAKE_INSTALL_BINDIR})
