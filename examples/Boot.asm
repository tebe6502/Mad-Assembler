;
;	Customer boot loader, MADS format, JAC!
;
; http://www.atariage.com/forums/topic/207712-how-to-make-your-own-bootdisk

sectors_size	= $80

main_start	= $0800
main_end	= $BFFF
main_size	= [main_end-main_start+1]
main_sector1	= $0002
main_sectors	= main_size/sectors_size
main_jmp	= $bfe0

sector_counter	= $80

	.print "Main memory : ",main_start,"-",main_end
	.print "Main sectors: ",main_sector1,"-",main_sector1+main_sectors-1

	opt h-f+

	org $700
load_address
	.word $0001		;Boot sector count Only low byte used
	.word load_address
	.word $ffff		;Relevant when using CASINI only

	lda #$ff		;Basic off
	sta $d301
	lda #0			;Loading noise off
	sta $41
	lda #1			;Drive #1
	sta $301
	lda #'R'		;'R'read
	sta $302
	mwa #main_start $304
	mwa #main_sector1 $30a

	mwa #main_sectors sector_counter
	sta sector_counter

load	jsr $e453		;load_from_disk
	bmi error

	adw $304 sectors_size	;Next memory location
	inw $30a		;Next sector
	dew sector_counter
	lda sector_counter
	ora sector_counter+1
	sta 712
	bne load
	jmp main_jmp

error	jmp $e477

	org load_address+$7f
	.byte 0			;Ensure $80 bytes size

