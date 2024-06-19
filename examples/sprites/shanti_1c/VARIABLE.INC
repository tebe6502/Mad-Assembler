; -*- text -*-
;fuer den WiNiFe-Compiler
;cdw by 'The Atari Team' 1989-2019

; These are lot of used global variables for Atari XL Computer
; But not all!

;  .LOCAL

; Here the most important addresses only

BOOT=9    ; 1
DOSVEC=10 ; 2
DOSINI=12 ; 2

APPMHI=14 ; 2 bytes, after this we can begin with display list or graphics memory
POKMSK=16
; bit dec hex
;   7 128 $80 - Breakkey is possible (BRKKY: 566,567)
;   6  64 $40 - key interrupt possible
;   2   4 $04 - Interrupt 4. pokey timer is possible
;   1   2 $02 - Interrupt 2. pokey timer is possible
;   0   1 $01 - Interrupt 1. pokey timer is possible

BRKKEY=17
RTCLOK=18 ; 18,19,20 3 byte Timer will increase every 1/50s (PAL)

STATUS=48

CHKSUM=49

SOUNDR=65 ; 0 means no sound at disk IO

CRITIC=66 ; !0 means no second VBI (faster ~50000 cycles less)

ERRNO=73

ATRACT=77 ; will increment every 5s, >128 color switch begin

; Addresses from 80 - 122 will used by screen editor
TMPCHR=80
HOLD1=81
LMARGN=82 ; left start position
RMARGN=83 ; right margin

ROWCRS=84 ; row position of the cursor
COLCRS=85 ; 85,86 colum position of the cursor

DINDEX=87 ; type of graphics
SAVMSC=88 ; address of the left upper corner of the screen
; The 4 line text window is TXTMSC (660,661)

; Address 90-98 are used by drawto/fill
OLDROW=90
OLDCOL=91 ; 91,92

OLDCHR=93
OLDADR=94 ; 94,95

; NEWROW=96
; NEWCOL=97 ; 97,98

FKDEV=96 ; 96,97 Pointer to definition table of function keys (since 1200XL)

PALNTS=98 ; 1 means PAL else NTSC

LOGCOL=99 ; logical line position (max 3 lines)

ADRESS=100 ; 100,101
MLTTMP=102 ; 102,103
SAVADR=104 ; 104,105

RAMTOP=106 ; upper RAM memory page real adress is RAMTOP * 256

BUFCNT=107 ; count of values in logical screen row

BUFSTR=108
BITMSK=110
SHFAMT=111 ; for pixel shift in pixel graphics
ROWAC=112 ; 112,113 calc register for plot/drawto
COLAC=114 ; 114,115
ENDPT=116 ; 116,117
DELTAR=118
DELTAC=119 ; 119,120
KEYDEF=121 ; key definition table
SWPFLG=123
HOLDCH=124
INSDAT=125
COUNTR=126 ; 126,127 line draw counter

; -----------------------------
; Address from 128 to 202 are used by Atari Basic

FREE=203 ; 203-211 in Atari Basic

; ----------------------------------------------------------------
; Internal zero page registers used by wnf-compiler
; ----------------------------------------------------------------
; we try to use only the 42 bytes of floating-point-register
;
BININT = 212                   ; return value for Atari Basic

@AUX  =   212

@PUTARRAY = 212                 ; 2 212 duerfen innerhalb von Expressions nicht ueberschrieben werden
@GETARRAY = @PUTARRAY+2         ; 2 214 dito ; used in MACROS.INC

; Math values (mult, div, modulo)
@OP   =   @AUX + 4              ; 4 216
; Ergebnis, Produkt, REST
@PRODUKT = @AUX+8               ; 2 220 ; used by IMULT
@REST =   @AUX+8                ; 2 222 ; used by IDIV/IMODULO

@ERG  =   @AUX+10               ; 2 224 ; used by conditions
@ISMODULO = @AUX+12             ; 1 226 ; used by IMODULO
@NEGATIV = @AUX+13              ; 1 227 ; used by IDIV/IMODULO

; working registers will always overwrite! Do not expect they will not changed after function call
@REG  =   @AUX+14               ; 27 bytes (13 word-Register) 226

@PRINTF_TYPE = 252
@COLOR_REGISTER = 253
@HEAP_PTR = 254                 ; 2 bytes

;
; -----------------------------
VDSLST = $200 ; Address of Displaylist interrupt
VBREAK = $206 ; if BRK (in Assembler) occured
VKEYBD = $208 ; key interrupt

