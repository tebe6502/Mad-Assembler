//=============================================================================

                icl '..\vcs.h'
                opt f+h-

//=============================================================================

                org $f000

//=============================================================================

start           INIT_SYSTEM

mainLoop        mva #$88 COLUBK

                W_SYNC
                mva #2 VSYNC
            :3  W_SYNC
                mva #0 VSYNC

                ldx #36
@               W_SYNC
                dex
                bne @-
                mva #0 VBLANK

                ldx #96
@               W_SYNC
                dex
                bne @-

                mva #$f8 COLUBK

                ldx #96
@               W_SYNC
                dex
                bne @-                

                mva #2 VBLANK

                ldx #30
@               W_SYNC
                dex
                bne @-                

                jmp mainLoop    ; Go back and do another frame

//=============================================================================

                org	$fffc
                
                .word start     ; reset vector
                .word start     ; break vector                

//=============================================================================

                icl '..\vcs.mac'

//=============================================================================