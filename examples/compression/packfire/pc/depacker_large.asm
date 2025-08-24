; ------------------------------------------
; PackFire 1.2k - (large depacker)
; ------------------------------------------

; ------------------------------------------
; Constants
KTOPVALUE               =       16777216
KBITMODELTOTAL          =       2048
KNUMMOVEBITS            =       5
KNUMPOSBITSMAX          =       4
KLENNUMLOWBITS          =       3
KLENNUMMIDBITS          =       3
KLENNUMLOWSYMBOLS       =       8
KLENNUMMIDSYMBOLS       =       8
KLENNUMHIGHBITS         =       8
LENCHOICE2              =       1
LENLOW                  =       2
LENMID                  =       130
LENHIGH                 =       258
KNUMLITSTATES           =       7
KSTARTPOSMODELINDEX     =       4
KENDPOSMODELINDEX       =       14
KNUMPOSSLOTBITS         =       6
KNUMLENTOPOSSTATES      =       4
KNUMALIGNBITS           =       4
KMATCHMINLEN            =       2
ISREP                   =       192
ISREPG0                 =       204
ISREPG1                 =       216
ISREPG2                 =       228
ISREP0LONG              =       240
POSSLOT                 =       432
SPECPOS                 =       688
ALIGN                   =       802
LENCODER                =       818
REPLENCODER             =       1332
LITERAL                 =       1846

; ------------------------------------------
; packed data in a0
; dest in a1
; probs buffer in a2 (must be 15980 bytes)
start:                  lea     var(pc),a5
                        movem.l (a0)+,d0/d5
                        move.l  d0,d2
                        lea     (a2),a6
                        lea     (a1),a3
clear_dest:             sf.b    (a3)+
                        subq.l  #1,d0
                        bge.b   clear_dest
                        move.w  #7990-1,d7
fill_probs:             move.w  #KBITMODELTOTAL>>1,(a2)+
                        dbf     d7,fill_probs
                        lea     (a1),a4
                        moveq   #0,d3
                        moveq   #0,d4
                        moveq   #0,d6
                        moveq   #-1,d7
                        move.l  d7,(a5)+
                        neg.l   d7
                        move.l  d7,(a5)+
                        move.l  d7,(a5)+
                        move.l  d7,(a5)
                        lea     -12(a5),a5
                        move.l  d6,a2
depack_loop:            move.l	d2,-(a7)
                        lea     (a6),a1
                        move.l  d4,d0
                        lsl.l   #KNUMPOSBITSMAX,d0
                        bsr.w   Check_Fix_Range2
                        bne.b   fix_range1
                        lea     (LITERAL*2)(a6),a3
                        moveq   #1,d3
                        cmp.w   #KNUMLITSTATES,d4
                        bmi.b   max_lit_state_2
                        move.l  a2,d0
                        sub.l   d7,d0
                        moveq   #0,d1
                        move.b  (a4,d0.l),d1
max_lit_loop1:          add.l   d1,d1
                        move.l  d1,d2
                        and.l   #$100,d2
                        move.l  d2,d0
                        add.w   #$100,d0
                        add.w   d0,d0
                        lea     (a3,d0.l),a1
                        bsr.w   Check_Code_Bound
                        bne.b   Check_Code_Bound_1
                        tst.l   d2
                        bne.b   max_lit_state_2
                        bra.b   No_Check_Code_Bound_1
Check_Code_Bound_1:     tst.l   d2
                        beq.b   max_lit_state_2
No_Check_Code_Bound_1:  cmp.w   #$100,d3
                        bmi.b   max_lit_loop1
max_lit_state_2:        cmp.w   #$100,d3
                        bhs.b   max_lit_state_exit
                        bsr.w   Check_Code_Bound2
                        bra.b   max_lit_state_2
table_state:            dc.b    0,0,0,0
                        dc.b    4-3,5-3,6-3,7-3,8-3,9-3
                        dc.b    10-6,11-6
max_lit_state_exit:     move.b  d3,d0
                        bsr.w   store_prev_byte2
                        move.b  table_state(pc,d4.w),d4
                        bra.w   cont
fix_range1:             lea     (ISREP*2)(a6),a1
                        bsr.w   Check_Fix_Range3
                        bne.b   Check_Fix_Range_2
                        move.l  rep2-var(a5),rep3-var(a5)
                        move.l  rep1-var(a5),rep2-var(a5)
                        move.l  d7,rep1-var(a5)
                        move.l  d4,d0
                        moveq   #0,d4
                        cmp.w   #KNUMLITSTATES,d0
                        bmi.b   change_state_3
                        moveq   #3,d4
