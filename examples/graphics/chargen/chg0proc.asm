* Obs≥uga przerwaÒ
DLI    PHA
       LDA SDMACTL	; ZWEZ  EKRAN
       AND #%11111100
       ORA #%00000001
       STA SDMACTL
       STA DMACTL

       LDA #$7A		; KOLORY ZESTAWU
       STA COL1		; ZNAKOW
       LDA #$75
       STA COL2
AKTZZN EQU *+1		; USTAW AKTYWNY
       LDA #DEFINED	; ZESTAW ZNAKOW
       STA CHBASE
       STA SCHBASE
       PLA
       RTI

VBLANK PHA
       LDA SDMACTL	; POSZERZ EKRAN
       AND #%11111100
       ORA #%00000010
       STA SDMACTL
       STA DMACTL
       LDA #$CA		; KOLORY MENU
       STA COL1
       LDA #$C0
       STA COL2

       LDA #STAND1	; STANDARDOWY
       STA CHBASE	; ZESTAW ZNAKOW
       STA SCHBASE
       PLA
EXITVB EQU *+1
       JMP $E462

* Procedura poprawiajπca znak
ZNAK   LDA ZNACZ	; FIRE WCISNIETY
     AND #1		; I STRZALKA W
     BNE MNOZ_8		; TYM SAMYM
     LDA ZNACZ		; MIEJSCU???
     BPL MNOZ_8
     JMP LOOP

MNOZ_8 LDA INT		; ZNAJDZ ADRES
     ASL @		; ZNAKU:
     ROL ADRZN+1
     ASL @
     ROL ADRZN+1
     ASL @
     ROL ADRZN+1
     STA ADRZN

     CLC
     LDA ADRZN+1
     AND #%0111
     ADC AKTZZN
     STA ADRZN+1

     LDA #0
     LDX PZNSX
     SEC
L_2  ROR @
     DEX
     BPL L_2

     STA MASK

     LDY PZNSY
     LDA (ADRZN),Y
MASK   EQU *+1
     EOR #0
     STA (ADRZN),Y

     JSR POZNAK

     JMP LOOP

* PROCEDURE†††††††††††††
NEGUJ  LDA (ADEKOP),Y	; NEGUJ .Y ZNAKOW
     EOR #%10000000	; OD ADRESU
     STA (ADEKOP),Y	; ZAPISANEGO W
     DEY		; SLOWIE
     BPL NEGUJ		; ADEKOP
     RTS

* Zapisz adres ekranowy opcji w ADEKOP
USADOP LDA <EKRAN
     STA ADEKOP
     LDA >EKRAN
     STA ADEKOP+1

L_3  DEY
     BMI J_2
     CLC
     LDA ADEKOP
     ADC #40
     STA ADEKOP
     BCC L_3
     INC ADEKOP+1
     JMP L_3

J_2  CLC
     TXA
     ADC ADEKOP
     STA ADEKOP
     BCC J_3
     INC ADEKOP+1
J_3  RTS


* Zapisz adres znaku w s≥owie ADDR
USADZN LDX #0
     LDY AKTZZN
     STX ADDR
     STY ADDR+1

     STX POM

     LDA INT
     ASL @
     ROL POM
     ASL @
     ROL POM
     ASL @
     ROL POM

     CLC
     ADC ADDR
     STA ADDR
     LDA POM
     ADC ADDR+1
     STA ADDR+1
     RTS

* 	Wyglπd ekranu††††
EKRAN  EQU *
      DTA c'QRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRE'
      DTA c'|QRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRE|'
      DTA D'||       CHARACTERS  DESIGNER 0       ||'
      DTA D'||      (c) Slawomir SERO Ritter      ||'
      DTA c'|ZRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRC|'
      DTA c'|',$d1,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$d7,$c5,c'QRRRRRRWRRRRRREQRRRRRRRRRRRE|'
