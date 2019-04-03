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

.ifdef SYSROOT
export LANG=/usr/lib/locale/en_US
ROOT=${SYSROOT}
.else
ROOT=
.endif

SWIFTCFLAGS+=-L${ROOT}/usr/local/lib -I${ROOT}/usr/local/include -I${GUNAO_DIR}/posix/CLReflect
.ifdef SYSROOT
SWIFT_BUILD_FLAGS+=--destination destination.json
.endif

all:	all-real

install:
	mkdir -p ${ROOT}/usr/local/include/swiftfsm
	cp .build/${SWIFT_BUILD_CONFIG}/lib*.${EXT} ${ROOT}/usr/local/lib/
	cp .build/${SWIFT_BUILD_CONFIG}/*.swift* ${ROOT}/usr/local/include/swiftfsm/

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

xc-clean:

.include "../../../mk/mipal.mk"		# comes last!

CFLAGS=-I${ROOT}/include -I${ROOT}/usr/local/include -I${GUNAO_DIR}/posix/CLReflect -I${GUNAO_DIR}/Common
CXXFLAGS=-I${ROOT}/include -I${ROOT}/usr/local/include -I${GUNAO_DIR}/posix/CLReflect
LDFLAGS=-L${ROOT}/usr/local/lib -lgusimplewhiteboard

.ifdef SYSROOT
LDFLAGS+=-L${ROOT} -L${ROOT}/lib/swift/linux -fuse-ld=/home/user/src/swift-tc/ctc-linux64-atom-2.5.2.74/bin/i686-aldebaran-linux-gnu-ld 
.endif

.if ${OS} == Darwin
LDFLAGS+=-lc++
.endif