change_state_3:         lea     (LENCODER*2)(a6),a1
                        bra.b   Check_Fix_Range_3
Check_Fix_Range_2:      lea     (ISREPG0*2)(a6),a1
                        bsr.w   Check_Fix_Range3
                        bne.b   Check_Fix_Range_4
                        lea     (ISREP0LONG*2)(a6),a1
                        move.l  d4,d0
                        lsl.l   #KNUMPOSBITSMAX,d0
                        bsr.w   Check_Fix_Range2
                        bne.b   Check_Fix_Range_5
                        move.l  d4,d0
                        moveq   #9,d4
                        cmp.w   #KNUMLITSTATES,d0
                        bmi.b   change_state_4
                        moveq   #11,d4
change_state_4:         bsr.w   store_prev_byte
                        bra.w   cont
Check_Fix_Range_4:      lea     (ISREPG1*2)(a6),a1
                        bsr.w   Check_Fix_Range3
                        bne.b   Check_Fix_Range_6b
                        move.l  rep1-var(a5),d1
                        bra.b   Check_Fix_Range_7
Check_Fix_Range_6b:     lea     (ISREPG2*2)(a6),a1
                        bsr.w   Check_Fix_Range3
                        bne.b   Check_Fix_Range_8
                        move.l  rep2-var(a5),d1
                        bra.b   Check_Fix_Range_9
Check_Fix_Range_8:      move.l  rep3-var(a5),d1
                        move.l  rep2-var(a5),rep3-var(a5)
Check_Fix_Range_9:      move.l  rep1-var(a5),rep2-var(a5)
Check_Fix_Range_7:      move.l  d7,rep1-var(a5)
                        move.l  d1,d7
Check_Fix_Range_5:      move.l  d4,d0
                        moveq   #8,d4
                        cmp.w   #KNUMLITSTATES,d0
                        bmi.b   change_state_5
                        moveq   #11,d4
change_state_5:         lea     (REPLENCODER*2)(a6),a1
Check_Fix_Range_3:      lea     (a1),a3
                        bsr.w   Check_Fix_Range
                        bne.b   Check_Fix_Range_10
                        lea     (LENLOW*2)+(KLENNUMLOWBITS*2)(a3),a3
                        moveq   #0,d3
                        moveq   #KLENNUMLOWBITS,d1
                        bra.b   Check_Fix_Range_11
Check_Fix_Range_10:     lea     (LENCHOICE2*2)(a3),a1
                        bsr.w   Check_Fix_Range
                        bne.b   Check_Fix_Range_12
                        lea     (LENMID*2)+(KLENNUMMIDBITS*2)(a3),a3
                        moveq   #KLENNUMLOWSYMBOLS,d3
                        moveq   #KLENNUMMIDBITS,d1
                        bra.b   Check_Fix_Range_11
Check_Fix_Range_12:     lea     (LENHIGH*2)(a3),a3
                        moveq   #KLENNUMLOWSYMBOLS+KLENNUMMIDSYMBOLS,d3
                        moveq   #KLENNUMHIGHBITS,d1
Check_Fix_Range_11:     move.l  d1,d2
                        moveq   #1,d6
Check_Code_Bound_Loop:  exg.l   d6,d3
                        bsr.w   Check_Code_Bound2
                        exg.l   d6,d3
                        subq.l  #1,d2
                        bne.b   Check_Code_Bound_Loop
                        moveq   #1,d0
                        lsl.l   d1,d0
                        sub.l   d0,d6
                        add.l   d3,d6
                        cmp.w   #4,d4
                        bhs.w   change_state_6
                        addq.w  #KNUMLITSTATES,d4
                        move.l  d6,d0
                        cmp.w   #KNUMLENTOPOSSTATES,d0
                        bmi.b   check_len
                        moveq   #KNUMLENTOPOSSTATES-1,d0
check_len:              lea     (POSSLOT*2)(a6),a3
                        lsl.l   #KNUMPOSSLOTBITS+1,d0
                        add.l   d0,a3
                        moveq   #KNUMPOSSLOTBITS,d2
                        moveq   #1,d3
