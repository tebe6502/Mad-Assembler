/*

  Przyklad wykorzystania makr do przekazywania parametrów

  Kazda procedura umieszczana jest w osobnym banku, kazda ma osobny stos, który
  modyfikuje makro PROC
  
  Makro PROC po modyfikacji stosu wywoluje procedure przez JSR
  
*/
 
 org $2000
 
 proc PutChar,'a'-64    ; wywolanie makra PROC, jako parametr
 proc PutChar,'a'-64    ; nazwa procedury która bedzie wywolana przez JSR
 proc PutChar,'r'-64    ; oraz jeden argument (kod znaku INTERNAL)
 proc PutChar,'e'-64
 proc PutChar,'a'-64

 proc Kolor,$23         ; wywolanie innej procedurki zmieniajacej kolor tla

;---

 jmp *			; petla bez konca, aby zobaczyc efekt dzialania

;---

proc .macro             ; deklaracja makra PROC
 push [=:1],:2,:3,:4      ; wywolanie makra PUSH odkladajacego na stos argumenty
                        ; =:1 wylicza bank pamieci
 
 jsr :1                 ; skok do procedury (nazwa procedury w pierwszym parametrze)
 
 lmb #0                 ; Load Memory Bank, ustawia bank na wartosc 0
 .endm                  ; koniec makra PROC 

;---

push .macro             ; deklaracja makra PUSH

  lmb #:1               ; ustawia bank pamieci

 .if :2<=$FFFF          ; jesli przekazany argument jest mniejszy równy $FFFF to
  lda <:2               ; odloz go na stosie
  sta stack
  lda >:2
  sta stack+1
 .endif 

 .if :3<=$FFFF
  lda <:3
  sta stack+2
  lda >:3
  sta stack+3
 .endif 

 .if :4<=$FFFF
  lda <:4
  sta stack+4
  lda >:4
  sta stack+5
 .endif 
 
 .endm
 

* ------------ *            ; procedura KOLOR
*  PROC Kolor  *
* ------------ *
 lmb #1                     ; ustawienie numeru banku na 1
                            ; wszystkie deklaracje beda teraz nalezec do tego banku
stack org *+256             ; stos dla procedury KOLOR
color equ stack

Kolor                       ; kod procedury KOLOR
 lda color
 sta 712
 rts

 
* -------------- *          ; procedura PUTCHAR
*  PROC PutChar  *
* -------------- *
 lmb #2                     ; ustawienie numeru banku na 2
                            ; wszystkie deklaracje beda teraz nalezec do tego banku
stack org *+256             ; stos dla procedury PUTCHAR
char  equ stack

PutChar                     ; kod procedury PUTCHAR
 lda char
 sta $bc40
scr equ *-2

 inc scr
 rts
