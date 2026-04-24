# Native build targets for UDPspeeder.
#
# Cross-compilation and release bundling are done in CI — see
# .github/workflows/build.yml and scripts/ci-build.sh. The upstream
# makefile used to carry cross-toolchain targets with absolute paths
# hardcoded to the original author's machine; those have been removed.

cc_local=g++

SOURCES0=main.cpp log.cpp common.cpp lib/fec.cpp lib/rs.cpp crc32/Crc32.cpp packet.cpp delay_manager.cpp fd_manager.cpp connection.cpp fec_manager.cpp misc.cpp tunnel_client.cpp tunnel_server.cpp
SOURCES=${SOURCES0} my_ev.cpp -isystem libev
NAME=speederv2

FLAGS= -std=c++11   -Wall -Wextra -Wno-unused-variable -Wno-unused-parameter -Wno-missing-field-initializers ${OPT}

all: git_version
	rm -f ${NAME}
	${cc_local}   -o ${NAME}          -I. ${SOURCES} ${FLAGS} -lrt -ggdb -static -O2

freebsd: git_version
	rm -f ${NAME}
	${cc_local}   -o ${NAME}          -I. ${SOURCES} ${FLAGS} -lrt -ggdb -static -O2

mingw: git_version
	rm -f ${NAME}
	${cc_local}   -o ${NAME}          -I. ${SOURCES} ${FLAGS}  -ggdb -static -O2 -lws2_32

mingw_wepoll: git_version    # needs a libev patched with the wepoll backend
	rm -f ${NAME}
	${cc_local}   -o ${NAME}          -I. ${SOURCES0} ${FLAGS}  -ggdb -static -O2   -DNO_LIBEV_EMBED -D_WIN32 -lev -lws2_32

mac: git_version
	rm -f ${NAME}
	${cc_local}   -o ${NAME}          -I. ${SOURCES} ${FLAGS}  -ggdb -O2

cygwin: git_version
	rm -f ${NAME}
	${cc_local}   -o ${NAME}          -I. ${SOURCES} ${FLAGS} -lrt -ggdb -static -O2 -D_GNU_SOURCE

fast: git_version
	rm -f ${NAME}
	${cc_local}   -o ${NAME}          -I. ${SOURCES} ${FLAGS} -lrt -ggdb

debug: git_version
	rm -f ${NAME}
	${cc_local}   -o ${NAME}          -I. ${SOURCES} ${FLAGS} -lrt -Wformat-nonliteral -D MY_DEBUG -ggdb

debug2: git_version
	rm -f ${NAME}
	${cc_local}   -o ${NAME}          -I. ${SOURCES} ${FLAGS} -lrt -Wformat-nonliteral -ggdb

clean:
	rm -f ${NAME} ${NAME}.exe
	rm -f git_version.h

git_version:
	echo "const char *gitversion = \"$(shell git rev-parse HEAD)\";" > git_version.h
