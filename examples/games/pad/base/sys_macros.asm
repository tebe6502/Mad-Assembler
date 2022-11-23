;================================================================================
; System macros, Atari XL + mads [NRV 2009]
;================================================================================

;--------------------------------------------------------------------------------
; SetVector [address] [word]
;--------------------------------------------------------------------------------

	.macro SetVector
	   .if :0 <> 2
	      .error "SetVector error"

	   .else
	      lda #<:2
	      sta :1
	      lda #>:2
	      sta :1+1
	   .endif

	.endm


;--------------------------------------------------------------------------------
; SetColor [0..4] [0..255]
; SetColor [0..4] [0..15] [0..15]
;--------------------------------------------------------------------------------

	.macro SetColor
	   .if :0 < 2 .or :0 > 3
	      .error "SetColor error"

	   .else
	      .if :0 = 2
	          lda #:2
	          sta COLPF0+:1
	      .else
	          lda #[:2 * 16 + :3]
	          sta COLPF0+:1
	      .endif
	   .endif

	.endm


;--------------------------------------------------------------------------------
; SetPMColor [0..3] [0..255]
; SetPMColor [0..3] [0..15] [0..15]
;--------------------------------------------------------------------------------

	.macro SetPMColor
	   .if :0 < 2 .or :0 > 3
	      .error "SetPMColor error"

	   .else
	      .if :0 = 2
	          lda #:2
	          sta COLPM0+:1
	      .else
	          lda #[:2 * 16 + :3]
	          sta COLPM0+:1
	      .endif
	   .endif

	.endm


;--------------------------------------------------------------------------------
; VcountSync [0..130]
; (maximum limit is different on PAL: 155)
; (could wait forever if there are interrupts activated!)
; (or if some other "thread" uses "wsync")
;--------------------------------------------------------------------------------

	.macro VcountSync
	   .if :0 <> 1
	      .error "VcountSync error"

	   .else
	      sta WSYNC

	      lda #:1
VSync1	 cmp VCOUNT
	      bne VSync1

	      lda #:1+1
VSync2	 cmp VCOUNT
	      bne VSync2

	      sta WSYNC
	   .endif

	.endm


;--------------------------------------------------------------------------------
; VcountWait [0..130]
; (maximum limit is different on PAL: 155)
;--------------------------------------------------------------------------------

	.macro VcountWait
	   .if :0 <> 1
	      .error "VcountWait error"

	   .else
	      lda #:1
VWait1	 cmp VCOUNT
	      bne VWait1
	   .endif

	.endm


;--------------------------------------------------------------------------------
; VcountWaitUntilEnter [0..129] [(p1+1)..130]
; (maximum limit is different on PAL: 155)
;--------------------------------------------------------------------------------

	.macro VcountWaitUntilEnter
	   .if :0 <> 2 .or :1 >= :2
	      .error "VcountWaitUntilEnter error"

	   .else
VWait1     lda VCOUNT
		 cmp #:1
		 beq VExit
	      bcc VWait1	; VCOUNT < :1
		 cmp #:2
		 beq VExit
	      bcs VWait1	; VCOUNT >= :2
VExit
	   .endif

	.endm


;--------------------------------------------------------------------------------
; VcountWaitUntilExit [0..129] [(p1+1)..130]
; (maximum limit is different on PAL: 155)
;--------------------------------------------------------------------------------

	.macro VcountWaitUntilExit
	   .if :0 <> 2 .or :1 >= :2
	      .error "VcountWaitUntilExit error"

	   .else
VWait1     lda VCOUNT
		 cmp #:1
		 beq VWait1
	      bcc VExit	; VCOUNT < :1
		 cmp #:2
	      bcc VWait1	; VCOUNT < :2
		 beq VWait1
VExit
	   .endif

	.endm


