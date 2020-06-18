TERMBOX_COMMIT = "b0776be8ab299d1280d06ad46953dd7498f63476"

.PHONY: all configure

all: build/termbox-1.1.2/build/src/libtermbox.a

configure:
	mkdir -p build
	curl -L https://github.com/nsf/termbox/archive/v1.1.2.tar.gz --output build/termbox.tar.gz
	cd build && tar -xf termbox.tar.gz
	cp -v waf build/termbox-1.1.2

build/termbox-1.1.2/build/src/libtermbox.a: build/termbox-1.1.2/src/termbox.c
	cd build/termbox-1.1.2 && python waf configure && python waf
