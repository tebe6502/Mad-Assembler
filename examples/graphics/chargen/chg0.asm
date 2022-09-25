
;---------------------------
;  CHARACTERS GENERATOR 0
;---------------------------
;Wersja:1.0  Data:12.12.94
;---------------------------
;Autor:Slawomir'SERO'Ritter
;---------------------------
;Dolaczyc plik (icl):
;D:CHG0PROC.ASM
;---------------------------

LIST_ERR EQU %00000101
LIST_ALL EQU %00000111
CODE_MEM EQU %00010000
CODE_FIL EQU %00100000


* ADRESY SYSTEMOWE
SETVBV	EQU $E45C
CIOV	EQU $E456
IFP	EQU $D9AA
FASC	EQU $D8E6

FR0	EQU $D4
LBUFF	EQU $580

VVBLKD	EQU $224
VDSLST	EQU $200
NMIEN	EQU $D40E
DLADR	EQU 560
DMACTL	EQU $D400
SDMACTL	EQU 559
COL2	EQU $D018
COL1	EQU $D017
SCHBASE	EQU 756
CHBASE	EQU $D409
STICK0	EQU $278
STRIG0	EQU $284
DRIV	EQU $301
SKCTL	EQU $D20F
KEY	EQU 764
DOSRUN	EQU $A
RUNAD	EQU $2E0

IOCB   EQU $340
IO_COM EQU IOCB+2
IO_STA EQU IOCB+3
IO_ADR EQU IOCB+4	;(2)
IO_LEN EQU IOCB+8	;(2)
IO_MOD EQU IOCB+10
IO_AUX EQU IOCB+11


* stale
STAND1	EQU 224		; ADRESY
STAND2	EQU 204		; ZESTAWOW
DEFINED	EQU $88		; ZNAKOW (TYLKO MSB)

ADRPROGRAM	EQU $9000	; ADRESY
ADRZZ		EQU $87FA	; CZÊŒCI PROGRAMU!!!
GRPM		EQU $80		;

LENZZ  EQU $0406

MINSX  EQU 48	; KRANCOWE
MINSY  EQU 32	; WSPOLRZEDNE
MAXSX  EQU 204	; STRZALKI
MAXSY  EQU 222

MINWX  EQU 64	; KRANCOWE
MINWY  EQU 193	; WSPOLRZEDNE
MAXWX  EQU 190	; WSKAZNIKA

STRZALKA EQU 0	; NR.SPRITE'U DLA STRZALKI
WSKAZNIK EQU 1	; NR.SPRITE'U DLA WSKAZNIKA

ILOP	EQU 5	; ILOSC OKIEN
WAITCTL	EQU 12	; OPOZNIENIE

CHN0   EQU $00
CHN1   EQU $10
GETT   EQU 5
PUTT   EQU 9
GETB   EQU 7
PUTB   EQU 11
EOL    EQU 155
EOF    EQU 136

* strona zerowa
_PMZ0  EQU $D0
_IOZ0  EQU $E0

POM    EQU $F0
ADDR   EQU $F1
       *   $F2
ADDR2  EQU $F3
       *   $F4
ADRZN  EQU $F5		; -ADRES ZNAKU
       *   $F6		;  W ZESTAWIE ZNAKOW
ZNACZ  EQU $F7		; -ZNACZNIK FIRE
ADEKOP EQU $F8		; -ADRES OPCJI W
       *   $F9		; PAMIECI EKRANU
POM2   EQU $FA
ADDR3  EQU $FB	;(2)

       ORG ADRPROGRAM

       JMP START

* Procedura STARTowa
OLDDLT ORG *+2		; DLIST DOS(ADR)

START LDX VVBLKD	; PRZEDLUZ WEKTOR
     LDY VVBLKD+1
     STX EXITVB
     STY EXITVB+1
     LDY <VBLANK	; NOWY VBLANK
     LDX >VBLANK
     LDA #7
     JSR SETVBV

     LDX DLADR		; ZACHOWAJ WEKTOR
     LDY DLADR+1
     STX OLDDLT
     STY OLDDLT+1

     LDX #00		; WYPELNIJ KOLEJNYMI