LINIA DTA D'|Å        Ñ|ASC:00|INT:00||QUIT TO DOS||'
      DTA d'|Å        Ñ',c'ZRRRRRRXRRRRRRC|',d'LOAD       ||'
      DTA D'|Å        Ñ',c'QRRRRRRRRRRRRRE|',d'SAVE       ||'
      DTA D'|Å        Ñ|ADRESS: $8800||DIRECTORY  ||'
      DTA D'|Å        Ñ',c'ZRRRRRRRRRRRRRC|',d'SET ADRESS ||'
      DTA D'|Å        Ñ',c'QRRRRRRRRRRRRRE|',d'CLEAR  ALL ||'
      DTA D'|Å        Ñ|ROLL: ú û ù ü||CLEAR CHAR.||'
      DTA D'|Å        Ñ',c'ZRRRRRRRRRRRRRC|',d'TURN',$5e,d' CHAR.||'
      DTA D'|',$da,$d8,$d8,$d8,$d8,$d8,$d8,$d8,$d8,$c3,c'QRRRRRRRRRRRRRE|',d'TURN CHAR.||'
      DTA c'|QRRRRRRRRE|',d'STANDARD    1||MIRROR   ',$52,d' ||'
      DTA D'||Œœ“Õ¡Ã††||STANDARD    2||MIRROR   | ||'
      DTA D'||INVERTED||ƒ≈∆…Œ≈ƒ††††††||COPY  CHAR.||'
      DTA c'|ZRRRRRRRRCZRRRRRRRRRRRRRCZRRRRRRRRRRRC|'
      DTA c'ZRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRC'
LITERS org *+128

* 	Display List††††
DLIST  DTA B($70),B($70),B($70)
       DTA B($42),A(EKRAN)
       DTA B(2),B(2),B(2),B(2),B(2)
       DTA B(2),B(2),B(2),B(2),B(2)
       DTA B(2),B(2),B(2),B(2),B(2)
       DTA B(2),B(2),B(2),B(2)
       DTA B($80)
       DTA B(2),B(2),B(2),B(2)
       DTA B($41),A(DLIST)

* Kszta≥t strza≥ki i wskaünika
ST_SHAPE EQU *
     DTA B(%11100000)
     DTA B(%11100000)
     DTA B(%11000000)
     DTA B(%11000000)
     DTA B(%10100000)
     DTA B(%10100000)
     DTA B(%00010000)
     DTA B(%00010000)
     DTA A(0),A(0),A(0),A(0)

WS_SHAPE EQU *
     DTA B($F0),B($F0),B($F0),B($F0)
     DTA B($F0),B($F0),B($F0),B($F0)
     DTA A(0),A(0),A(0),A(0)

* Put 2 hex digits INT
_pihex   pha
     jsr _pidig
     pla
     lsr @
     lsr @
     lsr @
     lsr @
_pidig   and #%00001111
     ora #$10
     cmp #$19+1
     bcc *+4
     adc #6
     sta (_ioz0),Y
     dey
     rts

;----------------------
; PM library
; author: M.Liminowicz
;----------------------

* page 0
_pmtmp   equ _pmz0	;(2)
_pmpoint equ _pmz0+2	;(2)

* system variables
sdmctl equ $22F
gprior equ $26F
pcolr0 equ $2C0

hposp0 equ $D000
gractl equ $D01D
sizep0 equ $D008
pmbase equ $D407

* switch PM graphics on
_pmon and #%11111000
     sta pmbase
     sta _pmaddr
     lda sdmctl
     and #%11101111
     sta sdmctl
     lda #0
     rol @
     sta _pmres
     asl @
     asl @
     asl @
     asl @
     ora sdmctl
     ora #%00001100
     sta sdmctl
     lda gprior
     and #%11000000
     ora #%00001000
     sta gprior
     lda #%00000011
     sta gractl

     lda #0
     ldx #7
_pmout sta hposp0,x
     sta sizep0,x
     sta _pmpx,x
     sta _pmpy,x
     dex
     bpl _pmout

     jsr _pmpadr

     ldx #1

     ldy #0
     tya

_pmcpage sta (_pmtmp),y
     iny
     bne *-3
     inc _pmtmp+1
     dex
     bpl _pmcpage

     lda #4
     jsr _pmpadr

     lda #0
     tay
     sta (_pmtmp),y
     iny
     bne *-3
     rts

