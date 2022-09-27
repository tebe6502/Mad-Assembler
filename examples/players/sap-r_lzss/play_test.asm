
VCOUNT = $D40B
COLBAK = $D01A

	org $2000

start

    lda <song_data
    ldx >song_data

    ldy #0
    jsr init_song


wait_frame
    mva #0 colbak

wait
    lda vcount
    cmp #8
    bne wait

    mva #$0f colbak

    jsr decode_frame
    jsr play_frame

    jmp  wait_frame

ii  lda $d20a
    sta $d01a
    jmp ii


song_data
	dta a(song_end-song_data)
        ins 'humblebee.lz16'
song_end


    .align

    .link 'playlzs16_u.obx'

.print buffers

	run start