;--------------------------------------------------------------------------------
; MarkScanLine [0..255] [0..255]
; (mark the current scan line with a color)
;--------------------------------------------------------------------------------

	.macro MarkScanLine
	   .if :0 <> 0 .and :0 <> 2
	      .error "MarkScanLine error"

	   .else
	  	   .if :0 = 0
  		      sta WSYNC
  	     	 lda #255		; mark color
	  	      sta COLBK

  		      sta WSYNC
  	     	 lda #0		; restore color
	  	      sta COLBK

  		   .else
	     	 sta WSYNC
		      lda #:1		; mark color
		      sta COLBK

		      sta WSYNC
		      lda #:2		; restore color
	     	 sta COLBK
		   .endif
	   .endif

	.endm


;--------------------------------------------------------------------------------
; MarkScanLineIfConsol [0..255] [0..255]
; (mark the current scan line with a color, if a consol key is pressed)
;--------------------------------------------------------------------------------

	.macro MarkScanLineIfConsol
	   .if :0 <> 0 .and :0 <> 2
	      .error "MarkScanLineIfConsol error"

	   .else
		 .if :0 = 0
		      lda CONSOL
		      and #%111
	     	 cmp #%111
		      beq ExitMarkScanLineIfConsol

		      sta WSYNC
		      lda #255		; mark color
		      sta COLBK

		      sta WSYNC
		      lda #0		; restore color
	     	 sta COLBK

	   	 .else
		      lda CONSOL
		      and #%111
	     	 cmp #%111
		      beq ExitMarkScanLineIfConsol

		      sta WSYNC
	     	 lda #:1		; mark color
		      sta COLBK

		      sta WSYNC
	     	 lda #:2		; restore color
		      sta COLBK

	   	 .endif
	   .endif

ExitMarkScanLineIfConsol

	.endm


;--------------------------------------------------------------------------------
; MarkCyclesIfConsol [0..255] [0..255]
; (mark the current scan position with a color, for some cycles)
;--------------------------------------------------------------------------------

	.macro MarkCyclesIfConsol
	   .if :0 = 0
	      lda CONSOL
	      and #%111
	      cmp #%111
	      beq ExitMarkCyclesIfConsol

	      lda #255		; mark color
	      sta COLBK

	      lda ($00),y	; dummy 5 cycles
	      lda ($00),y	; dummy 5 cycles
	      lda ($00),y	; dummy 5 cycles
	      lda ($00),y	; dummy 5 cycles
	      lda ($00),y	; dummy 5 cycles
	      lda ($00),y	; dummy 5 cycles

	      lda #0		; restore color
	      sta COLBK

	   .elseif :0 = 2
	      lda CONSOL
	      and #%111
	      cmp #%111
	      beq ExitMarkCyclesIfConsol

	      lda #:1		; mark color
	      sta COLBK

	      lda ($00),y	; dummy 5 cycles
	      lda ($00),y	; dummy 5 cycles
	      lda ($00),y	; dummy 5 cycles
	      lda ($00),y	; dummy 5 cycles
	      lda ($00),y	; dummy 5 cycles
	      lda ($00),y	; dummy 5 cycles

	      lda #:2		; restore color
	      sta COLBK

	   .else
	      .error "MarkCyclesIfConsol error"

	   .endif

ExitMarkCyclesIfConsol

	.endm


;--------------------------------------------------------------------------------
; SetBasic [0,1]
;--------------------------------------------------------------------------------

	.macro SetBasic
	   .if :0 <> 1
	      .error "SetBasic error"

	   .else
	      .if :1 = 0
	         lda PORTB	; deactivate Basic
	         ora #%00000010
	         sta PORTB
	      .else
	         lda PORTB	; activate Basic
	         and #%11111101
	         sta PORTB
	      .endif
	   .endif

	.endm


;--------------------------------------------------------------------------------
; SetOperativeSystem [0,1]
;--------------------------------------------------------------------------------

	.macro SetOperativeSystem
	   .if :0 <> 1
	      .error "SetOperativeSystem error"

	   .else
	      .if :1 = 0
	         lda PORTB	; deactivate Operative System
	         and #%11111110
	         sta PORTB
	      .else
	         lda PORTB	; activate Operative System
	         ora #%00000001
	         sta PORTB
	      .endif
	   .endif

	.endm


