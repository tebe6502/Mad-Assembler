;PMG objects must have position changed one pixel to the left in odd lines. They are shifted one pixel to the right in odd lines because of hardware effect.
;There is no PMG DMA in even lines because of hardware effect.
;Color of the right-most pixel in even line (not shifted) is taken from colpm2.

 org pmLAdr + 0
;P4/Missiles

	.by $00,$00,$00,$00,$00,$00,$00,$00  ;8 invisible lines

	.by $00,$00,$00,$00,$00,$00,$00,$00  ;blank lines
	.by $00,$00,$00,$00,$00,$00,$00,$00
	.by $00,$00,$00,$00

	;M0 pink pos 62 size 0
	;M1 light brown pos 74 size 0
	;M2 yellow pos 75 size 0
	;M3 white pos 73 size 3

	;visible screen lines
	.by $00 ;0 P4
	.by $00 ;1 P4
	.by $00 ;2 P4
	.by $00 ;3 P4
	.by $00 ;4 P4
	.by $00 ;5 P4
	.by $00 ;6 P4
	.by $00 ;7 P4
	.by $00 ;8 P4
	.by $00 ;9 P4
	.by $00 ;10 P4
	.by $C0 ;11 P4
	.by $C0 ;12 P4
	.by $C0 ;13 P4
	.by $C0 ;14 P4
	.by $C0 ;15 P4
	.by $C0 ;16 P4
	.by $C0 ;17 P4
	.by $C0 ;18 P4
	.by $C0 ;19 P4
	.by $C0 ;20 P4
	.by $C0 ;21 P4
	.by $C0 ;22 P4
	.by $C0 ;23 P4
	.by $C0 ;24 P4
	.by $C0 ;25 P4
	.by $C0 ;26 P4
	.by $C0 ;27 P4 M3 pos 72
	.by $C0 ;28 P4 M3 pos 79
	.by $20 ;29 P4 M3 pos 68 size 1 may be deferred 2 lines, M0 size 0, M1 size 0, M2 size 0
	.by $28 ;30 P4 M1 d $28
	.by $68 ;31 P4
	.by $60 ;32 P4 M2 pos 76, M1 d $60
	.by $E0 ;33 P4
	.by $E0 ;34 P4 M2 pos 78
	.by $E0 ;35 P4
	.by $E0 ;36 P4 M2 pos 79
	.by $20 ;37 P4 M0 light brown
	.by $28 ;38 P4 M2 pos 80, M1 d $28
	.by $26 ;39 P4 M2 pos 75, M1 pos 75, M0 green
	.by $26 ;40 P4 M1 pos 74, M0 light brown
	.by $00 ;41 P4 M2 pos 81 size 3 may be deferred 2 lines, M0 size 0, M1 size 0, M3 size 1, M0 pos 74 may be deferred
	.by $00 ;42 P4
	.by $38 ;43 P4 M3 pos 67 may be deferred, M1 pos 63
	.by $38 ;44 P4 M2 pos 80 may be deferred 1 line, M1 pos 81 may be deferred
	.by $20 ;45 P4
	.by $20 ;46 P4 M0 green
	.by $23 ;47 P4
	.by $23 ;48 P4 M2 pos 81 may be deferred
	.by $28 ;49 P4
	.by $28 ;50 P4 M0 light brown may be deferred 2 lines
	.by $6D ;51 P4 M1 pos 83
	.by $6D ;52 P4
	.by $E0 ;53 P4 M1 pos 80 may be deferred, M0 green may be deferred 3 lines
	.by $E0 ;54 P4
	.by $E0 ;55 P4
	.by $E0 ;56 P4
	.by $10 ;57 P4 M3 pos 97 size 3 may be deferred 4 lines, M2 size 1 may be deferred, M0 size 0, M1 size 0
	.by $10 ;58 P4 M2 pos 87
	.by $18 ;59 P4
	.by $18 ;60 P4 M1 pos 83
	.by $98 ;61 P4 M2 pos 81, M1 pos 73
	.by $98 ;62 P4 M2 pos 88, M1 pos 85
	.by $90 ;63 P4 M1 pos 77
	.by $98 ;64 P4 M2 pos 86, M1 d $98
	.by $D0 ;65 P4
	.by $D0 ;66 P4 M1 pos 104 may be deferred
	.by $50 ;67 P4
	.by $50 ;68 P4 M2 pos 87
	.by $40 ;69 P4
	.by $40 ;70 P4
	.by $00 ;71 P4 M3 pos 47 may be deferred
	.by $00 ;72 P4 M2 pos 104 may be deferred, M0 pos 104 may be deferred
	.by $00 ;73 P4
	.by $00 ;74 P4
	.by $00 ;75 P4
	.by $00 ;76 P4
	.by $00 ;77 P4
	.by $00 ;78 P4
	.by $80 ;79 P4
	.by $80 ;80 P4
	.by $80 ;81 P4
	.by $80 ;82 P4
	.by $C0 ;83 P4
	.by $C0 ;84 P4
	.by $80 ;85 P4
	.by $80 ;86 P4
	.by $80 ;87 P4 M3 pos 46 may be deferred
	.by $80 ;88 P4
	.by $80 ;89 P4
	.by $80 ;90 P4
	.by $80 ;91 P4
	.by $80 ;92 P4
	.by $80 ;93 P4
	.by $80 ;94 P4
	.by $00 ;95 P4 M3 pos 118 may be deferred
	.by $00 ;96 P4
	.by $00 ;97 P4 M2 size 0 may be deferred, M1 size 1 may be deferred, M0 size 0, M3 size 3, M0 light brown may be deferred
	.by $00 ;98 P4
	.by $00 ;99 P4
	.by $00 ;100 P4
	.by $00 ;101 P4
	.by $00 ;102 P4
	.by $08 ;103 P4
	.by $08 ;104 P4
	.by $E3 ;105 P4 M1 pos 108 may be deferred 4 lines
	.by $E3 ;106 P4 M2 pos 106, M0 yellow pos 105
	.by $E3 ;107 P4
	.by $E3 ;108 P4 M0 pos 107
	.by $FA ;109 P4 M2 pos 107 may be deferred 1 line, M0 pos 106
	.by $FA ;110 P4 M1 pos 109
	.by $C8 ;111 P4 M1 pos 63
	.by $CC ;112 P4 M1 pos 62 d $CC
	.by $C8 ;113 P4 M2 pos 33 may be deferred, M3 pos 120 may be deferred up to before line 118
	.by $C0 ;114 P4 M1 d $C0
	.by $C8 ;115 P4 M1 pos 63
	.by $C8 ;116 P4
	.by $C0 ;117 P4 M1 pos 66
	.by $C8 ;118 P4 M1 d $C8
	.by $80 ;119 P4 M1 pos 47
	.by $88 ;120 P4 M1 d $88
	.by $08 ;121 P4 M1 pos 63, M3 pos 47 may be deferred
	.by $08 ;122 P4 M0 yellow pos 46 may be deferred 4 lines
	.by $18 ;123 P4 M1 pos 67
	.by $18 ;124 P4 M1 pos 68 M1 size 3 may be deferred 2 lines, M0 size 0, M2 size 0, M3 size 3
	.by $2C ;125 P4 M1 pos 66
	.by $2E ;126 P4 M0 d $2E, M1 pos 65
	.by $3E ;127 P4 M2 pos 36, M1 pos 63
	.by $0D ;128 P4 M2 M0 d $0D M0 pos 47
	.by $3F ;129 P4 M0 pos 97, M1 pos 61, M2 pos 55, M2 size 3, M0 size 3, M1 size 3, M3 size 3
	.by $3F ;130 P4 M1 pos 62
	.by $3E ;131 P4
	.by $3E ;132 P4 M1 pos 63, M0 pos 96
	.by $3E ;133 P4 M1 pos 61, M0 pos 97
	.by $3E ;134 P4 M1 pos 60
	.by $3E ;135 P4 M0 pos 98
	.by $3E ;136 P4 M1 pos 59, M2 pos 51
	.by $3F ;137 P4 M0 pos 96
	.by $3F ;138 P4 M0 pos 98
	.by $33 ;139 P4 M2 pos 54, M1 size 0 may be deferred 1 line, M0 size 3, M2 size 3, M3 size 3
	.by $3B ;140 P4 M2 pos 55, M1 pos 55 M1 d $3B
	.by $3A ;141 P4
	.by $3A ;142 P4 M1 pos 57, M0 pos 41
	.by $3E ;143 P4 M0 pos 98
	.by $1E ;144 P4 M2 d $1E, M0 pos 101
	.by $1E ;145 P4 M1 pos 58, M0 pos 99
	.by $1E ;146 P4 M0 pos 100
	.by $3D ;147 P4 M0 size 1, M1 size 0, M2 size 3, M3 size 3, M0 pos 53
	.by $02 ;148 P4 M2 pos 61 may be deferred 1 line M2 M1 M0 d $02
	.by $93 ;149 P4 M1 pos 64 yellow may be deferred 1 line, M1 size 3 may be deferred 2 lines, M0 size 1, M2 size 3, M3 size 3, M0 pos 50
	.by $8A ;150 P4 M2 M1 M0 d $8A, M3 pos 65 grey 1
	.by $9A ;151 P4 M1 pos 52 white, M2 yellow, M3 pos 47, M0 pos 48
	.by $96 ;152 P4 M1 d $96, M2 light brown
	.by $11 ;153 P4 M0 pos 65
	.by $01 ;154 P4 M2 d $01
	.by $02 ;155 P4
	.by $02 ;156 P4
	.by $00 ;157 P4 M0 pos 64 may be deferred 1 line, M3 brown
	.by $01 ;158 P4 M0 d $01, M2 light blue may be deferred
	.by $02 ;159 P4 M2 pos 81, M1 pos 95 grey1 may be deferred, M1 size 0 may be deferred, M0 size 1, M2 size 3, M3 size 3
	.by $01 ;160 P4 M0 d $01
	.by $02 ;161 P4
	.by $00 ;162 P4 M0 d $00
	.by $00 ;163 P4
	.by $00 ;164 P4
	.by $00 ;165 P4
	.by $00 ;166 P4
	.by $00 ;167 P4
	.by $00 ;168 P4
	.by $00 ;169 P4
	.by $00 ;170 P4
	.by $00 ;171 P4
	.by $00 ;172 P4
	.by $30 ;173 P4
	.by $30 ;174 P4
	.by $30 ;175 P4
	.by $38 ;176 P4 M1 d $38
	.by $30 ;177 P4
	.by $00 ;178 P4 M2 d $00, M1 light blue
	.by $30 ;179 P4 M2 brown, M3 grey1
	.by $10 ;180 P4 M2 d $10
	.by $10 ;181 P4
	.by $10 ;182 P4
	.by $00 ;183 P4
	.by $00 ;184 P4
	.by $00 ;185 P4
	.by $00 ;186 P4
	.by $00 ;187 P4
	.by $00 ;188 P4
	.by $00 ;189 P4
	.by $00 ;190 P4
	.by $00 ;191 P4


 org pmLAdr + 256 * 1
