;
;	">> VISDOM DEMO PART II <<"_for_the_Halle_Project_93
;
;	This is the final fixed single file version I have promised 19 years ago :-)
;
;	(c) 25-02-1993 by_JAC! first_version_with_main_effects
;	(r)_03-03-1993_by_JAC! Wiggle_works_100%.
;	(r)_07-03-1993_by_JAC! Visdom,Credits_&_Infopart.
;	(r)_09-03-1993_by-JAC! Ktab_&_ImpRes.
;	(r)_13-03-1993_by_JAC! Info_V1.1,ImpRes_break.
;	(f)_16-03-1993_by_JAC! All_texts_written,excluded,encrypted.
;	(f)_16-03-1993_by_JAC! final_version
;	(r)_06-08-1995_by_JAC! for Amiga
;	(r)_28-09-2002 by JAC! for_PC
;	(r)_17-06-2010 by JAC! wiggle_color_mix_fixed
;	(r)_22-02-2012 by JAC! fader,decrunch,PAL_and_RAM_size_check_added
;	(r)_26-02-2012 by JAC! PAL_check_activated_(silly_me)
;
;	Wiggle-X-Width: 8 to 64 = 57 Pixels
;	Secret_key_is_"wudsn ursel"_without_shift_or_control.
;
;	Pack with SuperPacker. All big segments must be packed using Exomizer with
;	depack=$9000, buffer=$9100 and decrunch effect code "JSR $3F00".

index	= 11			;Hiddencode_register_index.
space	= $9b			;Empty_Char_code_offset.
whold	= 200			;Time_to_hold_wiggle.
wnumb	= 5			;Number_of_wiggles_shown.
sin	= $18			;Visdom_sine_offset.

irqa	= $c0			;IRQ_temporaries.
irqx	= $c1			;...
irqy	= $c2			;...
dliup	= $c3			;DLI_counter.
dliv	= $c4			;DLI_vector.
dlip	= $c6			;DLI_pointer_(internal).
keyold	= $c8			;Last_pressed_key.
keyind	= $c9			;Keytab_index.
keybrk	= $ca			;"HELP"_pressed.
termin	= $cb			;Scroller_termination.

splipic	= $1000			;"Pic:GtiaSplit.pic"
scrdat	= $1c80			;"Dat:Summer.dat"
scrchr	= $2000			;"Chr:Summer.chr"
vispic	= $2400			;"Pic:VisOne.pic"
sintab1	= $2e00			;"Sin:VisOne.sin"
sintab2	= $3000			;"Sin:GtiaSplit.sin"_phasing_1.
sintab3	= $3100			;"Sin:GtiaSplit.sin"_phasing_3.
sintab4	= $3200			;"Sin:TextBounce.sin"
sintab5	= $3300			;"Sin:Sinus256.sin"
txtchr	= $3400			;"Chr:HalleChar.chr"
imppic	= $3800			;"Pic:Impres9x64.pic"
hidtxt	= $3b00			;"Dat:HalleHidden.txt"
scrtxt	= $5200			;"Dat:HalleScroll.txt"
credtxt	= $5ea5			;...
moretxt	= $5f4e			;...
inftxt	= $6000			;"Dat:HalleInfo.txt"
sndinit	= $ec07			;Init_Module.
sndplay	= $faf3			;Play_Module.

scrpos	= $e0			;ScrDat_offset.
scrcnt	= $e1			;ScrDat_offset_counter.
scrsof	= $e2			;Softscroll_value.
scrcod	= $e3			;Char_code.
scrspd	= $e4			;Scroll_speed.
scrcol1	= $e5			;Scroll_Color_1.
scrcol2	= $e6			;Scroll_Color_2.
scrhold	= $e7			;Scroll_hold_counter.

impxpos	= $f0			;ImpRes_X_Position.
impypos	= $f1			;ImpRes_Y_Position.
impsoft	= $f2			;ImpRes_Softscroll_value.
impmode	= $f3			;ImpRes_Scroll_mode.

wtime	= $f4			;Wiggle_hold_timer.
wnumber	= $f5			;Wiggle_counter.
whell	= $f6			;Wiggle_brightness.
whadd	= $f7			;Wiggle_fadeup.
wcnt1	= $f8			;Wiggle_move_values_(random).
wcnt2	= $f9			;...
wcol1	= $fa			;...
wcol2	= $fb			;...
wadd1	= $fc			;...
wadd2	= $fd			;...
wstep1	= $fe			;...
wstep2	= $ff			;...

base	= $8000
xtab	= base			;Animated_Sine_value_table.
btab	= base+$100		;Branch_offset_table.
mtab	= base+$200		;Missle_HPOS_table.
htab	= base+$300		;HPOS_conversion_table.
wigllo	= base+$400		;Split.pic_lineoffsets_LO.
wiglhi	= base+$500		;Split.pic_lineoffsets_HI.
vftab1	= base+$600		;Visdom_color_tabs_($40_bytes).
vftab2	= base+$700		;...
vftab3	= base+$800		;...
vftab4	= base+$900		;...
vftab5	= base+$a00		;...
vftab6	= base+$b00		;...
scrsm	= base+$c00		;Scroll_memory_($280_bytes).
textllo	= base+$f00		;Bouncetext_lineoffsets_LO.
textlhi	= base+$f80		;Bouncetext_lineoffsets_HI.
stab	= base+$1000		;Stars_X_position.
gtab	= base+$1100		;Stars_X_speed.
ktab	= base+$1200		;Bouncetext_colors.
impllo	= base+$1300		;ImpRes_lineoffsets_LO.
implhi	= base+$1400		;ImpRes_lineoffsets_HI.
impdl	= base+$1500		;ImpRes_DL_(???_bytes).
impsm	= base+$2000		;ImpRes_Picture_($1000_bytes).
lmsrout	= base+$3000		;Set_LMS_command_Adresses.
tsm	= base+$3800		;Text_SM.

tp	= $80			;ScrollText_Pointer.
ip	= $82			;InfoText_Pointer.
p1	= $84
p2	= $86
p3	= $88
p4	= $8a
x1	= $90
x2	= $91
x3	= $92
cnt	= $9f

;================================================================
	.include "../Macros.inc"

;================================================================

	.bank

