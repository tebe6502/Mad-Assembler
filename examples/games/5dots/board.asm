
;*************************************  BOARD

initBoard   ; ****** Clears board memory, and loads initial setup 
 
            mwa #board dest     ; clear board
            ldy #0
@           mva #0 (dest),y
            inw dest
            cpw dest #board+(BOARD_SIZE*BOARD_SIZE)
            bne @-
            lda level           ; init layout
            clc:rol:tay
            mwa lvlptrs,y src
            ldy #0
            ldx #1   
            mwa #board dest
@           mwa (src),y dataw 
            adw dest dataw set+1
            
            cpw #0 dataw
            beq setgoal
set         stx $ffff                                        

            jsr add4Search

            iny 
            jmp @-      
            
setgoal     iny
            mwa (src),y dataw
            mva dataw timer
            sta basetimer
            iny
            mwa (src),y dataw
            mva dataw goal                           
                            ; print levelname    
setname     lda level          
            asl:tay
            mwa lvlptrs,y src
            sec          
            sbw src #16
            mwa #vram_game dest
            adw dest #866 dest
            ldy #12
@           lda (src),y
            sta (dest),y
            dey
            bpl @- 
            
            lda game_mode       ; check ARCADE MODE
            cmp #MODE_ARCADE
            sne 
            jmp arcade
            
noarcade    mwa #vram_game+226 src
            mwa #vram_game+266 dest
            jsr label
            mwa #vram_game+346 dest
            jsr label
            mwa #vram_game+626 dest
            jsr label

            
            lda game_mode       ; check 
            cmp #MODE_EXPLORE
            bne noexplore
            
            mwa #vram_game+266 dest
            mwa #hint_label src
            jsr label
            mwa #vram_game+346 dest
            mwa #undo_label src
            jsr label 

noexplore   rts

arcade      mwa #vram_game+266 dest
            mwa #timer_label src
            jsr label
            mwa #vram_game+346 dest
            mwa #goal_label src
            jsr label
            mwa #vram_game+626 dest
            mwa #arcade_label src
            
            
label       ldy #12
@           lda (src),y
            sta (dest),y
            dey
            bpl @-
           
            rts 

showBoard   ; ****** Prints board contents 
            ldx #BOARD_SIZE-1
            mwa #board src
            mwa #vram_game+41 dest
showcell    ldy #BOARD_SIZE-1
            lda (src),y
            ora #$40        ; adds 32 (to get proper chars from chartable)
.ifndef debug_mode
            and #%01111111  ; hides bit 7 (lookup marker)
.endif
            sta (dest),y
            dey
            bpl showcell+2
            adw src #BOARD_SIZE
            adw dest #40
            dex     
            bpl showcell    
            rts                 


showCursor  ; ******* jump to position

            lda cursorX
            clc:rol:rol
            add #CURSOR_OFFSET_X
            sta cursorXlast
            
            lda cursorY       
            clc:rol:rol
            add #CURSOR_OFFSET_Y
            sta cursorYlast

            mva cursorXlast moveX+1
            mva cursorYlast moveY+1
            ;sta cursorYprev
            jmp clearLast

moveCursor  ; ******* smooth movement animation 
            
            lda cursorX
            clc:rol:rol
            add #CURSOR_OFFSET_X
            sta cursorXlast
            
            lda cursorY       
            clc:rol:rol
            add #CURSOR_OFFSET_Y
            sta cursorYlast
            
clearLast   mva #2 cursor_moves
            lda:cmp:req 20      ; wait 4 VSYNC

            ldx cursorYprev     ; clear last
            mva #0 pmg+$200,x            
            sta pmg+$280,x
            inx            
            sta pmg+$280,x            

moveY       ldy #0              ; show new
            mva #128 pmg+$200,y            
            mva #192 pmg+$280,y
            sty cursorYprev
            iny
            sta pmg+$280,y
            dey            
            cpy cursorYlast     ; count target y distance
            beq moveYstop       ; reached
            bmi incY
            dec moveY+1
            jmp moveX
incY        inc moveY+1
            jmp moveX
            
moveYstop   dec cursor_moves

moveX       ldx #0
            stx hposp0
            stx hposp1
            cpx cursorXlast     ; count target x distance
            beq moveXstop       ; reached
            bmi incX 
decX        dec moveX+1
            jmp clearLast
incX        inc moveX+1 
            jmp clearLast

moveXstop   dec cursor_moves   
            sne                  ; test if target reached on both axes      
            rts
            jmp clearLast

