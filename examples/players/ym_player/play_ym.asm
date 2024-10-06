; ym player
; Written by Mariusz Wojcieszek 2017
; https://forums.atariage.com/profile/42656-mariuszw/ 
;
; YM file format
; http://leonard.oxg.free.fr/ymformat.html 

;portb			equ $d301
Pokey			equ $d200
YMData			equ $1000

YMRegisters	equ $80
YMFrequency	equ $8f


		org YMData
		ins 'skrju.ym',$36
YMDataEnd equ *

YMSongTitle
		dta c'YM player',b($9b)



		org $a000
get_data
		stx regX

		ldx #13
YM_loop		lda src: $ffff,x
		sta YMRegisters,x
		dex
		bpl YM_loop

		adw src #16

		ldx regX: #$0

		rts

iccmd    = $0342
icbufa   = $0344
icbufl   = $0348
jciomain = $E456
;
putline		ldx #$00
		sta icbufa,x
		tya
		sta icbufa+1,x
		lda #$ff
		sta icbufl,x
		lda #$09
		sta iccmd,x
		jmp jciomain

start
		lda #<YMSongTitle
		ldy #>YMSongTitle
		jsr putline

		mwa #YMData src

		lda #$38
		sta YMRegisters+7

		jsr InitPokey

PlayYMLoop	jsr get_data
	
YMWaitVBL

; channel A
YMNoise
		ldy #$14 ; channel 3+4 of 2nd Pokey
		lda YMRegisters+7
		and #$38
		cmp #$38
		beq YMNoiseClear
		lsr @
		lsr @
		lsr @
		ldx #0
		lsr @
		bcc @+
		inx
		lsr @
		bcc @+
		inx
@		jsr YMHandleChannelCheckNoise
		jmp YMChannelA
YMNoiseClear
		jsr PokeyChannelClear
YMChannelA
		ldx #00 ; channel A
		ldy #00 ; channel 1+2 of 1st Pokey
		lda YMRegisters+7
		and #$01
		bne YMChannelAClear
		jsr YMHandleChannelTone
		jmp YMChannelB
YMChannelAClear
		jsr PokeyChannelClear

YMChannelB
		ldx #01 ; channel B
		ldy #04 ; channel 3+4 of 1st Pokey
		lda YMRegisters+7
		and #$02
		bne YMChannelBClear
		jsr YMHandleChannelTone
		jmp YMChannelC
YMChannelBClear
		jsr PokeyChannelClear

YMChannelC
		ldx #02 ; channel C
		ldy #$10 ; channel 1+2 of second Pokey
		lda YMRegisters+7
		and #$04
		bne YMChannelCClear
		jsr YMHandleChannelTone
		jmp YMSync
YMChannelCClear
		jsr PokeyChannelClear
YMSync
		lda #0
		sta $d01a
		
		lda:cmp:req $14		;wait 1 frame
		
wait		lda $d40b
		cmp #16
		bne wait
		
		lda #$0f
		sta $d01a
		
		lda $d014
		cmp #$0f
		bne @+
		dec NTSCCounter
		bne @+
		lda #$06
		sta NTSCCounter
		bne YMSync

@		jmp PlayYMLoop

NTSCCounter
		dta b(5)

YMCheckEnd
;		cmp #$fd
		jne PlayYMLoop

YMEnd
		jsr InitPokey
; End
		jmp *

YMHandleChannelTone
		; X - YM channel (0,1,2)
		; Y - Pokey channel (0,4,$10,$14)
		lda YMRegisters+8,x ; Volume
		and #$0f
		ora #$e0 ; pure tone
		sta Pokey+3,y
		txa
		asl @
		tax
		lda YMRegisters+1,x
		sta YMFrequency
		lda YMRegisters,x
		asl @
		rol YMFrequency
		asl @
		rol YMFrequency
		asl @
		rol YMFrequency
		sec
		sbc #$07
		bcs @+
		dec YMFrequency
		bmi @+
		lda #$00
		sta YMFrequency
@		sta Pokey,y ; frequency low byte
		lda YMFrequency
		sta Pokey+2,y
		rts

YMHandleChannelCheckNoise
		lda YMRegisters+6
		asl @
		asl @
		asl @
		sec
		sbc #$07
		sta Pokey,y
		bcc PokeyChannelClear
		lda #$00
		;sbc #$00
		sta Pokey+2,y
		lda YMRegisters+8,x ; Volume
		and #$0f
		ora #$80 ; noise
		sta Pokey+3,y
		rts

PokeyChannelClear
		lda #$00
		sta Pokey,y
		sta Pokey+2,y
		sta Pokey+3,y
		rts

InitPokey
; Init Pokey
		lda #$00
		ldx #7
InitPokeyLoop
		sta Pokey,x
		sta Pokey+$10,x
		dex
		bpl InitPokeyLoop
		lda #$00
		sta Pokey+$0f
		sta Pokey+$1f
		lda #$03
		sta Pokey+$0f
		sta Pokey+$1f
		lda #%01111000
		sta Pokey+$08
		sta Pokey+$18
		rts

		run start