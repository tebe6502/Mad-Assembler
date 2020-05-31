/*
  Engine sterujacy klockami dla GETRIS'a
  v1.1 by TeBe/Madteam
  changes: 20.12.2004
*/

buf       equ $a000
width     equ 32

height    equ 128

znak      equ $ff

kloc      equ $80          ;(2)
kloc_tmp  equ kloc+2       ;(2)
klocek_nr equ kloc_tmp+2   ;(1)
pos_x     equ klocek_nr+1  ;(1)
pos_y     equ pos_x+1      ;(1)
old       equ pos_y+1      ;(1)

;---
 org $2456
;---

ant
 dta $4f,a(buf)
 :height-1 dta $f
 dta $41,a(ant)

main

.proc init
 lda #0
 sta pos_x
 sta faza+1
 sta pos_y
 
 jsr get_kloc
 
 ldx #height
loop1 lda #znak
 ldy #0
 sta (kloc),y
 ldy #width-1
 sta (kloc),y

 lda kloc
 clc
 adc #width
 sta kloc
 bcc _skp
 inc kloc+1
_skp
 dex
 bne loop1

 lda #height-1
 sta pos_y 
 jsr get_kloc
 
 lda #znak
 ldy #width-1
loop2 sta (kloc),y
 dey
 bpl loop2

 lda #width/2-2
 sta pos_x
 lda #0
 sta pos_y
 
 jsr get_kloc

 lda $d40b
 bne *-3

 sei
 lda #0
 sta $d40e
 lda #$fe
 sta $d301
 
 mwa #nmi $fffa
 
 lda #$40
 sta $d40e

 jsr losuj_klocek

.endp


/*
  LET'S GO
*/

loop
wait ldx #8
hh lda 20
 cmp 20
 beq *-2
 
 dex
 bne hh


faza lda #0
 beq cont
 
 lda delay
 sta wait+1

 lda #width/2-2
 sta pos_x
 lda #0
 sta pos_y
 sta faza+1
 sta w_dol+1
 sta read_joy
 sta r_d300+1

 jsr losuj_klocek

 jsr get_kloc
 
 jsr test_posY
 bne stop               ; brak mozliwosci ruchu GAME OVER

cont
 ldx #" "
 jsr put_klocek

;--- w dol do konca
w_dol lda #0
 beq _skip2

 jsr test_posY
 sta faza+1
 bne _skip
 jsr test_posY
 sta faza+1
 bne _skip
 jsr test_posY
 sta faza+1
 bne _skip
 jsr test_posY
 sta faza+1
 jmp _skip

_skip2

;--- zmiana pozycji Y klocka
 jsr test_posY
 sta faza+1
 bne _skip
  
;--- zmiana fazy klocka
r_d010 lda #0
 bne _skip_trig

 jsr test_faza
 lda #$ff
 sta r_d010+1

_skip_trig

;--- zmiana pozycji X klocka
r_d300 lda #0
 cmp #7
 bne _nxt1
 
 ldx #1
 jsr test_posX
 jmp _end_joy

_nxt1
 cmp #11
 bne _nxt2

 ldx #$ff
 jsr test_posX
 jmp _end_joy

_nxt2
 cmp #13
 bne _skip

 sta w_dol+1
 lda #1
 sta wait+1
 jmp _skip

_end_joy
 lda #0
 sta read_joy
 sta r_d300+1

_skip
 ldx #znak
 jsr put_klocek
 
 jmp loop


stop lda $d20a
 sta $d01a
 jmp stop

/*
  Sprawdz mozliwosc zmiany fazy klocka
*/
.proc test_faza

 ldx klocek_nr
 stx old
 
 inx
 txa
 and #3
 ora maska
 sta klocek_nr

 tay
 lda l_test,y
 sta jump+1
 lda h_test,y
 sta jump+2

 lda #0
jump jsr $ffff
 beq ok
 
 lda old
 sta klocek_nr
 
 lda #$ff
 rts

ok rts
.endp


/*
  Sprawdz mozliwosc zmiany pozycji X klocka
*/
.proc test_posX

 lda pos_x
 sta old

 txa
 clc
 adc pos_x
 sta pos_x
 
 jsr get_kloc
 
 ldy klocek_nr
 lda l_test,y
 sta jump+1
 lda h_test,y
 sta jump+2

 lda #0
jump jsr $ffff
 beq ok
 
 lda old
 sta pos_x
 
 jsr get_kloc
 rts

