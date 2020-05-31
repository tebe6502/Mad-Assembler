* -----------------------------
* |second POKEY detect routine|
* | answer in A register:     |
* |$00 - absent $80 - present |
* -----------------------------
* | code & idea: Seban/SLIGHT |
* |-+* (c) 1995,96 Slight! *+-|
* -----------------------------

	org $2000

main	jsr stereo

	bmi present

absent	jsr printf
	.by $9b 'STEREO absent' $9b 0

	jmp quit

present	jsr printf
	.by $9b 'STEREO present' $9b 0

quit	jsr printf
	.by $9b 'Press any key' $9b 0

	mva #$ff 764

wait	ldy 764
	iny
	beq wait

	rts

* ---------------------------------

stereo	sei
	inc $d40e
	lda #$03
	sta $d21f
	sta $d210
	ldx #$00
	stx $d211
	inx
	stx $d21e

	ldx:rne $d40b

	stx $d219
loop	ldx $d40b
	bmi stop
	lda #$01
	bit $d20e
	bne loop

stop	lda $10
	sta $d20e
	dec $d40e
	cli
	txa
	rts

* ---------------------------------

	.link 'libraries\stdio\lib\printf.obx'


	run main

