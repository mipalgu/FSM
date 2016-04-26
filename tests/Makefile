#
#	$Id$
#
# GU localisation module Makefile
#
ALL_TARGETS=host
CI_WIP=yes
BIN=FSM_tests
TESTFILE=1

all:	all-real

HOST_SWIFTC=swiftc
SWIFT_SRCS!=ls *.swift
SWIFT_BRIDGING_HEADER=FSM_tests-Bridging-Header.h
SWIFTCFLAGS=-lFSM -I${SRCDIR}/../../.. -I${SRCDIR}/../../../../Common
ALL_HDRS!=ls *.h
#C_FLAGS=-lrt -ldl 
#C_SRCS!=ls *.c
LDFLAGS+=-lFSM

.include "../../../../mk/whiteboard.mk"    # I need the C whiteboard
.include "../../swiftfsm.mk"
.include "../../../../mk/mipal.mk"
