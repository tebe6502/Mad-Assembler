; @com.wudsn.ide.asm.mainsourcefile=char_sprites.asm
;******************************************************************

main_init       sei

                lda #1
                sta frame_counter
                lda #0
                sta max_frame

                jsr copychars ;copy charset from rom
                
				jsr disable_roms
                jsr disable_irq
                jsr setup_nmi
                jsr setup_dli
                jsr setup_dma
                jsr setup_colors
                jsr setup_screen
                jsr makechars
				
				;jsr makeshifttables
                jsr switch_vbi
                jsr setup_main
                jsr music_init
                cli
                rts

setup_main
                lda #1
                sta buffer_switched
                lda #0
                sta buffer_rendered
                rts

disable_roms    lda PBCTL
                ora #%00000010
                sta PBCTL
                lda #%000       ;Disable PMs
                sta GRACTL
                                
                lda PORTB
                and #%01111100
                ora #%10000010
                sta PORTB
                rts

disable_irq     lda #$00
                sta IRQEN
                rts

setup_nmi       lda <vbi_handler0
                sta vbi_handler_jmp+1
                lda >vbi_handler0
                sta vbi_handler_jmp+2

                lda #<nmi_handler
                sta NMI
                lda #>nmi_handler
                sta NMI+1
                lda #%11000000
                sta NMIEN
                rts

switch_vbi      lda <vbi_handler
                sta vbi_handler_jmp+1
                lda >vbi_handler
                sta vbi_handler_jmp+2
                rts

setup_dli       
                lda #0
                sta dli_index
                
                lda #<DLIST1
                sta DLISTL
                lda #>DLIST1
                sta DLISTH
                rts

setup_colors    MVA #$82 COLBK
                MVA #$86 COLPF0
                MVA #$18 COLPF1
                MVA #$0E COLPF2
                MVA #$8C COLPF3

                MVA #242 COLPM0
                MVA #242 COLPM1
                MVA #116 COLPM2
                MVA #116 COLPM3
                rts

setup_dma       lda #%00111110 ;DListEnable+OneLinePMResolution+PMEnable+Normal
                sta DMACTL
                lda #0
                sta CHACTL
                lda #%111
                sta GRACTL
                rts

setup_screen    

                lda #0
                sta scroll_value
                sta scroll_value+1
                sta HSCROL

                lda #>charbase2
                sta char_buffer
                
                lda #>ekr2
                sta screen_buffer
                lda #0
                sta current_dlist
                
                lda #125       ;erase screen
                ldx #0
delscr1         sta EKR2,x
                sta EKR2+$100,x
                sta EKR2+$200,x
                sta EKR2+$300,x
                sta EKR1,x
                sta EKR1+$100,x
                sta EKR1+$200,x
                sta EKR1+$300,x

                dex
                bne delscr1


				rts

copychars 		ldy #0
copychars1		lda charbaseos,y
				sta charbase,y
				sta charbase+$400,y
				sta charbase+$800,y
				sta charbase+$c00,y
				sta charbase+$1000,y
				sta charbase+$1400,y
				sta charbase+$1800,y
				sta charbase+$1c00,y
				
				lda charbaseos+$100,y
				sta charbase+$500,y
				sta charbase+$900,y
				sta charbase+$d00,y
				sta charbase+$1100,y
				sta charbase+$1500,y
				sta charbase+$1900,y
				sta charbase+$1d00,y

				lda charbaseos+$200,y
				sta charbase+$600,y
				sta charbase+$a00,y
				sta charbase+$e00,y
				sta charbase+$1200,y
				sta charbase+$1600,y
				sta charbase+$1a00,y
				sta charbase+$1e00,y
				
				lda charbaseos+$300,y
				sta charbase+$700,y
				sta charbase+$b00,y
				sta charbase+$f00,y
				sta charbase+$1300,y
				sta charbase+$1700,y
				sta charbase+$1b00,y
				sta charbase+$1f00,y
				
				dey
				bne copychars1
				rts

makechars		
				ldy #7
makechars1      lda #0
                sta charbase,y
                sta charbase+$400,y
                sta charbase+$800,y
                sta charbase+$c00,y
                sta charbase+$1000,y
                sta charbase+$1400,y
                sta charbase+$1800,y
                sta charbase+$1c00,y
                
                dey
                bpl makechars1

                ldx #15
                
makechars2      lda charbox,x
                ;lda #0
                sta charbase+$3e8,x
                sta charbase+$3e8+$400,x
                sta charbase+$3e8+$800,x
                sta charbase+$3e8+$c00,x
                
                lda charboxb,x
                sta charbase+$3e8+$1000,x
                sta charbase+$3e8+$1400,x
                sta charbase+$3e8+$1800,x
                sta charbase+$3e8+$1c00,x
                dex
                bpl makechars2

                rts

charbox
                .byte %00010000
                .byte %01000101
                .byte %01000000
                .byte %00010001
                .byte %00000100
                .byte %01010000
                .byte %00000101
                .byte %01000100

                .byte %10111000
                .byte %11111100
                .byte %11111100
                .byte %11111100
                .byte %10111000
                .byte %10100100
                .byte %01010100
                .byte %00000000

charboxb
                .byte %00010000
                .byte %01000101
                .byte %01000000
                .byte %00010001
                .byte %00000100
                .byte %01010000
                .byte %00000101
                .byte %01000100

                .byte %10111000
                .byte %11111100
                .byte %11111100
                .byte %11111100
                .byte %10111000
                .byte %10100100
                .byte %01010100
                .byte %00000000


