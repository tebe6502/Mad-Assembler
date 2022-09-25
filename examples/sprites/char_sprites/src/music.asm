; @com.wudsn.ide.asm.mainsourcefile=char_sprites.asm
;******************************************************************

;
; MUSIC init & play
; example by Raster/C.P.U., 2003-2004
;
;
SFX_HIT         equ 0
SFX_ITEM        equ 1
SFX_INJURED     equ 2
SFX_DEAD        equ 3
SFX_ENDLEVEL    equ 4

STEREOMODE      equ 0           ;0 => compile RMTplayer for mono 4 tracks
;                               ;1 => compile RMTplayer for stereo 8 tracks
;                               ;2 => compile RMTplayer for 4 tracks stereo L1 R2 R3 L4
;                               ;3 => compile RMTplayer for 4 tracks stereo L1 L2 R3 R4
;
;
;                ORG $4800       ;place RMT player from here
.align 256

PLAYER          equ *+$400
                
:1024           DTA 0           ;make space needed for player


                icl "rmtplayr"          ;include RMT player routine on $4400

MODUL           equ RMT_MODULE_LOAD ;$DC00               ;address of RMT module

music_init
;
                ;lda #0                      ;max volume
                ;sta RMTGLOBALVOLUMEFADE
                
                ldx #<MODUL                 ;low byte of RMT module to X reg
                ldy #>MODUL                 ;hi byte of RMT module to Y reg
                ;lda #0                      ;starting song line 0-255 to A reg
                jsr RASTERMUSICTRACKER      ;Init

;Init returns instrument speed (1..4 => from 1/screen to 4/screen)
;                tay
;                lda tabpp-1,y
;                sta acpapx2+1               ;sync counter spacing
;                lda #16+0
;                sta acpapx1+1               ;sync counter init
                rts

music_play      
                jsr RASTERMUSICTRACKER+3    ;1 play
                rts

;*******************************************************
; A = sfx (instrument) number
;*******************************************************
sfx_play        
                asl                         ; * 2
                tay                         ;Y = 2,4,..,16  instrument number * 2 (0,2,4,..,126)
                ldx #1                      ;X = 3          channel (0..3 or 0..7 for stereo module)
sfx_note        lda #1                     ;A = 12         note (0..60)
                jsr RASTERMUSICTRACKER+15   ;RMT_SFX start tone (It works only if FEAT_SFX is enabled !!!)
                rts

stopmusic       jsr RASTERMUSICTRACKER+9    ;all sounds off
                rts
                
sfx_effect      dta 0                ;sfx number variable
        