* switch PM graphics off
_pmoff   lda sdmctl
     and #%11100011
     sta sdmctl
     lda #0
     sta gprior
     sta gractl
     ldx #7
_clppos  equ *
     sta hposp0,x
     dex
     bpl _clppos
     rts

* set player's parameters
_pmset   and #3
     sta _pmhelp
     txa
     ldx _pmhelp
     sta pcolr0,x
     dey
     tya
     and #%00000011
     sta sizep0,x
     rts

* set player's positions
_pmxy    and #7
     sta _pmhelp
     txa
     ldx _pmhelp
     sta _pmpx,x
     sta hposp0,x

     tya
     pha
     txa

     jsr _pmpadr

     pla
     ldx _pmres
     bne *+4
     and #$7F

     ldx _pmhelp
     ldy _pmpy,x
     sta _pmpy,x

     cpx #4
     bcs _pmmisil

     pha

     ldx #0
_pmcptb  lda (_pmtmp),y

     pha
     lda #0
     sta (_pmtmp),y
     pla
     sta _pmbuff,x
     iny
     tya
     and #$7F
     bne *+13
     lda _pmres
     bne *+8
     tya
     and #$80
     eor #$80
     tay

     inx
     cpx #16
     bcc _pmcptb

     pla
     tay
     ldx #0
_pmcpob  lda _pmbuff,x
     sta (_pmtmp),y
     iny
     tya
     and #$7F
     bne *+13
     lda _pmres
     bne *+8
     tya
     and #$80
     eor #$80
     tay
     inx
     cpx #16
     bcc _pmcpob
     rts

_pmmisil pha

     dex
     dex
     dex
     dex

     lda (_pmtmp),y
     and _pmmask,x
     sta (_pmtmp),y

     pla
     tay
     lda _pmmask,x
     eor #$FF
     ora (_pmtmp),y
     sta (_pmtmp),y
     rts

* copy shape to player
_pmshape stx _pmpoint
     sty _pmpoint+1
     cmp #4
     bcc *+3
     rts
     sta _pmhelp
     tax
     lda _pmpx,x
     sta hposp0,x
     txa
     jsr _pmpadr
     ldy _pmhelp
     ldx _pmpy,y
     ldy #0
_pmcppl  lda (_pmpoint),y
     sty _pmhelp
     pha
     txa
     tay
     pla
     sta (_pmtmp),y
     tya
     tax
     inx
     txa
     and #$7F
     bne *+13
     lda _pmres
     bne *+8
     txa
     and #$80
     eor #$80
     tax
     ldy _pmhelp
     iny
     cpy #16
     bcc _pmcppl
     rts

* set address of desired player
_pmpadr  pha
     lda #0
     sta _pmtmp
     ldx _pmres
     inx
     txa
     asl @	; ,clc
     tax
     adc _pmaddr
     sta _pmtmp+1
     pla
     cmp #4
     bcs _pmisile
     tax

_pmsearc dex
     bpl *+3
     rts

     clc
     lda _pmtmp
     adc #$80
     ldy _pmres
     beq *+4
     adc #$80
     sta _pmtmp
     bcc *+4
     inc _pmtmp+1
     jmp _pmsearc

_pmisile ldx _pmres
_pmis1   sec
     lda _pmtmp
     sbc #$80
     sta _pmtmp
     lda _pmtmp+1
     sbc #0
     sta _pmtmp+1
     dex
     bpl _pmis1
     rts

* My variables
_pmaddr  org *+1
_pmres   org *+1
_pmhelp  org *+1
_pmpy    org *+8
_pmpx    org *+8
_pmbuff  org *+16

_pmmask  dta b(%11111110)
         dta b(%11111011)
         dta b(%11101111)
         dta b(%10111111)

* ROLLuj znak
ROLL	LDA ZNACZ	; PUSCZONO FIRE?
     AND #1
     BEQ WR2		; NIE!:WROC.

     LDA PZNSX		; SPACJA CZY OPCJA?
     TAX
     AND #1
     BNE WR2

     LDA TABROL,X	; ADRES PROC.
     STA JSRROL		; REALIZ. OPCJE
     LDA TABROL+1,X
     STA JSRROL+1
     JSR USADZN

