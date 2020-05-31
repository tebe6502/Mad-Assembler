NLines equ 40
TexDim equ 133

BasOct equ %00100010
BasVol equ %10110111

ZpVar equ $e4

	org ZpVar
num1 org *+2
num2 org *+1
zoom org *+1
ang  org *+1

	org ZpVar
lcnt org *+1
angs org *+1

cxl  org *+1
cyl  org *+1
cxh  org *+1
cyh  org *+1
dcxl org *+1
dcyl org *+1
dcxh org *+1
dcyh org *+1
stxl org *+1
styl org *+1
stxh org *+1
styh org *+1
vdxl org *+1
vdyl org *+1
vdxh org *+1
vdyh org *+1

tdx  org *+1
colz org *+6

baso org *+1

	ert *>$100

	org $2000

TextureMem org *+TexDim*256

	ert [*&$ff]!=0

DisplayList
	dta $70,$70,$b0,$6f
DisplayList_ScreenAddr
	dta a(Screen2)
DisplayList_Lines
	org *+[NLines-2]
	dta $8f
  	dta $41,a(DisplayList)

ZoomTable   dta 63,68,73,78,84,90,96,103,110,118,127,136,145,156,167,179
ZoomSteps   equ *-ZoomTable

CurCenter  dta 81+>TextureMem,81+>TextureMem,54+>TextureMem,54+>TextureMem
CenterDxL  dta $a0,$10,$c0,$50
CenterDxH  dta $fc,$fc,$fd,$fe

BasNotes1
	dta $73,$73,$55,$61
BasLength equ *-BasNotes1

Notes equ *-1
;      0   1   2   3   4   5   6   7   8   9   a   b
;    D-1 G-1 A-1 C-2 D-2 F-2 G-2 A-2 A#2 C-3 D-3 C-1
; dta $b5
 dta     $a1,$8f,$78,$6b,$5a,$50,$47,$43,$3c,$35,$f0

Music
	dta $04|%11000000
	dta $05|%11000000
	dta $06|%11000000
	dta $0a|%10000000
	dta $04|%11000000
	dta $04|%10000000
	dta $05|%11000000
	dta $06|%11000000
	dta $0a|%11000000

	dta $09|%11000000
	dta $07|%11000000
	dta $06|%11000000
	dta $05|%10000000
	dta $06|%11000000
	dta $06|%10000000
	dta $05|%11000000
	dta $04|%11000000
	dta $03|%10000000
	dta $0a|%00100000

	dta $09|%11000000
	dta $07|%11000000
	dta $09|%10000000
	dta $0a|%11000000
	dta $0a|%10000000
	dta $09|%11000000
	dta $07|%11000000
	dta $06|%11000000

	dta $09|%11000000
	dta $07|%11000000
	dta $06|%11000000
	dta $04|%10000000
	dta $03|%00100000
	dta $02|%11000000
	dta $01|%11000000
	dta $0b|%11000000

MusicLength equ *-Music

; unpacking quadrant to halfcircle saves only one byte so maybe later...
SinHalf dta 021,041,062
        dta 082,102,121,139
        dta 156,172,187,201
        dta 213,224,233,241
        dta 247,251,254,255
		dta 254,251,247
		dta 241,233,224,213
		dta 201,187,172,156
		dta 139,121,102,082
		dta 062,041,021,000
SinSteps    equ *-SinHalf

	ert [SinSteps%2]!=0
RotateSpeed equ *-1
        dta 1,1,2,1,2,3,4,5,4,3,2,1,1,0,75,74,73,72,72,71,72,73,74,75
RotateSpeedLength equ *-RotateSpeed

FirstCol equ 1

; num1*num2/128 => (x,a)
MulU8_Div128
	lda #$00
	tax
	stx num1+1
	beq MulU8_EnterLoop
MulU8_DoAdd
	add num1
	tay
	txa
	adc num1+1
	tax
	tya
MulU8_Loop
	asl num1
	rol num1+1
MulU8_EnterLoop
	lsr num2
	bcs MulU8_DoAdd
	bne MulU8_Loop
	asl @
	txa
	asl @
	ldx #0
	scc:inx   ; (x,a)/128 => (x,a)
	rts

