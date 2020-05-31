S_ADDIZ  SMB 'S_ADDIZ'
INSTALL  SMB 'INSTALL'
U_GONOFF SMB 'U_GONOFF'
I_GETTD  SMB 'I_GETTD'
COMTAB   SMB 'COMTAB'

* Atari OS
RTCLOK   EQU $0012
FMSZPG   EQU $0043
LOMEM    EQU $0080
VVBLKD   EQU $0224
SDLSTL   EQU $0230
SDLSTH   EQU $0231
INVFLG   EQU $02B6
SHFLOK   EQU $02BE
PORTB    EQU $D301
SETVBLV  EQU $E45C
XITVBV   EQU $E462

* Adresy SDX
S_VER    EQU $0701
JEXTSW   EQU $07F7

         BLK SPARTA $580

         LDA S_VER     ;Ustalenie wersji SDX
         AND #$0F
         ORA #$30
         STA DSDXVER+2 ;revision
         LDA S_VER
         LSR @
         LSR @
         LSR @
         LSR @
         ORA #$30
         STA DSDXVER   ;ver no.

;         LDA PORTB
;         PHA
;         AND #$FE
;         STA PORTB     ;wylaczenie OSa

;         LDY #$05
;L05A1    LDA L05CC,Y   ;przepisanie 2 skokow
;         STA $FFC6,Y
;         DEY
;         BPL L05A1
;         PLA
;         STA PORTB

         LDA VTDMAIN
         LDX VTDMAIN+1
         JSR S_ADDIZ    ;dodanie po resecie

         LDX #$0A
         STX COUNTVBL
         LDA #$00
         STA CLKFAIL
         STA ST_ONOFF
         DEC INSTALL

         JMP PROCPARM

VTDMAIN  DTA V(TDMAIN)

;L05CC    JMP L05E4
;         JMP L0649

************************
         BLK RELOC MAIN   ; $5D2

TDMAIN   LDA #$00         ;przy resecie
         STA CLKFAIL
         LDY ST_ONOFF
         JMP CHKONOFF

PROCPARM JSR U_GONOFF     ;C=ON/OFF, U_FAIL
         LDA #$00
         ROL @            ;zlapanie C
         TAY
         STY ST_ONOFF

CHKONOFF CPY #$00
         BEQ TURNOFF

* Wlacz TD
         LDY PTDVBPRO
         LDX PTDVBPRO+1
         JSR CHGVBLK
         CLC
         RTS

* Wylacz TD
TURNOFF  LDY <XITVBV
         LDX >XITVBV
         JSR CHGVBLK

         LDA SDLSTL   ;Przywroc jesli
         CMP PNEWDL   ;te same adresy
         BNE XTURNOFF ;DL
         LDA SDLSTH
         CMP PNEWDL+1
         BNE XTURNOFF

         SEC          ;Przywrocenie
         LDA ADROLDDL ;starej DL
         SBC #$03
         STA SDLSTL
         STA FMSZPG
         LDA ADROLDDL+1
         SBC #$00
         STA SDLSTH
         STA FMSZPG+1

         LDY #$06
NEXTDLB  LDA (FMSZPG),Y
         INY            ;Szukamy
         CMP #$41       ;JMP+VBLK
         BNE NEXTDLB
         LDA SDLSTL     ;Przepisujemy
         STA (FMSZPG),Y ;z niego
         INY            ;adres
         LDA SDLSTH     ;poczatku DL
         STA (FMSZPG),Y
XTURNOFF CLC
         RTS

* Zmiana wektora VB
CHGVBLK  LDA #07       ;VVBLKD
         JMP SETVBLV

;         LDA RTCLOK+2
;WAITCLK  CMP RTCLOK+2
;         BEQ WAITCLK
;         STY VVBLKD
;         STX VVBLKD+1
;         RTS

PTDVBPRO DTA V(TDVBPROC)
PNEWDL   DTA V(NEWDL)

************************
PREPINFO BIT CLKFAIL
         BPL L0650
         SEC
         RTS

L0650    DEC CLKFAIL
         STX PUTCHAR+2  ;Zapamietanie adresu
         STY PUTCHAR+1  ;info
         JSR I_GETTD
         BCC TIMEDATE
         INC CLKFAIL    ;Gdy nie da sie odczytac zegara
         RTS