WYPLTR TXA		; ZNAKAMI DOL EKRANU
     STA LITERS,X
     INX
     BPL WYPLTR

     LDA #GRPM
     SEC
     JSR _PMON

     LDA #STRZALKA
     LDX #$1C
     LDY #1
     JSR _PMSET

     LDA #WSKAZNIK
     LDX #$32
     LDY #1
     JSR _PMSET

     LDA #STRZALKA
     LDX <ST_SHAPE
     LDY >ST_SHAPE
     JSR _PMSHAPE

     LDA #WSKAZNIK
     LDX <WS_SHAPE
     LDY >WS_SHAPE
     JSR _PMSHAPE

     LDA #WSKAZNIK
     LDX POZWX
     LDY POZWY
     JSR _PMXY

     LDA #DEFINED
     STA AKTZZN
CONT2 JSR POZNAK

     LDX <DLI		; NOWY DLI
     LDY >DLI
     STX VDSLST
     STY VDSLST+1

     LDA #$C0		; DLI I VBLANK
     STA NMIEN

     LDX <DLIST
     LDY >DLIST
     STX DLADR
     STY DLADR+1

     LDX POZSX
     LDY POZSY
     JSR ARROW

* Pêtla g³ówna
LOOP LDA #0
     STA ZNACZ
     JSR ARR
     LDY POZSY
     CPY #MINWY		; STRZALKA NA LITERZE?
     BCC DALEJ
     LDX POZSX
     CPX #MINWX
     BCC DALEJ
     CPX #MAXWX+1
     BCS DALEJ
     JSR USTWSK
     JSR POZNAK
LOOPUJ JMP LOOP

* Procedura wybieraj¹ca opcje
DALEJ LDA POZSY
     SEC		; WSP. STRZALKI
     SBC #MINSY		; (W PIXELACH)
     LSR @		; NA WSPOLRZEDNE W
     LSR @		; ZNAKACH
     LSR @		; (x)
     STA PZNSY

     LDA POZSX		; (y)
     SEC
     SBC #MINSX
     LSR @
     LSR @
     STA PZNSX

     LDA PZNSX
     LDY PZNSY
     CMP LASTX		; STRZALKA WSKAZUJE
     BNE J_1
     CPY LASTY		; TEN SAM ZNAK?
     BNE J_1
     LDA ZNACZ
     ORA #%10000000
     STA ZNACZ

J_1  LDA PZNSX
     STA LASTX
     STY LASTY

     LDX #ILOP		; SPRAWDZ W KTORYM
L_1  DEX		; OKNIE JEST STRZALKA
     BMI LOOPUJ		; POROWNUJAC JEJ WSP.
     *           Z WSP. BRZEGU OKNA:

     LDA PZNSX
     CMP LEBOP,X	; -LEWA
     BCC L_1

     LDA PZNSY
     CMP UPBOP,X	; -GORNA
     BCC L_1

     LDA RIBOP,X	; -PRAWA
     CMP PZNSX
     BCC L_1

     LDA DOBOP,X	; -DOLNA
     CMP PZNSY
     BCC L_1

     SEC		; PODAJ WSPOLRZEDNE
     LDA PZNSX		; STRZALKI W OKNIE:
     SBC LEBOP,X
     STA PZNSX		; -(X)

     SEC
     LDA PZNSY
     SBC UPBOP,X
     STA PZNSY		; -(Y)

     TXA
     ASL @
     TAX

     LDA TABADO,X
     STA JMPOP		; ADRES PROC.
     LDA TABADO+1,X	; OBSLUGUJACEJ
     STA JMPOP+1	; OKNO

JMPOP EQU *+1
     JMP LOOP

PZNSX  DTA B(0)		; ZNAKOWE WSP. X I Y
PZNSY  DTA B(0)		; STRZALKI

