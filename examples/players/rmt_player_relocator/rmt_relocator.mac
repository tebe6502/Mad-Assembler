
/*
  RMT Relocator v1.1 (16.12.2008)

  Example:
		rmt_relocator 'file.rmt' , new_address
*/

.macro	rmt_relocator

	.get [$100] :1,0,6				// wczytujemy plik do bufora MADS'a

	ert .wget[$100] <> $FFFF , 'Bad file format'

new_add = :2						// nowy adres dla modulu RMT

old_add	= .wget[$102]					// stary adres modulu RMT

length	= .wget[$104] - old_add + 1			// dlugosc pliku RMT bez naglowka DOS'u

ofset	= new_add-old_add

	.get [old_add-6] :1

	.put[old_add-4] = .lo(new_add)				// poprawiamy nag³ówek DOS'a
	.put[old_add-3] = .hi(new_add)				// tak aby zawieral informacje o nowym

	.put[old_add-2] = .lo(new_add + length - 1)		// adresie modulu RMT
	.put[old_add-1] = .hi(new_add + length - 1)

type	= .get[old_add+3]

pinst	= .wget[old_add+8]
pltrc	= .wget[old_add+10]
phtrc	= .wget[old_add+12]
ptlst	= .wget[old_add+14]

	.put[old_add+8] = .lo(pinst+ofset)
	.put[old_add+9] = .hi(pinst+ofset)

	.put[old_add+10] = .lo(pltrc+ofset)
	.put[old_add+11] = .hi(pltrc+ofset)

	.put[old_add+12] = .lo(phtrc+ofset)
	.put[old_add+13] = .hi(phtrc+ofset)

	.put[old_add+14] = .lo(ptlst+ofset)
	.put[old_add+15] = .hi(ptlst+ofset)

//	ISTRUMENTS
	.rept (pltrc-pinst)/2
	?tmp = .wget[pinst+#*2]

	.put[pinst+#*2] = .lo(?tmp+ofset)
	.put[pinst+#*2+1] = .hi(?tmp+ofset)

	.endr

//	TRACKS
	.rept phtrc-pltrc
	?tmp = .get[pltrc+#] + .get[phtrc+#]<<8

	ift ?tmp>0
	.put[pltrc+#] = .lo(?tmp+ofset)
	.put[phtrc+#] = .hi(?tmp+ofset)
	eif

	.endr

//	TRACK LIST

	ift type='8'
	skip=8
	els
	skip=4
	eif

	.rept [(old_add+length-ptlst)/skip]+1
	ift .get[ptlst+#*skip]=$fe
	?tmp = .get[ptlst+#*skip+2] + .get[ptlst+#*skip+3]<<8
	.put[ptlst+#*skip+2] = .lo(?tmp+ofset)
	.put[ptlst+#*skip+3] = .hi(?tmp+ofset)
	eif
	.endr

	.sav [old_add] length
.endm