*	= $3f00
	.byte 13,10,155
	.byte "Visdom-II by JAC!/Peter Dell.",13,10,155
	.byte "Original version released for the Halle Project on 16-03-1993.",13,10,155
	.byte "This fixed version released on 26-02-2012."13,10,155
	.byte 253,253,253,0

;==========================================================
; Pre-loader to fade the screen off
;==========================================================

.bank
.local
*	= $2000
init_loader
	jsr ?init_loader_system
	jsr ?init_loader_fade
	rts

; Check if this is PAL system and has 64k. 
; If not wait for a key and cold start.
?init_loader_system
	lda #1
	sta 580	;Enforce cold start upon reset

	lda $d014
	and #2
	bne ?init_loader_fail_pal
	sei
	lda #0
	sta $d40e
	ldy #0
	lda $d301
	pha
	lda #$fe	;Disable OS ROM
	sta $d301
	ldx $e000	;Check if writeable
	inc $e000
	cpx $e000
	bne ?init_loader_system1
	iny		;No
?init_loader_system1
	pla
	sta $d301
	lda #$40
	sta $d40e
	cli
	cpy #0
	bne ?init_loader_fail_64k
	rts

?init_loader_fail_64k
	set init_loader_error_dl1,init_loader_error_sm2

?init_loader_fail_pal
	lda #14
	sta 708
	set $230,init_loader_error_dl
?init_loader_fail1
	clc
	lda 20
	adc $d40b
	sta $d40a
	sta $d01a
	lda $d20f
	and #12
	cmp #12
	beq ?init_loader_fail1
	jmp $e474
	
init_loader_error_dl
	.byte $70,$70,$70,$70,$70,$70,$70,$70,$70,$70,$70,$70
	.byte $47
init_loader_error_dl1
	.word init_loader_error_sm1
	.byte $70,$46
	.word init_loader_error_sm3
	.byte $41
	.word init_loader_error_dl

init_loader_error_sm1
	.sbyte "REQUIRES PAL SYSTEM."
init_loader_error_sm2
	.sbyte "  REQUIRES 64K RAM. "
init_loader_error_sm3
	.sbyte "PRESS KEY TO REBOOT."

;----------------------------------------------------------------

?init_loader_fade
	lda #0
	sta x2
	ldx #8
?init_loader_fade2
	lda 704,x
	pha
	and #$f0
	sta x1
	pla
	and #15
	beq ?init_loader_fade3
	sec
	sbc #1
	ora x1
	sta x2
?init_loader_fade3
	sta 704,x
	dex
	bpl ?init_loader_fade2
	lda 20
	clc
	adc #2
?init_loader_fade4
	cmp 20
	bne ?init_loader_fade4
	lda x2
	bne ?init_loader_fade
	
	ldx #$1f		;Setup PM graphics for STX $D000 in the packer
?init_loader_fade5
	sta $d000,x
	dex
	bpl ?init_loader_fade5
	lda #$80
	sta $d00d
	lda #6
	sta 704
	sta $d012
	rts

.bank
*	= $2e2
	.word init_loader

.local

;================================================================

	.bank
*	= $3f00

decrunch_effect
	lda $d20a	;Noise_effect
	sta $d000
	lda $d40b
	sta $d012
	lda #0
	sta $d000
	rts
;================================================================

	.bank
*	= $4000

start	jsr copy
	jsr init

	jsr intro
	jsr wiggle
loop
	set p1,credtxt		;Text_start.
	set p2,credatt		;Attributes_Start.
	jsr credits
	jsr wiggle
	jsr impress
	set p1,moretxt		;Text_start.
	set p2,moreatt		;Attributes_Start.
	jsr credits
	jsr wiggle
	jsr impress
	jmp loop

;================================================================
kernel	lda wcol1
	ora whell
	sta kernel2+1
	lda wcol2
	ora whell
	sta $d019
	tay
	clc
	ldx #0
kernel1	sta $d40a
	lda mtab,x
	sta $d004
kernel2	lda #$00
	sta $d01a
	lda btab,x
	sta kernel3+1
kernel3	bne *+0
kernel4	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	sty $d01a
	inx
	bpl kernel1
	rts

kernel5	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	bit $00
	sty $d01a
	inx
	bpl kernel1
	rts

k	= kernel5-kernel4

;================================================================
nmi	bit $d40f		;NMI_handling.
	bpl vbi
	jmp (dliv)

;================================================================
vbi	sta irqa
	stx irqx
	sty irqy
	cld
	lda #$22		;Visdom_Colors.
	sta $d400
	lda #$14
	sta $d01b
	lda #10
	sta $d016
	lda #14
	sta $d017
	lda #0
	sta $d018

	lda #32			;Missle_Border.
	sta $d004
	lda #40
	sta $d005
	lda #208
	sta $d006
	lda #216
	sta $d007
	lda #$ff
	sta $d00c
	sta $d011
	lda #0
	sta $d019

	lda #84			;Underlay_PM.
	sta $d000
	lda #93
	sta $d001
	lda #150
	sta $d002
	lda #179
	sta $d003
	lda #$ff
	sta $d009
	sta $d00a
	sta $d00b
	set dliv,dli1

	jsr sndplay		;Replay_Tune.
	jsr scroll		;Do_Scroller.
	jsr visdom		;Sine_VISDOM_colors.
	jsr getkey		;Keyboard_routine.
	lda #$c0
	sta $d40e
	lda irqa
	ldx irqx
	ldy irqy
	rti

;================================================================
dli1	sta irqa
	stx irqx
	sty irqy
	lda #$fe
	sta $d40a
	sta $d00d
	sta $d00e
	sta $d00f
	sta $d010

	ldx #55
dli2	lda vftab1,x		;Visdom_Kernel.
	ldy vftab2,x
	sta $d40a
	sta $d01a
	sty $d012
	lda vftab3,x
	ldy vftab5,x
	sta $d013
	sty $d014
	lda vftab4,x
	ldy vftab6,x
	sta $d01a
	sty $d015
	dex
	bpl dli2

	lda #0
	sta $d40a
	sta $d01a
	sta $d000
	sta $d001
	sta $d002
	sta $d003
	sta $d40a
	sta $d004
	sta $d005
	sta $d006
	sta $d007
	jmp (dlip)

dli3	sta $d40a
	lda #$70
	sta $d01b
