

dst	= $a010

	
	org $2000
	
dl	dta d'ppp'
	dta $4e,a(dst)
	:101 dta $e
	dta $4e,0,h(dst+$1000)
	:95 dta $e
	dta $41,a(dl)
	
main	mwa #dl $230

	mwa #src inputPointer
	mwa #dst outputPointer
	jsr unlz4
	
	jmp *

src	ins 'koronis.lz4',11		; cut 11 bytes from begining, 6 bytes from end


unlz4
                jsr    xBIOS_GET_BYTE                  ; length of literals
                sta    token
		:4 lsr
                beq    read_offset                     ; there is no literal
                cmp    #$0f
                jsr    getlength
literals        jsr    xBIOS_GET_BYTE
                jsr    store
                bne    literals
read_offset     jsr    xBIOS_GET_BYTE
                tay
                sec
                eor    #$ff
                adc    outputPointer
                sta    source
                tya
                php
                jsr    xBIOS_GET_BYTE
                plp
                bne    not_done
                tay
                beq    unlz4_done
not_done        eor    #$ff
                adc    outputPointer+1
                sta    source+1
                ; c=1
                lda    #$ff
token           equ    *-1
                and    #$0f
                adc    #$03                            ; 3+1=4
                cmp    #$13
                jsr    getLength

@               lda    $ffff
source		equ    *-2

		inw    source

		jsr    store
                bne    @-
                beq    unlz4                           ; zawsze

store           sta    $ffff
outputPointer	equ    *-2

		inw    outputPointer
 
		dec    lenL
                bne    unlz4_done
                dec    lenH

unlz4_done      rts

getLength_next  jsr    xBIOS_GET_BYTE
                tay
                clc
                adc    #$00
lenL            equ    *-1
                bcc    @+
                inc    lenH
@               iny
getLength       sta    lenL
                beq    getLength_next
                tay
                beq    @+
                inc    lenH
@               rts

lenH		.byte    $00

xBIOS_GET_BYTE
		lda $ffff
inputPointer	equ *-2
		inw inputPointer
		rts

	run main