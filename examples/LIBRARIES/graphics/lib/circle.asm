// CIRCLE (19.06.2006)


	// struktura dla zmiennych na stronie zerowej,
	// dzieki ktorej wymusimy relokowalnosc dla wiekszej liczby zmiennych

	.struct		zp

	mo		.byte
	og		.byte
	ou		.byte
	x		.byte
	y		.byte

	ks_plus_x	.byte
	ks_minus_x	.byte
	ks_plus_y	.byte
	ks_minus_y	.byte

	ws_plus_x	.byte
	ws_minus_x	.byte
	ws_plus_y	.byte
	ws_minus_y	.byte

	ks		.byte
	ws		.byte
	r		.byte

	.ends


zpage		ext	.byte
plot		ext	.proc (.byte x,y) .reg

	.public circle

	.reloc

/********************************************************************
  CIRCLE

  wywolanie procedury:

        CIRCLE #ks,#ws,#r
        CIRCLE ks,ws,r

  KS -> wspolrzedna pozioma srodka okregu KS
  WS -> wspolrzedna pionowa srodka okregu WS
  R  -> promien okregu R

********************************************************************/

.proc circle (.byte x , y , a) .reg

;{ ks - pozycja pozioma srodka okregu }
;{ ws - pozycja pionowa srodka okregu }
;{ r  - promien okregu }

;procedure Circle(ks, ws, r: byte);
;var x, y, mo, og, ou:byte;
;begin
	stx zpage+zp.ks
	sty zpage+zp.ws
	sta zpage+zp.r

;y := 0;
;x := r;
;mo := 0;

        ldy #0
        sty zpage+zp.mo
        tax

;while x >= y do begin

loop    stx zpage+zp.x
        sty zpage+zp.y

        txa
        cmp zpage+zp.y
        bcs cont

        rts

cont

;plot(ks+x, ws+y);

        clc
        adc zpage+zp.ks
        sta zpage+zp.ks_plus_x

	tax

        tya
        adc zpage+zp.ws
        sta zpage+zp.ws_plus_y

        plot , @	; zpage+zp.ks_plus_x , @

;plot(ks-x, ws+y);

        lda zpage+zp.ks
        sec
        sbc zpage+zp.x
        sta zpage+zp.ks_minus_x

        plot @		; , zpage+zp.ws_plus_y

;plot(ks+x, ws-y);

        lda zpage+zp.ws
;        sec
        sbc zpage+zp.y
        sta zpage+zp.ws_minus_y

        plot zpage+zp.ks_plus_x , @

;plot(ks-x, ws-y);

        plot zpage+zp.ks_minus_x	; , zpage+zp.ws_minus_y

;plot(ks+y, ws+x);

        lda zpage+zp.ks
        clc
        adc zpage+zp.y
        sta zpage+zp.ks_plus_y

	tax

        lda zpage+zp.ws
        adc zpage+zp.x
        sta zpage+zp.ws_plus_x

        plot , @	; zpage+zp.ks_plus_y , @

;plot(ks+y, ws-x);

        lda zpage+zp.ws
        sec
        sbc zpage+zp.x
        sta zpage+zp.ws_minus_x

        plot zpage+zp.ks_plus_y , @

;plot(ks-y, ws+x);

        lda zpage+zp.ks
        sbc zpage+zp.y
        sta zpage+zp.ks_minus_y

        plot @ , zpage+zp.ws_plus_x

;plot(ks-y, ws-x);

        plot , zpage+zp.ws_minus_x	; zpage+zp.ks_minus_y , zpage+zp.ws_minus_x

;og := mo + y + y + 1;

        lda zpage+zp.mo
        sec                     ; ustawienie znacznika przeniesienia C podczas dodawania
        adc zpage+zp.y          ; spowoduje ze wynik takiego dodawania bedzie zwiekszony o 1
        adc zpage+zp.y
        sta zpage+zp.og

;mo := og;

        sta zpage+zp.mo

;ou := og - x - x + 1;

        clc                     ; skasowanie znacznika przeniesienia C podczas odejmowania
        sbc zpage+zp.x          ; spowoduje ze wynik takiego odejmowania bedzie zwiekszony o 1
        sbc zpage+zp.x
        sta zpage+zp.ou

;y := y + 1;

        ldx zpage+zp.x
        ldy zpage+zp.y
        iny

;  if ou < og then
;  begin
;   x := x - 1;
;   mo := ou;
;  end;

;        lda ou
        cmp zpage+zp.og
        bcc dec_x
        jmp loop

dec_x   dex
;        lda ou
        sta zpage+zp.mo
        jmp loop

;end;

;end;

.endp

	blk update address
	blk update external
	blk update public