JSRROL EQU *+1
     JSR ROLL
     JSR POZNAK
WR2  JMP LOOP

TABROL DTA A(UPROLL),A(LTROLL)
       DTA A(DNROLL),A(RTROLL)

LTROLL LDY #7		; ILOSC BAJTOW
L_4  LDA (ADDR),Y	; ROLLUJ BAJT WZORU
     ASL @		; (W LEWO)
     BCC J_4
     ORA #1
J_4  STA (ADDR),Y
     DEY		; NAST.BAJT
     BPL L_4
     RTS
RTROLL LDY #7		; ILOSC BAJTOW
L_5  LDA (ADDR),Y	; ROLLUJ BAJT WZORU
     LSR @		; (W PRAWO)
     BCC J_5
     ORA #%10000000
J_5  STA (ADDR),Y
     DEY		; NAST.BAJT
     BPL L_5
     RTS
UPROLL LDY #0		; (W GORE)
     LDA (ADDR),Y
     TAX
L_6  INY
     LDA (ADDR),Y
     DEY
     STA (ADDR),Y
     INY
     CPY #7
     BNE L_6
     TXA
     STA (ADDR),Y
     RTS
DNROLL LDY #7		; (W DOL)
     LDA (ADDR),Y
     TAX
L_7  DEY
     LDA (ADDR),Y
     INY
     STA (ADDR),Y
     DEY
     BNE L_7
     TXA
     STA (ADDR),Y
     RTS

* Zinwertuj znaki zestawu
NO_INV LDY PZNSY	; SPRAWDZ CZY TA
     CPY ZN_N_I		; SAMA OPCJA
     BEQ WR		; NIE!:
     STY ZN_N_I		; ZAPISZ NR.OPCJI

     LDX #2		; ZANEGUJ"NORMAL"
     LDY #16
     JSR USADOP
     LDY #7
     JSR NEGUJ
     LDX #2		; ZANEGUJ"INVERTED"
     LDY #17
     JSR USADOP
     LDY #7
     JSR NEGUJ

     LDA <LITERS	; ZANEGUJ ZESTAW
     STA ADEKOP		; ZNAKOW
     LDA >LITERS
     STA ADEKOP+1
     LDY #127
     JSR NEGUJ

WR   JMP LOOP

ZN_N_I DTA B(0)		; NR.WYBRANEJ OPCJI

* ZmieÒ zestaw znakÛw
ST_DEF LDX ZN_S_D	; CZY NIE TA SAMA
     CPX PZNSY		; OPCJA?-NIE:
     BEQ WR
NEGSD STX ZN_S_D	; ZAPISZ NR.OPCJI
     LDY TABSDY,X	; ZANEGUJ OSTATNIA
     LDX #12		; NAZWE OPCJI
     JSR USADOP
     LDY #12
     JSR NEGUJ

     LDX PZNSY		; ZANEGUJ AKT.
     CPX ZN_S_D		; NAZWE OPCJI
     BNE NEGSD

     LDA TABADZ,X	; ZAPISZ NOWY ADRES
     STA AKTZZN		; ZESTAWU ZNAKOW
     JSR POZNAK		; POKAZ ZNAK
     JMP LOOP

ZN_S_D DTA B(2)		; NR.WYBRANEJ OPCJI

TABSDY DTA B(15),B(16),B(17)
TABADZ DTA B(STAND1),B(STAND2),B(DEFINED)

* Pokaø znak w powiÍkszeniu
POZNAK JSR USADZN

     LDX <LINIA+2	; ZAPISZ ADRES
     LDY >LINIA+2	; OKNA NA EKRANIE
     STX ADDR2
     STY ADDR2+1

     LDY #0		; ILOSC BAJTOW ZNAKU
RYSZN LDA (ADDR),Y
     STA POM
     TYA
     TAX
     LDA #0

     LDY #7		; ILOSC BITOW
