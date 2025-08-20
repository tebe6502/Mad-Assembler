
	org $2000


.local	test

atari
	nop
	nop
.endl


.local second

	nop

	.local dup

	c64:
	mwa #0 $80

	ldx amstrad

	.endl

.endl


.local +test

	nop

	.local	+second.dup

	amstrad:
	lda c64
	nop

	.endl

	nop
.endl

.print *

	jmp :test

	lda second.dup


	run $2000