; Original P/M graphics usage:
;   Space       Meteor: P1
;               Starfield: M0
;               Ark: PF
;               Shot: M1
;   Planet      Tractor: BL
;               Shuttleship: P1
;               Beasties: P0/P1
;               Defense: PF
;               Beastie in tractor beam: M1
;               Starfield: M0

        icl     'hardware.inc'
        icl     'kernel.inc'

consol_prev     = $40
temp            = $41
m1pat           = $42       ;pattern to draw for M1 to emulate 8cc

mpos_shot       = $45
ppos_ark        = $46
ppos_meteor     = $47
ppos_shuttle    = $48
ppos_defenses   = $49
star_bytepos    = $4A
star_mode       = $4B
star_mask1      = $4C
star_mask2      = $4D

_grp0   = grafp0
_grp1   = grafp1
_colup0 = colpm0
_colup1 = colpm1

swcha	= $4E
swchb	= $4F

inpt4	= $52
inpt5	= $53
refp0	= $54
		; $55
_audv0	= $56
_audv1	= $57
_audf0	= $5C
_audf1	= $5D
_audc0	= $5E
_audc1	= $5F

;--- $60+ cleared by reset routine ---

;$80-84     P0/P1/M0/M1/BL horizontal position
;$9A        vertical position of ark shot
;$9C        shot direction (1=left, 2=right, 3=up, 4=down)
;$9D        vertical position of ark
;$9F-A0     meteor graphic pointer
;$A3        shuttleship vertical position
;$A8        beastie #1 flags
;   D6=1    on surface
;   D7=1    moving right
;$A9        beastie #2 flags
;   D6=1    on surface
;   D7=1    moving right
;$AA        beasties on board shuttleship
;$AB        shuttleship hit anim timer
;$AD        ark energy
;$AE        score BCD high
;$B0        score BCD mid
;$B2        score BCD low
;$B4-B5     frame counter
;$B6        local temporary
;$B7        local temporary
;$B8        misc flags
;   D7=1    shuttleship out of ark
;   D6=1    planetary view
;   D3=1    game over
;$B9        terrain scroll position
;$BA        meteors left counter
;$BC        game mode
;$BD-BE     score digit 1 graphic pointer
;$BF-C0     score digit 2 graphic pointer
;$C1-C2     score digit 3 graphic pointer
;$C3-C4     score digit 4 graphic pointer
;$C5-C6     score digit 5 graphic pointer
;$C7-C8     score digit 6 graphic pointer
;$C9        ark vertical position
;$CB        last joystick direction
;$CC        random seed
;$CD-CE     shuttleship graphic pointer
;$CF        shuttleship horizontal position
;$D0        starfield HMP0
;$D2        shuttleship motion counter
;$D4        beastie #1 horizontal position
;$D5        beastie #2 horizontal position
;$D6        tractor beam vpos
;$D7        current meteor fast time
;$D8        current meteor close speed
;$D9        automated defense vertical position
;$DA        flags
;   D6=1    automated defenses rising
;   D7=1    automated defense laser on
;$DB        beastie position in tractor beam
;$DD
;$DE-DF     beastie graphic pointer
;$E0        surface timer (counts up every 8 frames)
;$E1        automated defense laser timer
;$E2        meteor fast time
;$E3        meteor close speed
;$E4        shuttleship speed
;$E5        surface timer value for meteor warning
;$E6        automated defense laser period
;$E7        meteors per round
;$E9        beastie type
;$EA        shuttleship color
;$ED        joystick trigger state
;$F2        attract color mask

pf_starfield = $1000
pf_score = $1200
pf_score2 = $1214
pf_energy = $1228

missiles = $1300
player0 = $1400
player1 = $1500
player2 = $1600
player3 = $1700

        org     $2000

