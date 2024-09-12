;*
;* RMT FEATures definitions
;*
;* For optimizations of RMT player routine to concrete RMT modul only!
;* --------BEGIN--------
FEAT_SFX			equ 0			;* 0 => No SFX support, 1 => SFX support
FEAT_GLOBALVOLUMEFADE		equ 0			;* 0 => No RMTGLOBALVOLUMEFADE support, 1=> RMTGLOBALVOLUMEFADE support (+7 bytes)
FEAT_NOSTARTINGSONGLINE		equ 0			;* 0 => Init with starting songline, 1=> no starting songline (start from songline 0 always), cca 22 or 24 bytes
FEAT_INSTRSPEED		equ 0			;* cca 21 or 5 bytes
FEAT_CONSTANTSPEED	equ 0			;* cca 28 bytes
;* VARIOUS COMMANDS
FEAT_COMMAND1		equ 1			;* cca 8 bytes
FEAT_COMMAND2		equ 1			;* cca 20 bytes (+save 1 address in zero page) and quicker whole RMT routine
FEAT_COMMAND3		equ 1			;* cca 12 bytes
FEAT_COMMAND4		equ 1			;* cca 15 bytes
FEAT_COMMAND5		equ 1			;* cca 67 bytes
FEAT_COMMAND6		equ 1			;* cca 15 bytes
;* COMMAND7 SETNOTE (i.e. command 7 with parameter != $80)
FEAT_COMMAND7SETNOTE		equ 1		;* cca 12 bytes
;* COMMAND7 VOLUMEONLY (i.e. command 7 with parameter == $80)
FEAT_COMMAND7VOLUMEONLY		equ 1		;* cca 74 bytes
;* PORTAMENTO
FEAT_PORTAMENTO		equ 1			;* cca 138 bytes and quicker whole RMT routine
;* FILTER
FEAT_FILTER			equ 1			;* cca 179 bytes and quicker whole RMT routine
FEAT_FILTERG0L		equ	1			;* (cca 38 bytes for each)
FEAT_FILTERG1L		equ	1
FEAT_FILTERG0R		equ	1
FEAT_FILTERG1R		equ	1
;* BASS16B (i.e. distortion value 6)
FEAT_BASS16			equ 1			;* cca 194 bytes +128bytes freq table and quicker whole RMT routine
FEAT_BASS16G1L		equ 1			;* (cca 47 bytes for each)
FEAT_BASS16G3L		equ 1
FEAT_BASS16G1R		equ 1
FEAT_BASS16G3R		equ 1
;* VOLUME ONLY for particular generators
FEAT_VOLUMEONLYG0L	equ 1			;* (cca 7 bytes for each)
FEAT_VOLUMEONLYG2L	equ 1
FEAT_VOLUMEONLYG3L	equ 1
FEAT_VOLUMEONLYG0R	equ 1
FEAT_VOLUMEONLYG2R	equ 1
FEAT_VOLUMEONLYG3R	equ 1
;* TABLE TYPE (i.e. TABLETYPE=1)
FEAT_TABLETYPE		equ 1			;* cca 53 bytes and quicker whole RMT routine
;* TABLE MODE (i.e. TABLEMODE=1)
FEAT_TABLEMODE		equ 1			;* cca 16 bytes and quicker whole RMT routine
;* TABLE GO (i.e. TGO is nonzero value)
FEAT_TABLEGO		equ 1			;* cca 6 bytes and quicker whole RMT routine
;* AUDCTLMANUALSET (i.e. any MANUAL AUDCTL setting is nonzero value)
FEAT_AUDCTLMANUALSET	equ 1		;* cca 27 bytes and quicker whole RMT routine
;* VOLUME MINIMUM (i.e. VMIN is nonzero value)
FEAT_VOLUMEMIN		equ 1			;* cca 12 bytes and quicker whole RMT routine
;* INSTREUMENT EFFECTS (i.e. VIBRATO or FSHIFT are nonzero values with nonzero DELAY)
FEAT_EFFECTVIBRATO	equ 1			;* cca 65 bytes and quicker whole RMT routine
FEAT_EFFECTFSHIFT	equ 1			;* cca 11 bytes and quicker whole RMT routine
;* (btw - if no one from this two effect is used, it will save cca 102 bytes)
;* --------END--------