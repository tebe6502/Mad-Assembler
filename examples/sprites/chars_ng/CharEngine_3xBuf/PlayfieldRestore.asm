
//---------------------------------------------------------------------
//	PLAYFIELD B0 RESTORE
//---------------------------------------------------------------------

.local	PlayfieldB0_Restore

	@hlp2old B0 0
	@hlp2old B0 1
	@hlp2old B0 2
	@hlp2old B0 3
	@hlp2old B0 4
	@hlp2old B0 5
	@hlp2old B0 6

	jmp Engine.return
.endl


//---------------------------------------------------------------------
//	PLAYFIELD B1 RESTORE
//---------------------------------------------------------------------

.local	PlayfieldB1_Restore

	@hlp2old B1 0
	@hlp2old B1 1
	@hlp2old B1 2
	@hlp2old B1 3
	@hlp2old B1 4
	@hlp2old B1 5
	@hlp2old B1 6

	jmp Engine.return
.endl


//---------------------------------------------------------------------
//---------------------------------------------------------------------

.macro	@hlp2old

	lda Sprite:2.x
	beq skp

	mva	zp+@zp.old:2:1	zp+@zp.hlp0

	adb zp+@zp.old:2:1+1 >[PlayfieldBuf-Playfield:1] zp+@zp.hlp0+1

	ldy	#PlayfieldWidth*0
	mva	(zp+@zp.hlp0),y	(zp+@zp.old:2:1),y+
	mva	(zp+@zp.hlp0),y	(zp+@zp.old:2:1),y+
	mva	(zp+@zp.hlp0),y	(zp+@zp.old:2:1),y+
	mva	(zp+@zp.hlp0),y	(zp+@zp.old:2:1),y

	ldy	#PlayfieldWidth*1
	mva	(zp+@zp.hlp0),y	(zp+@zp.old:2:1),y+
	mva	(zp+@zp.hlp0),y	(zp+@zp.old:2:1),y+
	mva	(zp+@zp.hlp0),y	(zp+@zp.old:2:1),y+
	mva	(zp+@zp.hlp0),y	(zp+@zp.old:2:1),y

	ldy	#PlayfieldWidth*2
	mva	(zp+@zp.hlp0),y	(zp+@zp.old:2:1),y+
	mva	(zp+@zp.hlp0),y	(zp+@zp.old:2:1),y+
	mva	(zp+@zp.hlp0),y	(zp+@zp.old:2:1),y+
	mva	(zp+@zp.hlp0),y	(zp+@zp.old:2:1),y

	ldy	#PlayfieldWidth*3
	mva	(zp+@zp.hlp0),y	(zp+@zp.old:2:1),y+
	mva	(zp+@zp.hlp0),y	(zp+@zp.old:2:1),y+
	mva	(zp+@zp.hlp0),y	(zp+@zp.old:2:1),y+
	mva	(zp+@zp.hlp0),y	(zp+@zp.old:2:1),y

skp
.endm
