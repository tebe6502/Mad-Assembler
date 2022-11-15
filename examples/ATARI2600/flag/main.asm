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

                WAIT_X_SCANLINES 36
                mva #0 VBLANK

                WAIT_X_SCANLINES 96

                mva #$f8 COLUBK

                WAIT_X_SCANLINES 96              

                mva #2 VBLANK

                WAIT_X_SCANLINES 30               

                jmp mainLoop    ; Go back and do another frame

//=============================================================================

                org	$fffc
                
                .word start     ; reset vector
                .word start     ; break vector                

//=============================================================================

                icl '..\vcs.mac'

//=============================================================================