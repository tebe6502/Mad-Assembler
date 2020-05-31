
// 27.07.2009

@TAB_MEM_BANKS  EQU $0400	; pod tym adresem znajd¹ siê odnalezione banki dodatkowej pamiêci


        ORG $2000

main
        JSR @MEM_DETECT

	sta banks

	jsr printf
	dta 'Detected banks: %',0
	dta a(banks)

	jsr printf
	dta $9b,$9b,'Press any key...',$9b,0

	ldy #$ff
	sty 764

wait	ldy 764
	iny
	beq wait

	rts

banks	dta a(0)

	ICL 'procedures/@mem_detect.asm'

	.LINK 'libraries/stdio/lib/printf.obx'

        run main