* Przygotowanie daty i czasu

TIMEDATE LDA COMTAB+$0F ;rok
         SEC
         SBC #84
         BCS SKIPY2K ;Y2K
         ADC #$64    ;Y2K
SKIPY2K  STA YEARIDX+1
         PHA         ;Y2K
         AND #$03    ;Y2K
         TAY         ;Y2K
         PLA         ;Y2K
         LSR @
         LSR @
         SEC         ;Y2K CLC
YEARIDX  ADC #$00
         ADC COMTAB+$0D ;dzien
         LDX COMTAB+$0E ;mies
         ADC MONTHOFS-1,X

         CPY #$00    ;Y2K
         BNE SKIPY2K1        ;Y2K
         CPX #$03    ;Y2K
SKIPY2K1 SBC #$07    ;Y2K
         BCS SKIPY2K1 ;Y2K
         ADC #$08    ;Y2K

         ;Y2K TAY
         ;Y2K LDA COMTAB+$0F
         ;Y2K AND #$03
         ;Y2K BNE L0685
         ;Y2K CPX #$03
         ;Y2K BCC L0686
;Y2K L0685    INY
;Y2K L0686    TYA
;Y2K L0687    CMP #$07
;Y2K          BCC L068F
;Y2K          SBC #$07
;Y2K          BCS L0687
;Y2K L068F    ADC #$02  ;i mamy w A numer dnia tygodnia
         PHA

         LDY #$00  ;Zaczynamy drukowanie od poz.0

         JSR PRNSEP
         LDA SHFLOK
         BEQ SMALL
         LDA #'A'
         DTA B($2C)
SMALL    LDA #'a'
         LDX INVFLG
         BEQ NORMAL
         ORA #$80     ;zrob inverse
NORMAL   JSR PUTCHAR
         JSR PRNSEP

         PLA       ;W A nr dnia tygodnia
         TAX
         LDA DAY1-1,X
         JSR PUTCHAR
         LDA DAY2-1,X
         JSR PUTCHAR
         LDA DAY3-1,X
         JSR PUTCHAR
         JSR PRNSPACE
         LDA COMTAB+$D ;dzien
         JSR L075C
         JSR PRNMINUS
         LDX COMTAB+$E ;mies
         LDA MONTH1-1,X
         JSR PUTCHAR
         LDA MONTH2-1,X
         JSR PUTCHAR
         LDA MONTH3-1,X
         JSR PUTCHAR
         JSR PRNMINUS
         LDA COMTAB+$F ;rok
         JSR L0759

         JSR PRNSEP
         LDA COMTAB+$10 ;hh
         JSR L075C
         JSR PRNCOLON
         LDA COMTAB+$11 ;mm
         JSR L0759
         JSR PRNCOLON
         LDA COMTAB+$12 ;ss
         JSR L0759

         CLC
         INC CLKFAIL
         RTS

MONTHOFS DTA B($00,$03,$03,$06,$01,$04)
         DTA B($06,$02,$05,$00,$03,$05)

* Polskie
;DAY1     DTA C'SNPWSCP'
;DAY2     DTA C'oiotrzi'
;DAY3     DTA C'benoowa'
;MONTH1   DTA C'SLMKMCLSWPLG'
;MONTH2   DTA C'tuawaziirair'
;MONTH3   DTA C'ytrijepezzsu'

* Angielskie
DAY1     DTA C'SSMTWTF'
DAY2     DTA C'auouehr'
DAY3     DTA C'ynnedui'
MONTH1   DTA C'JFMAMJJASOND'
MONTH2   DTA C'aeapauuuecoe'
MONTH3   DTA C'nbrrynlgptvc'

L0759    LDX #$FF
         DTA B($2C) ; Bit
L075C    LDX #$00
L075E    STX STORAGE+$29
         LDX #$FF
         SEC
L0764    INX
         SBC #$0A
         BCS L0764
         ADC #$0A
         PHA
         TXA
         BNE L0776
         BIT STORAGE+$29
         BMI L0776
         ORA #$10
L0776    JSR L077C
         PLA
         AND #$0F
L077C    EOR #$30
PUTCHAR  STA $FFFF,Y
         INY
         RTS

PRNSEP   LDA #'|'
         DTA B($2C)
PRNSPACE LDA #' '
         DTA B($2C)
