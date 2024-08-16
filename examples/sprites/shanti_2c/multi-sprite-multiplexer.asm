; -*- text -*-
; Multisprite Multiplexer
;cdw by 'The Atari Team' 2022
;
; Written for Night Knight
;
; based on Shanti77 & tebe code, thanks for that code!

; The Atari 8bit has 4 Players. they take the whole screen in the hight.
; This code helps to display more than 16 sprites on a screen at the same time. 8bit wide, 16 lines high.
; We need a DLI every 8th display line, they must be at the right position.
; If we accept flickering, more than 4 sprites can be shown in the same horizontal height.
; But you should limit it to 8 sprites the same horizontal height.
; On old tube monitor with a slightly trailing plasma layer these flickering is not very strong.
; In Altirra Emulator you can set Frame blending on in the video configuration.
; On current LED/LCD/OLED Displays it will flicker little bit stronger.
;
; You must create a
; word array @all_sprite_data_table[1] = [...]
; Every sprite data to display need an entry in this table.
; The value of @sprite_shape[i] shows into this table and copy it's data to the player memory to show on screen.
; Which player is used for display isn't fix and vary, only the first sprite is fix and will also NOT flicker.
; Use the first sprite for your own game figure.
; Collision detection is a challenge.
;
; The source code is a little bit lengthy, we use lot of unroll-loop here.
; Especially when writing the data, no loop constructs are used.
;
; Later tests will have to show how many sprites can be displayed on NTSC systems
;
; Restrictions:
; You can't draw sprites over the first DLI + 8 screen lines
; You can't draw sprites under the last DLI
; You should not show more than 8 sprites in horizontal

; changes: 18.03.2024 Tebe/Madteam


pmadr = $B000


	.align

block_c0     .ds 32    ; Sprite color 0
block_c1     .ds 32
block_c2     .ds 32
block_c3     .ds 32

block_x0     .ds 32    ; Sprite Positionen 0
block_x1     .ds 32    ; Sprite Positionen 1
block_x2     .ds 32    ; Sprite Positionen 2
block_x3     .ds 32    ; Sprite Positionen 3

	ert <*<>0

tab_print_sprite

	dta a(print_sprite_0)		; 0000
	dta a(print_sprite_1)		; 0001
	dta a(print_sprite_0)		; 0010
	dta a(print_sprite_2)		; 0011
	dta a(print_sprite_0)		; 0100
	dta a(print_sprite_1)		; 0101
	dta a(print_sprite_0)		; 0110
	dta a(print_sprite_3)		; 0111
	dta a(print_sprite_0)		; 1000
	dta a(print_sprite_1)		; 1001
	dta a(print_sprite_0)		; 1010
	dta a(print_sprite_2)		; 1011
	dta a(print_sprite_0)		; 1100
	dta a(print_sprite_1)		; 1101
	dta a(print_sprite_0)		; 1110
	dta a(print_sprite_null)	; 1111

block_status .ds 32    ; help table for determining the occupation of sprites


@sprite_x
 .DS MAX_SPRITES

@sprite_y
 .DS MAX_SPRITES

@sprite_shape
 .DS MAX_SPRITES

@sprite_color
 .DS MAX_SPRITES


.print 'data: ',*-block_c0



; Sprite initialization
@init_sprites
    lda #MAX_SPRITES-1
    sta last_sprite

    lda #0
    tax
loop2
    sta pmadr+$300,x        ; clear Player/Missiles memory
    sta pmadr+$400,x
    sta pmadr+$500,x
    sta pmadr+$600,x
    sta pmadr+$700,x
    dex
    bne loop2

    rts


;
;     OO                                                    OO    OO
;     OO                                                          OO
;  OOOOO OOOOO   OOOOO OO   OO         OOOO  OOOOO  OOOOO  OOO  OOOOOO  OOOO   OOOO
; OO  OO OO  OO OO  OO OO   OO OOOOOO OO     OO  OO OO  OO  OO    OO   OO  OO OO
; OO  OO OO     OO  OO OO O OO         OOOO  OO  OO OO      OO    OO   OOOOOO  OOOO
; OO  OO OO     OO  OO OO O OO            OO OOOOO  OO      OO    OO   OO         OO
;  OOOOO OO      OOOOO  OO OO          OOOO  OO     OO     OOOO    OOO  OOOO   OOOO
;                                            OO

; draws always all sprites
; may only start from VCOUNT >= 105, otherwise it flickers heavily and display errors occur
@show_sprites
    ldy #0
    sty spr_flag

    lda @sprite_x           ; only sprites with X-Position != 0 will display
    beq no_spieler

    jsr print_sprite        ; player sprite 0 never flicker!
                            ; TIP: Take the lightest color! The darker, the less flickering is noticeable.
