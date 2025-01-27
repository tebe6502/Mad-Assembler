;
; Inertia Player 4.5 by Profi/Madteam
;

ciov	= $E456

audf1	= $D200
audc1	= $D201
audc2	= $D203
audc3	= $D205
audc4	= $D207

skctl	= $D20F
	
portb	= $D301

dmactrl	= $D400

nmien	= $D40E

dmactls = $022F
dlptrs  = $0230

colpf1s	= $02C5
colpf2s	= $02C6
colbaks	= $02C8

KRPDEL	= $02D9
KEYREP	= $02DA
chbas	= $02F4
key     = $02FC

dosrun	= $000A
CLOCK	= $0014

iocom	= $0342
iosta	= $0343
ioadr	= $0344
iolen	= $0348
ioaux1	= $034A
ioaux2	= $034B


;--------------------------

covox		= $d600


loop_length	= $d8

buffer		= $2700

bnk_temp	= $b100

E_4000		= $4000

volume		= $d800

lfrq		= $ff00
hfrq		= $ff25

;--------------------------

	org $e0

tmp	.ds 2
hlp	.ds 2
pom	.ds 2
fnm	.ds 2
src	.ds 2
msg	.ds 2

	org $f0
	
dst	.ds 2
patno	.ds 1
patend	.ds 1
pataed	.ds 1
patadr	.ds 2
cnts	.ds 1
pause	.ds 1
num	.ds 1
lp	.ds 1
nr0	.ds 1
nr1	.ds 1
nr2	.ds 1
nr3	.ds 1


;--------------------------

	org $0400

song		.ds $80


sample_volume	.ds 32		; sample volume

sample_adr_l	.ds 32		; sample addres
sample_adr_h	.ds 32

sample_rep_l	.ds 32		; repeat point for sample (sample_rep = samples_adr + sample_rep)
sample_rep_h	.ds 32

sample_len_l	.ds 32		; sample length
sample_len_h	.ds 32

sample_rlen_l	.ds 32		; repeat length
sample_rlen_h	.ds 32

sample_bank	.ds 32


;--------------------------
	org $0600
;--------------------------

volume_slide

	sec
	lda player.vol0+2
vol0sub	sbc #$00
	cmp >volume
	bcs E_0611
	lda #$00
	sta vol0sub+1
	jmp E_0613

E_0611	sta player.vol0+2

E_0613	sec
	lda player.vol1+2
vol1sub	sbc #$00
	cmp >volume
	bcs E_0624
	lda #$00
	sta vol1sub+1
	jmp E_0626

E_0624	sta player.vol1+2

E_0626	sec
	lda player.vol2+2
vol2sub	sbc #$00
	cmp >volume
	bcs E_0637
	lda #$00
	sta vol2sub+1
	jmp E_0639

E_0637	sta player.vol2+2

E_0639	sec
	lda player.vol3+2
vol3sub	sbc #$00
	cmp >volume
	bcs E_0648
	lda #$00
	sta vol3sub+1
	rts

E_0648	sta player.vol3+2
	rts


;--------------------------
	org $2000
;--------------------------

fnt
	ins 'it45.fnt'

scr
	dta $51,$4D,$4D,$4D,$4D,$4D,$4D,$4D,$4D,$4D,$4D,$4D,$4D,$4D,$4D,$4D
	dta $4D,$4D,$4D,$4D,$4D,$4D,$4D,$4D,$4D,$4D,$4D,$4D,$4D,$4D,$4D,$45

	dta $56,d'Inertia 4.5  by  Profi/Madteam',$42

	dta $56,d'                              ',$42
	dta $56,d'                              ',$42
	dta $56,d'                              ',$42

E_24A0	dta $56,d'select device:              '
E_24BD	dta d'  '
	dta $42

E_24C0	dta $56,d'8-bit covox'*
	dta d'                 '
E_24DD	dta d'  '
	dta $42

E_24E0	dta $56,d'4-bit pokey                 '
E_24FD	dta d'  '
	dta $42

E_2500	dta $56,d'                        '
E_2519	dta d'      '
	dta $42

E_2520	dta $56,d'                  '
E_2533	dta d'      '				; extended ram value
	dta d'      '
	dta $42

E_2540	dta $56,d'                              ',$42
E_2560	dta $56,d'                              ',$42
E_2580	dta $56,d'                              ',$42
E_25A0	dta $56,d'                              ',$42
E_25C0	dta $56,d'                              ',$42
E_25E0	dta $56,d'                              ',$42

	dta $56
	dta d'name: '
E_2607	dta d'                        '
	dta $42

	dta $56,d'                              ',$42

E_2640	dta $56,d'          '
E_264B	dta d'   '
	dta d'                 ',$42

	dta $5A,$4E,$4E,$4E,$4E,$4E,$4E,$4E,$4E,$4E,$4E,$4E,$4E,$4E,$4E,$4E
	dta $4E,$4E,$4E,$4E,$4E,$4E,$4E,$4E,$4E,$4E,$4E,$4E,$4E,$4E,$4E,$43

/*
	dta $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dta $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dta $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dta $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dta $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dta $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dta $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dta $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dta $00,$00,$00
*/

;--------------------------
	org buffer
;--------------------------

; $2700
	.ds $0500


; read patterns, modify player

; track 0

E_2C00	ldy #$01
	lda (patadr),y
	and #$1F
	beq E_2C45
	sta nr0

	ldx nr0
	lda sample_volume,x
	sta player.vol0+2

E_2C11	ldy #$00
	lda (patadr),y
	and #$3F
	tax
	lda lfrq,x
	sta player.lfrq0+1
	lda hfrq,x
	sta player.hfrq0+1

	ldx nr0
	lda sample_bank,x
	sta player.bnk0+1

	lda sample_len_h,x
	sta player.end0+1

	lda sample_adr_l,x
	sta player.smp0+1
	lda sample_adr_h,x
	sta player.smp0+2

	lda sample_rep_l,x
	sta player.lrep0+1
	lda sample_rep_h,x
	sta player.hrep0+1

	jmp E_2C52

E_2C45	ldy #$00
	lda (patadr),y
	and #$3F
	cmp #$24
	beq E_2C52
	jmp E_2C11

E_2C52	ldy #$01
	lda (patadr),y
	and #$E0
	beq E_2CA0
	cmp #$20
	beq E_2C87
	cmp #$40
	beq E_2C8C
	cmp #$80
	beq E_2C9A
	cmp #$60
	beq E_2C7B
	cmp #$C0
	beq E_2C71
	jmp E_2CA0

E_2C71	ldy #$02
	lda (patadr),y
	sta vol0sub+1
	jmp E_2CA0

E_2C7B	ldy #$02
	clc
	lda player.smp0+2
	adc (patadr),y
	sta player.smp0+2
	jmp E_2CA0

E_2C87	inc patend
	jmp E_2CA0

E_2C8C	ldy #$02	; new volume smp0
	lda (patadr),y
	sta player.vol0+2
	lda #$00
	sta vol0sub+1
	jmp E_2CA0

