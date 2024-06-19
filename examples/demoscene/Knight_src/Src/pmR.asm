
 org pmRAdr + 0
;P4/Missiles

	.by $00,$00,$00,$00,$00,$00,$00,$00  ;8 invisible lines

	.by $00,$00,$00,$00,$00,$00,$00,$00  ;blank lines
	.by $00,$00,$00,$00,$00,$00,$00,$00
	.by $00,$00,$00,$00

	;M3 size 3, M2 size 3, M1 size 0, M0 size 0
	;P3 white pos 43 size 0
	;M3 white pos 72 size 3
	;P2 yellow pos 66 size 0
	;M2 yellow pos 81 size 3
	;P1 light brown pos 66 size 0
	;M1 light brown pos 66 size 0
	;P0 pink pos 81 size 0
	;M0 pink pos 74 size 0

	;visible screen lines
	.by $00 ;0 P4
	.by $00 ;1 P4
	.by $00 ;2 P4
	.by $00 ;3 P4
	.by $00 ;4 P4
	.by $C0 ;5 P4
	.by $C0 ;6 P4
	.by $C0 ;7 P4
	.by $C0 ;8 P4
	.by $C0 ;9 P4
	.by $C0 ;10 P4
	.by $C0 ;11 P4
	.by $00 ;12 P4
	.by $00 ;13 P4
	.by $00 ;14 P4
	.by $00 ;15 P4
	.by $00 ;16 P4
	.by $C0 ;17 P4
	.by $C0 ;18 P4
	.by $C0 ;19 P4
	.by $C0 ;20 P4
	.by $C0 ;21 P4
	.by $C0 ;22 P4
	.by $C0 ;23 P4
	.by $40 ;24 P4
	.by $C0+$20 ;25 P4 M3 pos 73
	.by $C0+$10 ;26 P4
	.by $80+$20 ;27 P4 M3 pos 50 size 0
	.by $40+$20 ;28 P4
	.by $00+$20 ;29 P4 M3 pos 69 size 0 may be deferred
	.by $00+$20 ;30 P4
	.by $40+$20 ;31 P4
	.by $C0+$20 ;32 P4
	.by $C0+$20 ;33 P4 M3 pos 68 may be deferred
	.by $C0+$30 ;34 P4
	.by $C0+$30 ;35 P4
	.by $C0+$30 ;36 P4 M2 pos 80 may be deferred 2 lines
	.by $00+$30 ;37 P4 M3 pos 95 size 3 may be deferred
	.by $00+$30 ;38 P4
	.by $00+$30+$C ;39 P4
	.by $00+$10+$0 ;40 P4 M1 pos 71 may be deferred 1 line
	.by $00+$30+$8 ;41 P4
	.by $00+$20+$8 ;42 P4 M1 pos 78
	.by $00+$20+$C ;43 P4 M1 pos 81
	.by $00+$20+$0 ;44 P4 M1 pos 82 may be deferred
	.by $00+$20+$0 ;45 P4
	.by $00+$30+$8 ;46 P4
	.by $00+$20+$8 ;47 P4
	.by $00+$20+$0+$3 ;48 P4 M0 green
	.by $00+$20+$4+$1 ;49 P4
	.by $00+$00+$C ;50 P4 M0 pos 50 may be deferred
	.by $00+$20+$8 ;51 P4
	.by $00+$20+$0 ;52 P4 M1 pos 81 size 1 may be deferred 2 lines
	.by $00+$20+$0 ;53 P4
	.by $00+$00+$4 ;54 P4
	.by $00+$00+$4 ;55 P4
	.by $00+$30+$0 ;56 P4 M2 pos 79
	.by $00+$30+$0 ;57 P4
	.by $00+$30+$0 ;58 P4
	.by $00+$30+$4 ;59 P4
	.by $80+$10+$C ;60 P4 M2 pos 85
	.by $80+$10+$8 ;61 P4 M1 pos 72
	.by $80+$20+$0 ;62 P4 M2 size 0, M1 size 0, M3 pos 97 may be deferred 1 line
	.by $C0+$20+$0 ;63 P4 M1 pos 85 may be deferred 2 lines
	.by $C0+$20+$0 ;64 P4
	.by $40+$00+$8 ;65 P4 M2 pos 33 may be deferred
	.by $40+$00+$0 ;66 P4 M1 pos 86 may be deferred
	.by $40+$00+$0 ;67 P4
	.by $40+$00+$0 ;68 P4
	.by $40+$00+$0 ;69 P4
	.by $00+$00+$0 ;70 P4 M3 pos 48 may be deferred
	.by $00+$00+$0 ;71 P4
	.by $00+$00+$0 ;72 P4
	.by $00+$00+$0 ;73 P4
	.by $00+$00+$0 ;74 P4
	.by $00+$00+$0 ;75 P4
	.by $00+$00+$0 ;76 P4
	.by $80+$00+$0 ;77 P4
	.by $C0+$00+$8 ;78 P4
	.by $C0+$00+$0 ;79 P4
	.by $80+$00+$4 ;80 P4
	.by $80 ;81 P4 M1 pink may be deferred
	.by $80 ;82 P4
	.by $80 ;83 P4
	.by $80 ;84 P4
	.by $80 ;85 P4
	.by $80 ;86 P4
	.by $C0 ;87 P4 M3 pos 96 size 0
	.by $80 ;88 P4
	.by $80 ;89 P4
	.by $00 ;90 P4 M3 pos 118 size 3 may be deferred, M1 size 3 may be deferred
	.by $00 ;91 P4
	.by $00 ;92 P4
	.by $00 ;93 P4 M1 blue may be deferred 1 line
	.by $00 ;94 P4 M1 pos 102 may be deferred
	.by $00 ;95 P4
	.by $00 ;96 P4
	.by $00 ;97 P4
	.by $00 ;98 P4
	.by $00 ;99 P4 M1 light brown may be deferred
	.by $00 ;100 P4
	.by $00+$00+$0+$2 ;101 P4
	.by $00+$00+$0+$2 ;102 P4
	.by $00+$00+$0+$3 ;103 P4
	.by $00+$00+$8+$2 ;104 P4
	.by $00+$00+$8+$3 ;105 P4
	.by $C0+$00+$0+$0 ;106 P4
	.by $C0+$00+$8+$2 ;107 P4
	.by $C0+$00+$0+$0 ;108 P4 M0 brown, M0 pos 46 may be deferred
	.by $C0+$00+$4+$0 ;109 P4
	.by $C0+$00+$4+$0 ;110 P4 M1 brown, M0 light brown
	.by $C0 ;111 P4 M1 pos 49 size 0, M1 size 3 may be deferred
	.by $C0 ;112 P4
	.by $C0 ;113 P4
	.by $C0 ;114 P4
	.by $C0+$00+$0+$1 ;115 P4
	.by $C0+$00+$0+$1 ;116 P4
	.by $C0+$00+$0+$3 ;117 P4
	.by $C0+$00+$4+$0 ;118 P4 M0 purple
	.by $00+$00+$8+$0 ;119 P4 M0 pos 41 may be deferred 1 line, M3 pos 104 may be deferred
	.by $00+$00+$8+$1 ;120 P4 M1 size 3, M0 size 0
	.by $00+$00+$C+$2 ;121 P4 M1 pos 45
	.by $00+$00+$4+$2 ;122 P4 M0 yellow pos 100
	.by $00+$00+$8+$2 ;123 P4 M1 pos 68, M3 purple
	.by $00+$20+$8+$2 ;124 P4 M1 pos 67
	.by $00+$10+$8+$3 ;125 P4 M1 pos 66, M3 yellow
	.by $00+$30+$8+$3 ;126 P4 M2 pos 35 M1 pos 65, M3 white may be deferred 2 lines
	.by $00+$20+$C+$3 ;127 P4 M2 pos 37 M1 pos 63
	.by $00+$00+$C+$3 ;128 P4 M1 pos 62
	.by $00+$00+$C+$3 ;129 P4 M1 light brown pos 57 size 1, M2 brown, M1 size 1 may be deferred 1 line
	.by $00+$00+$8+$1 ;130 P4 M2 pos 65 may be deferred
	.by $00+$00+$C+$1 ;131 P4 M1 pos 56, M0 pos 56
	.by $00+$00+$0+$2 ;132 P4 M0 light brown size 1, M1 yellow size 0, pos 97 may be deferred 1 line
	.by $00+$00+$8+$0 ;133 P4 M0 pos 46 may be deferred 2 lines
	.by $00+$00+$0+$0 ;134 P4 M1 size 3 may be deferred 1 line, M3 size 0 may be deferred 1 line
	.by $80+$10+$8+$1 ;135 P4
	.by $00+$10+$0+$2 ;136 P4 M3 pos 41 may be deferred
	.by $00+$00+$0+$0 ;137 P4 M0 pos 41 may be deferred 2 lines, M2 pos 95 may be deferred 1 line
	.by $00+$10+$C+$0 ;138 P4
	.by $00+$10+$C+$1 ;139 P4 M1 pos 99
	.by $00+$00+$C+$0 ;140 P4 M1 pos 97, M2 pos 94 may be deferred
	.by $00+$00+$8+$2 ;141 P4 M1 pos 99 may be deferred 1 line, M3 yellow may be deferred
	.by $00+$00+$8+$1 ;142 P4 M0 pos 51
	.by $00+$00+$0+$2 ;143 P4 M1 pos 100 may be deferred 1 line
	.by $00+$00+$8+$2 ;144 P4 M0 pos 50
	.by $80+$00+$8+$0 ;145 P4 M0 pos 46 may be deferred 3 lines, M1 white may be deferred 2 lines
	.by $80+$00+$0+$0 ;146 P4 M1 pos 66 may be deferred, size 0 may be deferred, white may be deferred 1 line, M2 size 1 may be deferred
	.by $80+$00+$0+$0 ;147 P4
	.by $80+$00+$0+$2 ;148 P4
	.by $80+$00+$0+$0 ;149 P4 M0 pos 66 may be deferred 1 line
	.by $80+$20+$0+$2 ;150 P4 M2 grey 1
	.by $C0+$00+$8+$0 ;151 P4 M1 yellow, M3 white pos 68
	.by $00+$10+$8+$0 ;152 P4 M2 pos 62
	.by $C0+$30+$8+$0 ;153 P4 M3 pos 94
	.by $C0+$00+$8+$0 ;154 P4 M3 size 1, M2 size 0 may be deferred, M0 size 0 may be deferred
	.by $C0+$00+$8+$0 ;155 P4 M3 pos 95
	.by $00+$00+$8+$0 ;156 P4 M3 brown may be deferred
	.by $00+$00+$8+$0 ;157 P4 M2 light blue pos 95 may be deferred
	.by $00+$00+$8+$0 ;158 P4
	.by $00+$00+$8+$0 ;159 P4
	.by $00 ;160 P4
	.by $00 ;161 P4
	.by $00 ;162 P4
	.by $00 ;163 P4
	.by $00 ;164 P4
	.by $00 ;165 P4
	.by $00 ;166 P4
	.by $00+$00+$0+$1 ;167 P4
	.by $00+$00+$0+$1 ;168 P4
	.by $00+$00+$0+$2 ;169 P4
	.by $00+$00+$0+$1 ;170 P4
	.by $00 ;171 P4 M0 grey 1, M0 pos 78 may be deferred 2 lines
	.by $00 ;172 P4
	.by $00+$00+$0+$2 ;173 P4 M1 grey2
	.by $00 ;174 P4 M0 pos 95 may be deferred 1 line
	.by $00+$00+$0+$2 ;175 P4
	.by $00+$20+$0+$0 ;176 P4 M0 pos 50 size 1 may be deferred 4 lines
	.by $00+$20+$0+$0 ;177 P4
	.by $00+$20+$0+$0 ;178 P4
	.by $00+$20+$0+$0 ;179 P4 M2 pos 92
	.by $00+$00+$0+$3 ;180 P4 M2 grey1 M1 white M0 red
	.by $00+$10+$0+$3 ;181 P4 M2 pos 80
	.by $00+$00+$0+$3 ;182 P4
	.by $00+$00+$0+$3 ;183 P4
	.by $00+$00+$0+$3 ;184 P4
	.by $00+$10+$0+$3 ;185 P4
	.by $00+$00+$0+$3 ;186 P4
	.by $00+$00+$0+$3 ;187 P4
	.by $00+$00+$0+$3 ;188 P4
	.by $00+$00+$0+$3 ;189 P4
	.by $00+$00+$0+$3 ;190 P4
	.by $00+$00+$0+$3 ;191 P4



 org pmRAdr + 256 * 1
