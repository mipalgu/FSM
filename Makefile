#
#	$Id$
#
# GU localisation module Makefile
#
ALL_TARGETS=host-local
CI_WIP=yes

#XCTSCHEME=swiftfsm_local
#XCODEPROJ=../swiftfsm.xcodeproj

SWIFT_SRCS!=ls *.swift

#test:
#	xcodebuild -scheme ${XCTSCHEME} -project ${XCODEPROJ} -configuration Debug clean build test

.include "../../../mk/mipal.mk"
