
// packfire -t filename.in filename.out

dest	= $8010


	org	$2000

dl	dta d'ppp'
	dta $4e,a($8010)
	:101 dta $e
	dta $4e,a($9000)
	:91 dta $e
	dta $41,a(dl)

main
	mwa #dl 560
	
	mwa #data compressed_data
	mwa #dest decompressing

	jsr PackFireTiny

	jmp *


data
	ins 'koronis.pcf'

	
; -------------------------------

	icl 'depack.asm'

; -------------------------------


	run main