;P0

	.by $00,$00,$00,$00,$00,$00,$00,$00  ;8 invisible lines

	.by $00,$00,$00,$00,$00,$00,$00,$00  ;blank lines
	.by $00,$00,$00,$00,$00,$00,$00,$00
	.by $00,$00,$00,$00

	;P0 pink pos 81 size 0
	;M0 pink pos 74 size 0

	;visible screen lines
	.by $00 ;0 P0
	.by $00 ;1 P0
	.by $00 ;2 P0
	.by $00 ;3 P0
	.by $00 ;4 P0
	.by $00 ;5 P0
	.by $00 ;6 P0
	.by $00 ;7 P0
	.by $00 ;8 P0
	.by $00 ;9 P0
	.by $00 ;10 P0
	.by $00 ;11 P0
	.by $00 ;12 P0
	.by $00 ;13 P0
	.by $00 ;14 P0
	.by $00 ;15 P0
	.by $00 ;16 P0
	.by $00 ;17 P0
	.by $00 ;18 P0
	.by $00 ;19 P0
	.by $00 ;20 P0
	.by $00 ;21 P0
	.by $00 ;22 P0
	.by $80 ;23 P0
	.by $80 ;24 P0
	.by $00 ;25 P0
	.by $40 ;26 P0
	.by $00 ;27 P0
	.by $00 ;28 P0
	.by $00 ;29 P0
	.by $00 ;30 P0
	.by $00 ;31 P0
	.by $02 ;32 P0
	.by $04 ;33 P0
	.by $00 ;34 P0
	.by $00 ;35 P0
	.by $02 ;36 P0
	.by $04 ;37 P0
	.by $00 ;38 P0
	.by $0C ;39 P0 green
	.by $20 ;40 P0 pink
	.by $20 ;41 P0
	.by $20 ;42 P0
	.by $20 ;43 P0
	.by $20 ;44 P0
	.by $20 ;45 P0
	.by $20 ;46 P0
	.by $20 ;47 P0
	.by $00 ;48 P0 green
	.by $00 ;49 P0
	.by $00 ;50 P0
	.by $00 ;51 P0
	.by $00 ;52 P0
	.by $00 ;53 P0
	.by $00 ;54 P0
	.by $00 ;55 P0
	.by $C0 ;56 P0
	.by $40 ;57 P0
	.by $00 ;58 P0 light brown
	.by $40 ;59 P0 pos 65
	.by $00 ;60 P0
	.by $00 ;61 P0 green
	.by $08 ;62 P0
	.by $08 ;63 P0
	.by $80 ;64 P0 pos 71
	.by $A0 ;65 P0
	.by $80 ;66 P0
	.by $24 ;67 P0
	.by $20 ;68 P0
	.by $20 ;69 P0
	.by $20 ;70 P0
	.by $60 ;71 P0
	.by $90 ;72 P0 pos 76
	.by $90 ;73 P0
	.by $90 ;74 P0
	.by $92 ;75 P0
	.by $02 ;76 P0
	.by $02 ;77 P0
	.by $00 ;78 P0 pos 81 may be deferred 2 lines
	.by $00 ;79 P0
	.by $90 ;80 P0
	.by $90 ;81 P0
	.by $80 ;82 P0
	.by $00 ;83 P0 pos 42 may be deferred
	.by $00 ;84 P0
	.by $00 ;85 P0
	.by $00 ;86 P0
	.by $00 ;87 P0
	.by $00 ;88 P0
	.by $00 ;89 P0
	.by $00 ;90 P0
	.by $00 ;91 P0
	.by $00 ;92 P0
	.by $00 ;93 P0
	.by $00 ;94 P0
	.by $78 ;95 P0
	.by $F0 ;96 P0
	.by $00 ;97 P0
	.by $07 ;98 P0
	.by $00 ;99 P0
	.by $03 ;100 P0
	.by $03 ;101 P0
	.by $01 ;102 P0
	.by $01 ;103 P0
	.by $00 ;104 P0 pos 55 may be deferred
	.by $00 ;105 P0
	.by $00 ;106 P0
	.by $00 ;107 P0
	.by $02 ;108 P0 brown
	.by $0C ;109 P0
	.by $70 ;110 P0 light brown
	.by $99 ;111 P0
	.by $24 ;112 P0 pos 56 may be deferred 4 lines
	.by $16 ;113 P0
	.by $9E ;114 P0
	.by $14 ;115 P0
	.by $05 ;116 P0
	.by $00 ;117 P0 pos 33 may be deferred 1 line
	.by $03 ;118 P0 purple
	.by $8A ;119 P0
	.by $78 ;120 P0
	.by $98 ;121 P0
	.by $00 ;122 P0 yellow
	.by $80 ;123 P0
	.by $40 ;124 P0
	.by $4C ;125 P0 size 1 pos 34
	.by $74 ;126 P0 pos 35
	.by $02 ;127 P0 size 0 pos 41
	.by $00 ;128 P0
	.by $00 ;129 P0
	.by $01 ;130 P0
	.by $00 ;131 P0 pos 48
	.by $2A ;132 P0 light brown
	.by $B4 ;133 P0 pos 51
	.by $F2 ;134 P0 pos 54
	.by $98 ;135 P0 pos 52
	.by $C6 ;136 P0
	.by $50 ;137 P0
	.by $1E ;138 P0
	.by $F8 ;139 P0 pos 56
	.by $56 ;140 P0
	.by $2F ;141 P0
	.by $0B ;142 P0 pos 55 may be deferred 1 line
	.by $88 ;143 P0
	.by $06 ;144 P0
	.by $0E ;145 P0
	.by $02 ;146 P0
	.by $10 ;147 P0
	.by $80 ;148 P0
	.by $01 ;149 P0 pos 46
	.by $01 ;150 P0 pos 44
	.by $82 ;151 P0
	.by $04 ;152 P0
	.by $10 ;153 P0 pos 40
	.by $40 ;154 P0
	.by $21 ;155 P0
	.by $00 ;156 P0
	.by $00 ;157 P0
	.by $00 ;158 P0
	.by $00 ;159 P0
	.by $00 ;160 P0
	.by $00 ;161 P0
	.by $00 ;162 P0
	.by $00 ;163 P0
	.by $00 ;164 P0
	.by $00 ;165 P0
	.by $00 ;166 P0
	.by $00 ;167 P0
	.by $00 ;168 P0
	.by $00 ;169 P0
	.by $00 ;170 P0
	.by $C0 ;171 P0 grey 1
	.by $30 ;172 P0
	.by $02 ;173 P0
	.by $80 ;174 P0 pos 81
	.by $80 ;175 P0 pos 85
	.by $99 ;176 P0
	.by $01 ;177 P0
	.by $00 ;178 P0 pos 74
	.by $C0 ;179 P0
	.by $00 ;180 P0 red pos 50
	.by $00 ;181 P0
	.by $00 ;182 P0
	.by $00 ;183 P0
	.by $00 ;184 P0
	.by $00 ;185 P0
	.by $00 ;186 P0
	.by $00 ;187 P0
	.by $00 ;188 P0
	.by $00 ;189 P0
	.by $00 ;190 P0
	.by $00 ;191 P0


 org pmRAdr + 256 * 2