E_2C9A	ldy #$02
	lda (patadr),y
	sta pause


; track 1

E_2CA0	ldy #$04
	lda (patadr),y
	and #$1F
	beq E_2CE4
	sta nr1
	tax
	lda sample_volume,x
	sta player.vol1+2

E_2CB0	ldy #$03
	lda (patadr),y
	and #$3F
	tax

	lda lfrq,x
	sta player.lfrq1+1
	lda hfrq,x
	sta player.hfrq1+1

	ldx nr1
	lda sample_bank,x
	sta player.bnk1+1

	lda sample_len_h,x
	sta player.end1+1

	lda sample_adr_l,x
	sta player.smp1+1
	lda sample_adr_h,x
	sta player.smp1+2

	lda sample_rep_l,x
	sta player.lrep1+1

	lda sample_rep_h,x
	sta player.hrep1+1

	jmp E_2CF1


E_2CE4	ldy #$03
	lda (patadr),y
	and #$3F
	cmp #$24
	beq E_2CF1
	jmp E_2CB0

E_2CF1	ldy #$04
	lda (patadr),y
	and #$E0
	beq E_2D3F
	cmp #$20
	beq E_2D26
	cmp #$40
	beq E_2D2B
	cmp #$80
	beq E_2D39
	cmp #$60
	beq E_2D1A
	cmp #$C0
	beq E_2D10
	jmp E_2D3F

E_2D10	ldy #$05
	lda (patadr),y
	sta vol1sub+1
	jmp E_2D3F

E_2D1A	ldy #$05
	clc
	lda player.smp1+2
	adc (patadr),y
	sta player.smp1+2
	jmp E_2D3F

E_2D26	inc patend
	jmp E_2D3F

E_2D2B	ldy #$05
	lda (patadr),y
	sta player.vol1+2
	lda #$00
	sta vol1sub+1
	jmp E_2D3F

E_2D39	ldy #$05
	lda (patadr),y
	sta pause

; track 2

E_2D3F	ldy #$07
	lda (patadr),y
	and #$1F
	beq E_2D83
	sta nr2
	tax
	lda sample_volume,x
	sta player.vol2+2

E_2D4F	ldy #$06
	lda (patadr),y
	and #$3F
	tax

	lda lfrq,x
	sta player.lfrq2+1
	lda hfrq,x
	sta player.hfrq2+1

	ldx nr2
	lda sample_bank,x
	sta player.bnk2+1

	lda sample_len_h,x
	sta player.end2+1

	lda sample_adr_l,x
	sta player.smp2+1
	lda sample_adr_h,x
	sta player.smp2+2

	lda sample_rep_l,x
	sta player.lrep2+1

	lda sample_rep_h,x
	sta player.hrep2+1

	jmp E_2D90


E_2D83	ldy #$06
	lda (patadr),y
	and #$3F
	cmp #$24
	beq E_2D90
	jmp E_2D4F

E_2D90	ldy #$07
	lda (patadr),y
	and #$E0
	beq E_2DDE
	cmp #$20
	beq E_2DC5
	cmp #$40
	beq E_2DCA
	cmp #$80
	beq E_2DD8
	cmp #$60
	beq E_2DB9
	cmp #$C0
	beq E_2DAF
	jmp E_2DDE

E_2DAF	ldy #$08
	lda (patadr),y
	sta vol2sub+1
	jmp E_2DDE

E_2DB9	ldy #$08
	clc
	lda player.smp2+2
	adc (patadr),y
	sta player.smp2+2
	jmp E_2DDE

E_2DC5	inc patend
	jmp E_2DDE

E_2DCA	ldy #$08
	lda (patadr),y
	sta player.vol2+2
	lda #$00
	sta vol2sub+1
	jmp E_2DDE

E_2DD8	ldy #$08
	lda (patadr),y
	sta pause

; track 3

E_2DDE	ldy #$0A
	lda (patadr),y
	and #$1F
	beq E_2E22
	sta nr3
	tax
	lda sample_volume,x
	sta player.vol3+2

E_2DEE	ldy #$09
	lda (patadr),y
	and #$3F
	tax

	lda lfrq,x
	sta player.lfrq3+1
	lda hfrq,x
	sta player.hfrq3+1

	ldx nr3
	lda sample_bank,x
	sta player.bnk3+1

	lda sample_len_h,x
	sta player.end3+1

	lda sample_adr_l,x
	sta player.smp3+1
	lda sample_adr_h,x
	sta player.smp3+2

	lda sample_rep_l,x
	sta player.lrep3+1

	lda sample_rep_h,x
	sta player.hrep3+1

	jmp E_2E2F

E_2E22	ldy #$09
	lda (patadr),y
	and #$3F
	cmp #$24
	beq E_2E2F
	jmp E_2DEE

E_2E2F	ldy #$0A
	lda (patadr),y
	and #$E0
	beq i_e
	cmp #$20
	beq E_2E64
	cmp #$40
	beq E_2E69
	cmp #$80
	beq E_2E77
	cmp #$60
	beq E_2E58
	cmp #$C0
	beq E_2E4E
	jmp i_e

E_2E4E	ldy #$0B
	lda (patadr),y
	sta vol3sub+1
	jmp i_e

E_2E58	ldy #$0B
	clc
	lda player.smp3+2
	adc (patadr),y
	sta player.smp3+2
	jmp i_e

E_2E64	inc patend
	jmp i_e

E_2E69	ldy #$0B
	lda (patadr),y
	sta player.vol3+2
	lda #$00
	sta vol3sub+1
	jmp i_e

E_2E77	ldy #$0B
	lda (patadr),y
	sta pause

;--------------------------

i_e	lda patend
	bne i_en

	lda patadr
	clc
	adc <12
	sta patadr
	lda patadr+1
	adc >12
	sta patadr+1
	cmp pataed
	bcc i_end

i_en	inc patno
	ldx patno
song_len cpx #$00
	bcc i_ens

	lda #$06
	sta pause

	ldx #$00
	stx patno

i_ens	lda song,x
	sta patadr+1
	clc
	adc #$03
	sta pataed

	lda #$00
	sta patadr

i_end	lda SKCTL
	and #$08
	beq E_2EC1

	lda pause
	sta cnts

	clc
	ldy #loop_length
	jmp player.loop

;--------------------------
;--------------------------

E_2EC1	jsr E_3994

	lda #$FF
	sta PORTB
	sta KEY
	lda #$40
	sta NMIEN
	lda #$21
	sta DMACTLS
	cli

	ldx <E_3A3A	; space-play,esc-exit,c-continue
	ldy >E_3A3A
	jsr message

E_2EDE	lda KEY
	cmp #$21
	beq E_2F03
	cmp #$12
	beq E_2EF0
	cmp #$1C
	beq E_2F21
	jmp E_2EDE

E_2EF0	lda #$00
	sta DMACTRL
	sta DMACTLS

	jsr os_off

	jsr E_3994

	ldy #loop_length
	jmp player.next_pattern