Start
	sei
	lda #3
	sta $d20f
	sta $d21f
	ldx #0
	stx $d40E
	stx $d40a
	mvx #$fe $d301

InstallZpCode
	ldx #ZpCodeLength
	mva:rne ZpCode-1,x z:$ff,x-

FillDList
	ldx #NLines-2
	lda #$2f
FillDList_1
	sta DisplayList_Lines-1,x
	eor #$a0
	dex:bne FillDList_1

UnpackDeltas
	mva #ZoomSteps-1 zoom
UnpackDeltas_ZoomLoop
	mva #128-[2*SinSteps] UnpackDeltas_Angle+1
UnpackDeltas_Loop
	mva #SinSteps-1 ang
UnpackDeltas_AngLoop
	ldx zoom
	mva ZoomTable,x num1
	ldx ang
	mva SinHalf,x num2
	jsr MulU8_Div128 ;	num1*num2/128 => (x,a)
UnpackDeltas_Angle
	ldy #0
UnpackDeltas_Eor1
	eor #0
UnpackDeltas_Add1
	add #0
UnpackDeltas_AddrDrL
	sta DrL,y
	txa
UnpackDeltas_Eor2
	eor #0
	adc #0
UnpackDeltas_AddrDrH
	sta DrH,y
	inc UnpackDeltas_Angle+1
	dec ang
	bpl UnpackDeltas_AngLoop
	lda UnpackDeltas_Eor1+1
	eor #$ff
	sta UnpackDeltas_Eor1+1
	sta UnpackDeltas_Eor2+1
	and #1
	sta UnpackDeltas_Add1+2
	bne UnpackDeltas_Loop
	inc UnpackDeltas_AddrDrH+2
	inc UnpackDeltas_AddrDrL+2
	dec zoom
	bpl UnpackDeltas_ZoomLoop

; rysujemy tylko gorna lewa cwiartke + troche
PrepareTexture
	ldx #FirstCol
PrepareTexture_Level
	lda #[>TextureMem]
	add z:SquareSz-FirstCol,x
	cmp #[>TextureMem]+TexDim
	bcs PrepareTexture_NoDraw
PrepareTexture_YGo
	sta PrepareTexture_Store+2
	adc z:SquareSz-FirstCol,x
	cmp #[>TextureMem]+TexDim
	scc:lda #[>TextureMem]+TexDim
	sta PrepareTexture_YLimit+1
PrepareTexture_YLoop
	lda z:SquareSz-FirstCol,x
	add #[>TextureMem]
PrepareTexture_XLoop
	sta PrepareTexture_Store+1
	ldy z:SquareSz-FirstCol,x
	txa
PrepareTexture_Draw
	dey
PrepareTexture_Store
	sta a:$4000,y
	bne PrepareTexture_Draw
	lda PrepareTexture_Store+1
	add z:SquareSz-FirstCol+1,x
	bcs PrepareTexture_NextY
	cmp #[>TextureMem]+TexDim
	bcc PrepareTexture_XLoop
PrepareTexture_NextY
	inc:lda PrepareTexture_Store+2
PrepareTexture_YLimit
	cmp #0
	bcc PrepareTexture_YLoop
	lda PrepareTexture_Store+2
	sub z:SquareSz-FirstCol,x
	add z:SquareSz-FirstCol+1,x
	cmp #[>TextureMem]+TexDim
	bcc PrepareTexture_YGo
PrepareTexture_NoDraw
	inx
	cpx #7
	bcc PrepareTexture_Level

InitScreen
	mva #$21 $d400
	mwa #DisplayList $d402
	mwa #DLI $fffa
	mva #$80 $d01b
	sta $d40e

;   ldx #7
RandomColors
	lda $d20a
	sta $d013
	sta colz-1,x
	dex:bne RandomColors

Animate_Continue
	lda:rne $d40b

Player_Step
	lda #0
	eor #$ff
	sta Player_Step+1
	bne Animate_Zoom

	lda z:basv
	bne Player_1
	lda #BasVol
	mvx #BasOct baso
	inc z:basn
	sne:mvx #256-BasLength z:basn
