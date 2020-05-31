
// with INFINITE LOOP

	org $2000

	ift temp>$2100
	lda temp
	sta $80
	els
	lda temp
	sta $80
	lda temp+1
	sta $80+1
	eif

	:247 nop
 
temp


	end


// without INFINITE LOOP

	org $2000

	ift ?temp>$2100
	lda ?temp
	sta $80
	els
	lda ?temp
	sta $80
	lda ?temp+1
	sta $80+1
	eif

	:247 nop
 
?temp
