
/************************************************************************************************************************

  "Engine #4" for program sprites on graphics v1.3 by TeBe/Madteam

  In comparison to ENGINE #3, it uses faster method to check collisions it checks out distances
  from the middle of sprites. This method always takes the same CPU time regardless of sprite size.

  But keep in mind you should suitably calibrate "sensitivity" of the collisions' test ("PRG_DUCHY"
  procedure)

  The fastest version (without AND-ing mask similar to "ATARI MARIO BROS" ingame) works in two steps:

  1. giving back old screen data (based on "background buffer")
  2. putting sprite on the new position X,Y

  There are used 3 buffers: two screen buffers and one "background buffer")

  "Background buffer" enables to restore default contents for screen buffers

  Sprites are grouped on 4 frames, every 1 pixel on right.

  Sprites are defined by:
  - X,Y coordinates of left upper sprite's corner
  - sprite identification (e.g. based on this, you can check whether the sprite is "deadly" for other ones or not)
  - visibility indicator
  - collisions (with other sprite) indicator
  - table with animation frames of sprite
  - program for using sprite (you can set there X,Y position of sprite, reaction on collisions, etc.)

  ini_duch  : sprite init
  restore   : restores old screen's look for sprites
  put_duchy : puts sprite on screen
  prg_duchy : call program for using sprites and checks out collisions

*************************************************************************************************************************

  "Engine #4" dla spritow programowych na grafice v1.3 by Tebe/Madteam
  
  W porownaniu do "Engine #3" uzywa szybszej metody sprawdzania kolizji, sprawdza odleglosci od srodka duchow.
  Metoda ta niezaleznie od wielkosci ducha zajmuje zawsze tyle samo czasu CPU, nalezy tylko odpowiednio
  wykalibrowac "czulosc" testu kolizji (procedura PRG_DUCHY).

  Wersja najszybsza (bez maski andowania podobnie jak "Mario Bros"), dziala w dwoch krokach:
  1. oddanie starej zawartosci ekranu na podstawie "bufora tla"
  2. postawienie ducha na nowej pozycji X,Y
 
  Uzyte sa 3 bufory, 2 bufory ekranu i 1 "bufor tla".
  "Bufor tla" umozliwia przywrocenie domyslnej zawartosci buforom ekranow.
  
  Duchy rozpisane sa na 4 klatki, co 1 piksel w prawo.


  Duchy okreslaja:
  - wspolrzedne X,Y lewego gornego naroznika sprita
  - identyfikator ducha (np. na jego podstawie mozna okreslic czy duch jest smiertelny dla innych duchow)
  - wskaznik widzialnosci
  - wskaznik kolizji z innym duchem
  - tablica z fazami animacji ducha
  - program obslugi ducha (tam ustalamy pozycje X,Y ducha, reakcje na kolizje itp)
  
  ostatnie zmiany: 31.08.2005
************************************************************************************************************************/


// constans value definitions
max_sprites     equ 18                  ; maksymalna liczba duchow (max=31)
duch_h          equ 24                  ; wysokosc ducha (max=42)
duch_w          equ 4                   ; szerokosc ducha wyrazona w bajtach + 1 (tutaj szerokosc to 12 pixli)

duch_size       equ duch_h*duch_w       ; liczba bajtow przypadajaca na 1 klatke ducha

scr_width       equ 32                  ; szerokosc ekranu


// zero page definitions
tmp             equ $f0         ; 2
buf             equ tmp+2       ; 2
licz            equ buf+2       ; 1
screen          equ licz+1      ; 1
temp            equ screen+1    ; 1


// adres powrotu do PRG_DUCHY
return          equ prg_duchy.ret


.if max_sprites>31
 .error 'Za duzo duchow'
.endif

.if duch_h>42                           ; 256/rest_len = 256/6 = 42
 .error 'Za duza wysokosc ducha'
.endif


// tablica (? and 3)*2
t_and3mul2 :64 dta 0,2,4,6


// tablica szerokosci ducha (w bajtach) na podstawie pozycji X
// taka mala optymalizacja, jesli X=0 to przepisuj o 1 bajt mniej, jesli X<>0 to przepisuj wszystkie
t_and3w :64 dta duch_w-2 , duch_w-1 , duch_w-1 , duch_w-1


// tablica dzielenia przez 4
t_div4	:256 dta #/4


