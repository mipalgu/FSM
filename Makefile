#
#	$Id$
#
# Global Makefile
#
.if ${OS} == Darwin
EXT=dylib
.else
EXT=so
.endif

NO_DEFAULT_DEPENDENCIES_TARGETS=yes

ALL_TARGETS=build

SWIFT_BUILD_CONFIG?=debug

USE_WB_LIB=yes

#.include "../../mk/subdir.mk"		# required for meta-makefiles


build:	clean
	env swift build -c ${SWIFT_BUILD_CONFIG} ${SWIFTCFLAGS:=-Xswiftc %} ${CFLAGS:=-Xcc %} ${LDFLAGS:=-Xlinker %}
	#cd machines && bmake && cd ../

install:	build
	sudo cp .build/${SWIFT_BUILD_CONFIG}/lib*.${EXT} /usr/local/lib/swiftfsm/
	sudo cp .build/${SWIFT_BUILD_CONFIG}/*.swift* /usr/local/lib/swiftfsm/
	sudo cp Packages/CGUSimpleWhiteboard*/module.modulemap /usr/local/lib/swiftfsm/CGUSimpleWhiteboard/
	sudo cp Packages/CGUSimpleWhiteboard*/*.h /usr/local/lib/swiftfsm/CGUSimpleWhiteboard/
	sudo ln -s /usr/local/lib/swiftfsm/*.swift* /usr/local/include/swiftfsm/
	sudo ln -s /usr/local/lib/swiftfsm/CGUSimpleWhiteboard/module.modulemap /usr/local/include/swiftfsm/CGUSimpleWhiteboard/
	sudo ln -s /usr/local/lib/swiftfsm/CGUSimpleWhiteboard/*.h /usr/local/include/swiftfsm/CGUSimpleWhiteboard/

test:	clean
	swift test ${SWIFTCFLAGS:=-Xswiftc %} ${CFLAGS:=-Xcc %} ${LDFLAGS:=-Xlinker %}

clean:
	swift build --clean
	#cd machines && bmake clean && cd ../

generate-kripke:
	#./.build/debug/swiftfsm -k -n "PingPong" ./machines/PingPong/build.host-local/libPingPong.${EXT}
	#./.build/debug/swiftfsm -k -n "BigPingPong" ./machines/BigPingPong/build.host-local/libBigPingPong.${EXT}
	#cd swiftfsm/build.host/ && ./swiftfsm -k -n "WBPingPong" ../../machines/WBPingPong/build.host-local/libWBPingPong.${EXT}
	#cd swiftfsm/build.host/ && ./swiftfsm -k -n "NuSMVTest" ../../machines/NuSMVTest/build.host-local/libNuSMVTest.${EXT}
	#cd swiftfsm/build.host/ && ./swiftfsm -k -n "OneMinuteMicrowave" ../../machines/OneMinuteMicrowave/build.host-local/libOneMinuteMicrowave.${EXT} -k -n "OneMinuteMicrowaveUser" ../../machines/OneMinuteMicrowave/user/build.host-local/libOneMinuteMicrowave_user.${EXT}
	#cd swiftfsm/build.host && cat ../../machines/OneMinuteMicrowave/specification.smv >> OneMinuteMicrowave.smv && NuSMV OneMinuteMicrowave.smv

build-kripke:	build	generate-kripke

.include "../swiftfsm.mk"
#.include "../../mk/mipal.mk"		# comes last!

.if ${OS} == Darwin
LDFLAGS+=-lc++
.endif
