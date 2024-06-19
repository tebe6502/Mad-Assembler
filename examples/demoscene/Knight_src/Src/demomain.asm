;main code

.ifdef chk_ovrlap
 opt f+
.endif

 icl "system.inc"
 icl "demo.inc"

 icl "variables.asm"

 org startAdr

 icl "demo.asm"

 org tileMapLAdr
 icl "mapL.asm"

 org tileMapRAdr
 icl "mapR.asm"

 org picLAdr
 icl "picL.asm"
 
 org picRAdr
 icl "picR.asm"

 org scrollMemAdr
scrollMem	.ds 48

 org dlAdr
 icl "dList.asm"

 icl "handleKeyboard.asm"
 icl "tvField2VSync.asm"
 icl "dliScroll.asm"
 icl "dliCheckStability.asm"
 
 org pmLAdr
 icl "pmL.asm"
 
 org pmRAdr
 icl "pmR.asm"

 icl "dliHndL.asm"
 icl "dliHndR.asm"
 icl "scrollData.asm"
 
 run startAdr
