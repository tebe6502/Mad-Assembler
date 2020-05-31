/*
  Przyklad dzialania silnika spritow programowych na grafice

  ostatnie zmiany: 31.08.2005
*/

scr_h	equ 168

buf0	equ $7000       ; glowny bufor z pamiecia ekranu (256 linii)
buf1	equ $9000       ; 1 bufor ekranu (256 linii)
buf2	equ $b000       ; 2 bufor ekranu (256 linii)

prg	equ $0600

timer	equ $14
rejA	equ $80

min_fps	equ 1           ; minimalna liczba klatek


//	"bufor tla"'
	org buf0
;	ins 'tlo.mic',0,scr_h*32


/*
	Software sprites engine
*/
_src	equ $4000

	org $d800 , _src      ; asembluj pod $d800, umieszczaj pod _SRC

_dst
	icl 'engine_sprites_#4.asm'

	.print 'Free: ',*,'..$FF00'


// przepiszemy pod ROM

	org $0600

.proc	ini_engine

	lda:cmp:req 20

	sei
	mva #0 $d400
	sta $d40e
	mva #$fe $d301

	ldx >[$ff00-$d800]
	ldy #0

cp0	lda _src,y
cp1	sta _dst,y
	iny
	bne cp0

	inc cp0+2
	inc cp1+2
	dex
	bne cp0


.local	init_buf
; kopiujemy BUF0 do BUF1 i BUF2 (8192b)

	ldx #32
	ldy #0
cp0	lda buf0,y
cp1	sta buf1,y
cp2	sta buf2,y
	iny
	bne cp0

	inc cp0+2
	inc cp1+2
	inc cp2+2

	dex
	bne cp0

.endl

	mva #$ff $d301
	mva #$40 $d40e
	cli

	rts
 
.endp

	ini ini_engine


// LETS' GO
	org prg

// ANTIC PROGRAM
ant
	dta d'pppp',$20
	dta b($4e)
ant_a0	dta a(buf1)
	:127 dta $e

	dta b($4e)
ant_a1	dta a(buf1+$1000)
	:20 dta $e
	dta $8e
	:18 dta $e


; :scr_h-128-1 dta $e

	dta $41,a(ant)
 
 
// MAIN PROGRAM
main

	init_nmi $14 , nmi , $c0 

/*
 mva #62 duch_new
 mva #33 duch_new+1
 ldy #@duch.id
 mva #1 duch_new,y
 @ini_duch duch_new

 mva #25 duch_new
 mva #33 duch_new+1     ;12 , 54
 ldy #@duch.id
 mva #2 duch_new,y 
 @ini_duch duch_new
*/


	.rept 8                ; startujemy z 12 duchami
	jsr losuj
	@ini_duch duch_new
	.endr


	jsr synchro
	jmp loop


losuj
	ldy $d20a
	lda drop_wyb_prg.t_posx,y
	sta duch_new                   ; losujemy nowa pozycje X
	lda $d20a
	and #$7f
	sta duch_new+1                 ; nowa pozycje Y
	rts


/*****************
     L O O P
*****************/
loop

// ekran 1
 lda #0
 sta screen
 sta timer              ; zeruj licznik ramek
 
 lda #$f
 sta $d01a

 lda >buf2              ; pokaz BUF2
 sta ant_a0+1
 lda >buf2+$1000
 sta ant_a1+1

 jsr restore            ; przywroc stara zawartosc BUF1

 jsr prg_duchy          ; wykonaj programy obslugi duchow

 jsr put_duchy          ; postaw duchy


 lda #0
 sta $d01a
 
 jsr synchro            ; czekaj
 
; lda timer
; sta $0100

 
// ekran 2
 ldy #1
 sty screen
 
 dey
 sty timer              ; zeruj licznik ramek

 lda #$f
 sta $d01a

 lda >buf1              ; pokaz BUF1
 sta ant_a0+1
 lda >buf1+$1000
 sta ant_a1+1

 jsr restore            ; przywroc stara zawartosc BUF2

 jsr prg_duchy          ; wykonaj programy obslugi duchow
 
 jsr put_duchy          ; postaw duchy


 lda #0
 sta $d01a
 
 jsr synchro            ; czekaj


 jmp loop



/*
  New NMI routine
*/
.proc nmi
 sta rejA

 bit $d40f
 bpl vbl