E_2F03	jsr wait

	jsr E_3994

	lda #$06
	sta pause

	lda song
	sta patadr+1
	clc
	adc #$03
	sta pataed

	lda #$00
	sta patadr

	jsr E_3994

	jmp E_3058


; read directory

E_2F21	jsr os_on

	lda <dlist
	sta DLPTRS
	lda >dlist
	sta DLPTRS+1

	lda #$21
	sta DMACTLS
	lda >fnt
	sta CHBAS
	lda #$14
	sta KRPDEL
	lda #$03
	sta KEYREP
	lda #$40
	sta NMIEN
	jsr E_39B4

	ldx <E_39BA	; space-directory
	ldy >E_39BA
	jsr message

E_2F51	lda KEY
	cmp #$21
	bne E_2F51

E_2F58	jsr E_3175

	jsr E_314D

	jsr E_319F

	jsr fclose

	jsr fdir

	jsr frecord

	jsr wait

	jsr fclose

	jsr E_315E

	jsr E_39B4

	lda #$00
	sta E_3C6C
	sta E_3C6D
	sta E_3C6B
	jsr E_31CF

	ldx <E_39DA	; move-cursor, return-load
	ldy >E_39DA
	jsr message

	lda E_3C6B
	beq E_2FD5
E_2F90	ldy #$02
E_2F92	lda (pom),y
	cpy #$0A
	beq E_2FA6
	sec
	sbc #$20
	beq E_2FA6
	dey
	dey
	sta (hlp),y
	iny
	iny
	iny
	bne E_2F92
E_2FA6	lda #$0E
	dey
	dey
	sta (hlp),y
	lda E_3238
	iny
	sta (hlp),y
	lda E_3238+1
	iny
	sta (hlp),y
	lda E_3238+2
	iny
	sta (hlp),y
	jsr E_3135

	jsr E_3141

	inc E_3C6C
	lda E_3C6C
	cmp E_3C6B
	beq E_2FD2
	jmp E_2F90

E_2FD2	dec E_3C6B
E_2FD5	ldx #$00
E_2FD7	lda E_24A0+1,x
	eor #$80
	sta E_24A0+1,x
	inx
	cpx #$0C
	bne E_2FD7
E_2FE4	lda KEY
	cmp #$0C
	beq E_3003
	cmp #$0F
	beq E_2FFA
	cmp #$0E
	beq E_2FFD
	cmp #$21
	beq E_3000
	jmp E_2FE4

E_2FFA	jmp E_3074

E_2FFD	jmp E_3088

E_3000	jmp E_2F58

E_3003	jsr E_3175

	jsr E_3183

	ldy #$00
	ldx #$03
E_300D	lda (fnm),y
	cmp #$20
	beq E_301C
	sta E_3228,x
	inx
	iny
	cpy #$08
	bne E_300D
E_301C	ldy #$08
	ldx #$0C
E_3020	lda (fnm),y
	sta E_3228,x
	inx
	iny
	cpy #$0B
	bne E_3020
	lda #$40
	sta NMIEN
	lda #$21
	sta DMACTLS
	cli

	ldx <E_3A1A	; loading
	ldy >E_3A1A
	jsr message

	jsr E_324D

	ldx <E_39FA	; space-play, esc-exit
	ldy >E_39FA
	jsr message

	jsr os_on

E_304A	lda KEY
	cmp #$21
	beq E_3058
	cmp #$1C
	beq E_306E
	jmp E_304A

E_3058	lda #$00
	sta DMACTRL
	sta DMACTLS
	jsr os_off

	jsr E_3994

	jsr E_3526

	ldy #loop_length
	jmp player.next_pattern

E_306E	jsr E_39B4

	jmp E_2F58

E_3074	lda E_3C6D
	cmp E_3C6B
	beq E_3082
	inc E_3C6D
	jsr E_30B0

E_3082	jsr E_39B4

	jmp E_2FE4

E_3088	lda E_3C6D
	beq E_3093
	dec E_3C6D
	jsr E_30C9

E_3093	jsr E_39B4

	jmp E_2FE4

E_3099	lda <E_24A0+1
	sta tmp
	lda >E_24A0+1
	sta tmp+1
	rts

E_30A2	ldy #$00
E_30A4	lda (tmp),y
	eor #$80
	sta (tmp),y
	iny
	cpy #$0C
	bne E_30A4
	rts

E_30B0	jsr E_3099

	ldx E_3C6D
	dex
	beq E_30BF
E_30B9	jsr E_30E8

	dex
	bne E_30B9
E_30BF	jsr E_30A2

	jsr E_30E8

	jsr E_30A2

	rts

E_30C9	jsr E_3099

	ldx E_3C6D
	inx
E_30D0	jsr E_30E8

	dex
	bne E_30D0
	jsr E_30A2

	sec
	lda tmp
	sbc #$20
	sta tmp
	bcs E_30E4
	dec tmp+1
E_30E4	jsr E_30A2

	rts

E_30E8	clc
	lda tmp
	adc #$20
	sta tmp
	bcc E_30F3
	inc tmp+1
E_30F3	rts

E_30F4	cpy #$88
	bne E_30F9
	rts

E_30F9	jmp E_36A4

fdir	lda <E_320F	; *.MOD
	sta IOADR,x
	lda >E_320F
	sta IOADR+1,x
	lda #$03
	sta IOCOM,x
	lda #$06
	sta IOAUX1,x
	jsr CIOV

	bmi E_30F4
	rts

frecord	lda <buffer
	sta IOADR,x
	lda >buffer
	sta IOADR+1,x
	lda <256
	sta IOLEN,x
	lda >256
	sta IOLEN+1,x
	lda #$07
	sta IOCOM,x
	jsr CIOV

	bmi E_30F4
	rts

E_3135	clc
	lda hlp
	adc #$20
	sta hlp
	bcc E_3140
	inc hlp+1
E_3140	rts

E_3141	lda pom
	clc
E_3144	adc #$12
	sta pom
	bcc E_314C
	inc pom+1
E_314C	rts

E_314D	lda <buffer
	sta pom
	lda >buffer
	sta pom+1

	lda <E_24A0+1
	sta hlp
	lda >E_24A0+1
	sta hlp+1
	rts

E_315E	ldx #$00
	ldy #$01
E_3162	lda buffer,x
	cmp #$9B
	beq E_316E
	iny
	inx
	jmp E_3162

E_316E	sty E_3144+1
	sty E_3193+1
	rts

E_3175	ldx #$00
E_3177	lda E_3218,x
	sta E_3228,x
	inx
	cpx #$0F
	bne E_3177
	rts

E_3183	lda <buffer+2
	sta fnm
	lda >buffer+2
	sta fnm+1

	ldx E_3C6D
	beq E_319E

E_3190	lda fnm
	clc
E_3193	adc #$20
	sta fnm
	bcc E_319B
	inc fnm+1
E_319B	dex
	bne E_3190
E_319E	rts

E_319F	lda #$00
	tax
E_31A2	sta buffer,x
	inx
	bne E_31A2