RYSBA LSR POM
     ROR @
     STA (ADDR2),Y
     ASL @
     DEY
     BPL RYSBA

     CLC
     LDA ADDR2		; ZWIEKSZ ADRES LINI
     ADC #40
     STA ADDR2
     LDA ADDR2+1
     ADC #0
     STA ADDR2+1

     TXA
     TAY
     INY
     CPY #8
     BNE RYSZN
     RTS

* Obs≥uguj joystick-iem strza≥kÍ
ARROW  STX POZSX	; ZAPISZ WSP.
       STY POZSY	; STRZALKI
     LDA #STRZALKA	; WYSWIETL JA
     JSR _PMXY

     LDA STRIG0		; JESLI WCISNIETO
     BNE ARR		; FIRE TO WROC
     RTS

ARR  LDX POZSX		; POBIERZ WSP.
     LDY POZSY		; STRZALKI
UP   LDA #1		; I ODPOWIEDNIO
     BIT STICK0		; JE ZMODYFIKUJ
     BNE DOWN		; W ZALEZNOSCI OD
     CPY #MINSY		; RUCHU JOYA:
     BEQ DOWN		; -W GORE
     DEY
DOWN ASL @
     BIT STICK0
     BNE LEFT		; -W DOL
     CPY #MAXSY
     BEQ LEFT
     INY
LEFT ASL @
     BIT STICK0
     BNE RIGHT
     CPX #MINSX		; -W LEWO
     BEQ RIGHT
     DEX
RIGHT ASL @
     BIT STICK0
     BNE WAIT		; -W PRAWO
     CPX #MAXSX
     BEQ WAIT
     INX
WAIT STX POZSX		; ZAPISZ WSP.X
     LDX 20		; CZEKAJ NA
WAIT2 LDA ZNACZ		; VBLANK
     ORA $D010		; I SPRAWDZ
     STA ZNACZ		; CZY PUSZCZONO
     CPX 20		; FIRE?
     BEQ WAIT2

     LDX POZSX		; ODTWORZ WSP.X
     JMP ARROW

POZSX  DTA B(MINSX)
POZSY  DTA B(MINSY)

USTWSK EQU *
     TXA
     AND #%11111100	; TAK:USTAW ODPOW.
     TAX
     TYA
     AND #%11111000	; WSKAZNIK
     TAY
     INY
     STX POZWX
     STY POZWY
     LDA #WSKAZNIK
     JSR _PMXY

     LDA POZWY
     SEC
     SBC #MINWY		; WSP.(W PIXELACH)
     LSR @		; NA WSPOLRZEDNE
     LSR @		; W ZNAKACH
     LSR @		; (x)
     TAY

     LDA POZWX		; (y)
     SEC
     SBC #MINWX
     LSR @
     LSR @
     STA INT

     LDA #0
     CLC
DOD32 DEY		; PRZELICZ WSP.
     BMI INTTOASC	; NA KOD INT.ZNAKU
     ADC #32
     JMP DOD32

INTTOASC EQU *
     ADC INT
     STA INT

     LDX #3
PORINT DEX
     CMP TABINT,X	; ...I NA KOD ASCII
     BCC PORINT

     CLC
     ADC TABIPL,X
STAASC STA ASC

     LDX <LINIA
     LDY >LINIA
     STX _IOZ0
     STY _IOZ0+1

     LDY #24		; WYSWIETL (INT)
     LDA INT
     JSR _PIHEX

     DEY
     DEY
     DEY
     DEY
     DEY

     LDA ASC		; (ASC)
     JSR _PIHEX
     RTS

POZWX  DTA B(0)
POZWY  DTA B(0)
INT    DTA B(0)
ASC    DTA B(0)

TABINT DTA B($00),B($40),B($60)
TABIPL DTA B($20),B($100-$40),B($00)

* W≥πcz edytor (ekran DOS-a)
USEDIT LDA #STRZALKA
     TAX
     TAY
     JSR _PMXY
     LDA #WSKAZNIK
     TAX
     TAY
     JSR _PMXY
     LDX OLDDLT
     LDY OLDDLT+1
     STX DLADR
     STY DLADR+1
     RTS