PRNCOLON LDA #':'
         DTA B($2C)
PRNMINUS LDA #'-'
L078B    CLC
         BCC PUTCHAR

NEWDL    DTA B($70,$70)
         DTA B($30,$42)
         DTA V(STORAGE)
         DTA B($01)
ADROLDDL DTA V($0000)

TDLINE   DTA C'SpartaDOS X '
DSDXVER  DTA C'4.2'
TDLINFO  DTA B($00,$00,$00,$00)
         DTA B($00,$00,$00,$00)
         DTA B($00,$00,$00,$00)
         DTA B($00,$00,$00,$00)
         DTA B($00,$00,$00,$00)
         DTA B($00,$00,$00,$00)
         DTA B($00,$00)

PTDLINFO DTA V(TDLINFO)

* Co 30 VBLK
DOTDLINE LDA PORTB
         PHA
         LDA COMTAB-$16 ;Indeks banku pamieci EXT
         JSR JEXTSW     ;Przelaczenie na niego

         LDX PTDLINFO+1
         LDY PTDLINFO
         JSR PREPINFO

         LDX #$00
         LDA #$0F
         LDY #$00
         JSR MOV2STOR
         LDA #$19
         LDY #$0F
         JSR MOV2STOR
;         LDA #$80
;         STA STORAGE+$27
         PLA
         STA PORTB    ;Przywrocenie ustawienia pamieci
         RTS

CHKINV   CMP #$80
         BCC L07FD  ;mala!

TMPCHAR  DTA B(0)

* Przepisanie bajtow do STORAGE + zmiana kodow
MOV2STOR PHA
         LDA TDLINE,Y
         STA TMPCHAR
         AND #$7F
         CMP #$60
         BCS L07FD   ;mala litera?
L07F7    SBC #$1F
         BCS L07FD
         ADC #$60
L07FD    BIT TMPCHAR
         BMI CHSCREEN
         ORA #$80    ;ustaw inv.
CHSCREEN STA STORAGE,X
         INY
         INX
         PLA
         SEC
         SBC #$01
         BNE MOV2STOR
         RTS

TDVBPROC CLD
         DEC COUNTVBL
         BNE XTDVBPRO  ;Czy licznik sie wyzerowal

         LDA #25 ;30       ;Licznik od nowa
         STA COUNTVBL

         JSR DOTDLINE

         LDA SDLSTL    ;Czy zmieniono DL ?
         CMP PNEWDL
         BNE DLCHANGE
         LDA SDLSTH
         CMP PNEWDL+1
         BEQ XTDVBPRO

DLCHANGE LDA LOMEM     ;To gdy zmieniono DL
         PHA           ;Zapamietanie LOMEM
         LDA LOMEM+1   ;(bedzie uzywane jako TMP)
         PHA

         LDA SDLSTL    ;Przygotowanie DL
         STA LOMEM
         CLC
         ADC #$03
         STA ADROLDDL  ;Zmiana adresu skoku
         LDA SDLSTH    ;na nowa DL
         STA LOMEM+1
         ADC #$00
         STA ADROLDDL+1

         LDY #$06
NEWDLBYT LDA (LOMEM),Y
         INY           ;Szukamy
         CMP #$41      ;JMP+VBLK w Y
         BNE NEWDLBYT

         LDA PNEWDL    ;i przepisujemy adres naszej DL
         STA SDLSTL    ;do rejestru
         STA (LOMEM),Y ;i do skoku
         INY
         LDA PNEWDL+1
         STA SDLSTH
         STA (LOMEM),Y

         PLA           ;Przywracamy poprzednie MEMLO
         STA LOMEM+1
         PLA
         STA LOMEM
XTDVBPRO JMP XITVBV

************************

         BLK EMPTY $2C MAIN ; Num:2 Mem:$80
STORAGE  EQU *-$2C
CLKFAIL  EQU STORAGE+$28    ; licznik blednych odczytow zegara
COUNTVBL EQU STORAGE+$2A    ; licznik przerwan VBLK
ST_ONOFF EQU STORAGE+$2B    ; stan ON/OFF

         BLK UPDATE ADDRESS
         BLK UPDATE SYMBOLS
         BLK UPDATE NEW PROCPARM '@TD2'
         BLK UPDATE NEW PREPINFO 'I_FMTTD'

         END