;P1

	.by $00,$00,$00,$00,$00,$00,$00,$00  ;8 invisible lines

	.by $00,$00,$00,$00,$00,$00,$00,$00  ;blank lines
	.by $00,$00,$00,$00,$00,$00,$00,$00
	.by $00,$00,$00,$00

	;P1 light brown pos 66 size 0

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
	.by $78 ;28 P1
	.by $86 ;29 P1
	.by $01 ;30 P1
	.by $20 ;31 P1 pos 72
	.by $10 ;32 P1
	.by $08 ;33 P1
	.by $00 ;34 P1
	.by $04 ;35 P1
	.by $02 ;36 P1
	.by $00 ;37 P1
	.by $E1 ;38 P1
	.by $80 ;39 P1 pos 73
	.by $25 ;40 P1
	.by $8A ;41 P1
	.by $E8 ;42 P1 pos 68
	.by $A2 ;43 P1 pos 64
	.by $03 ;44 P1
	.by $11 ;45 P1
	.by $01 ;46 P1
	.by $01 ;47 P1
	.by $92 ;48 P1 pos 78
	.by $60 ;49 P1 pos 69
	.by $90 ;50 P1
	.by $00 ;51 P1 pos 76 may be deferred 3 lines
	.by $00 ;52 P1
	.by $00 ;53 P1
	.by $80 ;54 P1
	.by $40 ;55 P1
	.by $20 ;56 P1
	.by $00 ;57 P1
	.by $10 ;58 P1
	.by $41 ;59 P1 pos 65 size 1
	.by $86 ;60 P1 size 0
	.by $08 ;61 P1 pos 59
	.by $10 ;62 P1
	.by $20 ;63 P1
	.by $C0 ;64 P1
	.by $80 ;65 P1 pos 77
	.by $00 ;66 P1
	.by $00 ;67 P1
	.by $20 ;68 P1
	.by $00 ;69 P1
	.by $00 ;70 P1
	.by $08 ;71 P1
	.by $80 ;72 P1 pink pos 63
	.by $80 ;73 P1
	.by $02 ;74 P1 light brown pos 77
	.by $00 ;75 P1 size 3 pos 70 may be deferred
	.by $00 ;76 P1
	.by $00 ;77 P1
	.by $00 ;78 P1
	.by $00 ;79 P1
	.by $00 ;80 P1
	.by $00 ;81 P1 purple may be deferred
	.by $00 ;82 P1
	.by $00 ;83 P1
	.by $00 ;84 P1
	.by $00 ;85 P1
	.by $00 ;86 P1
	.by $00 ;87 P1
	.by $00 ;88 P1
	.by $80 ;89 P1
	.by $00 ;90 P1
	.by $80 ;91 P1
	.by $80 ;92 P1
	.by $00 ;93 P1 blue may be deferred 1 line
	.by $10 ;94 P1
	.by $20 ;95 P1
	.by $30 ;96 P1
	.by $30 ;97 P1
	.by $00 ;98 P1 pos 46 may be deferred
	.by $00 ;99 P1 light brown may be deferred
	.by $00 ;100 P1
	.by $00 ;101 P1
	.by $00 ;102 P1
	.by $00 ;103 P1
	.by $00 ;104 P1
	.by $00 ;105 P1
	.by $00 ;106 P1
	.by $00 ;107 P1
	.by $00 ;108 P1
	.by $00 ;109 P1
	.by $18 ;110 P1 brown
	.by $38 ;111 P1
	.by $38 ;112 P1
	.by $38 ;113 P1
	.by $38 ;114 P1
	.by $38 ;115 P1
	.by $38 ;116 P1
	.by $38 ;117 P1
	.by $80 ;118 P1 pos 54 size 0
	.by $25 ;119 P1 pos 60
	.by $44 ;120 P1
	.by $88 ;121 P1 size 1
	.by $08 ;122 P1
	.by $8F ;123 P1 size 0 pos 46
	.by $8F ;124 P1
	.by $CF ;125 P1
	.by $21 ;126 P1 pos 48
	.by $B0 ;127 P1
	.by $65 ;128 P1 pos 49
	.by $9A ;129 P1 light brown
	.by $19 ;130 P1
	.by $AA ;131 P1 pos 48
	.by $00 ;132 P1 yellow pos 41, pos 41 may be deferred 2 lines
	.by $00 ;133 P1
	.by $03 ;134 P1
	.by $0E ;135 P1
	.by $18 ;136 P1
	.by $30 ;137 P1
	.by $20 ;138 P1
	.by $40 ;139 P1
	.by $40 ;140 P1
	.by $03 ;141 P1 size 1 pos 40, pos 40 may be deferred 1 line
	.by $87 ;142 P1
	.by $8C ;143 P1
	.by $88 ;144 P1
	.by $00 ;145 P1
	.by $00 ;146 P1 white may be deferred 1 line
	.by $0C ;147 P1
	.by $08 ;148 P1
	.by $08 ;149 P1
	.by $0B ;150 P1
	.by $C8 ;151 P1 yellow pos 41
	.by $D0 ;152 P1
	.by $C3 ;153 P1 size 0
	.by $42 ;154 P1
	.by $84 ;155 P1
	.by $84 ;156 P1
	.by $88 ;157 P1
	.by $21 ;158 P1 pos 38
	.by $21 ;159 P1
	.by $22 ;160 P1
	.by $22 ;161 P1
	.by $42 ;162 P1
	.by $44 ;163 P1
	.by $44 ;164 P1
	.by $44 ;165 P1
	.by $44 ;166 P1
	.by $84 ;167 P1
	.by $80 ;168 P1
	.by $40 ;169 P1
	.by $02 ;170 P1
	.by $06 ;171 P1
	.by $04 ;172 P1
	.by $00 ;173 P1 grey2 pos 72 may be deferred 5 lines
	.by $00 ;174 P1
	.by $00 ;175 P1
	.by $00 ;176 P1
	.by $00 ;177 P1
	.by $10 ;178 P1
	.by $CE ;179 P1
	.by $20 ;180 P1 white
	.by $3C ;181 P1
	.by $7C ;182 P1
	.by $3F ;183 P1
	.by $3F ;184 P1
	.by $1E ;185 P1
	.by $30 ;186 P1
	.by $18 ;187 P1
	.by $00 ;188 P1
	.by $00 ;189 P1
	.by $00 ;190 P1
	.by $00 ;191 P1


 org pmRAdr + 256 * 3
