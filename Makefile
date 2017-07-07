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
	mkdir -p /usr/local/include/swiftfsm
	cp .build/${SWIFT_BUILD_CONFIG}/lib*.${EXT} /usr/local/lib/
	cp .build/${SWIFT_BUILD_CONFIG}/*.swift* /usr/local/include/swiftfsm/

.include "../../../mk/mipal.mk"		# comes last!

.if ${OS} == Darwin
LDFLAGS+=-lc++
.endif
