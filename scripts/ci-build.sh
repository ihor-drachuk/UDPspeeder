#!/usr/bin/env bash
# Build UDPspeeder for a given target in CI.
# Usage: scripts/ci-build.sh <target>
# Targets: amd64, arm64, armhf, win64, mac, mac-arm64

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
    amd64)
        CXX="${CXX:-g++}"
        OUT="${NAME}_amd64"
        "$CXX" "${COMMON_FLAGS[@]}" "${SOURCES[@]}" -lrt -lpthread -static -o "$OUT"
        ;;
    arm64)
        CXX="aarch64-linux-gnu-g++"
        OUT="${NAME}_arm64"
        "$CXX" "${COMMON_FLAGS[@]}" "${SOURCES[@]}" -lrt -lpthread -static -o "$OUT"
        ;;
    armhf)
        CXX="arm-linux-gnueabihf-g++"
        OUT="${NAME}_armhf"
        "$CXX" "${COMMON_FLAGS[@]}" "${SOURCES[@]}" -lrt -lpthread -static -o "$OUT"
        ;;
    win64)
        CXX="x86_64-w64-mingw32-g++"
        OUT="${NAME}.exe"
        "$CXX" "${COMMON_FLAGS[@]}" "${SOURCES[@]}" -static -lws2_32 -o "$OUT"
        ;;
    mac)
        CXX="${CXX:-clang++}"
        OUT="${NAME}_mac_x86_64"
        "$CXX" "${COMMON_FLAGS[@]}" "${SOURCES[@]}" -lpthread -arch x86_64 -o "$OUT"
        ;;
    mac-arm64)
        CXX="${CXX:-clang++}"
        OUT="${NAME}_mac_arm64"
        "$CXX" "${COMMON_FLAGS[@]}" "${SOURCES[@]}" -lpthread -arch arm64 -o "$OUT"
        ;;
    *)
        echo "unknown target: $TARGET" >&2
        exit 2
        ;;
esac

ls -la "$OUT"
file "$OUT" || true