; SAVE
// mlodszy i starszy bajt adresu dla SAVE_BUF1
l_sbuf1	:scr_h dta l(save_buf1+#*save_len)

h_sbuf1	:scr_h dta h(save_buf1+#*save_len)


// mlodszy i starszy bajt adresu dla SAVE_BUF2
l_sbuf2	:scr_h dta l(save_buf2+#*save_len)

h_sbuf2	:scr_h dta h(save_buf2+#*save_len)


; RESTORE
// mlodszy i starszy bajt adresu dla REST_BUF1
l_rbuf1	:scr_h dta l(rest_buf1+#*rest_len)

h_rbuf1	:scr_h dta h(rest_buf1+#*rest_len)


// mlodszy i starszy bajt adresu dla REST_BUF2
l_rbuf2	:scr_h dta l(rest_buf2+#*rest_len)

h_rbuf2	:scr_h dta h(rest_buf2+#*rest_len)


// tablica mnozen *8
t_mul8	:31 dta #*8


// tablice przechowujace informacje o duchach
.local duch 
visible :max_sprites .byte           ; wskazniki widzialnosci (obecnosci) ducha   

lfaz    :max_sprites .byte           ; liczniki faz animacji ducha   

hit     :max_sprites .byte           ; wskazniki kolizji ducha z innymi duchami
hit_idx :max_sprites .byte           ; ideks do ducha z ktorym nastapila kolizja

pos_x   :max_sprites .byte           ; aktualne wspolrzedne (X,Y) ducha   
pos_y   :max_sprites .byte

id      :max_sprites .byte           ; identyfikator ducha

szer_b1 :max_sprites .byte           ; szerokosc ducha dla EKRANU #1
szer_b2 :max_sprites .byte           ; szerokosc ducha dla EKRANU #2

l_afaz  :max_sprites .byte           ; adres faz animacji ducha
h_afaz  :max_sprites .byte

l_aprg  :max_sprites .byte           ; adres programu obslugi ducha
h_aprg  :max_sprites .byte

old_xb1 :max_sprites .byte           ; stare wspolrzedne (X,Y) ducha dla EKRANU #1
old_yb1 :max_sprites .byte
old_xb2 :max_sprites .byte           ; stare wspolrzedne (X,Y) ducha dla EKRANU #2
old_yb2 :max_sprites .byte
.endl


/*********************************************************************************************************
  ini_duch  : inicjalizacja ducha
  restore   : zwraca stary wyglad grafiki ekranu dla duchow
  put_duchy : umieszcza na ekranie ducha
  prg_duchy : wywoluje programy obslugi duchow oraz sprawdza kolizje
*********************************************************************************************************/


/*
  Name: INI_DUCH

  In:
      regA <adres_ducha
      regX >adres_ducha

  Out: 
      regA - indeks do tablicy DUCHY

  Info:
       Inicjujemy dane pierwszego wolnego ducha
*/
.proc ini_duch
 sta buf                        ; adres tablicy parametrow zapisujemy w BUF
 stx buf+1

 ldx #max_sprites-1             ; licznik dodanych spritow

lp
 lda duch.visible,x             ; pomijamy widoczne duchy (visible=1)
 bne skp

 ldy #@duch.pos_x
 lda (buf),y
 sta duch.pos_x,x

 ldy #@duch.pos_y
 lda (buf),y
 sta duch.pos_y,x

add

 lda #0
 sta duch.lfaz,x                ; zerujemy licznik faz
 sta duch.hit,x                 ; zerujemy znacznik trafienia ducha

 lda #$80                       ; duch staje sie widoczny (wartosc <> 0)
 sta duch.visible,x

 ldy #@duch.a_faz
 lda (buf),y
 sta duch.l_afaz,x
 iny
 lda (buf),y
 sta duch.h_afaz,x

 ldy #@duch.a_prg
 lda (buf),y
 sta duch.l_aprg,x
 iny
 lda (buf),y
 sta duch.h_aprg,x

 ldy #@duch.id
 lda (buf),y
 sta duch.id,x

 rts                            ; w regX indeks do tablicy DUCHY, pod ktorym zostaly zapisane dane nowego ducha
                                ; koniec modyfikacji danych ducha
skp
 dex
 bpl lp
 rts                            ; koniec szukania wolnego ducha

.endp


/*
  Name: PUT_DUCHY

  Info:
       Przenosi na ekran duchy (if visible=1)
*/
.proc put_duchy

 lda #max_sprites-1
 sta lp+1

lp ldx #0

 lda duch.visible,x
 bne _skp

 dec lp+1
 bpl lp
 rts

_skp
 lda duch.l_afaz,x      ; w BUF adres tablicy z adresami faz animacji
 sta buf
 lda duch.h_afaz,x
 sta buf+1


 ldy duch.pos_x,x       ; przesunienie wzgledem pozycji X
 lda t_and3mul2,y
 ldy duch.lfaz,x        ; ofset do tablicy faz animacji na podstawie licznika faz LFAZ
 ora t_mul8,y
 tay                    ; sumujemy i mamy indeks do tablicy adresow faz animacji

 iny
 lda (buf),y            ; jesli starszy bajt fazy animacji = 0 to zeruj licznik faz i pobierz pierwszy adres z tablicy faz
 bne ok

; lda #0
 sta duch.lfaz,x        ; zerujemy licznik faz (lfaz=0)

 ldy duch.pos_x,x
 lda t_and3mul2,y
 
 tay
 iny

ok

 lda (buf),y            ; obliczamy adres klatki animacji ducha uwzgledniajac OFSET
 sta tmp+1
 dey
 lda (buf),y
 sta tmp


 inc duch.lfaz,x        ; zwieksz o 1 licznik faz animacji ducha


 ldy duch.pos_y,x

 lda screen             ; na podstawie SCREEN ustal adres bufora ekranu
 beq e1

e2
 lda l_sbuf2,y          ; modyfikacja adresu skoku dla procedury kopiujacej EKRAN2
 sta _jsr+1
 clc
 adc <duch_h*save_len
 sta buf
 lda h_sbuf2,y
 sta _jsr+2
 adc >duch_h*save_len
 sta buf+1

 tya
 sta duch.old_yb2,x

 ldy duch.pos_x,x
 lda t_and3w,y
 sta licz
 sta duch.szer_b2,x
 
 lda t_div4,y
 sta duch.old_xb2,x

 jmp cnt

e1
 lda l_sbuf1,y                  ; modyfikacja adresu skoku do procedury kopiujacej EKRAN1
 sta _jsr+1
 clc
 adc <duch_h*save_len
 sta buf
 lda h_sbuf1,y
 sta _jsr+2
 adc >duch_h*save_len
 sta buf+1

 tya
 sta duch.old_yb1,x

 ldy duch.pos_x,x
 lda t_and3w,y
 sta licz
 sta duch.szer_b1,x

 lda t_div4,y
 sta duch.old_xb1,x

cnt
 tax

 lda #{rts}                     ; wstawienie rozkazu RTS
 ldy #0
 sta (buf),y

; lda #duch_w-1                  ; musimy zapisac 4 pionowe pasy o wysokosci DUCH_H bajtow
; sta licz                       ; lub 3 pionowe pasy jesli pozycje X zaczynamy od pixla zerowego
                                 ; zastapione przez DUCH.SZER_B1, DUCH.SZER_B2

; ldy #0                        ; Y=0
_jsr jsr $ffff

 inx
 dec licz
 bpl _jsr

 lda #{lda $ffff,x}             ; przywrocenie starej wartosci
 ldy #0
 sta (buf),y

skp
 dec lp+1
 bpl skok
 rts
 
skok jmp lp

.endp


save_len	equ 9           ; liczba bajtow na linie w SAVE_BUF1, SAVE_BUF2

// zapisuje ducha do BUF1 (linia co 9b)
.proc	save_buf1

	.print 'SAVE_BUF1: ',*

	.rept scr_h
	lda buf1+.r*scr_width,x
	ora (tmp),y
	sta buf1+.r*scr_width,x
	iny
	.endr

	lda $ffff,x

	rts

.endp


// zapisuje ducha do BUF2 (linia co 9b)
.proc	save_buf2

	.print 'SAVE_BUF2: ',*

	.rept scr_h
	lda buf2+.r*scr_width,x
	ora (tmp),y
	sta buf2+.r*scr_width,x
	iny
	.endr

	lda $ffff,x

	rts

.endp


/*
  Name: RESTORE

  Info:
       Zwracamy stara zawartosc grafiki ekranu zajmowana przez duchy
*/
.proc restore

 lda #max_sprites-1
 sta lp+1

lp ldx #0

 lda duch.visible,x
 beq skp

 lda screen
 beq e1

e2
 ldy duch.old_yb2,x

 lda l_rbuf2,y
 sta _jsr+1
 sta buf
 lda h_rbuf2,y
 sta _jsr+2
 sta buf+1

 lda #{rts}                     ; wstawienie rozkazu RTS
 ldy #duch_h*rest_len
 sta (buf),y

 ldy duch.szer_b2,x
 lda duch.old_xb2,x

 jmp cnt

e1
 ldy duch.old_yb1,x

 lda l_rbuf1,y
 sta _jsr+1
 sta buf
 lda h_rbuf1,y
 sta _jsr+2
 sta buf+1

 lda #{rts}                     ; wstawienie rozkazu RTS
 ldy #duch_h*rest_len
 sta (buf),y

 ldy duch.szer_b1,x
 lda duch.old_xb1,x

cnt
 tax

; ldy #duch_w-1                  ; musimy przywrocic 4 pionowe pasy o wysokosci DUCH_H bajtow
; sta licz

_jsr jsr $ffff

 inx
 dey
 bpl _jsr

 lda #{lda $ffff,x}             ; przywrocenie starej wartosci
 ldy #duch_h*rest_len
 sta (buf),y

skp
 dec lp+1
 bpl lp
 rts

.endp


rest_len	equ 6

// pocedura przywracania BUF1 na podstawie BUF0 (linia co 6b)
.proc	rest_buf1

	.print 'REST_BUF1: ',*

	:scr_h	mva buf0+#*scr_width,x	buf1+#*scr_width,x

	lda $ffff,x
	rts

.endp


// pocedura przywracania BUF2 na podstawie BUF0 (linia co 6b)
.proc	rest_buf2

	.print 'REST_BUF2: ',*

	:scr_h	mva	buf0+.r*scr_width,x	buf2+.r*scr_width,x

	lda $ffff,x

	rts

.endp


/*
  Name: PRG_DUCHY

  Info:
       Wywolujemy programy obslugi duchow
       
       w regX numer przetwarzanego ducha
*/
.proc prg_duchy

 lda #max_sprites-1
 sta lp+1

lp ldx #0

 lda duch.visible,x
 beq ret

 lda #0
 sta duch.hit,x                 ; reset kolizji

// testowanie kolizji z innymi duchami
 lda duch.pos_x,x
 clc
 adc #[(duch_w-1)*4]/2          ; obliczamy wspolrzedne srodka kwadratu
 sta kolizje.x1+1

 lda duch.pos_y,x
 adc #duch_h/2
 sta kolizje.y1+1

// porownaj pozycje X,Y z pozostalymi duchami w celu znalezienia kolizji
.local kolizje

 stx skp+1              ; pomin testowanie aktualnego ducha

 ldy #max_sprites-1

lp
 lda duch.visible,y     ; pomijamy niewidoczne duchy
 beq nxt

skp cpy #0              ; pomijamy ducha z ktorym aktualnie porownujemy, bo sami siebie nie mozemy porownywac
 beq nxt

// dx = abs(x2-x1)
        lda duch.pos_x,y        ; obliczamy X2
        sec
        adc #[(duch_w-1)*4]/2
x1      sbc #0
        bpl abs_00
        
        eor #$ff                ; zmiana znaku na przeciwny
        adc #1

abs_00  cmp #duch_w*2+2     ; kalibracja czulosci dla DX
        bcs nxt

// dy = abs(y2-y1)
        lda duch.pos_y,y        ; obliczamy Y2
        sec
        adc #duch_h/2
y1      sbc #0
        bpl abs_01
        
        eor #$ff                ; zmiana znaku na przeciwny
        adc #1
        
abs_01  cmp #duch_h-3       ; kalibracja czulosci dla DY
        bcc trafiony

nxt
        dey
        bpl lp

.endl

// rejestr X nie zostal zmodyfikowany, wiec nie trzeba go na nowo ladowac

; ldx lp+1                       ; przywracamy zawartosc rejestru X

cnt_
// skok do programu obslugi ducha
 lda duch.l_aprg,x
 sta _jmp+1
 lda duch.h_aprg,x
 sta _jmp+2

_jmp jmp $ffff

ret
 dec lp+1
 bpl lp
 rts

trafiony
// jest kolizja
; ldx lp+1                         ; koniecznie musimy przywrocic wartosc rejestru X

 lda duch.id,y
 sta duch.hit,x                   ; informacja, z ktorym duchem nastapila kolizja

 tya
 sta duch.hit_idx,x

 jmp cnt_                         ; koniec szukania kolizji, jedno trafienie wystarczy

.endp


/*
  Definicje nowych struktur danych
  
  @DUCH - dane opisujace ducha
*/
.struct	@duch
pos_x	.byte
pos_y	.byte

a_faz	.word           ; adres faz animacji ducha

a_prg	.word           ; adres programu obslugi ducha

id	.byte
.ends