E_31A8	sta E_24A0+1,x
	sta E_24C0+1,x
	sta E_24E0+1,x
	sta E_2500+1,x
	sta E_2520+1,x
	sta E_2540+1,x
	sta E_2560+1,x
	sta E_2580+1,x
	sta E_25A0+1,x
	sta E_25C0+1,x
	sta E_25E0+1,x
	inx
	cpx #$1E
	bne E_31A8
	rts

E_31CF	ldx #$00
E_31D1	lda buffer,x
	cmp #$9B
	beq E_31DF
	inx
	bne E_31D1
	dec E_3C6B
	rts

E_31DF	inc E_3C6B
	inx
	bne E_31D1
	dec E_3C6B
	rts

wait	lda CLOCK
E_31EB	cmp CLOCK
	beq E_31EB
	rts

;--------------------------

dlist	dta 'pppppp'
	dta $42,a(scr)
	:19 dta $02
	dta $41,a(dlist)

;--------------------------

E_320F	dta c'D1:*.MOD',$9B

E_3218	dta c'D1:********.***',$9B

E_3228	dta c'D1:********.MOD',$9B

E_3238	dta c'-/$'

;--------------------------

E_323B	pla
	pla
	jsr fclose

	ldx <E_3B3A	; this is not mod file
	ldy >E_3B3A
	jsr message

	jsr read_key

	jmp E_2F21


E_324D	lda #$21
	sta DMACTLS
	lda #$40
	sta NMIEN
	jsr E_319F

	ldx <E_3228	; FILENAME.MOD
	ldy >E_3228
	lda #$03
	jsr fopen

	ldx <$043C
	ldy >$043C
	jsr flen

	ldx <buffer
	ldy >buffer
	lda #$07
	jsr fread

	ldy #$03		; test MOD header ('M.K.')
E_3275	lda E_3B9A,y
	cmp buffer+1080,y	; header 'M.K.'
	bne E_323B
	dey
	bpl E_3275
	jsr E_36F4

	jsr E_36EB

	lda #$00
	sta E_3C65

	lda #$01
	sta E_3290+1
E_3290	ldx #$00
E_3292	ldy #$2A
	lda (dst),y
	tax
	iny
	lda (dst),y
	jsr E_36D8

	ldx E_3290+1
	sta sample_len_l,x
	tya
	sta sample_len_h,x

	lda sample_len_h,x
	ora sample_len_l,x
	beq E_32B2
	inc E_3C65

E_32B2	ldy #$2D
	lda (dst),y
	and #$40
	bne E_32BE
	lda (dst),y
	and #$3F
E_32BE	lsr @
	clc
	adc #$D8
	sta sample_volume,x
	ldy #$2E
	lda (dst),y
	tax
	iny
	lda (dst),y
	jsr E_36D8

	ldx E_3290+1
	sta sample_rep_l,x
	tya
	sta sample_rep_h,x

	ldy #$30
	lda (dst),y
	tax
	iny
	lda (dst),y
	jsr E_36D8

	ldx E_3290+1
	sta sample_rlen_l,x
	tya
	sta sample_rlen_h,x

	clc
	lda dst
	adc #$1E
	sta dst
	bcc E_32FA
	inc dst+1
E_32FA	inc E_3290+1
	lda E_3290+1
	cmp #$20
	bne E_3292


;Offset  Bytes  Description
;------  -----  -----------
; 950      1    Songlength. Range is 1-128.
; 951      1    This byte is set to 127, so that old trackers will search
;               through all patterns when loading.
;               Noisetracker uses this byte for restart, ProTracker doesn't.
; 952    128    Song positions 0-127.  Each hold a number from 0-63 (or
;               0-127) that tells the tracker what pattern to play at that
;               position.
;1080      4    The four letters "M.K." - This is something Mahoney & Kaktus
;               inserted when they increased the number of samples from
;               15 to 31. If it's not there, the module/song uses 15 samples
;               or the text has been removed to make the module harder to
;               rip. Startrekker puts "FLT4" or "FLT8" there instead.
;               If there are more than 64 patterns, PT2.3 will insert M!K!
;               here. (Hey - Noxious - why didn't you document the part here
;               relating to YOUR OWN PROGRAM? -Vishnu)
;
;Offset  Bytes  Description
;------  -----  -----------
;1084    1024   Data for pattern 00.
;   .
;   .
;   .
;xxxx  Number of patterns stored is equal to the highest patternnumber
;      in the song position table (at offset 952-1079).
;
;  Each note is stored as 4 bytes, and all four notes at each position in
;the pattern are stored after each other.
;
;00 -  chan1  chan2  chan3  chan4
;01 -  chan1  chan2  chan3  chan4
;02 -  chan1  chan2  chan3  chan4
;etc.
;
;Info for each note:
;
; _____byte 1_____   byte2_    _____byte 3_____   byte4_
;/                \ /      \  /                \ /      \
;0000          0000-00000000  0000          0000-00000000
;
;Upper four    12 bits for    Lower four    Effect command.
;bits of sam-  note period.   bits of sam-
;ple number.                  ple number.


	lda buffer+950	; song length
	sta song_len+1

	lda buffer+952
	sta E_3318+1

	ldy #$00
	sty E_339D+1
E_3315	lda buffer+952,y
E_3318	cmp #$00
	bcc E_331F
	sta E_3318+1
E_331F	iny
	cpy #$80
	bne E_3315
	ldy E_3318+1
	iny
	sty num
	sty E_3C66
	cpy #$33
	bcc E_3343

	pla
	pla
	jsr fclose

	ldx <E_3B1A	; too many patterns
	ldy >E_3B1A
	jsr message

	jsr read_key

	jmp E_2F21

E_3343	ldy #$00
E_3345	ldx buffer+952,y	; song positions (128)
	lda pattern_adr,x
	sta song,y
	iny
	cpy #$80
	bne E_3345

	lda #$00
	tay
	sta E_3C71

	lda <1084
	sta E_3C6F
	lda >1084
	sta E_3C70

E_3363	clc
	lda E_3C6F
	adc sample_len_l,y
	sta E_3C6F
	lda E_3C70
	adc sample_len_h,y
	sta E_3C70
	lda E_3C71
	adc #$00
	sta E_3C71
	iny
	cpy #$20
	bne E_3363

	ldx E_3C66
E_3386	clc
	lda E_3C70
	adc #$04
	sta E_3C70
	lda E_3C71
	adc #$00
	sta E_3C71
	dex
	bne E_3386

	jsr mod_info

E_339D	ldy #$00
	lda pattern_adr,y
	sta src+1
	lda #$00
	sta src

	ldx <1024
	ldy >1024
	jsr flen

	jsr E_36EB

	lda #$07
	jsr fread

	lda #$00
	sta lp

E_33BB	ldy #$03
E_33BD	lda (dst),y
	sta note,y
	dey
	bpl E_33BD

	jsr os_off

	jsr E_3567

	jsr os_on

	clc
	lda src
	adc #$03
	sta src
	bcc E_33D9
	inc src+1

