
tvField2VSync
	ldy #$88
	lda pal
	and #$0E
	cmp #$0E ; NTSC ?
	bne not_ntsc
	ldy #$7E
not_ntsc
	cpy vcount
	bne *-3
	lda #0
	sta colpf1
	sta colpf2
	sta colbak
	sta colpm0
	sta colpm1
	sta colpm2
	sta colpm3
	sta wsync
	ldy #3
	sta wsync
	sta wsync
; first line of vsync... half line at blanking level, second half at sync level
	nop ; 105
	sty dmactl ; 109
	ldx #7 ; 111
; Refresh cycles 26 30 34 38 42 46 50 54 58
vbwait1
	dex
	bne vbwait1 ; 5*X-1=34=31 (+2 Ref)= 33
	ldx #3 ; 36 (1)
	nop ; 39 (1)
	nop ; 41
	nop ; 44 (1)
	nop ; 47 (1)
	sta dmactl ; 52 (1)
	nop ; 55 (1)
	nop ; 57 
	stx vscount ; 61 (1)
	ldx #7 ; 63
; Refresh cycles 26 30 34 38 42 46 50 54 58
vbloop1
vbwait3
	dex
	bne vbwait3 ; 5*X-1 = 34 = 97, 
	sty dmactl ; 101 get HSync pulses back in normal order
	nop ; 103
	nop ; 105
	nop ; 107
	sta dmactl ; 111
	dec vscount ; 116 = 2
	beq vsyncend ; 4
	ldx #5 ; 6
vbwait2
	dex
	bne vbwait2 ; 5*X-1 = 24 (+ 2 Ref) = 32
	ldx #6 ; 35 (1)
	nop ; 37
	nop ; 40 (1)
	sty dmactl ; 45 (1)
	sta dmactl ; 51 (2)
	nop ; 53
	nop ; 56 (1)
	nop ; 59 (1)
	nop ; 61
	nop ; 63
	nop ; 65
	jmp vbloop1 ; 68 
; Refresh cycles 26 30 34 38 42 46 50 54 58
vsyncend
	sta wsync
	;lda #$23  ;this works allowing for PMG visible on high border
	lda #$20
	sta dmactl
	rts



;PAL
;effective cycle - DMACtl - state - duration - statement start cycle
;
;        - 0 - L - XX
;274:110 - 3 - H - 57 - 274:106
;275:053 - 0 - L - 49 - 275:048
;275:102 - 3 - H - 10 - 275:098
;275:112 - 0 - L - 49 - 275:108
;276:047 - 3 - H - 05 - 276:042
;276:052 - 0 - L - 50 - 276:047
;276:102 - 3 - H - 10 - 276:098
;276:112 - 0 - L - 49 - 276:108
;277:047 - 3 - H - 05 - 277:042
;277:052 - 0 - L - 50 - 277:047
;277:102 - 3 - H - 10 - 277:098
;277:112 - 0 - L - XX - 277:108
;
;
;
;NTSC (just 20 scan lines earlier than PAL)
;effective cycle - DMACtl - state - duration - statement start cycle
;
;        - 0 - L - XX
;254:110 - 3 - H - 57 - 254:106
;255:053 - 0 - L - 49 - 255:048
;255:102 - 3 - H - 10 - 255:098
;255:112 - 0 - L - 49 - 255:108
;256:047 - 3 - H - 05 - 256:042
;256:052 - 0 - L - 50 - 256:047
;256:102 - 3 - H - 10 - 256:098
;256:112 - 0 - L - 49 - 256:108
;257:047 - 3 - H - 05 - 257:042
;257:052 - 0 - L - 50 - 257:047
;257:102 - 3 - H - 10 - 257:098
;257:112 - 0 - L - XX - 257:108

