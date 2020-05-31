
* ---	Eratosthenes Sieve benchmark (with speed optimization)

true	= 1
false	= 0
size	= 8190
sizepl	= 256

flags	= $8000

iterations = 10


	org $2000

;void wait(void)
;{
; unsigned char a=PEEK(tick);
; while (PEEK(tick)==a) { ; }
;}

.proc wait
	lda:cmp:req 20
	rts
.endp


main

;int main()
;{
;	unsigned int i, prime, k, count, iter;
	.zpvar = $80
	
	.zpvar i, prime, k, count, bp .word
	.zpvar iter .byte

	.var iterations_num = iterations .word

;	printf("10 iterations\n");

	jsr printf
	.by '% iterations' $9b $9b 0
	dta a(iterations_num)

;	wait();
	wait

	mwa #0 $13
	
	sta bp

;	iter = 1;

	mva #1 iter

;	while (iter <= 10) {
	#while .byte iter < #iterations+1	;0

;		count = 0;
		mwa #0 count

;		i = 0;
;		mwa #0 i

		mwa #flags adr1

		lda #true
		ldy #0

;		while (i <= size) {
		jmp sk0
	lp0:
;		flags[i] = true;

		sta $ffff,y
	adr1:	equ *-2
		
		iny
		sne
		inc adr1+1
	sk0:
		ldx adr1+1
		cpx >flags+size+1
		jne lp0
		cpy <flags+size+1
		jne lp0

;			i++;
;		}

;		i = 0;
		mwa #flags i

		ldy #0
		
;		while (i <= size) {

		jmp sk1
	lp1:
;			if (flags[i]) {

			lda (i),y

			#if .byte @

;				prime = i + i + 3;
			
				lda i+1
				sta prime+1
				lda I
				asl @
				rol prime+1
				add #$03
				sta prime
				scc
				inc prime+1
				
;				k = i + prime;

				add i
				sta k
				lda i+1
				adc prime+1
				
			jmp sk2
				sta k+1
				
;				while (k <= size) {
			lp2:
;					flags[k] = false;

					lda #false
					sta (k),y

;					k = k + prime;

					lda k
					add prime
					sta k
					lda k+1
					adc prime+1
			sk2:
					sta k+1
		
				cmp >flags+size+1
				bne @+
				lda k
				cmp <flags+size+1
			@:
				jcc lp2			

;				}

;				count++;
				inw count

;			}
			#end

;			i++;
			inw i


	sk1:	cpw i #flags+size+1
		jcc lp1

;		}

;		iter++;

		inc iter

;	}
	#end
	
;	printf("\n%d primes\n", count);

	.var time .word

	mva $14 time
	mva $13 time+1
	
	jsr printf
	.by '% primes',$9b
	.by '% fps',$9b,$9b
	.by 'Press any key',$9b,0
	dta a(count)
	dta a(time)

	mva #$ff 764

loop	ldy:iny 764
	beq loop

	rts


	.link 'libraries/stdio/lib/printf.obx'


	run main
