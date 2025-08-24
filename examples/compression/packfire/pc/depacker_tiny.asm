; ------------------------------------------
; PackFire 1.2k - (tiny depacker)
; ------------------------------------------

; ------------------------------------------
; packed data in a0
; dest in a1
start:                  lea     26(a0),a2
                        move.b  (a2)+,d7
lit_copy:               move.b  (a2)+,(a1)+
main_loop:              bsr.b   get_bit
                        bcs.b   lit_copy
                        moveq   #-1,d3
get_index:              addq.l  #1,d3
                        bsr.b   get_bit
                        bcc.b   get_index
                        cmp.w   #$10,d3
                        beq.b   depack_stop
                        bsr.b   get_pair
                        move.w  d3,d6                                   ; save it for the copy
                        cmp.w   #2,d3
                        ble.b   out_of_range
                        moveq   #0,d3
out_of_range:           moveq   #0,d0
                        move.b  table_len(pc,d3.w),d1
                        move.b  table_dist(pc,d3.w),d0
                        bsr.b   get_bits
                        bsr.b   get_pair
                        move.l  a1,a3
                        sub.l   d3,a3
copy_bytes:             move.b  (a3)+,(a1)+
                        subq.w  #1,d6
                        bne.b   copy_bytes
                        bra.b   main_loop
table_len:              dc.b    $04,$02,$04
table_dist:             dc.b    $10,$30,$20
get_pair:               sub.l   a6,a6
                        moveq   #$f,d2
calc_len_dist:          move.w  a6,d0
                        and.w   d2,d0
                        bne.b   node
                        moveq   #1,d5
node:                   move.w  a6,d4
                        lsr.w   #1,d4
                        move.b  (a0,d4.w),d1
                        moveq   #1,d4
                        and.w   d4,d0
                        beq.b   nibble
                        lsr.b   #4,d1
nibble:                 move.w  d5,d0
                        and.w   d2,d1
                        lsl.l   d1,d4
                        add.l   d4,d5
                        addq.w  #1,a6
                        dbf     d3,calc_len_dist
get_bits:               moveq   #0,d3
getting_bits:           subq.b  #1,d1
                        bhs.b   cont_get_bit
                        add.w   d0,d3
depack_stop:            rts
cont_get_bit:           bsr.b   get_bit
                        addx.l  d3,d3
                        bra.b   getting_bits
get_bit:                add.b   d7,d7
                        bne.b   byte_done
                        move.b  (a2)+,d7
                        addx.b  d7,d7
byte_done:              rts