E_33D9	clc
	lda dst
	adc #$04
	sta dst
	bcc E_33E4
	inc dst+1

E_33E4	dec lp
	bne E_33BB

	inc E_339D+1
	dec num
	bne E_339D

	lda #$01
	sta E_33FF+1

	lda #$00
	sta E_3C67
	sta E_3C69
	jsr E_34AA

E_33FF	ldy #$01
	lda sample_len_l,y
	ora sample_len_h,y
	beq E_3458
	ldy E_33FF+1
	clc
	lda E_3C77
	adc sample_len_h,y
	adc #$01
	cmp #$7F
	bcc E_342D

	inc E_3C69
	lda E_3C69
	cmp E_3C6A
	beq E_342A
	jsr E_34AA

	jmp E_342D

E_342A	jmp E_34F5

E_342D	jsr E_34DF

	jsr E_34CE

	ldx sample_len_l,y
	lda sample_len_h,y
	tay
	jsr flen

	ldx src
	ldy src+1
	lda #$07
	jsr fread

	jsr E_3465

	jsr E_3951

	jsr E_34BB

	lda #$00
	sta src
	lda E_3C77
	sta src+1
E_3458	inc E_33FF+1
	lda E_33FF+1
	cmp #$20
	bne E_33FF
	jmp E_350C

E_3465	ldy E_33FF+1

	clc
	lda sample_adr_l,y
	adc sample_rep_l,y
	sta sample_rep_l,y
	lda sample_adr_h,y
	adc sample_rep_h,y
	sta sample_rep_h,y

	clc
	lda sample_adr_l,y
	adc sample_len_l,y
	sta sample_len_l,y
	lda sample_adr_h,y
	adc sample_len_h,y
	sta sample_len_h,y

	lda sample_rlen_l,y
	ora sample_rlen_h,y
	beq E_349B
	cmp #$02
	beq E_349B
	rts

E_349B	lda #$00
	sta sample_rep_l,y
	lda sample_len_h,y
	clc
	adc #$01
	sta sample_rep_h,y
	rts

E_34AA	lda #$00
	sta src
	sta E_3C76
	lda #$40
	sta src+1
	lda #$42
	sta E_3C77
	rts

E_34BB	ldy E_33FF+1
	lda sample_len_l,y
	sta E_3C76
	lda sample_len_h,y
	clc
	adc #$02
	sta E_3C77
	rts

E_34CE	lda #$00
	sec
	sbc sample_len_l,y
	sta src
	sta sample_adr_l,y
	lda src+1
	sta sample_adr_h,y
	rts

E_34DF	ldy E_33FF+1
	ldx E_3C69
	lda bnk_found,x
	sta PORTB
	lda bnk_found,x
	sec
	sbc #$01
	sta sample_bank,y	; banks code
	rts

E_34F5	lda #$FF
	sta PORTB
	pla
	pla
	jsr fclose

	ldx <E_3B7A	; out of memory
	ldy >E_3B7A
	jsr message

	jsr read_key

	jmp E_2F21

E_350C	jsr wait

	jsr E_3994

	lda #$06
	sta pause
	sta cnts

	lda song
	sta patadr+1
	clc
	adc #$03
	sta pataed
	jsr E_3994

	rts


E_3526	lda #$00
	sta patadr
	sta patno

	sta player.frac0+1
	sta player.frac1+1
	sta player.frac2+1
	sta player.frac3+1

	sta player.lfrq0+1
	sta player.lfrq1+1
	sta player.lfrq2+1
	sta player.lfrq3+1

	sta player.hfrq0+1
	sta player.hfrq1+1
	sta player.hfrq2+1
	sta player.hfrq3+1

	sta player.end0+1
	sta player.end1+1
	sta player.end2+1
	sta player.end3+1

	sta player.smp0+1
	sta player.smp1+1
	sta player.smp2+1
	sta player.smp3+1

	sta player.smp0+2
	sta player.smp1+2
	sta player.smp2+2
	sta player.smp3+2

	lda >volume
	sta player.vol0+2
	sta player.vol1+2
	sta player.vol2+2
	sta player.vol3+2

	rts

E_3567	lda note
	and #$0F
	ora note+1
	bne E_357F
	lda #$24
	ldy #$00
	sta (src),y
	iny
	lda #$00
	sta (src),y
	jmp E_35A7

E_357F	ldy #$00
E_3581	lda period_table,y
	cmp note+1
	bne E_359C
	lda note
	and #$0F
	cmp period_table+1,y
	bne E_359C
	tya
	lsr @
E_3595	ldy #$00
	sta (src),y
	jmp E_35A7

E_359C	iny
	iny
	cpy #$48
	bne E_3581
	lda #$24
	jmp E_3595

E_35A7	lda note+2
	jsr E_394C

	sta E_3C68

	lda note
	and #$10
	clc
	adc E_3C68
	ldy #$01
	sta (src),y
	tax
	lda sample_len_h,x
	ora sample_len_l,x
	bne E_35CC

	lda #$00
	ldy #$01
	sta (src),y
E_35CC	ldy #$02
	lda #$00
	sta (src),y
	ldy #$01
	lda note+2
	and #$0F
	cmp #$0C
	beq E_35F5
	cmp #$0F
	beq E_3610
	cmp #$0D
	beq E_35EE
	cmp #$09
	beq E_3627
	cmp #$0A
	beq E_3635
	rts

E_35EE	lda #$20
	ora (src),y
	sta (src),y
	rts

E_35F5	lda #$40
	ora (src),y
	sta (src),y

	ldy #$02
	lda note+3
	and #$40
	bne E_3609

	lda note+3
	and #$3F
E_3609	lsr @
	clc
	adc #$D8
	sta (src),y
	rts

E_3610	lda note+3
	cmp #$20
	bcs E_3626
	lda #$80
	ora (src),y
	sta (src),y
	ldy #$02
	lda note+3
	and #$1F
	sta (src),y
E_3626	rts

E_3627	lda #$60
	ora (src),y
	sta (src),y
	lda note+3
	ldy #$02
	sta (src),y
	rts

E_3635	lda note+3
	and #$0F
	beq E_364C
	lda #$C0
	ora (src),y
	sta (src),y
	lda note+3
	and #$0F
	lsr @
	ldy #$02
	sta (src),y
E_364C	rts

fopen	stx E_3658+1
	sty E_365D+1
	ldx #$10
	sta IOCOM,x
E_3658	lda #$00
	sta IOADR,x
E_365D	lda #$00
	sta IOADR+1,x
	lda #$04
	sta IOAUX1,x
	jsr CIOV

	bmi E_36A4
	rts

fclose	ldx #$10
	lda #$0C
	sta IOCOM,x
	jsr CIOV

	rts

flen	stx E_3694+1
	sty E_3699+1
	rts

fread	stx E_368A+1
	sty E_368F+1
	ldx #$10
	sta IOCOM,x
E_368A	lda #$00
	sta IOADR,x
E_368F	lda #$00
	sta IOADR+1,x
E_3694	lda #$00
	sta IOLEN,x