; Interrupt counters
CDTMV1 = 536
CDTMV2 = 538
CDTMV3 = 540

; For Interrupts, many more then every 1/50s
VTIMR1 = 528 ; Pokey Interrupt 1 AUDF1 ist der Zaehler STIMER muss beschrieben werden
VTIMR2 = 530 ; Pokey Interrupt 2
VTIMR4 = 532 ; Pokey Interrupt 4

VIMIRQ = 534
VVBLKI = 546 ; System VBI   Interrupt vektor (SETVBV with A=6, Address -> (Y,X), at exit JMP SYSVBV
VVBLKD = 548 ; Deferred VBI Interrupt vektor (SETVBV with A=7, Address -> (Y,X), at exit JMP XITVBV
CDTMA1 = 550
CDTMA2 = 552 ; (SETVBV with A=2, Address -> (Y,X), at exit RTS

SRTIMR = 555 ; Tastaturwiederholfrequenz

SDMCTL = 559 ; Shadow register of ANTIC DMA Controller
; 32 - DMA for display list
; 16 - single line Player Missiles
;  8 - DMA Player
;  4 - DMA Missiles
;  3 - wide screen (48 bytes)
;  2 - normal screen width (40 bytes)
;  1 - small screen width (32 bytes)
;  0 - no screen

SDLSTL=560 ; Shadow register of current Displaylist

BRKKY=566 ; vektor called if break key is pressed

COLDST=580 ; =0 heiﬂt warm-reset, sonst cold-reset, default ist 255

GPRIOR=623 ; Shadow register GTIA Chip (bit 7,6 graphics 11,10,9) other player missiles
; 192 - 16 color one hue (712 is hue)
; 128 - 9 colors (704-712 colors) there are no more color registers in HW
;  64 - 16 hue one color (712 is color)
;  32 - overlap player third color
;  16 - 4 missiles will be 5th player (711 is color)
;   8 - screen 0-1, player 0-3, screen 2-3, background
;   4 - screen 0-3, player 0-3, background
;   2 - player 0-1, screen 0-3, player 2-3, background
;   1 - player 0-3, screen 0-3, background

TXTROW=656
TXTCOL=657 ;2 bytes
TINDEX=659
TXTMSC=660 ;2 bytes

PCOLR=704
; COLOR=708

KRPDEL=729 ; Tastatur Ansprechfrequenz
KEYREP=730 ; Tastatur Wiederholfrequenz

NOCLIK=731 ; 0=click other value, no click

RUNAD=736
INITAD=738

CHACT=755  ; Shadow register of CHACTL
CHBAS=756  ; Shadow register of font CHBASE
CH=764     ; last pressed key, to reset last key insert value 255
; bit 7 set, control pressed
; bit 6 set, shift pressed
; other bit key code

CASBUF=1121 ; 130 Bytes, die eigentlich als Cassettenbuffer verwendet wurden, nutzen wir in @input und @readline

LBUFF=$580 ; wird eigentlich von FloatingPoint verwendet.

; -----------------------------
; OS-Handler Addresses
EDITRV = $E400  ; Editor
SCRENV = $E410  ; Screen
KEYBDV = $E420  ; Keyboard

; Input over Keyboard only

ICHID =   832+0 ; Handleridentifizierung
ICDNO =   832+1 ; Devicenummer e.g. D1:
ICCOM =   832+2 ; Befehlsbyte
ICSTA =   832+3 ; Status
ICBADR =  832+4 ; :2 Adresse Filebuffer oder Filename
ICPUT =   832+6 ; :2
ICBLEN =  832+8 ; :2 Laenge des Buffers
ICAUX1 =  832+10 ; nach Open nicht verwenden
ICAUX2 =  832+11 ; nach Open nicht verwenden
ICAUX3 =  832+12
ICAUX4 =  832+13
ICAUX5 =  832+14
ICAUX6 =  832+15

CIOV  =   $E456

CIO_OPEN	= 3
CIO_GETTEXT	= 5
CIO_GETDATA	= 7
CIO_PUTTEXT	= 9
CIO_PUTDATA	= 11
CIO_CLOSE	= 12
CIO_GETSTATUS	= 13
CIO_READ	= 4
CIO_WRITE	= 8
CIO_DIR	= 6

; Interrupts -----
SETVBV=$E45C
SYSVBV=$E45F
XITVBV=$E462