border1	lda #0			;Upper_Borderline.
	sta $d01a
	sta $d40a
	lda #0
	sta $d01a
	jsr kernel
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
dli4	lda #0
border2	ldx #0
	sta $d40a
	sta $d004
	sta $d01b
	stx $d01a
	sta $d40a
	lda #0
	sta $d01a
	lda #$23
	sta $d400
	lda #>scrchr		;Scroller_Screen.
	sta $d409
	lda scrsof
	sta $d404
	lda #12
	sta $d016
	lda scrcol1
	sta $d017
	eor #12
	sta $d018
	set dliv,dli5
	inc cnt			;Sync_Counter.
	lda irqa
	ldx irqx
	ldy irqy
	rti

dli5	sta irqa		;Second_Scroller_colorset.
	lda scrcol2
	sta $d017
	eor #12
	sta $d018
	lda irqa
	rti

;================================================================
wait	clc
	adc cnt			;Wait_Acc_VBlanks.
wait1	cmp cnt
	bne wait1
	rts

;================================================================
visdl	.byte $4e
	.word noline
	.byte $00,$80,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $20
	.byte $01
visdl1	.word splidl

splidl	.byte $4f,0,0,$4f,0,0,$4f,0,0,$4f,0,0,$4f,0,0,$4f,0,0,$4f,0,0,$4f,0,0
	.byte $4f,0,0,$4f,0,0,$4f,0,0,$4f,0,0,$4f,0,0,$4f,0,0,$4f,0,0,$4f,0,0
	.byte $4f,0,0,$4f,0,0,$4f,0,0,$4f,0,0,$4f,0,0,$4f,0,0,$4f,0,0,$4f,0,0
	.byte $4f,0,0,$4f,0,0,$4f,0,0,$4f,0,0,$4f,0,0,$4f,0,0,$4f,0,0,$4f,0,0
	.byte $4f,0,0,$4f,0,0,$4f,0,0,$4f,0,0,$4f,0,0,$4f,0,0,$4f,0,0,$4f,0,0
	.byte $4f,0,0,$4f,0,0,$4f,0,0,$4f,0,0,$4f,0,0,$4f,0,0,$4f,0,0,$4f,0,0
	.byte $4f,0,0,$4f,0,0,$4f,0,0,$4f,0,0,$4f,0,0,$4f,0,0,$4f,0,0,$4f,0,0
	.byte $4f,0,0,$4f,0,0,$4f,0,0,$4f,0,0,$4f,0,0,$4f,0,0,$4f,0,0,$4f,0,0
	.byte $4f,0,0,$4f,0,0,$4f,0,0,$4f,0,0,$4f,0,0,$4f,0,0,$4f,0,0,$4f,0,0
	.byte $4f,0,0,$4f,0,0,$4f,0,0,$4f,0,0,$4f,0,0,$4f,0,0,$4f,0,0,$4f,0,0
	.byte $4f,0,0,$4f,0,0,$4f,0,0,$4f,0,0,$4f,0,0,$4f,0,0,$4f,0,0,$4f,0,0
	.byte $4f,0,0,$4f,0,0,$4f,0,0,$4f,0,0,$4f,0,0,$4f,0,0,$4f,0,0,$4f,0,0
	.byte $4f,0,0,$4f,0,0,$4f,0,0,$4f,0,0,$4f,0,0,$4f,0,0,$4f,0,0,$4f,0,0
	.byte $4f,0,0,$4f,0,0,$4f,0,0,$4f,0,0,$4f,0,0,$4f,0,0,$4f,0,0,$4f,0,0
	.byte $4f,0,0,$4f,0,0,$4f,0,0,$4f,0,0,$4f,0,0,$4f,0,0,$4f,0,0,$4f,0,0
	.byte $4f,0,0,$4f,0,0,$4f,0,0,$4f,0,0,$4f,0,0,$4f,0,0,$4f,0,0,$4f,0,0
	.byte $01
	.word scrdl

scrdl	.byte $50
	.byte $54,0,>scrsm,$d4,128,>scrsm
	.byte $54,0,>scrsm+1,$54,128,>scrsm+1
	.byte $54,0,>scrsm+2
	.byte $41
	.word visdl

noline	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

code	.byte " abcdefghijklmnopqrstuvwxyz!."?  "

viscols	.byte $30,$20,$e0,$b0,$70,$40
vishell	.byte 0,0,2,0,2
	.byte 2,4,2,4,4,6,4,6,6,8,6,8,8,10,8,10,10,12
	.byte 10,12,12,14,12,14,14,14,14,14,14,14,14

;=============================================================
init	sei
	cld
	lda #0			;Disable_all_irqs.
	sta $d40e
	sta $d20e
	tax
init1	sta $d000,x		;Reset_customs.
	sta $d200,x
	sta $d400,x
	inx
	bne init1
	lda #3
	sta $d20f

init2	lda #0
	sta vftab1,x		;Reset_workspace.
	sta vftab2,x
	sta vftab3,x
	sta vftab4,x
	sta vftab5,x
	sta vftab6,x
	sta xtab,x
	sta btab,x
	sta mtab,x
	sta htab,x
	inx
	bne init2

	ldx #$10
init3	sta $00,x		;Clear_zeropage.
	inx
	bne init3

	lda #$fe		;Init_RAM_and_NMI_handler.
	sta $d301
	set $fffa,nmi

	set p1,splipic
	ldx #0
init4	lda p1
	sta wigllo,x
	sta wigllo+1,x
	clc
	adc #40
	sta p1
	lda p1+1
	sta wiglhi,x
	sta wiglhi+1,x
	adc #0
	sta p1+1
	inx
	inx
	bne init4
	lda #<noline		;Empty_bitmap_(40_bytes).
	ldx #>noline
	sta wigllo
	stx wiglhi

	set p1,lmsrout		;Generate_setlms_routine.
	ldy #0
	ldx #0
	set p2,[splidl+1]
init5	lda #$ac		;LDY_offset.
	jsr poke
	txa
	jsr poke
	lda #>xtab
	jsr poke
	lda #$b9		;LDA_wigllo,y.
	jsr poke
	lda #<wigllo
	jsr poke
	lda #>wigllo
	jsr poke
	lda #$8d		;STA_splidl+1.
	jsr poke
	lda p2
	jsr poke
	lda p2+1
	jsr poke
	add p2,1
	lda #$b9		;LDA_wiglhi,y.
	jsr poke
	lda #<wiglhi
	jsr poke
	lda #>wiglhi
	jsr poke
	lda #$8d		;STA_splidl+2.
	jsr poke
	lda p2
	jsr poke
	lda p2+1
	jsr poke
	add p2,2
	inx
	bmi *+5
	jmp init5
	lda #$60		;RTS.
	jsr poke
	jsr lmsrout		;Init_Splidl.

	lda #32
	ldx #0
