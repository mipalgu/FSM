#
#	$Id$
#
# GU localisation module Makefile
#
ALL_TARGETS=build-module
CI_WIP=yes

all:	all-real

SWIFT_SRCS!=ls *.swift

SWIFTCFLAGS=

build-module: host-local
	$Eenv ${BUILD_ENV} ${SWIFTC} ${SWIFT_MODULE} ${SWIFT_FRAMEWORKS} ${SWIFTCFLAGS} -emit-module ${SWIFT_SRCS} -o build.host-local/${MODULE_BASE}.swiftmodule

.include "../../../mk/mipal.mk"
