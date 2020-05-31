
	org $4000

font1	equ $8000
font2	equ $8400


init	mva >font2 fontwsk
	mva #2 linewsk

	jsr fontcopy
	jsr wait_vbl

	mva	#0	$d40e
	mwa	#dli	$200
	mwa	#dlist	$230
	mwa	#vbl	$222
	mva	#$c0	$d40e

loop	jmp loop

wait_vbl mva #1 $21c
wait0    lda $21c
         bne wait0
         rts

vbl      mva >font2 fontwsk
         mva #2 linewsk

         jmp $e45f		; jmp SYSVBL $C0E2


fontcopy   ldx #127
fontcopy0  ldy #5
fontcopy1  lda font1,y
fontcopy2  sta font2+2,y-
           bpl fontcopy1
           lda fontcopy1+1
           add #8
           sta fontcopy1+1
           lda fontcopy1+2
           adc #0
           sta fontcopy1+2
           lda fontcopy2+1
           add #8
           sta fontcopy2+1
           lda fontcopy2+2
           adc #0
           sta fontcopy2+2
           dex
           bpl fontcopy0
           rts


dli		pha

		sta $d40a
		lda #0
linewsk		equ *-1
		sta $d405
                eor #7
		sta linewsk

		lda #0
fontwsk		equ *-1
		sta $d409
                eor #4
		sta fontwsk

		lda $d20a
		sta $d01a

                pla
		rti


	org $5000

screen	equ *
	dta d'THETA MUSIC COMPOSER VER 2.00 BY JASKIER'
	dta d'                                        '
	dta d'PATTERN: -00E L: TRAC1 TRAC2 TRAC3 TRAC4'
	dta d'                                        '
	dta d'00 --- -- --  00 00-00 00-00 00-00 00-00'
	dta d'00 --- -- --     00-00 00-00 00-00 00-00'
	dta d'00 --- -- --  00 00-00 00-00 00-00 00-00'
	dta d'00 --- -- --     00-00 00-00 00-00 00-00'
	dta d'00 --- -- --  00 00-00 00-00 00-00 00-00'
	dta d'00 --- -- --     00-00 00-00 00-00 00-00'
	dta d'00 --- -- --  00 00-00 00-00 00-00 00-00'
	dta d'00 --- -- --     00-00 00-00 00-00 00-00'
	dta d'00 --- -- --  00 00-00 00-00 00-00 00-00'
	dta d'00 --- -- --     00-00 00-00 00-00 00-00'
	dta d'00 --- -- --                            '
	dta d'00 --- -- --                            '
	dta d'00 --- -- --                            '
	dta d'00 --- -- --                            '
	dta d'00 --- -- --                            '
	dta d'00 --- -- --  __________________________'
	dta d'00 --- -- --                            '
	dta d'00 --- -- --                            '
	dta d'00 --- -- --                            '
	dta d'00 --- -- --                            '
	dta d'00 --- -- --  __________________________'
	dta d'00 --- -- --                            '
	dta d'00 --- -- --  00000000000000000000000000'
	dta d'00 --- -- --  00000000000000000000000000'
	dta d'00 --- -- --  00000000000000000000000000'
	dta d'00 --- -- --  00000000000000000000000000'
	dta d'                INS:      00 00 00 00 00'
screeninf equ *
	dta d'SP:0 FR:0 0-0   -00E   00 00 00 00 00 00'
	dta d' FREE:  0000     00 00 00 00 00 00 00 00'
	dta d'                                        '
screenslupy equ *
	dta d'HEAVEN                                  '
	dta d'  OF                                    '
	dta d'TAQUART                                 '
	dta d' 2004                                   '
	dta d'________________________________________'


dlist	dta $a0,$e2,a(screen)
	:19    dta $82,$a2
	dta b($41),a(dlist)


	org font1
	ins 'tmcprog.fnt'

	run init