no_spieler
    ldy last_sprite

loop3
    lda @sprite_x,y
    beq no_print_sprite

    jsr print_sprite        ; Y register contains sprite number, Akku the X position

no_print_sprite
    dey
    bne there_are_more_sprites
    ldy #MAX_SPRITES-1

there_are_more_sprites
    cpy last_sprite: #$00
    bne loop3

    lda spr_flag: #$00
    beq no_start
    sta last_sprite

no_start
    rts


branch_y dta $00,$1f,$34,$46,$55,$61,$6a,$70


; Draw a sprite. current number [0 to MAX_SPRITE-1] in Y register
print_sprite
;    lda #$32
;    sta colbk

    lda @sprite_y,y    ; bereits gelesen

;    cmp #POSY_MIN     ; check Y position, code is not need here
;    bcc quit
;    cmp #POSY_MAX
;    bcs quit

    sta block_y

    and #7
    tax
    lda branch_y,x

    pha                ; line within a block
    
    bne no_dex
    
    lda block_y
    lsr
    lsr
    lsr
    tax                ; first block number

    dex                ; if dy == 0, then decrement the number of the first block

    lda block_status,x
    ora block_status+1,x
    ora block_status+2,x

    asl @
    sta print_+1

print_
    jmp (tab_print_sprite)


; We have block lines (each 8 real lines high) in here a sprite is moving
no_dex
    lda block_y: #$00
    lsr
    lsr
    lsr
    tax                ; first block number

    lda block_status,x
    ora block_status+1,x
    ora block_status+2,x

    asl @
    sta print+1

print
    jmp (tab_print_sprite)


;    lsr
;    bcc print_sprite_0
;    lsr
;    bcc print_sprite_1
;    lsr
;    bcc print_sprite_2
;    lsr
;    bcc print_sprite_3

print_sprite_null

    pla

; here it is not possible to draw a sprite
    lda spr_flag
    bne quit
    sty spr_flag
quit
    rts


; Y register contains sprite number [0 bis MAX_SPRITES-1]
; X register contains current Y position on the screen (*8 for real height)
print_sprite_0
    pla
    sta clear_sprite_0+1

    inc block_status,x
    inc block_status+2,x

; Set the position and color of sprites in the block
    lda block_x0+3,x
    bne no_inc
    inc block_x0+3,x
no_inc
    lda @sprite_x,y        ; sprite 0
    sta block_x0,x

    lda @sprite_color,y
    sta block_c0,x

    lda @sprite_shape,y    ; in A register is now the sprite shape content

shape_0
;    sty nr_sprite
    ldx block_y                   ; Y position in screen

set_sprite_0
    ____player $0400              ; draw the sprite

    ;ldy nr_sprite

;    lda #$81 ; with this byte it is very easy to see how the players are used.
;    ldx block_y                  ; Y position in screen
    lda #0
clear_sprite_0
    beq cls0                      ; jump to the clear routine

    .pages
; very fast clear functions due to unroll loops

cls0
    sta pmadr+$400+$11,x

    sta pmadr+$400+$10,x

    sta pmadr+$400-8,x
    sta pmadr+$400-7,x
    sta pmadr+$400-6,x
    sta pmadr+$400-5,x
    sta pmadr+$400-4,x
    sta pmadr+$400-3,x
    sta pmadr+$400-2,x
    sta pmadr+$400-1,x

    rts

cls1
    sta pmadr+$400+$13,x
    sta pmadr+$400+$14,x
    sta pmadr+$400+$15,x
    sta pmadr+$400+$16,x
    sta pmadr+$400+$17,x
    sta pmadr+$400+$18,x
    jmp cls7_36

cls2
    sta pmadr+$400+$13,x
    sta pmadr+$400+$14,x
    sta pmadr+$400+$15,x
    sta pmadr+$400+$16,x
    sta pmadr+$400+$17,x
    jmp cls7_30

cls3
    sta pmadr+$400+$13,x
    sta pmadr+$400+$14,x
    sta pmadr+$400+$15,x
    sta pmadr+$400+$16,x
    jmp cls7_24

cls4
    sta pmadr+$400+$13,x
    sta pmadr+$400+$14,x
    sta pmadr+$400+$15,x
    jmp cls7_18


cls5
    sta pmadr+$400+$13,x
    sta pmadr+$400+$14,x
    jmp cls7_12

cls6
    sta pmadr+$400+$13,x
    jmp cls7_6


