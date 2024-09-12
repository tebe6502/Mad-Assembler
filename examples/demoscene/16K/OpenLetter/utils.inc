ebecplusa
	clc
	adc $EB
	sta $EB
	bcc noplushec
	inc $EC
noplushec
	rts

setfont
	jsr wait_frame
	sta 756
	sta $D409
	rts
zeromove
	lda #$0
	tax
z_m
	sta move_data,x
	inx
	cpx #[move_data_e-move_data]
	bne z_m
	rts
calcmove
	lda move_data+1,X ; hl1+1 ; lsb,msb
	cmp move_data+5,X ;#$18+4
	bcs zobra1
	lda move_data+2,X ; de1
	clc
	adc move_data+4,X ; #$20
	sta move_data+2,X ; de1
	bcc zobra0
	inc move_data+3,X ;de1+1
zobra0
	jmp zobra2
zobra1
	lda move_data+2,X ;de1
	sec
	sbc move_data+4,X ;#$20
	sta move_data+2,X ;de1

	lda move_data+3,X ;de1+1
	sbc #$00
	sta move_data+3,X ;de1+1
zobra2
	lda move_data,X ;hl1
	clc
	adc move_data+2,X ;de1
	sta move_data,X ;hl1

	lda move_data+1,X ;hl1+1
	adc move_data+3,X ;de1+1
	sta move_data+1,X ;hl1+1
; value2
	rts
move_data
;md_v1
	dta 0,0 ;hl1 0 1
	dta 0,0 ;de1 2 3
	dta $26 ;bc 4
	dta $14 ; for cmp 5
;2
	dta 0,0 ;hl1 0 1
	dta 0,0 ;de1 2 3
	dta $24 ;+bc 4
	dta $8 ; for cmp 5
;3
	dta 0,0 ;hl1 0 1
	dta 0,0 ;de1 2 3
	dta $24 ;+bc 4
	dta $8 ; for cmp 5
;4
	dta 0,0 ;hl1 0 1
	dta 0,0 ;de1 2 3
	dta $22 ;+bc 4
	dta $0A ; for cmp 5
move_data_e


setdl
	jsr wait_frame
	stx $230
	stx $D402
	sty $231
	sty $D403
	rts
;set9
;	jsr wait_frame
;	lda #$40 ; GPRIOR
;setno9
;	sta $D01B
;	sta $26F
;	rts

wait_frame
RTCLOK      equ $0012
	pha
      lda RTCLOK+2
waits
      cmp RTCLOK+2
       beq waits
	pla
 rts

clear_ab
	jsr clear_a0
clear_b0
	lda #00
	tay
cb0
	sta $B000,y
	sta $B100,y
	sta $B200,y
	sta $B300,y
	sta $B400,y
	sta $B500,y
	sta $B600,y
	sta $B700,y
	sta $B800,y
	sta $B900,y
	sta $BA00,y
	sta $BB00,y
	sta $BC00,y
	sta $BD00,y
	sta $BE00,y
	sta $BF00,y
	iny
	bne cb0
	rts

clear_a0
	lda #00
	tay
ca0
	sta $A000,y
	sta $A100,y
	sta $A200,y
	sta $A300,y
	sta $A400,y
	sta $A500,y
	sta $A600,y
	sta $A700,y
	sta $A800,y
	sta $A900,y
	sta $AA00,y
	sta $AB00,y
	sta $AC00,y
	sta $AD00,y
	sta $AE00,y
	sta $AF00,y
	iny
	bne ca0
	rts