;P0

	.by $00,$00,$00,$00,$00,$00,$00,$00  ;8 invisible lines

	.by $00,$00,$00,$00,$00,$00,$00,$00  ;blank lines
	.by $00,$00,$00,$00,$00,$00,$00,$00
	.by $00,$00,$00,$00

	;P0 pink pos 80 size 0; for stability control pos set to -1, color grey 3
	;M0 pink pos 62 size 0

	;visible screen lines
	.by $00 ;0 P0
	.by $80 ;1 P0
	.by $80 ;2 P0
	.by $80 ;3 P0
	.by $80 ;4 P0
	.by $80 ;5 P0
	.by $80 ;6 P0
	.by $80 ;7 P0
	.by $80 ;8 P0
	.by $80 ;9 P0
	.by $80 ;10 P0
	.by $80 ;11 P0
	.by $80 ;12 P0
	.by $80 ;13 P0
	.by $80 ;14 P0
	.by $80 ;15 P0
	.by $80 ;16 P0
	.by $00 ;17 P0 pos 80 pink
	.by $00 ;18 P0
	.by $00 ;19 P0
	.by $00 ;20 P0
	.by $00 ;21 P0
	.by $00 ;22 P0
	.by $00 ;23 P0
	.by $00 ;24 P0
	.by $40 ;25 P0
	.by $40 ;26 P0
	.by $40 ;27 P0
	.by $40 ;28 P0
	.by $00 ;29 P0
	.by $00 ;30 P0
	.by $01 ;31 P0
	.by $01 ;32 P0
	.by $02 ;33 P0
	.by $02 ;34 P0
	.by $01 ;35 P0
	.by $01 ;36 P0
	.by $00 ;37 P0 light brown
	.by $00 ;38 P0
	.by $04 ;39 P0 green
	.by $04 ;40 P0 light brown
	.by $80 ;41 P0
	.by $48 ;42 P0 d $48
	.by $00 ;43 P0
	.by $E0 ;44 P0 d $E0
	.by $00 ;45 P0
	.by $00 ;46 P0 green
	.by $00 ;47 P0
	.by $00 ;48 P0
	.by $00 ;49 P0
	.by $00 ;50 P0 light brown may be deferred 2 lines
	.by $00 ;51 P0
	.by $00 ;52 P0
	.by $00 ;53 P0 green may be deferred 3 lines
	.by $00 ;54 P0
	.by $00 ;55 P0
	.by $70 ;56 P0 d $70
	.by $40 ;57 P0
	.by $00 ;58 P0 d $00, pos 69 may be deferred
	.by $00 ;59 P0
	.by $00 ;60 P0
	.by $30 ;61 P0
	.by $30 ;62 P0
	.by $60 ;63 P0
	.by $60 ;64 P0
	.by $C8 ;65 P0
	.by $C8 ;66 P0
	.by $F3 ;67 P0
	.by $F3 ;68 P0
	.by $23 ;69 P0
	.by $23 ;70 P0
	.by $07 ;71 P0
	.by $07 ;72 P0
	.by $0C ;73 P0
	.by $0C ;74 P0
	.by $40 ;75 P0 pos 78
	.by $40 ;76 P0
	.by $D8 ;77 P0
	.by $D9 ;78 P0 d $D9
	.by $92 ;79 P0
	.by $08 ;80 P0 d $08
	.by $00 ;81 P0
	.by $02 ;82 P0 d $02
	.by $04 ;83 P0
	.by $04 ;84 P0
	.by $00 ;85 P0 blue pos 81
	.by $00 ;86 P0
	.by $00 ;87 P0
	.by $00 ;88 P0
	.by $00 ;89 P0
	.by $00 ;90 P0
	.by $00 ;91 P0
	.by $00 ;92 P0
	.by $F0 ;93 P0
	.by $F0 ;94 P0
	.by $F0 ;95 P0
	.by $F0 ;96 P0
	.by $00 ;97 P0 light brown
	.by $00 ;98 P0
	.by $00 ;99 P0
	.by $00 ;100 P0
	.by $00 ;101 P0
	.by $00 ;102 P0
	.by $00 ;103 P0
	.by $00 ;104 P0
	.by $00 ;105 P0
	.by $00 ;106 P0
	.by $00 ;107 P0
	.by $00 ;108 P0
	.by $00 ;109 P0
	.by $00 ;110 P0 purple pos 33 may be deferred
	.by $00 ;111 P0 size 1 may be deferred
	.by $00 ;112 P0
	.by $00 ;113 P0
	.by $00 ;114 P0
	.by $00 ;115 P0
	.by $00 ;116 P0
	.by $00 ;117 P0
	.by $10 ;118 P0 d $10
	.by $60 ;119 P0
	.by $E8 ;120 P0 d $E8
	.by $48 ;121 P0
	.by $00 ;122 P0 yellow may be deferred 1 line d $00
	.by $80 ;123 P0
	.by $80 ;124 P0 pos 35
	.by $8C ;125 P0 pos 34
	.by $70 ;126 P0 pos 35 d $70
	.by $00 ;127 P0 size 0
	.by $00 ;128 P0 pos 47
	.by $80 ;129 P0
	.by $00 ;130 P0 d $00, pos 42 may be deferred
	.by $00 ;131 P0
	.by $00 ;132 P0
	.by $00 ;133 P0
	.by $07 ;134 P0 d $07
	.by $1C ;135 P0 pos 41 may be deferred 5 lines
	.by $18 ;136 P0 d $18
	.by $20 ;137 P0
	.by $20 ;138 P0
	.by $40 ;139 P0
	.by $40 ;140 P0
	.by $86 ;141 P0 size 1
	.by $E8 ;142 P0 size 0 pos 51 d $E8
	.by $88 ;143 P0 size 1 pos 41
	.by $81 ;144 P0 size 0 pos 42 d $81
	.by $01 ;145 P0 pos 40
	.by $41 ;146 P0 d $41
	.by $84 ;147 P0
	.by $46 ;148 P0 d $46
	.by $88 ;149 P0
	.by $48 ;150 P0 d $48
	.by $90 ;151 P0
	.by $50 ;152 P0 d $50
	.by $21 ;153 P0
	.by $21 ;154 P0
	.by $42 ;155 P0
	.by $02 ;156 P0 d $02
	.by $C6 ;157 P0
	.by $C6 ;158 P0
	.by $8C ;159 P0
	.by $8C ;160 P0
	.by $66 ;161 P0 pos 38
	.by $62 ;162 P0 d $62
	.by $66 ;163 P0
	.by $66 ;164 P0
	.by $CC ;165 P0
	.by $CC ;166 P0
	.by $CC ;167 P0
	.by $CC ;168 P0
	.by $CC ;169 P0
	.by $CC ;170 P0
	.by $0C ;171 P0
	.by $0C ;172 P0
	.by $00 ;173 P0 pos 72 d $18 grey2 may be deferred
	.by $00 ;174 P0
	.by $00 ;175 P0
	.by $00 ;176 P0
	.by $00 ;177 P0
	.by $3C ;178 P0 d $3C
	.by $88 ;179 P0
	.by $18 ;180 P0 white d $18
	.by $F0 ;181 P0
	.by $3F ;182 P0 d $3F
	.by $FE ;183 P0
	.by $3E ;184 P0 d $3E
	.by $78 ;185 P0
	.by $0C ;186 P0 d $0C
	.by $00 ;187 P0
	.by $00 ;188 P0
	.by $00 ;189 P0
	.by $00 ;190 P0
	.by $00 ;191 P0


 org pmLAdr + 256 * 2
