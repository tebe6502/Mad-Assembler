
* ---	Eratosthenes Sieve benchmark

true	= 1
false	= 0
size	= 255

flags	= $8000

iterations = 10

	opt r+
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
	.var i, prime, k, count, iter = 1, iterations_num=iterations .word
	
;	printf("10 iterations\n");

	jsr printf
	.by '% iterations' $9b $9b 0
	dta a(iterations_num)

;	wait();
	wait

	mwa #0 $13

;	iter = 1;

;	while (iter <= 10) {
p0	#while .word iter <= #iterations	;0

;		count = 0;
		mwa #0 count

;		i = 0;
		mwa #0 i

;		while (i <= size) {
p1		#while .word i <= #size		;1

;			flags[i] = true;

			adw i #flags adr

			lda #true
			sta $ffff
		adr:	equ *-2
		
;			i++;
			inw i
;		}
		#end

;		i = 0;
		mwa #0 i
		
;		while (i <= size) {
p2		#while .word i <= #size		;2

;			if (flags[i]) {

			adw i #flags adr2

			lda $ffff
		adr2:	equ *-2

			beq skip

;				prime = i + i + 3;

				adw i i prime

				adw prime #3

;				k = i + prime;

				adw i prime k

;				while (k <= size) {
p3				#while .word k <= #size		;3

;					flags[k] = false;

					adw k #flags adr3

					lda #false
					sta $ffff
				adr3:	equ *-2

;					k = k + prime;

					adw k prime

;				}
				#end

;				count++;
				inw count

;			}
		skip:

;			i++;
			inw i

;		}
		#end

;		iter++;

		inw iter

;	}
	#end
	
;	printf("\n%d primes\n", count);
	
;	i=PEEK(tick)+PEEK(tack)*256;

;	printf("\n%d fps\n", i);
	
;	return 0;
;}

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
