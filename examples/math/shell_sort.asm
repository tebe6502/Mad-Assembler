* Shell Sort (for 16-bit Elements)
* changes: 29.06.2007

/*

function ShellSort(arr,length) {
  var j, i, v, h, k;
  for (h=1; h < length; h=3*h+1);
  while (h=(h-1)/3)
    for (i=h, j=i, v=arr[i]; i<=length; arr[j+h]=v, i++, j=i, v=arr[i])
      while((j-=h) >= 0 && arr[j] > v)
        arr[j+h]=arr[j];
}

*/

	org $80

v_plus_1	.ds 2
h		.ds 2
arr_start	.ds 2

j		.ds 2	; Uses two bytes. Has to be on zero-page
j_plus_h	.ds 2	; Uses two bytes. Has to be on zero-page
arr_length	.ds 2	; Can safely use the same location as
			; j_plus_h, but doesn't have to be on ZP

        org $2000	; Start address.

main	lda <table
	ldx >table
	jsr shell_sort 

	mva	#$26	712

loop	jmp loop

/*
	lda <table		; slowest then shell_sort :P
	ldx >table
	jsr shell_sort.insertion_sort
*/

.proc	SHELL_SORT
		ldy #h_high-h_low-1
		bne sort_main		; Always branch
insertion_sort	ldy #0

sort_main	sty h_start_index
		cld
		sta j
		sta in_address

		clc
		adc #2
		sta arr_start

		stx j+1
		stx in_address+1

		txa
		adc #0
		sta arr_start+1

		ldy #0
		lda (j),y
		sta arr_length

		clc
		adc arr_start
		sta arr_end

		iny
		lda (j),y
		sta arr_length+1

		adc arr_start+1
		sta arr_end+1

;	for (h=1; h < length; h=3*h+1);

		ldx h_start_index	; Start with highest value of h
chk_prev_h	lda h_low,x
		cmp arr_length
		lda h_high,x
		sbc arr_length+1
		bcc end_of_init		; If h < array_length, we've found the right h
		dex
		bpl chk_prev_h
		rts			; array length is 0 or 1. No sorting needed.

end_of_init	inx
		stx h_index

;	while (h=(h-1)/3)

h_loop		dec h_index
		bpl get_h
		rts			; All done!

get_h		ldy h_index
		lda h_low,y
		sta h
		clc
		adc in_address		; ( in_address is arr_start - 2)
		sta i
		lda h_high,y
		sta h+1
		adc in_address+1
		sta i+1

; for (i=h, j=i, v=arr[i]; i<=length; arr[j+h]=v, i++, j=i, v=arr[i])

i_loop		lda i
		clc
		adc #2
		sta i
		sta j
		lda i+1
		adc #0
		sta i+1
		sta j+1

		ldx i
		cpx arr_end
		lda i+1
		sbc arr_end+1
		bcs h_loop

		ldy #0
		lda (j),y
		sta v
		clc
		adc #1
		sta v_plus_1
		iny
		lda (j),y
		sta v+1
		adc #0
		bcs i_loop		; v=$ffff, so no j-loop necessary
		sta v_plus_1+1

		dey			; Set y=0

;	while((j-=h) >= 0 && arr[j] > v)

j_loop		lda j
		sta j_plus_h
		sec
		sbc h
		sta j
		tax
		lda j+1
		sta j_plus_h+1
		sbc h+1
		sta j+1

; Check if we've reached the bottom of the array

		bcc exit_j_loop
		cpx arr_start
		sbc arr_start+1
		bcc exit_j_loop

; Do the actual comparison:  arr[j] > v

		lda (j),y
		tax
		iny			; Set y=1
		lda (j),y
		cpx v_plus_1
		sbc v_plus_1+1
		bcc exit_j_loop

;	arr[j+h]=arr[j];

		lda (j),y
		sta (j_plus_h),y
		dey			; Set y=0
		txa
		sta (j_plus_h),y
		bcs j_loop		; Always branch

;	for (i=h, j=i, v=arr[i]; i<length; arr[j+h]=v, i++, j=i, v=arr[i])  ***  arr[j+h]=v part

exit_j_loop	lda v
		ldy #0
		sta (j_plus_h),y
		iny
		lda v+1
		sta (j_plus_h),y
		jmp i_loop


; This describes the sequence h(0)=1; h(n)=k*h(n-1)+1 for k=3 (1,4,13,40...)
; All word-values are muliplied by 2, since we are sorting 2-byte values

h_low		.byte <2, <8, <26, <80, <242, <728, <2186, <6560, <19682
h_high		.byte >2, >8, >26, >80, >242, >728, >2186, >6560, >19682
h_start_index	.byte
h_index		.byte
in_address	.word
arr_end		.word
i		.word
v		.word

.endp


/*
  unsorted values (type WORD)
*/
	org $bc40

table	.word 960
	.word rnd( 0 , $FFFF , 960 / 2 )

	run main