LASTX  DTA B(0)		; POPRZEDNIE WSP. STRZ.
LASTY  DTA B(0)

* DANE DOTYCZACE OKIEN
TABOPC DTA B($02),B($0C),B($12),B($1B),B($02)
       DTA B($10),B($0F),B($0C),B($06),B($06)
       DTA B($09),B($18),B($18),B($25),B($09)
       DTA B($11),B($11),B($0C),B($11),B($0D)
       *   NO_INV,ST_DEF,ROLL  ,MENU  ,ZNAK

TABADO DTA A(NO_INV),A(ST_DEF)
       DTA A(ROLL),A(MENU),A(ZNAK)

LEBOP  EQU TABOPC
UPBOP  EQU TABOPC+ILOP
RIBOP  EQU TABOPC+ILOP+ILOP
DOBOP  EQU TABOPC+ILOP+ILOP+ILOP
       *   ADRESY WSP.BRZEGOW OKIEN


* Procedura obs³ugi MENU
MENU LDA PZNSY
     CMP #6
     BCS ME_2

     LDX <NUL_M
     JSR DSP_MSG

ME_2 LDA PZNSY
     ASL @
     TAX
     LDA TABMEN,X
     STA JMPMEN
     LDA TABMEN+1,X
     STA JMPMEN+1

JMPMEN EQU *+1
     JMP LOOP

TABMEN DTA A(TODOS),A(LOAD),A(SAVE)
       DTA A(DIR),A(SETADR),A(CLALL)
       DTA A(CLCHAR),A(TURNL),A(TURNR)
       DTA A(MIRV),A(MIRH),A(COPY)

* Procedury z MENU
TODOS JSR USEDIT
     LDX <DOS_M
     JSR DSP_MSG
     JSR SURE
     JSR _PMOFF

     LDY EXITVB		; STARY VBLANK
     LDX EXITVB+1
     LDA #7
     JSR SETVBV
     LDA #$40		; VBLANK
     STA NMIEN
     JMP (DOSRUN)

SETADR JSR USEDIT
     LDX <SET_M
     JSR DSP_MSG
     LDX <USE_M
     JSR DSP_MSG
     LDX <KEY_M
     JSR DSP_MSG
     LDA #255
     STA KEY
L_27 CMP KEY
     BNE J_27
     LDY STRIG0
     BNE L_27
J_28 LDY STRIG0
     BEQ J_28
J_27 STA KEY
     JSR USCHG
     JSR NEGSA
     LDX <ADEKSA
     LDY >ADEKSA
     STX _IOZ0
     STY _IOZ0+1
L_28 LDA STICK0
     AND #%00000100	; (LEFT)
     BEQ DECADR
     LDA STICK0
     AND #%00001000	; (RIGHT)
     BEQ INCADR
     LDA STRIG0
     BNE L_28
     JSR WAIT_2
     JSR NEGSA
     JMP LOOP
DECADR SEC
     LDA ADWG+1
     SBC #$08
     STA ADWG+1
     JSR WAIT_2
     JMP L_28
INCADR CLC
     LDA ADWG+1
     ADC #$08
     STA ADWG+1
     JSR WAIT_2
     JMP L_28
WAIT_2 LDY #WAITCTL
L_29 LDA 20
L_30 CMP 20
     BEQ L_29
     DEY
     BNE L_29
     LDY #2
     LDA ADWG+1
     JMP _PIHEX
NEGSA LDX #27
     LDY #10
     JSR USADOP
     LDY #10
     JSR NEGUJ
     RTS

LOAD JSR USEDIT
     LDX <LOA_M
     JSR DSP_MSG
     JSR FILENAME
     BPL J_9
     JMP WRMENU

J_9  JSR CLOSE
     LDA #4
     JSR OPEN
     BMI J_11
     JSR MCIO
     BMI J_11
     JSR CLOSE
     BMI J_11

     LDA ADRZZ+2
     STA ADWG
     LDA ADRZZ+3
     STA ADWG+1
