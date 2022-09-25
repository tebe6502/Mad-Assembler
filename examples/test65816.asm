* test na poprawnosc asemblacji
* program sklada sie z wszystkich mozliwych
* trybow i rozkazow CPU65816
* komentarz zawiera informacje o oczekiwanym wyniku asemblacji rozkazu

        opt h-
        org $8000

Z       equ $80
Q       equ $a000
W       equ $6070
T       equ $708090

        opt c+

	LDA	(Z,X)   ;$A1
	LDA	Z,S	;$A3
	LDA	Z	;$A5
	LDA	[Z]	;$A7
	LDA	#6	;$A9
	LDA	Q	;$AD
	LDA	T	;$AF
	LDA	(Z),Y	;$B1
	LDA	(Z)	;$B2
	LDA	(Z,S),Y	;$B3
	LDA	Z,X	;$B5
	LDA	[Z],Y	;$B7
	LDA	Q,Y	;$B9
	LDA	Q,X	;$BD
	LDA	T,X	;$BF

	LDX	#6	;$A2
	LDX	Z	;$A6
	LDX	Q	;$AE
	LDX	Z,Y	;$B6
	LDX	Q,Y	;$BE

	LDY	#6	;$A0
	LDY	Z	;$A4
	LDY	Q	;$AC
	LDY	Z,X	;$B4
	LDY	Q,X	;$BC

	STA	(Z,X)	;$81
	STA	Z,S	;$83
	STA	Z	;$85
	STA	[Z]	;$87
	STA	Q	;$8D
	STA	T	;$8F
	STA	(Z),Y	;$91
	STA	(Z)	;$92
	STA	(Z,S),Y	;$93
	STA	Z,X	;$95
	STA	[Z],Y	;$97
	STA	Q,Y	;$99
	STA	Q,X	;$9D
	STA	T,X	;$9F

	STX	Z	;$86
	STX	Q	;$8E
	STX	Z,Y	;$96

	STY	Z	;$84
	STY	Q	;$8C
	STY	Z,X	;$94

	ADC	(Z,X)	;$61
	ADC	Z,S	;$63
	ADC	Z	;$65
	ADC	[Z]	;$67
	ADC	#6	;$69
	ADC	Q	;$6D
	ADC	T	;$6F
	ADC	(Z),Y	;$71
	ADC	(Z)	;$72
	ADC	(Z,S),Y	;$73
	ADC	Z,X	;$75
	ADC	[Z],Y	;$77
	ADC	Q,Y	;$79
	ADC	Q,X	;$7D
	ADC	T,X	;$7F

	AND	(Z,X)	;$21
	AND	Z,S	;$23
	AND	Z	;$25
	AND	[Z]	;$27
	AND	#6	;$29
	AND	Q	;$2D
	AND	T	;$2F
	AND	(Z),Y	;$31
	AND	(Z)	;$32
	AND	(Z,S),Y	;$33
	AND	Z,X	;$35
	AND	[Z],Y	;$37
	AND	Q,Y	;$39
	AND	Q,X	;$3D
	AND	T,X	;$3F

	ASL	Z	;$06
	ASL	@	;$0A
	ASL	Q	;$0E
	ASL	Z,X	;$16
	ASL	Q,X	;$1E

	SBC	(Z,X)	;$E1
	SBC	Z,S	;$E3
	SBC	Z	;$E5
	SBC	[Z]	;$E7
	SBC	#6	;$E9
	SBC	Q	;$ED
	SBC	T	;$EF
	SBC	(Z),Y	;$F1
	SBC	(Z)	;$F2
	SBC	(Z,S),Y	;$F3
	SBC	Z,X	;$F5
	SBC	[Z],Y	;$F7
	SBC	Q,Y	;$F9
	SBC	Q,X	;$FD
	SBC	T,X	;$FF

	JSR	Q	;$20
	JSR	T	;$22
	JSR	(Q,X)	;$FC

	JMP	Q	;$4C
	JMP	T	;$5C
	JMP	(Q)	;$6C
	JMP	(Q,X)	;$7C
	JMP	[Q]	;$DC

	LSR	Z	;$46
	LSR	@	;$4A
	LSR	Q	;$4E
	LSR	Z,X	;$56
	LSR	Q,X	;$5E

	ORA	(Z,X)	;$01
	ORA	Z,S	;$03
	ORA	Z	;$05
	ORA	[Z]	;$07
	ORA	#6	;$09
	ORA	Q	;$0D
	ORA	T	;$0F
	ORA	(Z),Y	;$11
	ORA	(Z)	;$12
	ORA	(Z,S),Y	;$13
	ORA	Z,X	;$15
	ORA	[Z],Y	;$17
	ORA	Q,Y	;$19
	ORA	Q,X	;$1D
	ORA	T,X	;$1F

	CMP	(Z,X)	;$C1
	CMP	Z,S	;$C3
	CMP	Z	;$C5
	CMP	[Z]	;$C7
	CMP	#6	;$C9
	CMP	Q	;$CD
	CMP	T	;$CF
	CMP	(Z),Y	;$D1
	CMP	(Z)	;$D2
	CMP	(Z,S),Y	;$D3
	CMP	Z,X	;$D5
	CMP	[Z],Y	;$D7
	CMP	Q,Y	;$D9
	CMP	Q,X	;$DD
	CMP	T,X	;$DF

	CPY	#6	;$C0
	CPY	Z	;$C4
	CPY	Q	;$CC

	CPX	#6	;$E0
	CPX	Z	;$E4
	CPX	Q	;$EC

	DEC	@	;$3A
	DEC	Z	;$C6
	DEC	Q	;$CE
	DEC	Z,X	;$D6
	DEC	Q,X	;$DE

	INC	@	;$1A
	INC	Z	;$E6
	INC	Q	;$EE
	INC	Z,X	;$F6
	INC	Q,X	;$FE

	EOR	(Z,X)	;$41
	EOR	Z,S	;$43
	EOR	Z	;$45
	EOR	[Z]	;$47
	EOR	#6	;$49
	EOR	Q	;$4D
	EOR	T	;$4F
	EOR	(Z),Y	;$51
	EOR	(Z)	;$52
	EOR	(Z,S),Y	;$53
	EOR	Z,X	;$55
	EOR	[Z],Y	;$57
	EOR	Q,Y	;$59
	EOR	Q,X	;$5D
	EOR	T,X	;$5F

	ROL	Z	;$26
	ROL	@	;$2A
	ROL	Q	;$2E
	ROL	Z,X	;$36
	ROL	Q,X	;$3E

	ROR	Z	;$66
	ROR	@	;$6A
	ROR	Q	;$6E
	ROR	Z,X	;$76
	ROR	Q,X	;$7E

	BRK		;$00

	CLC		;$18

	CLI		;$58

	CLV		;$B8

	CLD		;$D8

	PHP		;$08

	PLP		;$28

	PHA		;$48

	PLA		;$68

	RTI		;$40

	RTS		;$60

	SEC		;$38

	SEI		;$78

	SED		;$F8

	INY		;$C8

	INX		;$E8

	DEY		;$88

	DEX		;$CA

	TXA		;$8A

	TYA		;$98

	TXS		;$9A

	TAY		;$A8

	TAX		;$AA

	TSX		;$BA

	NOP		;$EA

	BPL	*+4	;$10

	BMI	*+4	;$30

	BNE	*+4	;$D0

	BCC	*+4	;$90

	BCS	*+4	;$B0

	BEQ	*+4	;$F0

	BVC	*+4	;$50

	BVS	*+4	;$70

	BIT	Z	;$24
	BIT	Q	;$2C
	BIT	Z,X	;$34
	BIT	Q,X	;$3C
	BIT	#6	;$89

	STZ	Z	;$64
	STZ	Z,X	;$74
	STZ	Q	;$9C
	STZ	Q,X	;$9E

	SEP	#6	;$E2

	REP	#6	;$C2

	TRB	Z	;$14
	TRB	Q	;$1C

	TSB	Z	;$04
	TSB	Q	;$0C

	BRA	*+4	;$80

	BRL	W	;$82

	COP	#$056	;$02

	MVN	Z,$40	;$54

	MVP	Z,$30	;$44

	PEA	Q	;$62
	PEA	(Z)	;$D4
	PEA	#$40	;$F4

	PHB		;$8B

	PHD		;$0B

	PHK		;$4B

	PHX		;$DA

	PHY		;$5A

	PLB		;$AB

	PLD		;$2B

	PLX		;$FA

	PLY		;$7A

	RTL		;$6B

	STP		;$DB

	TCD		;$5B

	TCS		;$1B

	TDC		;$7B

	TSC		;$3B

	TXY		;$9B

	TYX		;$BB

	WAI		;$CB

	WDM		;$42

	XBA		;$EB

	XCE		;$FB
