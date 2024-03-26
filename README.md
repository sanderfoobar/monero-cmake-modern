## Introduction

Monero is challenging to integrate due to its CMake. If we look at any project that 
uses the wallet2 interface (GUI, Feather, Monerujo, Cake, monero-cpp) we see a pattern of 
developers fighting the build system in order to link against libwallet_merged, resorting to 
including Monero in the source tree, hardcode include paths, and fiddle around with 
CMake variables from the root project.

Modern CMake tells us the `target_` family of functions should be used to provide preprocessor definitions, 
compiler options, include paths, and libraries specifically per target. For example, Monero 
currently has global calls like `include_directory()`, which adds `-I` everywhere, which may lead to 
unexpected errors.

Libraries generally install into `/usr/local/` and provide a pkg/CMake config so that consumers can 
find and use the library. Unfortunately Monero does not have this. 

This branch adds modern CMake and support for installing. This not only benefits third-party developers 
but also package maintainers, as distributions can now more easily package Monero. 

### Example: wallet creation

We can use `find_package(Monero 0.18.3.3 REQUIRED)` to find Monero with a minimum version.

```cmake
cmake_minimum_required(VERSION 3.25)
project(test)
set(CMAKE_CXX_STANDARD 17)

find_package(Monero 0.18.3.3 REQUIRED)
add_executable(test main.cpp)

target_link_libraries(test PUBLIC monero::wallet_api)
```

With a `monero::wallet_api` to link against. The include paths are set automatically.

```cpp
#include "wallet/api/wallet.h"

int main() {
  Monero::WalletManager *wm = Monero::WalletManagerFactory::getWalletManager();
  wm->createWallet("/tmp/foo", "", "English", false);
  return 0;
}
```

When we run the program we can see it writes a wallet file:

```bash
$ ./test

$ ls /tmp/foo*
/tmp/foo  /tmp/foo.keys

$ du -h test
15M	test
```

And it is statically linked (because I compiled Monero statically):

```
$ ldd test
	linux-vdso.so.1 (0x00007fff1db45000)
	libunbound.so.8 => /usr/local/lib/libunbound.so.8 (0x000076bbdb703000)
	libstdc++.so.6 => /lib/x86_64-linux-gnu/libstdc++.so.6 (0x000076bbdb400000)
	libm.so.6 => /lib/x86_64-linux-gnu/libm.so.6 (0x000076bbdb319000)
	libgcc_s.so.1 => /lib/x86_64-linux-gnu/libgcc_s.so.1 (0x000076bbdc6ef000)
	libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x000076bbdb000000)
	/lib64/ld-linux-x86-64.so.2 (0x000076bbdc73e000)
	libssl.so.3 => /lib/x86_64-linux-gnu/libssl.so.3 (0x000076bbdb65f000)
	libcrypto.so.3 => /lib/x86_64-linux-gnu/libcrypto.so.3 (0x000076bbdaa00000)
```

During CMake configure, library details are displayed, for easy linkage/version confirmation.

```text
-- ====== SUMMARY
-- [+] MONERO VERSION: 0.18.3.3
-- [+] STATIC: yes
-- [+] OpenSSL
--   - version: 1.1.1i
--   - include: /usr/local/openssl/include
--   - libs: /usr/local/openssl/lib/libssl.a;/usr/local/openssl/lib/libcrypto.a;dl
-- [+] Miniunpnp
--   - include: /usr/local/include
--   - libs: $<LINK_ONLY:miniupnpc::miniupnpc-private>
-- [+] ZMQ
--   - dirs: /usr/local/include
--   - libs: /usr/local/lib/libzmq.a
-- [+] Boost
--   - version: 1.74.0
--   - dirs: /usr/local/include
--   - libs: Boost::system;Boost::filesystem;Boost::thread;Boost::date_time;Boost::chrono;Boost::regex;Boost::serialization;Boost::program_options;Boost::locale
-- [+] Unbound
--   - version: 1.16.2
--   - dirs: /usr/local/include
--   - libs: unbound
-- [+] Sodium
--   - version: 1.0.18
--   - dirs: /usr/include
--   - libs: /usr/lib/x86_64-linux-gnu/libsodium.a
```

## Example: mnemonics

Every target in Monero is available under the `monero::` namespace. Linking against `monero::mnemonics` 
would allow:

```cpp
#include "mnemonics/electrum-words.h"
#include "mnemonics/language_base.h"

using namespace std;
int main() {
  vector<string> language_list;
  crypto::ElectrumWords::get_language_list(language_list);

  for(const auto &lang: language_list) {
    cout << lang << "\n";
  }
```

```text
Deutsch
English
Español
Français
Italiano
Nederlands
Português
русский язык
日本語
简体中文 (中国)
Esperanto
Lojban
```

The resulting executable was 1mb.

## Installation

Installation is just your regular CMake dance:

```bash
cmake -Bbuild .
make -Cbuild -j12
sudo make -Cbuild install 
```

Which will end up in `/usr/local/`.

### Custom prefix directory

```bash
cmake -Bbuild . -DCMAKE_INSTALL_PREFIX=/tmp/test .
```

You'll need `list(INSERT CMAKE_PREFIX_PATH 0 "/tmp/test/lib/cmake/monero")` in your CMake to account for the custom installation directory.

### results

Installation will look like this:

```text
$ find /tmp/test/             
/tmp/test/
/tmp/test/bin
/tmp/test/bin/monero-wallet-rpc
/tmp/test/bin/monerod
/tmp/test/lib
/tmp/test/lib/cmake
/tmp/test/lib/cmake/monero
/tmp/test/lib/cmake/monero/MoneroConfigVersion.cmake
/tmp/test/lib/cmake/monero/MoneroConfig.cmake
/tmp/test/lib/cmake/monero/MoneroTargets-release.cmake
/tmp/test/lib/cmake/monero/modules
/tmp/test/lib/cmake/monero/modules/FindLibUSB.cmake
/tmp/test/lib/cmake/monero/modules/Findsodium.cmake
[...]
/tmp/test/lib/cmake/monero/modules/functions.cmake
/tmp/test/lib/cmake/monero/modules/FindLibunwind.cmake
/tmp/test/lib/cmake/monero/modules/Version.cmake
/tmp/test/lib/cmake/monero/modules/FindReadline.cmake
/tmp/test/lib/cmake/monero/MoneroTargets.cmake
/tmp/test/lib/monero
/tmp/test/lib/monero/libblocks.a
/tmp/test/lib/monero/librpc_pub.a
/tmp/test/lib/monero/libeasylogging.a
/tmp/test/lib/monero/libcommon.a
/tmp/test/lib/monero/libwallet-crypto.a
/tmp/test/lib/monero/libversion.a
/tmp/test/lib/monero/libp2p.a
[...]
/tmp/test/lib/monero/libwallet_api.a
/tmp/test/lib/monero/libcryptonote_basic.a
/tmp/test/lib/monero/libcheckpoints.a
/tmp/test/lib/monero/libringct.a
/tmp/test/include
/tmp/test/include/monero
/tmp/test/include/monero/cryptonote_protocol
/tmp/test/include/monero/cryptonote_protocol/cryptonote_protocol_defs.h
/tmp/test/include/monero/cryptonote_protocol/cryptonote_protocol_handler_common.h
/tmp/test/include/monero/cryptonote_protocol/levin_notify.h
/tmp/test/include/monero/cryptonote_protocol/block_queue.h
/tmp/test/include/monero/cryptonote_protocol/fwd.h
/tmp/test/include/monero/cryptonote_protocol/cryptonote_protocol_handler.h
/tmp/test/include/monero/cryptonote_protocol/enums.h
/tmp/test/include/monero/cryptonote_config.h
/tmp/test/include/monero/common
/tmp/test/include/monero/common/varint.h
/tmp/test/include/monero/common/password.h
[...]
```

### Static build

```bash
cmake -Bbuild -DSTATIC=1 
  -DOPENSSL_LIBRARIES=/usr/local/openssl/lib/ 
  -DOPENSSL_ROOT_DIR=/usr/local/openssl 
  -DBOOST_ROOT=/usr/local .
```

Static build deps (tested on Ubuntu 22.04):