ok rts
.endp


/*
  Sprawdz mozliwosc zmiany pozycji Y klocka
*/
.proc test_posY

 inc pos_y
 
 jsr get_kloc
 
 ldy klocek_nr
 lda l_test,y
 sta jump+1
 lda h_test,y
 sta jump+2

 lda #0
jump jsr $ffff
 beq ok
 
 dec pos_y  
 jsr get_kloc
 
 lda #$ff
 rts

ok rts
.endp


/*
  Skok do odpowiedniej procedury klocka
*/
.proc put_klocek
 ldy klocek_nr
 lda l_klocek,y
 sta jump+1
 lda h_klocek,y
 sta jump+2
 
 txa
jump jmp $ffff
.endp


/*
  Procedury dla konkretnej fazy klocka
*/

.macro sta_kloc
 tax
 
.if :1=0
 mwa kloc kloc_tmp

.elseif :1=1 
 mwa kloc kloc_tmp
 inw kloc_tmp

.else
 lda kloc
 clc
 adc <:1
 sta kloc_tmp
 lda kloc+1
 adc >:1
 sta kloc_tmp+1

.endif
 
 txa
 
 ldy #0
 sta (kloc_tmp),y
 ldy #width
 sta (kloc_tmp),y
 ldy #width*2
 sta (kloc_tmp),y
 ldy #width*3
 sta (kloc_tmp),y
 ldy #width*4
 sta (kloc_tmp),y
 ldy #width*5
 sta (kloc_tmp),y
 ldy #width*6
 sta (kloc_tmp),y
 ldy #width*7
 sta (kloc_tmp),y
.endm


.macro lda_kloc
 tax
 
.if :1=0
 mwa kloc kloc_tmp

.elseif :1=1 
 mwa kloc kloc_tmp
 inw kloc_tmp

.else
 lda kloc
 clc
 adc <:1
 sta kloc_tmp
 lda kloc+1
 adc >:1
 sta kloc_tmp+1

.endif
 
 ldy #0
 txa

 ora (kloc_tmp),y
 ldy #width
 ora (kloc_tmp),y
 ldy #width*2
 ora (kloc_tmp),y
 ldy #width*3
 ora (kloc_tmp),y
 ldy #width*4
 ora (kloc_tmp),y
 ldy #width*5
 ora (kloc_tmp),y
 ldy #width*6
 ora (kloc_tmp),y
 ldy #width*7
 ora (kloc_tmp),y
.endm


* KLOCEK 1 (2 fazy)
; ' * '
; ' * '
; ' * '
.proc klocek1_0
 sta_kloc 1
 sta_kloc 1+width*8
 sta_kloc 1+width*2*8
 rts

test
 lda_kloc 1
 lda_kloc 1+width*8
 lda_kloc 1+width*2*8
 rts 
.endp


; '   '
; '***'
; '   '
.proc klocek1_1
 sta_kloc width*8
 sta_kloc 1+width*8
 sta_kloc 2+width*8
 rts

test
 lda_kloc width*8
 lda_kloc 1+width*8
 lda_kloc 2+width*8
 rts
.endp


* KLOCEK 2 (4 fazy)
; ' * '
; ' * '
; ' **'
.proc klocek2_0
 sta_kloc 1
 sta_kloc 1+width*8
 sta_kloc 1+width*2*8
 sta_kloc 2+width*2*8
 rts

test
 lda_kloc 1
 lda_kloc 1+width*8
 lda_kloc 1+width*2*8
 lda_kloc 2+width*2*8
 rts
.endp


; '   '
; '***'
; '*  '
.proc klocek2_1
 sta_kloc width*8
 sta_kloc 1+width*8
 sta_kloc 2+width*8
 sta_kloc width*2*8
 rts

test
 lda_kloc width*8
 lda_kloc 1+width*8
 lda_kloc 2+width*8
 lda_kloc width*2*8
 rts
.endp


; '** '
; ' * '
; ' * '
.proc klocek2_2
 sta_kloc 0
 sta_kloc 1
 sta_kloc 1+width*8
 sta_kloc 1+width*2*8
 rts

test
 lda_kloc 0
 lda_kloc 1
 lda_kloc 1+width*8
 lda_kloc 1+width*2*8
 rts
.endp