Check_Code_Bound_Loop2: bsr.w   Check_Code_Bound2
                        subq.l  #1,d2
                        bne.b   Check_Code_Bound_Loop2
                        sub.w   #(1<<KNUMPOSSLOTBITS),d3
                        cmp.w   #KSTARTPOSMODELINDEX,d3
                        bmi.b   Check_PosSlot_1
                        move.l  d3,d1
                        lsr.l   #1,d1
                        subq.l  #1,d1
                        move.l  d3,d0
                        moveq   #1,d7
                        and.l   d7,d0
                        addq.l  #2,d0
                        move.l  d0,d7
                        cmp.w   #KENDPOSMODELINDEX,d3
                        bhs.b   Check_PosSlot_3
                        lsl.l   d1,d0
                        move.l  d0,d7
                        lea     (SPECPOS*2)(a6),a3
                        sub.l   d3,d0
                        subq.l  #1,d0
                        add.l   d0,d0
                        add.l   d0,a3
                        bra.b   Check_PosSlot_4
Check_PosSlot_3:        subq.l  #KNUMALIGNBITS,d1
Shift_Range_Loop:       move.l  (a5),d0
                        lsr.l   #1,d0
                        add.l   d7,d7
                        move.l  d0,(a5)
                        cmp.l   d5,d0
                        bhi.b   Check_Code
                        sub.l   d0,d5
                        addq.l  #1,d7
Check_Code:             bsr.b   Get_Code
                        subq.l  #1,d1
                        bne.b   Shift_Range_Loop
                        lea     (ALIGN*2)(a6),a3
                        lsl.l   #KNUMALIGNBITS,d7
                        moveq   #KNUMALIGNBITS,d1
Check_PosSlot_4:        moveq   #1,d2
                        moveq   #1,d3
Check_Code_Bound_Loop3: bsr.b   Check_Code_Bound2
                        beq.b   Check_Code_Bound_2
                        or.l    d2,d7
Check_Code_Bound_2:     add.l   d2,d2
                        subq.l  #1,d1
                        bne.b   Check_Code_Bound_Loop3
                        bra.b   Check_PosSlot_2
Check_PosSlot_1:        move.l  d3,d7
Check_PosSlot_2:        addq.l  #1,d7
change_state_6:         addq.l  #KMATCHMINLEN,d6
Copy_Rem_Bytes:         bsr.b   store_prev_byte
                        subq.l  #1,d6
                        bne.b   Copy_Rem_Bytes
cont:                   move.l  (a7)+,d2
                        cmp.l   d2,a2
                        bmi.w   depack_loop
                        rts
store_prev_byte:        move.l  a2,d0
                        sub.l   d7,d0
                        move.b  (a4,d0.l),d0
store_prev_byte2:       move.b  d0,(a4,a2.l)
                        addq.l  #1,a2
                        rts
Check_Fix_Range3:       move.l  d4,d0
Check_Fix_Range2:       add.l   d0,d0
                        add.l   d0,a1
Check_Fix_Range:        move.l  (a5),d0
                        lsr.l   #8,d0
                        lsr.l   #3,d0
                        move.l  d1,-(a7)
                        move.l  d0,d1
                        swap    d1
                        mulu.w  (a1),d0
                        mulu.w  (a1),d1
                        swap    d1
                        add.l   d1,d0
                        move.l  (a7)+,d1
                        cmp.l   d5,d0
                        bls.b   Range_Lower
                        move.l  d0,(a5)
                        move.w  #KBITMODELTOTAL,d0
                        sub.w   (a1),d0
                        lsr.w   #KNUMMOVEBITS,d0
                        add.w   d0,(a1)
Get_Code:               move.l  (a5),d0
                        cmp.l   #KTOPVALUE,d0
                        bhs.b   top_range
                        lsl.l   #8,d0
                        move.l  d0,(a5)
                        lsl.l   #8,d5
                        move.b  (a0)+,d5
top_range:              moveq   #0,d0
                        rts
Check_Code_Bound2:      lea     (a3),a1
Check_Code_Bound:       add.l   d3,d3
                        lea     (a1,d3.l),a1
                        bsr.b   Check_Fix_Range
                        beq.b   Lower_Bound
                        addq.l  #1,d3
Lower_Bound:            rts
Range_Lower:            sub.l   d0,(a5)
                        sub.l   d0,d5
                        move.w  (a1),d0
                        lsr.w   #KNUMMOVEBITS,d0
                        sub.w   d0,(a1)
                        bsr.b   Get_Code
                        moveq   #1,d0
                        rts
var:
range:                  dc.l    -1
rep3:                   dc.l    1
rep2:                   dc.l    1
rep1:                   dc.l    1
