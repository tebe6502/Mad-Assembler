
dliCheckStability
	sta hitclr
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	lda p0pf ;collisions of Player 0
	;asl
	;sta colpf0
	and frameStability ;checking collision with pf0; should be 1 if ok
	sta frameStability
	rts
