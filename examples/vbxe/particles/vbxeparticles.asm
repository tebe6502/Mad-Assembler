        icl     'system.inc'
        icl     'hardware.inc'

setvbv = $E45C

vbxe_core_revision = $40
vbxe_minor_revision = $41
vbxe_coldetect = $4A
vbxe_blt_collision_code = $50
vbxe_blitter_busy = $53
vbxe_irq_status = $54
vbxe_memac_control = $5E
vbxe_memac_bank_sel = $5F

vbxe_video_control = $40
vbxe_xdl_adr0 = $41
vbxe_xdl_adr1 = $42
vbxe_xdl_adr2 = $43
vbxe_csel = $44
vbxe_psel = $45
vbxe_cr = $46
vbxe_cg = $47
vbxe_cb = $48
vbxe_colmask = $49
vbxe_colclr = $4a
vbxe_bl_adr0 = $50
vbxe_bl_adr1 = $51
vbxe_bl_adr2 = $52
vbxe_blitter_start = $53
vbxe_irq_control = $54
vbxe_p0 = $55
vbxe_p1 = $56
vbxe_p2 = $57
vbxe_p3 = $58
vbxe_memac_b_control = $5D

vbxe_base = $D600

        org     $2000

;===============================================================================
.proc main
        ;enable MEMAC A aperture at $8000-BFFF for CPU access
        mva     #$8A vbxe_base+vbxe_memac_control
        mva     #$80 vbxe_base+vbxe_memac_bank_sel

        ;copy rdata to MEMAC A window
        ldx     #>[vbxe_rdata_end+$FF]
        ldy     #0
        mwa     #[.adr vbxe_rdata_start] $80
        mwa     #$8000 $82
copy_loop:
        mva:rne ($80),y ($82),y+
        inc     $81
        inc     $83
        dex
        bne     copy_loop

        ;execute init blit
        mwa     #blit_init vbxe_base+vbxe_bl_adr0
        mva     #0 vbxe_base+vbxe_bl_adr2
        mva     #1 vbxe_base+vbxe_blitter_start
        lda:rne vbxe_base+vbxe_blitter_busy

        ;wait for vbl
        lda     #124
        cmp:rne vcount

        ;disable MEMAC A
        mva     #$00 vbxe_base+vbxe_memac_bank_sel

        ;set XDL address
        mwa     #xdl vbxe_base+vbxe_xdl_adr0
        mva     #0 vbxe_base+vbxe_xdl_adr2

        ;overlay trans 0, no xcolor, XDL on
        mva     #$01 vbxe_base+vbxe_video_control

        ;set final blitter address
        mwa     #$8000 vbxe_base+vbxe_bl_adr0
        mva     #0 vbxe_base+vbxe_bl_adr2

        ;revector VBI
        mwa     vvblki vbi.vbi_vector
        lda     #6
        ldx     #>vbi
        ldy     #<vbi
        jsr     setvbv

        ;all done
        mwa     #msg icbal
        mva     #[.len msg] icbll
        mva     #CIOCmdPutChars iccmd
        ldx     #0
        jsr     ciov

        lda     #$ff
        sta     ch
        cmp:req ch
        rts
.endp

.proc msg
        dta     'Press any key',$9B
.endp

;===============================================================================
; $01000-010FF  position Y low
; $01100-011FF  position X low
; $01200-012FF  velocity Y low
; $01300-013FF  velocity X low
; $01400-014FF  acceleration Y low
; $01500-015FF  position Y high
; $01600-016FF  position X high
; $01700-017FF  velocity Y high
; $01800-018FF  velocity X high
; $01900-019FF  acceleration Y high
;
        org     0,*

vbxe_rdata_start = *