E_3699	lda #$00
	sta IOLEN+1,x
	jsr CIOV

	bmi E_36A4
	rts

E_36A4	cpy #$88
	beq E_36CB
	sty E_3C6E
	pla
	pla
	jsr fclose

	ldx <E_3B5A	; i/o error
	ldy >E_3B5A
	jsr message

	jsr E_37CA

	jsr read_key

	jmp E_2F21

os_off	sei
	lda #$00
	sta NMIEN
	lda #$FE
	sta PORTB
E_36CB	rts

os_on	lda #$FF
	sta PORTB
	lda #$40
	sta NMIEN
	cli
	rts

E_36D8	stx src
	sta src+1
	clc
	lda src+1
	adc src+1
	sta src+1
	lda src
	adc src
	tay
	lda src+1
	rts

E_36EB	ldx <buffer
	ldy >buffer
	stx dst
	sty dst+1
	rts

E_36F4	ldx #$00
E_36F6	lda buffer,x
	tay
	lda E_4000,y
	sta E_2607,x
	inx
	cpx #$14
	bne E_36F6
	rts

message	stx msg
	sty msg+1

	ldy #$00
E_370C	lda (msg),y
	sta E_2640,y
	iny
	cpy #$20
	bne E_370C
	rts

read_key
	lda KEY
	cmp #$21
	bne read_key
	rts

E_371F	lda E_3C6A
	cmp #$01
	bne E_3756
	jsr os_on

	lda <dlist
	sta DLPTRS
	lda >dlist
	sta DLPTRS+1
	lda #$21
	sta DMACTLS
	lda >fnt
	sta CHBAS
	lda #$B2
	sta COLPF2S

	ldx <E_3A5A	; i need extended ram
	ldy >E_3A5A
	jsr message

	jsr read_key

E_374C	lda KEY
	cmp #$21
	bne E_374C
	jmp (DOSRUN)

E_3756	ldx #$00
	stx E_3C62
	stx E_3C62+1
	stx E_3C62+2
E_3761	lda E_3A7A,x	; extended ram
	sta E_2520,x
	inx
	cpx #$20
	bne E_3761
	ldx E_3C6A
E_376F	sed
	clc
	lda E_3C62
	adc #$84
	sta E_3C62
	lda E_3C62+1
	adc #$63
	sta E_3C62+1
	lda E_3C62+2
	adc #$01
	sta E_3C62+2
	cld
	dex
	bne E_376F
	lda E_3C62
	tax
	and #$0F
	ora #$10
	sta E_2533+5
	txa
	jsr E_394C

	ora #$10
	sta E_2533+4
	lda E_3C62+1
	tax
	and #$0F
	ora #$10
	sta E_2533+3
	txa
	jsr E_394C

	ora #$10
	sta E_2533+2
	lda E_3C62+2
	tax
	and #$0F
	ora #$10
	sta E_2533+1
	txa
	jsr E_394C

	ora #$10
	sta E_2533
	rts

E_37CA	lda #$00
	sta E_3C62
	sta E_3C62+1
	ldx E_3C6E
E_37D5	clc
	sed
	lda E_3C62
	adc #$01
	sta E_3C62
	bcc E_37E4
	inc E_3C62+1
E_37E4	cld
	dex
	bne E_37D5
	lda E_3C62
	tax
	and #$0F
	ora #$10
	sta E_264B+2
	txa
	jsr E_394C

	ora #$10
	sta E_264B+1

	lda E_3C62+1
	and #$0F
	ora #$10
	sta E_264B
	rts

mod_info
	ldx #$00
E_3809	lda E_3A9A,x		; info about MOD (patterns, samples, length etc... )
	sta E_24A0,x
	inx
	cpx #$80
	bne E_3809
	lda #$00
	sta E_3C62

	ldx E_3C65
	beq E_382C
E_381E	clc
	sed
	lda E_3C62
	adc #$01
	sta E_3C62
	cld
	dex
	bne E_381E
E_382C	lda E_3C62
	and #$0F
	ora #$10
	sta E_24DD+1
	lda E_3C62
	jsr E_394C

	ora #$10
	sta E_24DD

	lda #$00
	sta E_3C62

	ldx E_3C66
E_3849	clc
	sed
	lda E_3C62
	adc #$01
	sta E_3C62
	cld
	dex
	bne E_3849
	lda E_3C62
	and #$0F
	ora #$10
	sta E_24BD+1
	lda E_3C62
	jsr E_394C

	ora #$10
	sta E_24BD
	lda #$00
	sta E_3C62
	ldx song_len+1
E_3874	clc
	sed
	lda E_3C62
	adc #$01
	sta E_3C62
	cld
	dex
	bne E_3874
	lda E_3C62
	and #$0F
	ora #$10
	sta E_24FD+1
	lda E_3C62
	jsr E_394C

	ora #$10
	sta E_24FD
	lda #$00
	sta E_3C62
	sta E_3C62+1
	sta E_3C62+2
	ldx E_3C71
	beq E_38C5
E_38A7	clc
	sed
	lda E_3C62
	adc #$36
	sta E_3C62
	lda E_3C62+1
	adc #$55
	sta E_3C62+1
	lda E_3C62+2
	adc #$06
	sta E_3C62+2
	cld
	dex
	bne E_38A7
E_38C5	ldx E_3C70
	beq E_38E8
E_38CA	clc
	sed
	lda E_3C62
	adc #$56
	sta E_3C62
	lda E_3C62+1
	adc #$02
	sta E_3C62+1
	lda E_3C62+2
	adc #$00
	sta E_3C62+2
	cld
	dex
	bne E_38CA
E_38E8	ldx E_3C6F
	beq E_390B
E_38ED	clc
	sed
	lda E_3C62
	adc #$01
	sta E_3C62
	lda E_3C62+1
	adc #$00
	sta E_3C62+1
	lda E_3C62+2
	adc #$00
	sta E_3C62+2
	cld
	dex
	bne E_38ED
E_390B	cld
	lda E_3C62
	and #$0F
	ora #$10
	sta E_2519+5
	lda E_3C62
	jsr E_394C

	ora #$10
	sta E_2519+4
	lda E_3C62+1
	and #$0F
	ora #$10
	sta E_2519+3
	lda E_3C62+1
	jsr E_394C

	ora #$10
	sta E_2519+2
	lda E_3C62+2
	and #$0F
	ora #$10
	sta E_2519+1
	lda E_3C62+2
	jsr E_394C

	ora #$10
	sta E_2519
	rts

E_394C
	lsr @
	lsr @
	lsr @
	lsr @

	rts

E_3951	lda src
	sta dst
	lda src+1
	sta dst+1

	ldy E_33FF+1
	lda sample_len_h,y
	sta E_3980+1

	ldy #$01
E_3964	lda (dst),y
	eor #$80
	sta num
	dey
	lda (dst),y
	eor #$80
	clc
	adc num
	ror @
	iny
	eor #$80
	sta (dst),y

	inc dst
	bne E_397E
	inc dst+1

