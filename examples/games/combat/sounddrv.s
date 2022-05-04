		.pages 1
audio_tabs:
audio_lotab:
		:32 dta <((#+1)*57-7)

audio_lotabp4:
		:32 dta <(((#+1)*57)/3*3+2-7)

audio_lotab6:
		:32 dta <((#+1)*57*3-7)

audio_lotab15:
;		:32 dta <(((#+1)*57*15)-7-1)
		:32 dta <((#+1)*57*15+1-7)

audio_lotab31:
		:32 dta <(((#+1)*57*31)/2-7)

audio_lotab93:
		:32 dta <((#+1)*57*93/2-7)
		.endpg

audio_hitab:
		:32 dta >((#+1)*57-7)

audio_hitabp4:
		:32 dta >(((#+1)*57)/3*3+2-7)

audio_hitab6:
		:32 dta >((#+1)*57*3-7)

audio_hitab15:
;		:32 dta >(((#+1)*57*15)-7-1)
		:32 dta >((#+1)*57*15+1-7)

audio_hitab31:
		:32 dta >(((#+1)*57*31)/2-7)

audio_hitab93:
		:32 dta >((#+1)*57*93/2-7)

audio_ctab:
		dta		$10		;$0: volume only mode
		dta		$C0		;$1: 4-bit poly
		dta		$C0		;$2: 4 bit poly, div 15
		dta		$40		;$3: 5-bit poly -> 4 bit poly
		dta		$a0		;$4: pure tone
		dta		$a0		;$5: pure tone
		dta		$a0		;$6: pure tone
		dta		$20		;$7: 5-bit poly, div 2
		dta		$80		;$8: 9-bit poly
		dta		$20		;$9: 5-bit poly mode
		dta		$A0		;$A: pure tone, div 31
		dta		$B0		;$B: volume only mode
		dta		$a0		;$C: pure tone, div 6
		dta		$a0		;$D: pure tone, div 6
		dta		$a0		;$E: pure tone, div 93
		dta		$20		;$F: 5-bit poly, div 6
		
audio_dtab:
		dta		<audio_lotab
		dta		<audio_lotab
		dta		<audio_lotab15
		dta		<audio_lotabp4
		dta		<audio_lotab
		dta		<audio_lotab
		dta		<audio_lotab31
		dta		<audio_lotab
		dta		<audio_lotab
		dta		<audio_lotab6
		dta		<audio_lotab31
		dta		<audio_lotab
		dta		<audio_lotab6
		dta		<audio_lotab6
		dta		<audio_lotab93
		dta		<audio_lotab6

;==========================================================================
.proc	InitAudio
		lda		#$f8
		sta		audctl
		rts
.endp

;==========================================================================
.proc	UpdateAudio
		lda		_audc0
		and		#$0f
		tax
		lda		_audf0
		and		#$1f
		ora		audio_dtab,x
		tax
		mva		audio_tabs,x audf1
		mva		audio_hitab,x audf2

		lda		_audc1
		and		#$0f
		tax
		lda		_audf1
		and		#$1f
		ora		audio_dtab,x
		tax
		mva		audio_tabs,x audf3
		mva		audio_hitab,x audf4
		
		lda		_audc0
		and		#$0f
		tax
		lda		_audv0
		and		#$0f
		ora		audio_ctab,x
		sta		audc2		

		lda		_audc1
		and		#$0f
		tax
		lda		_audv1
		and		#$0f
		ora		audio_ctab,x
		sta		audc4
		rts
.endp
