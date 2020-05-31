// LINE (19.06.2006)

	// tworzymy strukture dla zmiennych na stronie zerowej, aby wymusic ich relokowalnosc

	.struct	zp
	d	.word
	i	.byte
	npix	.byte
	dx	.byte
	dy	.byte
	.ends


zpage	ext	.byte
plot	ext	.proc (.byte x,y) .reg

	.public	line

	.reloc

/********************************************************************
  BRESENHAM LINE
  
  maksymalna dlugosc linii ograniczona jest do 128 pixli

  wywolanie procedury:
                      LINE #x1 , #y1 , #x2 , #y2
                      LINE X1,Y1,#X2,#Y2

  X -> wspolrzedna pozioma
  Y -> wspolrzedna pionowa

********************************************************************/

.proc line (.byte x1,y1,x2,y2) .var

	.var x1, y1, x2, y2	.byte

;procedure Line(x1, y1, x2, y2, color : byte);
;var d : integer;
;    dinc2 : word;
;    xinc1, xinc2, yinc1, yinc2, dinc1, i, npix, dx, dy, x, y : byte;
;begin

;  xinc2 := 1;
;  yinc2 := 1;

        lda #{inx}
        sta xinc2

        lda #{iny}
        sta yinc2

; { Calculate dx and dy for initialisation }
;  dx := abs(x2 - x1);
;  dy := abs(y2 - y1);

        lda x2
        sec
        sbc x1
        bpl abs_00
        
        eor #$ff        ; zmiana znaku na przeciwny
        adc #1

abs_00  sta zpage+zp.dx

        lda y2
        sec
        sbc y1
        bpl abs_01
        
        eor #$ff        ; zmiana znaku na przeciwny
        adc #1
        
abs_01  sta zpage+zp.dy

; { Initialize all vars based on which is the independent variable }
;  if dx >= dy then
;    begin
        
        lda zpage+zp.dx
        cmp zpage+zp.dy
        bcc y_independent        

; >= tutaj

; { x is independent variable }
;      npix := dx;
;      dinc1 := dy Shl 1;
;      d := dinc1 - dx;
;      dinc2 := d - dx;
;      xinc1 := 1;
;      yinc1 := 0;

x_independent
        lda zpage+zp.dx
        sta zpage+zp.npix
        
        lda zpage+zp.dy
        asl @
        sta dinc1+1
        
        sec
        sbc zpage+zp.dx
        sta zpage+zp.d
        lda #0
        sbc #0
        sta zpage+zp.d+1
        
        lda zpage+zp.d
        sec
        sbc zpage+zp.dx
        sta l_dinc2+1
        lda zpage+zp.d+1
        sbc #0
        sta h_dinc2+1

        lda #{inx}
        sta xinc1

        lda #{nop}
        sta yinc1

; { Make sure x and y move in the right directions }
;      if x1 >= x2 then
;       begin
;        xinc1 := $ff;
;        xinc2 := $ff;
;      end;
;      if y1 >= y2 then yinc2 := $ff;

        lda x1
        cmp x2
        bcc lt_00
        
        lda #{dex}
        sta xinc1
        sta xinc2        

lt_00   lda y1
        cmp y2
        bcc drawing
        
        lda #{dey}
        sta yinc2
        jmp drawing
                        
; < tutaj

;  else
;    begin
; { y is independent variable }
;      npix := dy;
;      dinc1 := dx Shl 1;
;      d := dinc1 - dy;
;      dinc2 := d - dy;
;      xinc1 := 0;
;      yinc1 := 1;

y_independent
        lda zpage+zp.dy
        sta zpage+zp.npix
        
        lda zpage+zp.dx
        asl @
        sta dinc1+1
        
        sec
        sbc zpage+zp.dy
        sta zpage+zp.d
        lda #0
        sbc #0
        sta zpage+zp.d+1
        
        lda zpage+zp.d
        sec
        sbc zpage+zp.dy
        sta l_dinc2+1
        lda zpage+zp.d+1
        sbc #0
        sta h_dinc2+1

        lda #{iny}
        sta yinc1

        lda #{nop}
        sta xinc1

; { Make sure x and y move in the right directions }
;      if x1 >= x2 then xinc2 := $ff;
;      if y1 >= y2 then
;       begin
;        yinc1 := $ff;
;        yinc2 := $ff;
;      end;

        lda x1
        cmp x2
        bcc lt_01
        
        lda #{dex}
        sta xinc2

lt_01   lda y1
        cmp y2
        bcc drawing
        
        lda #{dey}
        sta yinc1
        sta yinc2

; { Start drawing at <x1,y1> }
;  x := x1;
;  y := y1;

drawing ldx x1
        ldy y1

; { Draw the pixels }
;  for i := 0 to npix do begin

petla

;      PutPixel(x, y, color);


// dla procedury PLOT typu .REG nie musimy podawac parametrow jesli akurat wiemy
// ze w odpowiednich rejestrach sa juz wlasciwe dane

        plot

;      if d < 0 then

        clc
        
        lda zpage+zp.d+1
        bpl plus

;        begin
;          d := d + dinc1;
;          x := x + xinc1;
;          y := y + yinc1;
;        end

minus   lda zpage+zp.d
;        clc
dinc1   adc #0
        sta zpage+zp.d
        bcc xinc1
        inc zpage+zp.d+1

xinc1   nop
yinc1   nop

        dec zpage+zp.npix
        bpl petla

        rts

;      else
;        begin
;          d := d + dinc2;
;          x := x + xinc2;
;          y := y + yinc2;
;        end;
;    end;
;end;

plus    lda zpage+zp.d
;        clc
l_dinc2 adc #0
        sta zpage+zp.d
        lda zpage+zp.d+1
h_dinc2 adc #0
        sta zpage+zp.d+1

xinc2   nop
yinc2   nop

        dec zpage+zp.npix
        bpl petla       

	rts

.endp

	blk update address
	blk update external
	blk update public
