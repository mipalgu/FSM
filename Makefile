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

install:	build
	sudo cp .build/${SWIFT_BUILD_CONFIG}/lib*.${EXT} /usr/local/lib/swiftfsm/
	sudo cp .build/${SWIFT_BUILD_CONFIG}/*.swift* /usr/local/lib/swiftfsm/
	sudo cp Packages/CGUSimpleWhiteboard*/module.modulemap /usr/local/lib/swiftfsm/CGUSimpleWhiteboard/
	sudo cp Packages/CGUSimpleWhiteboard*/*.h /usr/local/lib/swiftfsm/CGUSimpleWhiteboard/
	sudo ln -s /usr/local/lib/swiftfsm/*.swift* /usr/local/include/swiftfsm/
	sudo ln -s /usr/local/lib/swiftfsm/CGUSimpleWhiteboard/module.modulemap /usr/local/include/swiftfsm/CGUSimpleWhiteboard/
	sudo ln -s /usr/local/lib/swiftfsm/CGUSimpleWhiteboard/*.h /usr/local/include/swiftfsm/CGUSimpleWhiteboard/

test:	swift-test-package

.include "../../../mk/mipal.mk"		# comes last!

CFLAGS+=-I../../../Common

.if ${OS} == Darwin
LDFLAGS+=-lc++
.endif