cls7
    sta pmadr+$400-7,x
cls7_6
    sta pmadr+$400-6,x
cls7_12
    sta pmadr+$400-5,x
cls7_18
    sta pmadr+$400-4,x
cls7_24
    sta pmadr+$400-3,x
cls7_30
    sta pmadr+$400-2,x
cls7_36
    sta pmadr+$400-1,x

    sta pmadr+$400+$10,x
    sta pmadr+$400+$11,x
    sta pmadr+$400+$12,x
    rts

    .endpg


print_sprite_1
    pla
    sta clear_sprite_1+1

    lda #2
    ora block_status,x     ; Claim the selected sprite in status
    sta block_status,x
    lda #2
    ora block_status+2,x
    sta block_status+2,x


    lda block_x1+3,x
    bne no_inc2
    inc block_x1+3,x
no_inc2
    lda @sprite_x,y        ; sprite 1
    sta block_x1,x

    lda @sprite_color,y
    sta block_c1,x

    lda @sprite_shape,y

shape_1
;    sty nr_sprite
    ldx block_y

set_sprite_1
    ____player $0500

;    ldy nr_sprite
;    ldx block_y                   ; Y position in screen
    lda #0
clear_sprite_1
    beq cls0b

    .pages
; very fast clear functions due to unroll loops

cls0b
    sta pmadr+$500+$11,x

    sta pmadr+$500+$10,x

    sta pmadr+$500-8,x
    sta pmadr+$500-7,x
    sta pmadr+$500-6,x
    sta pmadr+$500-5,x
    sta pmadr+$500-4,x
    sta pmadr+$500-3,x
    sta pmadr+$500-2,x
    sta pmadr+$500-1,x

    rts

cls1b
    sta pmadr+$500+$13,x
    sta pmadr+$500+$14,x
    sta pmadr+$500+$15,x
    sta pmadr+$500+$16,x
    sta pmadr+$500+$17,x
    sta pmadr+$500+$18,x
    jmp cls7b_36


cls2b
    sta pmadr+$500+$13,x
    sta pmadr+$500+$14,x
    sta pmadr+$500+$15,x
    sta pmadr+$500+$16,x
    sta pmadr+$500+$17,x
    jmp cls7b_30

cls3b
    sta pmadr+$500+$13,x
    sta pmadr+$500+$14,x
    sta pmadr+$500+$15,x
    sta pmadr+$500+$16,x
    jmp cls7b_24

cls4b
    sta pmadr+$500+$13,x
    sta pmadr+$500+$14,x
    sta pmadr+$500+$15,x
    jmp cls7b_18

cls5b
    sta pmadr+$500+$13,x
    sta pmadr+$500+$14,x
    jmp cls7b_12


cls6b
    sta pmadr+$500+$13,x
    jmp cls7b_6

cls7b
    sta pmadr+$500-7,x
cls7b_6
    sta pmadr+$500-6,x
cls7b_12
    sta pmadr+$500-5,x
cls7b_18
    sta pmadr+$500-4,x
cls7b_24
    sta pmadr+$500-3,x
cls7b_30
    sta pmadr+$500-2,x
cls7b_36
    sta pmadr+$500-1,x

    sta pmadr+$500+$10,x
    sta pmadr+$500+$11,x
    sta pmadr+$500+$12,x
    rts

    .endpg


print_sprite_2
    pla
    sta clear_sprite_2+1

    lda #4
    ora block_status,x    ;Claim the selected sprite in status
    sta block_status,x
    lda #4
    ora block_status+2,x
    sta block_status+2,x


    lda block_x2+3,x
    bne no_inc3
    inc block_x2+3,x
no_inc3
    lda @sprite_x,y        ; sprite 2
    sta block_x2,x

    lda @sprite_color,y
    sta block_c2,x

    lda @sprite_shape,y

shape_2
;    sty nr_sprite
    ldx block_y

set_sprite_2
    ____player $0600

;    ldy nr_sprite
;    ldx block_y                   ; Y position in screen
    lda #0
clear_sprite_2
    beq cls0c


    .pages
; very fast clear functions due to unroll loops

cls0c
    sta pmadr+$600+$11,x

    sta pmadr+$600+$10,x

    sta pmadr+$600-8,x
    sta pmadr+$600-7,x
    sta pmadr+$600-6,x
    sta pmadr+$600-5,x
    sta pmadr+$600-4,x
    sta pmadr+$600-3,x
    sta pmadr+$600-2,x
    sta pmadr+$600-1,x

    rts