E_397E	lda dst+1
E_3980	cmp #$00
	bne E_3964

	ldy #$00
	tya
E_3987	sta (dst),y
	iny
	bne E_3987
	inc dst+1
E_398E	sta (dst),y
	iny
	bne E_398E
	rts

E_3994	ldx #$00
E_3996	lda player,x
	tay
	lda zp_copy,x
	sta player,x
	tya
	sta zp_copy,x
	inx
	cpx #$F0
	bne E_3996
	rts

E_39A8	ldx #$00
E_39AA	lda .adr(player),x
	sta zp_copy,x
	inx
	bne E_39AA
	rts

E_39B4	lda #$FF
	sta KEY
	rts


; teksty

E_39BA	dta $56,d'space-directory               ',$42

E_39DA	dta $56,$53,$54,d'-move cursor   return-load  ',$42

E_39FA	dta $56,d'space-play     esc-exit       ',$42

E_3A1A	dta $56,d'loading                       ',$42

E_3A3A	dta $56,d'space-play,esc-exit,c-continue',$42

E_3A5A	dta $56,d'     i need extended ram      ',$42

E_3A7A	dta $56,d'     extended ram-       bytes',$42

E_3A9A	dta $56,d'                   patterns-  ',$42
	dta $56,d'                    samples-  ',$42
	dta $56,d'                song length-  ',$42
	dta $56,d'                 length-      ',$42

E_3B1A	dta $56,d'too many patterns             ',$42

E_3B3A	dta $56,d'this is not mod file          ',$42

E_3B5A	dta $56,d'i/o error                     ',$42

E_3B7A	dta $56,d'out of memory                 ',$42

E_3B9A	dta c'M.K.'


start

E_3B9E	ldy #$00
	sty DMACTRL
	sty DMACTLS
	tya
E_3BA7	sta bnk_temp,y
	iny
	bne E_3BA7
	ldy #$00
E_3BAF	tya
	ora #$01
	and #$EF
	sta PORTB
	sta E_4000
	iny
	bne E_3BAF
	ldy #$00
E_3BBF	tya
	ora #$01
	and #$EF
	sta PORTB
	ldx E_4000
	lda E_4000
	eor #$FF
	sta E_4000
	cmp E_4000
	bne E_3BE6
	eor #$FF
	sta E_4000
	cmp E_4000
	bne E_3BE6
	lda #$01
	sta bnk_temp,x
E_3BE6	iny
	bne E_3BBF
	ldy #$00
	ldx #$00
E_3BED	lda bnk_temp,y
	beq E_3BFB
	tya
	sta bnk_found,x
	inx
	cpx #$3C
	beq E_3BFE
E_3BFB	iny
	bne E_3BED

E_3BFE	lda #$FF
	sta PORTB
	stx E_3C6A	; banks number
	jsr E_371F

	jsr wait

	lda #$92
	sta COLPF2S
	lda #$0C
	sta COLPF1S
	jsr E_39A8

	jsr E_5000

	sei
	lda #$00
	sta NMIEN
	lda #$FE
	sta PORTB

	ldx #$00
E_3C29	lda volume_tab,x
E_3C2C	nop
E_3C2D	nop
E_3C2E	nop
E_3C2F	nop
E_3C30	nop
E_3C31	eor #$10
E_3C33	sta $D800,x
	sta $F800,x
	inx
	bne E_3C29
	inc E_3C29+2
	inc E_3C33+2
	lda E_3C33+2
	cmp #$F8
	bne E_3C29

	ldy #$00
E_3C4B	lda tab_frq,y
	sta lfrq,y
	iny
	bne E_3C4B

	lda #$FF
	sta PORTB
	lda #$40
	sta NMIEN
	cli
	jmp E_2F21

E_3C62	dta $00,$00,$00

E_3C65	brk
E_3C66	brk
E_3C67	brk
E_3C68	brk
E_3C69	brk
E_3C6A	brk
E_3C6B	brk
E_3C6C	brk
E_3C6D	brk
E_3C6E	brk
E_3C6F	brk
E_3C70	brk
E_3C71	brk

note	dta $00,$00,$00,$00

E_3C76	brk
E_3C77	brk

tab_frq
	dta l($0064)
	dta l($006A)
	dta l($0070)
	dta l($0077)
	dta l($007E)
	dta l($0086)
	dta l($008E)
	dta l($0096)
	dta l($009F)
	dta l($00A8)
	dta l($00B2)
	dta l($00BD)
	dta l($00C8)
	dta l($00D4)
	dta l($00E1)
	dta l($00EE)
	dta l($00FC)
	dta l($010B)
	dta l($011B)
	dta l($012C)
	dta l($013E)
	dta l($0151)
	dta l($0165)
	dta l($017A)
	dta l($0191)
	dta l($01A8)
	dta l($01C2)
	dta l($01DC)
	dta l($01F8)
	dta l($0217)
	dta l($0237)
	dta l($0258)
	dta l($027C)
	dta l($02A2)
	dta l($02CA)
	dta l($02F4)
	dta l($0000)

	dta h($0064)
	dta h($006A)
	dta h($0070)
	dta h($0077)
	dta h($007E)
	dta h($0086)
	dta h($008E)
	dta h($0096)
	dta h($009F)
	dta h($00A8)
	dta h($00B2)
	dta h($00BD)
	dta h($00C8)
	dta h($00D4)
	dta h($00E1)
	dta h($00EE)
	dta h($00FC)
	dta h($010B)
	dta h($011B)
	dta h($012C)
	dta h($013E)
	dta h($0151)
	dta h($0165)
	dta h($017A)
	dta h($0191)
	dta h($01A8)
	dta h($01C2)
	dta h($01DC)
	dta h($01F8)
	dta h($0217)
	dta h($0237)
	dta h($0258)
	dta h($027C)
	dta h($02A2)
	dta h($02CA)
	dta h($02F4)
	dta h($0000)

	dta $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dta $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dta $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dta $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dta $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dta $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dta $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dta $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dta $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dta $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dta $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dta $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dta $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dta $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dta $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dta $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dta $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dta $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dta $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dta $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

; zero page copy
;--------------------------

zp_copy	.ds $100

;--------------------------

;Periodtable for Tuning 0, Normal
;  C-1 to B-1 : 856,808,762,720,678,640,604,570,538,508,480,453
;  C-2 to B-2 : 428,404,381,360,339,320,302,285,269,254,240,226
;  C-3 to B-3 : 214,202,190,180,170,160,151,143,135,127,120,113
  
period_table
	dta a(856)
	dta a(808)
	dta a(762)
	dta a(720)
	dta a(678)
	dta a(640)
	dta a(604)
	dta a(570)
	dta a(538)
	dta a(508)
	dta a(480)
	dta a(453)

	dta a(428)
	dta a(404)
	dta a(381)
	dta a(360)
	dta a(339)
	dta a(320)
	dta a(302)
	dta a(285)
	dta a(269)
	dta a(254)
	dta a(240)
	dta a(226)

	dta a(214)
	dta a(202)
	dta a(190)
	dta a(180)
	dta a(170)
	dta a(160)
	dta a(151)
	dta a(143)
	dta a(135)
	dta a(127)
	dta a(120)
	dta a(113)