;--------------------------------------------------------------------------------
; EnableBasic
;--------------------------------------------------------------------------------

	.macro EnableBasic
	   .if :0 <> 0
	      .error "EnableBasic error"

	   .else
	      SetBasic 1
	   .endif

	.endm


;--------------------------------------------------------------------------------
; DisableBasic
;--------------------------------------------------------------------------------

	.macro DisableBasic
	   .if :0 <> 0
	      .error "DisableBasic error"

	   .else
	      SetBasic 0
	   .endif

	.endm


;--------------------------------------------------------------------------------
; EnableOperativeSystem
;--------------------------------------------------------------------------------

	.macro EnableOperativeSystem
	   .if :0 <> 0
	      .error "EnableOperativeSystem error"

	   .else
	      SetOperativeSystem 1
	   .endif

	.endm


;--------------------------------------------------------------------------------
; DisableOperativeSystem
;--------------------------------------------------------------------------------

	.macro DisableOperativeSystem
	   .if :0 <> 0
	      .error "DisableOperativeSystem error"

	   .else
	      SetOperativeSystem 0
	   .endif

	.endm


;--------------------------------------------------------------------------------
; EnableNormalInterrupts
;--------------------------------------------------------------------------------

	.macro EnableNormalInterrupts
	   .if :0 <> 0
	      .error "EnableNormalInterrupts error"

	   .else
	      cli
;	      lda #[8+16+32]	; serial I/O interrupts
;	      lda #[64+128]		; keyboard and break interrupts (only ones enabled on powerup)
;	      sta IRQEN
	      lda #64			; VBI interrupt
	      sta NMIEN
	   .endif

	.endm


;--------------------------------------------------------------------------------
; DisableNormalInterrupts
;--------------------------------------------------------------------------------

	.macro DisableNormalInterrupts
	   .if :0 <> 0
	      .error "DisableNormalInterrupts error"

	   .else
	      sei
	      lda #0
	      sta IRQEN
	      sta NMIEN
	   .endif

	.endm


;--------------------------------------------------------------------------------
; ClearSystem
;--------------------------------------------------------------------------------

	.macro ClearSystem
	   .if :0 <> 0
	      .error "ClearSystem error"

	   .else
	      clc
	      cld

	      sei

	      lda #0
	      sta IRQEN	; clear interrupts and screen
	      sta NMIEN

	      sta DMACTL
	      sta COLBK

	      sta GRACTL	; clear P/M
	      sta GRAFP0
	      sta GRAFP1
	      sta GRAFP2
	      sta GRAFP3
	      sta GRAFM

	      sta HPOSP0
	      sta HPOSP1
	      sta HPOSP2
	      sta HPOSP3
	      sta HPOSM0
	      sta HPOSM1
	      sta HPOSM2
	      sta HPOSM3

	      sta PRIOR	; clear GTIA also

	      sta AUDCTL	; clear sound
	      sta AUDC1
	      sta AUDC2
	      sta AUDC3
	      sta AUDC4

	      lda #3
	      sta SKCTL
	   .endif

	.endm


;--------------------------------------------------------------------------------
; SetDisplayListAddress [word]
; (use when the screen is not being displayed!)
; (remember to not cross the 1K limit..)
;--------------------------------------------------------------------------------

	.macro SetDisplayListAddress
	   .if :0 <> 1
	      .error "SetDisplayListAddress error"

	   .else
	      SetVector DLISTL, :1

;	      lda #<:1
;	      sta DLISTL
;	      lda #>:1
;	      sta DLISTH
	   .endif

	.endm


;--------------------------------------------------------------------------------
; SetFontAddress [word]
; (remember that this transform to a page a number)
;--------------------------------------------------------------------------------

	.macro SetFontAddress
	   .if :0 <> 1
	      .error "SetFontAddress error"

	   .else
	      lda #>:1
	      sta CHBASE
	   .endif

	.endm


