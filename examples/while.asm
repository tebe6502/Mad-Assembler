
hlp	= $80

	org $2000

 	.var i,j .byte		; default i=0, j=0

main
 	mwa #$bc40 hlp
 
	#while	.byte j < #24

		mva #0 i

		ldx j
	
		#while .byte i < #40

	 		ldy i
		 	txa
		 	sta (hlp),y

		 	inc i

		#end

	adw hlp #40

	inc j

	#end

	jmp *

	run main