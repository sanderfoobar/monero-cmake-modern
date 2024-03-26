add_library(qrcodegen)

target_sources(qrcodegen
    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/QrCode.cpp
    )

target_include_directories(qrcodegen
        PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
        PUBLIC $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
        PUBLIC $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/monero/>
        )

monero_install_library(qrcodegen
        INCLUDE_DIR "${CMAKE_INSTALL_INCLUDEDIR}/monero/qrcodegen/"
        HEADERS QrCode.hpp)
