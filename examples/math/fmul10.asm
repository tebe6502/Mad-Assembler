/*
  Fast Multiply by 10
  By Leo Nechaev (leo@ogpi.orsk.ru), 28 October 2000.
*/

fmul10	ASL @		;multiply by 2
	STA TEMP+1	;temp store in TEMP
	ASL @		;again multiply by 2 (*4)
	ASL @		;again multiply by 2 (*8)
	CLC
TEMP	ADC #0		;as result, A = x*8 + x*2
	RTS
