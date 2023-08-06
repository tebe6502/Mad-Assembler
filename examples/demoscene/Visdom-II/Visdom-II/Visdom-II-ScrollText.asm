;
;	">> Halle-External-Scrolltextmodule <<"
;
;	(c/r)_17-03-94_by_JAC!
;
;	Genenrate/Convert_scrolltext_into_special_format.
;	Send_$6000-$6dad_to_"Dat:HalleScroll.txt".
;

tp	equ $80			;ScrollText_Pointer
x1	equ $e0

;================================================================
set	macro
	lda #<\2
	sta \1
	lda #>\2
	sta \1+1
	endm

add	macro
	clc
	lda \1
	adc #<\2
	sta \1
	lda \1+1
	adc #>\2
	sta \1+1
	endm

;================================================================
*	equ $1000
org1	equ *

	set tp,scrtxt
	jsr context
	set tp,credtxt
	jsr context
	set tp,moretxt
	jsr context
finish	lda $d40b
	sta $d01a
	jmp finish

;================================================================
context	ldy #0			;Convert_AscII_to_ScrollChar
contex1	lda (tp),y
	beq contex6		;End_Code
	cmp #$f0		;Color_Code
	bcc contex2
	add tp,3
	jmp contex1
contex2	cmp #$e0		;Speed_Code
	bcs contex5

	ldx #31
contex3	cmp code,x
	beq contex4
	dex
	bne contex3
contex4	stx x1
	txa
	asl
	asl
	clc
	adc x1
	sta (tp),y
contex5	add tp,1
	jmp contex1
contex6	sta (tp),y		;End_flag_found
	rts

code	db ' abcdefghijklmnopqrstuvwxyz!."?  '

end1
;================================================================
*	equ $6000
org2	equ *

scrtxt	db $e2,$f0,$38,$78
	db '  it took some time ... but now it is done'
	db '             ',$e0
	db ' watch!     ',$e0
	db 'and now fasten your seatbelt and get ready for the...    '
	db $e3,' wiggle     ',$e0

	db $e2,$f0,$38,$78
	db 'yo folx! this is jacomo leopardi '
	db 'back with his brandnew production ... '
	db 'especially done for ...       ',$e3,'     '
	db $f0,$48,$48,'"the',$e1,' halle project"          '
	db $e2,32,32,$f0,$78,$f8
	db 'this scroller will be in english but you '
	db 'can press "help" at any time to enter one of the '
	db 'helpscreens. there you will find more information '
	db 'in german!     ',$e4,'         ',$e1
	db 'so let"s go for the greetings now ... no order ... '

	db $e3,'         ',$f0,$08,$18
	db 'paul!      ',$e0
	db ' zap       ',$e0
	db 'herma      ',$e0
	db 'cosmos!     ',$e0
	db 'roger      ',$e0
	db 'erwin      ',$e0
	db 'pille      ',$e0
	db 'rudi!      ',$e0
	db 'kroko      ',$e0
	db ' css       ',$e0
	db ' tlb       ',$e0
	db 'friday!     ',$e0
	db 'pimpf      ',$e0
	db 'nick!      ',$e0
	db 'benjy      ',$e0
	db 'spueli!     ',$e0
	db 'all members of   abbuc      ',$e0
	db 'those funny people in   "cf"      ',$e0
	db 'and also genie ',$e2,'and elder of synenergy!      ',$e3
	db '          '
	db $f0,$28,$c8,$e2
	db 'and so i"ll use this to give a message to you all ... '
	db 'i just can"t stand any more demos with ...            '
	db $f0,$38,$38,$e1
	db '"a ripped four color picture with a ripped vbi tune '
	db 'and a graphics two lms scroller ... of course with a ripped '
	db 'font" !!!           '
	db $f0,$28,$c8,$e2
	db 'what"s up guys ?  '
	db 'aren"t you able of anything else but ripping and coding '
	db 'old laaaaame ugly stuff ?     ',$e4,'         '
	db $f0,$e8,$f8,$e1
	db 'why don"t you try to be inventive ?  make something new '
	db 'or at least try to make something better ...    '
	db $e4,'  please!     ',$e0,'   '
	db $f0,$a8,$d8,$e2
	db 'by the way ... this demo would have been finished before '
	db 'if there had not been this  moth',$e1,'erfucking military '
	db 'service  called "bundeswehr"   ',$e2
	db 'oh guys it really sucks! fortunately there are only '
	db 'two months left ... yeah!  then i"ll go on holiday and '
	db 'afterwards i"ll start my studies in computer science. '
	db 'well i hope so.            '
	db $f0,$38,$b8,$e2
	db 'one more thing ... do you know my first "visdom demo" ?  '
	db 'it was coded two years ago and went around whole europe!  '
	db 'i"had never supposed it to be so successful but i '
	db 'received letters from poland as well as from spain!  '
	db 'and for i hope that this will happen again here are some '
	db 'things i"d like you all to know ...          '
	db $f0,$88,$98
	db 'i"m always looking for cool tunes on xl since i"m a coder '
	db 'and not a musician. if you"ve composed any please send it '
	db 'to the adress mentioned in one of the helpscreens.  '
	db 'the tune you"re listenling to at the moment was especially '
	db 'composed for this demo by "karsten schmitt". thank you css! '
	db '             '

	db $f0,$38,$48,$e1
	db 'some final words ...    ',$e2
	db 'there have been some "cracked" versions of my first '
	db '"visdom demo". done by some silly henbrained simple minded '
	db 'motherfuckers like "haegar weller" who only know how to '
	db 'use a stupid diskmonitor to change texts!   '
	db 'if you ever get such a version please send it to me. '
	db '       ',$e4
	db '         ',$e2
	db 'are you interested in an xl development system using an '
	db 'amiga ?  i have written such a system! i use it for '
	db 'all my coding on xl. for further information just '
	db 'contact me!  my adress appears by pressing "help". '
	db 'i"m also looking for good packers and crunchers!  '
	db 'i already have "magnus cruncher five". how about '
	db 'the source or the algorythm of "lharc" ??!!          '
	db $f0,$38,$38,$e3
	db 'xl rules! ... army sucks! ... '
	db 'xl rules! ... army sucks! ... '
	db 'xl rules! ... army sucks! ... '
	db '                       '
	db $f0,$08,$08,$e1
	db 'eleven minutes have passed since this demo '
	db 'began but there are more parts left on the disk so this '
	db 'one will now terminate ... bye bye ....   jac!      '
	db 0

credtxt	db '        welcome!        '
	db ' visdom   demo  part ii '
	db 'coded by peter    dell  '
	db 'sound bykarsten schmidt '
	db '        done for        '
	db '  the    halle  project '
	db ' press    help  for info'
	db 0

moretxt	db 'xl rules  and   army sux'
	db ' coming   soon   on xl  '
	db ' filled vectors by jac! '
	db ' "soon" i hope. really! '
	db 0

end2	dw 0,0
	dw org2,end2-org2
	dw org1,end1-org1
