
iocb	= $340
ciov	= $e456

	.extrn printf .proc		; procedura PUTLINE z biblioteki STDIO

	.public	open, close, read


	.RELOC

/*
  OPEN

  Command:
          $03 - OPEN

  Example:
          open channel , #command(4 or 8) , #file_name
          open #$10 , #4 , #file_name

          file_name dta c'...',$9b
          channel = $10,$20,$30 ...
*/
open	.proc (.byte chn+1,com+1 .word fname) .var

chn	ldx	#0

	mva	#3	iocb+2,x	; CIO command ; $03 - OPEN

	mwa	fname	iocb+4,x	; file name

com	mva	#0	iocb+$a,x	; $04 - READ ; $08 - WRITE
 
	jmp	pciov

fname	.word

	.endp


/*
  CLOSE

  Command:
          $0C - CLOSE

  Example:
          close channel
          close #$10

          channel = $10,$20,$30 ...
*/
close	.proc (.byte x) .reg

	mva	#$c	iocb+2,x	; CIO command

	jmp	pciov

	.endp


/*
  READ

  Command:
          $05 - GET RECORD
          $07 - GET CHARACTER
          $09 - PUT RECORD
          $0B - PUT CHARACTERS

  Example:
          read channel , #command , #buffer , #length
          read #$10 , command , buffer , length

          channel = $10,$20,$30 ...
*/
read	.proc (.byte chn+1,com+1 .word buf,len) .var

chn	ldx	#0

com	mva	#0	iocb+2,x	; CIO command

	mwa	buf	iocb+4,x	; buffer address

	mwa	len	iocb+8,x	; length

	jmp	pciov

buf	.word
len	.word

	.endp


/*
  PCIOV
  
  regY = status
*/
pciov	.proc

        jsr	ciov
 
        sty	status

        bmi	err
        rts

err	cpy	#136		; na b³¹d 136 nie reagujemy
	beq	quit

	printf
	dta 'I/O Error %',$9b,$00
	dta a(status)

quit	ldy	status
        rts

status	dta a(0)

	.endp