Player_1
	asl @
	sta z:basv
	ldx #$c0
	scc:ldx #$c6
	stx $d203
	stx $d213
	ldx z:basn
	asl z:baso
	lda BasNotes1+BasLength-256,x
	scc:lsr @
	sta $d202
	sta $d212

	lda #$a0
	asl z:nml
	scc:sta $d201
	bne Animate_Zoom

Player_L
	ldx #$ff
	inx
	sne:ldx #256-MusicLength
	lda Music-256+MusicLength,x
	pha
	and #$0f
	tay
	pla
	stx Player_L+1
	and #$f0
	sta z:nml
	lda Notes,y
	sta $d200
Player_DelayW
	sta DelayBuf
	inc Player_DelayW+1
Player_DelayR
	lda DelayBuf+256-1
	sta $d210
	inc Player_DelayR+1
	lda #$a4
	sta $d211
	lda #$ac
Player_Audc
	sta $d201

Animate_Zoom
	ldy Animate_AddrDrL_X+2
	cpy #[>DrL]
	bne Animate_Zoom_1

Animate_ShiftColors
	ldx #4
Animate_ShiftColors_1
	mva colz,x colz+1,x
	sta $d015,x
	dex:bpl Animate_ShiftColors_1
	lda $d20a
	sta colz
	sta $d014

Animate_Zoom_1
	iny
	cpy #[>DrL]+ZoomSteps
	scc:ldy #[>DrL]
	sty Animate_AddrDrL_X+2
	sty Animate_AddrDrL_Y+2
	sty Animate_AddrDrH_X+2
	sty Animate_AddrDrH_Y+2
	bcc Animate_Rotate

Animate_NewDirection
Animate_NewDirection_Index
	ldy #$7c
	ldx #$ff
NewDirection
	lda #0
	sta cxl+1,x
	lda CurCenter-$7c,y
	sta cxh+1,x
	lda CenterDxL-$7c,y
	sta dcxl+1,x
	lda CenterDxH-$7c,y
	sta dcxh+1,x
	inx
	bne Animate_Rotate
	iny
	spl:ldy #$7c
	sty Animate_NewDirection_Index+1
	bne NewDirection	; !

Animate_Rotate
	dec acnt
	bpl Animate_AngleX
	mvx #7 acnt
	ldx angx
	lda RotateSpeed,x
	sta angs
	dex
	spl:ldx #RotateSpeedLength-1
	stx angx

Animate_AngleX
	ldx #[SinSteps/2]+128-[2*SinSteps]
Animate_AddrDrL_X
	lda DrL+256*[ZoomSteps-1],x
	sta z:DrawTexture_L_DyL+1
	sta z:DrawTexture_R_DyL+1
	sta vdxl
Animate_AddrDrH_X
	lda DrH+256*[ZoomSteps-1],x
	sta z:DrawTexture_L_DyH+1
	sta z:DrawTexture_R_DyH+1
	sta vdxh
	txa
	add angs
	spl:sbc #2*SinSteps-1     ; -
	sta Animate_AngleX+1
Animate_AngleY
	ldx #128-[2*SinSteps]
Animate_AddrDrL_Y
	lda DrL+256*[ZoomSteps-1],x
	sta vdyl
	eor #$ff
	add #1
	sta z:DrawTexture_L_DxL+1
	sta z:DrawTexture_R_DxL+1
Animate_AddrDrH_Y
	lda DrH+256*[ZoomSteps-1],x
	sta vdyh
	eor #$ff
	adc #0
	sta z:DrawTexture_L_DxH+1
	sta z:DrawTexture_R_DxH+1
	txa
	add angs
	spl:sbc #2*SinSteps-1     ; -
	sta Animate_AngleY+1

	ert [>[DrH+256*[ZoomSteps-1]]]!=[>[DrL+256*[ZoomSteps-1]]]

Animate_Translate
	ldx #1
	lda z:DrawTexture_L_DyL+1
	ldy z:DrawTexture_L_DyH+1

Animate_Translate_SMulBy32
	sty tdx
	ldy #4
Animate_Translate_SMulBy32_Shift
	asl @
	rol tdx
	dey:bpl Animate_Translate_SMulBy32_Shift
	eor #$ff
	sec
	adc cxl,x
	sta stxl,x
	lda cxh,x
	sbc tdx
	sta stxh,x

	lda vdxl,x
	ldy vdxh,x

