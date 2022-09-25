
	org $2000
	
main	jsr printf
	dta c'date: %-%-% / %:%:%',$9b,0
	dta a(_year)
	dta a(_month)
	dta a(_day)
	dta a(_hour)
	dta a(_minute)
	dta a(_second)

@	lda $d20a
	sta $d01a
	jmp @-
	
_year	dta a(year)
_month	dta a(month)
_day	dta a(day)

_hour	dta a(hour)
_minute	dta a(minute)
_second	dta a(second)
	
	.link '..\libraries\stdio\lib\printf.obx'

	run main
