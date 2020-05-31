CRUNCH = ../bin/nucrunch

all: go.prg rgo.prg

run: go.prg
	open $<

rrun: rgo.prg
	open $<

go.prg: testbed.prg crunchedbmp.prg
	cbmcombine $^ >$@

rgo.prg: rtestbed.prg rcrunchedbmp.prg
	cbmcombine $^ >$@

rcrunchedbmp.prg: bmp0.prg bmp1.prg bmp_c.prg $(CRUNCH) Makefile
	$(CRUNCH) bmp1.prg bmp0.prg, bmp_c.prg -e 0x2000 -r -o $@ -L l0.log

crunchedbmp.prg: bmp0.prg bmp1.prg bmp_c.prg $(CRUNCH) Makefile
	$(CRUNCH) bmp1.prg bmp0.prg, bmp_c.prg -l 0x1000 -o $@ -L l0.log

bmp.prg bmp0.prg bmp1.prg bmp_c.prg: gentest.py crc8.py
	python $<

testbed.prg: ../decrunch.a65
rtestbed.prg: ../rdecrunch.a65

%.prg: %.a65
	xa $< -o $@ -l $@.lst

clean:
	/bin/rm -rf *.prg *.prg.lst __pycache__ *.pyc l*.log
