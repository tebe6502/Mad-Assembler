; modulo
; https://gist.github.com/hausdorff/5993556
;
.MACRO mod val1,val2
	lda	:val1
	sec
	
loop
	sbc :val2
	bcs loop
	adc :val2
.ENDM
