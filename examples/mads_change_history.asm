; MADS Change History Reference
;
; This file provides code samples to verify the additions, fixes and changes in the different MADS versions.
;

    org $2000
    opt h-

    .macro m_version
    .byte 10,13,':1',10,13
    .endm

; TODO: Incomplete for higher versions

    ;==================================================================
    m_version "https://www.wudsn.com/tmp/projects/mads/en/#2.0.5"

    .proc v2.0.5
    
    .proc unused
    
    .array tab .byte
    1,2,3
    .enda
    
    .endp

    .struct stru

    .array tab[3]
    .enda

    .ends
        
    .endp


    ;==================================================================
    m_version "https://www.wudsn.com/tmp/projects/mads/en/#2.0.4"

    .proc v2.0.4
;    .db $00    ;removed
;    .dw $00    ;removed

    .dbyte $1234
    .put[0]=1
    .put[0]=2
    .put[0]=3
    .put[0]=4
    .byte .get[0]    ;1 byte
    .word .wget[0]   ;2 bytes
    .long .lget[0]   ;3 bytes
    .long .dget[0]   ;4 bytes

tmp = $80
posx = $82
ptr2 = $84
ptr4 = $86

    adw (tmp),y #1 posx
    adw (tmp),y ptr2 ptr4
    
    .endp

    ;==================================================================
    m_version "https://www.wudsn.com/tmp/projects/mads/en/#2.0.2"

    .proc v2.0.2

    .sb "Test"
    .sb +$80,"Test"
    .sb 1,"Test",'A'

    .endp


    ;==================================================================
    m_version "https://www.wudsn.com/tmp/projects/mads/en/#2.0.1"

    .proc v2.0.1

    .array word_array .word
    1,2,3
    .enda

    .array long_array .long
    1,2,3
    .enda

    .array dword_array .dword
    1,2,3
    .enda

    .endp

    ;===================================================================
; TODO: Incomplete for lower versions

    .proc v1.9.5  ;https://www.wudsn.com/tmp/projects/mads/en/#1.9.5
; TODO: Incomplete

line0
line1
line2
line3

ladr1 :4 dta l(line:1)
hadr1 :4 dta h(line:1)

ladr2 :4 dta l(line%%1)
hadr2 :4 dta h(line%%1)
    .endp

    