;P2

	.by $00,$00,$00,$00,$00,$00,$00,$00  ;8 invisible lines

	.by $00,$00,$00,$00,$00,$00,$00,$00  ;blank lines
	.by $00,$00,$00,$00,$00,$00,$00,$00
	.by $00,$00,$00,$00

	;P2 yellow pos 66 size 0
	;M2 yellow pos 81 size 3

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
	.by $00 ;23 P2
	.by $00 ;24 P2
	.by $00 ;25 P2
	.by $00 ;26 P2
	.by $78 ;27 P2
	.by $86 ;28 P2
	.by $01 ;29 P2
	.by $80 ;30 P2 pos 74
	.by $40 ;31 P2
	.by $20 ;32 P2
	.by $10 ;33 P2
	.by $10 ;34 P2
	.by $08 ;35 P2
	.by $04 ;36 P2
	.by $04 ;37 P2
	.by $78 ;38 P2 pos 63 size 1 size may be deferred 1 line but data change required
	.by $CE ;39 P2
	.by $87 ;40 P2 pos 62
	.by $72 ;41 P2 pos 65
	.by $D1 ;42 P2
	.by $B0 ;43 P2
	.by $60 ;44 P2
	.by $80 ;45 P2
	.by $80 ;46 P2
	.by $03 ;47 P2
	.by $20 ;48 P2 pos 66
	.by $50 ;49 P2
	.by $58 ;50 P2
	.by $88 ;51 P2
	.by $08 ;52 P2
	.by $04 ;53 P2
	.by $04 ;54 P2
	.by $02 ;55 P2
	.by $02 ;56 P2
	.by $00 ;57 P2
	.by $20 ;58 P2 pos 58 size 3
	.by $E2 ;59 P2 pos 61
	.by $50 ;60 P2 pos 59
	.by $98 ;61 P2
	.by $91 ;62 P2 pos 61
	.by $89 ;63 P2 pos 60
	.by $08 ;64 P2
	.by $0C ;65 P2 pos 59 may be deferred 3 lines
	.by $0C ;66 P2
	.by $04 ;67 P2
	.by $06 ;68 P2
	.by $0A ;69 P2 pos 61 may be deferred 5 lines
	.by $06 ;70 P2
	.by $06 ;71 P2
	.by $06 ;72 P2
	.by $06 ;73 P2
	.by $06 ;74 P2
	.by $06 ;75 P2
	.by $02 ;76 P2
	.by $02 ;77 P2
	.by $02 ;78 P2
	.by $02 ;79 P2
	.by $00 ;80 P2 pos 43 may be deferred
	.by $00 ;81 P2
	.by $00 ;82 P2
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
	.by $00 ;95 P2
	.by $C0 ;96 P2
	.by $C0 ;97 P2
	.by $80 ;98 P2
	.by $40 ;99 P2
	.by $40 ;100 P2
	.by $00 ;101 P2 pos 104 may be deferred
	.by $00 ;102 P2
	.by $00 ;103 P2
	.by $00 ;104 P2
	.by $00 ;105 P2
	.by $80 ;106 P2
	.by $80 ;107 P2
	.by $80 ;108 P2
	.by $00 ;109 P2 light brown pos 38 size 3 may be deferred
	.by $00 ;110 P2
	.by $00 ;111 P2
	.by $00 ;112 P2
	.by $00 ;113 P2
	.by $00 ;114 P2
	.by $00 ;115 P2
	.by $00 ;116 P2
	.by $00 ;117 P2
	.by $3E ;118 P2
	.by $3E ;119 P2
	.by $3F ;120 P2
	.by $3F ;121 P2
	.by $3F ;122 P2
	.by $3F ;123 P2
	.by $3F ;124 P2
	.by $3F ;125 P2
	.by $7F ;126 P2
	.by $BF ;127 P2
	.by $3F ;128 P2 pos 39
	.by $3F ;129 P2 brown
	.by $3F ;130 P2 pos 40
	.by $3F ;131 P2 pos 38
	.by $3F ;132 P2
	.by $1F ;133 P2
	.by $1F ;134 P2
	.by $1E ;135 P2
	.by $1E ;136 P2
	.by $1E ;137 P2 pos 40
	.by $1E ;138 P2
	.by $1E ;139 P2
	.by $1E ;140 P2
	.by $0E ;141 P2
	.by $0E ;142 P2
	.by $0E ;143 P2
	.by $0E ;144 P2
	.by $0E ;145 P2
	.by $0E ;146 P2
	.by $06 ;147 P2
	.by $04 ;148 P2 pos 41
	.by $04 ;149 P2
	.by $50 ;150 P2 grey 1
	.by $68 ;151 P2
	.by $A0 ;152 P2 size 0 pos 52
	.by $7C ;153 P2
	.by $F8 ;154 P2 pos 56
	.by $00 ;155 P2
	.by $00 ;156 P2
	.by $00 ;157 P2 light blue pos 78 may be deferred
	.by $00 ;158 P2 size 1 may be deferred
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
	.by $80 ;171 P2
	.by $80 ;172 P2
	.by $E0 ;173 P2
	.by $F8 ;174 P2
	.by $7F ;175 P2 pos 77
	.by $7F ;176 P2 pos 78
	.by $1D ;177 P2
	.by $1D ;178 P2
	.by $00 ;179 P2 pos 71
	.by $70 ;180 P2 grey1
	.by $F0 ;181 P2
	.by $F8 ;182 P2
	.by $F8 ;183 P2
	.by $F8 ;184 P2
	.by $78 ;185 P2
	.by $F8 ;186 P2
	.by $F8 ;187 P2
	.by $70 ;188 P2
	.by $30 ;189 P2
	.by $00 ;190 P2
	.by $00 ;191 P2


 org pmRAdr + 256 * 4
