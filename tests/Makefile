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

SWIFT_SRCS!=ls *.swift
SWIFT_BRIDGING_HEADER=FSM_tests-Bridging-Header.h
ALL_HDRS!=ls *.h
LDFLAGS+=-L/usr/local/lib -lFSM -lFunctional

.include "../../../../mk/whiteboard.mk"    # I need the C whiteboard
.include "../../swiftfsm.mk"
.include "../../../../mk/mipal.mk"
