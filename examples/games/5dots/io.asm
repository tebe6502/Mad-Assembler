fname       dta c'D:GAMEDATA.SAV',$9b
SAVE_SIZE   equ 212

.array fbuffer [SAVE_SIZE+6] .byte = $FF
.enda
flength     dta a(.sizeof fbuffer)

error_label dta d'error:       '

IO_CHANNEL  equ 1


io_command  .by 0
io_status   .by 0
io_ready    .by 1       ; should contain 1 when last read or write operation was successful
io_rw       .by $08     ; io open type 04 read , 08 write 
crc_1       .by 0
crc_2       .by 0
crc_ok      .by 0


dataLoad
        mva #$04 io_rw
        jsr fopen
        jsr fread
        jsr fclose
        lda io_status
        beq @+
        jsr dataSave
        rts

@       jsr validatebuffer   
        lda crc_ok
        bne @+        
        jsr dataSave
        rts

@       jsr setsavedata
        rts        

safeSave 
        lda io_ready
        cmp #1
        beq dataSave
        rts
dataSave
        mva #$08 io_rw
        jsr fillbuffer
        jsr fopen
        jsr fwrite
        jsr fclose
        rts        


fillbuffer                  ; prepare data to save (encode and store CRC checksums) 
        mva #0 fbuffer+SAVE_SIZE+4
        mva #0 fbuffer+SAVE_SIZE+5
        mva random fbuffer
        mva random fbuffer+1
        mva random fbuffer+2
        mva random fbuffer+3
        ldx #0
        ldy #0
@       lda savedata,x 
        eor fbuffer+SAVE_SIZE+4
        sta fbuffer+SAVE_SIZE+4
        lda savedata,x
        add fbuffer+SAVE_SIZE+5
        sta fbuffer+SAVE_SIZE+5
        txa
        eor fbuffer,y
        eor savedata,x       
        sta fbuffer+4,x
        iny 
        cpy #4 
        bne @+
        ldy #0
@       inx
        cpx #SAVE_SIZE
        bne @-1
        rts
       
validatebuffer          ; validation result is stored in crc_ok :  1 - OK ; 0 - KO  
        mva #0 crc_1
        mva #0 crc_2
        mva #1 crc_ok
        ldx #0
        ldy #0
@       txa
        eor fbuffer,y
        eor fbuffer+4,x       
        sta fbuffer+4,x
        eor crc_1
        sta crc_1
        lda fbuffer+4,x
        add crc_2
        sta crc_2
        iny 
        cpy #4 
        bne @+
        ldy #0
@       inx
        cpx #SAVE_SIZE
        bne @-1
        lda crc_1
        cmp fbuffer+SAVE_SIZE+4
        bne crc_fail
        lda crc_2
        cmp fbuffer+SAVE_SIZE+5
        bne crc_fail
        jmp crc_exit
crc_fail
        mva #0 crc_ok
crc_exit        
        rts

setsavedata             ; move valid data from save file to memory          
        ldx #0
@       mva fbuffer+4,x savedata,x    
        inx    
        cpx #SAVE_SIZE
        bne @-
        rts
        

*--------
*- OPEN
*--------
fopen 
     
         ldx #IO_CHANNEL*16     ; channel number
         mva #0 io_status
         ;mva #0 iocb+1,x       ; device num 
         mva #$03 io_command    ; OPEN
         sta iocb+2,x 
         mva io_rw iocb+10,x    ; 4 read / 8 write 
         mwa #fname iocb+4,x   
        
         jsr ciov     
         bmi ferror   
         rts


*---------
*- CLOSE
*---------
fclose 

         ldx #IO_CHANNEL*16     ; channel number
         mva #0 io_status
         mva #$0c io_command    ; close
         sta iocb+2,x 
        
         jsr ciov           
         bmi ferror         
         rts               

*--------
*- READ
*--------
fread 

         ldx #IO_CHANNEL*16     ; channel number
         mva #0 io_status
         sta io_ready
         mva #$07 io_command    ; read
         sta iocb+2,x 
         mwa #fbuffer iocb+4,x
         mwa flength iocb+8,x
        
         jsr ciov           
         bmi ferror
         mva #1 io_ready
         rts

*---------
*- WRITE
*---------
fwrite 

         ldx #IO_CHANNEL*16     ; channel number
         mva #0 io_status
         sta io_ready
         mva #$0b io_command    ; write
         sta iocb+2,x 
         mwa #fbuffer iocb+4,x
         mwa flength iocb+8,x
        
         jsr ciov           
         bmi ferror
         mva #1 io_ready
         rts


ferror      
        ldx #IO_CHANNEL*16     ; channel number
        mva iocb+3,x io_status

.ifdef     debug_mode          ; print io error info on title screen
        ldx #0
@       lda error_label,x
        sta vram_title+(56*40+13*40+20),x
        inx
        cpx #10
        bne @-
        mwa #[56*40+13*40+30] dest
        adw dest #vram_title dest
        lda io_command 
        jsr printNum

        mwa #[56*40+13*40+35] dest
        adw dest #vram_title dest
        lda io_status 
        jsr printNum
.endif        
        rts     