drawLine    ; ******* draws last line from found lines array 

            dec fline_count                 ; get line from flines
            ldy fline_count                 ; and store in lines
            ldx line_count
            mva fline_sx,y line_sx,x
            sta start_x
            mva fline_sy,y line_sy,x
            sta start_y
            jsr getOffset
            mwa start_offset boardPos       ; get line start offset
            
            ldx line_count
            mva fline_cx,y line_cx,x
            sta start_x
            mva fline_cy,y line_cy,x
            sta start_y
            jsr getOffset
            mwa start_offset dataw          ; get new dot offset
            ldx line_count
            mva fline_dir,y line_dir,x
            sta line_bit
            inc line_count                  
             
            mva #BOARD_SIZE+1 pos_offset    ; offset for linebit = 4 '\'
            
            lda #2
            bit line_bit
            beq @+
            mva #1 pos_offset;              ; offset for linebit = 2 '-'

@           lda #8
            bit line_bit
            beq @+
            mva #BOARD_SIZE pos_offset      ; offset for linebit = 8 '|'

@           lda #16
            bit line_bit
            beq @+ 
            dew boardPos 
            mva #BOARD_SIZE-1 pos_offset    ; offset for linebit = 16 '/'

@           adw boardPos #board src           
            ldy #0
            ldx #4
@           lda (src),y
            ora line_bit                    ; 'or' line_bit with cell content
            sta (src),y                     
            tya 
            adc pos_offset
            tay
            dex 
            bne @- 
            

            jsr add4Search                  ; add neighbours to search lookup table
         
            inc score
            sed 
            adw arcadescore #1
            cld
            jsr updateScore

			ldy	#$22						;Y = 2,4,..,16	instrument number * 2 (0,2,4,..,126)
			ldx #3						;X = 3			channel (0..3 or 0..7 for stereo module)
			lda #12						;A = 12			note (0..60)
			jsr RASTERMUSICTRACKER+15	;RMT_SFX start tone (It works only if FEAT_SFX is enabled !!!)

            rts            

getOffset   ; ****** calc boardPosition (index)
            mva #0 start_offset+1           
            mva start_x start_offset
            ldx start_y
            beq @+1
@           adw start_offset #BOARD_SIZE 
            dex
            bne @-
@           rts


hideGuide   ; ******* clear line selection guide           
            lda cursorYprev
            tay
            lda:cmp:req 20          ; wait 4 VSYNC
                                    ; clear guide

            ldx #20
@           mva #0 pmg+$200,y
            mva #0 pmg+$300,y
            mva #0 pmg+$280,y
            mva #0 pmg+$380,y
            iny            
            dex
            bne @-
            rts
            
showGuide   ; ******* draw line selection guide   

            ldy fline_sel 
            mva fline_sx,y sx
            mva fline_sy,y sy
            mva fline_dir,y line_bit
            
            lda sx
            clc:rol:rol
            add #CURSOR_OFFSET_X
            sta cx
            
            lda sy       
            clc:rol:rol
            add #CURSOR_OFFSET_Y
            sta cy
            sta cursorYprev
            tay
            
not1        lda #2
            cmp line_bit
            bne not2        
                                    ; bit 2 - horizontal guide

            lda cx                  ; x pos
            sta hposp0              
            add #1
            sta hposp1
            add #7
            sta hposp2
            add #1
            sta hposp3

            mva #$FF pmg+$200,y     ; y pos
            mva #$FF pmg+$300,y
            mva #$FF pmg+$280,y
            mva #$FF pmg+$380,y
            
            jmp not16                        
            
not2        
            lda #4
            cmp line_bit
            bne not4        
                                    ; bit 4 - diagonal guide

            lda cx                  ; x pos
            sta hposp0              
            add #1
            sta hposp1
            add #7
            sta hposp2
            add #1
            sta hposp3

            ldx #8
            mva #%10000000 line_bit
@           mva line_bit pmg+$200,y     ; y pos
            mva line_bit pmg+$308,y     
            iny            
            mva line_bit pmg+$280,y
            mva line_bit pmg+$388,y
            lsr line_bit
            dex 
            bne @-
            
            jmp not16                        
                    
            
not4        
            lda #8
            cmp line_bit
            bne not8        
                                    ; bit 8 - vertical guide

            lda cx                  ; x pos
            sta hposp0              
            sta hposp1
            ;add #8
            sta hposp2
            sta hposp3

            ldx #16
@           mva #$80 pmg+$200,y     ; y pos
            mva #$80 pmg+$300,y
            iny
            mva #$80 pmg+$280,y
            mva #$80 pmg+$380,y
            dex
            bne @-
            
            jmp not16                        
             

not8        
            lda #16
            cmp line_bit
            bne not16        

                                    ; bit 16 - diagonal guide /

            lda cx                  ; x pos
            sub #7
            sta hposp0              
            sub #1
            sta hposp1
            sub #7
            sta hposp2
            sub #1
            sta hposp3

            ldx #8
            mva #%00000001 line_bit
            ;iny