; '  *'
; '***'
; '   '
.proc klocek2_3
 sta_kloc 2
 sta_kloc width*8
 sta_kloc 1+width*8
 sta_kloc 2+width*8
 rts

test
 lda_kloc 2
 lda_kloc width*8
 lda_kloc 1+width*8
 lda_kloc 2+width*8
 rts
.endp


* KLOCEK 3 (1 faza)
; '   '
; ' **'
; ' **'
.proc klocek3_0
 sta_kloc 1+width*8
 sta_kloc 2+width*8
 sta_kloc 1+width*2*8
 sta_kloc 2+width*2*8
 rts

test
 lda_kloc 1+width*8
 lda_kloc 2+width*8
 lda_kloc 1+width*2*8
 lda_kloc 2+width*2*8
 rts
.endp


* KLOCEK 4 (2 fazy)
; '   '
; ' **'
; '** '
.proc klocek4_0
 sta_kloc 1+width*8
 sta_kloc 2+width*8
 sta_kloc width*2*8
 sta_kloc 1+width*2*8
 rts

test
 lda_kloc 1+width*8
 lda_kloc 2+width*8
 lda_kloc width*2*8
 lda_kloc 1+width*2*8
 rts
.endp


; '*  '
; '** '
; ' * '
.proc klocek4_1
 sta_kloc 0
 sta_kloc width*8
 sta_kloc 1+width*8
 sta_kloc 1+width*2*8
 rts

test
 lda_kloc 0
 lda_kloc width*8
 lda_kloc 1+width*8
 lda_kloc 1+width*2*8
 rts
.endp


* KLOCEK 5 (2 fazy)
; '   '
; '** '
; ' **'
.proc klocek5_0
 sta_kloc width*8
 sta_kloc 1+width*8
 sta_kloc 1+width*2*8
 sta_kloc 2+width*2*8
 rts

test
 lda_kloc width*8
 lda_kloc 1+width*8
 lda_kloc 1+width*2*8
 lda_kloc 2+width*2*8
 rts
.endp


; ' * '
; '** '
; '*  '
.proc klocek5_1
 sta_kloc 1
 sta_kloc width*8
 sta_kloc 1+width*8
 sta_kloc width*2*8
 rts

test
 lda_kloc 1
 lda_kloc width*8
 lda_kloc 1+width*8
 lda_kloc width*2*8
 rts
.endp


* KLOCEK 6 (1 faza)
; ' * '
; '***'
; ' * '
.proc klocek6_0
 sta_kloc 1
 sta_kloc width*8
 sta_kloc 1+width*8
 sta_kloc 2+width*8
 sta_kloc 1+width*2*8
 rts

test
 lda_kloc 1
 lda_kloc width*8
 lda_kloc 1+width*8
 lda_kloc 2+width*8
 lda_kloc 1+width*2*8
 rts
.endp


* KLOCEK 7 (4 fazy)
; '   '
; '***'
; ' * '
.proc klocek7_0
 sta_kloc width*8
 sta_kloc 1+width*8
 sta_kloc 2+width*8
 sta_kloc 1+width*2*8
 rts

test
 lda_kloc width*8
 lda_kloc 1+width*8
 lda_kloc 2+width*8
 lda_kloc 1+width*2*8
 rts
.endp


; ' * '
; '** '
; ' * '
.proc klocek7_1
 sta_kloc 1
 sta_kloc width*8
 sta_kloc 1+width*8
 sta_kloc 1+width*2*8
 rts

test
 lda_kloc 1
 lda_kloc width*8
 lda_kloc 1+width*8
 lda_kloc 1+width*2*8
 rts
.endp


; ' * '
; '***'
; '   '
.proc klocek7_2
 sta_kloc 1
 sta_kloc width*8
 sta_kloc 1+width*8
 sta_kloc 2+width*8
 rts

test
 lda_kloc 1
 lda_kloc width*8
 lda_kloc 1+width*8
 lda_kloc 2+width*8
 rts
.endp


; ' * '
; ' **'
; ' * '
.proc klocek7_3
 sta_kloc 1
 sta_kloc 1+width*8
 sta_kloc 2+width*8
 sta_kloc 1+width*2*8
 rts

test
 lda_kloc 1
 lda_kloc 1+width*8
 lda_kloc 2+width*8
 lda_kloc 1+width*2*8
 rts
.endp


