;============================================================
;    setting up the highres screen
;============================================================

; Set up bitmap and screen data pointers

                lda #0          ; Black background and border
                sta $d020
                sta $d021
                lda #$3b        ; Bitmap mode on
                sta $d011
                lda #$18        ; Multicolor on
                sta $d016

                lda #15         ; Volume to max
                sta 54296

                lda $dd00       ; Set video bank to start at 16384
                and #252
                ora #2
                sta $dd00

                lda #$78        ; Set bitmap to top half and
                sta $d018       ; color screen to start at 39936

                lda #255        ; Activate all sprites
                sta 53269
                lda #8          ; Multicolors
                sta 53285
                lda #1
                sta 53286
                lda #255        ; Activate multicolor
                sta 53276

                lda #54         ; Turn off BASIC ROM
                sta 1

                jsr hide_sprites
                jsr setup_constants
                jsr clear_screen
                jsr draw_logo
                jsr set_gradient_colors
                ;jsr setup_intro_irq
                jsr show_credits

state_checker   ldx game_state          ; Loop that monitors state changes and
state_loop1     cpx game_state          ; jumps to the subroutine specified in state_handler+1,2
                beq state_loop1
                ldx game_state
                lda state_jumptab1,x
                sta state_handler+1
                lda state_jumptab2,x
                sta state_handler+2
state_handler   jsr begin_intro
                jmp state_checker

;============================
; Table with code addresses for setup subroutines
; for different state values
;============================

state_jumptab1    .byte <begin_intro,<start_new_game,<start_level,<activate_level,<finish_level
                .byte <increase_level,<game_over,<back_to_intro,<prep_highscore,<insert_highscore
                .byte <prep_party
state_jumptab2    .byte >begin_intro,>start_new_game,>start_level,>activate_level,>finish_level
                .byte >increase_level,>game_over,>back_to_intro,>prep_highscore,>insert_highscore
                .byte >prep_party



