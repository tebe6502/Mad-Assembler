;------------------------------------------------
; "Exclamation mark" Loader - Debug GienekP
; F2ED => C5A7
; F385 => C642
; F6A4 => F2B0
; F6E2 => F302
;------------------------------------------------

CASINI   = $02   ; wektor inicjacji po odczycie z kasety
BOOTM    = $09   ; znacznik odczytu wstępnego
DOSVEC   = $0A   ; wektor startowy programu dyskowego
TMPVAR   = $D0   ; tymczasowa zmienna
LMARGIN  = $52   ; lewy margines obrazu
ROWCRS   = $54   ; pionowa pozycja kursora
COLCRS   = $55   ; pozioma pozycja kursora
COLDST   = $0244 ; znacznik zimnego startu systemu
RUNAD    = $02E0 ; adres uruchomienia
INITAD   = $02E2 ; adres inicjalizacji
CRSINH   = $02F0 ; znacznik widoczności kursora
KBCODES  = $02FC ; rejestr-cień KBCODE
ICCMD    = $0342 ; kod rozkazu operacji I/O
ICBUFA   = $0344 ; adres bufora danych
ICBUFL   = $0348 ; długość bufora danych
ICAX1    = $034A ; rejestr pomocniczy dla operacji I/O
CARTTEST = $BFFC ; ROM 00 dla cartridge
PACTL    = $D302 ; rejestr kontroli portu A
JCIOMAIN = $E456 ; skok do CIOMAIN


DERRMSG   = $F381 ; OS-A BOOT ERROR
;DERRMSG   = $C43D ; OS-B BOOT ERROR
EOUTCH   = $F6A4 ; OS-A zapis znaku do edytora
;EOUTCH   = $F2B0 ; OS-B zapis znaku do edytora
KGETCH   = $F6E2 ; OS-A pobranie znaku z klawiatury
;KGETCH   = $F302 ; OS-B pobranie znaku z klawiatury

CRAZY1   = $F2ED ; OS-A końcówka proc $C58B BOOT - wstępny odczyt z dyskietki
;CRAZY1   = $C5A7 ; OS-B końcówka proc $C58B BOOT - wstępny odczyt z dyskietki
CRAZY2   = $F385 ; OS-A PUTLINE - wyświetlenie linii tekstu
;CRAZY2   = $C642 ; OS-B PUTLINE - wyświetlenie linii tekstu
CRAZY3   = $F39C ; OS-A RTS
;CRAZY3   = RETURN ; OS-B RTS


;------------------------------------------------

         OPT h-F+
         
;------------------------------------------------
         ORG $0700

         ;
         ; HEADER
         ;
HEADER   dta $20,$05,<HEADER,>HEADER,<RESTART,>RESTART
;------------------------------------------------
         ORG $0706

         ;
         ; RUN
         ;
RUN      JSR INIT
HIDE     JSR DECRYPT; was JMP CRAZY1
;------------------------------------------------
         ORG $070C

         ;
         ; MAIN (after EOR $FF)
         ;
MAIN     LDA #$00
         TAX
         TAY
@        LDA CARTTEST
         BNE MJ1
         INX
         BNE @-
         INY
         BNE @-
         LDA #$01
         STA CARTTEST
;------------------------------------------------
         ORG $0720

         ;
         ; RESTART
         ;
RESTART  LDA CARTTEST
         BEQ @+
MJ1      CLC
         PLA
         PLA
         JMP PROC6
@        LDA #$01
         STA CRSINH
         LDA #$07
         STA.W LMARGIN
         LDA #$0A
         STA.W COLCRS
         STA.W ROWCRS
         LDX #<MSG
         LDY #>MSG
         JSR CRAZY2
@        JSR KGETCH
         CMP #$1B
         BNE @-
         PLA
         PLA
         JMP PROC2
;------------------------------------------------
         ORG $0750

         ;
         ; PROC6
         ;
PROC6    LDA #<PROC2
         STA.W DOSVEC
         LDA #>PROC2
         STA.W DOSVEC+1
         NOP
;------------------------------------------------
         ORG $075B

         ;
         ; PROC2
         ;
PROC2    LDA #$02
         STA.W LMARGIN
         LDA #$00
         STA CRSINH
         LDA #$7D
         JSR EOUTCH
         JSR PROC5
         LDX #$10
         LDA #$03
         STA ICCMD,X
         LDA #<DEVICE
         STA ICBUFA,X
         LDA #>DEVICE
         STA ICBUFA+1,X
         LDA #$04
         STA ICAX1,X
         LDA #$80
         STA ICAX1+1,X
         LDA #$0C
         STA KBCODES
         JSR JCIOMAIN
         LDA #$00
         STA T0936
         LDX #$10
         LDA #<T0934
         STA ICBUFA,X
         LDA #>T0934
         STA ICBUFA+1,X
         LDA #$02
         STA ICBUFL,X
         LDA #$00
         STA ICBUFL+1,X
         LDA #$07
         STA ICCMD,X
         JSR JCIOMAIN
         BMI PROC8
;------------------------------------------------
         ORG $07B5

         ;
         ; PROC9
         ;
PROC9    LDX #$10
         LDA #<T0930
         STA ICBUFA,X
         LDA #>T0930
         STA ICBUFA+1,X
         LDA #$04
;------------------------------------------------
         ORG $07C3

         ;
         ; PROC10
         ;
