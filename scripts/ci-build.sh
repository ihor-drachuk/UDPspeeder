#!/usr/bin/env bash
# Build UDPspeeder for a given target in CI.
# Usage: scripts/ci-build.sh <target>
# Targets: linux-amd64, linux-arm64, linux-armhf, windows-i686, macos-amd64, macos-arm64

set -euo pipefail

TARGET="${1:?usage: $0 <target>}"
NAME="speederv2"

SOURCES=(
    main.cpp log.cpp common.cpp
    lib/fec.cpp lib/rs.cpp
    crc32/Crc32.cpp
    packet.cpp delay_manager.cpp fd_manager.cpp
    connection.cpp fec_manager.cpp misc.cpp
    tunnel_client.cpp tunnel_server.cpp
    my_ev.cpp
)

COMMON_FLAGS=(
    -std=c++11
    -Wall -Wextra
    -Wno-unused-variable -Wno-unused-parameter -Wno-missing-field-initializers
    -O2
    -I. -isystem libev
)

echo "const char *gitversion = \"$(git rev-parse HEAD)\";" > git_version.h

case "$TARGET" in
    linux-amd64)
        CXX="${CXX:-g++}"
        OUT="${NAME}-linux-amd64"
        "$CXX" "${COMMON_FLAGS[@]}" "${SOURCES[@]}" -lrt -lpthread -static -o "$OUT"
        ;;
    linux-arm64)
        CXX="aarch64-linux-gnu-g++"
        OUT="${NAME}-linux-arm64"
        "$CXX" "${COMMON_FLAGS[@]}" "${SOURCES[@]}" -lrt -lpthread -static -o "$OUT"
        ;;
    linux-armhf)
        CXX="arm-linux-gnueabihf-g++"
        OUT="${NAME}-linux-armhf"
        "$CXX" "${COMMON_FLAGS[@]}" "${SOURCES[@]}" -lrt -lpthread -static -o "$OUT"
        ;;
    windows-i686)
        # -Wno-narrowing: libev/ev_win32.c initialises SOCKET (unsigned) with
        # -1, which modern g++ rejects as narrowing in C++11 aggregate init.
        # The value is then compared against INVALID_SOCKET, so the cast is
        # intentional; silencing is the minimal, non-invasive fix.
        CXX="i686-w64-mingw32-g++-posix"
        OUT="${NAME}-windows-i686.exe"
        "$CXX" "${COMMON_FLAGS[@]}" -Wno-narrowing "${SOURCES[@]}" -static -lws2_32 -o "$OUT"
        ;;
    macos-amd64)
        CXX="${CXX:-clang++}"
        OUT="${NAME}-macos-amd64"
        "$CXX" "${COMMON_FLAGS[@]}" "${SOURCES[@]}" -lpthread -arch x86_64 -o "$OUT"
        ;;
    macos-arm64)
        CXX="${CXX:-clang++}"
        OUT="${NAME}-macos-arm64"
        "$CXX" "${COMMON_FLAGS[@]}" "${SOURCES[@]}" -lpthread -arch arm64 -o "$OUT"
        ;;
    *)
        echo "unknown target: $TARGET" >&2
        exit 2
        ;;
esac

ls -la "$OUT"
file "$OUT" || true