;P1

	.by $00,$00,$00,$00,$00,$00,$00,$00  ;8 invisible lines

	.by $00,$00,$00,$00,$00,$00,$00,$00  ;blank lines
	.by $00,$00,$00,$00,$00,$00,$00,$00
	.by $00,$00,$00,$00

	;P1 light brown pos 66 size 0
	;M1 light brown pos 74 size 0

	;visible screen lines
	.by $00 ;0 P1
	.by $00 ;1 P1
	.by $00 ;2 P1
	.by $00 ;3 P1
	.by $00 ;4 P1
	.by $00 ;5 P1
	.by $00 ;6 P1
	.by $00 ;7 P1
	.by $00 ;8 P1
	.by $00 ;9 P1
	.by $00 ;10 P1
	.by $00 ;11 P1
	.by $00 ;12 P1
	.by $00 ;13 P1
	.by $00 ;14 P1
	.by $00 ;15 P1
	.by $00 ;16 P1
	.by $00 ;17 P1
	.by $00 ;18 P1
	.by $00 ;19 P1
	.by $00 ;20 P1
	.by $00 ;21 P1
	.by $00 ;22 P1
	.by $00 ;23 P1
	.by $00 ;24 P1
	.by $00 ;25 P1
	.by $00 ;26 P1
	.by $00 ;27 P1
	.by $38 ;28 P1 d $38
	.by $8E ;29 P1
	.by $80 ;30 P1 d $80
	.by $01 ;31 P1 pos 75
	.by $01 ;32 P1
	.by $80 ;33 P1
	.by $80 ;34 P1 pos 77
	.by $80 ;35 P1
	.by $00 ;36 P1 d $00
	.by $80 ;37 P1 pos 78
	.by $80 ;38 P1 pos 66 size 1
	.by $51 ;39 P1 pos 65
	.by $80 ;40 P1 pos 62 d $80
	.by $19 ;41 P1 pos 66 size 0
	.by $89 ;42 P1 d $89
	.by $04 ;43 P1
	.by $18 ;44 P1 d $18
	.by $70 ;45 P1 pos 80
	.by $70 ;46 P1 pos 63
	.by $84 ;47 P1 pos 80
	.by $84 ;48 P1 pos 78
	.by $12 ;49 P1 pos 67
	.by $12 ;50 P1
	.by $82 ;51 P1
	.by $82 ;52 P1
	.by $81 ;53 P1 pos 75
	.by $81 ;54 P1 pos 78
	.by $02 ;55 P1
	.by $02 ;56 P1
	.by $84 ;57 P1
	.by $84 ;58 P1 pos 80
	.by $70 ;59 P1 pos 65
	.by $83 ;60 P1 d $83
	.by $82 ;61 P1 pos 63
	.by $82 ;62 P1 pos 62 size 1
	.by $81 ;63 P1 pos 60
	.by $80 ;64 P1 d $80
	.by $80 ;65 P1 pos 78 may be deferred 1 line, size 0 may be deferred 1 line
	.by $80 ;66 P1
	.by $80 ;67 P1
	.by $80 ;68 P1
	.by $50 ;69 P1
	.by $50 ;70 P1
	.by $08 ;71 P1
	.by $08 ;72 P1
	.by $40 ;73 P1 pos 81 may be deferred
	.by $40 ;74 P1
	.by $28 ;75 P1
	.by $28 ;76 P1
	.by $08 ;77 P1
	.by $08 ;78 P1
	.by $05 ;79 P1
	.by $05 ;80 P1
	.by $00 ;81 P1
	.by $00 ;82 P1
	.by $00 ;83 P1 yellow pos 44 size 0 may be deferred
	.by $00 ;84 P1
	.by $00 ;85 P1
	.by $00 ;86 P1
	.by $00 ;87 P1
	.by $00 ;88 P1
	.by $00 ;89 P1
	.by $00 ;90 P1
	.by $00 ;91 P1
	.by $00 ;92 P1
	.by $00 ;93 P1
	.by $00 ;94 P1
	.by $F8 ;95 P1
	.by $F8 ;96 P1
	.by $78 ;97 P1
	.by $3C ;98 P1 d $3C
	.by $00 ;99 P1
	.by $0C ;100 P1 d $0C
	.by $00 ;101 P1 brown pos 57 may be deferred
	.by $00 ;102 P1
	.by $00 ;103 P1
	.by $00 ;104 P1
	.by $00 ;105 P1
	.by $00 ;106 P1
	.by $00 ;107 P1
	.by $08 ;108 P1 d $08
	.by $20 ;109 P1
	.by $1F ;110 P1 d $1F
	.by $44 ;111 P1 pos 55
	.by $FF ;112 P1 d $FF
	.by $61 ;113 P1
	.by $A0 ;114 P1 d $A0
	.by $04 ;115 P1
	.by $42 ;116 P1 d $42
	.by $86 ;117 P1 pos 54
	.by $1A ;118 P1 pos 48 d $1A
	.by $8D ;119 P1
	.by $8D ;120 P1 pos 53 size 1
	.by $86 ;121 P1 pos 46 size 0 size may be deferred 1 line
	.by $40 ;122 P1 d $40
	.by $88 ;123 P1
	.by $56 ;124 P1 d $56
	.by $BC ;125 P1
	.by $7F ;126 P1 d $7F
	.by $E4 ;127 P1 pos 49
	.by $12 ;128 P1 pos 54 d $12
	.by $47 ;129 P1
	.by $81 ;130 P1 d $81
	.by $0F ;131 P1
	.by $42 ;132 P1 d $42
	.by $A3 ;133 P1 pos 52
	.by $A7 ;134 P1 d $A7
	.by $87 ;135 P1 pos 50
	.by $0F ;136 P1 pos 51 d $0F
	.by $A7 ;137 P1
	.by $A8 ;138 P1 d $A8
	.by $3E ;139 P1 pos 59
	.by $0F ;140 P1 d $0F
	.by $6E ;141 P1
	.by $0F ;142 P1 d $0F
	.by $1F ;143 P1
	.by $1F ;144 P1
	.by $9E ;145 P1
	.by $9E ;146 P1
	.by $3E ;147 P1
	.by $3E ;148 P1
	.by $00 ;149 P1 pos 58 may be deferred 3 lines yellow may be deferred 1 line
	.by $00 ;150 P1
	.by $00 ;151 P1 white
	.by $FF ;152 P1 d $FF
	.by $F0 ;153 P1
	.by $F0 ;154 P1 d $00
	.by $F0 ;155 P1
	.by $20 ;156 P1 d $20
	.by $00 ;157 P1
	.by $00 ;158 P1
	.by $00 ;159 P1 pos 81 grey1 may be deferred
	.by $00 ;160 P1
	.by $00 ;161 P1
	.by $00 ;162 P1
	.by $00 ;163 P1
	.by $00 ;164 P1
	.by $00 ;165 P1
	.by $00 ;166 P1
	.by $00 ;167 P1
	.by $00 ;168 P1
	.by $00 ;169 P1
	.by $00 ;170 P1
	.by $E0 ;171 P1
	.by $0F ;172 P1 d $0F
	.by $40 ;173 P1
	.by $40 ;174 P1
	.by $08 ;175 P1
	.by $02 ;176 P1 pos 86 d $02
	.by $04 ;177 P1
	.by $93 ;178 P1 light blue d $93
	.by $02 ;179 P1
	.by $28 ;180 P1 d $28 light brown
	.by $04 ;181 P1
	.by $04 ;182 P1
	.by $00 ;183 P1
	.by $00 ;184 P1
	.by $00 ;185 P1
	.by $00 ;186 P1
	.by $00 ;187 P1
	.by $00 ;188 P1
	.by $00 ;189 P1
	.by $00 ;190 P1
	.by $00 ;191 P1


 org pmLAdr + 256 * 3