@           mva line_bit pmg+$200,y     ; y pos
            mva line_bit pmg+$308,y     
            iny            
            mva line_bit pmg+$280,y
            mva line_bit pmg+$388,y
            asl line_bit
            dex 
            bne @-
            
            jmp not16                        

not16       lda:cmp:req 20      ; wait 4 VSYNC
            rts


updateTitleTop5
            mwa #topscore1+24 dest
            ldx #0

updateLine  mwa top5,x src
            
            ldy #0
            lda src+1
            clc
            :4 lsr
            add #16
            sta (dest),y
            iny

            lda src+1
            and #15                       
            add #16
            sta (dest),y
            iny

            lda src
            clc
            :4 lsr
            add #16
            sta (dest),y
            iny

            lda src
            and #15                       
            add #16
            sta (dest),y

            inx:inx
            cpx #10
            beq @+            
            adw dest #40
            jmp updateLine                        
@
            rts

updateScore ; *********************************** 
            mwa #vram_game+113 dest
            lda score
            jsr printNum

            lda game_mode       
            cmp #MODE_ARCADE
            bne skip_arcade 

            mwa #vram_game+634 dest
            ldy #0
            ldx #0
            
            lda arcadescore+1
            clc
            :4 lsr
            beq @+
px000       ldx #1
            add #16
            sta (dest),y
            iny

@           lda arcadescore+1
            and #15
            bne p0x00
            cpx #1
            beq p0x00
            jmp @+
p0x00       ldx #1
            add #16
            sta (dest),y
            iny

@           lda arcadescore
            clc
            :4 lsr
            bne p00x0
            cpx #1
            beq p00x0
            jmp @+
p00x0       add #16
            sta (dest),y
            iny

@           lda arcadescore
            and #15                       
            add #16
            sta (dest),y
            iny
            lda #0
            sta (dest),y                        

skip_arcade            
            rts 

updateHiScore ; *********************************** 
            mwa #476 dest
            adw dest #vram_game dest
            ldy level
            lda (hiscores), y
            jsr printNum
            rts 

updateMoves ; ***********************************
            mwa #193 dest
            adw dest #vram_game dest
            lda moves
            jsr printNum
            rts 

showLevelT  ; ************************************            
            
            mwa #[56*40+10*40+16] dest
            adw dest #vram_title dest
            lda level
            add #1
            jsr printNum
            rts 

showHiscoreT ; ************************************            
            
            ldx #0
@           lda hiscore_label,x
            sta vram_title+(56*40+12*40+27),x
            inx
            cpx #15
            bne @-
            
            mwa #[56*40+12*40+36] dest
            adw dest #vram_title dest
            ldy level
            lda (hiscores),y
            jsr printNum

            lda level          
            asl:tay
            mwa lvlptrs,y src
            sec          
            sbw src #16
            mwa #vram_title+(56*40+12*40+8) dest
            
            ldy #12
@           lda (src),y
            sta (dest),y
            dey
            bpl @-

            rts                       



showLevelG  ; ************************************            
            
            mwa #793 dest
            adw dest #vram_game dest
            lda level
            add #1
            jsr printNum
            rts 

            
showMode   ; ************************************            
            
            mwa #0 src          
            lda game_mode       
            cmp #MODE_ARCADE
            sne 
            sta level
            clc:rol:rol:rol ; multiply * 8 
            sta src
            adw src #modenames src
            mwa #vram_title dest
            adw dest #[56*40+8*40+15] dest
            ldy #7
@           lda (src),y
            sta (dest),y
            dey
            bpl @- 
            rts             
            
zeroTimer    mva rtclock zero_time
            mva rtclock+1 zero_time+1
            mva rtclock+2 zero_time+2
            rts

updateTimer lda game_mode
            cmp #MODE_ARCADE
            bne @+
            sec
            lda rtclock+2 
            sbc zero_time+2
            cmp #50
            bmi @+
            mva rtclock+2 zero_time+2
            clc
            dec timer
            bmi @+
showTimer   mwa #273 dest
            adw dest #vram_game dest
            lda timer
            jsr printNum
            jsr updateTimebar
@           rts

TIMEBAR_TOP_OFFSET = 15
TIMEBAR_HEIGHT = 96

showTimebar 
            mva #145 hposm0
            mva #205 hposm1
            mva #0 timerbarlast
            ldy #16
@           tya
            and #1
            beq @+
            :3 sec:rol
@           sta  pmg+$180,y 
            iny
            cpy #112
            bne @-1
            rts

updateTimebar
            lda basetimer ; timer * 96
            sec
            sbc timer
            sta sx
            lda #$00
            ldx #$08
            clc
m0          bcc m1
            clc
            adc #96