cls1c
    sta pmadr+$600+$13,x
    sta pmadr+$600+$14,x
    sta pmadr+$600+$15,x
    sta pmadr+$600+$16,x
    sta pmadr+$600+$17,x
    sta pmadr+$600+$18,x
    jmp cls7c_36


cls2c
    sta pmadr+$600+$13,x
    sta pmadr+$600+$14,x
    sta pmadr+$600+$15,x
    sta pmadr+$600+$16,x
    sta pmadr+$600+$17,x
    jmp cls7c_30

cls3c
    sta pmadr+$600+$13,x
    sta pmadr+$600+$14,x
    sta pmadr+$600+$15,x
    sta pmadr+$600+$16,x
    jmp cls7c_24

cls4c
    sta pmadr+$600+$13,x
    sta pmadr+$600+$14,x
    sta pmadr+$600+$15,x
    jmp cls7c_18

cls5c
    sta pmadr+$600+$13,x
    sta pmadr+$600+$14,x
    jmp cls7c_12


cls6c
    sta pmadr+$600+$13,x
    jmp cls7c_6

cls7c
    sta pmadr+$600-7,x
cls7c_6
    sta pmadr+$600-6,x
cls7c_12
    sta pmadr+$600-5,x
cls7c_18
    sta pmadr+$600-4,x
cls7c_24
    sta pmadr+$600-3,x
cls7c_30
    sta pmadr+$600-2,x
cls7c_36
    sta pmadr+$600-1,x

    sta pmadr+$600+$10,x
    sta pmadr+$600+$11,x
    sta pmadr+$600+$12,x
    rts

    .endpg


print_sprite_3
    pla
    sta clear_sprite_3+1

    lda #8
    ora block_status,x     ;Claim the selected sprite in status
    sta block_status,x
    lda #8
    ora block_status+2,x
    sta block_status+2,x


    lda block_x3+3,x
    bne no_inc4
    inc block_x3+3,x
no_inc4
    lda @sprite_x,y        ; sprite 3
    sta block_x3,x

    lda @sprite_color,y
    sta block_c3,x

    lda @sprite_shape,y

shape_3
;    sty nr_sprite
    ldx block_y

set_sprite_3
    ____player $0700

;    ldy nr_sprite
;    ldx block_y
    lda #0
clear_sprite_3
    beq cls0d


    .pages
; very fast clear functions due to unroll loops

cls0d
    sta pmadr+$700+$11,x

    sta pmadr+$700+$10,x

    sta pmadr+$700-8,x
    sta pmadr+$700-7,x
    sta pmadr+$700-6,x
    sta pmadr+$700-5,x
    sta pmadr+$700-4,x
    sta pmadr+$700-3,x
    sta pmadr+$700-2,x
    sta pmadr+$700-1,x

    rts

cls1d
    sta pmadr+$700+$13,x
    sta pmadr+$700+$14,x
    sta pmadr+$700+$15,x
    sta pmadr+$700+$16,x
    sta pmadr+$700+$17,x
    sta pmadr+$700+$18,x
    jmp cls7d_36


cls2d
    sta pmadr+$700+$13,x
    sta pmadr+$700+$14,x
    sta pmadr+$700+$15,x
    sta pmadr+$700+$16,x
    sta pmadr+$700+$17,x
    jmp cls7d_30

cls3d
    sta pmadr+$700+$13,x
    sta pmadr+$700+$14,x
    sta pmadr+$700+$15,x
    sta pmadr+$700+$16,x
    jmp cls7d_24

cls4d
    sta pmadr+$700+$13,x
    sta pmadr+$700+$14,x
    sta pmadr+$700+$15,x
    jmp cls7d_18

cls5d
    sta pmadr+$700+$13,x
    sta pmadr+$700+$14,x
    jmp cls7d_12


cls6d
    sta pmadr+$700+$13,x
    jmp cls7d_6

cls7d
    sta pmadr+$700-7,x
cls7d_6
    sta pmadr+$700-6,x
cls7d_12
    sta pmadr+$700-5,x
cls7d_18
    sta pmadr+$700-4,x
cls7d_24
    sta pmadr+$700-3,x
cls7d_30
    sta pmadr+$700-2,x
cls7d_36
    sta pmadr+$700-1,x

    sta pmadr+$700+$10,x
    sta pmadr+$700+$11,x
    sta pmadr+$700+$12,x
    rts

    .endpg


; Very fast data copy functions due to unroll loops

.macro	____player (player)
 sty nr_sprite+1
 tay

 :+16 mva data+#*$100,y pmadr+:player+#,x

nr_sprite
 ldy #$00
.endm