J_11 JMP WRMENU

SAVE JSR USEDIT
     LDX <SAV_M
     JSR DSP_MSG
     JSR FILENAME
     BMI J_11

     LDA #$FF
     STA ADRZZ
     STA ADRZZ+1
     LDA ADWG
     STA ADRZZ+2
     CLC
     ADC #$FF
     STA ADRZZ+4
     LDA ADWG+1
     STA ADRZZ+3
     ADC #$03
     STA ADRZZ+5

     JSR CLOSE
     LDA #8
     JSR OPEN
     BMI WRMENU
     JSR MCIO
     BMI WRMENU
     JSR CLOSE
     JMP WRMENU

DIR  JSR USEDIT
     LDX <DIR_M
     JSR DSP_MSG
     JSR FILENAME
     BMI WRMENU
     JSR CLOSE
     LDA #6
     JSR OPEN
     BMI WRMENU
L_11 LDX #CHN1
     LDA #GETT
     JSR USBUFOR
     BMI WRMENU
     LDX #CHN0
     LDA #PUTT
     JSR USBUFOR
     BMI WRMENU
     BPL L_11		; (JMP)
USBUFOR STA IO_COM,X
     LDA #128
     STA IO_LEN,X
     LDA #0
     STA IO_LEN+1,X
     LDA <BUFOR
     STA IO_ADR,X
     LDA >BUFOR
     STA IO_ADR+1,X
     JSR CIOV
     BPL WRUSBU
     CPY #136
     BNE J_12
     PLA
     PLA
     JSR CLOSE
     LDA #255
     STA KEY
L_12 CMP KEY
     BEQ L_12
     JMP WRMENU
WRUSBU RTS

J_12 JMP ERROR
WRMENU JSR USCHG
     JMP CONT2

TURNL LDA #1
     BIT ZNACZ
     BEQ J_20
     BPL J_20
     JSR USADZN
     LDA #3
     STA LOPC
L_26 JSR T_R
     DEC LOPC
     BNE L_26
     JMP J_24
LOPC DTA B(0)

TURNR LDA #1
     BIT ZNACZ
     BEQ J_20
     BPL J_20
     JSR USADZN
     JSR T_R
     JMP J_24

T_R  LDY #15
     LDA #0
L_22 STA BUFOR,Y
     DEY
     BPL L_22

     LDA #%10000000
     STA P_2
     LDY #7
L_19 LDA (ADDR),Y
     LDX #7
L_20 LSR @
     BCC J_21
     PHA
     LDA BUFOR,X
P_2  EQU *+1
     ORA #0
     STA BUFOR,X
     PLA
J_21 DEX
     BPL L_20
     LSR P_2
     DEY
     BPL L_19
BTS  LDY #7
L_21 LDA BUFOR,Y
     STA (ADDR),Y
     DEY
     BPL L_21
     RTS

MIRH LDA #1
     BIT ZNACZ
     BEQ J_20
     BPL J_20
     JSR USADZN
     LDY #7
L_16 LDA (ADDR),Y
     LDX #7
L_17 ASL @
     ROR P_1
     DEX
     BPL L_17
P_1  EQU *+1
     LDA #0
     STA (ADDR),Y
     DEY
     BPL L_16
J_24 JSR POZNAK
J_20 JMP LOOP

MIRV LDA #1
     BIT ZNACZ
     BEQ J_20
     BPL J_20
     JSR USADZN
     LDY #7
L_24 LDA (ADDR),Y
     STA BUFOR,Y
     DEY
     BPL L_24

     LDY #3
     LDX #4
L_25 LDA BUFOR,X
     PHA
     LDA BUFOR,Y
     STA BUFOR,X
     PLA
     STA BUFOR,Y
     INX
     DEY
     BPL L_25
     JSR BTS
     JMP J_24

CLALL JSR USEDIT
     LDX <CLA_M
     JSR DSP_MSG
     LDA AKTZZN
     CMP #DEFINED
     BEQ J_19
     LDX <ROM_M
     JSR DSP_MSG
