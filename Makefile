#
#	$Id$
#
# GU localisation module Makefile
#
ALL_TARGETS=build-module build-archive
CI_WIP=yes

all:	all-real

SWIFT_SRCS!=ls *.swift

build-module: host-local
	$Eenv ${BUILD_ENV} ${SWIFTC} ${SWIFT_MODULE} ${SWIFT_FRAMEWORKS} ${SWIFTCFLAGS} -emit-module ${SWIFT_SRCS} -o build.host-local/${MODULE_BASE}.swiftmodule

build-archive:	host-local
	rm -f build.host-local/${BIN}.a
	ar cr build.host-local/${BIN}.a `ls build.host-local/*.o`

.include "../../../mk/mipal.mk"