;--------------------------------------------------------------------------------
; SetPMBaseAddress [word]
; (remember that this transform to a page a number)
;--------------------------------------------------------------------------------

	.macro SetPMBaseAddress
	   .if :0 <> 1
	      .error "SetPMBaseAddress error"

	   .else
	      lda #>:1
	      sta PMBASE
	   .endif

	.endm


;--------------------------------------------------------------------------------
; SetMemory [address] [bytes] [value]
;--------------------------------------------------------------------------------

; warning, using some page zero memory

	.macro SetMemory

setMemPtr	= 254
setMemCounter	= 252

	   .if :0 <> 3
	      .error "SetMemory error"

	   .else
	      ldy #0

	      lda #<:1
	      sta setMemPtr
	      lda #>:1
	      sta setMemPtr+1

	      .if :2 < 256
	         lda #:3
setMemLoop1
	         sta (setMemPtr),y
	         iny
	         cpy #:2
	         bne setMemLoop1

	      .else
	         lda #<:2
	         sta setMemCounter
	         lda #>:2
	         sta setMemCounter+1

setMemLoop2
	         lda #:3
	         sta (setMemPtr),y
	         iny
	         bne setMemB1
	         inc setMemPtr+1
setMemB1
	         lda setMemCounter
	         bne setMemB2
	         dec setMemCounter+1
setMemB2
	         dec setMemCounter

	         lda setMemCounter
	         ora setMemCounter+1
	         bne setMemLoop2
	      .endif
	   .endif

	.endm


;--------------------------------------------------------------------------------
; SetMemoryRandom [address] [bytes]
;--------------------------------------------------------------------------------

; warning, using some page zero memory

	.macro SetMemoryRandom

setMemRPtr	= 254
setMemRCounter	= 252

	   .if :0 <> 2
	      .error "SetMemoryRandom error"

	   .else
	      ldy #0

	      lda #<:1
	      sta setMemRPtr
	      lda #>:1
	      sta setMemRPtr+1

	      .if :2 < 256
setMemRLoop1
	         lda RANDOM
	         sta (setMemRPtr),y
	         iny
	         cpy #:2
	         bne setMemRLoop1

	      .else
	         lda #<:2
	         sta setMemRCounter
	         lda #>:2
	         sta setMemRCounter+1

setMemRLoop2
	         lda RANDOM
	         sta (setMemRPtr),y
	         iny
	         bne setMemRB1
	         inc setMemRPtr+1
setMemRB1
	         lda setMemRCounter
	         bne setMemRB2
	         dec setMemRCounter+1
setMemRB2
	         dec setMemRCounter

	         lda setMemRCounter
	         ora setMemRCounter+1
	         bne setMemRLoop2
	      .endif
	   .endif

	.endm


;--------------------------------------------------------------------------------
; ClampMemory [address] [bytes] [min value] [max value]
;--------------------------------------------------------------------------------

; warning, using some page zero memory

	.macro ClampMemory

clampMemPtr	= 254
clampMemCounter	= 252

	   .if :0 <> 4
	      .error "ClampMemory error"

	   .else
	      ldy #0

	      lda #<:1
	      sta clampMemPtr
	      lda #>:1
	      sta clampMemPtr+1

	      .if :2 < 256
clampMemLoop1
	         lda (clampMemPtr),y
	         cmp #:3
	         bcs clampMemB3		; if >= min then continue
	         lda #:3
	         jmp clampMemB4
clampMemB3
	         cmp #:4
	         bcc clampMemB4		; if < max then continue
;	         beq clampMemB4		; if = max then continue
	         lda #:4
clampMemB4
	         sta (clampMemPtr),y

	         iny
	         cpy #:2
	         bne clampMemLoop1

	      .else
	         lda #<:2
	         sta clampMemCounter
	         lda #>:2
	         sta clampMemCounter+1

