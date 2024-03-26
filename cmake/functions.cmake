include(GNUInstallDirs)
include(CMakePackageConfigHelpers)

function(monero_install_library targetName)
    set(flags)
    set(args)
    set(listArgs INCLUDE_DIR HEADERS)
    cmake_parse_arguments(arg "${flags}" "${args}" "${listArgs}" ${ARGN})

    set(include_dir "${arg_INCLUDE_DIR}")
    set(headers "${arg_HEADERS}")

    if(NOT include_dir)
        set(include_dir "${CMAKE_INSTALL_INCLUDEDIR}/monero/")
    endif()

    if(headers AND include_dir)
        install_with_directory(DESTINATION ${include_dir} FILES ${headers})
    endif()

    install(TARGETS ${targetName} EXPORT MoneroTargets
        RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}/monero/
        LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}/monero/
        ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}/monero/
        INCLUDES DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/monero/)
endfunction()

function(print_cmake_summary)
    message(STATUS "====== SUMMARY")
    message(STATUS "[+] MONERO VERSION: ${VERSION}")
    if(STATIC)
        message(STATUS "[+] STATIC: yes")
    else()
        message(STATUS "[+] STATIC: no")
    endif()
#    message(STATUS "[+] ARM: ${ARM}")
#    message(STATUS "[+] Android: ${ANDROID}")
#    message(STATUS "[+] iOS: ${IOS}")

    if(GIT_FOUND)
        execute_process(COMMAND git rev-parse "HEAD" WORKING_DIRECTORY ${CMAKE_SOURCE_DIR} OUTPUT_VARIABLE GIT_HEAD OUTPUT_STRIP_TRAILING_WHITESPACE)
        execute_process(COMMAND git rev-parse --abbrev-ref HEAD WORKING_DIRECTORY ${CMAKE_SOURCE_DIR} OUTPUT_VARIABLE GIT_BRANCH OUTPUT_STRIP_TRAILING_WHITESPACE)
        message(STATUS "[+] Git")
        message(STATUS "  - head: ${GIT_HEAD}")
        message(STATUS "  - branch: ${GIT_BRANCH}")
    endif()

    message(STATUS "[+] OpenSSL")
    message(STATUS "  - version: ${OPENSSL_VERSION}")
    message(STATUS "  - include: ${OPENSSL_INCLUDE_DIR}")
    message(STATUS "  - libs: ${OPENSSL_LIBRARIES}")

    message(STATUS "[+] Miniunpnp")
    get_target_property(miniupnpc_include miniupnpc::miniupnpc INTERFACE_INCLUDE_DIRECTORIES)
    message(STATUS "  - include: ${miniupnpc_include}")

    message(STATUS "[+] ZMQ")
    message(STATUS "  - dirs: ${ZMQ_INCLUDE_DIRS}")
    message(STATUS "  - libs: ${ZMQ_LIBRARIES}")

    message(STATUS "[+] Boost")
    message(STATUS "  - version: ${Boost_VERSION}")
    message(STATUS "  - dirs: ${Boost_INCLUDE_DIRS}")
    message(STATUS "  - libs: ${Boost_LIBRARIES}")

    message(STATUS "[+] Unbound")
    message(STATUS "  - version: ${LIBUNBOUND_VERSION}")
    message(STATUS "  - dirs: ${LIBUNBOUND_INCLUDE_DIR}")
    message(STATUS "  - libs: ${LIBUNBOUND_LIBRARIES}")

    message(STATUS "[+] Sodium")
    message(STATUS "  - version: ${sodium_VERSION_STRING}")
    message(STATUS "  - dirs: ${sodium_INCLUDE_DIR}")
    message(STATUS "  - libs: ${sodium_LIBRARY_RELEASE}")

    if(C_SECURITY_FLAGS)
        message(STATUS "C security hardening flags: ${C_SECURITY_FLAGS}")
    endif()
    if(CXX_SECURITY_FLAGS)
        message(STATUS "C++ security hardening flags: ${CXX_SECURITY_FLAGS}")
    endif()
    if(LD_SECURITY_FLAGS)
        message(STATUS "linker security hardening flags: ${LD_SECURITY_FLAGS}")
    endif()
endfunction()

macro(install_with_directory)
    set(optionsArgs "")
    set(oneValueArgs "DESTINATION")
    set(multiValueArgs "FILES")
    cmake_parse_arguments(CAS "${optionsArgs}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )

    foreach(FILE ${CAS_FILES})
        get_filename_component(DIR ${FILE} DIRECTORY)
        INSTALL(FILES ${FILE} DESTINATION ${CAS_DESTINATION}/${DIR})
    endforeach()
endmacro(install_with_directory)