lfsr_tab:
        :256 dta <[(# << 8) ^ (# << 6) ^ (# << 2) ^ (# << 1) ^ $FFFF]
        :256 dta >[(# << 8) ^ (# << 6) ^ (# << 2) ^ (# << 1) ^ $FFFF]

;               source                  destination             size          AND/XOR/coll zoom pat mode
blit_template_clear:
        ;clear particle
        dta     e($10000),a($0100),$01, e($10000),a($0100),$01, a($0000),$00, $00,$00,$00, $00,$00,$08

blit_template_draw:
        ;draw particle
        dta     e($10000),a($0100),$01, e($10000),a($0100),$01, a($0000),$00, $00,$01,$00, $00,$00,$08

blit_template_phys_update:
        ;blit position high X/Y to erase blit list
        dta     e($01500),a($0100),$01, e($08007),a($FFFF),$15, a($00FF),$01, $FF,$00,$00, $00,$00,$08

        ;set carry arrays to $81 (256 x 3)
        dta     e($00000),a($0000),$00, e($02000),a($0100),$01, a($00FF),$02, $00,$81,$00, $00,$00,$08

        ;add velocity Y low to position Y low
        ;add velocity X low to position X low
        ;add accel Y low to velocity Y low
        dta     e($01200),a($0100),$01, e($01000),a($0100),$01, a($00FF),$02, $FF,$00,$00, $00,$00,$0A

        ;stencil blit inverted carries to carry array
        dta     e($01000),a($0100),$01, e($02000),a($0100),$01, a($00FF),$02, $80,$80,$00, $00,$00,$09

        ;clear carries from low arrays (AND $7F)
        dta     e($01000),a($0100),$01, e($01000),a($0100),$01, a($00FF),$02, $00,$7F,$00, $00,$00,$0C

        ;add carries to high arrays
        dta     e($02000),a($0100),$01, e($01500),a($0100),$01, a($00FF),$02, $FF,$80,$00, $00,$00,$0A

        ;add velocity Y high to position Y high
        ;add velocity X high to position X high
        ;add accel Y high to velocity Y high
        dta     e($01700),a($0100),$01, e($01500),a($0100),$01, a($00FF),$02, $FF,$00,$00, $00,$00,$0A

        ;check for any particle Y >= $C0, X < $10, or X > $F0
        ;evaluated as: (Y & (Y - $40)) | ((X - $10) & (X - $70))

        ;1. temp1 = -$40
        dta     e($00000),a($0000),$00, e($02000),a($0000),$01, a($00FF),$00, $00,$C0,$00, $00,$00,$08
        
        ;2. temp1 += Y
        dta     e($01500),a($0000),$01, e($02000),a($0000),$01, a($00FF),$00, $FF,$00,$00, $00,$00,$0A
        
        ;3. temp1 &= Y
        dta     e($01500),a($0000),$01, e($02000),a($0000),$01, a($00FF),$00, $80,$00,$00, $00,$00,$0C
        
        ;4. temp2 = -$10
        dta     e($00000),a($0000),$00, e($02100),a($0000),$01, a($00FF),$00, $00,$F0,$00, $00,$00,$08
        
        ;5. temp3 = -$70
        dta     e($00000),a($0000),$00, e($02200),a($0000),$01, a($00FF),$00, $00,$90,$00, $00,$00,$08
        
        ;6. temp2,temp3 += X
        dta     e($01600),a($0000),$01, e($02100),a($0100),$01, a($00FF),$01, $FF,$00,$00, $00,$00,$0A
        
        ;7. temp2 &= temp3
        dta     e($02200),a($0000),$01, e($02100),a($0000),$01, a($00FF),$00, $FF,$00,$00, $00,$00,$0C
        
        ;8. temp1 |= temp2
        dta     e($02100),a($0000),$01, e($02000),a($0000),$01, a($00FF),$00, $FF,$00,$00, $00,$00,$0B
        
        ;9. kill = $7F
        dta     e($00000),a($0000),$00, e($02400),a($0000),$01, a($00FF),$00, $00,$7F,$00, $00,$00,$08

        ;10. stencil blit to convert bit 7 to $7F/80 -- later XOR $7F to convert to $00/$FF
        dta     e($02000),a($0000),$01, e($02400),a($0000),$01, a($00FF),$00, $80,$00,$00, $00,$00,$09

        ;kill velocity and acceleration and force Y=$FF for any particle OOB
        dta     e($02400),a($0000),$01, e($01200),a($0000),$01, a($00FF),$02, $FF,$80,$00, $00,$00,$0C
        dta     e($02400),a($0000),$01, e($01700),a($0000),$01, a($00FF),$02, $FF,$80,$00, $00,$00,$0C
        dta     e($02400),a($0000),$01, e($01500),a($0000),$01, a($00FF),$00, $FF,$7F,$00, $00,$00,$0B

        ;initialize a new particle

blit_init_particle_begin:
        ;1. set position, velocity, and acceleration
        dta     e(new_particle_pos+0),a($0001),$00, e($01000),a($0100),$00, a($0000),$04, $FF,$00,$00, $00,$00,$08
        dta     e(new_particle_pos+5),a($0001),$00, e($01500),a($0100),$00, a($0000),$04, $FF,$00,$00, $00,$00,$08

        ;2. set velocity X low from RNG
        dta     e($07FF0),a($0000),$00, e($01300),a($0000),$00, a($0000),$00, $7F,$00,$00, $00,$00,$08

        ;3. sign extend velocity X low to velocity X high
        dta     e($07FF0),a($0000),$00, e($01800),a($0000),$00, a($0000),$00, $80,$00,$00, $00,$00,$09
        dta     e($07FF0),a($0000),$00, e($01800),a($0000),$00, a($0000),$00, $00,$7F,$00, $00,$00,$0A

        ;4. set velocity Y low from RNG
        dta     e($07FF1),a($0001),$00, e($01200),a($0000),$00, a($0000),$00, $7F,$80,$00, $00,$00,$08

        ;5. increment to next particle (6x1 increment blit)
        dta     e($00000),a($0000),$00, e(blit_init_particle_begin-blit_template_phys_update+$AA00+6),a($0000),$15, a($0005),$00, $00,$01,$00, $00,$00,$0A

        ;blit position high X/Y to draw blit list
        dta     e($01500),a($0100),$01, e($09507),a($FFFF),$15, a($00FF),$01, $FF,$00,$00, $00,$00,$08

        ;update 32-bit RNG LFSR @ $7FF0

        ;1. copy lowest two bytes into blit list
        dta     e($07FF0),a($0001),$00, e(*-blit_template_phys_update+$AA00+$15*2-6),a($0015),$00, a($0000),$01, $FF,$00,$00, $00,$00,$08

        ;2. shift register right 16 bits (4x1 blit move down by 2)
        dta     e($07FF2),a($0100),$00, e($07FF0),a($0001),$00, a($0000),$03, $FF,$00,$00, $00,$00,$08

        ;3. XOR in contribution from first byte
        dta     e($00000),a($0100),$00, e($07FF1),a($0001),$00, a($0000),$01, $FF,$00,$00, $00,$00,$0D

        ;4. XOR in contribution from second byte
        dta     e($00000),a($0100),$00, e($07FF2),a($0001),$00, a($0000),$01, $FF,$00,$00, $00,$00,$05

blit_template_phys_update_end:

new_particle_pos:
        dta     $40,$40,$00,$00,$04     ;pyl, pxl, vyl, vxl, ayl
        dta     $BF,$80,$FC,$81,$00     ;pyh, pxh, vyh, vxh, ayh

blit_init:
        ;clear VBXE memory from $01000-7FFFF ($200 x $7F zoom 8x1 descending)
        dta     e($00000),a($0000),$00, e($7FFFF),a($F000),$FF, a($01FF),$7E, $00,$00,$00, $07,$00,$08
        
        ;initialize blit list at $8000
        dta     e(blit_template_clear      ),a($0000),$01, e($08000),a($0015),$01, a($0014),$FF, $FF,$00,$00, $00,$00,$08
        dta     e(blit_template_draw       ),a($0000),$01, e($09500),a($0015),$01, a($0014),$FF, $FF,$00,$00, $00,$00,$08
        dta     e($09510                   ),a($0015),$01, e($09525),a($0015),$01, a($0000),$FE, $FF,$00,$00, $00,$00,$0A
        dta     e($09510                   ),a($0015),$01, e($09510),a($0015),$01, a($0000),$FF, $00,$08,$00, $00,$00,$0B
        dta     e(blit_template_phys_update),a($0015),$01, e($0aa00),a($0015),$01, a($0014),[blit_template_phys_update_end-blit_template_phys_update]/$15-1, $FF,$00,$00, $00,$00,$00

xdl:
        ;24 blank lines
        dta     $34,$00             ;repeat, attribute map off, overlay disable
        dta     $17                 ;repeat 23 times

        ;192 SR lines at $10000, palette 0
        dta     $62,$88             ;overlay address, repeat, graphics, end, overlay misc
        dta     $BF                 ;repeat 191 times
        dta     a(0),$01,a($100)    ;overlay @ $10000, stride $100
        dta     $00                 ;ANTIC palette 0, overlay palette 0, overlay narrow
        dta     $FF                 ;overlay priority over all

vbxe_rdata_end = *

;===============================================================================
        org     $0600

.proc vbi
        mva     #1 vbxe_base+vbxe_blitter_start
        jmp     $0000
vbi_vector = *-2
.endp


        run     main