init6	sta scrsm,x		;Clear_Scroller.
	sta scrsm+$100,x
	sta scrsm+$180,x
	inx
	bne init6

	set tp,scrtxt		;Set_text_begin.
	set ip,inftxt
	lda #0
	sta scrpos		;Init_scroll_values.
	sta scrcnt
	sta scrsof
	sta scrhold
	sta scrcol1
	sta scrcol2
	lda #space
	sta scrcod
	lda #3
	sta scrspd

	ldx #0
init7	lda $d20a		;Init_Starfield.
	sta stab,x
	lda $d20a
	and #3
	clc
	adc #1
	sta gtab,x
	txa
	and #63
	cmp #32
	bcc *+4
	eor #63
	tay
	lda vishell+4,y
	sta ktab,x
	inx
	bne init7

	set p1,tsm
	ldx #0
init8	lda p1			;LMS_adrs_for_Text_bounce.
	sta textllo,x
	clc
	adc #40
	sta p1
	lda p1+1
	sta textlhi,x
	adc #0
	sta p1+1
	inx
	bpl init8

	jsr sndinit		;Init_module.
	jsr bragen		;Init_HTAB.
	jsr impinit		;Init_ImpRes_(SM,DL_&_llo/hi).

	lda #0
	sta keyold		;Init_GETKEY.
	sta keyind
	sta keybrk
	sta termin		;Init_Termination_Flag.
	sta border1+1		;Init_Screen.
	sta border2+1
	set dlip,dli3
	set $d402,visdl
	rts

;===============================================================
poke	sta (p1),y		;Store_LmsRout_byte.
	dic p1
	rts

;================================================================
bragen	ldx #0			;Generate branch offset tab
	ldy #0
bragen1	lda braxtab,x
	cmp x1
	beq bragen3
	sta x1
	cmp #$ff
	beq bragend
	lda branch,x
bragen2	sta htab,y
	iny
	cpy x1
	bne bragen2
bragen3	inx
	jmp bragen1
bragend	rts

braxtab	.byte 8,15,24,32,40,48,56,64,72,76,80,84,88,92,96
	.byte 100,104,108,112,112,114,116,120,127,$ff

branch	.byte 12,k+13,11,k+11,10,k+10,9,k+9,8,k+8,7,k+7
	.byte 6,k+6,5,k+5,4,k+4,3,k+3,2,k+2,1,k+1,0,k

;===============================================================
	
intro	lda #155
	cmp $d40b
	bne *-3
	lda #$40		;VBI/DLI_on.
	sta $d40e
	jsr introa		;Wait_for_Scroll.
	lda #50
	jsr wait

	set [visdl+1],[vispic+2360]
	ldx #0
intro1	lda #1
	jsr wait
	sub [visdl+1],40	;Scroll_VisPic_lms.
	lda #$0e
	ora visdl+3,x		;Enlarge_DL.
	sta visdl+3,x
	inx
	cpx #59
	bne intro1

	jsr introa		;Wait_for_Scroll.
	lda #100
	jsr wait

	lda #0			;Fade_VisTabs.
	sta x1
	set p1,vftab1
intro2	ldx x1			;Which_Tab.
	lda viscols,x		;Char_Color.
	sta x2
	ldx #0
intro3	lda #2			;Fade_up.
	jsr wait
	txa
	ldy #127
intro4	sta (p1),y		;Whole_tab.
	dey
	bpl intro4
	inx
	cpx #16
	bne intro3

	lda #15
	sta x3
intro5	lda #2			;Fade_Down.
	jsr wait
	ldy #0
intro6	tya
	and #63
	cmp #32
	bcc *+4
	eor #63
	tax
	lda vishell,x		;With_Bars_and_..
	clc
	adc x3
	cmp #16
	bcc *+4
	lda #15
	ora x2			;Colors.
	sta (p1),y
	iny
	bpl intro6
	dec x3
	bpl intro5
	lda #50			;Short_delay.
	jsr wait

	inc p1+1		;Next_Tab.
	inc x1
	lda x1			;6th_Tab_?
	cmp #6
	bne intro2

	jsr introa
	lda #100
	jsr wait

	ldx #15
intro7	inc border1+1		;Upper_borderline.
	lda #2
	jsr wait
	dex
	bne intro7

	lda #25			;Wait_a_little.
	jsr wait
	ldx #15
intro8	inc border2+1		;Lower_borderline.
	lda #2
	jsr wait
	dex
	bne intro8

	lda #25			;Wait_a_little.
	jsr wait
	ldx #15
intro9	inc whell		;Background.
	lda #2
	jsr wait
	dex
	bne intro9

	lda #2			;hold_"WIGGLE".
	sta scrspd
	lda #250
	sta scrhold
	rts

introa	lda #2			;Set_Speed.
	sta scrspd
	lda #70
introb	cmp scrhold		;Wait_for_ScrollHold.
	bne introb
	lda #0			;Hold_Scroll.
	sta scrspd
	rts

;===============================================================
scroll	lda scrhold		;Hold_scroller_?
	beq scroll0
	dec scrhold
	rts

scroll0	lda scrsof		;Do_soft-scroll.
	sec
	sbc scrspd
	bmi scroll1
	sta scrsof
	rts

scroll1	clc			;Do_hard-scroll.
	adc #4
	sta scrsof
	ldy scrcod		;Chardat_offset.
	inc scrcod
	inc scrpos		;Scrsm_offset.
	lda scrpos
	and #$3f
	sta scrpos
	tax
	sta scrdl+2		;LMS_scroll.
	sta scrdl+8
	sta scrdl+14
	ora #$80
	sta scrdl+5
	sta scrdl+11
	lda scrdat+$000,y	;Copy_scrdat.
	sta scrsm+$000,x
	sta scrsm+$040,x
	lda scrdat+$0a0,y
	sta scrsm+$080,x
	sta scrsm+$0c0,x
	lda scrdat+$140,y
	sta scrsm+$100,x
	sta scrsm+$140,x
	lda scrdat+$1e0,y
	sta scrsm+$180,x
	sta scrsm+$1c0,x
	lda scrdat+$280,y
	sta scrsm+$200,x
	sta scrsm+$240,x
	dec scrcnt		;Dec_charsize.
	bmi scroll2
	rts