* KLOCEK 8 (4 fazy)
; '  *'
; '  *'
; '***'
.proc klocek8_0
 sta_kloc 2
 sta_kloc 2+width*8
 sta_kloc width*2*8
 sta_kloc 1+width*2*8
 sta_kloc 2+width*2*8
 rts

test
 lda_kloc 2
 lda_kloc 2+width*8
 lda_kloc width*2*8
 lda_kloc 1+width*2*8
 lda_kloc 2+width*2*8
 rts
.endp


; '*  '
; '*  '
; '***'
.proc klocek8_1
 sta_kloc 0
 sta_kloc width*8
 sta_kloc width*2*8
 sta_kloc 1+width*2*8
 sta_kloc 2+width*2*8
 rts

test
 lda_kloc 0
 lda_kloc width*8
 lda_kloc width*2*8
 lda_kloc 1+width*2*8
 lda_kloc 2+width*2*8
 rts
.endp


; '***'
; '*  '
; '*  '
.proc klocek8_2
 sta_kloc 0
 sta_kloc 1
 sta_kloc 2
 sta_kloc width*8
 sta_kloc width*2*8
 rts

test
 lda_kloc 0
 lda_kloc 1
 lda_kloc 2
 lda_kloc width*8
 lda_kloc width*2*8
 rts
.endp


; '***'
; '  *'
; '  *'
.proc klocek8_3
 sta_kloc 0
 sta_kloc 1
 sta_kloc 2
 sta_kloc 2+width*8
 sta_kloc 2+width*2*8
 rts

test
 lda_kloc 0
 lda_kloc 1
 lda_kloc 2
 lda_kloc 2+width*8
 lda_kloc 2+width*2*8
 rts
.endp


* KLOCEK 9 (4 fazy)
; '** '
; '** '
; '*  '
.proc klocek9_0
 sta_kloc 0
 sta_kloc 1
 sta_kloc width*8
 sta_kloc 1+width*8
 sta_kloc width*2*8
 rts

test
 lda_kloc 0
 lda_kloc 1
 lda_kloc width*8
 lda_kloc 1+width*8
 lda_kloc width*2*8
 rts
.endp


; '***'
; ' **'
; '   '
.proc klocek9_1
 sta_kloc 0
 sta_kloc 1
 sta_kloc 2
 sta_kloc 1+width*8
 sta_kloc 2+width*8
 rts

test
 lda_kloc 0
 lda_kloc 1
 lda_kloc 2
 lda_kloc 1+width*8
 lda_kloc 2+width*8
 rts
.endp


; '  *'
; ' **'
; ' **'
.proc klocek9_2
 sta_kloc 2
 sta_kloc 1+width*8
 sta_kloc 2+width*8
 sta_kloc 1+width*2*8
 sta_kloc 2+width*2*8
 rts

test
 lda_kloc 2
 lda_kloc 1+width*8
 lda_kloc 2+width*8
 lda_kloc 1+width*2*8
 lda_kloc 2+width*2*8
 rts
.endp


; '   '
; '** '
; '***'
.proc klocek9_3
 sta_kloc width*8
 sta_kloc 1+width*8
 sta_kloc width*2*8
 sta_kloc 1+width*2*8
 sta_kloc 2+width*2*8
 rts

test
 lda_kloc width*8
 lda_kloc 1+width*8
 lda_kloc width*2*8
 lda_kloc 1+width*2*8
 lda_kloc 2+width*2*8
 rts
.endp


/*
  ustawia adres 'kloc' wg aktualnej pozycji X,Y klocka
*/
.proc get_kloc

 ldy pos_y

 clc
 lda l_buf,y
 adc pos_x
 sta kloc
 lda h_buf,y
 adc #0
 sta kloc+1
 rts
.endp


/*
  losujemy wartosc z przedzialu <0..8>
*/
.proc losuj_klocek
 lda $d20a
 and #%00011100
 :2 lsr @
 sta _add+1
 
 lda $d20a
 and #%00001000
 :3 lsr @
 clc
_add adc #0

 :2 asl @
 sta klocek_nr
 and #%11111100
 sta maska
 rts
.endp


/*
  NMI
*/
.proc nmi

 bit $d40f
 bpl vbl


vbl
 sta regA+1
 
 sta $d40f
 
 inc 20
 
 mwa #ant $d402
 lda #%00100001
 sta $d400

 lda #10
 sta $d017
 lda #$94
 sta $d018

 lda read_joy
 bne _skip
 
 lda $d300
 and #$f
 cmp #7
 beq ok
 cmp #11
 beq ok
 cmp #13
 beq ok
 jmp _skip
 