PROC10   STA ICBUFL,X
         LDA #$00
         STA ICBUFL+1,X
         JSR JCIOMAIN
         BPL PJ1
         CPY #$88
         BNE PROC8
         JSR PROC5
         JMP PROC7
;------------------------------------------------
         ORG $07DA

         ;
         ; PROC8
         ;
PROC8    TYA
         PHA
         JSR PROC5
         PLA
         TAY
         BEQ PJ1
         JSR DERRMSG
         JMP PROC7
PJ1      LDA T0936
         BNE @+
         LDA T0930
         STA RUNAD
         LDA T0930+1
         STA RUNAD+1
         DEC T0936
@        LDX #$10
         LDA T0930
         STA ICBUFA,X
         PHA
         LDA T0930+1
         STA ICBUFA+1,X
         TAY
         PLA
         INY
         BNE @+
         TAY
         INY
         BNE @+
         LDA T0932
         STA T0930
         LDA T0932+1
         STA T0930+1
         LDA #<T0932
         STA ICBUFA,X
         LDA #>T0932
         STA ICBUFA+1,X
         LDA #$02
         JMP PROC10
@        LDA T0932
         SEC
         SBC T0930
         STA ICBUFL,X
         LDA T0932+1
         SBC T0930+1
         STA ICBUFL+1,X
         LDA T0930+1
         INC ICBUFL,X
         BNE @+
         INC ICBUFL+1,X
@        LDX #$10
         LDA #<RETURN
         STA INITAD
         LDA #>RETURN
         STA INITAD+1
         JSR JCIOMAIN
         BPL @+
         JMP PROC8
@        LDA #$00
         STA COLDST
         LDA #$01
         STA BOOTM
         NOP
         NOP
         NOP
         JSR PROC4
         JSR PROC3
         JSR PROC1
         JMP PROC9
;------------------------------------------------
         ORG $087A

         ;
         ; PROC3
         ;
PROC3    JMP (INITAD)
;------------------------------------------------
         ORG $087D

         ;
         ; PROC7
         ;
PROC7    LDA #$00
         STA COLDST
         LDA #$01
         STA BOOTM
         NOP
         NOP
         NOP
         JSR PROC4
         JSR PROC1
         JMP (RUNAD)
;------------------------------------------------
         ORG $0892

         ;
         ; PROC4
         ;
PROC4    LDA #<CRAZY3
         STA.W CASINI
         LDA #>CRAZY3
         STA.W CASINI+1
         RTS
ENDENCR
;------------------------------------------------
         ORG $089D

         ;
         ; DECRYPT
         ;
DECRYPT  LDA #<MAIN
         STA.W TMPVAR
         LDA #>MAIN
         STA.W TMPVAR+1
LOOP     LDY #$00
         LDA (TMPVAR),Y
         EOR #$00        ; was EOR #$FF
         STA (TMPVAR),Y
         INC.W TMPVAR
         BNE @+
         INC.W TMPVAR+1
@        LDA.W TMPVAR+1
         CMP #>ENDENCR
         BNE LOOP
         LDA.W TMPVAR
         CMP #<ENDENCR-1
         BNE LOOP
         LDA #$00
         STA.W TMPVAR
         STA.W TMPVAR+1
         NOP
         RTS
;------------------------------------------------
         ORG $08CF

         ;
         ; PROC1
         ;
PROC1    LDA #$3C
         STA PACTL
         RTS
;------------------------------------------------
         ORG $08D5

         ;
         ; REPLACE
         ;
REPLACE  LDA #$20
         STA HIDE
         LDA #$9D
         STA HIDE+1
         LDA #$08
         STA HIDE+2
         RTS
;------------------------------------------------
         ORG $08E5

         ;
         ; PROC5
         ;
PROC5    LDX #$10
         LDA #$0C
         JSR JCIOMAIN
         LDX #$20
         LDA #$0C
         JSR JCIOMAIN
RETURN   RTS
;------------------------------------------------
         ORG $08F4

         ;
         ; INIT
         ;
INIT     JSR PROC1
         JSR REPLACE
         RTS
;------------------------------------------------
         ORG $08FB

         ;
         ; DEVICE
         ;
DEVICE   dta 'C:',$9B
;------------------------------------------------
         ORG $08FE

         ;
         ; Message
         ;
MSG      dta $FD
         dta 'cartridge installed'*,$1D,$9C 
         dta 'type <ESC> to '*
         dta 'contiue boot'*,$FD,$9B   
;------------------------------------------------
         ORG $0930

         ;
         ; T0930
         ;
T0930    dta $00,$00
;------------------------------------------------
         ORG $0932

         ;
         ; T0932
         ;
T0932    dta $00,$00
;------------------------------------------------
         ORG $0934

         ;
         ; T0934
         ;
T0934    dta $00,$00
;------------------------------------------------
         ORG $0936

         ;
         ; T0936
         ;
T0936    dta $00,$00
;------------------------------------------------
         ORG $0938

         ;
         ; UNUSED
         ;
UNUSED   dta $00,$00,$00,$00,$00,$00,$00,$00
         dta $00,$00,$00,$00,$00,$00,$00,$00
         dta $00,$00,$00,$00,$00,$00,$00,$00
         dta $00,$00,$00,$00,$00,$00,$00,$00
         dta $00,$00,$00,$00,$00,$00,$00,$00
         dta $00,$00,$00,$00,$00,$00,$00,$00
         dta $00,$00,$00,$00,$00,$00,$00,$00
         dta $00,$00,$00,$00,$00,$00,$00,$00
         dta $00,$00,$00,$00,$00,$00,$00,$00
