
scrollData
; Original scroll text shown during WAP-NIAK 2012
;	dta d'Welcome to the KNIGHT demo. '
;	dta d'What you can hopefully see is 320x192 interlaced picture originally created by Levi of Samar for C64. '
;	dta d'It consists of two 15-color 160x192 sub-pictures where one is shifted horizontally a hi-res pixel distance against other. '
;	dta d'The graphic mode is called DGI - Delayed Gtia Interlace and is one of several modes based on a phenomenon called DGF - Delayed Gtia Function. '
;	dta d'The phenomenon has been discovered in 2009. Its availability depends on temperature of GTIA and ANTIC chips. '
;	dta d'Press L to see left shifted sub-picture, R for right shifted, I for both interlaced. '
;	dta d'Greetings to all Atarians and especially to attendees of WAP-NIAK 2012. '
;	dta d'Idea and code by Pavros, 2011-2012. '

scrollDataCommon .macro
	dta d'Press SPACE to pause scrolling text. '
	dta d'Presented picture of KNIGHT has been originally created by Levi (Tomasz Lewandowski) for C64 in Interlaced FLI mode and has been converted for purposes of this demo with his permission. '
	dta d'The DGI mode allows your Atari for displaying interlaced multicolor picture in horizontal resolution of 320 pixels. '
	dta d'The effect is accomplished by interlacing two multicolor sub-pictures in resolution of 160 pixels where one is shifted horizontally a hi-res pixel distance against other. '
	dta d'DGI stands for Delayed Gtia Interlace and the mode belongs to family of modes based on a phenomenon called DGF - Delayed Gtia Function. '
	dta d'The phenomenon has been discovered in 2009. Its availability depends on temperature of GTIA and ANTIC chips. '
	dta d'Press 1 to see left shifted sub-picture only, 2 for not shifted one, 3 for both interlaced - DGI mode. '
	dta d'Press 4 or 5 to see the picture in variants of DGX mode (480i). '
	dta d'DGX stands for Delayed Gtia cross(X) interlace and is a combination of horizontal (DGI) and vertical interlace, where the latter is a regular tv interlace elaborated for Atari by Rybags. '
	dta d'Greetings to all Atarians and especially to attendees of WAP-NIAK 2012. '
	dta d'Idea and code by Pavros, 2011-2012. '
	dta d'Press ESC to quit. '
.endm

	dta d'                                            '
	dta d'Welcome to DGI graphic mode demo. '
	scrollDataCommon

scrollDataLast
scrollNotReadyData
	dta d'                                            '
scrollDataEnd

	dta d'Welcome to DGI graphic mode demo. '
	dta d'WARNING! Graphic chips in your Atari are not warm enough for displaying DGF family graphic modes. '
	dta d'Please run DGF INIT program and warm up the chips. Use hair dryer for fastest effect (less than 3 minutes). '
	scrollDataCommon

scrollNotReadyDataLast
	dta d'                                            '
scrollNotReadyDataEnd
