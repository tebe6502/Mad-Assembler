 icl 'atari.hea'

            org $2000

main        mva #@dmactl(standard|dma|players|missiles|lineX1) sdmctl
            mva >$3000 pmbase     ; missiles and players data address

;            ldy #0              ; clearing pmg memory
;            lda #255 
;clrPMGt     ;
;			lda random
;			ror
;			bcs set0
;			lda #%11110000
;			jmp set
;set0		lda #%00001111
;set         :4 sta pmg+$400+#*$100,y
;            sta pmg+$300,y
;            iny
;            bne clrPMGt
            
            mva #33 gprior       ; set priority
            mva #3 pmcntl       ; enable players and missles only
            
            mva #$ff sizem
            lda #3        
            :4 sta sizep:1
            
            ldx #20
            :4 inx:inx:stx colpm:1
            inx:inx:stx 711
           
   			lda #80
            :4 sta hposm:1
            :4 sta hposp:1

            lda #$06    
            ldx >VBLANK ;HIGH BYTE OF USER ROUTINE
            ldy <VBLANK ;LOW BYTE
            jsr setvbv
   			  			         
            
loop		jmp loop

VBLANK		
			lda 19
			lsr
			lda 20
			ror
			ldx #3
@			sta hposp0,x
			sta colpm0,x
			eor #$ff
			sta hposm0,x
			eor #$ff
			asl
			dex 
			bpl @- 

            jmp sysvbv            


			org $3000
			
			org $3560
			.by %00011000
			.by %00100100
			.by %01000010
			.by %01000010
            .by %10000001
            .by %10000001
			.by %10100101
			.by %10100101
			.by %10100101
            .by %10000001
            .by %10000001
            .by %10000001
            .by %10100101
            .by %10011001
            .by %10000001
			.by %01000010
			.by %01000010
			.by %00100100
			.by %00011000
            
			org $3480
			.by %00011000
			.by %00100100
			.by %01000010
			.by %01000010
            .by %10000001
            .by %10000001
			.by %10100101
			.by %10100101
			.by %10100101
            .by %10000001
            .by %10000001
            .by %10000001
            .by %10100101
            .by %10011001
            .by %10000001
			.by %01000010
			.by %01000010
			.by %00100100
			.by %00011000
            
            
			org $36A0
			.by %00011000
			.by %00100100
			.by %01000010
			.by %01000010
            .by %10000001
            .by %10000001
			.by %10100101
			.by %10100101
			.by %10100101
            .by %10000001
            .by %10000001
            .by %10000001
            .by %10100101
            .by %10011001
            .by %10000001
			.by %01000010
			.by %01000010
			.by %00100100
			.by %00011000
            
            
			org $37C0
			.by %00011000
			.by %00100100
			.by %01000010
			.by %01000010
            .by %10000001
            .by %10000001
			.by %10100101
			.by %10100101
			.by %10100101
            .by %10000001
            .by %10000001
            .by %10000001
            .by %10100101
            .by %10011001
            .by %10000001
			.by %01000010
			.by %01000010
			.by %00100100
			.by %00011000
            
            
            run main