clampMemLoop2
	         lda (clampMemPtr),y
	         cmp #:3
	         bcs clampMemB5		; if >= min then continue
	         lda #:3
	         jmp clampMemB6
clampMemB5
	         cmp #:4
	         bcc clampMemB6		; if < max then continue
;	         beq clampMemB6		; if = max then continue
	         lda #:4
clampMemB6
	         sta (clampMemPtr),y

	         iny
	         bne clampMemB1
	         inc clampMemPtr+1
clampMemB1
	         lda clampMemCounter
	         bne clampMemB2
	         dec clampMemCounter+1
clampMemB2
	         dec clampMemCounter

	         lda clampMemCounter
	         ora clampMemCounter+1
	         bne clampMemLoop2
	      .endif
	   .endif

	.endm


;--------------------------------------------------------------------------------
; AndMemory [address] [bytes] [value]
;--------------------------------------------------------------------------------

; warning, using some page zero memory

	.macro AndMemory

andMemPtr	= 254
andMemCounter	= 252

	   .if :0 <> 3
	      .error "AndMemory error"

	   .else
	      ldy #0

	      lda #<:1
	      sta andMemPtr
	      lda #>:1
	      sta andMemPtr+1

	      .if :2 < 256
andMemLoop1
	         lda (andMemPtr),y
	         and #:3
	         sta (andMemPtr),y
	         iny
	         cpy #:2
	         bne andMemLoop1

	      .else
	         lda #<:2
	         sta andMemCounter
	         lda #>:2
	         sta andMemCounter+1

andMemLoop2
	         lda (andMemPtr),y
	         and #:3
	         sta (andMemPtr),y
	         iny
	         bne andMemB1
	         inc andMemPtr+1
andMemB1
	         lda andMemCounter
	         bne andMemB2
	         dec andMemCounter+1
andMemB2
	         dec andMemCounter

	         lda andMemCounter
	         ora andMemCounter+1
	         bne andMemLoop2
	      .endif
	   .endif

	.endm


;--------------------------------------------------------------------------------
; CopyMemory [source address] [dest address] [bytes]
;--------------------------------------------------------------------------------

; warning, using some page zero memory

	.macro CopyMemory

copyMemPtr1	= 254
copyMemPtr2	= 252
copyMemCounter	= 250

	   .if :0 <> 3
	      .error "CopyMemory error"

	   .else
	      ldy #0

	      lda #<:1
	      sta copyMemPtr1
	      lda #>:1
	      sta copyMemPtr1+1

	      lda #<:2
	      sta copyMemPtr2
	      lda #>:2
	      sta copyMemPtr2+1

	      .if :3 < 256
copyMemLoop1
	         lda (copyMemPtr1),y
	         sta (copyMemPtr2),y
	         iny
	         cpy #:3
	         bne copyMemLoop1

	      .else
	         lda #<:3
	         sta copyMemCounter
	         lda #>:3
	         sta copyMemCounter+1

copyMemLoop2
	         lda (copyMemPtr1),y
	         sta (copyMemPtr2),y
	         iny
	         bne copyMemB1
	         inc copyMemPtr1+1
	         inc copyMemPtr2+1
copyMemB1
	         lda copyMemCounter
	         bne copyMemB2
	         dec copyMemCounter+1
copyMemB2
	         dec copyMemCounter

	         lda copyMemCounter
	         ora copyMemCounter+1
	         bne copyMemLoop2
	      .endif
	   .endif

	.endm


;--------------------------------------------------------------------------------
; CreateDisplayList [DL address] [DL mode] [memory address]
; (remember to not cross the 1K limit.. and the 4K limit)
;--------------------------------------------------------------------------------

; 	.macro CreateDisplayList
; 	   .if :0 <> 3
; 	      .error "CreateDisplayList error"
; 
; 	   .else
; 
; 	   .endif
; 
; 	.endm


;--------------------------------------------------------------------------------
;
;--------------------------------------------------------------------------------



