#
#	$Id$
#
# GU localisation module Makefile
#
ALL_TARGETS=build-module
CI_WIP=yes

all:	all-real

SWIFT_SRCS!=ls *.swift
SWIFT_BRIDGING_HEADER=FSM-Bridging-Header.h
SWIFTCFLAGS=-I${SRCDIR}/../.. -I${SRCDIR}/../../../Common

build-module: host-local
	$Eenv ${BUILD_ENV} ${SWIFTC} ${SWIFT_MODULE} ${SWIFT_FRAMEWORKS} ${SWIFTCFLAGS} -import-objc-header ${SWIFT_BRIDGING_HEADER}  -emit-module ${SWIFT_SRCS} -o build.host-local/${MODULE_BASE}.swiftmodule

build-archive:	host-local
	rm -f build.host-local/${BIN}.a
	ar cr build.host-local/${BIN}.a `ls build.host-local/*.o`

.include "../../../mk/whiteboard.mk"    # I need the C whiteboard
.include "../swiftfsm.mk"
.include "../../../mk/mipal.mk"