Animate_Translate_SMulBy16
	sty tdx
	ldy #3
Animate_Translate_SMulBy16_Shift
	asl @
	rol tdx
	dey:bpl Animate_Translate_SMulBy16_Shift
	eor #$ff
	sec
	adc:sta stxl,x
	lda stxh,x
	sbc tdx
	sta stxh,x

	lda dcxl,x
	add:sta cxl,x
	lda dcxh,x
	adc:sta cxh,x

	dex
	bmi Animate_Draw
	lda z:DrawTexture_L_DxL+1
	ldy z:DrawTexture_L_DxH+1
	jmp Animate_Translate_SMulBy32

Animate_Draw
	lda #[>Screen2^>Screen1]
	eor:sta DisplayList_ScreenAddr+1
	eor #[>Screen2^>Screen1]
	tax
	jmp DrawTexture

DLI
	sta DLI_1+1
	lda $d40b
	sta $d40a
	lda #12
	sta $d405
	lda #4
	sta $d405
DLI_1
	lda #0
	rti

ZpCode
	org r:$00
ZpCodeStart

acnt dta 0
angx dta 0

nml dta %00000000

basv dta 0
basn dta $ff

DrawTexture
	dex
	stx z:DrawTexture_Scr+2
DrawTexture_Main
	mva #40 lcnt
	mva #32 z:DrawTexture_Scr+1
DrawTexture_NextLine
	clc
	mva stxl z:DrawTexture_L_FracX+1
	ldy stxh
	mva styl z:DrawTexture_L_FracY+1
	mva styh z:DrawTexture_L+2
	ldx #256-32   ; sta a:,x is 5 cycles anyway
DrawTexture_Loop
	stx z:DrawTexture_ScrL+1

DrawTexture_L
	ldx a:TextureMem,y
DrawTexture_L_FracX
	lda #0
DrawTexture_L_DxL
	adc #$00
	sta z:DrawTexture_R_FracX+1
	tya
DrawTexture_L_DxH
	adc #$01
	tay
DrawTexture_L_FracY
	lda #0
DrawTexture_L_DyL
	adc #$00
	sta z:DrawTexture_R_FracY+1
	lda z:DrawTexture_L+2
DrawTexture_L_DyH
	adc #$00
	sta z:DrawTexture_R+2

DrawTexture_R
	lda a:TextureMem,y
	ora z:Asl4,x
DrawTexture_ScrL
	ldx #0
DrawTexture_Scr
	sta Screen1,x
DrawTexture_R_FracX
	lda #0
DrawTexture_R_DxL
	adc #$00
	sta z:DrawTexture_L_FracX+1
	tya
DrawTexture_R_DxH
	adc #$01
	tay
DrawTexture_R_FracY
	lda #0
DrawTexture_R_DyL
	adc #$00
	sta z:DrawTexture_L_FracY+1
	lda z:DrawTexture_R+2
DrawTexture_R_DyH
	adc #$00
	sta z:DrawTexture_L+2

DrawTexture_NextByte
	inx
	bne DrawTexture_Loop
	dex
DrawTexture_AddV
	lda vdxl+1,x
	add:sta stxl+1,x
	lda vdxh+1,x
	adc:sta stxh+1,x
	inx:beq DrawTexture_AddV
	lda #32
	add:sta DrawTexture_Scr+1
	scc:inc DrawTexture_Scr+2
	dec lcnt
	bne DrawTexture_NextLine
	jmp Animate_Continue

Asl4 dta $00,$10,$20,$30,$40,$50,$60,$70,$80,$90

SquareSz
	dta 1
	dta 1,3,9,27
	dta 81,81

	ert *>ZpVar
ZpCodeLength equ *-ZpCodeStart
	org ZpCode+ZpCodeLength

	org ((*+$ff)&$ff00)
DelayBuf
	org *+$100

; interleaved
	org ((*+$ff)&$ff00)
DrL org *+256*ZoomSteps
DrH equ DrL+128

	org (*+$fff)&$f000

; 64 pix * NLines lines
; 32 B * NLines lines
Screen1 org *+32*NLines
Screen2 org *+32*NLines

	ert *>$D800

	run Start

	end

