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

SWIFTCFLAGS+=-L/usr/local/lib -I/usr/local/include

all:	all-real

install:
	sudo mkdir -p /usr/local/include/swiftfsm
	sudo mkdir -p /usr/local/lib/swiftfsm
	sudo cp .build/${SWIFT_BUILD_CONFIG}/lib*.${EXT} /usr/local/lib/swiftfsm/
	sudo cp .build/${SWIFT_BUILD_CONFIG}/*.swift* /usr/local/include/swiftfsm/

test:	swift-test-package

.include "../../../mk/mipal.mk"		# comes last!

CFLAGS+=-I../../../Common

.if ${OS} == Darwin
LDFLAGS+=-lc++
.endif
