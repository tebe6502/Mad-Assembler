;int main() {
;    const int WIERSZ = 5;
;    const int KOLUMNA = 15;
;    int j, i = 1;
	
	org $2000

	.var wiersz=15, kolumna=20, j, i=1, hlp .byte

main

;    while(i <= WIERSZ)
	.while .byte i <= wiersz
;     {
;       cout << setw(KOLUMNA - i) << '*';

	sbb kolumna i 82	; [KOLUMNA - i]  ->  82 (w komórce 82 lewy margines)

	putchar	#$9b	; cout << setw(KOLUMNA - i)

	putchar	#'*'	; cout << '*'

;       j = 1;
	mva #1 j

;       while( j <= 2*i-2 )
	lda i
	asl @
	sub #2
	sta hlp

	 .while .byte j <= hlp
;        {
;         cout << '*';
	  putchar #'*'

;         j++;
	  inc j
;        }
	 .endw
;       cout << endl;

;       i++;
	inc i
;     }
	.endw
	
;    return 0;                     
;}
	mva #$02 82	; domyslna wartosc komorki 82

	mva #$c2 712

	jmp *

	.link	'libraries\stdio\lib\putchar.obx'

*---
	run main