
//---------------------------------------------------------------------
//	SPRITE RESTORE
//---------------------------------------------------------------------

.local	SpriteRestore

	sta	zp+@zp.hlp0
	sty	zp+@zp.hlp0+1

	ldy	#PlayfieldWidth*0
	mva	CharsBackupB0+0,x	(zp+@zp.hlp0),y+
	mva	CharsBackupB0+1,x	(zp+@zp.hlp0),y+
	mva	CharsBackupB0+2,x	(zp+@zp.hlp0),y+
	mva	CharsBackupB0+3,x	(zp+@zp.hlp0),y

	ldy	#PlayfieldWidth*1
	mva	CharsBackupB0+4,x	(zp+@zp.hlp0),y+
	mva	CharsBackupB0+5,x	(zp+@zp.hlp0),y+
	mva	CharsBackupB0+6,x	(zp+@zp.hlp0),y+
	mva	CharsBackupB0+7,x	(zp+@zp.hlp0),y

	ldy	#PlayfieldWidth*2
	mva	CharsBackupB0+8,x	(zp+@zp.hlp0),y+
	mva	CharsBackupB0+9,x	(zp+@zp.hlp0),y+
	mva	CharsBackupB0+10,x	(zp+@zp.hlp0),y+
	mva	CharsBackupB0+11,x	(zp+@zp.hlp0),y

	ldy	#PlayfieldWidth*3
	mva	CharsBackupB0+12,x	(zp+@zp.hlp0),y+
	mva	CharsBackupB0+13,x	(zp+@zp.hlp0),y+
	mva	CharsBackupB0+14,x	(zp+@zp.hlp0),y+
	mva	CharsBackupB0+15,x	(zp+@zp.hlp0),y

	rts
.endl