;P3

	.by $00,$00,$00,$00,$00,$00,$00,$00  ;8 invisible lines

	.by $00,$00,$00,$00,$00,$00,$00,$00  ;blank lines
	.by $00,$00,$00,$00,$00,$00,$00,$00
	.by $00,$00,$00,$00

	;visible screen lines
	.by $00 ;0 P3 white pos 43 size 0
	.by $00 ;1 P3
	.by $00 ;2 P3
	.by $00 ;3 P3
	.by $00 ;4 P3
	.by $00 ;5 P3
	.by $00 ;6 P3
	.by $00 ;7 P3
	.by $00 ;8 P3
	.by $00 ;9 P3
	.by $00 ;10 P3
	.by $00 ;11 P3
	.by $00 ;12 P3
	.by $00 ;13 P3
	.by $00 ;14 P3
	.by $00 ;15 P3
	.by $00 ;16 P3
	.by $00 ;17 P3
	.by $80 ;18 P3
	.by $80 ;19 P3
	.by $40 ;20 P3
	.by $20 ;21 P3
	.by $10 ;22 P3
	.by $08 ;23 P3
	.by $00 ;24 P3
	.by $04 ;25 P3
	.by $02 ;26 P3
	.by $81 ;27 P3 pos 72
	.by $00 ;28 P3 pos 52 may be deferred
	.by $00 ;29 P3
	.by $80 ;30 P3
	.by $40 ;31 P3 pos 68
	.by $20 ;32 P3
	.by $10 ;33 P3
	.by $00 ;34 P3
	.by $08 ;35 P3
	.by $04 ;36 P3
	.by $02 ;37 P3
	.by $01 ;38 P3
	.by $00 ;39 P3 pos 60 may be deferred
	.by $80 ;40 P3
	.by $40 ;41 P3
	.by $00 ;42 P3
	.by $20 ;43 P3
	.by $10 ;44 P3
	.by $00 ;45 P3 pos 77 may be deferred
	.by $00 ;46 P3
	.by $01 ;47 P3
	.by $80 ;48 P3
	.by $00 ;49 P3
	.by $00 ;50 P3
	.by $00 ;51 P3
	.by $20 ;52 P3 pos 67
	.by $60 ;53 P3
	.by $40 ;54 P3
	.by $C0 ;55 P3
	.by $80 ;56 P3
	.by $00 ;57 P3 pos 50 size 3 may be deferred
	.by $00 ;58 P3
	.by $00 ;59 P3
	.by $00 ;60 P3
	.by $00 ;61 P3
	.by $00 ;62 P3
	.by $00 ;63 P3
	.by $00 ;64 P3
	.by $00 ;65 P3
	.by $F8 ;66 P3
	.by $F8 ;67 P3
	.by $F8 ;68 P3
	.by $FC ;69 P3
	.by $F8 ;70 P3
	.by $FC ;71 P3
	.by $FC ;72 P3
	.by $FC ;73 P3
	.by $EC ;74 P3
	.by $FE ;75 P3
	.by $FE ;76 P3
	.by $E0 ;77 P3 pos 65
	.by $F0 ;78 P3
	.by $F1 ;79 P3
	.by $F1 ;80 P3
	.by $E3 ;81 P3 pos 69
	.by $E3 ;82 P3
	.by $E3 ;83 P3
	.by $F3 ;84 P3 pos 70
	.by $F3 ;85 P3
	.by $E3 ;86 P3
	.by $81 ;87 P3 pos 46
	.by $80 ;88 P3
	.by $80 ;89 P3
	.by $80 ;90 P3
	.by $80 ;91 P3
	.by $80 ;92 P3
	.by $80 ;93 P3
	.by $80 ;94 P3
	.by $00 ;95 P3 pos 66 may be deferred
	.by $00 ;96 P3
	.by $00 ;97 P3
	.by $00 ;98 P3
	.by $00 ;99 P3
	.by $00 ;100 P3
	.by $00 ;101 P3
	.by $F8 ;102 P3
	.by $F8 ;103 P3
	.by $F8 ;104 P3
	.by $F8 ;105 P3
	.by $F8 ;106 P3
	.by $F8 ;107 P3
	.by $F8 ;108 P3
	.by $F8 ;109 P3
	.by $F8 ;110 P3
	.by $F8 ;111 P3
	.by $F8 ;112 P3
	.by $F8 ;113 P3
	.by $F8 ;114 P3
	.by $F8 ;115 P3
	.by $F8 ;116 P3
	.by $F8 ;117 P3 pos 68 may be deferred 2 lines
	.by $F8 ;118 P3
	.by $F8 ;119 P3
	.by $F8 ;120 P3
	.by $40 ;121 P3
	.by $00 ;122 P3 pos 34 size 0 may be deferred 1 line
	.by $03 ;123 P3 purple
	.by $04 ;124 P3
	.by $40 ;125 P3 yellow
	.by $00 ;126 P3 white size 1 may be deferred 2 lines
	.by $00 ;127 P3
	.by $C0 ;128 P3
	.by $C0 ;129 P3
	.by $C0 ;130 P3
	.by $E0 ;131 P3
	.by $E0 ;132 P3
	.by $60 ;133 P3
	.by $60 ;134 P3
	.by $70 ;135 P3
	.by $70 ;136 P3
	.by $30 ;137 P3
	.by $30 ;138 P3
	.by $30 ;139 P3
	.by $30 ;140 P3
	.by $00 ;141 P3 yellow may be deferred
	.by $00 ;142 P3 pos 44 may be deferred
	.by $00 ;143 P3
	.by $00 ;144 P3
	.by $60 ;145 P3
	.by $40 ;146 P3
	.by $43 ;147 P3
	.by $8C ;148 P3
	.by $E4 ;149 P3 size 3
	.by $C0 ;150 P3
	.by $30 ;151 P3 white pos 49 size 1
	.by $1F ;152 P3
	.by $06 ;153 P3 pos 48
	.by $00 ;154 P3
	.by $00 ;155 P3 pos 67 size 3 may be deferred
	.by $00 ;156 P3 brown may be deferred
	.by $00 ;157 P3
	.by $00 ;158 P3
	.by $00 ;159 P3
	.by $00 ;160 P3
	.by $00 ;161 P3
	.by $00 ;162 P3
	.by $00 ;163 P3
	.by $00 ;164 P3
	.by $40 ;165 P3
	.by $60 ;166 P3
	.by $60 ;167 P3
	.by $E0 ;168 P3
	.by $70 ;169 P3
	.by $70 ;170 P3
	.by $7F ;171 P3
	.by $7F ;172 P3
	.by $7F ;173 P3
	.by $7F ;174 P3
	.by $3F ;175 P3
	.by $3F ;176 P3
	.by $3F ;177 P3 pos 68
	.by $1F ;178 P3
	.by $1F ;179 P3 pos 69
	.by $0F ;180 P3 pos 67
	.by $07 ;181 P3
	.by $03 ;182 P3
	.by $00 ;183 P3
	.by $00 ;184 P3
	.by $00 ;185 P3
	.by $00 ;186 P3
	.by $00 ;187 P3
	.by $00 ;188 P3
	.by $00 ;189 P3
	.by $00 ;190 P3
	.by $00 ;191 P3


 org pmRAdr + 256 * 5