ok
 cmp old_joy
 bne new_joy
 
 dec delay_joy
 bne _skip
 
new_joy
 sta r_d300+1
 sta old_joy
 lda #$ff
 sta read_joy
 lda #4
 sta delay_joy
 
_skip
 lda $d010
 bne nmiQ

 dec delay_trig
 bne regA

 sta r_d010+1

 lda #8
 sta delay_trig
 jmp regA

nmiQ lda #1
 sta delay_trig

regA lda #0
 rti

.endp


/*
 adresy procedur dla klockow
*/
l_klocek
 dta l(klocek1_0,klocek1_1,klocek1_0,klocek1_1)
 dta l(klocek2_0,klocek2_1,klocek2_2,klocek2_3)
 dta l(klocek3_0,klocek3_0,klocek3_0,klocek3_0)
 dta l(klocek4_0,klocek4_1,klocek4_0,klocek4_1)
 dta l(klocek5_0,klocek5_1,klocek5_0,klocek5_1)
 dta l(klocek6_0,klocek6_0,klocek6_0,klocek6_0)
 dta l(klocek7_0,klocek7_1,klocek7_2,klocek7_3)
 dta l(klocek8_0,klocek8_1,klocek8_2,klocek8_3)
 dta l(klocek9_0,klocek9_1,klocek9_2,klocek9_3)

h_klocek
 dta h(klocek1_0,klocek1_1,klocek1_0,klocek1_1)
 dta h(klocek2_0,klocek2_1,klocek2_2,klocek2_3)
 dta h(klocek3_0,klocek3_0,klocek3_0,klocek3_0)
 dta h(klocek4_0,klocek4_1,klocek4_0,klocek4_1)
 dta h(klocek5_0,klocek5_1,klocek5_0,klocek5_1)
 dta h(klocek6_0,klocek6_0,klocek6_0,klocek6_0)
 dta h(klocek7_0,klocek7_1,klocek7_2,klocek7_3)
 dta h(klocek8_0,klocek8_1,klocek8_2,klocek8_3)
 dta h(klocek9_0,klocek9_1,klocek9_2,klocek9_3)

l_test
 dta l(klocek1_0.test,klocek1_1.test,klocek1_0.test,klocek1_1.test)
 dta l(klocek2_0.test,klocek2_1.test,klocek2_2.test,klocek2_3.test)
 dta l(klocek3_0.test,klocek3_0.test,klocek3_0.test,klocek3_0.test)
 dta l(klocek4_0.test,klocek4_1.test,klocek4_0.test,klocek4_1.test)
 dta l(klocek5_0.test,klocek5_1.test,klocek5_0.test,klocek5_1.test)
 dta l(klocek6_0.test,klocek6_0.test,klocek6_0.test,klocek6_0.test)
 dta l(klocek7_0.test,klocek7_1.test,klocek7_2.test,klocek7_3.test)
 dta l(klocek8_0.test,klocek8_1.test,klocek8_2.test,klocek8_3.test)
 dta l(klocek9_0.test,klocek9_1.test,klocek9_2.test,klocek9_3.test)

h_test
 dta h(klocek1_0.test,klocek1_1.test,klocek1_0.test,klocek1_1.test)
 dta h(klocek2_0.test,klocek2_1.test,klocek2_2.test,klocek2_3.test)
 dta h(klocek3_0.test,klocek3_0.test,klocek3_0.test,klocek3_0.test)
 dta h(klocek4_0.test,klocek4_1.test,klocek4_0.test,klocek4_1.test)
 dta h(klocek5_0.test,klocek5_1.test,klocek5_0.test,klocek5_1.test)
 dta h(klocek6_0.test,klocek6_0.test,klocek6_0.test,klocek6_0.test)
 dta h(klocek7_0.test,klocek7_1.test,klocek7_2.test,klocek7_3.test)
 dta h(klocek8_0.test,klocek8_1.test,klocek8_2.test,klocek8_3.test)
 dta h(klocek9_0.test,klocek9_1.test,klocek9_2.test,klocek9_3.test)


l_buf	:height+1 dta l(buf+#*width)
h_buf	:height+1 dta h(buf+#*width)

maska      brk
read_joy   brk
delay      dta 8
delay_trig dta 8
delay_joy  dta 4
old_joy    brk

;---
 run main
;---
