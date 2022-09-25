; @com.wudsn.ide.asm.mainsourcefile=char_sprites.asm
;******************************************************************


;*** DISPLAY LIST

;                ORG DLISTSTART
.ALIGN
DLIST1           DTA BLANK8,BLANK8,BLANK8
                DTA DLI+BLANK1
DLIST_SCREEN1
                DTA HS+DLI+LMS+MODE4,a(EKR2)
:22             DTA HS+DLI+LMS+MODE4,a(EKR2+40+#*40)
                DTA HS+DLI+LMS+MODE4,a(EKR2+23*40)           ; last line DLI for sprite flip
                DTA DLIJUMP,a(DLIST1)

DLIST2           DTA BLANK8,BLANK8,BLANK8
                DTA DLI+BLANK1
DLIST_SCREEN2
                DTA HS+DLI+LMS+MODE4,a(EKR1)
:22             DTA HS+DLI+LMS+MODE4,a(EKR1+40+#*40)
                DTA HS+DLI+LMS+MODE4,a(EKR1+23*40)           ; last line DLI for sprite flip
                DTA DLIJUMP,a(DLIST2)
            
tab_dlist_lo:   .byte <DLIST1, <DLIST2
tab_dlist_hi:   .byte >DLIST1, >DLIST2