```bash
#!/bin/bash
#run as root/sudo

export OPENSSL_ROOT_DIR=/usr/local/openssl/
export CFLAGS="-fPIC"
export CPPFLAGS="-fPIC"
export CXXFLAGS="-fPIC"

# boost
wget https://boostorg.jfrog.io/artifactory/main/release/1.73.0/source/boost_1_73_0.tar.gz
tar -xzf boost_1_73_0.tar.gz
pushd boost_1_73_0
./bootstrap.sh
./b2 --with-atomic --with-system --with-filesystem --with-thread --with-date_time --with-chrono --with-regex --with-serialization --with-program_options --with-locale variant=release link=static runtime-link=static cflags="-fPIC" cxxflags="-fPIC" install -a --prefix=/usr/local/
popd
rm -rf boost_1_73_0

# openssl
wget https://www.openssl.org/source/openssl-1.1.1i.tar.gz
tar -xvf openssl-1.1.1i.tar.gz
rm -xvf openssl-1.1.1i.tar.gz
pushd openssl-1.1.1i
./config no-shared no-dso --prefix=/usr/local/openssl
make -j8
make install
popd
rm -rf openssl-1.1.1i

# expat
wget https://github.com/libexpat/libexpat/releases/download/R_2_4_8/expat-2.4.8.tar.bz2
tar -xf expat-2.4.8.tar.bz2
rm expat-2.4.8.tar.bz2
pushd expat-2.4.8
./configure --enable-static --disable-shared --prefix=/usr/local/expat/
make -j8
make -j8 install
popd
rm -rf expat-2.4.8

# libunbound
wget https://www.nlnetlabs.nl/downloads/unbound/unbound-1.16.2.tar.gz
tar -xzf unbound-1.16.2.tar.gz
rm unbound-1.16.2.tar.gz
pushd unbound-1.16.2
./configure --disable-shared --enable-static --without-pyunbound --with-libexpat=/usr/local/expat/ --with-ssl=/usr/local/openssl/ --with-libevent=no --without-pythonmodule --disable-flto --with-pthreads --with-libunbound-only --with-pic
make -j8
make -j8 install
popd
rm -rf unbound-1.16.2

# zmq
git clone -b v4.3.2 --depth 1 https://github.com/zeromq/libzmq
pushd libzmq
git reset --hard a84ffa12b2eb3569ced199660bac5ad128bff1f0
./autogen.sh
./configure --disable-shared --enable-static --disable-libunwind --with-libsodium
make -j8
make -j8 install
popd
rm -rf libzmq

# zlib
git clone -b v1.2.11 --depth 1 https://github.com/madler/zlib
pushd zlib
git reset --hard cacf7f1d4e3d44d871b605da3b647f07d718623f
./configure --static --prefix=/usr/local/zlib
make -j8
make -j8 install
popd
rm -rf zlib

# libusb
git clone -b v1.0.23 --depth 1 https://github.com/libusb/libusb
pushd libusb
git reset --hard e782eeb2514266f6738e242cdcb18e3ae1ed06fa
./autogen.sh --disable-shared --enable-static
make -j8
make -j8 install
popd
rm -rf libusb

# libsodium
# on ubuntu, `libsodium-dev` already comes with a static .a

# miniupnp
git clone -b miniupnpc_2_2_1 --depth 1 https://github.com/miniupnp/miniupnp.git
pushd miniupnp/miniupnpc
git reset --hard 544e6fcc73c5ad9af48a8985c94f0f1d742ef2e0
cmake -Bbuild -DUPNPC_BUILD_STATIC=1 -DUPNPC_BUILD_SHARED=OFF -DUPNPC_BUILD_TESTS=OFF -DUPNPC_BUILD_SAMPLE=OFF .
sudo make -Cbuild -j8 install
popd
rm -rf miniupnp
```

## Closing

This branch is a proof-of-concept, and currently only supports x86_64 linux static/shared builds as the CMake was 
basically rewritten (`CMakeLists.txt` reduced from 1200 lines to 140).

More information:

- Forked from commit [c821478](https://github.com/monero-project/monero/commit/c8214782fb2a769c57382a999eaf099691c836e7).
- Removed support for Apple/Windows/iOS/ARM/PowerPC/RISC/BSD
- Removed vendored libraries: rapidjson, miniupnp
- both supercop/randomx were forked in order to change their CMake
- supercop currently only compiles `amd64-64-24k`
- Removed the various compiler flags
- Removed unit tests, documentation, fuzzing support
- Removed Trezor support