J_19 JSR SURE
     LDA INT
     STA OSTINT
     LDA #0
     STA INT
L_15 JSR CLR
     INC INT
     BPL L_15
     LDA OSTINT
     STA INT
     JSR USCHG
     JMP J_17

OSTINT DTA B(0)

CLCHAR JSR CLR
J_17 JSR POZNAK
     LDY #2
     STY PZNSY
     JMP ST_DEF

CLR  JSR USADZN
     LDY AKTZZN
     STY LASTZZN
     CPY #DEFINED
     BEQ J_15
     LDX ADDR
     LDA ADDR+1
     STX ADDR3
     STA ADDR3+1
     LDY #DEFINED
     STY AKTZZN
     JSR USADZN
     LDA LASTZZN
     STA AKTZZN
J_15 LDY #7
L_14 SEC
     LDA AKTZZN
     SBC #DEFINED
     BEQ J_16
     LDA (ADDR3),Y
J_16 STA (ADDR),Y
     DEY
     BPL L_14
     RTS

LASTZZN DTA B(0)

COPY LDX #27
     LDY #17
     JSR USADOP
     LDY #10
     JSR NEGUJ
     JSR USADZN
     LDX ADDR
     LDY ADDR+1
     STX ADDR3
     STY ADDR3+1
J_22 LDA #0
     STA ZNACZ
     JSR ARR
     LDA ZNACZ
     BMI J_22
     LDY POZSY
     CPY #MINWY		; STRZALKA NA LITERZE?
     BCC J_23
     LDX POZSX
     CPX #MINWX
     BCC J_23
     CPX #MAXWX+1
     BCS J_23
     JSR USTWSK
     JSR USADZN
     LDY #7
L_18 LDA (ADDR3),Y
     STA (ADDR),Y
     DEY
     BPL L_18
     JSR POZNAK
J_23 LDX #27
     LDY #17
     JSR USADOP
     LDY #10
     JSR NEGUJ
     JMP LOOP

* Upewnij siê !!!
SURE LDX <SUR_M
     JSR DSP_MSG
     LDA #255		; (NIC)
     STA KEY
L_8  LDA KEY
     CMP #255		; (NIC)
     BEQ L_8
     LDX #255
     STX KEY
     CMP #43		; (KLAWISZ y)
     BNE WRLOOP
     LDX <YES_M
     JMP DSP_MSG

* Wróæ do pêtli g³ównej
WRLOOP PLA		; (KLAWISZ N)
     PLA
     LDX <NEG_M
     JSR DSP_MSG
     JSR USCHG
     JMP LOOP

* W³¹cz ekra CHG
USCHG  LDX <DLIST
     LDY >DLIST
     STX DLADR
     STY DLADR+1
     LDA #STRZALKA
     LDX POZSX
     LDY POZSY
     JSR _PMXY
     LDA #WSKAZNIK
     LDX POZWX
     LDY POZWY
     JSR _PMXY
     RTS

* Wypisz tekst
* Odszukaj text nr. .X
DSP_MSG LDY #0
FM0  DEX
     BMI MOUT
FMES LDA TEKSTY,Y
     INY
     CMP #EOL
     BNE FMES
     BEQ FM0		; (JMP)

* Wypisz
MOUT TXA
     LDX #CHN0
     STA IO_LEN,X
     CLC
     TYA
     ADC DTAA
     STA IO_ADR,X
     LDA #0
     STA IO_LEN+1,X
     ADC DTAA+1
     STA IO_ADR+1,X
     LDA #PUTT
     STA IO_COM,X
     JMP CIOV

* Pobierz nazwê pliku
FILENAME LDX <NUL_M
     JSR DSP_MSG
     LDX #255
     STX KEY
     LDY NAMA
     JSR MOUT
     LDX <FIL_M

* POBIERZ TEKST
GET_TE JSR DSP_MSG

     LDX #CHN0
     LDA #GETT
     STA IO_COM,X
     LDA TXTA
     STA IO_ADR,X
     LDA TXTA+1
     STA IO_ADR+1,X
     STA IO_LEN+1,X
     JMP CIOV