;P2

	.by $00,$00,$00,$00,$00,$00,$00,$00  ;8 invisible lines

	.by $00,$00,$00,$00,$00,$00,$00,$00  ;blank lines
	.by $00,$00,$00,$00,$00,$00,$00,$00
	.by $00,$00,$00,$00

	;P2 yellow pos 62 size 3
	;M2 yellow pos 75 size 0

	;visible screen lines
	.by $00 ;0 P2
	.by $00 ;1 P2
	.by $00 ;2 P2
	.by $00 ;3 P2
	.by $00 ;4 P2
	.by $00 ;5 P2
	.by $00 ;6 P2
	.by $00 ;7 P2
	.by $00 ;8 P2
	.by $00 ;9 P2
	.by $00 ;10 P2
	.by $00 ;11 P2
	.by $00 ;12 P2
	.by $00 ;13 P2
	.by $00 ;14 P2
	.by $00 ;15 P2
	.by $00 ;16 P2
	.by $00 ;17 P2
	.by $00 ;18 P2
	.by $00 ;19 P2
	.by $00 ;20 P2
	.by $00 ;21 P2
	.by $00 ;22 P2
	.by $04 ;23 P2
	.by $04 ;24 P2
	.by $04 ;25 P2
	.by $04 ;26 P2
	.by $64 ;27 P2
	.by $64 ;28 P2
	.by $A4 ;29 P2
	.by $A4 ;30 P2 pos 82
	.by $80 ;31 P2
	.by $80 ;32 P2
	.by $80 ;33 P2
	.by $80 ;34 P2
	.by $80 ;35 P2
	.by $80 ;36 P2
	.by $E4 ;37 P2
	.by $E4 ;38 P2 pos 63
	.by $EC ;39 P2
	.by $EC ;40 P2 pos 73 size 1
	.by $FF ;41 P2 pos 68 size 3 size may be deferred 1 line
	.by $FF ;42 P2 pos 64
	.by $F0 ;43 P2
	.by $F0 ;44 P2
	.by $62 ;45 P2 size 0
	.by $62 ;46 P2 pos 65
	.by $38 ;47 P2 pos 68
	.by $38 ;48 P2
	.by $DA ;49 P2
	.by $DA ;50 P2
	.by $82 ;51 P2
	.by $82 ;52 P2 pos 76
	.by $80 ;53 P2
	.by $80 ;54 P2 pos 77
	.by $80 ;55 P2
	.by $80 ;56 P2 pos 79
	.by $99 ;57 P2
	.by $99 ;58 P2 pos 53 size 3
	.by $39 ;59 P2
	.by $3B ;60 P2 pos 55 d $3B
	.by $E8 ;61 P2
	.by $E8 ;62 P2 pos 57
	.by $E8 ;63 P2
	.by $00 ;64 P2 d $00
	.by $07 ;65 P2 pos 54
	.by $07 ;66 P2 pos 55
	.by $03 ;67 P2
	.by $03 ;68 P2
	.by $03 ;69 P2
	.by $03 ;70 P2
	.by $03 ;71 P2
	.by $03 ;72 P2
	.by $01 ;73 P2
	.by $01 ;74 P2
	.by $01 ;75 P2
	.by $01 ;76 P2
	.by $01 ;77 P2 pos 58
	.by $01 ;78 P2
	.by $01 ;79 P2
	.by $01 ;80 P2
	.by $00 ;81 P2
	.by $00 ;82 P2 green pos 43 size 0 may be deferred
	.by $00 ;83 P2
	.by $00 ;84 P2
	.by $00 ;85 P2
	.by $00 ;86 P2
	.by $00 ;87 P2
	.by $00 ;88 P2
	.by $00 ;89 P2
	.by $00 ;90 P2
	.by $00 ;91 P2
	.by $00 ;92 P2
	.by $00 ;93 P2
	.by $00 ;94 P2
	.by $80 ;95 P2
	.by $80 ;96 P2
	.by $40 ;97 P2
	.by $40 ;98 P2
	.by $7C ;99 P2 pos 45 may be deferred 2 lines
	.by $7C ;100 P2
	.by $1E ;101 P2
	.by $0E ;102 P2 d $0E
	.by $0C ;103 P2
	.by $03 ;104 P2 d $03
	.by $08 ;105 P2
	.by $03 ;106 P2 d $03
	.by $00 ;107 P2 light brown pos 36 size 3 may be deferred 1 line
	.by $02 ;108 P2 d $02
	.by $06 ;109 P2
	.by $06 ;110 P2
	.by $0E ;111 P2
	.by $0E ;112 P2 pos 34
	.by $0F ;113 P2
	.by $0F ;114 P2
	.by $1F ;115 P2
	.by $1F ;116 P2
	.by $1F ;117 P2
	.by $1F ;118 P2
	.by $3F ;119 P2 pos 37
	.by $3F ;120 P2
	.by $3F ;121 P2
	.by $3F ;122 P2
	.by $3F ;123 P2
	.by $3F ;124 P2
	.by $BF ;125 P2 pos 35
	.by $BF ;126 P2
	.by $BF ;127 P2 pos 38
	.by $3F ;128 P2 d $3F
	.by $C0 ;129 P2 pos 49
	.by $6A ;130 P2 size 0 d $6A
	.by $F5 ;131 P2
	.by $39 ;132 P2 d $39
	.by $4B ;133 P2
	.by $03 ;134 P2 d $03
	.by $EF ;135 P2 pos 47
	.by $20 ;136 P2 pos 44 d $20
	.by $80 ;137 P2
	.by $80 ;138 P2
	.by $00 ;139 P2 pos 40 size 1 may be deferred 3 lines
	.by $00 ;140 P2
	.by $01 ;141 P2
	.by $01 ;142 P2
	.by $04 ;143 P2
	.by $04 ;144 P2
	.by $98 ;145 P2 pos 41
	.by $08 ;146 P2 pos 40 may be deferred 1 line with data change d $08
	.by $70 ;147 P2
	.by $01 ;148 P2 d $01
	.by $22 ;149 P2
	.by $22 ;150 P2
	.by $60 ;151 P2 yellow
	.by $60 ;152 P2 light brown
	.by $80 ;153 P2 pos 41
	.by $50 ;154 P2 d $50
	.by $00 ;155 P2
	.by $00 ;156 P2
	.by $00 ;157 P2
	.by $00 ;158 P2 pos 77 size 0 light blue may be deferred
	.by $00 ;159 P2
	.by $00 ;160 P2
	.by $00 ;161 P2
	.by $00 ;162 P2
	.by $00 ;163 P2
	.by $00 ;164 P2
	.by $00 ;165 P2
	.by $00 ;166 P2
	.by $00 ;167 P2
	.by $00 ;168 P2
	.by $00 ;169 P2
	.by $00 ;170 P2
	.by $60 ;171 P2
	.by $60 ;172 P2
	.by $C0 ;173 P2
	.by $20 ;174 P2 d $20
	.by $10 ;175 P2 pos 89
	.by $C9 ;176 P2 d $C9
	.by $96 ;177 P2
	.by $00 ;178 P2 d $00
	.by $FF ;179 P2 brown size 1
	.by $FF ;180 P2
	.by $FF ;181 P2
	.by $FF ;182 P2
	.by $00 ;183 P2
	.by $00 ;184 P2
	.by $00 ;185 P2
	.by $00 ;186 P2
	.by $00 ;187 P2
	.by $00 ;188 P2
	.by $00 ;189 P2
	.by $00 ;190 P2
	.by $00 ;191 P2


 org pmLAdr + 256 * 4