pattern_adr
	dta h($4200)
	dta h($4500)
	dta h($4800)
	dta h($4B00)
	dta h($4E00)
	dta h($5100)
	dta h($5400)
	dta h($5700)
	dta h($5A00)
	dta h($5D00)
	dta h($6000)
	dta h($6300)
	dta h($6600)
	dta h($6900)
	dta h($6C00)
	dta h($6F00)
	dta h($7200)
	dta h($7500)
	dta h($7800)
	dta h($7B00)
	dta h($FC00)
	dta h($F900)
	dta h($CC00)
	dta h($C900)
	dta h($C600)
	dta h($C300)
	dta h($C000)
	dta h($BD00)
	dta h($BA00)
	dta h($B700)
	dta h($B400)
	dta h($B100)
	dta h($AE00)
	dta h($AB00)
	dta h($A800)
	dta h($A500)
	dta h($A200)
	dta h($9F00)
	dta h($9C00)
	dta h($9900)
	dta h($9600)
	dta h($9300)
	dta h($9000)
	dta h($8D00)
	dta h($8A00)
	dta h($8700)
	dta h($8400)
	dta h($8100)
	dta h($7E00)

; detected banks (max 64)

bnk_found
	dta $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dta $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dta $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dta $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

	dta $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dta $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dta $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dta $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dta $00,$00,$00,$00,$00,$00,$00


;--------------------------
	org $5000
;--------------------------

E_5000	lda <dlist
	sta DLPTRS
	lda >dlist
	sta DLPTRS+1
	lda #$21
	sta DMACTLS

	lda >fnt
	sta CHBAS

	lda #$92
	sta COLPF2S
	lda #$00
	sta COLBAKS
	sta E_3C76
	jsr E_39B4

E_5024	lda KEY
	cmp #$0F
	beq E_5036
	cmp #$0E
	beq E_5049
	cmp #$0C
	beq E_505A
	jmp E_5024

E_5036	lda E_3C76
	cmp #$01
	beq E_5024
	inc E_3C76
	jsr E_50A5

	jsr E_39B4

	jmp E_5024

E_5049	lda E_3C76
	beq E_5024
	dec E_3C76
	jsr E_50A5

	jsr E_39B4

	jmp E_5024

E_505A	lda E_3C76
	beq E_50BB

	lda $D209
	cmp $D219
	beq E_506A
	jmp E_50DA

E_506A	jsr wait

	jsr os_off

	jsr E_3994

; POKEY mono

	lda >audf1
	sta player.reg0+2
	sta player.reg1+2
	sta player.reg2+2
	sta player.reg3+2

	lda <audc1
	sta player.reg0+1

	lda <audc2
	sta player.reg1+1

	lda <audc3
	sta player.reg2+1

	lda <audc4
	sta player.reg3+1

	lda #{lsr @}
	sta E_3C2C
	sta E_3C2D
	sta E_3C2E
	sta E_3C2F
	sta E_3C30

	jsr E_3994

	jsr E_319F

	rts

E_50A5	ldx #$0A
E_50A7	lda E_24C0+1,x
	eor #$80
	sta E_24C0+1,x
	lda E_24E0+1,x
	eor #$80
	sta E_24E0+1,x
	dex
	bpl E_50A7
	rts

E_50BB	jsr E_39B4

	jsr os_off

	jsr E_3994

; COVOX

	lda >covox
	sta player.reg0+2
	sta player.reg1+2
	sta player.reg2+2
	sta player.reg3+2

	lda #$00
	sta E_3C31+1
	jsr E_3994

	jsr E_319F

	rts

E_50DA	jsr wait

	jsr os_off

	jsr E_3994

; POKEY stereo

	lda >audf1
	sta player.reg0+2
	sta player.reg1+2
	sta player.reg2+2
	sta player.reg3+2

	lda <audc1
	sta player.reg0+1

	lda <[audc2+$10]
	sta player.reg1+1

	lda <[audc3+$10]
	sta player.reg2+1

	lda <audc4
	sta player.reg3+1

	lda #{lsr @}
	sta E_3C2C
	sta E_3C2D
	sta E_3C2E
	sta E_3C2F

	lda #{nop}
	sta E_3C30

	jsr E_3994

	jsr E_319F

	rts


;--------------------------
	org $8000
;--------------------------

volume_tab

	ins 'volume.dat'


;--------------------------
	org $B000
;--------------------------

.local	player,$0010

; channel #0

loop

bnk0	lda #$FE
	sta PORTB
frac0	lda #$00
lfrq0	adc #$00
	sta frac0+1
	lda smp0+1
hfrq0	adc #$00
	sta smp0+1
	bcc smp0
	inc smp0+2
	lda smp0+2
end0	cmp #$00
	bcc smp0
lrep0	lda #$00
	sta smp0+1
hrep0	lda #$00
	sta smp0+2
	jmp bnk1

smp0	ldx $4000
vol0	lda volume,x
reg0	sta covox

; channel #1

bnk1	lda #$FE
	sta PORTB
frac1	lda #$00
lfrq1	adc #$00
	sta frac1+1
	lda smp1+1
hfrq1	adc #$00
	sta smp1+1
	bcc smp1
	inc smp1+2
	lda smp1+2
end1	cmp #$00
	bcc smp1
lrep1	lda #$00
	sta smp1+1
hrep1	lda #$00
	sta smp1+2
	jmp bnk2

smp1	ldx $4000
vol1	lda volume,x
reg1	sta covox+1

; channel #2

bnk2	lda #$FE
	sta PORTB
frac2	lda #$00
lfrq2	adc #$00
	sta frac2+1
	lda smp2+1
hfrq2	adc #$00
	sta smp2+1
	bcc smp2
	inc smp2+2
	lda smp2+2
end2	cmp #$00
	bcc smp2
lrep2	lda #$00
	sta smp2+1
hrep2	lda #$00
	sta smp2+2
	jmp bnk3

smp2	ldx $4000
vol2	lda volume,x
reg2	sta covox+2

; channel #3

bnk3	lda #$FE
	sta PORTB
frac3	lda #$00
lfrq3	adc #$00
	sta frac3+1
	lda smp3+1
hfrq3	adc #$00
	sta smp3+1
	bcc smp3
	inc smp3+2
	lda smp3+2
end3	cmp #$00
	bcc smp3
lrep3	lda #$00
	sta smp3+1
hrep3	lda #$00
	sta smp3+2
	jmp skp

smp3	ldx $4000
vol3	lda volume,x
reg3	sta covox+3

skp	dey
	beq E_B0C2
	jmp loop

E_B0C2	jsr volume_slide

	dec cnts
	beq next_pattern

	ldy #loop_length
	jmp loop

next_pattern
	lda #$00
	sta patend

	lda #$FE
	sta PORTB
	jmp E_2C00
.endl

	run start