scroll2	ldy #0
scroll3	lda (tp),y
	bne scroll4		;Last_?
	sta scrspd
	lda #200
	sta termin
	lda #space

scroll4	cmp #$e0		;Special_?
	bcs scroll5
	sta scrcod		;New_code.
	lda #4			;New_char.
	sta scrcnt
	dic tp			;Next_char.
	rts

scroll5	cmp #$f0
	bcs scroll7
	and #7
	beq scroll6
	sta scrspd
	lda #space
	sta scrcod
	lda #0
	sta scrcnt
	dic tp
	rts

scroll6	lda #80
	sta scrhold
	lda #space
	sta scrcod
	lda #0
	sta scrcnt
	dic tp
	rts

scroll7	iny
	lda (tp),y
	sta scrcol1
	iny
	lda (tp),y
	sta scrcol2
	lda #0
	sta scrcnt
	lda #space
	sta scrcod
	add tp,3
	rts

;================================================================
visdom	lda cnt			;Do_Colorbars_Sine.
	asl
	tax
	lda sintab1,x
	sta dli2+31		;"M"
	lda sintab1+[sin*1],x
	sta dli2+19		;"O"
	lda sintab1+[sin*2],x
	sta dli2+28		;"D"
	lda sintab1+[sin*3],x
	sta dli2+16		;"S"
	lda sintab1+[sin*3]+[sin/2],x
	sta dli2+4		;"I"
	lda sintab1+[sin*4]+[sin/2],x
	sta dli2+1		;"V"
	rts

;================================================================
getkey	lda termin		;Scroller_termination_?
	beq getkey0
	dec termin
	beq getkey1

getkey0	lda $d20f		;Shift_pressed_?
	and #8
	beq getkey1

	lda $d010		;Trigger_pressed_?
	bne getkey2
getkey1	sei
	lda #0
	sta $d40e
	sta $d20e
	sta $d400
	sta $d01a
	lda #$ff
	sta $d301
	jmp ($fffc)		;Goto_system_reset.

getkey2	lda $d20f		;Any_key_pressed_?
	and #4
	bne getkey5
	lda $d209		;which_one_?
	cmp #17
	bne getkey3
	sta keybrk		;"HELP".
getkey3	cmp keyold
	beq getkey5
	sta keyold
	ldx keyind
	cmp keytab,x
	bne getkey4
	inx
	stx keyind
	cpx #11
	bne getkey5
	ldy #index
	jmp hidden

getkey4	lda #0
	sta keyind
getkey5	rts

keytab	.byte 46,11,58,62,35,33,11,40,62,42,0
	; "W  U  D  S  N     U  R  S  E  L"

;================================================================
wiggle	lda #15			;Fade_down.
	sta whell
	lda #$ff
	sta whadd
	lda #whold
	sta wtime		;Keep_it_up_(N)_Doubleframes.
	lda #wnumb
	sta wnumber		;Do_it_(N)_times.
	lda #1
	jsr wait
	set dlip,dli3
	set [visdl1],splidl	;Reset_vectors.

wiggle1	lda $d20a		;New_wiggle.
	and #$f0
	cmp #$f0		;Would_result_in_both_sides_being_$f0
	beq wiggle1
	sta wcol1		;Color_for_$d01a
wiggle2	lda $d20a
	and #$f0
	ora wcol1		;Since_$D019_will_be_or-ed_with_$d01a,_wcol2_must_have_at_least_the_same_bits_set_as_wcol1
	cmp wcol1
	beq wiggle2		;But_must_not_be_equal
	sta wcol2
	lda $d20a
	and #3
	sta wadd1
	lda $d20a
	and #3
	sta wadd2
	lda $d20a
	and #7
	sta wstep1
	lda $d20a
	and #3
	sta wstep2
	inc wadd1
	inc wadd2
	inc wstep1
	inc wstep2

wiggle3	jsr dotabs		;New_Xtab.
	lda #1
	jsr wait
	jsr lmsrout		;SetLms_instructions.

	clc
	lda whell		;GTIA_fading.
	adc whadd
	sta whell
	cmp #$ff
	bne wiggle4
	lda #0
	sta whadd
	sta whell
wiggle4	cmp #15
	beq wiggle6

	lda keybrk		;User_break.
	bne wiggle5

	dec wtime		;Dec_showingtime.
	bne wiggle3
	lda #whold		;Set_it_again.
	sta wtime

	dec wnumber		;Dec_number_of_wiggles.
	bne wiggle1
wiggle5	lda #1			;Start_blend_up.
	sta whadd
	jmp wiggle3

wiggle6	lda #0			;Pure_White.
	sta wcol1
	sta wcol2
	lda keybrk
	beq wiggle7
	jsr info
wiggle7	rts

;===============================================================
dotabs	lda wcnt1		;Calc_Wiggle.
	sta x1
	clc
	adc wadd1
	sta wcnt1

	lda wcnt2
	sta x2
	clc
	adc wadd2
	sta wcnt2

	lda wstep1
	sta dotab2+1
	lda wstep2
	sta dotab3+1

	ldx #0
dotab1	ldy x1
	lda sintab2,y		;Calc_Xtab.
	ldy x2
	clc
	adc sintab3,y
	and #$fe
	sta xtab,x
	tay
	clc			;Convert_xpos_table_to_..
	adc #48
	sta mtab,x		;Missile_HPOS.
	lda htab,y
	sta btab,x

	clc
	lda x1
dotab2	adc #0			;Steps.
	sta x1
	clc
	lda x2
dotab3	adc #0			;Steps.
	sta x2
	inx
	bpl dotab1
	rts

;================================================================
credl	.byte $00,$80,$54
	.word tsm
	.byte $94,$14,$14,$14,$80,$00
	.byte $14,$94,$14,$14,$14,$80,$00
	.byte $14,$94,$14,$14,$14,$80,$00
	.byte $01
	.word scrdl

