/*
 *  NuCrunch 0.1
 *  Christopher Jam
 *  February 2016
 */

Requirements:

for building nucrunch itself, grab rust from rust-lang.org

The test suite currently requires
- xa65       (cf http://www.floodgap.com/retrotech/xa/)
- Python     (either 2.6+ or 3.0+ are fine)
- Numpy      ('sudo pip install numpy' should sort you for that)
- cbmcombine (comes with pucrunch)

Building

make
cd tests
make

Testing

cd tests
make run   ; test decrunch
make rrun  ; test rdecrunch

Each test decrunches a fullscreen koala in two segments, performs a CRC check (green border for success, red for failure)
waits one second
then decrunches an update, and CRC checks that.
First image is concentric circles with a rect of grey-on-grey noise
Second image is just the concentric circles.


Usage:
nucrunch input.prg [input2.prg ...] [-r] -o output.prg [-l 0xload_start| -e 0xload_end] [-L dump.log]

 -r	output for rdecrunch (unpacks from high to low)

 Use commas to delineate groups, eg
	../bin/nucrunch f1g1.prg f2g1.prg, f1g2.prg, f1g3,prg f2g3.prg f3g3.prg -o out.prg -l 0x1000

 Call decrunch to unpack the first group, then decrunch_next_group for each subsequent group

 Include either decrunch.a65 or ndecrunch.a65 in your executable

 define NUCRUNCH_ALIGN_FOR_SPEED to optimise alignment

 to decrunch using rdecrunch:

	ldx #<decrunch_src       ; where decrunch_src is the byte after the end of the crunched data (load_end)
	lda #>(decrunch_src-1)
	jsr decrunch
 
 to decrunch using decrunch:

	ldx #<decrunch_src
	lda #>decrunch_src
	jsr decrunch




