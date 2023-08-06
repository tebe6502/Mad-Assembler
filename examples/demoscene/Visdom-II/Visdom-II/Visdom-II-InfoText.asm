;
;	">> Halle-External-Infotextmodule <<"
;
;	(c/r)_17-03-94_by_JAC!
;
;
;	Genenrate/Convert_infotext_into_special_format.
;	Send_$7000-$8e78_to_"Dat:HalleInfo.txt".

tp	equ $80			;ScrollText_Pointer
x1	equ $e0

;================================================================
set	macro
	lda #<\2
	sta \1
	lda #>\2
	sta \1+1
	endm

add	macro
	clc
	lda \1
	adc #<\2
	sta \1
	lda \1+1
	adc #>\2
	sta \1+1
	endm

;================================================================
*	equ $400
org1	equ *

	set tp,inftxt
	ldy #0
con1	lda (tp),y
	beq con2

	cmp #96
	bcs con3
	sec
	sbc #$20

con3	tax
	lda $3600,x
	sta (tp),y
	iny
	bne con1
	inc tp+1
	jmp con1
con2	lda #$ff
	sta (tp),y
xx	lda $d40b
	sta $d01a
	jmp xx
end1
;================================================================
*	equ $7000
org2	equ *
inftxt
	db ' ... es hat lange gedauert ...          '
	db '         ... aber nun sie ist fertig ...'
	db '                                        '
	db '        Jacomo Leopardi presents        '
	db '                                        '
	db '           VISDOM DEMO PART II          '
	db '                                        '
	db '                                        '
	db '                 "HELP"                 '
	db '     bringt die folgende Infoseite,     '
	db '    "Space" fuehrt zurueck zum Demo.    '
	db '                                        '
	db '                 "SHIFT"                '
	db 'beendet das Demo und laedt den naechsten'
	db 'Teil der "Halle Project Demo" von Disk. '

	db '           VISDOM DEMO PART II          '
	db '                                        '
	db '          Code, Gfx , Design by         '
	db '            JAC! / Peter Dell           '
	db '                                        '
	db '                Sound by                '
	db '          CSS! / Karsten Schmitt        '
	db '                                        '
	db '          Original Big Font by          '
	db '                 FLASH                  '
	db '                                        '
	db ' Final version done on 16-03-93 by JAC! '
	db '                                        '
	db ' Source lenght:  41763 byte (2377 lines)'
	db ' Data lenght  :  18991 byte             '

	db '        Hier ist meine Adresse:         '
	db '                                        '
	db '               >> JAC! <<               '
	db '      (Visdom rules - Wudsn ursels)     '
	db '                                        '
	db '               Peter Dell               '
	db '            In der Klink 32             '
	db '            6601 Heusweiler             '
	db '                Germany                 '
	db '             +49 6806 77859             '
	db '                                        '
	db 'Freitags 17h00 bis Sonntags 17h00 immer,'
	db ' solange ich noch beim Bund bin. Shit!  '
	db 'Die Woche uber wenn ihr Glueck habt, dh.'
	db '  wenn ich Glueck habe und Urlaub habe. '

	db ' Die 3 Haupteffekte in diesem Demo sind '
	db 'vollkommen neu und in dieser Art nur auf'
	db 'einem einzigen 8-Bit Rechner moeglich ..'
	db '                                        '
	db '           "DEM ATARI XL / XE"          '
	db '                                        '
	db '                                        '
	db '         >> RASTERSPLIT LOGO <<         '
	db '                                        '
	db '   Das Multicolor "Visdom" Logo ueber   '
	db ' diesem Text hat 9 Farben in Multicolor '
	db ' Aufloesung, von denen die Schriftfarben'
	db '  der 6 Buchstaben in jeder Zeile (!)   '
	db 'frei aus der 128 Farben Palette gewaehlt'
	db '        werden koennen. @ by JAC!       '

	db '      >> DER RASTERSPLIT WIGGLE <<      '
	db '                                        '
	db 'Durch einen Softsplit,der in jeder Zeile'
	db 'einen neuen Wert erhalten kann, erreicht'
	db ' dieser Effekt eine GTIA-Aufloesung von '
	db '                                        '
	db '      ##  32 Farbabstufungen  ##        '
	db '                                        '
	db '         dargestellt in einem           '
	db '                                        '
	db '     ## 128 Zeilen Sin-Sin-Wiggle ##    '
	db '                                        '
	db '    Das ist absoluter 8-Bit Rekord!     '
	db ' (Und vom kritischen Timing her nicht   '
	db ' nicht mehr zu ueberbieten. @ by JAC!)  '

	db '              >> IMPRES <<              '
	db '                                        '
	db '       "The IMPossible RESolution       '
	db '      that was made to IMPRESs you."    '
	db '                                        '
	db ' Ein neuer (wirklich neuer) Effekt, der '
	db ' es ermoeglicht, mit der GTIA 160 Pixel '
	db ' in einer 40 Zeichen Zeile darzustellen.'
	db '                                        '
	db '        ## 16 Farbabstufungen ##        '
	db '        in Multicolor Aufloesung.       '
	db '                                        '
	db '     In diesem Demo laeuft das ganze    '
	db ' zusaetzlich noch im Overscan Modus mit '
	db '    einer bewegten Grafik.  @ by JAC!   '

	db '                                        '
	db ' SOUND - SOUND - SOUND - SOUND - SOUND. '
	db '                                        '
	db 'Sound hat man ja bekanntlich nie genug, '
	db ' (oder war es Geld ? ...) und deshalb:  '
	db '                                        '
	db 'Suche ich Soundprogrammierer auf dem XL!'
	db '                                        '
	db 'Wer einen Guten Song geschreiben hat und'
	db ' glaubt, dass er auch anderen gefaellt, '
	db 'kann sich mit mir in Verbindung setzen. '
	db '  Meine Adresse steht auf einer dieser  '
	db 'Seiten herum. Also los Leute, Toene gibt'
	db ' es doch jetzt wirklich genug, oder ??  '
	db '                                        '

	db 'PS:                                     '
	db ' Wer (so wie Haegar Weller bei meiner   '
	db '   ersten Visdom Demo) hier irgendwas   '
	db ' klaut, veraendert oder damit Profit zu '
	db '  machen versucht, kann damit rechnen,  '
	db '   dass er frueher oder spaeter ganz    '
	db '         grossen Aerger bekommt.        '
	db '(So wie Haegar Weller, der LAAAAAAAMER!)'
	db '                                        '
	db '                                        '
	db 'PS: (PPS ? oder PSS ? oder PS2 oder was)'
	db 'Im folgenden Liste ich noch die Personen'
	db '   auf, die bei der Erstellung dieses   '
	db 'Werkes von Bedeutung waren ... ob ich es'
	db 'wollte oder nicht ... tschau @ JAC! 1993'

	db 'Mein Dank geht hiermit an:              '
	db '                                        '
	db '  Flash St.Wendel fuer die Entspannung, '
	db ' die tollen Frauen,die kalten Eiswuerfel'
	db '       und die laute Lautstaerke.       '
	db '                                        '
	db '  Onkel Ruehe, Onkel Naumann und ihrer  '
	db ' Bundeswehr fuer die verlorene Zeit,das '
	db ' schlechte Essen,die gestressten Nerven,'
	db ' die miese Bezahlung und die verlorenen '
	db ' Gehirnzellen ...                       '
	db '.. sowie die Tatsache, dass deshalb mein'
	db ' Megademo nicht fertig wird.  R-ME SUX! '
	db '                                        '
	db '                                        '

	db 'Weiterhin danke ich:                    '
	db '                                        '
	db ' Telekom und Post fuer die hohen Portos,'
	db ' Telefonrechungen, geknickten Disketten '
	db ' und schwachsinnigen Postwurfsendungen  '
	db 'mit Kuchenfahrten in den Bayrischen Wald'
	db 'und Baumwoll-Rheumadecken Wettbewerben. '
	db '                                        '
	db 'Casio fuer die schlechteste Uebersetzung'
	db 'der japanischen Bedingungsanleitung fuer'
	db '      eine digitale Armbanduhr.         '
	db '                                        '
	db 'Atari Inc. fuer das kuerzeste Computer- '
	db '    handbuch mit den meisten Spachen.   '
	db '                                        '

	db 'Weiterhin danke ich:                    '
	db '                                        '
	db '  Genius & Elder of Synenergy fuer die  '
	db '       Daten zum SID und dem C16.       '
	db '                                        '
	db ' Den Phantastischen Vieren, De La Soul, '
	db '  Del Tha Funkee Homosapien, Ice-T und  '
	db '  Arrested Development fuer die coolen  '
	db '  Hardcore-Hip-Hop-Rave-Metal-Rap CDs.  '
	db '                                        '
	db 'Der deutschen Radio- und TV-Werbung fuer'
	db '  die reinsten,aprilfrischsten,neusten, '
	db '   phosphatfreisten,auslaufsichersten,  '
	db '  medizinisch-detmatologisch getesteten '
	db '  Splipeinlagen- und Waschmittel Spots. '

	db 'Weiterhin danke ich:                    '
	db '                                        '
	db '     Coca Cola fuer die Coca Cola.      '
	db '                                        '
	db '    MS-Dos fuer seine schwachsinnige    '
	db '       Aufwaertskompatibilitaet.        '
	db ' (Speichersegmentierung, ha, haha ... ) '
	db '                                        '
	db '     Magnus fuer den Cruncher V5.0      '
	db ' Fantastisches Teil,leider nicht faehig '
	db '   das DOS im Speicher zu lassen. JAC!  '
	db '                                        '
	db '    Steffen Wenzel fuer den 320k XL     '
	db '             und die Speedy.            '
	db '                                        '

	db 'Weiterhin danke ich auch noch:          '
	db '                                        '
	db '   PROMAX of Kefrens fuer den Editor    '
	db '              des Seka V3.2             '
	db '                                        '
	db '      J. & T. Marin fuer den 65c02      '
	db '             Crossassembler             '
	db '                                        '
	db 'Dr. Erwin Steif fuer den 24 Mhz Eprommer'
	db ' und den kaputten roten Golf, in dem er '
	db '      so gerne mal mit Patrizia ...     '
	db '                                        '
	db ' Pille fuer die coolsten Songtitel und  '
	db '   den besten Blutworschdsupp-Remix.    '
	db '                                        '
	db 0

end2	dw 0,0
	dw org2,end2-org2
	dw org1,end1-org1