* CIOV z sprawdzeniem koñca pliku
MCIO JSR CIOV
     BPL IOOK
     CPY #EOF
     BEQ IOOK
ERROR LDA #0
     STY FR0
     STA FR0+1
     JSR IFP
     JSR FASC
     LDX #3
L_10 LDA LBUFF,X
     AND #%01111111
     STA ERRNR,X
     DEX
     BNE L_10
     LDX <ERR_M
     JSR DSP_MSG
     LDY #255
     STY KEY
L_9  CPY KEY
     BEQ L_9
     STY KEY
     RTS
IOOK LDY #1
     RTS

* Zamknij kana³
CLOSE LDX #CHN1
     LDA #12
     STA IO_COM,X
     JSR CIOV
     LDA #3
     STA SKCTL		; CICHO!!!
     TYA
     BMI ERROR
     RTS

* Otwórz kana³
OPEN LDX #CHN1
     STA IO_MOD,X
     LDA #3
     STA IO_COM,X
* Szukaj dwukropka
     LDY #':'
     CPY TEXT+1
     BEQ SETI
     CPY TEXT+2
     BEQ SETI
     LDA #0
* Ustaw iocb
SETI CLC
     ADC DNMA
     STA IO_ADR,X
     LDA #0
     ADC DNMA+1
     STA IO_ADR+1,X
     LDA SKCTL
     AND #%00001000	; (SHIFT)
     ASL @
     ASL @
     ASL @
     ASL @
     STA IO_AUX,X
     JSR CIOV
     BMI ERROR
     LDA IO_MOD,X
     ORA #3
SETDAT STA IO_COM,X
     LDA <LENZZ
     STA IO_LEN,X
     LDA >LENZZ
     STA IO_LEN+1,X
     LDA <ADRZZ
     STA IO_ADR,X
     LDA >ADRZZ
     STA IO_ADR+1,X
     TYA
     RTS

	ICL 'CHG0PROC.ASM'

* Dane adresowe
ADWG   DTA B(0),B(DEFINED)
DTAA   DTA A(TEKSTY)
TXTA   DTA A(TEXT)
DNMA   DTA A(DNAM)
NAMA   DTA A(TEXT-TEKSTY)

* Numery komunikatow
NUL_M  EQU 0
SUR_M  EQU 1
ERR_M  EQU 2
LOA_M  EQU 3
FIL_M  EQU 4
YES_M  EQU 5
NEG_M  EQU 6
SAV_M  EQU 7
DOS_M  EQU 8
DIR_M  EQU 9
CLA_M  EQU 10
ROM_M  EQU 11
SET_M  EQU 12
USE_M  EQU 13
KEY_M  EQU 14

TEKSTY DTA B(EOL)
       DTA C'SURE (y/N)',B(EOL)
       DTA $fd,C'I/O ERROR:'
ERRNR  DTA C' ...!',B(EOL)
       DTA C'CLEAR & LOAD CHARACTERS',B(EOL)
       DTA $1c,$1c,C'FILENAME:',B(EOL)
       DTA C'YES!',B(EOL)
       DTA C'NO!',B(EOL)
       DTA C'SAVE CHARACTERS',B(EOL)
       DTA C'QUIT TO DOS',B(EOL)
       DTA C'DIRECTORY',B(EOL)
       DTA C'CLEAR ALL CHARACTERS',B(EOL)
       DTA C'& COPY FROM ROM',B(EOL)
       DTA C'SET ADDRES OF LOADING:',B(EOL)
       DTA C'Use joystick (left,right,fire).',B(EOL)
       DTA C'Press fire or any key!',B(EOL)

DNAM   DTA C'D0:'
TEXT   DTA C'D0:NONAME00.FNT'
       DTA B(EOL)
BUFOR  ORG *+128
ADEKSA EQU LINIA+140

       RUN START