;P3

	.by $00,$00,$00,$00,$00,$00,$00,$00  ;8 invisible lines

	.by $00,$00,$00,$00,$00,$00,$00,$00  ;blank lines
	.by $00,$00,$00,$00,$00,$00,$00,$00
	.by $00,$00,$00,$00

	;P3 white pos 42 size 0
	;M3 white pos 73 size 3

	;visible screen lines
	.by $00 ;0
	.by $00*2 ;1 P3 - dma/sh
	.by $00 ;2 P3
	.by $00 ;3 P3 - dma/sh
	.by $00 ;4 P3
	.by $00 ;5 P3 - dma/sh
	.by $00 ;6 P3
	.by $00 ;7 P3 - dma/sh
	.by $00 ;8 P3
	.by $00 ;9 P3 - dma/sh
	.by $00 ;10 P3
	.by $00 ;11 P3 - dma/sh
	.by $00 ;12 P3
	.by $00 ;13 P3 - dma/sh
	.by $00 ;14 P3
	.by $00 ;15 P3 - dma/sh
	.by $00 ;16 P3
	.by $40 ;17 P3 - dma/sh
	.by $40 ;18 P3 - no dma
	.by $C0 ;19 P3 - dma/sh
	.by $C0 ;20 P3 pos 45
	.by $80 ;21 P3 - dma/sh
	.by $80 ;22 P3 pos 46
	.by $80 ;23 P3 - dma/sh
	.by $80 ;24 P3 pos 48
	.by $80 ;25 P3
	.by $80 ;26 P3 pos 50
	.by $80 ;27 P3 pos 49
	.by $80 ;28 P3 pos 51
	.by $80 ;29 P3
	.by $80 ;30 P3 pos 53
	.by $80 ;31 P3
	.by $00 ;32 P3 d $00
	.by $80 ;33 P3 pos 54
	.by $80 ;34 P3 pos 56
	.by $80 ;35 P3
	.by $80 ;36 P3 pos 58
	.by $00 ;37 P3 pos 59
	.by $80 ;38 P3 d $80
	.by $80 ;39 P3
	.by $80 ;40 P3 pos 61
	.by $00 ;41 P3 pos 62
	.by $80 ;42 P3 d $80
	.by $80 ;43 P3
	.by $80 ;44 P3 pos 64
	.by $C0 ;45 P3 pos 63
	.by $C0 ;46 P3
	.by $E1 ;47 P3 pos 77
	.by $E1 ;48 P3
	.by $00 ;49 P3 pos 49 size 3 may be deferred
	.by $00 ;50 P3
	.by $00 ;51 P3
	.by $00 ;52 P3
	.by $00 ;53 P3
	.by $00 ;54 P3
	.by $00 ;55 P3
	.by $00 ;56 P3
	.by $00 ;57 P3
	.by $00 ;58 P3
	.by $00 ;59 P3
	.by $00 ;60 P3
	.by $00 ;61 P3
	.by $00 ;62 P3
	.by $00 ;63 P3
	.by $00 ;64 P3
	.by $F8 ;65 P3
	.by $F8 ;66 P3
	.by $F8 ;67 P3
	.by $F8 ;68 P3
	.by $F8 ;69 P3
	.by $F8 ;70 P3 pos 50
	.by $FC ;71 P3 pos 49
	.by $FC ;72 P3
	.by $FC ;73 P3
	.by $FC ;74 P3
	.by $EE ;75 P3
	.by $EE ;76 P3
	.by $CF ;77 P3
	.by $CF ;78 P3
	.by $E2 ;79 P3 pos 68
	.by $E2 ;80 P3
	.by $E3 ;81 P3 pos 69
	.by $E3 ;82 P3
	.by $23 ;83 P3
	.by $23 ;84 P3 pos 71
	.by $63 ;85 P3
	.by $63 ;86 P3
	.by $C0 ;87 P3 pos 95 size 0 size may be deferred 1 line but with data change to $80
	.by $20 ;88 P3 d $20
	.by $40 ;89 P3
	.by $20 ;90 P3 d $20
	.by $20 ;91 P3
	.by $20 ;92 P3
	.by $00 ;93 P3 pos 66 size 3 may be deferred
	.by $00 ;94 P3
	.by $00 ;95 P3
	.by $00 ;96 P3
	.by $00 ;97 P3
	.by $00 ;98 P3
	.by $00 ;99 P3
	.by $00 ;100 P3
	.by $00 ;101 P3
	.by $00 ;102 P3
	.by $F0 ;103 P3
	.by $F0 ;104 P3
	.by $F8 ;105 P3
	.by $F8 ;106 P3
	.by $F8 ;107 P3
	.by $F8 ;108 P3
	.by $F8 ;109 P3
	.by $F8 ;110 P3
	.by $FC ;111 P3 pos 63
	.by $FC ;112 P3
	.by $7C ;113 P3
	.by $7C ;114 P3
	.by $FC ;115 P3
	.by $FC ;116 P3
	.by $7C ;117 P3
	.by $7C ;118 P3
	.by $7C ;119 P3
	.by $7C ;120 P3
	.by $3C ;121 P3
	.by $3C ;122 P3
	.by $10 ;123 P3 purple pos 34 size 1
	.by $10 ;124 P3
	.by $00 ;125 P3 white may be deferred 2 lines
	.by $00 ;126 P3
	.by $C0 ;127 P3
	.by $C0 ;128 P3
	.by $E0 ;129 P3
	.by $E0 ;130 P3
	.by $60 ;131 P3
	.by $60 ;132 P3
	.by $60 ;133 P3
	.by $60 ;134 P3
	.by $30 ;135 P3
	.by $30 ;136 P3
	.by $78 ;137 P3
	.by $78 ;138 P3
	.by $30 ;139 P3
	.by $30 ;140 P3
	.by $30 ;141 P3
	.by $30 ;142 P3
	.by $00 ;143 P3 pos 47 may be deferred 4 lines
	.by $00 ;144 P3
	.by $00 ;145 P3
	.by $00 ;146 P3
	.by $C0 ;147 P3
	.by $C0 ;148 P3
	.by $C0 ;149 P3
	.by $CC ;150 P3 grey 1 d $CC
	.by $7F ;151 P3 pos 49
	.by $7F ;152 P3
	.by $3F ;153 P3
	.by $3E ;154 P3 d $3E
	.by $00 ;155 P3
	.by $00 ;156 P3
	.by $00 ;157 P3 brown pos 69 size 3 may be deferred
	.by $00 ;158 P3
	.by $00 ;159 P3
	.by $00 ;160 P3
	.by $00 ;161 P3
	.by $00 ;162 P3
	.by $00 ;163 P3
	.by $00 ;164 P3
	.by $C0 ;165 P3
	.by $C0 ;166 P3
	.by $E0 ;167 P3
	.by $E0 ;168 P3
	.by $F0 ;169 P3
	.by $F0 ;170 P3
	.by $7F ;171 P3
	.by $7F ;172 P3
	.by $7F ;173 P3
	.by $7F ;174 P3
	.by $3F ;175 P3 pos 67
	.by $3F ;176 P3
	.by $1F ;177 P3
	.by $1F ;178 P3 pos 69
	.by $60 ;179 P3 grey1 pos 71 size 1
	.by $70 ;180 P3 d $70
	.by $F0 ;181 P3
	.by $F8 ;182 P3 d $F8
	.by $F8 ;183 P3
	.by $FC ;184 P3 d $FC
	.by $F8 ;185 P3
	.by $F8 ;186 P3
	.by $78 ;187 P3
	.by $78 ;188 P3
	.by $70 ;189 P3
	.by $70 ;190 P3
	.by $00 ;191 P3


 org pmLAdr + 256 * 5