credatt	.byte 00,00,00,00,00,00,$00,$00,$30,$70,$00,$00	;"Welcome"
	.byte 00,00,00,00,10,10,$80,$b0,$80,$b0,$90,$b0	;"Visdom"
	.byte 00,00,10,10,00,00,$10,$20,$00,$d0,$00,$d0	;"Peter"
	.byte 00,00,10,10,10,10,$10,$20,$00,$d0,$00,$d0	;"Karsten"
	.byte 00,00,00,00,00,00,$00,$00,$30,$70,$00,$00	;"done"
	.byte 10,10,10,10,10,10,$30,$00,$30,$00,$30,$00	;"halle"
	.byte 10,10,00,00,00,00,$c0,$c0,$30,$30,$c0,$c0	;"space"

moreatt	.byte 00,00,10,10,00,00,$80,$b0,$20,$00,$20,$00	;"Rules"
	.byte 00,00,00,00,10,10,$30,$70,$30,$70,$30,$70	;"Coming"
	.byte 00,00,10,10,10,10,$80,$b0,$80,$b0,$20,$00	;"Filled"
	.byte 00,00,10,10,10,10,$40,$40,$20,$00,$20,$00	;"Soon"

tscrx	.byte 0,0,0,0,0,0
tcols	.byte 0,0,0,0,0,0
thell	.byte 0,0,0,0,0,0

tfade1	.byte 0,2,4,6,8,10,12,14
tfade2	.byte 0,2,4,6,8,10,10,10
tfade3	.byte 0,2,4,6,6,6,6,6

;================================================================
credits	jsr clrtsm		;Print_Credits.
	jsr credini

credit1	jsr clrtsm
	jsr prttsm
	jsr credup
	lda keybrk		;User_break_?
	bne credit2
	ldy #0			;Text_end_flag_?
	lda (p1),y
	bne credit1

credit2	jsr clrtsm		;Clear_Screen.
	jsr credex		;Fadeup.
	lda keybrk
	beq credit3		;Do_info_?
	jsr info
credit3	rts

;================================================================
credup	ldx #0
credup1	lda tcols,x
	ora tcols+1,x
	beq credup3
	ldy #0
credup2	tya
	sta thell,x
	sta thell+1,x
	lda #3
	jsr wait
	iny
	cpy #8
	bne credup2
	lda #35
	jsr wait
credup3	inx
	inx
	cpx #6
	bne credup1

	ldx #125
credup4	lda keybrk		;Delay_if_no_User_break.
	bne credup5
	lda #1
	jsr wait
	dex
	bne credup4

credup5	ldy #7
credup6	tya
	ldx #5
credup7	sta thell,x
	dex
	bpl credup7
	lda #3
	jsr wait
	dey
	bpl credup6
	lda #30
	jsr wait
	rts

;================================================================
credini	ldx #5
	lda #0
credin1	sta tcols,x		;Reset_all.
	sta tscrx,x
	sta thell,x
	dex
	bpl credin1

	lda #1			;Fade_down_Screen.
	jsr wait
	set dlip,credli
	set [visdl1],credl
	ldx #15
credin2	stx credli1+1
	lda #2
	jsr wait
	dex
	bne credin2
	lda #25
	jsr wait
	rts

;================================================================
credex	ldx #0
credex1	stx credli1+1		;Exit_Credits.
	lda #2
	jsr wait
	inx
	cpx #16
	bne credex1
	rts

;================================================================
credli	sta $d40a		;Upper_Borderline.
	lda #14
	sta $d01a
	sta $d40a
credli1	lda #0			;Fade_Background.
	sta $d01a
	lda #0			;First_DLI.
	sta dliup
	set dliv,credli2	;New_DLI.
	lda irqa
	ldx irqx
	ldy irqy
	rti

credli2	sta irqa
	stx irqx
	sty irqy
	ldx dliup		;Last_DLI.
	cpx #6
	beq credli6
	lda tscrx,x
	sta $d404
	ldy thell,x		;Fade_index.
	lda tfade1,y		;Brightness.
	beq credli3		;Black_?
	ora tcols,x		;Set_Textcolor_1.
credli3	sta $d016
	lda tfade2,y
	beq credli4
	ora tcols,x		;Set_Textcolor_2.
credli4	sta $d017
	lda tfade3,y
	beq credli5
	ora tcols,x		;Set_Textcolor_3.
credli5	sta $d018
	inc dliup
	lda irqa
	ldx irqx
	ldy irqy
	rti

credli6	lda #100
	cmp $d40b
	bne *-3
	jmp dli4

;================================================================
clrtsm	ldx #0
	lda #32			;Clear_Text_screen.
clrtsm1	sta tsm,x
	sta tsm+$100,x
	sta tsm+$200,x
	sta tsm+$300,x
	sta tsm+$400,x
	sta tsm+$500,x
	sta tsm+$600,x
	sta tsm+$700,x
	inx
	bne clrtsm1
	rts

;================================================================
prttsm	lda #3			;Line_counter.
	sta x1
	set p4,[tsm+4]		;Text_Destination.
prttsm1	lda #8			;Print_8_chars.
	sta x2
prttsm2	ldy #0
	lda (p1),y		;Get_char.
	clc			;Calc_DatAdr.
	adc #<scrdat
	sta p3
	lda #0
	adc #>scrdat
	sta p3+1
	ldx #5			;Lines.
prttsm3	ldy #4			;Rows.
prttsm4	lda (p3),y
	nop
	nop
	sta (p4),y		;Copy_ScrDat.
	dey
	bpl prttsm4
	add p3,160
	add p4,48
	dex
	bne prttsm3
	sub p4,235
	dic p1
	dec x2
	bne prttsm2
	add p4,200
	dec x1
	bne prttsm1

	ldy #11
prttsm5	lda (p2),y		;Get_attributes.
	sta tscrx,y
	dey
	bpl prttsm5
	add p2,12
	rts

;================================================================
infdl	.byte $00,$00,$00,$00,$62
infdl1	.word tsm
	.byte $22,$22,$22,$22,$22
	.byte $22,$22,$22,$22,$22
	.byte $22,$22,$22,$22,$02,$00,$00,$00
	.byte $01
	.word scrdl

infcols	.byte 10,6,2,0,2,6,10,14

infdli	sta $d40a		;Upper_Borderline.
	lda #14
	sta $d01a
	sta $d40a
infdli1	lda #0			;Fade_Background.
	sta $d01a
	sta $d018
	lda #>txtchr		;Text_Screen.
	sta $d409
	lda #14
	sta $d017
	lda #$80
	sta $d008
	sta $d00d
	lda #1
	sta $d01b

	lda cnt			;Scroll_Ktab.
	clc
