TERMBOX_COMMIT = "b0776be8ab299d1280d06ad46953dd7498f63476"

.PHONY: all configure

all: build/termbox/build/src/libtermbox.a

configure:
	mkdir -p build
	cd build/termbox 2>/dev/null || git clone https://github.com/nsf/termbox.git build/termbox
	cd build/termbox && git checkout -b $(TERMBOX_COMMIT) $(TERMBOX_COMMIT)

build/termbox/build/src/libtermbox.a: build/termbox/src/termbox.c
	cd build/termbox && python waf configure && python waf
