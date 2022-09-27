
	icl 'atari.hea'

	org $2000

start

    lda <song_data_L
    ldx >song_data_L

    ldy #$10
    jsr player_L.init_song


    lda <song_data_R
    ldx >song_data_R

    ldy #$00
    jsr player_R.init_song


wait_frame
l0  lda vcount
    cmp #8
    bne l0

    mva #$0f colbak

    clc
    jsr player_R.decode_frame
    clc
    jsr player_L.decode_frame

    ;bcs ii

    mva #$00 colbak

l1  lda vcount
    cmp #64
    bne l1

    mva #$08 colbak

    jsr player_R.play_frame
    jsr player_L.play_frame

    mva #$00 colbak

    jmp wait_frame

ii  lda $d20a
    sta $d01a
    jmp ii


song_data_R
	dta a(song_end_R-song_data_R)
        ins 'acid_R.lz16'
song_end_R

song_data_L
	dta a(song_end_L-song_data_L)
        ins 'acid_L.lz16'
song_end_L


    .align

.local player_R
    .link 'playlzs16_u.obx'
    :$900 brk
.endl

    .align

.local player_L
    .link 'playlzs16_u.obx'
    :$900 brk
.endl

	run start