vdli jmp dli1

vbl
 inc timer

 mwa #ant $d402
 mva #%00100001 $d400
 
; mva #$00 $d01a
 mva #$78 $d016
 mva #$84 $d017
 mva #$8e $d018
 
 lda #$ff
 sta synchro.gate+1 

q
 lda rejA
 rti 

.endp


dli1
 sta $d40a

 lda #$74
 ;sta $d01a

 jmp nmi.q




/*
  Frame synchronization
*/
.proc	synchro

	lda #0
	sta gate+1
gate	lda #0
	beq gate

	lda timer
	cmp #min_fps         ; minimum 2 ramki opoznienia
	bcc synchro

	rts

.endp


/*
  Sprites graphics
*/

drop
	ins 'shape_create.dat'

drop_wyb0 equ drop+duch_size*4
drop_wyb1 equ drop_wyb0+duch_size*4
drop_wyb2 equ drop_wyb1+duch_size*4
drop_wyb3 equ drop_wyb2+duch_size*4
drop_wyb4 equ drop_wyb3+duch_size*4
drop_wyb5 equ drop_wyb4+duch_size*4
drop_wyb6 equ drop_wyb5+duch_size*4
drop_wyb7 equ drop_wyb6+duch_size*4
drop_wyb8 equ drop_wyb7+duch_size*4

puste
	org *+duch_size*4
	:duch_size*4 dta $ff


min_x	equ 24
max_x	equ 112


// program obslugi wybuchu ducha "drop"
.proc drop_wyb_prg

 lda duch.lfaz,x
 cmp #11-1              ; 11 faz minus 1, pomijamy faze koncowa o adresie "0"
 bne skp

 lda #0
 sta duch.visible,x     ; wylacz ducha wybuchu

skp
 jmp return

t_posx
 dta rnd(min_x,max_x,256)

.endp



// program obslugi ducha "drop"
.proc drop_prg

lp
 lda $d20a
 and #3
 tay

 lda duch.hit,x         ; test kolizji
 bne skp

 lda duch.pos_x,x
 cmp #4         ;min_x
 bcs _s0

 lda #4

_s0 
 
 cmp #max_x
 bcc _s1

 lda #max_x

_s1
 clc
 adc t_addx,y
 sta duch.pos_x,x

skp
 lda duch.pos_y,x
 adc t_addy,y

 cmp #scr_h-duch_h
 bcc exi

; lda screen
; beq qui

 mwa #duch_wybuch buf           ; nowy adres tablicy z parametrami ducha
 jsr ini_duch.add

 ldy $d20a
 lda drop_wyb_prg.t_posx,y
 sta duch_new                   ; losujemy nowa pozycje X
 lda #0
 sta duch_new+1

 @ini_duch duch_new             ; dodajemy nowego ducha na pozycji aktualnego

qui
 jmp return

exi
 sta duch.pos_y,x
 jmp return

t_addy dta 1,1,1,1
t_addx dta $fe,$fe,1,1

.endp



/*
.proc drop_prg

 lda duch.id,x
 cmp #1
 bne _2

 lda duch.hit,x
 beq skp

kk lda #$80
 sta $d01a
 jmp kk

skp
 jmp return


_2
 inc duch.pos_x,x
 
 jmp return

.endp
*/


// dane dla ducha
duch_new        dta @duch [0] ( 0 , 0 , drop_fazy , drop_prg , 1 )

duch_wybuch     dta @duch [0] ( 0 , 0 , drop_wyb_fazy , drop_wyb_prg , 2 )


drop_fazy
 @adres drop
 :8 brk

drop_wyb_fazy
 @adres drop_wyb0
 @adres drop_wyb1
 @adres drop_wyb2
 @adres drop_wyb3
 @adres drop_wyb4
 @adres drop_wyb5
 @adres drop_wyb6
 @adres drop_wyb7
 @adres drop_wyb8
 @adres puste
 :8 brk

;---

 .print 'End: ',*
 
 
 run  main

/*
  Macro definitions
*/
 opt l-
 icl 'init_nmi.mac'


.macro @ini_duch
 lda <:1
 ldx >:1
 jsr ini_duch
.endm


.macro @adres
 dta a ( :1 , :1+duch_size , :1+duch_size*2 , :1+duch_size*3 )
.endm