m1          ror
            ror sx
            dex
            bpl m0
            ldx sx            
            
            LDX #8      ; and then divided by 120
            ASL sx
L1          ROL
            BCS L2
            CMP basetimer
            BCC L3
L2          SBC basetimer
            SEC
L3          ROL sx
            DEX
            BNE L1

            lda sx      ; 15 top offset added
            clc
            adc #TIMEBAR_TOP_OFFSET+1
            ldy timerbarlast
            sta timerbarlast
            lda #0
@           sta pmg+$180,y
            iny
            cpy timerbarlast
            bmi @-

            rts


showGoal    mwa #353 dest
            adw dest #vram_game dest
            lda goal
            jsr printNum

@           rts
            
            
showHint   ;
            
            mva fline_cx cursorX
            mva fline_cy cursorY
            jsr moveCursor
            
            
endHint     mva #$ff keycode
            rts                        
            
            
updateBombs ; ******* updates bombs on puzzle mode screen  
            mwa #vram_game dest 
            adw dest #226 src
            adw dest #306 dataw
            adw dest #266 dest
            
            ldy #12
@           lda (src),y
            sta (dest),y
            sta (dataw),y
            dey
            bpl @-
            
            lda bombs
            beq @+
            ldy #0
putBomb     tya:clc:rol:tax
            mva #$54 vram_game+266,x 
            mva #$56 vram_game+267,x 
            mva #$58 vram_game+306,x 
            mva #$5a vram_game+307,x
            iny
            cpy bombs
            bne putBomb 
                
@
            rts            
            
            
updateSearch
            mwa #0 dataw
@           ldy #0 
            adw dataw #board dest
            lda (dest),y
            and #%01111111
            sta (dest),y
            inw dataw
            cpw dataw #BOARD_SIZE*BOARD_SIZE
            bne @-
            
            mwa #0 dataw
@           ldy #0 
            adw dataw #board dest
            lda (dest),y
            and #1
            seq 
            jsr add4Search                  ; add neighbours to search lookup table            
            inw dataw
            cpw dataw #BOARD_SIZE*BOARD_SIZE
            bne @-
                
            rts
            
showPadlock
 
            lda:cmp:req 20      ; wait 4 VSYNC
            ldx #0
@           :4 mva padlock+#*$40,x pmg+$400+LEVEL_PREVIEW_Y+#*$100,x           
            
            inx
            cpx #64
            bne @-
            jsr colorPreview
			
			rts			            
           
colorPreview
            ldx #0
@           lda level
            asl:asl:asl:asl
            ora pmg_colors,x
            sta colpm0,x
            inx 
            cpx #4
            bne @-
            rts
            
showPreview

			lda game_mode       ; check PUZZLE MODE
            cmp #MODE_PUZZLE
            bne @+
			lda unlocked
			cmp level
			bpl @+
			jsr showPadlock
			rts

@           lda:cmp:req 20      ; wait 4 VSYNC
            jsr colorPreview
            ldx #64
            lda #0
@           :4 sta pmg+$400+LEVEL_PREVIEW_Y+#*$100,x           
            :4 sta pmg+$401+LEVEL_PREVIEW_Y+#*$100,x
            :2 dex
            bpl @-
            
            lda level           ; read layout
            asl:tay
            mwa lvlptrs,y src
            ldy #0
@           mwa (src),y dataw 
            cpw #0 dataw
            sne
            jmp setgridpos
            sec
            sbw dataw #(BOARD_SIZE*3)
            ldx #0
mod         inx
            sec
            ;sbw dataw #BOARD_SIZE
            lda dataw
            sbc #BOARD_SIZE
            sta dataw
            bcs mod
            lda dataw+1
            beq done
            dec dataw+1
            jmp mod
done                     
            lda dataw
            adc #BOARD_SIZE
            dex
            stx sy
            sec
            sbc #3
            sta sx
            and #3
            sta cx
            mwa #pmg+$400+LEVEL_PREVIEW_Y dest
            lsr sx
            lsr sx
            beq @+
plrsel      adw dest #$100 dest
            dec sx
            bne plrsel 
@                     
            tya
            tax              
            lda sy
            asl:asl
            tay
            mva #%10000000 cy
            lda cx
            beq cstore
movebit     :2 lsr cy
            dec cx 
            bne movebit            

cstore      lda (dest),y
            ora cy
            sta (dest),y
            iny
            sta (dest),y 
            
            txa
            tay    
                
            iny
            jmp @-1      

setgridpos            

            mva #LEVEL_PREVIEW_X hposp0
            mva #LEVEL_PREVIEW_X+8 hposp1
            mva #LEVEL_PREVIEW_X+16 hposp2
            mva #LEVEL_PREVIEW_X+24 hposp3

            rts            