infdli3	adc #0			;Add_Bounce_offset.
	tay

	ldx dliup
	bmi infdlix
infdli4	lda stab,x
	sta $d40a
	sta $d000
	stx $d012
	lda ktab,y
	sta $d017
	iny
	sta $d40a
	lda ktab,y
	sta $d017
	iny
	inx
	inx
	bpl infdli4

infdlix	lda #0
	sta $d40a
	sta $d000
	sta $d001
	lda #100
	cmp $d40b
	bne *-3
	jmp dli4

;================================================================
info	jsr clrtsm		;Clear_Screen.
	ldx #0
	jsr bounce3		;Init_Textposition.
	lda #1
	jsr wait
	lda #$80		;No_Stars_yet.
	sta dliup
	set dlip,infdli		;New_DLI.
	set [visdl1],infdl	;New_DL.
	ldx #15
info1	stx infdli1+1		;Fade_down_Background.
	lda #2
	jsr infwait
	dex
	bpl info1
	lda #30
	jsr infwait

info2	lda #1
	jsr infwait
	dec dliup
	dec dliup
	bne info2
	lda #75
	jsr infwait

info3	jsr infprt
	jsr bounce
	ldy #0
	lda (ip),y
	cmp #$ff
	bne info4
	set ip,inftxt
info4	lda keybrk		;"HELP"_pressed,_then_..
	beq info5
	cmp #17
	beq info3

info5	lda #50
	jsr infwait

info6	lda #1
	jsr infwait
	inc dliup
	inc dliup
	bpl info6
	lda #25
	jsr infwait

	ldx #15
info7	inc infdli1+1
	lda #2
	jsr infwait
	dex
	bne info7

	lda #0			;Reset_Keybrk.
	sta keybrk
	rts

;================================================================
infwait	sta x1			;Wait_and_..
	stx x2
infwai1	lda #1
	jsr wait
	ldx #0
infwai2	lda stab,x		;Move_Stars-
	clc
	adc gtab,x
	sta stab,x
	inx
	bpl infwai2
	dec x1
	bne infwai1
	ldx x2
	rts

;================================================================
infprt	ldy #0
infprt1	lda (ip),y		;Copy_Infotext_to_TSM.
	sta tsm,y
	iny
	bne infprt1
	inc ip+1		;Next_Page.
	lda #1
	jsr infwait		;Do_Starmovement.
infprt2	lda (ip),y
	sta tsm+$100,y
	iny
	bne infprt2
	inc ip+1
	lda #1
	jsr infwait
	ldy #[599-512]
infprt3	lda (ip),y
	sta tsm+$200,y
	dey
	bpl infprt3
	add ip,[600-512]
	rts			;$280_bytes.

;================================================================
bounce	ldx #0			;Bouncy_bouncy_...
bounce1	jsr bounce3
	inx
	bne bounce1

	lda #0			;Reset_HELP_flag.
	sta keybrk
	jsr bounce4

	ldx #$ff
bounce2	jsr bounce3
	dex
	cpx #$ff
	bne bounce2
	rts

bounce3	lda #1			;Calc_LMS/Softscroll.
	jsr infwait
	sec
	lda #$80
	sbc sintab4,x
	pha
	lsr
	lsr
	lsr
	tay
	lda textllo,y
	sta infdl1
	lda textlhi,y
	sta infdl1+1
	pla
	sta infdli3+1		;Ktab_offset.
	and #7
	sta $d405		;Y_Softscroll.
	rts

bounce4	ldy #3			;Do_Stars_until:
	ldx #0
bounce5	lda #1
	jsr infwait
	lda $d20f		;Space_or_...
	and #4
	bne bounce6
	lda $d209
	cmp #$21
	bne bounce6
	sta keybrk
bounce6	lda keybrk		;Help_appears.
	bne bounce7
	dex			;for_4*256/50_Secs.
	bne bounce5
	dey
	bne bounce5
bounce7	rts

;===============================================================
imphtab	.byte $00,$72,$74,$76,$78,$7a,$7c,$7e
	.byte $0e,$0e,$0e,$0e,$0e,$0e,$0e,$0e

impdli	sta $d40a		;Upper_Borderline.
	lda #14
	sta $d01a
	lda #$23
	sta $d400
	lda impsoft
	sta $d404

	lda impypos
	lsr
	lda #$40
	bcc *+4
	lda #$80

	sta $d40a
	ldx dliup
	ldy imphtab,x
	sty $d012
	sty $d01a
	ldy imphtab+1,x
	sty $d013
	ldy imphtab+2,x
	sty $d014
	ldy imphtab+3,x
	sty $d015
	ldy imphtab+4,x
	sty $d016
	ldy imphtab+5,x
	sty $d017
	ldy imphtab+6,x
	sty $d018
	ldy imphtab+7,x
	sty $d019

	ldx #0
impdli1	sta $d40a
	eor #$c0
	sta $d01b
	sta $d40a
	eor #$c0
	sta $d01b
	inx
	cpx #64
	bne impdli1

	lda #100
	cmp $d40b
	bne *-3
	jmp dli4

;===============================================================
impinit	lda #64			;Init_ImpRes_data.
	sta x1			;Line_counter.
	set p1,impsm
	set p2,imppic
impini1	lda #0
	sta x2			;Index_1.
	lda #63
	sta x3			;Index_2.

impini2	ldy x2
	lda (p2),y
	ldy x3
	sta (p1),y
	dec x2
	bpl impini3
	lda #8
	sta x2
impini3	dec x3
	bpl impini2
	add p1,64
	add p2,9
	dec x1
	bne impini1

	set p1,impdl
	jsr impin4
	jsr impin4
	ldy #0
	lda #$01
	sta (p1),y
	iny
	lda #<scrdl
	sta (p1),y
	iny
	lda #>scrdl
	sta (p1),y

	lda #0
	sta impxpos
	sta impypos
	sta impsoft
	rts

impin4	ldx #0
	set p2,impsm
