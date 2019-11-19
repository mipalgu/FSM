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

.include "../../mk/prefs.mk"

CFLAGS=-I${GUNAO_DIR}/posix/CLReflect -I${GUNAO_DIR}/Common
CXXFLAGS=-I${GUNAO_DIR}/posix/CLReflect
LDFLAGS=-lgusimplewhiteboard

all:	all-real

generate-xcodeproj:
	$Ecp config.sh.in config.sh
	$Eecho "CCFLAGS=\"${CFLAGS:C,(.*),-Xcc \1,g}\"" >> config.sh
	$Eecho "LINKFLAGS=\"${LDFLAGS:C,(.*),-Xlinker \1,g}\"" >> config.sh
	$Eecho "SWIFTCFLAGS=\"${SWIFTCFLAGS:C,(.*),-Xswiftc \1,g}\"" >> config.sh
	$E./xcodegen.sh

xc-clean:

.include "../../../mk/mipal.mk"		# comes last!