dlist_start:
        dta     $70,$70,$70
        .rept 166
        dta     $5C,a(pf_starfield + (((17*#)%160)/8) + (((#*17)%160)&7)*40 - 1)
        .endr

        ;dynamically rewritten to jump to space or planetary sub-dlist
dlist_jump = *+1
        dta     $01,a(dlist_start)

        org     $2400

revtab:
        .rept 256
            dta     [[#&$80]>>7]+[[#&$40]>>5]+[[#&$20]>>3]+[[#&$10]>>1]+[[#&$08]<<1]+[[#&$04]<<3]+[[#&$02]<<5]+[[#&$01]<<7]
        .endr

pf_tr0  dta     $F0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0F
pf_tr1  dta     $F0,$00,$00,$00,$00,$00,$00,$00,$00,$0F,$F0,$00,$00,$00,$00,$00,$00,$00,$00,$0F
pf_tr2  dta     $F0,$00,$00,$FF,$00,$00,$00,$00,$00,$FF,$FF,$00,$00,$00,$00,$00,$FF,$00,$00,$0F
pf_tr3  dta     $FF,$00,$0F,$FF,$F0,$0F,$FF,$00,$FF,$FF,$FF,$FF,$00,$FF,$F0,$0F,$FF,$F0,$00,$FF
pf_tr4  dta     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
pf_tr5  dta     $00,$00,$00,$00,$00,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$00,$00,$00,$00,$00,$00
pf_trb  dta     $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

pf_trptrs:
        :12 dta <pf_trb
        :4 dta  <pf_tr0
        dta     <pf_tr1
        dta     <pf_tr2
        dta     <pf_tr3
        :4 dta  <pf_tr4
        dta     <pf_tr5

dlist_space:
        ;In the original game, the ark top is Y=123, score box top Y=209, digit top Y=212.
        ;We have ark top at Y=113.
        dta     $30
        dta     $66,a(pf_score)
        dta     $06
        dta     $10
        dta     $0B
        dta     $41,a(dlist_start)

dlist_planet:
        dta     $10
        dta     $60
dlist_planet_terrptrs = *+1
        :12 dta $4C,a(pf_tr0)
        dta     $41,a(dlist_start)

        org     $2600
        icl     'sounddrv.asm'
        icl     'consoledrv.asm'

main:
        sei
        lda     #0
        sta     nmien

        ;reset hardware
        ldx     #0
hwres:
        sta     $d000,x
        sta     $d200,x
        sta     $d400,x
        inx
        bpl     hwres

        mva     #$40 irqen

        mva     #3 sizep2
        mva     #3 sizep3

        jsr     InitConsole
        jsr     InitAudio

        ;clear P/M graphics and low memory
        lda     #0
        tax
clearpm:
        sta     missiles,x
        sta     player0,x
        sta     player1,x
        sta     player2,x
        sta     player3,x
        sta     pf_score,x
        sta     pf_starfield,x
        sta     pf_starfield+$100,x
        sta     0,x
        sta     $200,x
        sta     $300,x
        inx
        bne     clearpm

        ;clear char playfields
        lda     #10
        ldx     #39
        sta:rpl pf_score,x-

        ;wait for vertical blank
        lda     #240/2
        cmp:rne vcount

        ;set up initial display list
        mwa     #dlist_start dlistl

        ;set up charset
        mva     #>font0 chbase

        ;turn on P/M and display list DMA
        mva     #>missiles pmbase
        mva     #0 vdelay
        mva     #$3e dmactl
        mva     #$03 gractl
        mva     #$01 prior

        jmp     L1351

        .if * > $2E00
        .error "Overflow"
        .endif

;==============================================================================
        org     $2E00
font0:
        dta     $00,$00,$00,$00,$00,$00,$3E,$22     ;0
        dta     $00,$00,$00,$00,$00,$00,$08,$08     ;1
        dta     $00,$00,$00,$00,$00,$00,$7E,$42     ;2
        dta     $00,$00,$00,$00,$00,$00,$7C,$44     ;3
        dta     $00,$00,$00,$00,$00,$00,$44,$44     ;4
        dta     $00,$00,$00,$00,$00,$00,$7E,$40     ;5
        dta     $00,$00,$00,$00,$00,$00,$7E,$42     ;6
        dta     $00,$00,$00,$00,$00,$00,$3E,$02     ;7
        dta     $00,$00,$00,$00,$00,$00,$3C,$24     ;8
        dta     $00,$00,$00,$00,$00,$00,$3E,$22     ;9
        dta     $00,$00,$00,$00,$00,$00,$00,$00     ;blank
        dta     $00,$00,$00,$00,$00,$00,$00,$00     ;19
        dta     $00,$00,$00,$00,$00,$00,$00,$00     ;82
        dta     $00,$00,$00,$00,$00,$00,$70,$88     ;(C)
        dta     $00,$00,$00,$00,$00,$00,$00,$94     ;im
        dta     $00,$00,$00,$00,$00,$00,$00,$63     ;ag
        dta     $00,$00,$00,$00,$00,$00,$00,$26     ;ic
        dta     $00,$00,$00,$00,$00,$00,$00,$00
        dta     $00,$00,$00,$00,$00,$00,$00,$00
        dta     $00,$00,$00,$00,$00,$00,$00,$00
        dta     $00,$00,$00,$00,$00,$00,$00,$00
        dta     $00,$00,$00,$00,$00,$00,$00,$00
        dta     $00,$00,$00,$00,$00,$00,$00,$00

        dta     $22,$26,$26,$26,$26,$26,$3E,$00     ;0
        dta     $08,$08,$18,$18,$18,$18,$18,$00     ;1
        dta     $02,$02,$7E,$60,$60,$60,$7E,$00     ;2
        dta     $04,$3C,$06,$06,$46,$46,$7E,$00     ;3
        dta     $44,$44,$44,$7E,$0C,$0C,$0C,$00     ;4
        dta     $40,$7E,$06,$06,$46,$46,$7E,$00     ;5
        dta     $40,$40,$7E,$46,$46,$46,$7E,$00     ;6
        dta     $06,$06,$06,$06,$06,$06,$06,$00     ;7
        dta     $24,$3C,$66,$46,$46,$46,$7E,$00     ;8
        dta     $22,$22,$3E,$06,$06,$06,$06,$00     ;9
        dta     $00,$00,$00,$00,$00,$00,$00,$00     ;blank
        dta     $BB,$AA,$BB,$8A,$8A,$8B,$00,$00     ;19
        dta     $B8,$89,$B9,$A1,$A1,$B8,$00,$00     ;82
        dta     $88,$24,$44,$44,$24,$88,$88,$70     ;(C)
        dta     $AA,$AA,$AA,$AA,$AA,$AA,$AA,$00     ;im
        dta     $94,$94,$94,$F5,$94,$94,$93,$00     ;ag
        dta     $A9,$28,$28,$A8,$A8,$A9,$26,$00     ;ic

_INFO0  .macro
        dta     :1
        .endm
_INFO1  .macro
        dta     :2
        .endm
_INFO2  .macro
        dta     :3
        .endm
_INFO3  .macro
        dta     :4
        .endm
_INFO4  .macro
        dta     :5
        .endm
_INFO5  .macro
        dta     :6
        .endm

_INFOS  .macro
        :1      %10101000,%10000001,%00000111,%00011001,%01110111,%00000000
        :1      %10101000,%10000001,%00000001,%01010101,%01000100,%00000000
        :1      %10101000,%10000001,%00010111,%00010101,%01100110,%00000000
        :1      %01001000,%10000001,%00100100,%00010101,%01000100,%00000000
        :1      %01001000,%10000001,%01000100,%01010101,%01000100,%00000000
        :1      %01001010,%10000001,%00000111,%00011001,%01000100,%00000000
        :1      %00000000,%00000000,%00000000,%00000000,%00000000,%00000000
        :1      %00000000,%00000000,%00000000,%00000000,%00000000,%00000000
        .endm

        _INFOS  _INFO0
        _INFOS  _INFO1
        _INFOS  _INFO2
        _INFOS  _INFO3
        _INFOS  _INFO4
        _INFOS  _INFO5

;==============================================================================
        org     $3000
L1000   ldx     #$04
L1002   lda     $80,X
        jsr     L1319           ;reposition sprite
        dex
        bpl     L1002
        lda     $B8             ;get flags
        and     #$08            ;check if game over
        beq     L1018a          ;jump if not
        lda     $B4             ;get frame counter
        and     #$07            ;mask to 8 phases
L1018a  tay                     ;-> index
        lda     starfield_mode,Y;look up starfield NUSIZ0
        sta     star_mode       ;update starfield effect
        lda     starfield_mask1,y
        sta     star_mask1
        lda     starfield_mask2,y
        sta     star_mask2

        ldx     #$02
        lda     $80,X
        jsr     L1319           ;reposition missile 0
        sta     $D0
        lda     #$00
        bit     $B8
        bvc     L103B
        lda     #$A0
L103B   sta     colbk

        lda     #$60
        sta     hposp2
        lda     #$80
        sta     hposp3

        ;draw ark
        lda     #217
        sec
        sbc     $C9
        tay
        sty     ppos_ark
        .rept   19
            lda     $87+18-#
            sta     player3+#,y
            tax
            lda     revtab,x
            sta     player2+#,y
        .endr

        ;repeat last line once
        lda     $87
        sta     player3+19,y
        tax
        lda     revtab,x
        sta     player2+19,y

        ;check if on planet
        bit     $B8
        bvc     no_extended_ark

        sta     player2+20,y
        sta     player2+21,y
        sta     player2+22,y
        sta     player2+23,y
        lda     $87
        sta     player3+20,y
        sta     player3+21,y
        sta     player3+22,y
        sta     player3+23,y

no_extended_ark:

        ;set up display list
        bit     $b8
        bvs     use_planet_dlist
        ldx     #<dlist_space
        ldy     #>dlist_space
        bne     use_space_dlist
use_planet_dlist:
        ldx     #<dlist_planet
        ldy     #>dlist_planet
use_space_dlist:
        stx     dlist_jump
        sty     dlist_jump+1

        ;draw meteor
        lda     $9D
        beq     skip_meteor
        lda     #210
        sec
        sbc     $9D
        tax
        stx     ppos_meteor
        cpx     #198
        bcs     skip_meteor
        ldy     #0
draw_meteor:
        lda     ($9F),y
        sta     player1,x
        inx
        cpx     #198
        bcs     skip_meteor
        iny
        cpy     #8
        bne     draw_meteor
skip_meteor:

        ;check if we should skip planetary rendering
        bit     $B8
        svs:jmp skip_planetary

        ;=== start planetary-only pre rendering ===

        ;draw shuttleship (vclipped >= 138 and <208), planet only
        lda     #214
        sec
        sbc     $A3
        tax
        stx     ppos_shuttle
        cpx     #208
        bcs     skip_shuttle
        ldy     #0
draw_shuttle:
        lda     ($CD),y
        cpx     #138
        scc:sta player1,x
        inx
        iny
        cpy     #8
        bne     draw_shuttle
skip_shuttle:

        ;draw tractor beam
        lda     #220
        sec
        sbc     $D6             ;get tractor beam start vpos
        clc
        adc     #256+128-218
        bmi     skip_tractor
        tax

        lda     #$20

draw_tractor:
        sta     missiles+218-128,x
        inx
        bpl     draw_tractor
skip_tractor:

        ;check if beasties scrolled off
        ldx     $B9
        cpx     #10
        scc:jmp skip_beasties

        ;draw beasties
        lda     $DE
        clc
        adc     #10+1
        sbc     $B9
        tay
        bit     $A8
        svs:jmp skip_beastie1
        bpl     draw_beastie1

draw_beastie1r:
        cpx     #8
        beq     draw_beastie1r_8
        bcs     draw_beastie1r_9
        cpx     #6
        beq     draw_beastie1r_6
        bcs     draw_beastie1r_7
        cpx     #4
        beq     draw_beastie1r_4
        bcs     draw_beastie1r_5
        cpx     #2
        beq     draw_beastie1r_2
        bcs     draw_beastie1r_3
        cpx     #1
        beq     draw_beastie1r_1

        .rept 10,#
.def :draw_beastie1r_:1 = *
            ldx     L1E73+#-10,y
            lda     revtab,x
            sta     player0+208+#
        .endr
        jmp     skip_beastie1

draw_beastie1:
        cpx     #8
        beq     draw_beastie1_8
        bcs     draw_beastie1_9
        cpx     #6
        beq     draw_beastie1_6
        bcs     draw_beastie1_7
        cpx     #4
        beq     draw_beastie1_4
        bcs     draw_beastie1_5
        cpx     #2
        beq     draw_beastie1_2
        bcs     draw_beastie1_3
        cpx     #1
        beq     draw_beastie1_1

        .rept 10,#
.def :draw_beastie1_:1 = *
            lda     L1E73+#-10,y
            sta     player0+208+#
        .endr
skip_beastie1:

        ldx     $B9
        bit     $A9
        svs:jmp skip_beastie2
        bpl     draw_beastie2

draw_beastie2r:
        cpx     #8
        beq     draw_beastie2r_8
        bcs     draw_beastie2r_9
        cpx     #6
        beq     draw_beastie2r_6
        bcs     draw_beastie2r_7
        cpx     #4
        beq     draw_beastie2r_4
        bcs     draw_beastie2r_5
        cpx     #2
        beq     draw_beastie2r_2
        bcs     draw_beastie2r_3
        cpx     #1
        beq     draw_beastie2r_1

        .rept 10,#
.def :draw_beastie2r_:1 = *
            ldx     L1E73+#-10,y
            lda     revtab,x
            sta     player1+208+#
        .endr
        jmp     skip_beastie2

draw_beastie2:
        cpx     #8
        beq     draw_beastie2_8
        bcs     draw_beastie2_9
        cpx     #6
        beq     draw_beastie2_6
        bcs     draw_beastie2_7
        cpx     #4
        beq     draw_beastie2_4
        bcs     draw_beastie2_5
        cpx     #2
        beq     draw_beastie2_2
        bcs     draw_beastie2_3
        cpx     #1
        beq     draw_beastie2_1

        .rept 10,#
.def :draw_beastie2_:1 = *
            lda     L1E73+#-10,y
            sta     player1+208+#
        .endr
skip_beastie2:
skip_beasties:

        ;draw beastie in tractor
        lda     $DB
        beq     no_draw_tractor_beastie
        lda     #215
        sec
        sbc     $DB
        tax

        .rept 8
            lda     missiles+#,x
            ora     #$08
            sta     missiles+#,x
        .endr
no_draw_tractor_beastie:

        ;draw planetary defense
        lda     #219
        sec
        sbc     $D9
        tax
        stx     ppos_defenses

        cpx     #207
        bcs     skip_defenses
        lda     missiles,x
        ora     #%11000011
        sta     missiles,x
        lda     missiles+1,x
        ora     #%11000011
        sta     missiles+1,x

        txa
        clc
        adc     #256+128-209+2
        tax

draw_defenses:
        lda     missiles+209-128,x
        ora     #%01000010
        sta     missiles+209-128,x
        inx
        bpl     draw_defenses
skip_defenses:

        ;draw terrain into display list
        lda     #23
        sec
        sbc     $B9             ;terrain scroll position
        tax
        ldy     #33
draw_terrain:
        lda     pf_trptrs,x
        sta     dlist_planet_terrptrs,y
        dex
        dey
        dey
        dey
        bpl     draw_terrain

        ;=== end planetary-only pre rendering ===

        jmp     skip_space

skip_planetary:
        ;=== begin space-only pre rendering ===
        ;
        ;draw score box
        lda     #$ff
        sta     player2+199
        sta     player2+219
        sta     player3+199
        sta     player3+219

        ldx     #18
draw_scorebox:
        mva     #$80 player2+200,x
        mva     #$01 player3+200,x
        dex
        bpl     draw_scorebox

        ;set up ark energy bar
        ldx     #0
        lda     $AD
        lsr
        lsr
        lsr
        tay
        beq     L12AD
        lda     #$FF
L12A6   sta     pf_energy+7,x
        inx
        dey
        bne     L12A6
L12AD   lda     $AD
        and     #$07
        tay
        lda     L1FAA,y
        sta     pf_energy+7,x
        inx
        lda     #0
L12B8   cpx     #6
        beq     L12C2
        sta     pf_energy+7,x
        inx
        bne     L12B8
L12C2:
        ;=== end space-only pre rendering ===

skip_space:

        ;draw shot
        lda     $9A
        sta     mpos_shot
        beq     no_draw_shot
        lda     #218
        sec
        sbc     $9A
        sta     mpos_shot
        tax
        lda     missiles,x
        ora     m1pat
        sta     missiles,x

        ;draw only one line if firing horizontally
        lda     $9C
        cmp     #3
        bcc     narrow_shot

        .rept 7
            lda     missiles+#+1,x
            ora     m1pat
            sta     missiles+#+1,x
        .endr
narrow_shot:
no_draw_shot:

        ;draw new starfield (M0)
        lda     $82
        lsr
        lsr
        lsr
        tax
        stx     star_bytepos
        lda     $82
        and     #7
        sta     hscrol
        ldy     star_mode
        bit     star_mask1
        seq:jmp star_replicated

        .rept 8
            lda     starfield_masks+[23-#],y
            sta     pf_starfield+40*#+0,x
            sta     pf_starfield+40*#+20,x

            lda     starfield_masks+[15-#],y
            sta     pf_starfield+40*#+1,x
            sta     pf_starfield+40*#+21,x
        .endr

        jmp     star_done

star_replicated:
        .rept 8
            lda     starfield_masks+[23-#],y
            sta     pf_starfield+40*#+0,x
            sta     pf_starfield+40*#+20,x
            sta     pf_starfield+40*#+2,x
            sta     pf_starfield+40*#+22,x
            and     star_mask2
            sta     pf_starfield+40*#+4,x
            sta     pf_starfield+40*#+24,x

            lda     starfield_masks+[15-#],y
            sta     pf_starfield+40*#+1,x
            sta     pf_starfield+40*#+21,x
            sta     pf_starfield+40*#+3,x
            sta     pf_starfield+40*#+23,x
            and     star_mask2
            sta     pf_starfield+40*#+5,x
            sta     pf_starfield+40*#+25,x
        .endr

star_done:
        jsr     UpdateAudio

        ;wait for start of display
        ldx     #32/2
        cpx:rne vcount

        ;=== begin display kernel ===

        sta     hitclr
        lda     $F0
        sta     _colup1
        ldx     #$B8
L1059   stx     wsync

        ;draw space above ark
        txa
        eor     $B4
        sta     colpf0

        dex
        cpx     $C9             ;check against ark vpos
        bne     L1059           ;keep looping if we are above ark

        lda     #$12
        sta     $B6

        ;draw ark
L1088   sta     wsync
        ldy     $B6
        lda     L1FC6,Y
        sta     colpm2
        sta     colpm3
        txa
        eor     $B4
        sta     colpf0

        dex
        dec     $B6
        bpl     L1088
        sta     wsync

        ;check for ark-meteor collision (P1-PF)
        lda     p1pl
        clc
        adc     #$7c
        pha

        ;check if we should draw planet or space
        bit     $B8
        bvs     L10C7           ;jump if planet
        jmp     L1164           ;jump if space

;---- planet rendering
;
L10C7   lda     $CF
        stx     $B7
        ldx     #$01
        jsr     L1319           ;reposition player 1
        sta     wsync

        ;copy playfield color to PF1+PF2 so we can use mode F hack
        lda     L1FC6
        sta     colpf1
        sta     colpf2

        ;copy playfield color to PM0 for planetary defenses
        sta     colpm0

        ;patch display list for laser
        lda     ppos_defenses
        sec
        sbc     #$20
        sta     $BD
        asl
        tay
        lda     #>dlist_start/2
        rol
        sta     wsync

        bit     $DA             ;check if laser is on
        bpl     no_laser

        sta     $BE
        tya
        adc     $BD
        sta     $BD
        scc:inc $BE
        ldy     #3
        lda     #$4F
        sta     ($BD),Y
        ldy     #6
        sta     ($BD),Y

no_laser:

        sta     wsync
        lda     $B7
        sec
        sbc     #$03
        tax
        lda     $EA             ;get shuttleship color
        sta     _colup1
        lda     #$00
        sta     wsync

        ;reposition GTIA M0/M3 for planetary lasers
        sta     wsync
        mva     #$30 hposm0
        mva     #$C8 hposm3
        mva     #%11010111 sizem

        bne     L1122a          ;!! - unconditional

L10F3   sta     wsync
        dex
        cpx     #$13
        beq     L1195
        sta     wsync
L1122a  txa
        eor     $B4
        sta     colpf0          ;update star color

        dex
        cpx     #$13
        bne     L10F3

L1195
L11A6:
        sta     wsync
        sta     wsync
        sta     wsync
        ldx     #$00
        lda     $D4
        jsr     L1319           ;reposition P0 (beastie #1)
        inx
        lda     $D5
        jsr     L1319           ;reposition P1 (beastie #2)
        sta     wsync
        sta     wsync
        sta     wsync
        sta     wsync
        sta     wsync
        lda     #$2E
        sta     _colup0
        sta     _colup1
        ldx     #$0A
        ldy     $A1
        lda     L1E49,Y         ;look up terrain color
        sta     $B6             ;set terrain color
        ldy     $B9             ;get terrain scroll position
L11E6   dey
        bmi     L11F0
        sta     wsync
        dex
        bne     L11E6
        beq     L121E

L11F0   ldy     #0
L11F4   sta     wsync
        lda     $B6             ;get terrain color
        ora     L1E24,Y         ;add in terrain gradient
        sta     colpf0
        sta     colpm2
        iny
        dex
        bne     L11F4
L121E   lda     $B6
        sta     colbk

        ;unpatch display list for laser
        bit     $DA             ;check if laser is on
        bpl     no_laser2

        lda     #$5c
        ldy     #3
        sta     ($BD),y
        ldy     #6
        sta     ($BD),y
no_laser2:

        jmp     L12F4

;---- bottom half of space rendering
;
L1164   sta     wsync

L116A   sta     wsync
        txa
        eor     $B4
        sta     colpf0
        dex
        cpx     #$15
        bne     L116A
        sta     wsync

        ;draw score box
        lda     #$2C            ;text color (orange)
        and     $F2
        sta     colpf1

        lda     #$8C            ;box color (blue)
        and     $F2
        sta     colpm2
        sta     colpm3

        lda     #$44            ;energy color (red)
        sta     colpf0
        mva     #>font0 chbase

        sta     wsync

        ;set up to draw last two lines of first character row
        mva     #6 vscrol

        sta     wsync
        sta     wsync
        sta     wsync
        sta     wsync
        sta     wsync

        ;modify second character row to draw a full 8 lines
        mva     #7 vscrol

L12F4   jmp     L1866

;==============================================================================
; Player/missile reposition
;
L1319   clc
        adc     pm_hpos_adjust,x
        ldy     pmoffset,x
        sta     hposp0,y
        rts

pmoffset:
        dta     0,1,4,5,6

pm_hpos_adjust:
        dta     $30,$30,$30,$30,$30

;==============================================================================
; Reset routine
;
L1351   sei
        cld
        ldx #$FF
        txs
        inx
        txa
L1358   sta $00,X
        inx
        bne L1358
        dec $F2
        ldx #$0B
        lda #$01
        sta $B8
        sta $CC
        sta $BC
        lda #>L1DD8
        sta $CE
        lda #>L1E73
        sta $DF
        lda #$02
        sta $BA
        jsr L1D0C
        jsr L1D45
L1383:
        ;=== start vblank ===

        ;erase ark
        ldx     ppos_ark
        lda     #0
        .rept $18
            sta     player2+#,x
            sta     player3+#,x
        .endr

        ;erase meteor
        ldx     ppos_meteor
        .rept 8
            sta     player1+#,x
        .endr

        ;erase shuttle
        ldx     ppos_shuttle
        .rept 8
            sta     player1+#,x
        .endr

        ;erase tractor beam and beasties in tractor: [138, 215), [208, 218)
        ldx     #39
erase_tractor:
        sta     missiles+138,x
        sta     missiles+158,x
        sta     missiles+178,x
        sta     missiles+198,x
        dex
        bpl     erase_tractor

        ;erase beasties
        lda     #0
        .rept 10
            sta     player0+208+#
            sta     player1+208+#
        .endr

        ;erase shot
        ldx     mpos_shot
        .rept 8
            sta     missiles+#,x
        .endr

        ;clear old starfield
        lda     #0
        ldx     star_bytepos
        .rept 8
            sta     pf_starfield+40*#,x
            sta     pf_starfield+40*#+1,x
            sta     pf_starfield+40*#+2,x
            sta     pf_starfield+40*#+3,x
            sta     pf_starfield+40*#+4,x
            sta     pf_starfield+40*#+5,x
            sta     pf_starfield+40*#+20,x
            sta     pf_starfield+40*#+21,x
            sta     pf_starfield+40*#+22,x
            sta     pf_starfield+40*#+23,x
            sta     pf_starfield+40*#+24,x
            sta     pf_starfield+40*#+25,x
        .endr

        ;update random number generator
        lda     $CC
        asl
        eor     $CC
        asl
        asl
        rol     $CC

        ;block until scan 220
        lda     #220/2-1
        cmp:rcs vcount

        ;erase score box: [199,219]
        ldx     #4
        lda     #0
erase_defenses_score:
        sta     player2+199,x
        sta     player2+204,x
        sta     player2+209,x
        sta     player2+214,x
        sta     player3+199,x
        sta     player3+204,x
        sta     player3+209,x
        sta     player3+214,x
        dex
        bpl     erase_defenses_score
        sta     player2+219
        sta     player3+219

        ;block until vblank
        lda     #248/2-1
        cmp:rcs vcount

        mva     #$e0 chbase

        ;read input
        jsr     UpdateConsole

        jsr     vblank
        jmp     L1000

vblank:
        ;bump frame counter
        inc $B4
        bne L13AC
        inc $B5
        bne L13AC
        bit $DD
        bvs L13A8
        bmi L13AC
L13A8   lda #$F3
        sta $F2
L13AC:

        bit     $DD
        bvs     L13BB
        bmi     L13BF
L13BB   lda     inpt4           ;read joystick 1 trigger
        bpl     L1400
L13BF   lda     swchb
        ror     $B8
        bcs     L13CA
        lsr
        bcs     L1400
        rol
L13CA   lsr
        rol     $B8
        lsr
        bit     $BB
        bcc     L13D6
        rol     $BB
        bne     L141F
L13D6   bpl     L13F5
        lda     $DD
        ora     #$60
        sta     $DD
        jsr     L1BE1
L13E1   lda     $B4
        and     #$1F
        sta     $BB
        inc     $BC
        lda     $BC
        cmp     #$07
        bne     L13FD
        lda     #$01
        sta     $BC
        bne     L13FD
L13F5   lda     $BB
        eor     $B4
        and     #$1F
        beq     L13E1
L13FD   jmp     L1802

L1400   ldy     $BC
        lda     L1428,Y
        sta     $EC
        lda     #$FF
        sta     $F2
        ldx     #$80
        stx     $DD
        jsr     L1BE1
        jsr     L1D0C
        jsr     L1D45
        jsr     L1C01
        lda     #$28            ;40 units
        sta     $AD             ;set ark energy
L141F   lda     $DD
        and     #$20
        beq     L142F
        jmp     L1802

L1428:
        dta     $00,$00,$80,$40,$00,$80,$40

L142F   lda     $B8
        and     #$20
        beq     L148D
        inc     $C9
        bit     $B8
        bvc     L1449
        lda     $B4
        and     #$07
        bne     L1449
        lda     $B9
        cmp     #$0A
        beq     L1449
        inc     $B9
L1449   lda     $C9
        cmp     #$B7
        bne     L148D
        lda     $B8
        and     #$CF
        bit     $EC
        bpl     L1461
        sta     $B8
        inc     $A1
        jsr     L1D7B
        jmp     L146D

L1461   eor     #$40
        sta     $B8
        bit     $B8
        bvc     L146D
        ora     #$10
        sta     $B8
L146D   lda     #$26
        sta     $CA
        bit     $B8
        bvs     L148D
        lda     $AA
        cmp     #$02
        bcc     L148A
        inc     $A1
        lda     #$00
        sta     $AA
        tay
        ldx     #$10
        jsr     L1CEA
        jsr     L1D7B
L148A   jsr     L1C01

        ;pre-draw ark
L148D   lda     $CA
        beq     L14D4
        bmi     L14D4
        lsr
        cmp     #$13
        bcs     L14A4
        tay
        ldx     L1E2E,Y
        lda     L1FB3,X
        sta     $87,X
        jmp     L14D2

L14A4   dec     $C9
        bit     $B8
        bvc     L14B6
        lda     $B4
        and     #$07
        bne     L14B6
        lda     $B9
        beq     L14B6
        dec     $B9
L14B6   lda     $C9
        cmp     #$68
        bne     L14D2
        lda     #$80
        sta     $CA
        lda     #$00
        sta     $A4
        bit     $B8
        bvc     L14D4
        lda     #$4C
        sta     $CF
        lda     #$56
        sta     $A3
        bne     L14D4
L14D2   inc     $CA
L14D4   lda     $AB
        beq     L14F8
        and     #$F8
        clc
        adc     #$E8
        tay
        dec     $AB
        bne     L1502
        lda     #$4C
        sta     $CF
        lda     #$56
        sta     $A3
        rol     $B8
        clc
        ror     $B8
        lda     $AA
        beq     L1502
        jsr     L1C39
        dec     $AA
L14F8   ldy     #<L1DD8
        lda     $B4
        and     #$02
        beq     L1502
        ldy     #<L1DE0
L1502   sty     $CD                 ;set shuttleship graphic pointer low
        lda $CA
        bpl L150F
        lda $9E
        bne L150F
        jsr L1C4B
L150F   ldy $9E
        beq L157E
        ldx $D7
        lda $D1
        clc
        adc $D8
        sta $D1
        bcc L151F
        inx
L151F   stx $B6
        lda $D8
        cmp #$80
        bcs L152B
        lda $D7
        beq L1537
L152B   lda $D8
        sec
        sbc L1FF7,Y
        sta $D8
        bcs L1537
        dec $D7
L1537   ldx #$00
        bit $EE
        bpl L1548
        lda $EF
        and #$07
        tax
        lda L1DC2,X
        tax
        inc $EF
L1548   cpy #$01
        beq L156A
        cpy #$02
        beq L1571
        cpy #$03
        beq L155B
        lda $9D
        clc
        adc $B6
        bne L1560
L155B   lda $9D
        sec
        sbc $B6
L1560   sta $9D
        txa
        clc
        adc $81
        sta $81
        bne L157E
L156A   lda $81
        clc
        adc $B6
        bne L1576
L1571   lda $81
        sec
        sbc $B6
L1576   sta $81
        txa
        clc
        adc $9D
        sta $9D
L157E   ldy #$00
        sty $D6
        bit $B8
        bpl L15C5
        lda $AB
        bne L1593
        jsr L1BF1
        lda     inpt4,X             ;read joystick 1/2 trigger
        sta     $ED
        bpl     L15A3
L1593   lda $A5
        and #$DF
        sta $A5
        lda $DC
        bpl L15C5
        lda #$40
        sta $DC
        bne L15C5
L15A3   lda $A3
        cmp #$4E
        bcs L15C5
        lda $A5
        and #$BF
        ora #$20
        sta $A5
        lda $B4
        lsr
        bcc L15C9
        lda $CF
        clc
        adc #$03
        sta $84
        ldy $A3
        sty $D6
        cpy #$00
        bne L15C9
L15C5   lda $CA
        bmi L15CC
L15C9   jmp L16E9

L15CC   bit $DD
        bpl L15C9
        jsr L1BF1

        ;read joysticks
        lda     swcha

        ;select joystick 1 or 2
        cpx     #$01
        beq     L15DE
        lsr
        lsr
        lsr
        lsr
L15DE   and     #$0F
        bit     $B8
        bmi     L1649
        bvs     L15EA
        ldy     $AD                 ;check ark energy
        beq     L15C9               ;disable firing if no energy
L15EA   cmp     $CB
        beq     L15C9
        sta     $CB
        cmp     #$0B                ;check left
        beq     L1623
        cmp     #$07                ;check right
        beq     L1641
        cmp     #$0E                ;check up
        beq     L1602
        cmp     #$0D                ;check down
        beq     L1610
L1600   bne     L15C9

        ;up
L1602   lda     #$60
        sta     $9A
        lda     #$03
L1608   sta     $9C
        lda     #$50
        sta     $83
        bne     L162F

        ;down
L1610   bit     $B8
        bvc     L161B
        rol     $B8
        sec
        ror $B8
        bne L1649
L161B   lda #$5C
        sta $9A
        lda #$04
        bne L1608

        ;left
L1623   lda #$48
        sta $83
        lda #$01
L1629   sta $9C
        lda #$60
        sta $9A
L162F   lda $A4
        ora #$40
        sta $A4
        bit $B8
        bvs L163B
        dec     $AD
L163B   lda     #$06
        sta     $A6
        bne     L1600

        ;right
L1641   lda #$58
        sta $83
        lda #$02
        bne L1629

L1649   ldx $AB
        beq L164F
        lda #$0F
L164F   sta $B6
        tay
        lda     $A5
        and     #$BF
        cpy     #$0F
        beq     L165C
        ora     #$40
L165C   sta     $A5
        lsr     $B6
        bcs     L16A7
        lda     $D2
        adc     $E4
        sta     $D2
        bcc     L16A7
        lda     $A3
        cmp     #$4D
        bcc     L167A
        lda     $CF
        cmp     #$4B
        bcc     L16A7
        cmp     #$4E
        bcs     L16A7
L167A   inc     $A3             ;move shuttleship up
        lda     $A3
        cmp     #$56
        bne     L16A7
        lda     $B8
        and     #$7F
        sta     $B8
        lda     $A5
        and     #$BF
        sta     $A5
        lda     $AA
        cmp     #$02
        bcc     L16A7
        lda     $E8
        bne     L16A7
        lda     $9E
        bne     L16A7
        lda     $EB
        bne     L16A4
        lda     #$2F
        sta     $AD
L16A4   jsr     L1CBA
L16A7   lsr     $B6
        bcs     L16BB
        lda     $D2
        adc     $E4
        sta     $D2
        bcc     L16BB
        lda     $A3
        cmp     #$16
        bcc     L16BB
        dec     $A3             ;move shuttleship down
L16BB   lda $A3
        cmp #$4E
        bcs L16E9
        lsr $B6
        bcs L16D5
        lda $CF
        cmp #$01
        beq L16D5
        lda $D3
        adc $E4
        sta $D3
        bcc L16D5
        dec $CF
L16D5   lsr $B6
        bcs L16E9
        lda $CF
        cmp #$96
        beq L16E9
        lda $D3
        adc $E4
        sta $D3
        bcc L16E9
        inc $CF
L16E9   ldx     #$00            ;1cc M1+P1
        ldy     #$08
        lda     $9C             ;get shot direction
        beq     L1739           ;skip if no shot
        cmp     #$01            ;check if left
        beq     L1719           ;use wide M1 and move left if so
        cmp     #$02            ;check if right
        beq     L172C           ;use wide M1 and move right if so
        ldx     #$00            ;1cc M1+P1
        cmp     #$03            ;check if up
        beq     L170C           ;use narrow M1 and move up if so
        cmp     #$04            ;check if down
        bne     L1739           ;skip if not
        lda     $9A             ;get shot vpos
        sec                     ;move down
        sbc     #$08            ; "
        sta     $9A             ;update shot vpos
        bmi     L1724
        bpl     L1739

L170C   lda     $9A
        clc
        adc     #$08
        sta     $9A
        cmp     #$C0
        bcs     L1724
        bcc     L1739

L1719:
        ldx     #$0c            ;8cc M1, 1cc P1
        ldy     #$0c
        lda     $83
        sec
        sbc     #$08
        sta     $83
        bpl     L1739
L1724:
        ldx     #$00            ;1cc M1+P1
        ldy     #$08
        stx     $9C
        stx     $9A
        beq     L1739           ;!! - unconditional

L172C:
        ldx     #$0c            ;8cc M1, 1cc P1
        ldy     #$0c
        lda     $83
        clc
        adc     #$08
        sta     $83
        cmp     #$A0
        bcs     L1724
L1739   stx     sizem           ;NUSIZ1
        sty     m1pat

        lda     $A2
        bne     L174D
        lda     $90
        beq     L174D

        ;draw cycling lights in ark
        lda     $B4
        and     #$07
        tay
        lda     L1DD0,Y
        sta     $90

L174D:
        ;draw ark fins
        lda     $A2
        bne     L1770
        ldx     #$FE
        lda     $E8
        beq     L175D
        and     #$10
        beq     L1764
        bne     L1762

L175D   bit     swchb
        bvc     L1764
L1762   ldx     #$FF
L1764   lda     $8E
        beq     L176A
        stx     $8E             ;change ark fins
L176A   lda     $92
        beq     L1770
        stx     $92

L1770:
        lda     $B8             ;get flags
        and     #$08            ;check if game over
        beq     L179C           ;jump if not
        lda     $A2
        cmp     #$01
        bne     L179C
        lda     #>L1DD8
        sta     $A0
        lda     #$50
        sta     $81
        lda     #$50
        sta     $9D
        lda     #$DE
        sta     $F0
        lda     #$30
        sta     $D8
        lda     #$FB
        sta     $D7
        lda     #$40
        sta     $A5
        lda     #$FF
        sta     $AC
L179C   lda     $AC
        beq     L17E5
        lda     $D8
        clc
        adc     #$30
        sta     $D8
        bcc     L17AB
        inc     $D7
L17AB   lda     $D7
        bmi     L17B1
        dec     $9D
L17B1   lda     $D1
        clc
        adc $D8
        sta $D1
        lda $81
        adc $D7
        cmp #$9C
        bcs L17C5
        sta $81
        jmp L17E5

L17C5   lda #$00
        sta $AC
        sta $9D
        sta $A5
        lda #$C0
        sta $DD
        lda $B8
        and #$3F
        sta $B8
        lda $B2
        and #$F0
        sta $B6
        ldx $BC
        dex
        txa
        ora $B6
        sta $B2
L17E5   lda $AC
        beq L17F8
        ldy #$D8
        lda $B4
        and #$02
        bne L17F3
        ldy #$E0
L17F3   sty $9F
        jmp L1802

L17F8   lda     $B4
        and     #$18
        sta     $9F
        lda     #>L1E00
        sta     $A0
L1802   ldy     $85
        lda     $B4
        and     #$07
        bne     L1811
        iny
        cpy     #$12
        bne     L1811
        ldy     #$00
L1811   sty     $85
        lda     L1E59,Y
        sta     $82
        ldx     #$00
        lda     $DD
        and     #$20
        beq     L1831
        txa
        jsr     L1D23           ;set digit #1/2 pointers
        lda     $BC             ;get game mode
        jsr     L1D23           ;set digit #3/4 pointers
        lda     #$AA            ;blanks
        jsr     L1D23           ;set digit #5/6 pointers
        jmp     L1844

L1831   bit     $DD
        bpl     L1856
        lda     $AE             ;get score hi
        jsr     L1D23
        lda     $B0             ;get score mid
        jsr     L1D23
        lda     $B2             ;get score low
        jsr     L1D23
L1844   ldx     #$00
L1846   lda     pf_score+7,x    ;get digit
        and     #$3f            ;check if it's a zero
        bne     L1863           ;end if it's not a zero
        lda     #10             ;use blank
        sta     pf_score+7,x    ;change zero to blank
        sta     pf_score2+7,x   ;change zero to blank
        inx                     ;next char
        cpx     #5              ;check if we're on the last digit
        bne     L1846           ;loop if not
        beq     L1863           ;we're done

L1856   lda     $b5
        lsr
        lda     #$50            ;last logo char 'ic'
        scc:lda #$56
        ldx     #5              ;last position
        sec
L185A   sta     pf_score+7,x    ;set digit
        adc     #22
        sta     pf_score2+7,x
        sbc     #23
        dex
        bpl     L185A
L1863   ;jmp     L1000
        rts

L1866   pla                 ;pop meteor collision
        sta     $B6         ;save collision state
        lda     $DC
        bmi     L1892
        ldx     #$00
        lda     #1
        bit     m2pl        ;check CXP0FB for P0-BL (tractor-beastie1)
        bne     L187D       ;jump if collision
        inx
        asl
        bit     m2pl        ;check CXP1FB for P1-BL (tractor-beastie2)
        beq     L188E       ;jump if no collision
L187D   lda     $DC
        sta     $A8,X
        lda     #$80
        sta     $DC
        lda     #$06
        sta     $DB
        lda     $CF
        clc
        adc     #$03
        sta     $83

L188E   lda     m1pl        ;check for shot-meteor (M1-P1)
        and     #2
        bne     L18E3
        ;beq     L18E3

L1892   lda     $B6         ;get meteor collision state
        bpl     L18C7       ;jump if no meteor-ark collision

        lda     #$00
        sta     $CA
        sta     $A3
        sta     $A4
        sta     $A5
        sta     $DB
        sta     $DC
        lda     $B8
        and     #$7F
        sta     $B8
        lda     #$C0
        sta     $A2
        bit     $DD
        bpl     L1912
        lda     $AD         ;get ark energy
        sec                 ;deduct 10 units
        sbc     #$0A        ; "
        sta     $AD         ;set ark energy
        bcs     L1912       ;jump if non-negative
        lda     #$00        ;clamp ark energy to 0
        sta     $AD         ; "
        lda     $B8         ;
        ora     #$08        ;set game over flag
        sta     $B8
        bne     L1912

L18C7   lda     $B8         ;check if shuttleship outside of ark
        and     $DA         ;check if automated defense laser on
        bpl     L1918       ;miss if either laser off or shuttleship in ark
        lda     $A3         ;get shuttleship vertical position
        cmp     $D9         ;check if lined up with defense laser
        bcs     L1918       ;miss if shuttleship higher
        adc     #$05        ;add shuttleship height
        cmp     $D9         ;check against defense laser position
        bcc     L1918       ;miss if shuttleship lower
        lda     $AB         ;check if already running hit anim
        bne     L1918       ;miss if so
        lda     #$17        ;start hit anim
        sta     $AB         ;set hit anim timer
        bne     L1918       ;!! - unconditional

L18E3   ldy #$00
        sty $9A
        sty $9C
        sty $A7
        ldx #$00
        lda #$10
        bit $EE
        bpl L18F5
        lda #$30
L18F5   jsr L1CEA
        lda $AD
        cmp #$2F
        beq L1900
        inc $AD
L1900   bit $EC
        bpl L190C
        lda $AD
        cmp #$2F
        beq L190C
        inc $AD
L190C   lda $A4
        and #$BF
        sta $A4
L1912   lda #$00
        sta $9E
        sta $9D
L1918   bit $DC
        bvc L1930
        lda $DB
        sec
        sbc #$04
        sta $DB
        cmp #$06
        bcs L1953
        jsr L1C39
        lda #$00
        sta $DC
        sta $DB
L1930   bit $DC
        bpl L1953
        lda $B4
        lsr
        bcc L1953
        inc $DB
        lda $DB
        cmp $A3
        bne L1953
        lda #$00
        sta $DC
        sta $DB
        lda #$0F
        sta $A6
        lda $A4
        ora #$20
        sta $A4
        inc $AA
L1953   lda $A2
        bne L195A
        jmp L19D5

L195A   cmp #$97
        bcs L1969
        lsr
        lsr
        lsr
        tay
        ldx L1E2E,Y
        lda     #$00
        sta     $87,X
L1969   lda $B4
        and #$03
        bne L1986
        ldx #$12
        ldy $CC
L1973   lda $87,X
        beq L1983
        lda L1000,Y
        bne L197D
        tya
L197D   and     L1FB3,X
        sta     $87,X
        iny
L1983   dex
        bpl     L1973
L1986   dec     $A2
        bne     L19D5
        lda     $B8
        and     #$08
        beq     L199E
        lda     $B8
        and     #$3F
        sta     $B8
        lda     #$00
        sta     $A4
        sta     $B5
        beq     L19CF
L199E   bit     $DD
        bpl     L19C3
        bit     $B8
        bvc     L19B0
        lda     #$00
        sta     $AA
        lda     $E7
        sta     $BA
        bne     L19B7
L19B0   lda     $BA             ;add two more meteors to go
        clc
        adc     #$02
        sta     $BA
L19B7   lda     $B8
        and     #$3F
        sta     $B8
        jsr     L1C05
        jmp     L19CC

L19C3   lda $B8
        eor #$40
        sta $B8
        jsr L1C01
L19CC   jsr L1D0C
L19CF   lda $B8
        and #$F7
        sta $B8
L19D5   bit $B8
        bvs L19DC
        jmp L1AA2

L19DC   lda     $B4
        and     #$07
        bne     L1A0A
        inc     $E0             ;bump surface timer
        lda     $E0             ;get surface timer
        cmp     $E5             ;check if time to start meteor warning
        bne     L19F4           ;skip if not
        lda     $B8
        and     #$20
        bne     L19F4
        lda     #$FF
        sta     $E8
L19F4   lda     $DA
        and     #$20
        bne     L1A0A
        lda     $A1
        cmp     #$01
        bcc     L1A0A
        lda     #$10
        cmp     $E0
        bne     L1A0A
        lda     #$60
        sta     $DA
L1A0A:
        ;update beastie graphic
        lda     $E9             ;get current beastie type
        asl                     ;double to graphic base
        tay
        lda     $B4             ;get frame counter
        and     #$04            ;check if frame 2 should be used
        bne     L1A15
        iny                     ;bump to frame 2
L1A15   tya                     ;x10
        jsr     L1D3C           ; "
        sta     $DE             ;set beastie graphic offset

        lda     $B4             ;get frame counter
        and     #$01            ;even/odd frame?
        tax                     ;select beastie
        lda     $A8,X           ;get flags
        bpl     L1A3C           ;jump if going right
        lda     $D4,X
        beq     L1A57
        dec     $D4,X
        lda     $ED             ;check joystick trigger
        bmi     L1A51
        lda     $84
        clc
        adc     #$03
        cmp     $D4,X
        beq     L1A57
        bne     L1A51

L1A3C   lda     $D4,X
        cmp     #$9B
        beq     L1A57
        inc     $D4,X
        lda     inpt4           ;read joystick 1 trigger
        bmi     L1A51
        lda     $D4,X
        clc
        adc     #$07
        cmp $84
        beq L1A57
L1A51   lda $CC
        and #$07
        bne L1A5D
L1A57   lda $A8,X
        eor #$80
        sta $A8,X
L1A5D   lda $DA
        and #$20
        beq L1AA2
        lda $B4
        and #$03
        bne L1A8A
        bit $DA
        bvc L1A80
        inc $D9
        inc $D9
        lda $D9
        cmp #$50
        bne L1A8A
L1A77   lda $DA
        eor #$40
        sta $DA
        jmp L1A8A

L1A80   dec $D9
        dec $D9
        lda $D9
        cmp #$16
        beq L1A77
L1A8A   inc $E1
        rol $DA
        ldx $D9
        cpx #$16
        bcc L1A9C
        lda $E1
        cmp $E6
        clc
        bne L1AA0
        sec
L1A9C   lda #$00
        sta $E1
L1AA0   ror $DA
L1AA2   ldy #$00
        bit $DD
        bmi L1AC7
        jmp L1BCE

L1AAB   ldy     #$08
        and     #$10
        bne     L1AB3
        ldy     #$00
L1AB3   ldx     #$18
        dec     $E8
        bne     L1AC3
        lda     $B8
        and     #$EF
        sta     $B8
        lda     #$01
        sta     $BA
L1AC3   lda     #$01
        bne     L1AE8
L1AC7   lda     $A2
        bne     L1B04
        lda     $E8
        bne     L1AAB
        lda     $A4
        asl
        bcs     L1B38
        asl
        bcs     L1B16
        asl
        bcs     L1AF2
        lda     $AB
        bne     L1AEB
        bit     $DA
        bpl     L1AE8
        ldy     #$0E
        lda     #$08
        ldx     #$01
L1AE8   jmp     L1B60

L1AEB   tax
        lsr
        tay
        lda #$0C
        bne L1AE8
L1AF2   ldy $A6
        ldx $A6
        dec $A6
        bpl L1B00
        lda $A4
        and #$DF
        sta $A4
L1B00   lda #$04
        bne L1AE8
L1B04   lsr
        lsr
        lsr
        lsr
        tay
        ldx #$03
        lda $B4
        lsr
        bcc L1B12
        ldx #$08
L1B12   lda #$01
        bne L1AE8
L1B16   lda #$08
        sec
        sbc $A6
        tax
        ldy $A6
        lda L1B31,Y
        tay
        lda #$01
        dec $A6
        bpl L1B2E
        lda $A4
        and #$BF
        sta $A4
L1B2E   jmp L1B60

L1B31:
        dta     $00,$04,$08,$0C,$08,$04,$02

L1B38   lda $CA
        beq L1B50
        lsr
        cmp #$13
        bcs L1B50
        lsr
        tay
        ldx #$10
        lda $B4
        lsr
        bcc L1B4C
        ldx #$18
L1B4C   lda #$04
        bne L1B60
L1B50   ldx #$08
        lda $B4
        lsr
        lsr
        bcc L1B5A
        ldx #$10
L1B5A   lda #$0C
        ldy #$08
        bne L1B60
L1B60   sty     _audv0
        stx     _audf0
        sta     _audc0
        ldy #$00
        lda $A5
        asl
        bcs L1B9B
        asl
        bcs L1B8B
        asl
        bcs L1B76
        jmp L1BCE

L1B76   ldy #$08
        ldx #$10
        bit $DC
        bpl L1B80
        ldx #$04
L1B80   lda $B4
        and #$01
        bne L1B87
        inx
L1B87   lda #$04
        bne L1BCE
L1B8B   ldy #$00
        lda $B4
        and #$02
        beq L1B95
        ldy #$08
L1B95   ldx #$08
        lda #$04
        bne L1BCE
L1B9B   lda #$10
        sec
        sbc $A7
        tay
        ldx     $BA
        dec     $A7
        bpl     L1BAD
        lda     $A5
        and     #$7F
        sta     $A5
L1BAD   lda     #$08
        bit     $EE
        bpl     L1BBD
        lda     $B4
        and     #$02
        bne     L1BBB
        ldy     #$00
L1BBB   lda     #$0C
L1BBD   cpx     #$00
        bne     L1BCE
        ldx     $F1
        cpx     #$00
        bne     L1BCE
        ldy     $A7
        iny
        ldx     #$02
        lda     #$0C
L1BCE   sty     _audv1
        stx     _audf1
        sta     _audc1
L1BD4   jmp     L1383

;==============================================================================
; Game reset
;
L1BE1   lda #$01
        sta $B8
        ldx #$60
        lda #$00
L1BE9   sta $00,X
        inx
        cpx #$B4
        bne L1BE9
        rts

L1BF1   ldx #$00
        bit $EC
        bvc L1C00
        lda $B8
        asl
        eor     swchb
        bpl L1C00
        inx
L1C00   rts

L1C01   lda     $E7
        sta     $BA
L1C05   lda     #$40
        sta     $DA
        sta     $A8
        lda     #$C0
        sta     $A9
        lda     $A1
        lsr
        sta $F1
L1C14   cmp #$07
        bcc L1C1C
        sbc #$07
        bcs L1C14
L1C1C   sta $E9
        lda #$00
        sta $D4
        sta     $E0             ;reset surface timer
        sta $E1
        sta $D9
        sta $A3
        sta $A5
        ldx $AA
        stx $EB
        beq L1C34
        sta $A9
L1C34   lda #$9B
        sta $D5
        rts

L1C39   ldx #$00
        bit $A8
        bvc L1C40
        inx
L1C40   lda $A8,X
        ora #$40
        sta $A8,X
        lda $83
        sta $D4,X
        rts

L1C4B   ldy #$00
        lda $B8
        and #$10
        beq L1C56
        jmp L1CB7

L1C56   lda $CC
        and #$0C
        bne L1C70
        lda $F1
        beq L1C70
L1C60   dec $F1
        lda #$02
        sta $EF
        lda #$4E
        sta $F0
        lda $EE
        ora #$80
        bne L1C8B
L1C70   lda $BA
        bne L1C81
        lda $F1
        bne L1C60
        ldy #$00
        sty $9D
        sty $9E
        jmp L1CBA

L1C81   dec $BA
        lda #$8E
        sta $F0
        lda $EE
        and #$7F
L1C8B   sta $EE
        lda $CC
        and #$03
        tay
        bit $B8
        bvc L1C9B
        cpy #$03
        bne L1C9B
        dey
L1C9B   lda L1E41,Y             ;look up shot initial vpos
        sta $9D                 ;set shot vpos
        lda L1E45,Y             ;look up shot initial hpos
        sta $81                 ;set shot hpos
        lda $E2
        sta $D7
        lda $E3
        sta $D8
        rol $A5
        sec
        ror $A5
        lda #$10
        sta $A7
        iny
L1CB7   sty $9E
        rts

L1CBA   lda $B8
        ora #$20
        sta $B8
        lda $A4
        ora #$80
        sta $A4
        lda $AA
        sec
        sbc $EB
        tax
        lda #$00
        sta $CA
        sta $A3
        sta $DA
        sta $D9
L1CD6   dex
        bmi L1CDE
        clc
        adc #$0A
        bne L1CD6
L1CDE   clc
        adc $AD
        cmp #$30
        bcc L1CE7
        lda #$2F
L1CE7   sta $AD
        rts

;==============================================================================
; Update score
;
L1CEA   sed
        clc
        adc $00B2,Y
        sta $00B2,Y
        txa
        bcc L1CF7
        adc #$00
L1CF7   clc
        adc $00B0,Y
        sta $00B0,Y
        lda #$00
        bcc L1D04
        adc #$00
L1D04   adc $00AE,Y
        sta $00AE,Y
        cld
        rts

;==============================================================================
L1D0C   lda #$B7
        sta $C9
        lda #$40
        sta $84
        lda #$0A
        sta $B9
        lda #$01
        sta $CA
        lda $A4
        ora #$80
        sta $A4
        rts

;==============================================================================
; BCD to digit pair graphic offsets
;
L1D23   pha
        lsr
        lsr
        lsr
        lsr
        ora     #$40
        sta     pf_score+7,x
        clc
        adc     #$17
        sta     pf_score2+7,x
        inx
        pla
        and     #$0F
        ora     #$40
        sta     pf_score+7,x
        clc
        adc     #$17
        sta     pf_score2+7,x
        inx
        rts

;==============================================================================
; Multiply x10
;
L1D3C   asl                     ;x2
        sta     $B6             ;stash
        asl                     ;x4
        asl                     ;x8
        clc                     ;
        adc     $B6             ;x10
        rts

;==============================================================================
L1D45   lda     $BC             ;get current game mode
        cmp     #$04            ;check if advanced
        lda     #$02
        sta     $E2             ;set meteor fast time
        lda     #$70            ;slow meteor speed
        bcc     L1D53           ;jump if not advanced
        lda     #$F0            ;fast meteor speed
L1D53   sta     $E3             ;set meteor speed
        lda     #$80            ;slow shuttleship speed
        bcc     L1D5B           ;jump if not advanced
        lda     #$E0            ;fast shuttleship speed
L1D5B   sta     $E4             ;set shuttleship speed
        lda     #$70            ;set automated defense fire rate to 112 frames (~1.9s)
        bcc     L1D63
        lda     #$10            ;set automated defense fire rate to 16 frames (4/s)
L1D63   sta     $E6             ;set automated defense fire rate
        lda     #$70            ;set meteor warning to 112*8 frames (15 seconds)
        bcc     L1D6B
        lda     #$40            ;set meteor warning to 64*8 frames (8.5 seconds)
L1D6B   sta     $E5
        lda     #$08            ;8 meteors/round for normal
        bcc     L1D73
        lda     #$14            ;20 meteors/round for advanced
L1D73   sta     $E7             ;set meteor count per round
        lda     L1DBE
        sta     $EA             ;set shuttleship color
        rts

L1D7B   lda     $A1
        and     #$03
        bne     L1D96
        lda     $A1
        lsr
        lsr
        and     #$03
        tay
        lda     L1DBE,Y         ;look up shuttleship color
        sta     $EA             ;set shuttleship color
        lda     $E4
        clc
        adc     #$08
        bcs     L1D96
        sta     $E4
L1D96   lda     $E6
        sec
        sbc #$08
        beq L1D9F
        sta $E6
L1D9F   lda $E7
        cmp #$1E
        beq L1DA7
        inc $E7
L1DA7   lda $E3             ;get meteor speed
        clc                 ;increase it a bit
        adc #$10            ; "
        sta $E3             ;set meteor speed
        bcc L1DB2
        inc $E2
L1DB2   lda $E5
        cmp #$30
        beq L1DBD
        sec
        sbc #$04
        sta $E5
L1DBD   rts

;==============================================================================
        org     $2ABE

;==============================================================================
; Shuttleship color
;
L1DBE   dta     $DE,$8E,$4E,$2E

;==============================================================================
; Wobbly meteor motion table
;
L1DC2   dta     $FF,$FF,$FF,$FF,$01,$01,$01,$01

;==============================================================================
        dta     $FF,$FF,$FF,$FF,$FF,$FF

;==============================================================================
; Cycling ark lights
;
L1DD0   dta     $FC,$F8,$F4,$EC,$DC,$BC,$7C,$FC

;==============================================================================
; Shuttleship graphics
;
        .pages 1
L1DD8   dta     $00,$18,$FF,$70,$FF,$18,$00,$00     ;ship 1
L1DE0   dta     $00,$18,$FF,$0E,$FF,$18,$00,$00     ;ship 2
L1DE8   dta     $00,$20,$04,$81,$00,$20,$08,$81     ;explosion 3
        dta     $42,$00,$10,$4A,$10,$08,$42,$24     ;explosion 2
        dta     $18,$A5,$00,$A5,$00,$A5,$18,$00     ;explosion 1
        .endpg

;==============================================================================
; Meteor graphics
;
        .pages 1
L1E00   dta     $00,$3C,$7E,$6F,$5F,$3A,$1E,$0C
        dta     $00,$1C,$2E,$76,$FE,$DE,$7C,$18
        dta     $30,$78,$5C,$FA,$F6,$7E,$3C,$00
        dta     $18,$3E,$78,$7F,$6E,$74,$38,$00
        .endpg

;==============================================================================
        dta     $11,$21,$22,$33

;==============================================================================
; Terrain gradient
;
L1E24   dta     $0C,$0C,$0C,$0C,$0C,$0A,$08,$06,$04,$02

;==============================================================================
; Ark graphic index table
;
L1E2E   dta     $09,$08,$0A,$07,$0B,$06,$0C,$05,$0D,$04,$0E,$03,$0F,$02,$10,$01
        dta     $11,$00,$12

;==============================================================================
; Shot initial vpos
;
L1E41   dta     $5B,$5B,$C0,$00

;==============================================================================
; Shot initial hpos
;
L1E45   dta     $00,$98,$4C,$4C

;==============================================================================
; Terrain colors
;
L1E49   dta     $C0,$20,$50,$80,$F0,$A0,$C8,$E4,$F0,$44,$88,$64,$30,$50,$90,$00

;==============================================================================
; Starfield position loop
;
L1E59   dta     $0D,$1C,$2B,$3A,$49,$58,$67,$76,$85,$94,$85,$76,$67,$58,$49,$3A
        dta     $2B,$1C

;==============================================================================
; Beastie graphics (must be in one page)
;
        .pages 1
L1E73:
        dta     $00,$38,$28,$28,$38,$08,$38,$20,$38,$00
        dta     $00,$00,$00,$38,$28,$38,$28,$38,$38,$00

        dta     $00,$00,$00,$38,$10,$10,$38,$28,$08,$08
        dta     $00,$00,$00,$00,$38,$10,$38,$28,$20,$20

        dta     $00,$00,$00,$00,$00,$08,$4C,$38,$44,$00
        dta     $00,$00,$00,$00,$00,$08,$0C,$78,$28,$00

        dta     $00,$08,$14,$18,$1C,$10,$10,$10,$20,$00
        dta     $00,$00,$08,$14,$18,$1C,$10,$08,$00,$00

        dta     $24,$24,$18,$00,$00,$00,$00,$00,$00,$00
        dta     $00,$18,$24,$00,$00,$00,$00,$00,$00,$00

        dta     $00,$00,$18,$3C,$18,$3C,$3C,$0C,$04,$00
        dta     $00,$00,$18,$3C,$24,$3C,$3C,$30,$20,$00

        dta     $00,$00,$00,$18,$30,$20,$30,$18,$00,$00
        dta     $00,$00,$00,$18,$3C,$20,$3C,$18,$00,$00
        .endpg

        dta     $00

;==============================================================================
; Energy bar graphics
;
L1FAA   dta     $00,$80,$C0,$E0,$F0,$F8,$FC,$FE,$FF

;==============================================================================
; Starfield mode (formerly NUSIZ0)
;
;L1E6B   dta     $00,$02,$03,$12,$13,$23,$32,$33

starfield_mode:
        dta     $00,$00,$00,$18,$18,$30,$48,$48
starfield_mask1:
        dta     $00,$FF,$FF,$FF,$FF,$FF,$FF,$FF
starfield_mask2:
        dta     $00,$00,$FF,$00,$FF,$FF,$00,$FF

;==============================================================================
starfield_masks:
        dta     $00,$00,$00,$00,$00,$00,$00,$00
        dta     $00,$00,$00,$00,$00,$00,$00,$00
;        dta     $80,$40,$20,$10,$08,$04,$02,$01
        dta     $80,$60,$20,$10,$08,$04,$03,$01

        dta     $00,$00,$00,$00,$00,$00,$00,$00
        dta     $00,$00,$00,$00,$00,$00,$00,$80
        dta     $C0,$60,$30,$18,$0C,$06,$03,$01

        dta     $00,$00,$00,$00,$00,$00,$00,$00
        dta     $00,$00,$00,$00,$00,$80,$C0,$E0
        dta     $F0,$78,$3C,$1E,$0F,$07,$03,$01

        dta     $00,$00,$00,$00,$00,$00,$00,$00
        dta     $00,$80,$C0,$E0,$F0,$F8,$FC,$FE
        dta     $FF,$7F,$3F,$1F,$0F,$07,$03,$01
        dta     $00,$00,$00,$00,$00,$00,$00,$00
        dta     $00

;==============================================================================
; Ark graphics (right side)
;
L1FB3   dta     $80,$C0,$E0,$F0,$F8,$FC,$FE,$FF,$FE,$FC,$FE,$FF,$FE,$FC,$F8,$F0
        dta     $E0,$C0,$80

;==============================================================================
; Ark colors
;
L1FC6   dta     $4E,$4C,$4A,$48,$46,$44,$42,$4E,$42,$0E,$42,$4E,$42,$44,$46,$48
        dta     $4A,$4C,$4E

;==============================================================================
L1FF7   dta     $00,$18,$18,$08,$08,$51,$13,$51,$13

;==============================================================================
        run     main