impin5	ldy #0
	lda #$5f		;LMS.
	sta (p1),y
	iny
	lda p2
	sta (p1),y		;L_byte.
	sta impllo,x
	sta impllo+$40,x	;Gen_tab.
	sta impllo+$80,x
	sta impllo+$c0,x
	iny
	lda p2+1
	sta (p1),y		;Hi_byte.
	sta implhi,x
	sta implhi+$40,x	;Gen_tab.
	sta implhi+$80,x
	sta implhi+$c0,x

	add p2,64
	add p1,3
	inx
	cpx #64
	bne impin5
	rts

;==============================================================
impress	lda #1			;Fade_down_Screen.
	jsr wait
	lda #8
	sta dliup
	set dlip,impdli
	set [visdl1],impdl
	lda $d20a		;Set_Start_mode.
	and #3
	sta impmode

	lda #4
	sta x2
impres1	lda #0			;Reset_Position.
	sta impxpos
	sta impypos
	lda $d20a
	and #$f0
	sta x1
	ldx #7
impres2	lda imphtab,x		;Gen_new_Colortab.
	and #$0f
	ora x1
	sta imphtab,x
	dex
	bpl impres2

	lda #8			;Short_delay.
	jsr impeff

impres3	lda #2
	jsr impeff
	dec dliup
	bne impres3

	lda #250		;Do_Effect.
	jsr impeff
	lda keybrk
	bne impres4
	lda #250
	jsr impeff

impres4	inc dliup		;Fade_up.
	lda #2
	jsr impeff
	lda dliup
	cmp #8
	bne impres4

	lda keybrk		;User_broken_?_(he,he_...)
	bne impres5

	inc impmode		;Next_mode.
	dec x2			;Last_time_?
	bne impres1
	lda #8			;Short_delay.
	jsr impeff
	rts

impres5	jsr info
	rts

;===============================================================
impeff	sta x3
impeff1	lda #1
	jsr wait

	ldx cnt
	lda sintab5,x		;Do_Y_Sine.
	and #63
	sta impypos

	ldx #16
	lda impmode		;Which_mode_?
	lsr
	bcc impeff2
	stx impxpos		;Reset_X.
impeff2	lsr
	bcc impeff3
	stx impypos		;Reset_Y.
impeff3
	lda impxpos
	lsr
	sta x1
	ldx #0
	ldy impypos
impeff4	lda impllo,y
	ora x1
	sta impdl+1,x
	sta impdl+$c1,x
	lda implhi,y
	sta impdl+2,x
	sta impdl+$c2,x
	iny
	inx
	inx
	inx
	cpx #192
	bne impeff4

	lda impxpos		;Gen_softscroll_value.
	and #1
	eor #1
	asl
	sta impsoft

	lda impxpos		;Move_Xpos.
	clc
	adc #1
	cmp #18
	bne *+4
	lda #0
	sta impxpos

	lda keybrk		;User_break_?
	bne impeff5

	dec x3
	bne impeff1
impeff5	rts

;===============================================================
copy	sei
	ldy $d40b		;Disable_all.
	bne *-3
	sty $d40e
	sty $d20e
	sty $d400
	lda #$fe
	sta $d301
	ldx #$14		;Copy_Sound_module.
copy1	lda $9c00,y		;From_Link_loaction.
copy2	sta $ec00,y		;UP_To_Dest_location.
	iny
	bne copy1
	inc copy1+2
	inc copy2+2
	dex
	bne copy1

	ldx #$10		;Copy_Lowmem_data.
copy3	lda $8000,y		;From_Link_loaction.
copy4	sta $1000,y		;DOWN_To_Dest_location.
	iny
	bne copy3
	inc copy3+2
	inc copy4+2
	dex
	bne copy3
	rts

;===============================================================
hidden	lda #0
	sta [$d40e-index],y
	tax
hidden1	sta [$d000-1],x
	sta [$d200-1],x
	inx
	bne hidden1

	lda #3
	sta [$d20f-index],y
	lda #<hiddl
	sta [$d402-index],y
	lda #>hiddl
	sta [$d403-index],y
	lda #>txtchr
	sta [$d409-index],y
	lda #$21
	sta [$d400-index],y
	lda #$8
	sta [$d00d-index],y

hidden2	lda [$d40b-index],y
	bne hidden2
	ldx #250
hidden3	lda $d20a
	sta [$d40a-index],y
	sta [$d000-index],y
	sta [$d012-index],y
	dex
	bne hidden3
	inc cnt
	lda cnt
	and #31
	cmp #16
	bcc *+4
	eor #31
	sta [$d017-index],y
	jmp hidden2

hiddl	.byte $f0,$e0,$f0,$e0,$f0,$e0,$f0,$42
	.word hidtxt
	.byte $f0,2,$e0,2,$f0,2,$41
	.word hiddl

;	Put_all_the_data_into_a_separate_segment.
	.bank

*	= scrchr
	.incbin "Visdom-II-Summer.chr"		; $2000
*	= vispic
	.incbin "Visdom-II-VisdomSplitLogo.pic"	; $2400
	.rept sintab1-*
	.byte 0
	.endr

*	= sintab1
	.incbin "Visdom-II-VisdomSplitLogo.sin"	; $2e00
*	= sintab2
	.incbin "Visdom-II-GtiaSplit.sin"	; $3000
*	= sintab4
	.incbin "Visdom-II-InfoTextBounce.sin"	; $3200
*	= sintab5
	.incbin "Visdom-II-Sinus256.sin"	; $3300
*	= txtchr
	.incbin "Visdom-II-HalleChar.pur"	; $3400	;"Visdom-II-HalleChar.cod"_for_testing.
*	= imppic
	.incbin "Visdom-II-ImpRes9x64.pic"	; $3800
	.rept hidtxt-*
	.byte 0
	.endr

*	= hidtxt
	.incbin "Visdom-II-HalleHidden.txt"	; $3b00
*	= scrtxt
	.incbin "Visdom-II-HalleScroll.txt"	; $5200
	.rept inftxt-*
	.byte 0
	.endr

*	= inftxt
	.incbin "Visdom-II-HalleInfo.txt"	; $6000
	.rept $8000-*
	.byte 0
	.endr

*	= $8000
	.incbin "Visdom-II-GtiaSplit.pic"	; $8000	;copied_to_1000.
	.incbin "Visdom-II-Summer.dat"    	; $8c80	;copied_to_1c80.

*	= $9c00
	.incbin "Visdom-II-Sound$ec00.snd"	; $9c00	;copied_to_ec00.

	.bank
*	= $2e0
	.word start

