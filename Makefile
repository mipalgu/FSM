#
#	$Id$
#
# Global Makefile
#

ALL_TARGETS=host-local

.if ${OS} == Darwin
EXT=dylib
.else
EXT=so
.endif

SWIFTCFLAGS+=-L/usr/local/lib -I/usr/local/include -I${GUNAO_DIR}/posix/CLReflect

all:	all-real

install:
	mkdir -p /usr/local/include/swiftfsm
	cp .build/${SWIFT_BUILD_CONFIG}/lib*.${EXT} /usr/local/lib/
	cp .build/${SWIFT_BUILD_CONFIG}/*.swift* /usr/local/include/swiftfsm/

generate-xcodeproj:
	$Ecp config.sh.in config.sh
	$Eecho "CCFLAGS=\"${CFLAGS:C,(.*),-Xcc \1,g}\"" >> config.sh
	$Eecho "LINKFLAGS=\"${LDFLAGS:C,(.*),-Xlinker \1,g}\"" >> config.sh
	$Eecho "SWIFTCFLAGS=\"${SWIFTCFLAGS:C,(.*),-Xswiftc \1,g}\"" >> config.sh
	$E./xcodegen.sh

.include "../../../mk/mipal.mk"		# comes last!

.if ${OS} == Darwin
LDFLAGS+=-lc++
.endif
