#
#	$Id$
#
# GU localisation module Makefile
#
ALL_TARGETS=build-module
CI_WIP=yes

all:	all-real

B_D=./build.host-local
HOST_SWIFTC=swiftc
SWIFT_SRCS!=ls *.swift
SWIFT_BRIDGING_HEADER=FSM-Bridging-Header.h
SWIFTCFLAGS=-I${SRCDIR}/../.. -I${SRCDIR}/../../../Common

build-module: host-local

.include "../../../mk/whiteboard.mk"    # I need the C whiteboard
.include "../swiftfsm.mk"
.include "../../../mk/mipal.mk"
