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
SWIFT_BUILD_FLAGS=--destination destination.json

all:	all-real

install:
	mkdir -p /usr/local/include/swiftfsm
	cp .build/${SWIFT_BUILD_CONFIG}/lib*.${EXT} /usr/local/lib/
	cp .build/${SWIFT_BUILD_CONFIG}/*.swift* /usr/local/include/swiftfsm/

install-tc:
	mkdir -p /home/user/src/swift-tc/sysroot/home/nao/swift-tc/include/swiftfsm
	cp .build/${SWIFT_BUILD_CONFIG}/lib*.${EXT} /home/user/src/swift-tc/sysroot/home/nao/swift-tc/lib
	cp .build/${SWIFT_BUILD_CONFIG}/*.swift* /home/user/src/swift-tc/sysroot/home/nao/swift-tc/include/swiftfsm


generate-xcodeproj:
	$Ecp config.sh.in config.sh
	$Eecho "CCFLAGS=\"${CFLAGS:C,(.*),-Xcc \1,g}\"" >> config.sh
	$Eecho "LINKFLAGS=\"${LDFLAGS:C,(.*),-Xlinker \1,g}\"" >> config.sh
	$Eecho "SWIFTCFLAGS=\"${SWIFTCFLAGS:C,(.*),-Xswiftc \1,g}\"" >> config.sh
	$E./xcodegen.sh

.include "../../../mk/mipal.mk"		# comes last!

CFLAGS=-I/home/user/src/swift-tc/sysroot/home/nao/swift-tc/include -I/home/user/src/swift-tc/sysroot/home/nao/swift-tc/usr/local/include
CXXFLAGS=-I/home/user/src/swift-tc/sysroot/home/nao/swift-tc/include -I/home/user/src/swift-tc/sysroot/home/nao/swift-tc/usr/local/include
LDFLAGS=-fuse-ld=/home/user/src/swift-tc/ctc-linux64-atom-2.5.2.74/bin/i686-aldebaran-linux-gnu-ld -L/home/user/src/swift-tc/sysroot/home/nao/swift-tc/lib -L/home/user/src/swift-tc/sysroot/home/nao/swift-tc/usr/local/lib -L/home/user/src/swift-tc/sysroot/home/nao/swift-tc/lib/swift/linux -lgusimplewhiteboard

.if ${OS} == Darwin
LDFLAGS+=-lc++
.endif
