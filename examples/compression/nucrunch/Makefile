CRUNCH = bin/nucrunch
ARCHIVE = nucrunch-0.1.tar

#.SUFFIXES:
#.SUFFIXES: .c .o .a65 .prg

$(CRUNCH): nucrunch.rs
	mkdir -p bin
	time rustc -C opt-level=3 -o $@ $^

archive:
	tar -s ",^,$(ARCHIVE)/," -cvf $(ARCHIVE) -T MANIFEST
	gzip $(ARCHIVE)

clean:
	/bin/rm -rf bin/* *.tar

