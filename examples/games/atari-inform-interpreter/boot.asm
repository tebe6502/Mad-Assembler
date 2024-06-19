;this is source is based on disassembly of the original Atari Z3 Interpreter G by Infocom
;later heavily gutted and rewriten by Jindroush in 2023

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; changes on top of original:
;	-added three different disk layouts (SD_TWO_SIDE,SD_ONE_SIDE,DD_ONE_SIDE)
;	-fixed non-czech-conforming get_arg1_obj_prop_ptr_to_temp2
;	-slightly fixed random keyword behavior (still does not reseed, will need real motivation to use prng)
;	-added charset, turning on charset, translation table for CZ_LANG, just for testing
;	23_06_16 kubecj	-preliminary work on extmem support, all bugs fixed, czech tests in non-extmem build work now flawlessly
;	23_06_26 kubecj -extmem mostly finished, there are still random bugs which would be hard to find
;			-added check for 48KB of ram / 130KB of ram in extmem
;			-fixed latest bugs in extmem. Remaining should be only save/restore, verify also fails - probably sector mismatch again
;			-fixed sector mismatch in verify
;	23_06_27 kubecj -maybe all bugs fixed in EXTMEM changes, incl. save and restore
;	23_06_28 kubecj -simplified attribute bitmask creation
;	23_06_28 kubecj -this should be final Z3-only version. Capabilities include SD, SD-twoside, DD support, CZ Lang support and possibility of
;				EXTMEM support on 130XE+ machines.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;	23_06_28 kubecj -first attempt to run z4 code
;			-augmented code jumptables to be full
;			-one of the call instructions fixed to be *4P compatible
;	23_06_29 kubecj	-seems like call_1s and call_2s seems to work as call_vs(?)
;			-added call_vs2 functionality with all 8 parameters
;	23_07_01 kubecj -fixed all object addressing for z4
;			-fixed all property addressing for z4 (I wish I could read the docs more carefully, to spot difference
;				between bit 5 and 5 bits)
;			-added EXTMEM compatibility for the above
;			-understood there is something in the original implementation of relative jumps I don't understand
;				-so rewrote it in a way I understand (ie sign extend and then do 24bit addition)
;			-added dummy calls to all missing i/o functions
;			-allowed non-system sizes of DD diskettes (LONG_MEDIA)
;			-in this moment AMFV starts, but crashes soon because of missing read_char opcode
;	23_07_02 kubecj	-added more or less dummy read_char
;			-fixed computation of object pointer. This proves again that CZECH does not check all the corners.
;			-changed parser to use 9 byte words and lookup of 6 byte dictionary words
;	23_07_04 kubecj -added several screen oriented opcodes, more or less by guessing
;			-there are definitely some problems regarding the object creation/moving/removal
;			-also, there is some jumping bug which goes into the middle of the nowhere
;			-the problem is that most of the screen stuff can't be displayed on 40 column screen and the decision must be made
;				if I want to use software/XEP80/VBXE
;	23_07_05 kubecj -found bug in scan_table implementation which seems to have caused all the yesterday's mysterious bugs
;			-fixed z4 verify
;			-fixed some header flags. Found out Infocom did not assign interpreter number for Atari.
;			-fixed get_prop_len and get_prop_addr for Z4 long props (2 byte prop header)
;			-also learned how to f**k with original copy protection in AMFV
;	23_07_07 kubecj -added VBXE driver, looks very nice. Lots of work with buffering / output_streams follows.
;	23_07_09 kubecj -added buffering control, decided to flush buffer when buffering is set to 0
;			-added output stream functionality
;			-found out that there is either bug in my implementation of function calls, or the stack in this version is too small
;				-because when there are several 1s calls, each call with unconsumed sp result takes 1 stack position, 
;				-and if there is a loop over them...
;			-fixed read_char to print cursor and allow pushing enter (returning $0d on enter)
;			-in this very moment all 4 Z4 games look visually great. Also [more] must be re-implemented. 
;				-Wonder what would compiling to Z3 do.
;			-in todo there is still save/restore.
;	23_07_10 kubecj -save & restore in z4 appear to work. Not sure if $refre could be called from restore routine (nope!)
;				-in any case, dynamic memory in z4 is yuge and I have no idea how long space should be reserved for it
;				-Trinity has $9310 of dynamic memory.
;	23_07_11 kubecj -displaying [MORE] now even in vbxe mode
;			-not sure why it asks for [MORE] at the end of AMFV first screen (now sure - because screen model is broken)
;			-should also display 'story is loading' in a better way
;	23_07_14 kubecj -now everything looks okay in all 4 Z4 games
;			-removed almost all A40 code to standalone driver, need to check out the rest of the code and also Z3 dependencies
;			-Z3 Stationfall has parsing problem when compiled with EXTMEM
;	23_07_15 kubecj	-Stationfall fixed, took hours ;-) - caused by random memory overwrite in A40_cls caused by off-by-one error
;			-fixed size of cursor
;			-moved pmg stuff to graphics drivers as macros. also pmg init should be moved there(?)
;			-currently z4 & z3 seem to run well with both a40/vbxe graphics drivers
;			-just some originally z3 prints should be fixed to work in nicely (status, loading story etc)
;	23_07_17 kubecj	-fixed color of pmg cursor
;			-added S80, works on the first try, which is surprising. Missing [more]
;			-moved caching page compares to graphics drivers, good for now (in the future, needs to put large stack there first)
;			-unified graphics drivers api to limit number of if/elseifs in main code
;			-fixed display of not enough memory error (for example Z3 Stationfall and S80 won't work together on 64KB machine)
;			-fixed display of Z3 status line on 80 col drivers
;			-added [more] for S80
;			-loading story now looks more elegant, getting rid of top-of-the-screen-printing
;	23_07_18 kubecj -large stack implemented, works okay
;			-there is a problem with PMG, as 1-line PMG must be on 2K boundary
;	23_07_20 kubecj	-problem with PMG in VBXE - it seems this depends on core version, 1.26 looks good.
;				-this problem is visible only in Bureaucracy forms, when the cursor is above the text
;			-first attempt to run z5 code, implemented two of the call opcodes
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;	23_07_21 kubecj -fixed z5 call, added two other
;			-added extended opcodes, implemented shifts
;			-added all(?) header settings for z5
;			-added empty set_font and set_color (in fact, set_color may work for VBXE?)
;			-some changes regarding calls with 'n'
;			-also added number of parameters to stack save, for check_args
;	23_07_22 kubecj -added mostly empty aread, modified get keyboard string, but these are not correct/unfinished
;			-fixed bug in shift with 0
;			-print_table, copy_table implemented, fixed and reimplemented scan_table
;			-fixed get_prop_len 0 to conform to specification
;	23_07_23 kubecj	-implemented catch/throw. Now praxis passes with 3 failures in streams (more or less expected)
;			-verified Z4 still works, Z3 also works
;			-currently CIO is dropped altogether in A40 mode, all graphics drivers rewritten to output
;				only real characters on put_char and won't modify ROWCRS/COLCRS, the whole functionality is only in
;				interpreter's lowlevel_ functions. That should help us separate the graphics mode from zmachine screen model.
;			-fixed print_table to print newline only between lines. This fixes output of Sherlock/Borderzone.
;			-removed check in split_window for max number of lines. It created troubles in Zork I InvisiClues screens.
;			-two additional bugfixes in print_table - skip must be tested first if provided, COLSCR must be preserved on new line
;			-another print_table fix ;) - instead of new_line, just increment ROWCRS
;			-small fix in print_a_character to skip 0 leads to 100% praxix test pass
;			-fixed quite a devious bug in copy_table and now I have to wonder wherever else it may lurk. Basically, I was reading
;				directly from extmem, but since I load only until dynamic memory end, I was reaching uninitialized memory.
;				loading 64KB would solve it for me 'for free' though
;			-currently it seems that all z5 games mostly work, so the trinity of read/read_from_keyboard/tokenise must be written to
;				finish it
;	23_07_24 kubecj	-tried making font3 available in S80, it mostly works (and we're getting dangerously close to $3FFF)
;	23_07_25 kubecj	-added screen flush when waiting for char (fixes Beyond Zork start)
;	23_07_26 kubecj	-z8 support just to test it's same as Z5 (works out of the box). The only difference is in packed addresses.
;			-z7 works as well. So right now we have support for Z3-Z4-Z5-Z7-Z8 (Z5-Z7-Z8 not fully finished yet). Z6 is a no-no.
;			-z5 added check for 0 values in find_in_vocab number of words and in copy_table size, Beyond Zork started to work
;			-also, for extended memory we now load everything up to $FF always, for long stories. Otherwise we need to compute the
;				real length, which duplicates the code for us...
;			-added alphabet table processing, just for testing, not production quality at all (one game with it only)
;			-again there was a bug in print_table, that's one cursed function ;)
;	23_07_27 kubecj	-partial input for z5+ should now be working
;			-rewrote alphabet processing also for ascii-zchar-zstr conversion
;	23_08_01 kubecj	-just fixing bits here and there to get rid of all TODOs
;	23_08_03 kubecj	-trying to speed up things, mostly in cache invalidation
;	23_08_04 kubecj	-verified that all implemented op_ext don't touch memory, also they don't have variable number of pars
;			-it seems that also all opvar_ are correct now
;			-added some cache invalidation fixes for zdata
;			-implemented save & restore compatible with z4+, but found out the graphics state must be saved & restored as well
;	23_08_05 kubecj	-save/restore for z4+ fixed and verified to work correctly on AMFV and BZork.
;			-fixed particulary nasty bug when calling N call with 0. Fixes HHtG SG.
;	23_08_09 kubecj	-in call 0 fixed bug I created, while I fixed another bug ;)
;			-changed wording in save
;			-allowed external setting of interpreter version (for Beyond Zork)
;			-changed initialization order in naked_interpreter to survive reset
;			-fixed encoding of escaped characters (it's 5, 6, lo, hi for one special char)
;	23_08_10 kubecj	-slightly modified s80 fonts
;			-changed asm->binary including of fonts for S80
;	23_08_12 kubecj	-0.9.2 added PORTB writes in VBXE functions touching MEMACB. Will see if it helps.
;	23_08_27 kubecj	-0.9.4 added S64 driver. Looks good, just AMFV has problems in menu.
;	23_08_28 kubecj	-added font3 for S64 driver, not perfect, but usable. Not sure if something must be done regarding the speed of driver.
;	23_09_12 kubecj	-0.9.5 fixed error while displaying very early messages in Z3 stories. Did it by completely disabling status line
;				unless static memory is wholly loaded
;			-fixed two disk sector computation (leading to error 12)
;			-reverted back to code/data buffer cross invalidation. It was unclear why this was needed, but now it makes sense.
;				There is only one resource - cache, and two users - code & data readers. Because there is no way how to lock
;				some sectors to be used by one specific reader, it's always needed to invalidate buffers and its pointers in order
;				to prevent pointers pointing to buffers which were meanwhile re-loaded for the other reader. This whole caching
;				thing is a mess now and I have to re-think if complete rewrite isn't what's actually needed.
;				This bug must have been lurking there for many versions, but only in base memory Z3 with large story - Planetfall,
;				the cache was only two sectors so it almost immediately hit.
;	23_09_16 kubecj	-PunyInform needs get_cursor, implemented
;	23_09_17 kubecj	-found serious bug in call implementation - when the number of call parameters is larger than number of locals
;				the locals get overwriten without being preserved on stack. Not sure if any of the originals may have code
;				like this. (Inform6 veneer routine CA__Pr didn't work as expected in second 'before' call).
;	23_09_18 kubecj	-slightly fixed font3 in s64 driver
;	23_09_23 kubecj	0.9.6 s64peedy gonzales build with faster s64 driver


version_hihi = 0
version_hi = 9
version_lo = 6

;bugs
;the buffering is not okay when the unbuffered print does not start on the leftmost column. String then rolls over, instead of printing newline
;in Savoir Faire there are [more] prompts while displaying help, that's wrong

;todo
;check all out-of-game printing functions and make sure they don't interfere with changes regarding buffering etc.
;	-there's at least one case when the bug is displayed very early and needs [more] to be pressed several times.
;write all-extmem-tester (set portb to X and write X to $4000+X, in second pass verify which ones survived?)
;timed input for z4+
;terminating characters from header for z5+
;also all special input characters. Not sure if this could be implemented in a reasonable way, when original games are unaware of A800?

;later
;vbxe 1 - use colors in text mode
;vbxe 2 - use graphics mode, put_char would use multiple fonts via blitting, scroll via blitting, all colors and stuff. In fact, not sure
;	about this, because I don't understand vbxe screen model at all. If I have 8bits/1byte wide font, how do I create colored pixels of it?
;think of loading whole game to ram if 320+ (needs memory discovery code)
;split dd diskette
;think if using RANDOM is better than transplanting some PRNG from CC65


	opt h-

;for z3 split story
.ifndef SD_TWO_SIDE
	SD_TWO_SIDE = 0
.endif

;for z3 short story which fits real sd, or long story with fits unreal sd
.ifndef SD_ONE_SIDE
	SD_ONE_SIDE = 0
.endif

;for z3 short story which fits real sd, or long story with fits unreal sd
.ifndef ED_ONE_SIDE
	ED_ONE_SIDE = 0
.endif

;for long story to fit on one real disk
.ifndef DD_ONE_SIDE
	DD_ONE_SIDE = 0
.endif

;unreal disk
.ifndef LONG_MEDIA
	LONG_MEDIA = 0
.endif

.if SD_ONE_SIDE || SD_TWO_SIDE || DD_ONE_SIDE
	MAX_SECTORS = 720
.elseif ED_ONE_SIDE
	MAX_SECTORS = 1040
.endif

.if ZVER = 3
MAX_STORY_SIZE_HIHI = 1
.elseif ZVER = 4 || ZVER = 5
MAX_STORY_SIZE_HIHI = 3
.elseif ZVER = 7 || ZVER = 8
MAX_STORY_SIZE_HIHI = 7
.endif

;this is interpreter called from external menu
;so far, the configuration is from beginning of $80
;$80,$81 - story start sector
;later maybe color settings?
.ifndef NAKED_INTERPRETER
	NAKED_INTERPRETER = 0
.endif

.if NAKED_INTERPRETER
	.if ! DD_ONE_SIDE && ! LONG_MEDIA
		.error "Invalid compilation switches"
	.endif
.endif

;DEBUG_PRINTS=1
.ifndef DEBUG_PRINTS
	DEBUG_PRINTS=0
.endif

;czech language support (not all messages translated yet)
.ifndef CZ_LANG
	CZ_LANG = 0
.endif

;disables printing of [more] and waiting for key (more or less debugging tool)
SUPPRESS_MORE = 0

;video drivers
A40 = 1		;software gr.2 driver, 40 columns, not using CIO
VBXE = 2	;VBXE just one color txt, 80 columns
S80 = 3		;software gr.8 driver, 80 columns
S64 = 4		;software gr.8 driver, 64 columns

;zcode version to compile
.ifndef ZVER
	ZVER = 3
.endif

;large stack - larger than 256 stack words
.ifndef LARGE_STACK
	LARGE_STACK = 0
.endif

;extended memory support
.ifndef EXTMEM
	EXTMEM = 0
.endif

.if CZ_LANG
;CHAR_* are valid only for Capek encoding - for strings output via CIO (inverted only?)
;ZCHAR_* are zchar substitutes of accented characters - for strings output via unpacked zchar print
CHAR_PARLEFT = $06
CHAR_PARRIGHT = $24

CHAR_l_a_carka = $2A
ZCHAR_l_a_carka = $CF

CHAR_l_c_hacek = $27
ZCHAR_l_c_hacek = $D6

CHAR_C_hacek = $03

CHAR_l_e_hacek = $25
ZCHAR_l_e_hacek = $DA

CHAR_l_i_carka = $29
ZCHAR_l_i_carka = $DB

CHAR_I_carka = $09
ZCHAR_I_carka = $B2

CHAR_l_o_carka = $0F

CHAR_l_y_carka = $60

CHAR_l_z_hacek = $28
ZCHAR_l_z_hacek = $CB

CHAR_R_hacek = $12
ZCHAR_R_hacek = $BC

.endif

;atari characters needed
atari_eol = $9b
atari_backspace = $7e

;zscii/ascii chars
ascii_cr = $0D
ascii_lf = $0A
ascii_tab = $09
ascii_space = $20





;----------------------------------------------------------------------------------------------------------

;hardware regs
;gtia
GTIA_REGS = $D000
HPOSM0 = $D004
SIZEM = $D00C
GRACTL = $D01D
CONSOL = $D01F

;pokey
AUDF1 = $D200
AUDC1 = $D201
AUDCTL = $D208
RANDOM = $D20A
IRQEN = $D20E
SKCTL = $D20F

;pia
PORTB = $D301

;antic
PMBASE = $D407

;os vectors
SIOV = $e459
CIOV = $e456
DSKINV = $e453

;disk commands
DDEVIC   =$300       ;DEVICE BUS ID
DUNIT    =$301       ;UNIT NUMBER
DCOMND   =$302       ;BUS COMMAND
DSTATS   =$303       ;CMD TYPE/OP STATUS
DBUFLO   =$304       ;DATA BUFFER
DBUFHI   =$305       ;DATA BUFFER
DTIMLO   =$306       ;DEVICE TIMEOUT
DBYTLO   =$308       ;BUFFER LENGTH
DBYTHI   =$309       ;BUFFER LENGTH
DAUX1    =$30A
DAUX2    =$30B

;cio
ICHID_0    =$340       ;HANDLER INDEX OFFSET
ICDNO_0    =$341       ;DEVICE NUMBER
ICCOM_0    =$342       ;DEVICE COMMAND
ICSTA_0    =$343       ;OP STATUS
ICBAL_0    =$344       ;BUFFER ADDRESS
ICBAH_0    =$345       ;BUFFER ADDRESS
ICPT_0     =$346       ;PUT BYTE RTN-1
ICBLL_0    =$348       ;BUFFER LENGTH
ICBLH_0    =$349       ;BUFFER LENGTH
ICAX1_0    =$34A       ;AUX 1
ICAX2_0    =$34B
ICSPR_0    =$34C
ICAX3_0    =$34C
ICAX4_0    =$34D
ICAX5_0    =$34E
ICAX6_0    =$34F

CIO_OPEN = $03
CIO_CLOSE = $0C
CIO_PUT_BINARY = $0B
CIO_PRINT = $09

;os zpage vars
TRAMSZ = $06
BOOT = $09
DOSVEC_LO = $0A
DOSVEC_HI = $0B
DOSINI_LO = $0C
DOSINI_HI = $0D

POKMSK = $10
RTCLOK = $12
ROWCRS = $54
COLCRS = $55
RAMTOP = $6A

;os vars
SDMCTL = $22F
SDLSTL = $230
SDLSTH = $231
COLDST = $244
GPRIOR = $26f
PCOLR0 = $2c0
PCOLR1 = $2c1
PCOLR2 = $2c2
PCOLR3 = $2c3
COLOR0 = $2c4
COLOR1 = $2c5
COLOR2 = $2c6
COLOR3 = $2c7
COLOR4 = $2c8
RAMSIZ = $2e4
CHBAS = $2f4
CH = $2fc


end_of_48k_ram_page = $C000

;we need to compute this also for other densities
.if( SD_TWO_SIDE || SD_ONE_SIDE || ED_ONE_SIDE )
	STARTING_STORY_SECTOR = [ ( ( end_of_boot - boot_header ) / $80 ) + 1 ]
.elseif( DD_ONE_SIDE )
	STARTING_STORY_SECTOR = [ ( ( end_of_boot - boot_header ) / $100 ) + 1 + 3 ]	
.else
	.error
.endif

.if EXTMEM
story_hdr_begin = $4000	;not a magic, but address of extended memory window
.else
story_hdr_begin = end_of_boot + 7
.endif

story_hdr_version = story_hdr_begin + $00
story_hdr_flags = story_hdr_begin + $01
story_hdr_release_hi = story_hdr_begin + $02
story_hdr_release_lo = story_hdr_begin + $03
story_hdr_resident_memory_hi = story_hdr_begin + $04
story_hdr_resident_memory_lo = story_hdr_begin + $05
story_hdr_pc_hi = story_hdr_begin + $06
story_hdr_pc_lo = story_hdr_begin + $07
story_hdr_dict_hi = story_hdr_begin + $08
story_hdr_dict_lo = story_hdr_begin + $09
story_hdr_obj_hi = story_hdr_begin + $0A
story_hdr_obj_lo = story_hdr_begin + $0B
story_hdr_glob_hi = story_hdr_begin + $0C
story_hdr_glob_lo = story_hdr_begin + $0D
story_hdr_dynamic_hi = story_hdr_begin + $0E
story_hdr_dynamic_lo = story_hdr_begin + $0F
story_hdr_flags2_hi = story_hdr_begin + $10
story_hdr_flags2_lo = story_hdr_begin + $11

;12 13 14 15 16 17 unused

story_hdr_abbr_hi = story_hdr_begin + $18
story_hdr_abbr_lo = story_hdr_begin + $19
story_hdr_flen_hi = story_hdr_begin + $1A
story_hdr_flen_lo = story_hdr_begin + $1B
story_hdr_crc_hi = story_hdr_begin + $1C
story_hdr_crc_lo = story_hdr_begin + $1D

story_hdr_int = story_hdr_begin + $1E
story_hdr_int_ver = story_hdr_begin + $1F

story_hdr_screen_height = story_hdr_begin + $20
story_hdr_screen_width = story_hdr_begin + $21

story_hdr_screen_width_u_hi = story_hdr_begin + $22
story_hdr_screen_width_u_lo = story_hdr_begin + $23
story_hdr_screen_height_u_hi = story_hdr_begin + $24
story_hdr_screen_height_u_lo = story_hdr_begin + $25

story_hdr_screen_unitsx = story_hdr_begin + $26
story_hdr_screen_unitsy = story_hdr_begin + $27

story_hdr_rout_offs_hi = story_hdr_begin + $28
story_hdr_rout_offs_lo = story_hdr_begin + $29
story_hdr_str_offs_hi = story_hdr_begin + $2A
story_hdr_str_offs_lo = story_hdr_begin + $2B

story_hdr_screen_default_bk_col = story_hdr_begin + $2C
story_hdr_screen_default_fg_col = story_hdr_begin + $2D

story_hdr_termchars_hi = story_hdr_begin + $2E
story_hdr_termchars_lo = story_hdr_begin + $2F

;30 31 - z6 only
story_hdr_standard_hi = story_hdr_begin + $32
story_hdr_standard_lo = story_hdr_begin + $33

story_hdr_alphabet_table_hi = story_hdr_begin + $34
story_hdr_alphabet_table_lo = story_hdr_begin + $35

;36 37 - z5 header extension table

.if ZVER = 3
OBJ_PARENT_OFS = 4
OBJ_SIBLING_OFS = 5
OBJ_CHILD_OFS = 6
OBJ_PROP_OFS = 7
OBJ_SIZE = 9
DEFAULT_PROPS_CNT = 31
DICT_WORD_LEN = 6
.else
OBJ_PARENT_OFS = 6
OBJ_SIBLING_OFS = 8
OBJ_CHILD_OFS = 10
OBJ_PROP_OFS = 12
OBJ_SIZE = 14
DEFAULT_PROPS_CNT = 63
DICT_WORD_LEN = 9
.endif

current_opcode_80 = $80
argument_count_81 = $81
arg1_lo_82 = $82
arg1_hi_83 = $83
arg2_lo_84 = $84
arg2_hi_85 = $85
arg3_lo_86 = $86
arg3_hi_87 = $87
arg4_lo_88 = $88
arg4_hi_89 = $89

.if ZVER >= 4
arg5_lo_8A = $8A
arg5_hi_8B = $8B
arg6_lo_8C = $8C
arg6_hi_8D = $8D
arg7_lo_8E = $8E
arg7_hi_8F = $8F
arg8_lo_90 = $90
arg8_hi_91 = $91
.endif

temp_lo_92 = $92
temp_hi_93 = $93
temp2_lo_94 = $94
temp2_hi_95 = $95

zcode_addr_lo_96 = $96
zcode_addr_hi_97 = $97
zcode_addr_hihi_98 = $98
zcode_buffer_valid_99 = $99
zcode_buffer_lo_9A = $9A
zcode_buffer_hi_9B = $9B

zdata_addr_lo_9C = $9C
zdata_addr_hi_9D = $9D
zdata_addr_hihi_9E = $9E
zdata_buffer_valid_9F = $9F
zdata_buffer_lo_A0 = $A0
zdata_buffer_hi_A1 = $A1


stack_pointer_lo_A2 = $A2
stack_pointer_hi_A3 = $A3 ;only used with LARGE_STACK

stack_pointer_function_frame_lo_A4 = $A4
stack_pointer_function_frame_hi_A5 = $A5 ;only used with LARGE_STACK

.if !EXTMEM
game_base_page_A6 = $A6		;not used in EXTMEM
.endif

resident_mem_in_pages_A7 = $A7

.if !EXTMEM
after_dynamic_memory_page_A8 = $A8
.endif

cache_size_in_pages_A9 = $A9
get_sector_tmp_lo_AA = $AA
get_sector_tmp_hi_AB = $AB


ptr_globals_lo = $AC
ptr_globals_hi = $AD
ptr_dict_lo = $AE
ptr_dict_hi = $AF
ptr_abbrevs_lo = $B0
ptr_abbrevs_hi = $B1
ptr_objects_lo = $B2
ptr_objects_hi = $B3

;6 chars for Z3, 9 for Z4
converted_keyword_buffer_B4 = $B4
;b5, b6, b7, b8, b9 - z3
;ba, bb, bc - z4

;always free
;bd

local_vars_cnt1_BE = $BE
local_vars_cnt2_BF = $BF

curr_char_ptr_C0 = $C0
ptr_into_tokenized_buffer_C1 = $C1
chars_in_buffer_C2 = $C2
curr_kwd_buffer_idx_C3 = $C3
tmp_tokenized_buff_lo_C4 = $C4
tmp_tokenized_buff_hi_C5 = $C5
temp_vocab_count_lo_C6 = $C6
temp_vocab_count_hi_C7 = $C7
tmp_vocab_entry_len_C8 = $C8

charset_permanent_C9 = $C9
charset_temporary_CA = $CA
current_zchar_CB = $CB
tmp_abbrev_ptr_CC = $CC
zchars_already_output_CD = $CD
tmp_zchar_hi_CE = $CE
tmp_zchar_lo_CF = $CF
output_buffer_char_count_D0 = $D0
curr_char_ptr_in_D1 = $D1
curr_char_ptr_out_D2 = $D2

tmp_number_lo_D3 = $D3
tmp_number_hi_D4 = $D4
tmp_number_lo_D5 = $D5
tmp_number_hi_D6 = $D6
tmp_number_lo_D7 = $D7
tmp_number_hi_D8 = $D8
tmp_div_internal_lo_D9 = $D9
tmp_div_internal_hi_DA = $DA
number_of_significant_figures_DB = $DB

.if ZVER = 3
;Z3 only
status_type_DC = $DC
.endif

index_in_string_in_out_buffer_DD = $DD
byte_DE = $DE
transcripting_control_DF = $DF


lines_printed_since_last_pause_E0 = $E0
screen_lines_to_scroll_E1 = $E1
one_character_E2 = $E2
;e3
where_is_window_split_E4 = $E4

current_cache_idx_E5 = $e5
cache_age_correction_E6 = $e6
current_cache_age_E7 = $e7
available_cache_slot_idx_E8 = $e8

is_P_device_open_E9 = $E9
char_to_print_EA = $EA


sector_pointer_lo_EB = $EB
sector_pointer_hi_EC = $EC
read_buffer_lo_ED = $ED
read_buffer_hi_EE = $EE
disk_sect_lo_EF = $EF
disk_sect_hi_F0 = $F0
position_default_F1 = $F1
disk_drive_default_F2 = $F2
position_temp_F3 = $F3
disk_drive_temp_F4 = $F4
disk_drive_F5 = $F5

keydel_lo_f6 = $F6
keydel_hi_f7 = $F7
pmg_cursor_curr_shape_f8 = $F8

tmp_bitmap_F9 = $F9

temp_modded_lo_FA = $fa
temp_modded_hi_FB = $fb

;reserved for graphics drivers (not sure if used or not)
temp_gr1_lo = $fc
temp_gr1_hi = $fd
temp_gr2_lo = $fe
temp_gr2_hi = $ff

machine_stack = $100

tmp_disk_buffer = $400

;don't know how to make this correct in case of LARGE_STACK
;I was hoping to save the memory, but PMBASE must be on $800 multiples
;so $800+300 or $0+300 are the only options here
;or move it after large stack? or use player for this?
.if !LARGE_STACK
stack_word_lo = $500
stack_word_hi = $600
stack_start_page = >stack_word_lo
stack_pages = 2
.endif
start_of_cache_vars = $700

cached_sector_num_lo = start_of_cache_vars + 0
cached_sector_num_hi = start_of_cache_vars + $100
cache_age_table = start_of_cache_vars + $200

local_vars_lo = start_of_cache_vars + $300
local_vars_hi = start_of_cache_vars + $301
byte_A20 = start_of_cache_vars + $320
byte_A21 = start_of_cache_vars + $321

string_in_out_buffer = start_of_cache_vars + $380

pmg_missiles_mem = start_of_cache_vars + $400
pm_base = pmg_missiles_mem - $300

.if( (pm_base / $800 )*$800 != pm_base )
	.error Incorrect pm_base
.endif



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; miniloader for DD disks
;
.if DD_ONE_SIDE && ! NAKED_INTERPRETER

	org $b00
boot0_header:	.BYTE 0
		.BYTE 1
		.WORD boot0_header
		.WORD ldr_run
		RTS

ldr_run:	LDA	#$52
		STA	DCOMND

		LDA	#1
		STA	DUNIT

		;LDA	#$31
		;STA	DDEVIC
		
		LDA	#4		;from sector 4
		STA	DAUX1

		LDA	#0
		STA	DAUX2

		LDA	#0		;$100 long sector
		STA	DBYTLO
		LDA	#1
		STA	DBYTHI

		LDA	#50
		STA	DTIMLO

		LDA	#<boot_header	;to boot .org
		STA	DBUFLO
		LDA	#>boot_header
		STA	DBUFHI
ldr_loop:
		LDA	#$40
		STA	DSTATS

		JSR	SIOV
		BMI	dsk_op_error_ldr

		INC	DAUX1
		BNE	not_over_s
		INC	DAUX2

not_over_s:
		INC	DBUFHI
		DEC	ldr_sectors
		BNE	ldr_loop

		JSR	boot_header+6
		JMP	(boot_header+4)

ldr_sectors:	.BYTE	[ ( end_of_boot - boot_header ) / $100 ]
ldr_err:	.BYTE	'BOO BOO ERROR', atari_eol
ldr_err_len = * - ldr_err
dsk_op_error_ldr:
		LDX #0
		LDA #<ldr_err
		STA ICBAL_0,X
		LDA #>ldr_err
		STA ICBAH_0,X
		LDA #CIO_PRINT
		STA ICCOM_0,X
		LDA #$FF
		STA ICBLL_0,X
		JSR CIOV
ldr_halt:	JMP ldr_halt		

		:[3*128-*+boot0_header] .BYTE 0
.endif

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; the main game boot header
;

;must be on even page?
	org $c00-7

boot_header:	.BYTE 0
		.if( SD_TWO_SIDE || SD_ONE_SIDE || ED_ONE_SIDE )
			.BYTE [ ( end_of_boot - boot_header ) / $80 ]
		.elseif( DD_ONE_SIDE )
			.BYTE [ ( end_of_boot - boot_header ) / $100 ]
		.else
			.error "Unknown disk format"
		.endif
		.WORD boot_header
		.WORD init
		RTS

.if CZ_LANG
font_addr:
	ins "drv_a40_fnt1_capek.fnt"
.endif

.if EXTMEM
;here are defined two tables, each uses 'original' page as an index
;first translates page from 00-FF to banked page 40-7F
;second has precomputed portb values

;six lower bits of original page and hardcoded $40 bit to be in extmem window
pg_to_ext .macro pg
	.BYTE [[:pg & %00111111 ] | %01000000]
.endm

;1 - ram / 0 - selftest
;1 - undefined
;1 - antic to std ram
;0 - cpu to extended
;xx - bank
;1 - basic off
;1 - os rom on

pg_to_portb .macro pg
	.BYTE [[[:pg & %11000000]>>4 ] | %11100011]
.endm

extmem_map_pgs:
		:$100	pg_to_ext(:1)

extmem_map_portbs:
		:$100	pg_to_portb(:1)

.if [ * & 0xFF ] 
	.echo *
	.error "unaligned!"
.endif

.endif

init:
		LDA	#<game_init
		STA	DOSINI_LO
		STA	DOSVEC_LO
		LDA	#>game_init
		STA	DOSINI_HI
		STA	DOSVEC_HI

		.if NAKED_INTERPRETER
		;I think we can safely hardcode it this way
		;on reset, it
		LDA	$80
		STA	sector_patch1+1
		LDA	$81
		STA	sector_patch2+1
		.if ZVER >= 5
		LDA	$82
		STA	interpreter_version_patch+1
		.endif
		.endif

		LDA	#$FF		;on XL/XE systems turns off basic
		STA	PORTB

		JMP	game_init
; ---------------------------------------------------------------------------


		;this is actually the only place where such if/elseif should be
		.if VIDEO = A40
		icl "drv_a40.asm"
		.elseif VIDEO = VBXE
		icl "drv_vbxe.asm"
		.elseif VIDEO = S80
		icl "drv_s80.asm"
		.elseif VIDEO = S64
		icl "drv_s64.asm"
		.else
			.error "Invalid graphics driver selected (A40=1, VBXE=2, S80=3, S64=4 are the valid options)"
		.endif


; ---------------------------------------------------------------------------

aStoryLoading:	.BYTE 'The story is loading...', atari_eol
aStoryLoadingLen = * - aStoryLoading

; ---------------------------------------------------------------------------
          
game_init:
		;48K ram test
		LDA	#0
		STA	$B000			;sets $B000 to 0
		LDA	$B000
		BNE	not_enough_memory	;jumps if $B000 is nonzero (write protect, cart)

		;second test just in case $B000 is 00 originally
		DEC	$B000			;decrements $B000
		LDA	$B000			;check if $B000 is still 0
		BEQ	not_enough_memory

		.if EXTMEM
extmem_test:
		LDA	#$00			;$4000 in main ram is 0
		STA	$4000

		LDA	#$E3
		STA	PORTB			;switch banks
		STA	$4000			;$4000 in ext bank is $E3

		LDA	#$FF			;switch to main bank
		STA	PORTB

		LDA	$4000			;on 130XE $4000 would be $0, on lower computers it would be $E3
		CMP	#$E3
		BEQ	not_enough_memory
		.endif

		.if VIDEO = VBXE
		JSR	vbxe_detect
		BNE     no_vbxe
		.endif

		JMP	game_init_cont

		.if VIDEO = VBXE
no_vbxe:
		LDX	#0
		LDA	#<novbxe_text
		STA	ICBAL_0,X
		LDA	#>novbxe_text
		STA	ICBAH_0,X
		LDA	#CIO_PRINT
		STA	ICCOM_0,X
		LDA	#$FF
		STA	ICBLL_0,X
		JSR	CIOV
		JMP	dynhalt
		.endif

not_enough_memory:
		LDX	#0
		LDA	#<lowmem_err
		STA	ICBAL_0,X
		LDA	#>lowmem_err
		STA	ICBAH_0,X
		LDA	#CIO_PRINT
		STA	ICCOM_0,X
		LDA	#$FF
		STA	ICBLL_0,X
		JSR	CIOV
dynhalt:	JMP	dynhalt

.if !EXTMEM
lowmem_err:	.BYTE 'This game needs at least 48KB of RAM', atari_eol
.else
lowmem_err:	.BYTE 'This game needs at least 130KB of RAM', atari_eol
.endif

.if VIDEO = VBXE
novbxe_text:	.byte 'No VBXE found or unsupported core', atari_eol
.endif

;-----------------------------------------------------------------------------

game_init_cont:	
		CLD
		LDX	#$FF
		TXS

		;is this actually needed for anything?
		LDA	#>end_of_48k_ram_page
		STA	RAMTOP
		STA	RAMSIZ

		;should call only the respective init for selected driver
		JSR	graphics_init

		LDX	#$FF
		STX	CH
		STX	PORTB

		;$00
		INX
		STX	COLDST
		STX	AUDCTL
		STX	transcripting_control_DF
		STX	byte_2034

		;$01
		INX
		STX	BOOT
		STX	GPRIOR	;pmg over background

		LDA	#3
		STA	SKCTL	;enable keyboard
		STA	GRACTL	;players & missiles

		LDA	#50
		STA	DTIMLO

		LDA	#$70
		STA	POKMSK
		STA	IRQEN

		LDX	#$11
		LDA	#0
loop_reset_gtia:
		STA	GTIA_REGS,X
		DEX
		BPL	loop_reset_gtia


		TAX
loop_reset_pmg:
		STA	pmg_missiles_mem,X
		INX
		BNE	loop_reset_pmg

		LDA	#graphics_pmg_size
		STA	SIZEM

		;player/missile 1 - pmg cursor
		LDA	#graphics_pmg_color
		STA	PCOLR0

		LDA	#>pm_base
		STA	PMBASE

.if CZ_LANG
		LDA	#>font_addr
		STA	CHBAS
.endif

game_restart_entry_point:
		.if ZVER = 3
		LDA	#$60
		STA	o0ss_patch1
		.endif

		JSR	clear_screen_init_scr_vars

		;print loading message
		LDA	#[(SCREEN_WIDTH_CHARS_PRINTED - aStoryLoadingLen)/2]
		STA	COLCRS
		LDA	#[SCREEN_LINES_TOTAL / 2]
		STA	ROWCRS
		LDX	#<aStoryLoading
		LDA	#>aStoryLoading
		LDY	#aStoryLoadingLen
		JSR	print_string_X_lo_A_hi_Y_len

		;turn on PMG only (A40/S80/S64 have good PF settings by definition, VBXE has PF turned off)
		;xxx 0
		;xxx 0
		;dma 0
		;one line 1
		;pl dma 1
		;mis dma 1
		;no playfield 00
		LDA	SDMCTL
		ORA	#%00011100
		STA	SDMCTL

		;resetting all zvars
		LDA	#0
		LDX	#$80
loop_reset_zvars:
		STA	0,X     ;$80-$FF
		INX
		BNE	loop_reset_zvars

		TAX
		LDA	#$FF
loop_reset_cache_sectors:
		STA	cached_sector_num_lo,X
		STA	cached_sector_num_hi,X
		INX
		BNE	loop_reset_cache_sectors


		TXA
loop_reset_cache_age:
		STA	cache_age_table,X
		INX
		BNE	loop_reset_cache_age

		;prepare stack
		.if LARGE_STACK
		;large stack begins on 0
		LDA	#stack_start_page
		STA	stack_pointer_hi_A3
		STA	stack_pointer_function_frame_hi_A5
		.else
		;smol stack begins on 1
		INC	stack_pointer_lo_A2
		INC	stack_pointer_function_frame_lo_A4
		.endif

		;set cache age
		INC	current_cache_age_E7

		.if !EXTMEM
		LDA	#>story_hdr_begin
		STA	game_base_page_A6
		STA	read_buffer_hi_EE
		.endif

		;this	forces all requested sectors to be read
		DEC	resident_mem_in_pages_A7

header_load:
		.if EXTMEM
		LDA	#1
		STA	read_to_extmem
		.endif

		JSR	dsk_read_one_game_sector 	;reads in header

		.if EXTMEM
		LDA	extmem_map_portbs
		STA	PORTB
		.endif

		;compute story file length first
		.if EXTMEM
		LDA	story_hdr_flen_hi
		STA	temp2_hi_95
		LDA	story_hdr_flen_lo
		ASL
		STA	temp2_lo_94
		ROL	temp2_hi_95
		ROL	tmp_bitmap_F9

		.if ZVER = 3
		;nothing already done up there
		.elseif ZVER = 4 || ZVER = 5		;file length in Z4 & Z5 is *4
		ASL	temp2_lo_94
		ROL	temp2_hi_95
		ROL	tmp_bitmap_F9
		.elseif ZVER = 7 || ZVER = 8		;file length in Z8 is *8
		ASL	temp2_lo_94
		ROL	temp2_hi_95
		ROL	tmp_bitmap_F9

		ASL	temp2_lo_94
		ROL	temp2_hi_95
		ROL	tmp_bitmap_F9
		.else
			.error
		.endif
		LDA	tmp_bitmap_F9			;very long
		BNE	hlc1
		LDA	temp2_hi_95
		BEQ	hlc1
		BNE	hlc2
hlc1:		LDA	#$FF
hlc2:		
		STA	resident_mem_in_pages_A7

		;leave zvars still initialized to zeroes
		LDA	#0
		STA	temp2_lo_94
		STA	temp2_hi_95
		STA	tmp_bitmap_F9
		.endif

		.if !EXTMEM
		LDX	story_hdr_resident_memory_hi
		INX
		STX	resident_mem_in_pages_A7
		TXA
		CLC
		ADC	game_base_page_A6
		STA	after_dynamic_memory_page_A8
		.endif

.if LARGE_STACK
ramtop_page = stack_start_page
.else
ramtop_page = graphics_start_page
.endif
		.if EXTMEM
		LDA	#[ramtop_page - $80]
		;continues at init_game_pointers
		.else
		LDA	#ramtop_page
		CMP	after_dynamic_memory_page_A8
		BCC	int_error_0
		SEC
		SBC	after_dynamic_memory_page_A8		
		BNE	init_game_pointers                 	;ramtop > after_dynamic_memory_page (positive cache)

		;<48KB checks removed, it's solved way up high                                                                  
int_error_0:
		;although no longer true, this style of error message makes sense
		;changed this to standard print, as it can't be called that soon.
		;this is probably an error to call it so soon                     
		;internally it calls op0_new_line                              
		;which wants to display status in Z3                                   
		;which needs global variables                                     
		;but the memory containing them is not loaded yet                 
		;LDA	#0
		;JMP	display_internal_error

		LDX	#<aNotEnoughMemory
		LDA	#>aNotEnoughMemory
		LDY	#aNotEnoughMemoryLen
		JSR	print_string_X_lo_A_hi_Y_len
ie0:		JMP	ie0

aNotEnoughMemory: .BYTE 'Not enough memory to load this story.'
aNotEnoughMemoryLen = * - aNotEnoughMemory
		.endif						
; ---------------------------------------------------------------------------

init_game_pointers:
		STA	cache_size_in_pages_A9

		.if ZVER = 3
		LDA	#$EA
		STA	o0ss_patch1
		.endif

		.if EXTMEM
		;just for sure, effectivelly maps first bank
		LDA	extmem_map_portbs
		STA	PORTB
		.endif

		.if ZVER = 3
		LDA	story_hdr_flags
		ORA	#$20			;screen splitting available, in 4+ means sound support
		STA	story_hdr_flags
		AND	#2
		STA	status_type_DC		;extracts status type 0 = score/turns, 1 = time
		.endif

		.if ZVER >= 4
		LDA	story_hdr_flags+1
		;ORA	#4			;boldface available
		;ORA	#$08			;italic available
		ORA	#$10			;fixed space available
		;ORA	#$80			;timed keyboard input available
		STA	story_hdr_flags+1

		LDA	#SCREEN_LINES_TOTAL
		STA	story_hdr_screen_height
		.if ZVER >= 5
		STA	story_hdr_screen_height_u_lo
		.endif
		LDA	#SCREEN_WIDTH_CHARS
		STA	story_hdr_screen_width
		.if ZVER >= 5
		STA	story_hdr_screen_width_u_lo
		.endif

		.if ZVER >= 5
		LDX	#1
		STX	story_hdr_screen_unitsx
		STX	story_hdr_screen_unitsy

		;claiming support of 1.1 standard
		STX	story_hdr_standard_hi
		STX	story_hdr_standard_lo

		;0
		DEX
		STX	story_hdr_screen_default_bk_col
		STX	story_hdr_screen_default_fg_col
		STX	story_hdr_screen_width_u_hi
		STX	story_hdr_screen_height_u_hi

		LDA	story_hdr_flags2_lo
		AND	#( ( $8 | $10 | $20 | $80 ) ^ 0xFF ) ;no pics (or no font 3?), no undo, no mouse, no sound
		STA	story_hdr_flags2_lo

		.endif

		.if ZVER = 7
		;in this moment, the offsets are *2
		;in the respective functions they're added with address offsets, and multiplied by 4
		;thus getting 4P + 8R_O and 4P + 8S_O
		LDA	#0
		STA	hdr_str_offs_hihi
		STA	hdr_rout_offs_hihi

		LDA	story_hdr_rout_offs_hi
		STA	hdr_rout_offs_hi
		LDA	story_hdr_rout_offs_lo
		ASL
		STA	hdr_rout_offs_lo
		ROL	hdr_rout_offs_hi
		ROL	hdr_rout_offs_hihi

		LDA	story_hdr_str_offs_hi
		STA	hdr_str_offs_hi
		LDA	story_hdr_str_offs_lo
		ASL
		STA	hdr_str_offs_lo
		ROL	hdr_str_offs_hi
		ROL	hdr_str_offs_hihi
		.endif

		;this is actually platform, but Infocom did not have any for Atari
		;originally used 7 - Commodore 128, which is closest to 130XE
		;but then switched to Macintosh because of Beyond Zork and key names TODO, will maybe change again
		;and 2 (Apple IIe) uses ascii graphics in Beyond Zork
interpreter_version_patch:
		LDA	#7
		STA	story_hdr_int
		LDA	#interpreter_version
		STA	story_hdr_int_ver
		.endif

		;copy pointers to globals
		LDA	story_hdr_glob_hi
		.if !EXTMEM
		CLC
		ADC	game_base_page_A6
		.endif
		STA	ptr_globals_hi
		LDA	story_hdr_glob_lo
		STA	ptr_globals_lo

		;copy pointers to abbrevs
		LDA	story_hdr_abbr_hi
		.if !EXTMEM
		CLC
		ADC	game_base_page_A6
		.endif
		STA	ptr_abbrevs_hi
		LDA	story_hdr_abbr_lo
		STA	ptr_abbrevs_lo

		;copy pointers to dictionary. In Z5+ stores them aside to allow custom dictionaries for tokenize
		LDA	story_hdr_dict_hi
		.if !EXTMEM
		CLC
		ADC	game_base_page_A6
		.endif
		.if ZVER >= 5
		STA	main_dict_hi
		.else
		STA	ptr_dict_hi
		.endif

		LDA	story_hdr_dict_lo
		.if ZVER >= 5
		STA	main_dict_lo
		.else
		STA	ptr_dict_lo
		.endif

		;copy pointers to objects
		LDA	story_hdr_obj_hi
		.if !EXTMEM
		CLC
		ADC	game_base_page_A6
		.endif
		STA	ptr_objects_hi
		LDA	story_hdr_obj_lo
		STA	ptr_objects_lo

		;this loops for all the sectors
		;but, it loads only $FF of them
		;TODO fix somehow
resident_part_load_loop:
		LDA	sector_pointer_lo_EB
		CMP	resident_mem_in_pages_A7
		BCS	resident_part_fully_loaded
		JSR	dsk_read_one_game_sector
		JMP	resident_part_load_loop

resident_part_fully_loaded:
		.if EXTMEM
		LDA	extmem_map_portbs
		STA	PORTB
		LDA	#$00
		STA	read_to_extmem
		.endif


		;custom alphabet table in Z5+
		.if ZVER >= 5
		;check if there is custom alphabet table
		LDA	story_hdr_alphabet_table_lo
		ORA	story_hdr_alphabet_table_hi
		BEQ	ll4

		;todo this code will not work if the table is anywhere but in first 16K
		;fixing lda instructions should be enough enough
		LDA	story_hdr_alphabet_table_lo
		STA	ll1+1
		LDA	story_hdr_alphabet_table_hi
		CLC
		ADC	#>story_hdr_begin
		STA	ll1+2
		LDA	#<(character_table+6)
		STA	ll2+1
		LDA	#>(character_table+6)
		STA	ll2+2

		LDX	#3
ll3:		LDY	#26-1
ll1:		LDA.a	$0000,Y
ll2:		STA.a	$0000,Y
		DEY
		BPL	ll1
		
		LDA	ll1+1
		CLC
		ADC	#26
		STA	ll1+1
		LDA	ll1+2
		ADC	#0
		STA	ll1+2

		LDA	ll2+1
		CLC
		ADC	#32
		STA	ll2+1
		LDA	ll2+2
		ADC	#0
		STA	ll2+2
		DEX
		BNE	ll3
ll4:
		.endif

		;initialize the PC, hihi is 0 by default (as all zvars are 0)
		LDA	story_hdr_pc_hi
		STA	zcode_addr_hi_97
		LDA	story_hdr_pc_lo
		STA	zcode_addr_lo_96

		;todo not sure if still needed here?
		LDA	#[SCREEN_LINES_TOTAL-1]
		STA	screen_lines_to_scroll_E1

		.if SD_TWO_SIDE
		JSR	ask_insert_side_2
		;for others there is no need for any prompt
		.endif
	
		;init the screen model variables
		;todo should be before the 'ask' or not?
		JSR	clear_screen_init_scr_vars

		.if EXTMEM
		LDA	extmem_map_portbs
		STA	PORTB
		.endif
		LDA	#$FF
		STA	transcripting_control_DF
		LDA	story_hdr_flags2_lo
		ORA	byte_2034
		STA	story_hdr_flags2_lo
		JMP	main_execution_loop		;could be avoided if next vars moved elsewhere

; ---------------------------------------------------------------------------

operand_types_temp1:	.BYTE 0		;stores 4 types
operand_types_counter: .BYTE 0
operand_types_counter_end: .BYTE 8	;this constant is used for z3, other versions change this in runtime

.if ZVER >= 4
operand_types_temp2:	.BYTE 0		;stores additional 4 types
.endif

.if ZVER >= 5
extended_opcode: .BYTE 0
.endif

main_execution_loop:

		LDA	#0
		STA	argument_count_81
		JSR	get_one_code_zbyte
		;##TRACE "%06X inst:%02X" db($98)+dw($96)-1 (a)
		STA	current_opcode_80
		TAX	;just to refresh flags for next jump
		BMI	inst_ge_80
		JMP	process_opcodes_00_to_7F

inst_ge_80:
		CMP	#$B0
		BCS	inst_ge_B0
		JMP	process_opcodes_80_AF

inst_ge_B0:
		CMP	#$C0
		BCS	processing_var_operands
		JMP	between_B0_BF_process_0OP

processing_var_operands:
		JSR	get_one_code_zbyte
		STA	operand_types_temp1

		.if ZVER >= 4
		LDA	#[4*2]				;4 parameters max
		STA	operand_types_counter_end

		LDA	current_opcode_80
		CMP	#$EC				;only for call_vs2
		BEQ	setup_optypes_loop2
		.if ZVER >= 5
		CMP	#$FA				;call_vn2
		BEQ	setup_optypes_loop2
		.endif
		LDA	#$0
		STA	operand_types_temp2		;could be maybe removed
		BEQ	setup_optypes_loop1
setup_optypes_loop2:
		JSR	get_one_code_zbyte
		STA	operand_types_temp2
		LDA	#[8*2]				;8 parameters max
		STA	operand_types_counter_end
		.endif

setup_optypes_loop1:
		LDA	operand_types_temp1
		LDX	#0
		STX	operand_types_counter
		BEQ	switch_on_two_upper_bits

operand_types_loop:
		;moves two bits left for masking in next step
		.if ZVER = 3
		LDA	operand_types_temp1
		ASL
		ASL
		STA	operand_types_temp1
		.else
		ASL	operand_types_temp2
		ROL	operand_types_temp1
		ASL	operand_types_temp2
		ROL	operand_types_temp1
		LDA	operand_types_temp1
		.endif

switch_on_two_upper_bits:
		AND	#$C0		
		BNE	next_type2
		;%00 - type large constant
		JSR	read_code_zword_to_temp
		JMP	process_one_type

next_type2:
		CMP	#$40
		BNE	next_type3
		;%01 - type small constant
		JSR	read_code_zbyte_to_temp
		JMP	process_one_type

next_type3:
		CMP	#$80
		BNE	next_type4
		;$10 - type variable
		JSR	process_code_zbyte_as_variable

process_one_type:
		LDX	operand_types_counter
		LDA	temp_lo_92
		STA	arg1_lo_82,X
		LDA	temp_hi_93
		STA	arg1_hi_83,X
		INC	argument_count_81
		INX
		INX
		STX	operand_types_counter
		CPX	operand_types_counter_end		;in v3 it's always 8, in v4 it could be 8 or 16
		BCC	operand_types_loop

next_type4:
		;actually end of processing. Although not explicitely stated in standard, bits 11 stop processing
		LDA	current_opcode_80

		.if ZVER >= 5
		CMP	#$BE
		BNE	nt42
		LDA	extended_opcode
		AND	#op_ext_mask
		LDX	#<tbl_op_ext
		LDY	#>tbl_op_ext
		BNE	execute_opcode
nt42:
		.endif

		CMP	#$E0
		BCS	process_VAR_opcodes
		JMP	process_2OP

process_VAR_opcodes:
		LDX	#<tbl_op_var
		LDY	#>tbl_op_var
		AND	#op_var_mask		;execute var_ops

execute_opcode:
		STX	temp2_lo_94
		STY	temp2_hi_95
		ASL
		TAY
		LDA	(temp2_lo_94),Y
		STA	actual_execute+1
		INY
		LDA	(temp2_lo_94),Y
		STA	actual_execute+2
actual_execute: JSR	$0000
		JMP	main_execution_loop

between_B0_BF_process_0OP:
		.if ZVER >= 5
		CMP	#$BE
		BNE     bbbp0o
		JSR	get_one_code_zbyte
		STA	extended_opcode
		JMP	processing_var_operands
		.endif

bbbp0o:		LDX	#<tbl_op_0
		LDY	#>tbl_op_0
		AND	#op_0_mask	; BF-B0	= inst in lower	4 bits
		JMP	execute_opcode	; execute 0OPs

process_opcodes_80_AF:
		AND	#$30
		BNE	next_1op1
		JSR	read_code_zword_to_temp
		JMP	process_1OP

next_1op1:
		CMP	#$10
		BNE	next_1op2
		JSR	read_code_zbyte_to_temp
		JMP	process_1OP

next_1op2:
		CMP	#$20
		BNE	op_1_int_error_3
		JSR	process_code_zbyte_as_variable ; processing 1OPs

process_1OP:
		;JSR	move_temp_to_arg1_of_opcode
		LDA	temp_lo_92
		STA	arg1_lo_82
		LDA	temp_hi_93
		STA	arg1_hi_83
		INC	argument_count_81

		LDX	#<tbl_op_1
		LDY	#>tbl_op_1
		LDA	current_opcode_80
		AND	#op_1_mask
		JMP	execute_opcode

op_1_int_error_3:
		LDA	#3
	       	JMP	display_internal_error

process_opcodes_00_to_7F:
		AND	#$40
		BNE	first_is_variable_2op
		JSR	read_code_zbyte_to_temp
		JMP	process_second_2op_par

first_is_variable_2op:
		JSR	process_code_zbyte_as_variable

process_second_2op_par:
		;JSR	move_temp_to_arg1_of_opcode
		LDA	temp_lo_92
		STA	arg1_lo_82
		LDA	temp_hi_93
		STA	arg1_hi_83
		INC	argument_count_81

		LDA	current_opcode_80
		AND	#$20
		BNE	second_is_variable_2op
		JSR	read_code_zbyte_to_temp
		JMP	move_temp_to_arg2_of_opcode

second_is_variable_2op:
		JSR	process_code_zbyte_as_variable

move_temp_to_arg2_of_opcode:
		LDA	temp_lo_92
		STA	arg2_lo_84
		LDA	temp_hi_93
		STA	arg2_hi_85
		INC	argument_count_81

process_2OP:
		LDX	#<tbl_op_2
		LDY	#>tbl_op_2
		LDA	current_opcode_80
		AND	#op_2_mask
		JMP	execute_opcode		;execute 2OPs

		;this is just a debugging tool
		.if DEBUG_PRINTS
print_hex:
		LDA	arg1_lo_82
		LSR
		LSR
		LSR
		LSR
		AND	#$0F
		JSR	print_nibble
		LDA	arg1_lo_82
		AND	#$0F
print_nibble:	CMP	#$0A
		BCC	pn1
		ADC	#('A'-'0'-10-1)
pn1:		ADC	#'0'
		JMP	print_a_character
		.endif

op_illegal_instruction:

		.if DEBUG_PRINTS
		JSR	op0_new_line

		LDA	zcode_addr_hihi_98
		STA	arg1_lo_82
		JSR	print_hex
		LDA	zcode_addr_hi_97
		STA	arg1_lo_82
		JSR	print_hex
		LDA	zcode_addr_lo_96
		STA	arg1_lo_82
		JSR	print_hex

		LDA	#' '
		JSR	print_a_character

		LDA	current_opcode_80
		STA	arg1_lo_82
		JSR	print_hex

		.if ZVER >= 5
		LDA	current_opcode_80
		CMP	#$BE
		BNE	oii41
		LDA	extended_opcode
		STA	arg1_lo_82
		JSR	print_hex
		.endif
		.endif

oii41:		JSR	op0_new_line
		LDA	#4
		JMP	display_internal_error

	
; =============== S U B	R O U T	I N E =======================================


move_temp_to_arg1_of_opcode:
		LDA	temp_lo_92
		STA	arg1_lo_82
		LDA	temp_hi_93
		STA	arg1_hi_83
		INC	argument_count_81
		RTS


; =============== S U B	R O U T	I N E =======================================


read_code_zbyte_to_temp:
		LDA	#0
		BEQ	temp_hi_is_zero

read_code_zword_to_temp:
		JSR	get_one_code_zbyte

temp_hi_is_zero:
		STA	temp_hi_93
		JSR	get_one_code_zbyte
		STA	temp_lo_92
		RTS


; =============== S U B	R O U T	I N E =======================================


load_variable_A_to_temp:
		TAX
		BNE	process_variables
		JSR	op0_pop		;in this case it's popped/pushed = just read
		JMP	push_temp_92_93

process_code_zbyte_as_variable:
		JSR	get_one_code_zbyte
		BEQ	op0_pop		;in this case it's popped actually. Test it, weird?

process_variables:
		CMP	#16
		BCS	read_global_variable_A_to_temp

		;processes true local variable
		SEC
		SBC	#1
		ASL
		TAX
		LDA	local_vars_lo,X
		STA	temp_lo_92
		LDA	local_vars_hi,X
		STA	temp_hi_93
		RTS


; =============== S U B	R O U T	I N E =======================================

;input: A with variable number
;output: ptr in temp_obj
var_num_in_A_to_global_var_ptr_in_temp2:
		SEC
		SBC	#16		; remove local vars
		LDY	#0
		STY	temp2_hi_95
		ASL			; mul by 2 (word values)
		ROL	temp2_hi_95
		CLC
		ADC	ptr_globals_lo	; add global tbl ptr
		STA	temp2_lo_94
		LDA	temp2_hi_95
		ADC	ptr_globals_hi
		STA	temp2_hi_95
		RTS


; =============== S U B	R O U T	I N E =======================================

;A - variable number, assummed getting only those with $10 and higher
;destroys A, Y, temp2
;returns in temp_hi/temp_lo the word stored in global var

read_global_variable_A_to_temp:
		JSR	var_num_in_A_to_global_var_ptr_in_temp2

		LDY	#0
		JSR	get_one_byte_from_temp2_byte_Y_address
		STA	temp_hi_93
		INY
		JSR	get_one_byte_from_temp2_byte_Y_address
		STA	temp_lo_92

		RTS


; =============== S U B	R O U T	I N E =======================================

.if LARGE_STACK
stack_pages = 8
stack_start_page = graphics_start_page - stack_pages
.endif

op0_pop:
		.if LARGE_STACK
		LDA	stack_pointer_lo_A2
		BNE	o0p_1
		LDA	stack_pointer_hi_A3
		CMP	#stack_start_page
		BEQ	error_stack_underflow
		DEC	stack_pointer_hi_A3
		DEC	stack_pointer_hi_A3
o0p_1:		DEC	stack_pointer_lo_A2

		LDY	stack_pointer_hi_A3
		STY	o0p_2+2
		INY
		STY 	o0p_3+2

		LDY	stack_pointer_lo_A2
o0p_2:		LDX.a	$0000,Y
		STX	temp_lo_92
o0p_3:		LDA.a	$0000,Y
		STA	temp_hi_93
		RTS
		.else
		;smol stack
		DEC	stack_pointer_lo_A2
		BEQ	error_stack_underflow
		LDY	stack_pointer_lo_A2
		LDX	stack_word_lo,Y
		STX	temp_lo_92
		LDA	stack_word_hi,Y
		STA	temp_hi_93
		RTS
		.endif

error_stack_underflow:
		LDA	#5
		JMP	display_internal_error


; ---------------------------------------------------------------------------

push_temp_92_93:
		LDX	temp_lo_92
		LDA	temp_hi_93

push_stack_A_X:
		.if LARGE_STACK
		LDY	stack_pointer_hi_A3
		STY	psax_2+2
		INY
		STY	psax_1+2
		LDY	stack_pointer_lo_A2
psax_1:		STA.a	$0000,Y
		TXA
psax_2:		STA.a	$0000,Y
		INC	stack_pointer_lo_A2
		BNE	psax_3
		INC	stack_pointer_hi_A3
		INC	stack_pointer_hi_A3
		LDA	stack_pointer_hi_A3
		CMP	#[stack_start_page + stack_pages]
		BEQ	error_stack_overflow
psax_3:		RTS

		.else
		;smol stack
		LDY	stack_pointer_lo_A2
		STA	stack_word_hi,Y
		TXA
		STA	stack_word_lo,Y
		INC	stack_pointer_lo_A2
		BEQ	error_stack_overflow
		RTS
		.endif

error_stack_overflow:
		LDA	#6
		JMP	display_internal_error


; ---------------------------------------------------------------------------


set_variable_A_to_temp_value:
		TAX
		BNE	store_to_variable

		.if LARGE_STACK
		DEC	stack_pointer_lo_A2
		BNE	push_temp_92_93
		LDY	stack_pointer_hi_A3
		CPY	#stack_start_page
		BEQ	error_stack_underflow
		DEC	stack_pointer_hi_A3
		DEC	stack_pointer_hi_A3
		JMP	push_temp_92_93

		.else
		DEC	stack_pointer_lo_A2	;this also overwrites top of stack
		BNE	push_temp_92_93
		.endif
		BEQ	error_stack_underflow

return_zero:
		LDA	#0

store_value_in_A:

		STA	temp_lo_92
		LDA	#0
		STA	temp_hi_93

store_value_in_temp:
		JSR	get_one_code_zbyte
		BEQ	push_temp_92_93

store_to_variable:
		CMP	#16
		BCS	store_global_variable
		SEC
		SBC	#1
		ASL
		TAX
		LDA	temp_lo_92
		STA	local_vars_lo,X
		LDA	temp_hi_93
		STA	local_vars_hi,X
		RTS


; ---------------------------------------------------------------------------

store_global_variable:
		JSR	var_num_in_A_to_global_var_ptr_in_temp2

		.if EXTMEM

		LDA	temp2_lo_94
		STA	temp_modded_lo_FA
		LDY	temp2_hi_95
		LDA	extmem_map_portbs,Y
		STA	PORTB
		LDA	extmem_map_pgs,Y
		STA	temp_modded_hi_FB

		LDY 	#$00
		LDA	temp_hi_93
		STA	(temp_modded_lo_FA),Y

		LDA	temp2_lo_94
		CMP	#$FF
		BNE	sgv_1

		LDY	temp2_hi_95
		LDA	extmem_map_portbs+1,Y
		STA	PORTB
		LDA	extmem_map_pgs+1,Y
		STA	temp_modded_hi_FB
sgv_1:
		INC	temp_modded_lo_FA
sgv_2:
		LDY	#$00
		LDA	temp_lo_92
		STA	(temp_modded_lo_FA),Y
		.else

		LDA	temp_hi_93
		STA	(temp2_lo_94),Y
		INY
		LDA	temp_lo_92
		STA	(temp2_lo_94),Y

		.endif
prf_rts:
		RTS


; =============== S U B	R O U T	I N E =======================================

		;0 - return false
		;1 - return true
		;$40 on - jump is short, unsigned 6bits, else jump is long, signed 14 bits
predicate_fails:
		JSR	get_one_code_zbyte
		BPL	pred_do_branch

prf_dontjump:
		AND	#$40			;long or short branch?
		BNE	prf_rts			;short, just return
		JMP	get_one_code_zbyte	;long, just consume byte and return

predicate_succeeds:
		JSR	get_one_code_zbyte
		BPL	prf_dontjump

pred_do_branch:
		TAX
		AND	#$40
		BEQ	pred_do_long_branch
		TXA
		AND	#$3F
		STA	temp_lo_92
		LDA	#0
		STA	temp_hi_93
		BEQ	pred_verify_01

pred_do_long_branch:
		TXA
		AND	#$3F
		TAX
		AND	#$20			;checks for bit5 (ie. direction of jump)
		BEQ	pred_set_long_2nd
		TXA
		ORA	#$E0			;eventually sign extend
		TAX

pred_set_long_2nd:
		STX	temp_hi_93
		JSR	get_one_code_zbyte
		STA	temp_lo_92

pred_verify_01:
		LDA	temp_hi_93
		BNE	execute_jump_in_temp
		LDA	temp_lo_92
		BNE	pred_verify_1
		JMP	op0_rfalse

pred_verify_1:
		CMP	#1
		BNE	execute_jump_in_temp
		JMP	op0_rtrue

; ---------------------------------------------------------------------------

.if ZVER = 3
execute_jump_in_temp:
		JSR	dec_word_temp_92_93 ; always -2
		JSR	dec_word_temp_92_93

		LDA	#0
		STA	temp2_hi_95
		LDA	temp_hi_93
		STA	temp2_lo_94

		ASL
		ROL	temp2_hi_95

		LDA	temp_lo_92
		CLC
		ADC	zcode_addr_lo_96
		BCC	loc_FE2
		INC	temp2_lo_94
		BNE	loc_FE2
		INC	temp2_hi_95

loc_FE2:
		STA	zcode_addr_lo_96
		LDA	temp2_lo_94
		ORA	temp2_hi_95
		BEQ	op0_nop
		LDA	temp2_lo_94
		CLC
		ADC	zcode_addr_hi_97
		STA	zcode_addr_hi_97
		LDA	temp2_hi_95
		ADC	zcode_addr_hihi_98
		AND	#1			;I don't understand this
		STA	zcode_addr_hihi_98

		;on any PC change we invalidate code cache
		;##TRACE "*invalidate in jump"
		LDA	#0			
		STA	zcode_buffer_valid_99

op0_nop:
		RTS
.else
execute_jump_in_temp:
		LDA	#0
		STA	temp2_hi_95

		LDA	temp_lo_92
		SEC
		SBC	#2
		STA	temp_lo_92
		LDA	temp_hi_93
		SBC	#0
		STA	temp_hi_93
		BPL	ej1
		DEC	temp2_hi_95
ej1:

		LDA	zcode_addr_lo_96
		CLC
		ADC	temp_lo_92
		STA	zcode_addr_lo_96
		LDA	zcode_addr_hi_97
		PHA
		ADC	temp_hi_93
		STA	zcode_addr_hi_97
		LDA	zcode_addr_hihi_98
		PHA
		ADC	temp2_hi_95
		STA	zcode_addr_hihi_98

		PLA
		EOR	zcode_addr_hihi_98
		BNE	jinv1
		PLA
		EOR	zcode_addr_hi_97
		BNE	jinv2
		;##TRACE "#NOinvalidate in jump"
		RTS

jinv1:		PLA
jinv2:
		;invalidate code cache
		;##TRACE "*invalidate in jump"
		LDA	#0
		STA	zcode_buffer_valid_99
op0_nop:
		RTS

.endif

; =============== S U B	R O U T	I N E =======================================


dec_word_temp_92_93:
		LDA	temp_lo_92
		SEC
		SBC	#1
		STA	temp_lo_92
		BCS	dwt1
		DEC	temp_hi_93
dwt1:
		RTS


; =============== S U B	R O U T	I N E =======================================


inc_word_temp_92_93:
		INC	temp_lo_92
		BNE	dit1
		INC	temp_hi_93
dit1:
		RTS


; =============== S U B	R O U T	I N E =======================================


arg1_to_temp_92_93:
		LDA	arg1_lo_82
		STA	temp_lo_92
		LDA	arg1_hi_83
		STA	temp_hi_93
		RTS


; ---------------------------------------------------------------------------
;opcode jump tables

;this just assembles table depending on zmachine version
keyword .macro z3,z4,z5
	.if ZVER = 3
	.WORD :z3
	.elseif ZVER = 4
	.WORD :z4
	.elseif ZVER >= 5	;true for z5, z7, z8
	.WORD :z5
	.endif
.endm

.align 2,0
tbl_op_0:
		keyword op0_rtrue,		op0_rtrue,		op0_rtrue 
		keyword op0_rfalse,		op0_rfalse,		op0_rfalse
		keyword op0_print,		op0_print,		op0_print
		keyword op0_print_ret,		op0_print_ret,		op0_print_ret
		keyword op0_nop,		op0_nop,		op0_nop
		keyword op0_save,		op0_save,		op_illegal_instruction
		keyword op0_restore,		op0_restore,		op_illegal_instruction
		keyword op0_restart,		op0_restart,		op0_restart
		keyword op0_ret_popped,		op0_ret_popped,		op0_ret_popped
		keyword op0_pop,		op0_pop,		op0_catch		; 5 catch
		keyword op0_quit,		op0_quit,		op0_quit
		keyword op0_new_line,		op0_new_line,		op0_new_line
		keyword op0_show_status,	op_illegal_instruction,	op_illegal_instruction
		keyword	op0_verify,		op0_verify,		op0_verify
		keyword op_illegal_instruction,	op_illegal_instruction,	op_illegal_instruction	;5 extended (implemented in code)
		keyword op_illegal_instruction,	op_illegal_instruction,	op0_piracy		;5 piracy

op_0_mask = $F
op_0_cnt = ( * - tbl_op_0 ) / 2
.if[ op_0_cnt != op_0_mask+1 ]
	.error "Tbl op0 too short: ",op_0_cnt
.endif

tbl_op_1:
		keyword op1_jz,			op1_jz,			op1_jz
		keyword op1_get_sibling,	op1_get_sibling,	op1_get_sibling
		keyword op1_get_child,		op1_get_child,		op1_get_child
		keyword op1_get_parent,		op1_get_parent,		op1_get_parent
		keyword op1_get_prop_len,	op1_get_prop_len,	op1_get_prop_len
		keyword op1_inc,		op1_inc,		op1_inc
		keyword op1_dec,		op1_dec,		op1_dec
		keyword op1_print_addr,		op1_print_addr,		op1_print_addr
		keyword op_illegal_instruction,	op1_call_1s,		op1_call_1s
		keyword op1_remove_obj,		op1_remove_obj,		op1_remove_obj
		keyword op1_print_obj,		op1_print_obj,		op1_print_obj
		keyword op1_ret,		op1_ret,		op1_ret
		keyword op_jump,		op_jump,		op_jump
		keyword op1_print_paddr,	op1_print_paddr,	op1_print_paddr
		keyword op1_load,		op1_load,		op1_load
		keyword op1_not,		op1_not,		op1_call_1n

op_1_mask = $F
op_1_cnt = ( * - tbl_op_1 ) / 2
.if[ op_1_cnt != op_1_mask+1 ]
	.error "Tbl op1 too short: ",op_1_cnt
.endif

tbl_op_2:	
		keyword op_illegal_instruction	op_illegal_instruction	op_illegal_instruction
		keyword op2_je			op2_je			op2_je
		keyword op2_jl			op2_jl			op2_jl
		keyword op2_jg			op2_jg			op2_jg
		keyword op2_dec_chk		op2_dec_chk		op2_dec_chk
		keyword op2_inc_chk		op2_inc_chk		op2_inc_chk
		keyword op2_jin			op2_jin			op2_jin
		keyword op2_test		op2_test		op2_test
		keyword op2_or			op2_or			op2_or
		keyword op2_and			op2_and			op2_and
		keyword op2_test_attr		op2_test_attr		op2_test_attr
		keyword op2_set_attr		op2_set_attr		op2_set_attr
		keyword op2_clear_attr		op2_clear_attr		op2_clear_attr
		keyword op2_store		op2_store		op2_store
		keyword op2_insert_obj		op2_insert_obj		op2_insert_obj
		keyword op2_loadw		op2_loadw		op2_loadw
		keyword op2_loadb		op2_loadb		op2_loadb
		keyword op2_get_prop		op2_get_prop		op2_get_prop
		keyword op2_get_prop_addr	op2_get_prop_addr	op2_get_prop_addr
		keyword op2_get_next_prop	op2_get_next_prop	op2_get_next_prop
		keyword op2_add			op2_add			op2_add
		keyword op2_sub			op2_sub			op2_sub
		keyword op2_mul			op2_mul			op2_mul
		keyword op2_div			op2_div			op2_div
		keyword op2_mod			op2_mod			op2_mod
		keyword op_illegal_instruction	op2_call_2s		op2_call_2s
		keyword op_illegal_instruction	op_illegal_instruction	op2_call_2n		;5 call_2n
		keyword op_illegal_instruction	op_illegal_instruction	op2_set_colour		;5 set_colour
		keyword op_illegal_instruction	op_illegal_instruction	op2_throw		;5 throw
		keyword op_illegal_instruction	op_illegal_instruction	op_illegal_instruction
		keyword op_illegal_instruction	op_illegal_instruction	op_illegal_instruction
		keyword op_illegal_instruction	op_illegal_instruction	op_illegal_instruction

op_2_mask = $1F
op_2_cnt = ( * - tbl_op_2 ) / 2
.if[ op_2_cnt != op_2_mask+1 ]
	.error "Tbl op2 too short: ",op_2_cnt
.endif

tbl_op_var:
		keyword	opvar_call,		opvar_call_vs,		opvar_call_vs		;00
		keyword opvar_storew,		opvar_storew,		opvar_storew		;01
		keyword	opvar_storeb,		opvar_storeb,		opvar_storeb		;02
		keyword opvar_put_prop,		opvar_put_prop,		opvar_put_prop		;03
		keyword	opvar_sread,		opvar_sread,		opvar_aread		;04 4 different sread, 5 even more different
		keyword opvar_print_char,	opvar_print_char,	opvar_print_char        ;05
		keyword	opvar_print_num,	opvar_print_num,	opvar_print_num         ;06
		keyword opvar_random,		opvar_random,		opvar_random            ;07
		keyword	opvar_push,		opvar_push,		opvar_push              ;08
		keyword opvar_pull,		opvar_pull,		opvar_pull              ;09
		keyword	opvar_split_window,	opvar_split_window,	opvar_split_window      ;0a
		keyword opvar_set_window,	opvar_set_window,	opvar_set_window        ;0b
		keyword	op_illegal_instruction,	opvar_call_vs2,		opvar_call_vs2		;0c 4 call_vs2
		keyword op_illegal_instruction,	opvar_erase_window,	opvar_erase_window	;0d 4 erase_window
		keyword op_illegal_instruction,	op_illegal_instruction,	op_illegal_instruction	;0e 4 erase_line
		keyword op_illegal_instruction,	opvar_set_cursor,	opvar_set_cursor	;0f 4 set_cursor
		keyword op_illegal_instruction, op_illegal_instruction,	opvar_get_cursor	;10 4 get_cursor
		keyword op_illegal_instruction,	opvar_set_text_style,	opvar_set_text_style	;11 4 set_text_style
		keyword op_illegal_instruction,	opvar_buffer_mode,	opvar_buffer_mode	;12 4 buffer_mode
		keyword op_illegal_instruction,	opvar_output_stream,	opvar_output_stream	;13 3 output_stream
		keyword op_illegal_instruction,	op_illegal_instruction,	op_illegal_instruction	;14 3 input_stream
		keyword	op0_nop,		op0_nop,		op0_nop			;15 3 sound_effect
		keyword op_illegal_instruction,	opvar_read_char,	opvar_read_char		;16 4 read_char
		keyword	op_illegal_instruction,	opvar_scan_table,	opvar_scan_table	;17 4 scan_table
		keyword op_illegal_instruction,	op_illegal_instruction,	op1_not			;18 5 not
		keyword op_illegal_instruction,	op_illegal_instruction,	opvar_call_vn		;19 5 call_vn
		keyword op_illegal_instruction,	op_illegal_instruction,	opvar_call_vn2		;1a 5 call_vn2
		keyword op_illegal_instruction,	op_illegal_instruction,	opvar_tokenise		;1b 5 tokenise
		keyword op_illegal_instruction,	op_illegal_instruction,	op_illegal_instruction	;1c 5 encode_text
		keyword	op_illegal_instruction,	op_illegal_instruction,	opvar_copy_table	;1d 5 copy_table
		keyword op_illegal_instruction,	op_illegal_instruction,	opvar_print_table	;1e 5 print_table
		keyword	op_illegal_instruction,	op_illegal_instruction,	opvar_check_arg_count	;1f 5 check_arg_count

op_var_mask = $1F
op_var_cnt = ( * - tbl_op_var ) / 2
.if[ op_var_cnt != op_var_mask+1 ]
	.error "Tbl op_var too short: ",op_var_cnt
.endif

.if ZVER >= 5
tbl_op_ext:
		.WORD op0_save			;00 5 save
		.WORD op0_restore		;01 5 restore
		.WORD op_ext_log_shift		;02 5 log_shift
		.WORD op_ext_art_shift		;03 5 art_shift
		.WORD op_ext_set_font		;04 5 set_font
		.WORD op_illegal_instruction	;05
		.WORD op_illegal_instruction	;06
		.WORD op_illegal_instruction	;07
		.WORD op_illegal_instruction	;08
		.WORD op_ext_save_undo		;09 5 save_undo
		.WORD op_illegal_instruction	;0a 5 restore_undo
		.WORD op_illegal_instruction	;0b 5 print_unicode
		.WORD op_illegal_instruction	;0c 5 check_unicode
		.WORD op_ext_set_true_colour	;0d 5 set_true_colour
		.WORD op_illegal_instruction	;0e
		.WORD op_illegal_instruction	;0f

op_ext_mask = $0F
op_ext_cnt = ( * - tbl_op_ext ) / 2
.if[ op_ext_cnt != op_ext_mask+1 ]
	.error "Tbl op_ext too short: ",op_ext_cnt
.endif
.endif

; ---------------------------------------------------------------------------

op0_rtrue:
		LDX	#1

common_return_bool:
		LDA	#0

common_return_val_in_A_X:
		STX	arg1_lo_82
		STA	arg1_hi_83
		JMP	op1_ret

op0_rfalse:
		LDX	#0
		BEQ	common_return_bool

; =============== S U B	R O U T	I N E =======================================

		;why is there difference on entry/exit?
		;entry copies address and invalidates buffer
		;exit copies address back, together with validated buffer
		;rewrote to be the same, no bad side effect encountered so far

op0_print:
		LDX	#5
o0p_l1:		LDA	zcode_addr_lo_96,X
		STA	zdata_addr_lo_9C,X
		DEX
		BPL	o0p_l1

		;prints string and moves zdata_addr pointer
		JSR	print_zstring		

		;gets back code addr from zdata addr
		LDX	#5
o0p_l2:		LDA	zdata_addr_lo_9C,X
		STA	zcode_addr_lo_96,X
		DEX
		BPL	o0p_l2

		RTS


; =============== S U B	R O U T	I N E =======================================


op0_print_ret:
		JSR	op0_print
		JSR	op0_new_line
		JMP	op0_rtrue


; =============== S U B	R O U T	I N E =======================================

op0_ret_popped:
		JSR	op0_pop
		JMP	common_return_val_in_A_X


; =============== S U B	R O U T	I N E =======================================

.if ZVER >= 5
op0_piracy:
		JMP	predicate_succeeds
.endif

; =============== S U B	R O U T	I N E =======================================

op0_verify:
		JSR	print_interpreter_version_and_load_s1

		LDA	#0
		STA	local_vars_cnt1_BE	;none of these labels specify what they do in this function ;)
		STA	local_vars_cnt2_BF
		STA	tmp_bitmap_F9

		;cleaning up the zdata pointer, invalidating it
		LDX	#3
o0v_l1:
		STA	zdata_addr_lo_9C,X
		DEX
		BPL	o0v_l1


		LDA	#$40		; do not checksum first	$40 bytes of story
		STA	zdata_addr_lo_9C

		;modifies function get_one_data_zbyte to compare with any zpage zeroed register
		;this then reads all bytes from disk (otherwise low mem would be read from ram)
		LDA	#zdata_buffer_lo_A0
		STA	get_one_byte_page_compare_instruction+1	

		.if EXTMEM
		LDA	extmem_map_portbs
		STA	PORTB
		.endif
		LDA	story_hdr_resident_memory_hi
		STA	temp2_hi_95
		LDA	story_hdr_resident_memory_lo
		STA	temp2_lo_94

static_and_dynamic_memory_loop:
		JSR	get_one_data_zbyte
		CLC
		ADC	local_vars_cnt1_BE
		STA	local_vars_cnt1_BE
		BCC	loc_110A
		INC	local_vars_cnt2_BF
loc_110A:

		LDA	zdata_addr_lo_9C
		CMP	temp2_lo_94
		BNE	static_and_dynamic_memory_loop
		LDA	zdata_addr_hi_9D
		CMP	temp2_hi_95
		BNE	static_and_dynamic_memory_loop

		.if SD_TWO_SIDE
		JSR	ask_insert_side_2
		.else
		JSR	op0_new_line
		.endif

		.if EXTMEM
		LDA	extmem_map_portbs
		STA	PORTB
		.endif
		LDA	story_hdr_flen_hi
		STA	temp2_hi_95
		LDA	story_hdr_flen_lo
		ASL
		STA	temp2_lo_94
		ROL	temp2_hi_95
		ROL	tmp_bitmap_F9

		.if ZVER = 3
		;nothing already done up there
		.elseif ZVER = 4 || ZVER = 5		;file length in Z4 & Z5 is *4
		ASL	temp2_lo_94
		ROL	temp2_hi_95
		ROL	tmp_bitmap_F9
		.elseif ZVER = 7 || ZVER = 8		;file length in Z7 & Z8 is *8
		ASL	temp2_lo_94
		ROL	temp2_hi_95
		ROL	tmp_bitmap_F9

		ASL	temp2_lo_94
		ROL	temp2_hi_95
		ROL	tmp_bitmap_F9
		.else
			.error
		.endif

high_memory_loop:
		JSR	get_one_data_zbyte
		CLC
		ADC	local_vars_cnt1_BE
		STA	local_vars_cnt1_BE
		BCC	loc_1134
		INC	local_vars_cnt2_BF
loc_1134:

		LDA	zdata_addr_lo_9C
		CMP	temp2_lo_94
		BNE	high_memory_loop
		LDA	zdata_addr_hi_9D
		CMP	temp2_hi_95
		BNE	high_memory_loop
		LDA	zdata_addr_hihi_9E
		CMP	tmp_bitmap_F9
		BNE	high_memory_loop

		LDA	#resident_mem_in_pages_A7
		STA	get_one_byte_page_compare_instruction+1	;reverts the function back to compare with reg $a4

		;##TRACE "*zcode invalidate in verify"
		;##TRACE "*zdata invalidate in verify"
		LDA	#0
		STA	zdata_buffer_valid_9F
		STA	zcode_buffer_valid_99

		.if EXTMEM
		LDA	extmem_map_portbs
		STA	PORTB
		.endif
		LDA	story_hdr_crc_lo
		CMP	local_vars_cnt1_BE
		BNE	invalid_checksum
		LDA	story_hdr_crc_hi
		CMP	local_vars_cnt2_BF
		BNE	invalid_checksum
loc_pred_suc:
		JMP	predicate_succeeds

loc_pred_fail:
invalid_checksum:
		JMP	predicate_fails



; =============== S U B	R O U T	I N E =======================================


op1_jz:
		LDA	arg1_lo_82
		ORA	arg1_hi_83
		BEQ	loc_pred_suc
loc_1165:
		JMP	predicate_fails

; ---------------------------------------------------------------------------

.if ZVER = 3
get_one_byte_from_object_A_byte_Y_address:
		STA	temp2_lo_94			;in A is object number
		LDX	#0
		STX	temp2_hi_95

		ASL
		ROL	temp2_hi_95
		ASL
		ROL	temp2_hi_95
		ASL
		ROL	temp2_hi_95
		CLC
		ADC	temp2_lo_94
		BCC	gobfoabya_1
		INC	temp2_hi_95

gobfoabya_1:
		CLC					;input multiplied by 9 (sizeof object in v3)
		ADC	#[DEFAULT_PROPS_CNT*2-OBJ_SIZE]	;object table begins with 31 default property words. 31*2-9 = 53
		BCC	gobfoabya_2
		INC	temp2_hi_95

gobfoabya_2:
		.if EXTMEM
		STA	temp2_lo_94
		TYA
		CLC
		ADC	temp2_lo_94
		STA	temp2_lo_94
		BCC	gobfoabya_3
		INC	temp2_hi_95
gobfoabya_3:
		LDA	temp2_lo_94
		CLC
		ADC	ptr_objects_lo
		STA	gobfoabya_4+1

		LDA	temp2_hi_95
		ADC	ptr_objects_hi
		TAX
		LDA	extmem_map_portbs,X
		STA	PORTB
		LDA	extmem_map_pgs,X
		STA	gobfoabya_4+2
gobfoabya_4:	LDA.a	$0000

		.else
		CLC
		ADC	ptr_objects_lo
		STA	temp2_lo_94

		LDA	temp2_hi_95
		ADC	ptr_objects_hi
		STA	temp2_hi_95

		LDA	(temp2_lo_94),Y
		.endif

		RTS

set_one_byte_X_in_object_A_addr_Y:
;A - object
;X - value
;Y - offs in object

		STA	temp2_lo_94			;in A is object number
		PHA
		LDA	#0
		STA	temp2_hi_95
		PLA

		ASL
		ROL	temp2_hi_95
		ASL
		ROL	temp2_hi_95
		ASL
		ROL	temp2_hi_95
		CLC
		ADC	temp2_lo_94
		BCC	sobfoabya_1
		INC	temp2_hi_95

sobfoabya_1:
		CLC			; input	multiplied by 9	(sizeof	object in v3)
		ADC	#[DEFAULT_PROPS_CNT*2-OBJ_SIZE]		; object table begins with 31 default property words. 31*2-9 = 53
		BCC	sobfoabya_2
		INC	temp2_hi_95

sobfoabya_2:
		.if EXTMEM
		STA	temp2_lo_94
		TYA
		CLC
		ADC	temp2_lo_94
		STA	temp2_lo_94

		LDA	temp2_hi_95
		ADC     #0
		STA	temp2_hi_95

		TXA
		PHA

		LDA	temp2_lo_94
		CLC
		ADC	ptr_objects_lo
		STA	sobfoabya_4+1

		LDA	temp2_hi_95
		ADC	ptr_objects_hi
		TAX

		LDA	extmem_map_portbs,X
		STA	PORTB
		LDA	extmem_map_pgs,X
		STA	sobfoabya_4+2
		PLA
sobfoabya_4:	STA.a	$0000

		.else
		CLC
		ADC	ptr_objects_lo
		STA	temp2_lo_94
		LDA	temp2_hi_95
		ADC	ptr_objects_hi
		STA	temp2_hi_95

		TXA
		STA	(temp2_lo_94),Y
		.endif

		RTS

.else

set_obj_addr_X_A_to_temp2:
		STA	temp2_lo_94
		STX	temp2_hi_95
	
		ASL
		ROL	temp2_hi_95
		ASL
		ROL	temp2_hi_95
		ASL
		ROL	temp2_hi_95
		SEC
		SBC	temp2_lo_94
		STA	temp2_lo_94
		LDA	temp2_hi_95
		STX	temp2_hi_95
		SBC	temp2_hi_95
		STA	temp2_hi_95

		LDA	temp2_lo_94
		ASL
		ROL	temp2_hi_95
		;now we have mul by 14 (sizeof object in z4+)
		CLC
		ADC	#[DEFAULT_PROPS_CNT*2-OBJ_SIZE]
		BCC	gobfoabya_2
		INC	temp2_hi_95
gobfoabya_2:
		CLC
		ADC	ptr_objects_lo
		STA	temp2_lo_94

		LDA	temp2_hi_95
		ADC	ptr_objects_hi
		STA	temp2_hi_95
		RTS

set_one_byte_A_to_temp2_Y_address:
		.if EXTMEM
		PHA
		TXA
		PHA
		TYA
		CLC
		ADC	temp2_lo_94
		STA	sobftobya_1+1
		LDA	temp2_hi_95
		ADC	#0
		TAX
		LDA	extmem_map_portbs,X
		STA	PORTB
		LDA	extmem_map_pgs,X
		STA	sobftobya_1+2
		PLA
		TAX
		PLA
sobftobya_1:	STA.a	$0000
		.else
		STA	(temp2_lo_94),Y
		.endif
		RTS

.endif

get_one_byte_from_temp2_byte_Y_address:
		.if EXTMEM
		TYA
		PHA
		CLC
		ADC	temp2_lo_94
		STA	gobftobya_1+1
		LDA	temp2_hi_95
		ADC	#0
		TAY
		LDA	extmem_map_portbs,Y
		STA	PORTB
		LDA	extmem_map_pgs,Y
		STA	gobftobya_1+2
		PLA
		TAY
gobftobya_1:	LDA.a	$0000
		.else
		LDA	(temp2_lo_94),Y
		.endif
		RTS


; =============== S U B	R O U T	I N E =======================================

.if ZVER = 3
op1_get_sibling:
		LDA	arg1_lo_82
		LDY	#OBJ_SIBLING_OFS
		JSR	get_one_byte_from_object_A_byte_Y_address
		JMP	loc_1178m

op1_get_child:
		LDA	arg1_lo_82
		LDY	#OBJ_CHILD_OFS
		JSR	get_one_byte_from_object_A_byte_Y_address

loc_1178m:
		JSR	store_value_in_A
		LDA	temp_lo_92
		BEQ	loc_pred_fail2

loc_1181:
		JMP	predicate_succeeds
loc_pred_fail2:
		JMP	predicate_fails

.else

op1_get_sibling:
		LDA	arg1_lo_82
		LDX	arg1_hi_83
		JSR	set_obj_addr_X_A_to_temp2

		LDY	#OBJ_SIBLING_OFS+1
		JSR	get_one_byte_from_temp2_byte_Y_address
		PHA
		LDY	#OBJ_SIBLING_OFS
		JSR	get_one_byte_from_temp2_byte_Y_address
		TAX
		PLA
		JMP	loc_1178m

op1_get_child:
		LDA	arg1_lo_82
		LDX	arg1_hi_83
		JSR	set_obj_addr_X_A_to_temp2

		LDY	#OBJ_CHILD_OFS+1
		JSR	get_one_byte_from_temp2_byte_Y_address
		PHA
		LDY	#OBJ_CHILD_OFS
		JSR	get_one_byte_from_temp2_byte_Y_address
		TAX
		PLA

loc_1178m:
		JSR	store_value_in_X_A
		LDA	temp_lo_92
		ORA	temp_hi_93
		BEQ	loc_pred_fail2

loc_1181:
		JMP	predicate_succeeds
loc_pred_fail2:
		JMP	predicate_fails

.endif


; =============== S U B	R O U T	I N E =======================================
.if ZVER >= 5


;0OP:185 9 5/6 catch -> (result)
;Opposite to throw (and occupying the same opcode that pop used in Versions 3 and 4). catch returns the current "stack frame".

op0_catch:
		LDX	stack_pointer_function_frame_hi_A5
		LDA	stack_pointer_function_frame_lo_A4
		JMP	store_value_in_X_A

.endif

; =============== S U B	R O U T	I N E =======================================

.if ZVER >= 5
;2OP:28 1C 5/6 throw value stack-frame
;Opposite of catch: resets the routine call state to the state it had when the given stack frame value
;was 'caught', and then returns. In other words, it returns as if from the routine which 
;executed the catch which found this stack frame value.

op2_throw:
		LDA	arg2_lo_84
		STA	stack_pointer_function_frame_lo_A4
		LDA	arg2_hi_85
		STA	stack_pointer_function_frame_hi_A5
		JMP	op1_ret

.endif

; =============== S U B	R O U T	I N E =======================================

.if ZVER = 3
op1_get_parent:
		LDA	arg1_lo_82
		LDY	#OBJ_PARENT_OFS	
		JSR	get_one_byte_from_object_A_byte_Y_address
		JMP	store_value_in_A
.else
op1_get_parent:
		LDA	arg1_lo_82
		LDX	arg1_hi_83
		JSR	set_obj_addr_X_A_to_temp2

		LDY	#OBJ_PARENT_OFS+1
		JSR	get_one_byte_from_temp2_byte_Y_address
		PHA
		LDY	#OBJ_PARENT_OFS
		JSR	get_one_byte_from_temp2_byte_Y_address
		TAX
		PLA
		JMP	store_value_in_X_A
.endif

; =============== S U B	R O U T	I N E =======================================

op1_get_prop_len:
		LDA	arg1_lo_82
		ORA	arg1_hi_83
		BNE	o1_gpl_0
		JMP	store_value_in_A

o1_gpl_0:	LDA	arg1_hi_83
		.if !EXTMEM
		CLC
		ADC	game_base_page_A6
		.endif
		STA	temp2_hi_95

		;we are pointing at actual data, after len/id byte, hence move -1 in z3
		LDA	arg1_lo_82
		SEC
		SBC	#1
		STA	temp2_lo_94

		BCS	loc_11A2
		DEC	temp2_hi_95

loc_11A2:
		.if ZVER >= 4
		;when moved -1, we read length byte. If it has bit 7 on, we move for the previous length byte
		LDY	#0
		JSR	get_one_byte_from_temp2_byte_Y_address
		BPL	o1gpl_1

		LDA	temp2_lo_94
		SEC
		SBC	#1
		STA	temp2_lo_94

		BCS	o1gpl_1
		DEC	temp2_hi_95

o1gpl_1:
		.endif

		LDY	#0
		JSR	decode_property_length_from_temp2_to_A
		JMP	store_value_in_A


; =============== S U B	R O U T	I N E =======================================


op1_inc:
		LDA	arg1_lo_82
		JSR	load_variable_A_to_temp
		JSR	inc_word_temp_92_93
		JMP	loc_11C0


; =============== S U B	R O U T	I N E =======================================


op1_dec:
		LDA	arg1_lo_82
		JSR	load_variable_A_to_temp
		JSR	dec_word_temp_92_93

loc_11C0:
		LDA	arg1_lo_82
		JMP	set_variable_A_to_temp_value


; =============== S U B	R O U T	I N E =======================================


op1_print_addr:
		LDA	arg1_lo_82
		STA	zdata_addr_lo_9C
		LDA	arg1_hi_83
		STA	zdata_addr_hi_9D
		LDA	#0
		STA	zdata_addr_hihi_9E
		;##TRACE "*zdata invalidate in print_addr"
		STA	zdata_buffer_valid_9F

		JMP	print_zstring


; =============== S U B	R O U T	I N E =======================================

.if ZVER = 3
op1_remove_obj:
		LDA	arg1_lo_82			;object to be removed
		LDY	#OBJ_PARENT_OFS
		JSR	get_one_byte_from_object_A_byte_Y_address
		;in A is parent object
		BEQ	op_1_09_loc1			;has no parent

		;in A is parent of removed object
		STA	local_vars_cnt1_BE

		LDY	#OBJ_CHILD_OFS				;child of parent
		JSR	get_one_byte_from_object_A_byte_Y_address
		CMP	arg1_lo_82				;I'm not direct child of my parent
		BNE	op_1_09_loc3				;then search

		;otherwise
		LDA	arg1_lo_82
		LDY	#OBJ_SIBLING_OFS			;my sibling
		JSR	get_one_byte_from_object_A_byte_Y_address
		TAX
		LDA	local_vars_cnt1_BE
		LDY	#OBJ_CHILD_OFS				;set as child of parent
		JSR	set_one_byte_X_in_object_A_addr_Y
		JMP	op_1_09_loc2

op_1_09_loc3:
		;LDA	local_vars_cnt1_BE
		;in this place A is child of obj1 parent
op_1_09_loc4:   STA	local_vars_cnt1_BE
		LDY	#OBJ_SIBLING_OFS			;sibling of child of parent
		JSR	get_one_byte_from_object_A_byte_Y_address
		CMP	arg1_lo_82				;does it match removed object
		BNE	op_1_09_loc4				;no, check next sibling

		;this sibling matched removed object
		LDA	arg1_lo_82
		LDY	#OBJ_SIBLING_OFS				
		JSR	get_one_byte_from_object_A_byte_Y_address
		TAX
		LDA	local_vars_cnt1_BE
		LDY	#OBJ_SIBLING_OFS
		JSR	set_one_byte_X_in_object_A_addr_Y	;set found object's sibling to my sibling

op_1_09_loc2:
		LDX	#0
		LDY	#OBJ_PARENT_OFS				;parent
		LDA	arg1_lo_82
		JSR	set_one_byte_X_in_object_A_addr_Y

		LDX	#0
		LDY	#OBJ_SIBLING_OFS			;sibling
		LDA	arg1_lo_82
		JSR	set_one_byte_X_in_object_A_addr_Y

op_1_09_loc1:
		RTS

.else
;z4+
tmp_parent_lo: .BYTE 0
tmp_parent_hi: .BYTE 0

tmp_sibling_lo: .BYTE 0
tmp_sibling_hi: .BYTE 0

tmp_par_child_lo: .BYTE 0
tmp_par_child_hi: .BYTE 0

;removing object means
;	get objectX parent
;	if no parent, exit
;	get objectX sibling
;	get objectX parent's child
;	check if objectX is child of parent
;	if yes - set objectX sibling as child of parent, goto END
;
;	if not - enumerate siblings of child of parent
;		and then set found object's sibling to objectX sibling
;
;END:
;	set 0 to objectX parent
;	set 0 to objectX sibling

op1_remove_obj:
		LDA	arg1_lo_82			;object to be removed
		LDX	arg1_hi_83
		JSR	set_obj_addr_X_A_to_temp2

		LDY	#OBJ_PARENT_OFS+1		;parent
		JSR	get_one_byte_from_temp2_byte_Y_address
		STA	tmp_parent_lo
		LDY	#OBJ_PARENT_OFS			;parent
		JSR	get_one_byte_from_temp2_byte_Y_address
		STA	tmp_parent_hi
		ORA	tmp_parent_lo
		BNE	op_1_09_loc0
		JMP	op_1_09_loc1			;has no parent
	
op_1_09_loc0:
		LDY	#OBJ_SIBLING_OFS+1
		JSR	get_one_byte_from_temp2_byte_Y_address
		STA	tmp_sibling_lo
		LDY	#OBJ_SIBLING_OFS
		JSR	get_one_byte_from_temp2_byte_Y_address
		STA	tmp_sibling_hi

		;now get child of parent
		LDA	tmp_parent_lo
		LDX	tmp_parent_hi
		JSR	set_obj_addr_X_A_to_temp2

		LDY	#OBJ_CHILD_OFS+1		;parent
		JSR	get_one_byte_from_temp2_byte_Y_address
		STA	tmp_par_child_lo
		LDY	#OBJ_CHILD_OFS			;parent
		JSR	get_one_byte_from_temp2_byte_Y_address
		STA	tmp_par_child_hi
		CMP	arg1_hi_83
		BNE	op_1_09_loc3
		LDA	tmp_par_child_lo
		CMP	arg1_lo_82			;I'm not direct child of my parent
		BNE	op_1_09_loc3			;then search

		;otherwise I AM direct child of my parent
		;this means that my sibling must be child of my parent

		;my parent
		LDA	tmp_parent_lo
		LDX	tmp_parent_hi
		JSR	set_obj_addr_X_A_to_temp2

		;set the child
		LDA	tmp_sibling_hi
		LDY	#OBJ_CHILD_OFS
		JSR	set_one_byte_A_to_temp2_Y_address

		LDA	tmp_sibling_lo
		LDY	#OBJ_CHILD_OFS+1
		JSR	set_one_byte_A_to_temp2_Y_address
	
		JMP	op_1_09_loc2

op_1_09_loc3:
		LDA	tmp_par_child_lo
		LDX	tmp_par_child_hi

op_1_09_loc4:   
		STA	tmp_par_child_lo
		STX	tmp_par_child_hi
		JSR	set_obj_addr_X_A_to_temp2
		;sibling of child of parent

		LDY	#OBJ_SIBLING_OFS+1
		JSR	get_one_byte_from_temp2_byte_Y_address
		PHA
		LDY	#OBJ_SIBLING_OFS
		JSR	get_one_byte_from_temp2_byte_Y_address
		TAX
		PLA

		;does it match removed object
		;if no, check next sibling
      		CMP	arg1_lo_82
		BNE	op_1_09_loc4
		CPX	arg1_hi_83
		BNE	op_1_09_loc4

		;this sibling matched removed object
		LDA	tmp_par_child_lo
		LDX	tmp_par_child_hi
		JSR	set_obj_addr_X_A_to_temp2

		LDA	tmp_sibling_hi
		LDY	#OBJ_SIBLING_OFS				
		JSR	set_one_byte_A_to_temp2_Y_address
		LDA	tmp_sibling_lo
		LDY	#OBJ_SIBLING_OFS+1
		JSR	set_one_byte_A_to_temp2_Y_address

op_1_09_loc2:
		LDA	arg1_lo_82
		LDX	arg1_hi_83
		JSR	set_obj_addr_X_A_to_temp2

		LDA	#0
		LDY	#OBJ_PARENT_OFS	
		JSR	set_one_byte_A_to_temp2_Y_address

		LDA	#0
		LDY	#OBJ_PARENT_OFS+1
		JSR	set_one_byte_A_to_temp2_Y_address

		LDA	#0
		LDY	#OBJ_SIBLING_OFS
		JSR	set_one_byte_A_to_temp2_Y_address

		LDA	#0
		LDY	#OBJ_SIBLING_OFS+1
		JSR	set_one_byte_A_to_temp2_Y_address

op_1_09_loc1:
		RTS
.endif

; =============== S U B	R O U T	I N E =======================================

.if ZVER = 3
tmp_lo_bt:	.BYTE 0
op1_print_obj:
		LDA	arg1_lo_82

;this entry point used only in Z3 status line
print_obj_A_desc:
		PHA
		LDY	#OBJ_PROP_OFS
		JSR	get_one_byte_from_object_A_byte_Y_address
		STA	tmp_lo_bt

		PLA
		LDY	#OBJ_PROP_OFS+1
		JSR	get_one_byte_from_object_A_byte_Y_address
		STA	temp2_lo_94

		LDA	tmp_lo_bt
		STA	temp2_hi_95

		INC	temp2_lo_94
		BNE	loc_122C
		INC	temp2_hi_95

loc_122C:
		JSR	cvt_addr_in_temp2_to_zdata
		JMP	print_zstring

.else
op1_print_obj:
		LDA	arg1_lo_82
		LDX	arg1_hi_83
		JSR	set_obj_addr_X_A_to_temp2

		LDY	#OBJ_PROP_OFS+1
		JSR	get_one_byte_from_temp2_byte_Y_address
		PHA
		LDY	#OBJ_PROP_OFS
		JSR	get_one_byte_from_temp2_byte_Y_address
		STA	temp2_hi_95
		PLA
		STA	temp2_lo_94

		INC	temp2_lo_94
		BNE	loc_122C
		INC	temp2_hi_95
loc_122C:

		JSR	cvt_addr_in_temp2_to_zdata
		JMP	print_zstring
.endif

; ---------------------------------------------------------------------------

.if ZVER >= 5
return_val: .BYTE 0
.endif

op1_ret:
		;restore stack ptr (forget anything pushed after entering the function itself)
		LDA	stack_pointer_function_frame_lo_A4
		STA	stack_pointer_lo_A2

		.if LARGE_STACK
		LDA	stack_pointer_function_frame_hi_A5
		STA	stack_pointer_hi_A3
		.endif

		JSR	op0_pop
		STX	temp2_hi_95		;number of pushed locals
		.if ZVER >= 5
		STA	return_val
		.endif
		TXA
		BEQ	no_locals_to_restore

		DEX
		TXA
		ASL
		STA	temp2_lo_94		;used as counter to restore locals
loop_restoring_locals:
		JSR	op0_pop			;pop local
		LDY	temp2_lo_94		;restore it
		STA	local_vars_hi,Y
		TXA
		STA	local_vars_lo,Y
		DEC	temp2_lo_94		;decrement pointers
		DEC	temp2_lo_94
		DEC	temp2_hi_95
		BNE	loop_restoring_locals

no_locals_to_restore:
		.if ZVER >= 5
		JSR	op0_pop
		STA	current_fn_argument_count
		.endif

		.if LARGE_STACK
		;restore frame in large stack
		JSR	op0_pop
		STX	stack_pointer_function_frame_hi_A5
		.endif

		LDA	zcode_addr_hi_97
		PHA
		LDA	zcode_addr_hihi_98
		PHA

		;restore PC and frame
		JSR	op0_pop
		STX	zcode_addr_hi_97
		STA	zcode_addr_hihi_98

		JSR	op0_pop
		STX	stack_pointer_function_frame_lo_A4
		STA	zcode_addr_lo_96

		PLA
		EOR	zcode_addr_hihi_98
		BNE	o1r_inv1
		PLA
		EOR	zcode_addr_hi_97
		BNE	o1r_inv2
		;##TRACE "#NOinvalidate in op1_ret"		
		BEQ	o1r_inv3
o1r_inv1:	PLA
o1r_inv2:

		;invalidate buffer
		;##TRACE "*invalidate in op1_ret"
		LDA	#0
		STA	zcode_buffer_valid_99
o1r_inv3:

		.if ZVER >= 5
		;n functions just return, s functions store
		LDA	return_val
		BNE	retval
		RTS
		.endif
retval:
		JSR	arg1_to_temp_92_93	;return value
		JMP	store_value_in_temp


; =============== S U B	R O U T	I N E =======================================


op_jump:
		JSR	arg1_to_temp_92_93
		JMP	execute_jump_in_temp


; =============== S U B	R O U T	I N E =======================================


op1_print_paddr:
		LDA	arg1_lo_82
		STA	temp2_lo_94
		LDA	arg1_hi_83
		STA	temp2_hi_95
		JSR	cvt_paddr_in_temp2_to_zdata
		JMP	print_zstring


; =============== S U B	R O U T	I N E =======================================


op1_load:
		LDA	arg1_lo_82
		JSR	load_variable_A_to_temp
		JMP	store_value_in_temp


; =============== S U B	R O U T	I N E =======================================


op1_not:
		LDA	arg1_hi_83
		EOR	#$FF
		TAX
		LDA	arg1_lo_82
		EOR	#$FF

store_value_in_X_A:
		STA	temp_lo_92
		STX	temp_hi_93
		JMP	store_value_in_temp


; =============== S U B	R O U T	I N E =======================================


op2_jl:
		JSR	arg1_to_temp_92_93
		JMP	loc_12A4

op2_dec_chk:
		JSR	op1_dec

loc_12A4:
		LDA	arg2_lo_84
		STA	temp2_lo_94
		LDA	arg2_hi_85
		STA	temp2_hi_95
		JMP	loc_12CD

op2_jg:
		LDA	arg1_lo_82
		STA	temp2_lo_94
		LDA	arg1_hi_83
		STA	temp2_hi_95
		JMP	loc_12C5

op2_inc_chk:
		JSR	op1_inc
		LDA	temp_lo_92
		STA	temp2_lo_94
		LDA	temp_hi_93
		STA	temp2_hi_95

loc_12C5:
		LDA	arg2_lo_84
		STA	temp_lo_92
		LDA	arg2_hi_85
		STA	temp_hi_93

loc_12CD:
		JSR	sub_12D4
		BCC	o2t_prs
		BCS	o2ji_prf

sub_12D4:
		LDA	temp2_hi_95
		EOR	temp_hi_93
		BPL	loc_12DF
		LDA	temp2_hi_95
		CMP	temp_hi_93
		RTS

loc_12DF:
		LDA	temp_hi_93
		CMP	temp2_hi_95
		BNE	locret_12E9
		LDA	temp_lo_92
		CMP	temp2_lo_94

locret_12E9:
		RTS


; =============== S U B	R O U T	I N E =======================================



;2OP:27 1B 5 set_colour foreground background
;If coloured text is available, set text to be foreground-against-background. (Flush any buffered text to screen,
; in the old colours, first.)

.if ZVER >= 5
op2_set_colour:
op_ext_set_true_colour:
		;todo - vbxe should work with this
		RTS
.endif

; =============== S U B	R O U T	I N E =======================================

.if ZVER = 3
op2_jin:
		LDA	arg1_lo_82
		LDY	#OBJ_PARENT_OFS
		JSR	get_one_byte_from_object_A_byte_Y_address

		CMP	arg2_lo_84
		BEQ	o2t_prs
o2ji_prf:
		JMP	predicate_fails
.else
op2_jin:
		LDA	arg1_lo_82
		LDX	arg1_hi_83
		JSR	set_obj_addr_X_A_to_temp2

		LDY	#OBJ_PARENT_OFS+1
		JSR	get_one_byte_from_temp2_byte_Y_address
		CMP	arg2_lo_84
		BNE	o2ji_prf

		LDY	#OBJ_PARENT_OFS
		JSR	get_one_byte_from_temp2_byte_Y_address
		CMP	arg2_hi_85
		BEQ	o2t_prs

o2ji_prf:
		JMP	predicate_fails
.endif

; =============== S U B	R O U T	I N E =======================================


op2_test:
		LDA	arg2_lo_84
		AND	arg1_lo_82
		CMP	arg2_lo_84
		BNE	o2ji_prf
		LDA	arg2_hi_85
		AND	arg1_hi_83
		CMP	arg2_hi_85
		BNE	o2ji_prf
o2t_prs:
		JMP	predicate_succeeds


; =============== S U B	R O U T	I N E =======================================


op2_or:
		LDA	arg1_hi_83
		ORA	arg2_hi_85
		TAX
		LDA	arg1_lo_82
		ORA	arg2_lo_84
		JMP	store_value_in_X_A


; =============== S U B	R O U T	I N E =======================================


op2_and:
		LDA	arg1_hi_83
		AND	arg2_hi_85
		TAX
		LDA	arg1_lo_82
		AND	arg2_lo_84
		JMP	store_value_in_X_A


; =============== S U B	R O U T	I N E =======================================

;this bitmask looks a bit crazy but since input bits are reversed, the order is 0,4,2,6,1,5,3,7
cb_bitmask:	.BYTE %10000000, %00001000, %00100000, %00000010, %01000000, %00000100, %00010000, %00000001

create_bitmask_from_arg2:
		LDA	#0
		STA	tmp_bitmap_F9
		LDA	arg2_lo_84
		LSR
		ROL	tmp_bitmap_F9
		LSR
		ROL	tmp_bitmap_F9
		LSR
		ROL	tmp_bitmap_F9
		TAY

		LDX	tmp_bitmap_F9
		LDA	cb_bitmask, X
		STA	tmp_bitmap_F9
		;returns byte offs in Y
		;returns mask value in tmp_bitmap_F9
		RTS

; =============== S U B	R O U T	I N E =======================================

.if ZVER = 3
op2_test_attr:
		;in arg1 object
		;in arg2 bit num
		JSR	create_bitmask_from_arg2

		;in Y byte offset in object
		LDA	arg1_lo_82
                JSR	get_one_byte_from_object_A_byte_Y_address
		;in A attribute byte from byte Y (specified by arg2)
		AND	tmp_bitmap_F9
		BNE	o2t_prs	; success
		JMP	predicate_fails
.else
op2_test_attr:
		;in arg1 object
		LDA	arg1_lo_82
		LDX	arg1_hi_83
		JSR	set_obj_addr_X_A_to_temp2

		;in arg2 bit num
		JSR	create_bitmask_from_arg2

		;in Y byte offset in object
		JSR	get_one_byte_from_temp2_byte_Y_address
		;in A attribute byte from byte Y (specified by arg2)
		AND	tmp_bitmap_F9
		BNE	o2t_prs	; success
		JMP	predicate_fails
.endif

; =============== S U B	R O U T	I N E =======================================

.if ZVER = 3
op2_set_attr:
		LDA	arg1_lo_82
		ORA	arg1_hi_83
		BNE	osa1
		RTS

osa1:		JSR	create_bitmask_from_arg2
		;in Y byte offset in object
		TYA
		PHA
		LDA	arg1_lo_82
                JSR	get_one_byte_from_object_A_byte_Y_address
		ORA	tmp_bitmap_F9
		TAX
		PLA
		TAY
		;in Y restored byte offset
		LDA	arg1_lo_82
		JSR	set_one_byte_X_in_object_A_addr_Y
		RTS
.else
op2_set_attr:
		LDA	arg1_lo_82
		ORA	arg1_hi_83
		BNE	osa1
		RTS

osa1:		LDA	arg1_lo_82
		LDX	arg1_hi_83
		JSR	set_obj_addr_X_A_to_temp2

		JSR	create_bitmask_from_arg2

		JSR	get_one_byte_from_temp2_byte_Y_address
		ORA	tmp_bitmap_F9
		JSR	set_one_byte_A_to_temp2_Y_address
		RTS
.endif
; =============== S U B	R O U T	I N E =======================================

.if ZVER = 3
op2_clear_attr:
		JSR	create_bitmask_from_arg2
		TYA
		PHA
		LDA	arg1_lo_82
                JSR	get_one_byte_from_object_A_byte_Y_address
		EOR	#$FF
		ORA	tmp_bitmap_F9
		EOR	#$FF
		TAX
		PLA
		TAY
		LDA	arg1_lo_82
		JSR	set_one_byte_X_in_object_A_addr_Y
		RTS
.else
op2_clear_attr:
		LDA	arg1_lo_82
		LDX	arg1_hi_83
		JSR	set_obj_addr_X_A_to_temp2

		JSR	create_bitmask_from_arg2

		JSR	get_one_byte_from_temp2_byte_Y_address
		EOR	#$FF
		ORA	tmp_bitmap_F9
		EOR	#$FF
		JSR	set_one_byte_A_to_temp2_Y_address
		RTS
.endif


; =============== S U B	R O U T	I N E =======================================


op2_store:
		LDA	arg2_lo_84
		STA	temp_lo_92
		LDA	arg2_hi_85
		STA	temp_hi_93
		LDA	arg1_lo_82
		JMP	set_variable_A_to_temp_value


; =============== S U B	R O U T	I N E =======================================

.if ZVER = 3
op2_insert_obj:
		;removes obj1 from its parent
		JSR	op1_remove_obj

		LDA	arg1_lo_82
		LDY	#OBJ_PARENT_OFS			;set parent of obj1 to obj2
		LDX	arg2_lo_84
		JSR	set_one_byte_X_in_object_A_addr_Y

		LDA	arg2_lo_84
		LDY	#OBJ_CHILD_OFS			;get child of obj2
		JSR	get_one_byte_from_object_A_byte_Y_address
		PHA

		LDA	arg2_lo_84
		LDY	#OBJ_CHILD_OFS			;set child of obj2 to obj1
		LDX	arg1_lo_82
		JSR	set_one_byte_X_in_object_A_addr_Y

		PLA
		BEQ	locret_1399			;end if obj2 had no child

		TAX
		LDA	arg1_lo_82
		LDY	#OBJ_SIBLING_OFS                      ;otherwise set sibling of obj1 to obj2's former child
		JSR	set_one_byte_X_in_object_A_addr_Y

locret_1399:
		RTS

.else
o2io_tmp_lo: .BYTE 0
o2io_tmp_hi: .BYTE 0

op2_insert_obj:
		;remove obj1 from its parent
		JSR	op1_remove_obj

		LDA	arg1_lo_82
		LDX	arg1_hi_83
		JSR	set_obj_addr_X_A_to_temp2

		;set parent of obj1 to obj2
		LDA	arg2_lo_84
		LDY	#OBJ_PARENT_OFS+1
		JSR	set_one_byte_A_to_temp2_Y_address
		LDA	arg2_hi_85
		LDY	#OBJ_PARENT_OFS
		JSR	set_one_byte_A_to_temp2_Y_address

		LDA	arg2_lo_84
		LDX	arg2_hi_85
		JSR	set_obj_addr_X_A_to_temp2

		;get & store child of obj2
		LDY	#OBJ_CHILD_OFS+1
		JSR	get_one_byte_from_temp2_byte_Y_address
		STA	o2io_tmp_lo
		LDY	#OBJ_CHILD_OFS
		JSR	get_one_byte_from_temp2_byte_Y_address
		STA	o2io_tmp_hi

		;set child of obj2 to obj1
		LDA	arg1_lo_82	
		LDY	#OBJ_CHILD_OFS+1
		JSR	set_one_byte_A_to_temp2_Y_address
		LDA	arg1_hi_83
		LDY	#OBJ_CHILD_OFS
		JSR	set_one_byte_A_to_temp2_Y_address

		;end if obj2 had no child
		LDA	o2io_tmp_lo
 		ORA	o2io_tmp_hi
		BEQ	locret_1399

		LDA	arg1_lo_82
		LDX	arg1_hi_83
		JSR	set_obj_addr_X_A_to_temp2

		;otherwise set sibling of obj1 to obj2's former child
		LDA	o2io_tmp_lo
		LDY	#OBJ_SIBLING_OFS+1
		JSR	set_one_byte_A_to_temp2_Y_address
		LDA	o2io_tmp_hi
		LDY	#OBJ_SIBLING_OFS
		JSR	set_one_byte_A_to_temp2_Y_address

locret_1399:
		RTS

.endif

; =============== S U B	R O U T	I N E =======================================


op2_loadw:
		JSR	compute_wtable_ptr_to_zdata
		JSR	get_one_data_zbyte

o2lw_common_st:
		STA	temp_hi_93
		JSR	get_one_data_zbyte
		STA	temp_lo_92
		JMP	store_value_in_temp


; =============== S U B	R O U T	I N E =======================================


op2_loadb:
		JSR	compute_btable_ptr_to_zdata
		BEQ	o2lw_common_st

compute_wtable_ptr_to_zdata:
		ASL	arg2_lo_84
		ROL	arg2_hi_85

compute_btable_ptr_to_zdata:
		LDA	arg2_lo_84
		CLC
		ADC	arg1_lo_82
		STA	zdata_addr_lo_9C
		LDA	arg2_hi_85
		ADC	arg1_hi_83
		STA	zdata_addr_hi_9D
		;##TRACE "*zdata invalidate in loadb/loadw"
		LDA	#0
		STA	zdata_addr_hihi_9E
		STA	zdata_buffer_valid_9F
		RTS


; =============== S U B	R O U T	I N E =======================================


		;arg1 - object
		;arg2 - property num
op2_get_prop:
		JSR	get_arg1_obj_prop_ptr_to_temp2

loop_over_properties:
		JSR	decode_property_number_from_temp2_to_A
		CMP	arg2_lo_84
		BEQ	property_found
		BCC	property_miss
		JSR	move_to_next_property
		JMP	loop_over_properties

property_miss:
		LDA	ptr_objects_lo
		STA	temp2_lo_94
		LDA	ptr_objects_hi
		STA	temp2_hi_95

		LDA	arg2_lo_84
		SEC
		SBC	#1
		ASL
		TAY

		JSR	get_property_byte_Y_offs
		STA	temp_hi_93
		INY
		JSR	get_property_byte_Y_offs
		STA	temp_lo_92
		JMP	store_value_in_temp

property_found:
		JSR	decode_property_length_from_temp2_to_A
		TAX
		CMP	#1
		BEQ	copy_one_byte_of_property
		CMP	#2
		BEQ	copy_two_bytes_of_property

		;asking for property value when property has more than 2 bytes is illegal
		LDA	#7		
		JMP	display_internal_error

copy_one_byte_of_property:
                LDY	#1
		JSR	get_property_byte_Y_offs
		LDX	#0

loc_1400:
		BEQ	return_property_value

copy_two_bytes_of_property:
		LDY	#1
		JSR	get_property_byte_Y_offs
		TAX
		INY
		JSR	get_property_byte_Y_offs

return_property_value:
		STA	temp_lo_92
		STX	temp_hi_93
		JMP	store_value_in_temp


get_property_byte_Y_offs:
		.if EXTMEM
		TXA
		PHA
		TYA
		CLC
		ADC	temp2_lo_94
		STA	gpbyo+1
		LDA	temp2_hi_95
		ADC	#0
		TAX
		LDA	extmem_map_portbs,X
		STA	PORTB
		LDA	extmem_map_pgs,X
		STA	gpbyo+2
		PLA
		TAX
gpbyo:		LDA.a	$0000
		RTS
		.else
		LDA	(temp2_lo_94),Y
		RTS
		.endif

set_property_byte_Y_offs_to_A:
		.if EXTMEM
		PHA
		TXA
		PHA
		TYA
		CLC
		ADC	temp2_lo_94
		STA	spbyota+1
		LDA	temp2_hi_95
		ADC	#0
		TAX
		LDA	extmem_map_portbs,X
		STA	PORTB
		LDA	extmem_map_pgs,X
		STA	spbyota+2
		PLA
		TAX
		PLA
spbyota:	STA.a	$0000
		RTS
		.else
		STA	(temp2_lo_94),Y
		RTS
		.endif


; =============== S U B	R O U T	I N E =======================================


		;arg1 - object
		;arg2 - property
op2_get_prop_addr:
		JSR	get_arg1_obj_prop_ptr_to_temp2

loop_over_properties2:
		JSR	decode_property_number_from_temp2_to_A
		CMP	arg2_lo_84
		BEQ	property_found2
		BCC	property_miss2
		JSR	move_to_next_property
		JMP	loop_over_properties2

property_found2:
		.if ZVER >= 4
		JSR	decode_property_length_from_temp2_to_A
		CMP	#3
		BCC	op2gpa_1

		INC	temp2_lo_94
		BNE	op2gpa_1
		INC	temp2_hi_95
op2gpa_1:

		.endif

		INC	temp2_lo_94
		BNE	op2gpa_2
		INC	temp2_hi_95
op2gpa_2:

		LDA	temp2_lo_94
		STA	temp_lo_92
		LDA	temp2_hi_95
		.if !EXTMEM
		SEC
		SBC	game_base_page_A6	;creates address relative to beginning of data
		.endif
		STA	temp_hi_93	
		JMP	store_value_in_temp

property_miss2:
		JMP	return_zero


; =============== S U B	R O U T	I N E =======================================


op2_get_next_prop:
		;arg1 - object
		;arg2 - property
		JSR	get_arg1_obj_prop_ptr_to_temp2
		LDA	arg2_lo_84
		BEQ	loc_1455

loop_over_properties3:
		JSR	decode_property_number_from_temp2_to_A
		CMP	arg2_lo_84
		BEQ	property_found3
		BCC	property_miss2
		JSR	move_to_next_property
		JMP	loop_over_properties3

property_found3:
		JSR	move_to_next_property

loc_1455:
		JSR	decode_property_number_from_temp2_to_A
		JMP	store_value_in_A


; =============== S U B	R O U T	I N E =======================================


op2_add:
		LDA	arg1_lo_82
		CLC
		ADC	arg2_lo_84
		PHA
		LDA	arg1_hi_83
		ADC	arg2_hi_85
		TAX
		PLA
		JMP	store_value_in_X_A


; =============== S U B	R O U T	I N E =======================================


op2_sub:
		LDA	arg1_lo_82
		SEC
		SBC	arg2_lo_84
		PHA
		LDA	arg1_hi_83
		SBC	arg2_hi_85
		TAX
		PLA
		JMP	store_value_in_X_A


; =============== S U B	R O U T	I N E =======================================


op2_mul:
		JSR	init_math_vars_X_D7_D8

loc_1478:
		ROR	tmp_number_hi_D8
		ROR	tmp_number_lo_D7
		ROR	arg2_hi_85
		ROR	arg2_lo_84
		BCC	loc_148F
		LDA	arg1_lo_82
		CLC
		ADC	tmp_number_lo_D7
		STA	tmp_number_lo_D7
		LDA	arg1_hi_83
		ADC	tmp_number_hi_D8
		STA	tmp_number_hi_D8

loc_148F:
		DEX
		BPL	loc_1478
		LDA	arg2_lo_84
		LDX	arg2_hi_85
		JMP	store_value_in_X_A


; =============== S U B	R O U T	I N E =======================================


op2_div:
		JSR	div_mod_internal
		LDA	tmp_number_lo_D3
		LDX	tmp_number_hi_D4
		JMP	store_value_in_X_A


; =============== S U B	R O U T	I N E =======================================


op2_mod:
		JSR	div_mod_internal
		LDA	tmp_number_lo_D5
		LDX	tmp_number_hi_D6
		JMP	store_value_in_X_A


; =============== S U B	R O U T	I N E =======================================

;arg1 - input number to divide
;arg2 - divisor
;d3-d4 - result
;d5-d6 - modulo
div_mod_internal:
		LDA	arg1_hi_83
		STA	tmp_div_internal_hi_DA
		EOR	arg2_hi_85
		STA	tmp_div_internal_lo_D9
		LDA	arg1_lo_82
		STA	tmp_number_lo_D3
		LDA	arg1_hi_83
		STA	tmp_number_hi_D4
		BPL	loc_14C2
		JSR	negate_number_D3_D4

loc_14C2:
		LDA	arg2_lo_84
		STA	tmp_number_lo_D5
		LDA	arg2_hi_85
		STA	tmp_number_hi_D6
		BPL	loc_14CF
		JSR	negate_number_D5_D6

loc_14CF:
		JSR	div_mod_internal2
		LDA	tmp_div_internal_lo_D9
		BPL	loc_14D9
		JSR	negate_number_D3_D4

loc_14D9:
		LDA	tmp_div_internal_hi_DA
		BPL	locret_14EA

negate_number_D5_D6:
		LDA	#0
		SEC
		SBC	tmp_number_lo_D5
		STA	tmp_number_lo_D5
		LDA	#0
		SBC	tmp_number_hi_D6
		STA	tmp_number_hi_D6

locret_14EA:
		RTS

negate_number_D3_D4:
		LDA	#0
		SEC
		SBC	tmp_number_lo_D3
		STA	tmp_number_lo_D3
		LDA	#0
		SBC	tmp_number_hi_D4
		STA	tmp_number_hi_D4
		RTS

div_mod_internal2:
		LDA	tmp_number_lo_D5
		ORA	tmp_number_hi_D6
		BEQ	division_by_zero_int_error
		JSR	init_math_vars_X_D7_D8

loc_1502:
		ROL	tmp_number_lo_D3
		ROL	tmp_number_hi_D4
		ROL	tmp_number_lo_D7
		ROL	tmp_number_hi_D8
		LDA	tmp_number_lo_D7
		SEC
		SBC	tmp_number_lo_D5
		TAY
		LDA	tmp_number_hi_D8
		SBC	tmp_number_hi_D6
		BCC	loc_151A
		STY	tmp_number_lo_D7
		STA	tmp_number_hi_D8

loc_151A:
		DEX
		BNE	loc_1502
		ROL	tmp_number_lo_D3
		ROL	tmp_number_hi_D4
		LDA	tmp_number_lo_D7
		STA	tmp_number_lo_D5
		LDA	tmp_number_hi_D8
		STA	tmp_number_hi_D6
		RTS

division_by_zero_int_error:
		LDA	#8
		JMP	display_internal_error

; =============== S U B	R O U T	I N E =======================================


.if ZVER >= 5
;VAR:253 1D 5 copy_table first second size
;If second is zero, then size bytes of first are zeroed.
;Otherwise first is copied into second, its length in bytes being the absolute value of size 
;(i.e., size if size is positive, -size if size is negative).
;The tables are allowed to overlap. If size is positive, the interpreter must copy either forwards
; or backwards so as to avoid corrupting first in the copying process. If size is negative, 
;the interpreter must copy forwards even if this corrupts first.

oct_neglen:	.BYTE 0

opvar_copy_table:
		;arg1 - first
		;arg2 - second
		;arg3 - len

		;not mentioned in the docs, but without this some games fail
		LDA	arg3_lo_86
		ORA	arg3_hi_87
		BEQ	fic2		;immediatelly end

		LDA	arg3_hi_87
		BMI	oct_01
		LDA	#0
		BEQ	oct_02
oct_01:		LDA	#0
		SEC
		SBC	arg3_lo_86
		STA	arg3_lo_86
		LDA	#0
		SBC	arg3_hi_87
		STA	arg3_hi_87
		LDA	#1
oct_02:		STA	oct_neglen

		LDA	arg2_lo_84
		ORA	arg2_hi_85
		BNE	oct_nofill

		;this is fill, so arg1 must be writable
oct_03:		LDA	#0
		LDY	#0
		JSR	set_arg1_byte_A_offs_Y
		
		INC	arg1_lo_82
		BNE	fic1
		INC	arg1_hi_83
fic1:
		LDA	arg3_lo_86
		SEC
		SBC	#1
		STA	arg3_lo_86
		LDA	arg3_hi_87
		SBC	#0
		STA	arg3_hi_87
		ORA	arg3_lo_86
		BNE	oct_03
fic2:		RTS

oct_nofill:
		LDA	oct_neglen
		BNE	forward_copy

		LDA	arg1_hi_83
		CMP	arg2_hi_85
		BEQ	oct_nf1
		BCC	backward_copy
		BCS	forward_copy
oct_nf1:	LDA	arg1_lo_82
		CMP	arg2_lo_84
		BCC	backward_copy

forward_copy:

		LDA	arg1_lo_82
		STA	zdata_addr_lo_9C
		LDA	arg1_hi_83
		STA	zdata_addr_hi_9D

		;##TRACE "*zdata invalidate in copy_table forward"
		LDA	#0
		STA	zdata_addr_hihi_9E
		STA	zdata_buffer_valid_9F

		;get_one_data_zbyte increments for us
		;so we don't need to invalidate & increment in forward copy
fc_loop:
		JSR	get_one_data_zbyte
		LDY	#0
		JSR	set_arg2_byte_A_offs_Y
fc1:		INC	arg2_lo_84
		BNE	fc2
		INC	arg2_hi_85
fc2:		LDA	arg3_lo_86
		SEC
		SBC	#1
		STA	arg3_lo_86
		LDA	arg3_hi_87
		SBC	#0
		STA	arg3_hi_87
		ORA	arg3_lo_86
		BNE	fc_loop
		RTS

backward_copy:
		LDA	arg3_lo_86
		SEC
		SBC	#1
		STA	arg3_lo_86
		LDA	arg3_hi_87
		SBC	#0
		STA	arg3_hi_87

		LDA	arg1_lo_82
		CLC
		ADC	arg3_lo_86
		STA	arg1_lo_82
		LDA	arg1_hi_83
		ADC	arg3_hi_87
		STA	arg1_hi_83

		LDA	arg2_lo_84
		CLC
		ADC	arg3_lo_86
		STA	arg2_lo_84
		LDA	arg2_hi_85
		ADC	arg3_hi_87
		STA	arg2_hi_85

		INC	arg3_lo_86
		BNE	bc1
		INC	arg3_hi_87

bc1:
		;##TRACE "*zdata invalidate in copy_table backward"
		LDA	#0
		STA	zdata_addr_hihi_9E
		STA	zdata_buffer_valid_9F
		LDA	arg1_hi_83
		STA	zdata_addr_hi_9D
bc3:
		LDA	arg1_lo_82
		STA	zdata_addr_lo_9C

		JSR	get_one_data_zbyte
		LDY	#0
		JSR	set_arg2_byte_A_offs_Y

		LDA	arg1_lo_82
		SEC
		SBC	#1
		STA	arg1_lo_82
		LDA	arg1_hi_83
		SBC	#0
		STA	arg1_hi_83
		
		LDA	arg2_lo_84
		SEC
		SBC	#1
		STA	arg2_lo_84
		LDA	arg2_hi_85
		SBC	#0
		STA	arg2_hi_85
		
		LDA	arg3_lo_86
		SEC
		SBC	#1
		STA	arg3_lo_86
		LDA	arg3_hi_87
		SBC	#0
		STA	arg3_hi_87
		ORA	arg3_lo_86
		BEQ	bc2

		;if pages are still same, change only lo
		;otherwise change all and invalidate
		LDA	arg1_hi_83
		CMP	zdata_addr_hi_9D
		BEQ	bc3
		BNE	bc1
bc2:
		RTS
.endif

; =============== S U B	R O U T	I N E =======================================


.if ZVER >= 5
;VAR:254 1E 5 print_table zscii-text width height skip
;Print a rectangle of text on screen spreading right and down from the current cursor position, of given width and height, 
;from the table of ZSCII text given. (Height is optional and defaults to 1.) If a skip value is given, then that many characters
; of text are skipped over in between each line and the next.opvar_print_table:

opt_stored_col:	.BYTE $0

opvar_print_table:
		;arg1 - address
		;arg2 - width
		;arg3 - height
		;arg4 - skip

		;maybe temporary fix of hangs in Beyond Zork
		LDA	arg2_lo_84
		ORA	arg2_hi_85
		BEQ	ovpt04

		;default height is 1
		LDA	argument_count_81
		CMP	#2
		BCC     ovpt00
		BEQ	ovpt00
		LDA	arg3_lo_86
		ORA	arg3_hi_87
		BNE	ovpt01
ovpt00:		LDA	#1
		STA	arg3_lo_86
		LDA	#0
		STA	arg3_hi_87
ovpt01:
		LDA	COLCRS
		STA	opt_stored_col

ovpt02:
		;will risk and assume width to be 8bit
		LDY	#0

		LDA	arg1_lo_82
		STA	zdata_addr_lo_9c
		LDA	arg1_hi_83
		STA	zdata_addr_hi_9d
		STY	zdata_addr_hihi_9e
		;##TRACE "*zdata invalidate in print_table"
		STY	zdata_buffer_valid_9f

ovpt03:		TYA
		PHA
		JSR	get_one_data_zbyte
		JSR	print_a_character
		PLA
		TAY
		INY
		CPY	arg2_lo_84
		BNE	ovpt03

		LDA	arg1_lo_82
		CLC
		ADC	arg2_lo_84
		STA	arg1_lo_82
		LDA	arg1_hi_83
		ADC	arg2_hi_85
		STA	arg1_hi_83

		LDA	argument_count_81
		CMP	#4
		BNE	ovpt03b
		LDA	arg1_lo_82
		CLC
		ADC	arg4_lo_88
		STA	arg1_lo_82
		LDA	arg1_hi_83
		ADC	arg4_hi_89
		STA	arg1_hi_83

ovpt03b:
		LDA	arg3_lo_86
		SEC
		SBC	#1
		STA	arg3_lo_86
		LDA	arg3_hi_87
		SBC	#0
		STA	arg3_hi_87
		ORA	arg3_lo_86
		BEQ	ovpt04

		;not sure if this code shouldn't be part of op0_new_line code?
		LDA	active_window
		BNE	ovpt03d
		;lower window (0), just print newline (and possibly, scroll)
		JSR	op0_new_line
		JMP	ovpt03c
		;upper window (1), just increment row
		;todo WTH to do here if the game scrolls past the end of screen?
ovpt03d:	INC	ROWCRS

ovpt03c:	LDA     opt_stored_col
		STA	COLCRS
		JMP	ovpt02
ovpt04:		RTS
.endif



; =============== S U B	R O U T	I N E =======================================


.if ZVER >= 5
;if not implemented, return -1
op_ext_save_undo:
		LDA	#$FF
		STA	temp_lo_92
		STA	temp_hi_93
		JMP	store_value_in_temp
.endif


; =============== S U B	R O U T	I N E =======================================


.if ZVER >= 5
;EXT:2 2 5 log_shift number places -> (result)
;does a logical shift of number by the given number of places, shifting left (i.e. increasing)
; if places is positive, right if negative. In a right shift, the sign is zeroed instead of being shifted on. (See also art_shift.)
;the places operand must be in the range -15 to +15, otherwise behaviour is undefined.

		;arg1 - number
		;arg2 - shift
op_ext_log_shift:
		LDA	arg2_hi_85
		BMI	lsh_right
		ORA	arg2_lo_84
		BEQ	oels_end
lsh_left:
		LDX	arg2_lo_84
lshll1:		ASL	arg1_lo_82
		ROL	arg1_hi_83
		DEX
		BNE	lshll1
		BEQ	oels_end

lsh_right:	;negate shift
		LDA	#0
		SEC
		SBC	arg2_lo_84
		;STA	arg2_lo_84
		TAX

lshrr1:		LSR	arg1_hi_83
		ROR	arg1_lo_82
		DEX
		BNE	lshrr1
oels_end:
		JSR	arg1_to_temp_92_93
		JMP	store_value_in_temp
.endif


; =============== S U B	R O U T	I N E =======================================


.if ZVER >= 5
;EXT:3 3 5/- art_shift number places -> (result)
;Does an arithmetic shift of number by the given number of places, shifting left (i.e. increasing) 
;if places is positive, right if negative. In a right shift, the sign bit is preserved as well as being shifted on down. 
;(The alternative behaviour is log_shift.)
;The places operand must be in the range -15 to +15, otherwise behaviour is undefined.

		;arg1 - number
		;arg2 - shift
op_ext_art_shift:
		LDA	arg2_hi_85
		BMI	sh_right
		ORA	arg2_lo_84
		BEQ	oeas_end

sh_left:
		LDX	arg2_lo_84
shll1:		ASL	arg1_lo_82
		ROL	arg1_hi_83
		DEX
		BNE	shll1
		BEQ	oeas_end

sh_right:	;negate shift
		LDA	#0
		SEC
		SBC	arg2_lo_84
		;STA	arg2_lo_84
		TAX
		LDA	arg1_hi_83
		BMI     shrr2

		;positive number
shrr1:		CLC
		ROR	arg1_hi_83
		ROR	arg1_lo_82
		DEX
		BNE	shrr1
		BEQ	oeas_end

shrr2:		SEC
		ROR	arg1_hi_83
		ROR	arg1_lo_82
		DEX
		BNE	shrr2
oeas_end:
		JSR	arg1_to_temp_92_93
		JMP	store_value_in_temp
.endif



; =============== S U B	R O U T	I N E =======================================


.if ZVER >= 5
;VAR:255 1F 5 check_arg_count argument-number
;Branches if the given argument-number (counting from 1) has been provided by the routine call to the current routine. 
;(This allows routines in Versions 5 and later to distinguish between the calls routine(1) and routine(1,0), 
;which would otherwise be impossible to tell apart.)

opvar_check_arg_count:
		LDA	arg1_lo_82
		CMP	current_fn_argument_count
		BEQ	ocac2
		BCS	ocac1
ocac2:		JMP	predicate_succeeds
ocac1:		JMP	predicate_fails
.endif



; =============== S U B	R O U T	I N E =======================================


.if ZVER >= 5
;EXT:4 4 5 set_font font -> (result)
;If the requested font is available, then it is chosen for the current window, and the store value is the font ID of the
;	previous font (which is always positive). If the font is unavailable, nothing will happen and the store value is 0.
;If the font ID requested is 0, the font is not changed, and the ID of the current font is returned.

.if VIDEO = S80 || VIDEO = S64
window_fonts:	.BYTE 1,1

op_ext_set_font:
		LDX	active_window
		LDA	window_fonts,X
		STA	temp_lo_92
		STA	temp_hi_93

		LDA	arg1_lo_82
		BEQ	oesf_1
		CMP	#1
		BEQ	oesf_f1
		CMP	#2
		BEQ	oesf_f2
		CMP	#3
		BEQ	oesf_f3
		BNE	oesf_f4
		
oesf_f1:
oesf_f3:
		LDX	active_window
		STA	window_fonts,X
		JSR	graphics_set_font
		JMP	store_value_in_temp

oesf_f2:
oesf_f4:
		LDA	#0
		STA	temp_lo_92
		STA	temp_hi_93

oesf_1:		JMP	store_value_in_temp
.else
;todo other drivers NOW don't support fonts
op_ext_set_font:
		LDA	#0
		STA	temp_lo_92
		STA	temp_hi_93
		JMP	store_value_in_temp
.endif

.endif



; =============== S U B	R O U T	I N E =======================================


init_math_vars_X_D7_D8:
		LDX	#$10
		LDA	#0
		STA	tmp_number_lo_D7
		STA	tmp_number_hi_D8
		CLC
		RTS

; =============== S U B	R O U T	I N E =======================================


op2_je:
		DEC	argument_count_81
		BNE	enough_arguments_for_eq

		;at least 2 arguments
		LDA	#9
		JMP	display_internal_error

enough_arguments_for_eq:
		LDA	arg1_lo_82
		LDX	arg1_hi_83
		CMP	arg2_lo_84
		BNE	loc_154E
		CPX	arg2_hi_85
		BEQ	loc_1566

loc_154E:
		DEC	argument_count_81
		BEQ	loc_1569
		CMP	arg3_lo_86
		BNE	loc_155A
		CPX	arg3_hi_87
		BEQ	loc_1566

loc_155A:
		DEC	argument_count_81
		BEQ	loc_1569
		CMP	arg4_lo_88
		BNE	loc_1569
		CPX	arg4_hi_89
		BNE	loc_1569

loc_1566:
		JMP	predicate_succeeds

loc_1569:
		JMP	predicate_fails


; =============== S U B	R O U T	I N E =======================================

.if ZVER >= 5
current_fn_argument_count: .BYTE 0
store_the_result: .BYTE 0

op1_call_1n:
op2_call_2n:
opvar_call_vn:
opvar_call_vn2:
		;n calls DON'T store
		LDA	#0
		BEQ	callv5b
.endif

.if ZVER >= 3
opvar_call:
.endif

.if ZVER >= 4
op1_call_1s:
op2_call_2s:
opvar_call_vs:
opvar_call_vs2:
.endif

		.if ZVER >= 5
		;s calls DO store
		LDA	#1
callv5b:	STA	store_the_result
		.endif

		LDA	arg1_lo_82
		ORA	arg1_hi_83
		BNE	full_call_opcode
		.if ZVER >= 5
		LDA	store_the_result
		BNE	cv5c
		RTS
		cv5c:
		.endif
		LDA	#0
		JMP	store_value_in_A ; call 0 returns 0

full_call_opcode:
		LDX	stack_pointer_function_frame_lo_A4
		LDA	zcode_addr_lo_96
		JSR	push_stack_A_X

		LDX	zcode_addr_hi_97
		LDA	zcode_addr_hihi_98
		JSR	push_stack_A_X

		.if LARGE_STACK
		LDX	stack_pointer_function_frame_hi_A5
		LDA	#0
		JSR	push_stack_A_X
		.endif

		.if ZVER >= 5
		LDX	argument_count_81
		DEX
		STX	current_fn_argument_count
		TXA
		LDX	#0
		JSR	push_stack_A_X
		.endif
		
		LDA	zcode_addr_hi_97
		PHA
		LDA	zcode_addr_hihi_98
		PHA

		LDA	#0
		.if ZVER = 3
		ASL	arg1_lo_82			;this converts packed addr, in Z3 *2
		ROL	arg1_hi_83
		ROL
		STA	zcode_addr_hihi_98

		LDA	arg1_hi_83
		STA	zcode_addr_hi_97
		LDA	arg1_lo_82
		STA	zcode_addr_lo_96
		.else
		;for Z4, Z5, Z7, Z8. Init differs for Z7
		.if ZVER = 7
		LDA	hdr_rout_offs_lo
		CLC
		ADC	arg1_lo_82
		STA	zcode_addr_lo_96
		LDA	hdr_rout_offs_hi
		ADC	arg1_hi_83
		STA	zcode_addr_hi_97
		LDA	hdr_rout_offs_hihi
		ADC	#0
		STA	zcode_addr_hihi_98
		.else
		;in the beginning hihi must be set to 0!
		STA	zcode_addr_hihi_98
		LDA	arg1_hi_83
		STA	zcode_addr_hi_97
		LDA	arg1_lo_82
		STA	zcode_addr_lo_96
		.endif

		;*4 in Z4, Z5, Z7, Z8
		ASL	zcode_addr_lo_96
		ROL	zcode_addr_hi_97
		ROL	zcode_addr_hihi_98

		ASL	zcode_addr_lo_96
		ROL	zcode_addr_hi_97
		ROL	zcode_addr_hihi_98
		.if ZVER = 8				
		;z8 is additional *2, ie. unpacked *8
		ASL	zcode_addr_lo_96
		ROL	zcode_addr_hi_97
		ROL	zcode_addr_hihi_98
		.endif
		.endif

		PLA
		EOR	zcode_addr_hihi_98
		BNE	ovc_inv1
		PLA
		EOR	zcode_addr_hi_97
		BNE	ovc_inv2
		;##TRACE "#NOinvalidate in opvar_callX"		
		BEQ	ovc_inv3
ovc_inv1:	PLA
ovc_inv2:
		;PC was changed, so we must invalidate
		;##TRACE "*invalidate in opvar_callX"
		LDA	#0
		STA	zcode_buffer_valid_99
ovc_inv3:

		;here things get interesting
		;there is a possibility that number of parameters ($81-1) is different
		;to the number of locals
		;
		;in most, ideal cases, I call with N+1 parameters (+1 for call addr), and I have N locals
		;but for indirect calls, I may have more parameters than locals

		JSR	get_one_code_zbyte 		;number of local vars for this routine
		STA	local_vars_cnt2_BF
		BEQ	no_need_for_local_vars_initialization

		ASL
		STA	local_vars_cnt1_BE
		LDY	#0

loop_local_vars_initialization:
		STY	temp2_lo_94

		;read local var and push it to stack
		LDX	local_vars_lo,Y			
		LDA	local_vars_hi,Y
		JSR	push_stack_A_X

		.if ZVER >= 5
		;locals are always initialized to zero
		LDY	temp2_lo_94
		LDA	#0
		STA	local_vars_lo,Y
		STA	local_vars_hi,Y
		.else
		;z3 & z4 initialized from code memory
		JSR	get_one_code_zbyte
		STA	temp2_hi_95
		JSR	get_one_code_zbyte
		LDY	temp2_lo_94
		STA	local_vars_lo,Y
		LDA	temp2_hi_95
		STA	local_vars_hi,Y
		.endif

		INY
		INY
		CPY	local_vars_cnt1_BE
		BNE	loop_local_vars_initialization

no_need_for_local_vars_initialization:
		;1 arg call = 0 args for function call, skip it
		.if ZVER >= 5
		LDY	current_fn_argument_count
		.else
		LDY	argument_count_81
		DEY
		.endif

		CPY	local_vars_cnt2_BF
		BCC	lvcl0
		LDY	local_vars_cnt2_BF
lvcl0:
		TYA
		BEQ	locals_overwriting_end

		ASL
		TAY

lvcl:		LDA	arg2_lo_84-2,Y
		STA	local_vars_lo-2,Y
		LDA	arg2_hi_85-2,Y
		STA	local_vars_hi-2,Y
		DEY
		DEY
		BNE	lvcl

locals_overwriting_end:
		LDX	local_vars_cnt2_BF

		.if ZVER >= 5
		LDA	store_the_result
		.else
		TXA
		.endif

		;store how many words are on stack and if we should clean-up
		JSR	push_stack_A_X	

		LDA	stack_pointer_lo_A2
		STA	stack_pointer_function_frame_lo_A4
		.if LARGE_STACK
		LDA	stack_pointer_hi_A3
		STA	stack_pointer_function_frame_hi_A5
		.endif
		RTS

; =============== S U B	R O U T	I N E =======================================

		;arg1 - array
		;arg2 - idx in array
		;arg3 - value to store
opvar_storew:
		ASL	arg2_lo_84
		ROL	arg2_hi_85

		LDA	arg3_hi_87
		LDY	#0
		JSR	write_table_byte_Y_offs

		INY
		BNE	ovst_common

opvar_storeb:
		LDA	arg3_lo_86
		LDY	#0
ovst_common:
		LDA	arg3_lo_86
		JSR	write_table_byte_Y_offs
		RTS

write_table_byte_Y_offs:
		PHA
		LDA	arg2_lo_84
		CLC
		ADC	arg1_lo_82
		STA	temp2_lo_94
		LDA	arg2_hi_85
		ADC	arg1_hi_83
		.if !EXTMEM
		CLC
		ADC	game_base_page_A6
		.endif
		STA	temp2_hi_95

		.if EXTMEM
		TXA
		PHA
		TYA
		CLC
		ADC	temp2_lo_94
		STA	wtbyo+1
		LDA	temp2_hi_95
		ADC	#0
		TAX

		LDA	extmem_map_portbs,X
		STA	PORTB
		LDA	extmem_map_pgs,X
		STA	wtbyo+2

		PLA
		TAX

		PLA
wtbyo:		STA.a	$0000
		.else
		PLA
		STA	(temp2_lo_94),Y
		.endif
		RTS


; =============== S U B	R O U T	I N E =======================================

		;arg1 - object
		;arg2 - property
		;arg3 - value
opvar_put_prop:
		JSR	get_arg1_obj_prop_ptr_to_temp2
loop_over_properties4:
		JSR	decode_property_number_from_temp2_to_A
		CMP	arg2_lo_84
		BEQ	property_found4
		BCC	property_miss4
		JSR	move_to_next_property
		JMP	loop_over_properties4

property_found4:
		JSR	decode_property_length_from_temp2_to_A
		LDY	#1
		TAX
		CMP	#1
		BEQ	single_byte_prop
		CMP	#2
		BNE	wrong_property_length


		LDA	arg3_hi_87
		JSR	set_property_byte_Y_offs_to_A
		INY

single_byte_prop:
		LDA	arg3_lo_86
		JSR	set_property_byte_Y_offs_to_A
		RTS

property_miss4:
		LDA	#10
		JMP	display_internal_error

wrong_property_length:
		LDA	#11
		JMP	display_internal_error


; =============== S U B	R O U T	I N E =======================================

		;arg1 - zchar
		;in fact 0-1023, but since the upper are undefined...
opvar_print_char:
		LDA	arg1_lo_82
		JMP	print_a_character

; =============== S U B	R O U T	I N E =======================================

                ;arg1 - number
opvar_print_num:
		LDA	arg1_lo_82
		STA	tmp_number_lo_D3
		LDA	arg1_hi_83
		STA	tmp_number_hi_D4

print_signed_int_num_internal_D3_D4:
		LDA	tmp_number_hi_D4
		BPL	input_is_positive
		LDA	#'-'
		JSR	print_a_character
		JSR	negate_number_D3_D4

input_is_positive:
		LDA	#0
		STA	number_of_significant_figures_DB

division_loop:
		LDA	tmp_number_lo_D3
		ORA	tmp_number_hi_D4
		BEQ	exit_division_loop

		;divide by 10
		LDA	#10
		STA	tmp_number_lo_D5
		LDA	#0
		STA	tmp_number_hi_D6
		JSR	div_mod_internal2

		LDA	tmp_number_lo_D5
		PHA
		INC	number_of_significant_figures_DB
		BNE	division_loop

exit_division_loop:
		LDA	number_of_significant_figures_DB
		BNE	intermediate_result_nonzero
		;zero, so print... zero and exit
		LDA	#'0'
		JMP	print_a_character

intermediate_result_nonzero:
		;this displays numbers backwards
		PLA			
		CLC
		ADC	#'0'
		JSR	print_a_character
		DEC	number_of_significant_figures_DB
		BNE	intermediate_result_nonzero
		RTS


; =============== S U B	R O U T	I N E =======================================

opvar_random:
		LDA	arg1_hi_83
		BMI     RESEED
		ORA	arg1_lo_82
		BEQ	RESEED

		LDA	arg1_lo_82
		STA	arg2_lo_84
		LDA	arg1_hi_83
		STA	arg2_hi_85		;stores input number to arg2, to work as a divisor
		JSR	get_random_a_x
		STX	arg1_lo_82
		AND	#$7F
		STA	arg1_hi_83		;two consecutive randoms stored as a 15bit number
		JSR	div_mod_internal	;divided by input
		LDA	tmp_number_lo_D5	;use modulo
		STA	temp_lo_92
		LDA	tmp_number_hi_D6
		STA	temp_hi_93
		JSR	inc_word_temp_92_93	;incremented by 1
		JMP	store_value_in_temp
RESEED:
		LDA	#0			;just return 0, reseed next to impossible when using RANDOM
		STA	temp_lo_92
		STA	temp_hi_93
		JMP	store_value_in_temp

; =============== S U B	R O U T	I N E =======================================

.if ZVER >= 4
		;arg1 - always 1
		;arg2 - time [OPTIONAL]
		;arg3 - routine [OPTIONAL]

		;todo - time/routine not yet implemented
opvar_read_char:
		;when waiting for keys, first flush buffer
		JSR	flush_buffer_to_screen

		LDA	#$FF
		STA	CH
		LDA	#0
		STA	keydel_lo_f6
		STA	keydel_hi_f7

		;leaves Y on the line
		graphics_pmg_cursor_on
orc_3:
		LDX	CH
		INC	keydel_lo_f6
		BNE	orc_4
		INC	keydel_hi_f7
		BNE	orc_4
		LDA	#$80
		STA	keydel_hi_f7

		;Y still valid
		graphics_pmg_cursor_xor

orc_4:
		CPX	#$FF
		BEQ	orc_3
		LDA	#$FF
		STA	CH
		TXA
		BMI	orc_3
		LDA	keycode_to_atascii,X
		CMP	#atari_eol
		BEQ	orc_5
		TAX
		BPL	orc_5
		JSR	bad_beep
		JMP	orc_3

orc_5:
		STA	one_character_E2

		LDY	#$80
		STY	CONSOL
		LDX	#8
orc_6:
		DEX
		BNE	orc_6
		DEY
		BNE	orc_6

orc_7:          ;inside recomputes Y
		graphics_pmg_cursor_off

orc_9:		LDA	one_character_E2
		CMP	#atari_eol
		BNE	orc_8
		LDA	#$0D

orc_8:		STA	temp_lo_92
		LDA	#0
		STA	temp_hi_93
		JMP	store_value_in_temp
.endif

; =============== S U B	R O U T	I N E =======================================

.if ZVER >= 4
opvar_scan_table:
;scan_table x table len form -> (result)
;Is x one of the words in table, which is len words long? 
;If so, return the address where it first occurs and branch. If not, return 0 and don't.

		;arg1 - word to find
		;arg2 - table
		;arg3 - length of table
		;arg4 - bit 7 - on = word, off = byte, lower 7 bits = increment [optional]

		.if ZVER >= 5
		LDA	argument_count_81
		CMP	#4
		BCS	ostp0
		LDA	#2
		STA	arg4_lo_88
		BNE	word_scan0
ostp0:		LDA	arg4_lo_88
		PHP
		AND	#$7F
ostp1:		STA	arg4_lo_88
		PLP
		BPL	byte_scan00
		.else
		LDA	#2
		STA	arg4_lo_88
		.endif

word_scan0:
		LDA	#0
		STA	zdata_addr_hihi_9E
		;##TRACE "*zdata invalidate in word_scan"
		STA	zdata_buffer_valid_9F
		LDA	arg2_hi_85
		STA	zdata_addr_hi_9D

word_scan:
		LDA	arg2_lo_84
		STA	zdata_addr_lo_9C

		JSR	get_one_data_zbyte
		CMP	arg1_hi_83
		BNE	word_not_found1

		JSR	get_one_data_zbyte
		CMP	arg1_lo_82
		BEQ	word_found1

word_not_found1:
		LDA	arg2_lo_84
		CLC
		ADC	arg4_lo_88
		STA	arg2_lo_84
		BCC	word_not_found2
		INC	arg2_hi_85
word_not_found2:

		LDA	arg3_lo_86
		SEC
		SBC	#1
		STA	arg3_lo_86
		LDA	arg3_hi_87
		SBC	#0
		STA	arg3_hi_87
		ORA	arg3_lo_86
		BEQ	word_not_found3

		LDA	arg2_hi_85
		CMP	zdata_addr_hi_9D
		BNE	word_scan0
		BEQ	word_scan	

word_not_found3:
		;did not find
		LDA	#0
		JSR	store_value_in_A
		JMP	predicate_fails
word_found1:
		LDX	arg2_hi_85
		LDA	arg2_lo_84
		JSR	store_value_in_X_A
		JMP	predicate_succeeds




byte_scan00:	;praxis tested this with $100 in first parameter?
		LDA	arg1_hi_83
		BNE	byte_not_found3

byte_scan0:
		LDA	#0
		STA	zdata_addr_hihi_9E
		;##TRACE "*zdata invalidate in byte_scan"
		STA	zdata_buffer_valid_9F
		LDA	arg2_hi_85
		STA	zdata_addr_hi_9D

byte_scan:
		LDA	arg2_lo_84
		STA	zdata_addr_lo_9C

		JSR	get_one_data_zbyte
		CMP	arg1_lo_82
		BEQ	byte_found1

byte_not_found1:
		LDA	arg2_lo_84
		CLC
		ADC	arg4_lo_88
		STA	arg2_lo_84
		BCC	byte_not_found2
		INC	arg2_hi_85
		;##TRACE "*zdata invalidate in byte_scan"
		LDA	#0
		STA	zdata_buffer_valid_9F
byte_not_found2:
		LDA	arg3_lo_86
		SEC
		SBC	#1
		STA	arg3_lo_86
		LDA	arg3_hi_87
		SBC	#0
		STA	arg3_hi_87
		ORA	arg3_lo_86
		BEQ	byte_not_found3

		LDA	arg2_hi_85
		CMP	zdata_addr_hi_9D
		BNE	byte_scan0
		BEQ	byte_scan	

		;did not find
byte_not_found3:
		LDA	#0
		JSR	store_value_in_A
		JMP	predicate_fails
byte_found1:
		LDX	arg2_hi_85
		LDA	arg2_lo_84
		JSR	store_value_in_X_A
		JMP	predicate_succeeds


.endif

; =============== S U B	R O U T	I N E =======================================

.if ZVER >= 4
;VAR:241 11 4 set_text_style style
;Sets the text style to: Roman (if 0), Reverse Video (if 1), Bold (if 2), Italic (4), Fixed Pitch (8). 
;In some interpreters (though this is not required) a combination of styles is possible (such as reverse video and bold).
;In these, changing to Roman should turn off all the other styles currently set.

screen_output_reverse:	.BYTE 0

		;arg1 - style
opvar_set_text_style:
		LDX	#$00
		LDA	arg1_lo_82
		AND	#1
		BEQ	osts_1
		LDX	#$80
osts_1: 	STX	screen_output_reverse
		RTS

.endif

; =============== S U B	R O U T	I N E =======================================

.if ZVER >= 4
;VAR:242 12 4 buffer_mode flag
;If set to 1, text output on the lower window in stream 1 is buffered up so that it can be word-wrapped properly. If set to 0, it isn't.

window0_is_buffered: .BYTE 1

		;arg1 - flag
opvar_buffer_mode:
		LDA	arg1_hi_83
		BNE	ovbm
		LDA	arg1_lo_82
		BEQ	ovbm2
		CMP	#1
		BEQ	ovbm2
ovbm:		LDA	#0
ovbm2:		STA	window0_is_buffered
		BNE	ovbm3
		;here we check if buffering is set to 0, we are in lower window, so we print buffered characters
		;in fact flushing the buffer
		;todo why storing colcrs?
		LDA	active_window
		BNE	ovbm3
		LDA	COLCRS
		PHA
		JSR	flush_buffer_to_screen
		PLA
		STA	COLCRS
ovbm3:		RTS

.endif


; =============== S U B	R O U T	I N E =======================================

.if ZVER >= 4
;VAR:243 13 3 output_stream number table
;If stream is 0, nothing happens. If it is positive, then that stream is selected; 
;if negative, deselected. (Recall that several different streams can be selected at once.)
;When stream 3 is selected, a table must be given into which text can be printed. 
;The first word always holds the number of characters printed, the actual text being stored at bytes table+2 onward.
; It is not the interpreter's responsibility to worry about the length of this table being overrun.

stream_1 = $01
stream_2 = $02
stream_3 = $04

selected_streams:	.BYTE stream_1
stream_3_ptrs:		.BYTE 0
stream_3_ptr_lo:	:16 .BYTE 0
stream_3_ptr_hi:	:16 .BYTE 0

;todo handling stream 4
;todo testing stream 2
		;arg1 - stream
		;arg2 - table [OPTIONAL for stream 3]

opvar_output_stream:
		LDA	arg1_hi_83
		BMI	ovos_1
		;positive, selecting
		LDX	arg1_lo_82
		BEQ	ovos_e
	
		LDA	selected_streams
	
		CPX	#1
		BNE	ovos_2
		ORA	#stream_1
		JMP	ovos_4

ovos_2:		CPX	#2
		BNE	ovos_3
		ORA	#stream_2
		JMP	ovos_4
ovos_3:		CPX	#3
		BNE	ovos_3			;currently not handling stream 4
		ORA	#stream_3
		PHA
		;stream 3 special handling
		INC	stream_3_ptrs
		LDX	stream_3_ptrs
		CPX	#1
		BEQ     ovos_32
		CPX	#16
		BCC	ovos_31
		LDA	#17
	       	JMP	display_internal_error
ovos_31:	LDA	stream_3_ptr_lo-1,X
		STA	stream_3_ptr_lo,X
		LDA	stream_3_ptr_hi-1,X
		STA	stream_3_ptr_hi,X
		DEX
		BNE	ovos_31
ovos_32:	LDA	arg2_lo_84
		STA	stream_3_ptr_lo
		LDA	arg2_hi_85
		STA	stream_3_ptr_hi
		;zeroing the length
		LDY	#0
		LDA	#0
		JSR	stream_3_set_byte
		INY
		JSR	stream_3_set_byte
		PLA
ovos_4:		STA	selected_streams
ovos_e:		RTS

		;negative, deselecting
ovos_1:		LDX	arg1_lo_82
		LDA	selected_streams
		CPX	#$FF
		BNE	ovos_5
		AND	#(stream_1 ^ $FF)
		JMP	ovos_4

ovos_5:		CPX	#$FE
		BNE	ovos_6
		AND	#(stream_2 ^ $FF)
		JMP	ovos_4

ovos_6:		CPX	#$FD
		BNE	ovos_e
		AND	#(stream_3 ^ $FF)
		PHA
		;stream 3 special handling
		LDX	stream_3_ptrs
		BEQ	ovos_7
		LDX	#0
ovos_8:		LDA	stream_3_ptr_lo+1,X
		STA	stream_3_ptr_lo,X
		LDA	stream_3_ptr_hi+1,X
		STA	stream_3_ptr_hi,X
		INX
		CPX	stream_3_ptrs
		BNE	ovos_8
		DEC	stream_3_ptrs

		;if still some stream_3 selected, don't deselect
		LDA	stream_3_ptrs
		BEQ	ovos_7
		PLA
		AND	#stream_3
		PHA	
ovos_7:		PLA
		STA	selected_streams
		RTS

str_3_tmp:	.WORD 0

stream_3_insert_byte:
		PHA
		TXA
		PHA
		TYA
		PHA
		LDY	#1
		JSR	stream_3_get_byte
		CLC
		ADC	stream_3_ptr_lo
		STA	str_3_tmp
		PHP
		LDY	#0
		JSR	stream_3_get_byte
		PLP
		ADC	stream_3_ptr_hi
		STA	str_3_tmp+1
	
		LDA	str_3_tmp
		CLC
		ADC	#2
		STA	str_3_tmp
		LDA	str_3_tmp+1
		ADC	#0
		STA	str_3_tmp+1

		;now str_3_tmp points to where the char should be stored
		LDY	#1
		JSR	stream_3_get_byte
		CLC
		ADC	#1
		PHP
		JSR	stream_3_set_byte
		PLP
		BCC	s3ib_1
		LDY	#0
		JSR	stream_3_get_byte
		CLC
		ADC	#1
		JSR	stream_3_set_byte
		
s3ib_1:         ;now ptr is incremented
		PLA
		TAY
		PLA
		JSR	stream_3_tmp_set_byte
		PLA
		RTS

stream_3_tmp_set_byte:
		;A - value
		PHA
		TXA
		PHA
		TYA
		PHA

		LDA	str_3_tmp
		STA	s3tsb+1

		LDA	str_3_tmp+1
		.if EXTMEM
		TAX

		LDA	extmem_map_portbs,X
		STA	PORTB
		LDA	extmem_map_pgs,X
		.endif
		STA	s3tsb+2
		PLA
		TAY
		PLA
		TAX
		PLA
s3tsb:		STA.a	$0000
		RTS

stream_3_set_byte:
		;Y - offset
		;A - value
		.if EXTMEM
		PHA
		TXA
		PHA
		TYA
		CLC
		ADC	stream_3_ptr_lo
		STA	s3sb+1

		LDA	stream_3_ptr_hi
		ADC	#0
		TAX

		LDA	extmem_map_portbs,X
		STA	PORTB
		LDA	extmem_map_pgs,X
		STA	s3sb+2
		PLA
		TAX
		PLA
s3sb:		STA.a	$0000
		RTS
		.else
		PHA
		LDA	stream_3_ptr_lo
		STA	s3sb2+1
		LDA	stream_3_ptr_hi
		STA	s3sb2+2
		PLA
s3sb2:		STA.a	$0000,Y
		RTS
		.endif

stream_3_get_byte:
		;Y - offset
		.if EXTMEM
		TXA
		PHA
		TYA
		CLC
		ADC	stream_3_ptr_lo
		STA	s3gb+1

		LDA	stream_3_ptr_hi
		ADC	#0
		TAX

		LDA	extmem_map_portbs,X
		STA	PORTB
		LDA	extmem_map_pgs,X
		STA	s3gb+2
		PLA
		TAX
s3gb:		LDA.a	$0000
		RTS
		.else
		LDA	stream_3_ptr_lo
		STA	s3sb2+1
		LDA	stream_3_ptr_hi
		STA	s3sb2+2
s3sg2:		LDA.a	$0000,Y
		RTS
		.endif

	
.endif

; =============== S U B	R O U T	I N E =======================================

.if ZVER >= 4
;VAR:237 D 4 erase_window window
;Erases window with given number (to background colour); 
;or if -1 it unsplits the screen and clears the lot; or if -2 it clears the screen without unsplitting it. 
;In cases -1 and -2, the cursor may move (see S 8 for precise details).

		;arg1 - window
opvar_erase_window:
		LDA	arg1_hi_83
		CMP	#$FF
		BNE	oew_1
		LDA	arg1_lo_82
		CMP	#$FE
		BNE	oew_2
		CMP	#$FF
		BNE	oew_l
		JSR	unsplit_window
oew_2:
		JMP	graphics_cls

oew_1:		;here hi is loaded
		CMP	#0
		BNE	oew_l
		LDA	arg1_lo_82
		CMP	#1
		BNE	oew_3
		LDX	#0
		LDY	where_is_window_split_E4
		CPY	#0
		BNE	oew_4
		LDY	#SCREEN_LINES_TOTAL
		JMP	oew_4

oew_3:		CMP	#0
		BNE	oew_l
		;lower, window 0

		.if ZVER >= 5
		LDA	#0
		STA	ROWCRS
		.else
		LDA	#SCREEN_LINES_TOTAL-1
		STA	ROWCRS
		.endif
		LDA	#0
		STA	COLCRS

		LDX	where_is_window_split_E4
		LDY	#SCREEN_LINES_TOTAL
oew_4:	
		JSR	graphics_cls_partial
oew_l:
		RTS
.endif

; =============== S U B	R O U T	I N E =======================================

.if ZVER >= 4
;VAR:239 F 4 set_cursor line column
ROWCRS0:	.BYTE 0
COLCRS0:	.BYTE 0

		;arg1 - line (1 based)
		;arg2 - col (1 based)
opvar_set_cursor:
		DEC	arg1_lo_82

		LDX	active_window
		BEQ	ovsc_2		;no cursor setting for lower window

ovsc_3:
		LDA	arg1_lo_82
		CMP	#SCREEN_LINES_TOTAL-1
		BCS	ovsc_1

		STA	ROWCRS
ovsc_1:
		DEC	arg2_lo_84
		LDA	arg2_lo_84
		CMP	#SCREEN_WIDTH_CHARS
		BCS	ovsc_2
		STA	COLCRS
ovsc_2:
		RTS

opvar_get_cursor:
		LDY	#00
		TYA
		JSR	set_arg1_byte_A_offs_Y
		INY
		LDA	ROWCRS
		CLC
		ADC	#1
		JSR	set_arg1_byte_A_offs_Y
		INY
		LDA	#0
		JSR	set_arg1_byte_A_offs_Y
		INY
		LDA	COLCRS
		CLC
		ADC	#1
		JSR	set_arg1_byte_A_offs_Y
		RTS
.endif

; =============== S U B	R O U T	I N E =======================================


opvar_push:
		LDX	arg1_lo_82
		LDA	arg1_hi_83
		JMP	push_stack_A_X


; =============== S U B	R O U T	I N E =======================================


opvar_pull:
		JSR	op0_pop
		LDA	arg1_lo_82
		JMP	set_variable_A_to_temp_value


; =============== S U B	R O U T	I N E =======================================


set_tokenized_buff_byte_A_offs_Y:
		.if EXTMEM
		PHA
		TXA
		PHA
		TYA
		CLC
		ADC	tmp_tokenized_buff_lo_C4
		STA	stbbaoy+1

		LDA	tmp_tokenized_buff_hi_C5
		ADC	#0
		TAX

		LDA	extmem_map_portbs,X
		STA	PORTB
		LDA	extmem_map_pgs,X
		STA	stbbaoy+2
		PLA
		TAX
		PLA
stbbaoy:	STA.a	$0000
		RTS
		.else
		STA	(tmp_tokenized_buff_lo_C4),Y
		RTS
		.endif

get_tokenized_buff_byte_offs_Y:
		.if EXTMEM
		TXA
		PHA
		TYA
		CLC
		ADC	tmp_tokenized_buff_lo_C4
		STA	gtbbaoy+1

		LDA	tmp_tokenized_buff_hi_C5
		ADC	#0
		TAX

		LDA	extmem_map_portbs,X
		STA	PORTB
		LDA	extmem_map_pgs,X
		STA	gtbbaoy+2
		PLA
		TAX
gtbbaoy:	LDA.a	$0000
		RTS
		.else
		LDA	(tmp_tokenized_buff_lo_C4),Y
		RTS
		.endif

set_arg2_byte_A_offs_Y:
		.if EXTMEM
		PHA
		TXA
		PHA
		TYA
		CLC
		ADC	arg2_lo_84
		STA	sa2baoy+1

		LDA	arg2_hi_85
		ADC	#0
		TAX

		LDA	extmem_map_portbs,X
		STA	PORTB
		LDA	extmem_map_pgs,X
		STA	sa2baoy+2
		PLA
		TAX
		PLA
sa2baoy:	STA.a	$0000
		RTS
		.else
		STA	(arg2_lo_84),Y
		RTS
		.endif


cmp_arg2_byte_A_offs_Y:
		.if EXTMEM
		PHA
		TXA
		PHA
		TYA
		CLC
		ADC	arg2_lo_84
		STA	ca2baoy+1

		LDA	arg2_hi_85
		ADC	#0
		TAX

		LDA	extmem_map_portbs,X
		STA	PORTB
		LDA	extmem_map_pgs,X
		STA	ca2baoy+2
		PLA
		TAX
		PLA
ca2baoy:	CMP.a	$0000
		RTS
		.else
		CMP	(arg2_lo_84),Y
		RTS
		.endif


get_arg2_byte_offs_Y:
		.if EXTMEM
		TXA
		PHA
		TYA
		CLC
		ADC	arg2_lo_84
		STA	ga2boy+1
	
		LDA	arg2_hi_85
		ADC	#0
		TAX

		LDA	extmem_map_portbs,X
		STA	PORTB
		LDA	extmem_map_pgs,X
		STA	ga2boy+2
		PLA
		TAX
ga2boy:		LDA.a	$0000	
		RTS
		.else
		LDA	(arg2_lo_84),Y
		RTS
		.endif

keyword_buffer:	:[DICT_WORD_LEN] .BYTE 0
MAX_TOKENS_PARSED = 59

.if ZVER >= 5 && EXTMEM
opvar_aread:
		;text, parse, time, routine -> (result)
		;arg1 - text
		;arg2 - parse
		;arg3 - time
		;arg4 - routine

		;todo time/routine
		;implicit EXTMEM

aread_01:
		JSR	get_keyboard_string_outlen_in_A
		STA	chars_in_buffer_C2

		LDA	arg2_lo_84
		ORA	arg2_hi_85
		BNE	aread_02

		;if 0 in argument parse, does not parse and exits
		;todo - difference between time-ended input (0) and manual-ended input ($0d)
aread_end:	LDA	#ascii_cr
		STA	temp_lo_92
		LDA	#0
		STA	temp_hi_93
		JMP	store_value_in_temp

aread_02:
		LDA	main_dict_lo
		STA	ptr_dict_lo
		LDA	main_dict_hi
		STA	ptr_dict_hi
		LDA	#0
		STA	tokenise_skip

		JSR	tokenizer_int
		JMP	aread_end

.else


opvar_sread:
		.if ZVER = 3
		JSR	op0_show_status
		.endif

		.if !EXTMEM
		LDA	arg1_hi_83
		CLC
		ADC	game_base_page_A6
		STA	arg1_hi_83

		LDA	arg2_hi_85
		CLC
		ADC	game_base_page_A6
		STA	arg2_hi_85
		.endif

		JSR	get_keyboard_string_outlen_in_A
		STA	chars_in_buffer_C2

		JSR	tokenizer_int

		RTS
.endif


.if ZVER >= 5
;VAR:251 1B 5 tokenise text parse dictionary flag

main_dict_lo:		.BYTE 0
main_dict_hi:		.BYTE 0
tokenise_skip:		.BYTE 0

opvar_tokenise:
		;arg1 - text
		;arg2 - parse
		;arg3 - dict [OPTIONAL]
		;arg4 - flag [OPTIONAL]

		LDA	argument_count_81
		CMP	#3	
		BCS	ot01
		LDX	main_dict_lo
		LDY	main_dict_hi
		BNE	ot02
ot01:		LDX	arg3_lo_86
		LDY	arg3_hi_87
ot02:		STX	ptr_dict_lo
		STY	ptr_dict_hi

		LDA	argument_count_81
		CMP	#4
		BCC	ot03

		LDA	arg4_lo_88
		ORA	arg4_hi_89
		BEQ	ot03

		LDA	#1
		BNE	ot04

ot03:		LDA	#0
ot04:		STA	tokenise_skip

                LDY	#1
		JSR	get_arg1_byte_offs_Y
		STA	chars_in_buffer_C2
                ;fall through to tokenizer_int
.endif
		
tokenizer_int:
		LDA	#0
		STA	curr_kwd_buffer_idx_C3
		LDY	#1
		JSR	set_arg2_byte_A_offs_Y
		.if ZVER >= 5
		LDY	#2
		.else
		LDY	#1
		.endif
		STY	curr_char_ptr_C0
		LDY	#2
		STY	ptr_into_tokenized_buffer_C1

main_parse_loop:
		LDY	#0
		JSR	get_arg2_byte_offs_Y		;max length of parsed input
		BEQ	parse_buffer_length_zero
		CMP	#MAX_TOKENS_PARSED+1
		BCC	parse_buffer_length_okay

parse_buffer_length_zero:
		LDA	#MAX_TOKENS_PARSED
		JSR	set_arg2_byte_A_offs_Y

parse_buffer_length_okay:
		INY
		JSR	cmp_arg2_byte_A_offs_Y
		BCC	tokenizer_end
		LDA	chars_in_buffer_C2
		ORA	curr_kwd_buffer_idx_C3
		BNE	we_have_some_chars

tokenizer_end:
		RTS

we_have_some_chars:
		LDA	curr_kwd_buffer_idx_C3
		CMP	#DICT_WORD_LEN
		BCC	not_yet_enough_chars
		JSR	skip_rest_of_word_over_needed_chars

not_yet_enough_chars:
		LDA	curr_kwd_buffer_idx_C3
		BNE	not_a_whitespace

		LDX	#DICT_WORD_LEN - 1
clear_keyword_buffer:
		STA	keyword_buffer,X
		DEX
		BPL	clear_keyword_buffer

		JSR	init_where_to_write
		LDA	curr_char_ptr_C0
		LDY	#3
		JSR	set_tokenized_buff_byte_a_offs_Y	;writes where this token starts in ascii form after the token
		TAY
		JSR	get_arg1_byte_offs_Y			;input buffer
		JSR	is_word_separator
		BCS	loc_175C
		JSR	is_punct_or_whitespace
		BCC	not_a_whitespace
		INC	curr_char_ptr_C0
		DEC	chars_in_buffer_C2
		JMP	main_parse_loop

not_a_whitespace:
		LDA	chars_in_buffer_C2
		BEQ	whole_word_scanned_in_keyword_buffer
		LDY	curr_char_ptr_C0
		JSR	get_arg1_byte_offs_Y
		JSR	again_check_for_sep_whit
		BCS	whole_word_scanned_in_keyword_buffer
		LDX	curr_kwd_buffer_idx_C3
		STA	keyword_buffer,X
		DEC	chars_in_buffer_C2
		INC	curr_kwd_buffer_idx_C3
		INC	curr_char_ptr_C0
		JMP	main_parse_loop

loc_175C:
		STA	keyword_buffer
		DEC	chars_in_buffer_C2
		INC	curr_kwd_buffer_idx_C3
		INC	curr_char_ptr_C0

whole_word_scanned_in_keyword_buffer:
		LDA	curr_kwd_buffer_idx_C3
		BEQ	main_parse_loop
		JSR	init_where_to_write
		LDA	curr_kwd_buffer_idx_C3
		LDY	#2
		JSR	set_tokenized_buff_byte_a_offs_Y	;writes length of ascii form of token

		.if ZVER >= 5
		LDA	tokenise_skip
		BEQ	loc_sk					;do all tokens
		LDY	#0
		JSR	get_tokenized_buff_byte_offs_Y
		STA	temp_hi_93
		INY
		JSR	get_tokenized_buff_byte_offs_Y
		ORA	temp_hi_93
		BNE     loc_sk2					;jump over if filled
		.endif

loc_sk:		JSR	convert_kwd_buffer_to_zdata
		JSR	find_word_in_vocab
		LDY	#1
		JSR	get_arg2_byte_offs_Y
		CLC
		ADC	#1
		JSR	set_arg2_byte_a_offs_Y			;increment found tokens counter
		JSR	init_where_to_write
		LDY	#0
		STY	curr_kwd_buffer_idx_C3
		LDA	temp_hi_93
		JSR	set_tokenized_buff_byte_a_offs_Y
		INY
		LDA	temp_lo_92
							; writes token address itself
							; in memory it's always 4 bytes:
							; XXXXLLOO - token, length of ascii form, offset of ascii form
		JSR	set_tokenized_buff_byte_a_offs_Y
loc_sk2:	LDA	ptr_into_tokenized_buffer_C1
		CLC
		ADC	#4
		STA	ptr_into_tokenized_buffer_C1
		JMP	main_parse_loop

; =============== S U B	R O U T	I N E =======================================


init_where_to_write:
		LDA	arg2_lo_84
		CLC
		ADC	ptr_into_tokenized_buffer_C1
		STA	tmp_tokenized_buff_lo_C4
		LDA	arg2_hi_85
		ADC	#0
		STA	tmp_tokenized_buff_hi_C5
		RTS


; =============== S U B	R O U T	I N E =======================================


skip_rest_of_word_over_needed_chars:
		LDA	chars_in_buffer_C2
		BEQ	no_more_chars_left
		LDY	curr_char_ptr_C0
		JSR	get_arg1_byte_offs_Y
		JSR	again_check_for_sep_whit
		BCS	no_more_chars_left
		DEC	chars_in_buffer_C2
		INC	curr_kwd_buffer_idx_C3
		INC	curr_char_ptr_C0
		BNE	skip_rest_of_word_over_needed_chars
no_more_chars_left:
		RTS


; =============== S U B	R O U T	I N E =======================================

again_check_for_sep_whit:
		JSR	is_word_separator
		BCS	first_char_found

is_punct_or_whitespace:
		LDX	#[punct_white_tbl_len - 1 ]

loop_find_whitespace:
		CMP	punct_white_tbl,X
		BEQ	first_char_found
		DEX
		BPL	loop_find_whitespace
		CLC
		RTS

punct_white_tbl:
		.BYTE '!'
		.BYTE '?'
		.BYTE ','
		.BYTE '.'
		.BYTE ascii_cr
		.BYTE ' '

punct_white_tbl_len = * - punct_white_tbl


; =============== S U B	R O U T	I N E =======================================


is_word_separator:
		TAX
		LDY	#0
		JSR	get_dict_byte_offs_Y
		TAY
		TXA

loop_search_first_char:
		JSR	cmp_dict_byte_offs_Y
		BEQ	first_char_found
		DEY
		BNE	loop_search_first_char
		CLC
		RTS

first_char_found:
		SEC
		RTS


; =============== S U B	R O U T	I N E =======================================


get_temp_lo_byte_offs_Y:
.if EXTMEM
		TXA
		PHA
		TYA
		CLC
		ADC	temp_lo_92
		STA	gtloboy+1

		LDA	temp_hi_93
		ADC	#0
		TAX
		LDA	extmem_map_portbs,X
		STA	PORTB
		LDA	extmem_map_pgs,X
		STA	gtloboy+2

		PLA
		TAX
gtloboy:	LDA.a	$0000
		RTS
.else
		LDA	(temp_lo_92),Y
		RTS
.endif

cmp_dict_byte_offs_Y:
.if EXTMEM
		PHA
		TXA
		PHA
		TYA
		CLC
		ADC	ptr_dict_lo
		STA	cdboy+1

		LDA	ptr_dict_hi
		ADC	#0
		TAX
		LDA	extmem_map_portbs,X
		STA	PORTB
		LDA	extmem_map_pgs,X
		STA	cdboy+2

		PLA
		TAX
		PLA
cdboy:		CMP.a	$0000
		RTS
.else
		CMP	(ptr_dict_lo),Y
		RTS
.endif



get_dict_byte_offs_Y:
.if EXTMEM
		TXA
		PHA
		TYA
		CLC
		ADC	ptr_dict_lo
		STA	gdboy+1

		LDA	ptr_dict_hi
		ADC	#0
		TAX
		LDA	extmem_map_portbs,X
		STA	PORTB
		LDA	extmem_map_pgs,X
		STA	gdboy+2

		PLA
		TAX
gdboy:		LDA.a	$0000
		RTS
.else
		LDA	(ptr_dict_lo),Y
		RTS
.endif


find_word_in_vocab:
		LDY	#0
		STY	temp_hi_93
		JSR	get_dict_byte_offs_Y
		STA	temp_lo_92

		INC	temp_lo_92
		BNE	fwiv_01
		INC	temp_hi_93
fwiv_01:
		LDA	temp_lo_92	
		CLC
		ADC	ptr_dict_lo
		STA	temp_lo_92

		LDA	temp_hi_93
		ADC	ptr_dict_hi
		STA	temp_hi_93

		;so we skipped the word separators table


		JSR	get_temp_lo_byte_offs_Y
		STA	tmp_vocab_entry_len_C8
		JSR	inc_word_temp_92_93

		JSR	get_temp_lo_byte_offs_Y
		STA	temp_vocab_count_hi_C7
		JSR	inc_word_temp_92_93

		JSR	get_temp_lo_byte_offs_Y
		STA	temp_vocab_count_lo_C6
		JSR	inc_word_temp_92_93

		.if ZVER >= 5
		LDA	temp_vocab_count_hi_C7
		BPL	lover1
		;count is negative, we ignore it
		LDA	#0
		SEC
		SBC	temp_vocab_count_lo_C6
		STA	temp_vocab_count_lo_C6
		LDA	#0
		SBC	temp_vocab_count_hi_C7
		STA	temp_vocab_count_hi_C7
lover1:
		;in acc we should have hi part
		ORA	temp_vocab_count_lo_C6
		BEQ     vocab_not_a_match		;dictionary of 0 count
		.endif

loop_next_vocab_entry:
		LDY	#0
		JSR	get_temp_lo_byte_offs_Y
		CMP	converted_keyword_buffer_B4
		BNE	vocab_not_a_match ; move to next vocab entry
		INY
		JSR	get_temp_lo_byte_offs_Y
		CMP	converted_keyword_buffer_B4+1
		BNE	vocab_not_a_match ; move to next vocab entry
		INY
		JSR	get_temp_lo_byte_offs_Y
		CMP	converted_keyword_buffer_B4+2
		BNE	vocab_not_a_match ; move to next vocab entry
		INY
		JSR	get_temp_lo_byte_offs_Y
		CMP	converted_keyword_buffer_B4+3
		.if ZVER >= 4
		BNE	vocab_not_a_match ; move to next vocab entry
		INY
		JSR	get_temp_lo_byte_offs_Y
		CMP	converted_keyword_buffer_B4+4
		BNE	vocab_not_a_match ; move to next vocab entry
		INY
		JSR	get_temp_lo_byte_offs_Y
		CMP	converted_keyword_buffer_B4+5
		.endif
		BEQ	vocab_match

vocab_not_a_match:
		LDA	tmp_vocab_entry_len_C8	;move to next vocab entry
		CLC
		ADC	temp_lo_92
		STA	temp_lo_92
		BCC	loc_1835
		INC	temp_hi_93
loc_1835:

		LDA	temp_vocab_count_lo_C6	;decrement number of entries to	search
		SEC
		SBC	#1
		STA	temp_vocab_count_lo_C6
		BCS	loc_1840
		DEC	temp_vocab_count_hi_C7
loc_1840:

		ORA	temp_vocab_count_hi_C7
		BNE	loop_next_vocab_entry
vocab_final_nomatch:
		;implicit 0 in A
		STA	temp_lo_92
		STA	temp_hi_93
		RTS

vocab_match:
		.if !EXTMEM
		LDA	temp_hi_93
		SEC
		SBC	game_base_page_A6
		STA	temp_hi_93
		.endif
		RTS



; =============== S U B	R O U T	I N E =======================================

get_one_code_zbyte:
		;##TRACE "get_one_code_zbyte %06X" db($98)+dw($96)
		LDY	zcode_addr_hihi_98
		BNE	get_one_code_zbyte2
		LDA	zcode_addr_hi_97
		CMP	resident_mem_in_pages_A7
		BCS	get_one_code_zbyte2
		.if EXTMEM
		TAX
		LDA	extmem_map_portbs,X
		STA	PORTB
		LDA	extmem_map_pgs,X
		.else
		;implicit CLC (BCS up there)
		ADC	game_base_page_A6
		.endif
		STA	gocz_ptch1+2
		LDY	zcode_addr_lo_96
gocz_ptch1:	LDA.a	$0000,Y
		;##TRACE "get_one_code_zbyte %06X %02X" db($98)+dw($96) (a)

		INC	zcode_addr_lo_96
		BNE	loc_1885b
		INC	zcode_addr_hi_97
		BNE	loc_1885b
		INC	zcode_addr_hihi_98
loc_1885b:
		TAY
		RTS

get_one_code_zbyte2:
		LDA	zcode_buffer_valid_99	;nonzero = current sector is valid
		BNE	gocz_actual_byte_read

		;Y = hihi
		LDA	zcode_addr_hi_97
		;cross invalidation is important, because we have TWO different users, but only ONE cache
		;so any pointer of 'code' may point to sector needed by 'data'
		LDX	#0
		STX	zdata_buffer_valid_9F

		JSR	get_sector_Y_A_page_in_memory
		STA	zcode_buffer_hi_9B
		LDX	#$FF
		STX	zcode_buffer_valid_99

gocz_actual_byte_read:
		LDY	zcode_addr_lo_96
		LDA	(zcode_buffer_lo_9A),Y

		INC	zcode_addr_lo_96
		BNE	loc_1885
		;##TRACE "*invalidate in get_one_code_zbyte increment"
		LDY	#0
		STY	zcode_buffer_valid_99
		INC	zcode_addr_hi_97
		BNE	loc_1885
		INC	zcode_addr_hihi_98
loc_1885:

		TAY
		RTS

; =============== S U B	R O U T	I N E =======================================

get_one_data_zbyte:
		LDY	zdata_addr_hihi_9E
		BNE	get_one_data_zbyte2
		LDA	zdata_addr_hi_9D
get_one_byte_page_compare_instruction:
		CMP	resident_mem_in_pages_A7
		;this instruction is sometimes patched, register is changed to any 0 zpage register
		;this means it always reads and never touches memory
		;used for checksumming story in verify
		BCS	get_one_data_zbyte2
		.if EXTMEM
		TAX
		LDA	extmem_map_portbs,X
		STA	PORTB
		LDA	extmem_map_pgs,X
		.else
		;implicit CLC (BCS up there)
		ADC	game_base_page_A6
		.endif
		STA	godz_ptch1+2
		LDY	zdata_addr_lo_9C
godz_ptch1:	LDA.a	$0000,Y

		INC	zdata_addr_lo_9C
		BNE	loc_1885c
		INC	zdata_addr_hi_9D
		BNE	loc_1885c
		INC	zdata_addr_hihi_9E
loc_1885c:
		TAY
		RTS

get_one_data_zbyte2:
		LDA	zdata_buffer_valid_9F	;nonzero = current sector is valid
		BNE	godz_actual_byte_read

		;Y = hihi
		LDA	zdata_addr_hi_9D
		;cross invalidation is important, because we have TWO different users, but only ONE cache
		;so any pointer of 'code' may point to sector needed by 'data'
		LDX	#0
		STX	zcode_buffer_valid_99

		JSR	get_sector_Y_A_page_in_memory
		STA	zdata_buffer_hi_A1
		LDX	#$FF
		STX	zdata_buffer_valid_9F

godz_actual_byte_read:
		LDY	zdata_addr_lo_9C
		LDA	(zdata_buffer_lo_A0),Y

		INC	zdata_addr_lo_9C
		BNE	loc_1885d
		LDY	#0
		;##TRACE "*invalidate in get_one_code_zbyte increment"
		STY	zdata_buffer_valid_9F

		INC	zdata_addr_hi_9D
		BNE	loc_1885d
		INC	zdata_addr_hihi_9E
loc_1885d:

		TAY
		RTS


; =============== S U B	R O U T	I N E =======================================

get_sector_Y_A_page_in_memory:
		STY	get_sector_tmp_hi_AB
		STA	get_sector_tmp_lo_AA

		;##TRACE "Sector to find: %04X" dw(get_sector_tmp_lo_AA)

		;looking for sector in cache
		LDX	#0
sec_find_loop:
		CMP	cached_sector_num_lo,X
		BNE	sec_find_next
		TYA
		CMP	cached_sector_num_hi,X
		BNE	sfln
		STX	current_cache_idx_E5
		;##TRACE "  - sector found: %04X at %02X" dw(get_sector_tmp_lo_AA) db(current_cache_idx_E5)

		BEQ	sec_find_match
sfln:
		LDA	get_sector_tmp_lo_AA

sec_find_next:
		INX
		CPX	cache_size_in_pages_A9
		BCC	sec_find_loop

sec_find_miss:
		;##TRACE "  - sector not found: %04X" dw(get_sector_tmp_lo_AA)

		;we haven't found it in cache
		JSR	find_available_cache_slot	;find slot
		LDX	available_cache_slot_idx_E8
		STX	current_cache_idx_E5
		
		LDA	get_sector_tmp_lo_AA		;save sector number in slot
		STA	cached_sector_num_lo,X
		STA	sector_pointer_lo_EB
		LDA	get_sector_tmp_hi_AB
		AND	#MAX_STORY_SIZE_HIHI
		STA	cached_sector_num_hi,X
		STA	sector_pointer_hi_EC
		TXA
		CLC
		.if EXTMEM
		ADC	#$80
		.else
		ADC	after_dynamic_memory_page_A8 ; where to	read-in	cached sector
		.endif
		STA	read_buffer_hi_EE
		JSR	dsk_read_one_game_sector	;and read sector to memory
		BCS	read_error_internal

sec_find_match:
		;currently we have cache sector in our hands
		LDY	current_cache_idx_E5
		LDA	cache_age_table,Y
		CMP	current_cache_age_E7
		BEQ	loc_192B
		INC	current_cache_age_E7 	;here the highest age may overflow $FF
		BNE	loc_1924              	;did not overflow
		JSR	find_lowest_cache_age	;did overflow

		LDX	#0			;correct the ages
loc_190D:
		LDA	cache_age_table,X
		BEQ	loc_1918
		SEC
		SBC	cache_age_correction_E6
		STA	cache_age_table,X
loc_1918:	INX
		CPX	cache_size_in_pages_A9
		BCC	loc_190D


		LDA	#0
		SEC
		SBC	cache_age_correction_E6
		STA	current_cache_age_E7	;and the global age


loc_1924:	LDA	current_cache_age_E7	;modify current sectors age
		LDY	current_cache_idx_E5
		STA	cache_age_table,Y

loc_192B:
		LDA	current_cache_idx_E5
		CLC
		.if EXTMEM
		ADC	#$80
		.else
		ADC	after_dynamic_memory_page_A8 ; returns page ptr	to wanted sector
		.endif
		RTS

read_error_internal:
		.if DEBUG_PRINTS
		JSR	op0_new_line
		LDA	get_sector_tmp_lo_AA
		STA	arg1_lo_82
		LDA	get_sector_tmp_hi_AB
		STA	arg1_hi_83
		JSR	opvar_print_num
		JSR	op0_new_line
		.endif

		LDA	#14
		JMP	display_internal_error



; =============== S U B	R O U T	I N E =======================================


find_available_cache_slot:
		LDA	cache_age_table

		LDX	#0
		STX	available_cache_slot_idx_E8
		INX
loc_193E:
		CMP	cache_age_table,X
		BCC	loc_1948
		LDA	cache_age_table,X
		STX	available_cache_slot_idx_E8

loc_1948:
		INX
		CPX	cache_size_in_pages_A9
		BCC	loc_193E

		STA	cache_age_correction_E6
		RTS

; =============== S U B	R O U T	I N E =======================================

find_lowest_cache_age:
		LDX	#0
		STX	available_cache_slot_idx_E8
loc_1954:
		LDA	cache_age_table,X
		BNE	loc_1960
		INX
		CPX	cache_size_in_pages_A9
		BCC	loc_1954
		BCS	loc_1973

loc_1960:
		INX

loc_1961:
		CMP	cache_age_table,X
		BCC	loc_196E
		LDY	cache_age_table,X
		BEQ	loc_196E
		TYA
		STX	available_cache_slot_idx_E8

loc_196E:
		INX
		CPX	cache_size_in_pages_A9
		BCC	loc_1961

loc_1973:
		STA	cache_age_correction_E6
		RTS

; =============== S U B	R O U T	I N E =======================================

cvt_addr_in_temp2_to_zdata:
		LDA	zdata_addr_hi_9D
		PHA
		LDA	zdata_addr_hihi_9E
		PHA

		LDA	temp2_lo_94
		STA	zdata_addr_lo_9C
		LDA	temp2_hi_95
		STA	zdata_addr_hi_9D
		LDA	#0
		STA	zdata_addr_hihi_9E

		PLA
		CMP	zdata_addr_hihi_9E
		BNE	cait2_1
		PLA
		CMP	zdata_addr_hi_9D
		BNE	cait2_2
		;##TRACE "*NOinvalidate in cvt_addr_in_temp2_to_zdata"
		RTS

cait2_1:	PLA
cait2_2:	LDA	#0
		;##TRACE "*invalidate in cvt_addr_in_temp2_to_zdata"
		STA	zdata_buffer_valid_9F
		RTS


; =============== S U B	R O U T	I N E =======================================

.if ZVER = 7
hdr_str_offs_lo:	.BYTE 0
hdr_str_offs_hi:	.BYTE 0
hdr_str_offs_hihi:	.BYTE 0

hdr_rout_offs_lo:	.BYTE 0
hdr_rout_offs_hi:	.BYTE 0
hdr_rout_offs_hihi:	.BYTE 0
.endif

cvt_paddr_in_temp2_to_zdata:
		LDA	zdata_addr_hi_9D
		PHA
		LDA	zdata_addr_hihi_9E
		PHA

.if ZVER=3
		LDA	temp2_lo_94
		ASL
		STA	zdata_addr_lo_9C
		LDA	temp2_hi_95
		ROL
		STA	zdata_addr_hi_9D
		LDA	#0
		ROL
		STA	zdata_addr_hihi_9E

.elseif ZVER = 4 || ZVER = 5

		LDA	temp2_lo_94
		STA	zdata_addr_lo_9C
		LDA	temp2_hi_95
		STA	zdata_addr_hi_9D
		LDA	#0
		STA	zdata_addr_hihi_9E

		ASL	zdata_addr_lo_9C
		ROL	zdata_addr_hi_9D
		ROL	zdata_addr_hihi_9E

		ASL	zdata_addr_lo_9C
		ROL	zdata_addr_hi_9D
		ROL	zdata_addr_hihi_9E

.elseif ZVER = 7

		LDA	temp2_lo_94
		CLC
		ADC	hdr_str_offs_lo
		STA	zdata_addr_lo_9C
		LDA	temp2_hi_95
		ADC	hdr_str_offs_hi
		STA	zdata_addr_hi_9D
		LDA	#0
		ADC	hdr_str_offs_hihi
		STA	zdata_addr_hihi_9E

		ASL	zdata_addr_lo_9C
		ROL	zdata_addr_hi_9D
		ROL	zdata_addr_hihi_9E

		ASL	zdata_addr_lo_9C
		ROL	zdata_addr_hi_9D
		ROL	zdata_addr_hihi_9E

.elseif ZVER = 8

		LDA	temp2_lo_94
		STA	zdata_addr_lo_9C
		LDA	temp2_hi_95
		STA	zdata_addr_hi_9D
		LDA	#0
		STA	zdata_addr_hihi_9E

		ASL	zdata_addr_lo_9C
		ROL	zdata_addr_hi_9D
		ROL	zdata_addr_hihi_9E

		ASL	zdata_addr_lo_9C
		ROL	zdata_addr_hi_9D
		ROL	zdata_addr_hihi_9E

		ASL	zdata_addr_lo_9C
		ROL	zdata_addr_hi_9D
		ROL	zdata_addr_hihi_9E
.else
	.error
.endif

		PLA
		CMP	zdata_addr_hihi_9E
		BNE	cpit2_1
		PLA
		CMP	zdata_addr_hi_9D
		BNE	cpit2_2
		;##TRACE "*NOinvalidate in cvt_paddr_in_temp2_to_zdata"
		RTS

cpit2_1:	PLA
cpit2_2:	LDA	#0
		;##TRACE "*invalidate in cvt_paddr_in_temp2_to_zdata"
		STA	zdata_buffer_valid_9F
locret_19a1:	RTS

; =============== S U B	R O U T	I N E =======================================

character_table:
	.BYTE $0,$0,$0,$0,$0,$0,'abcdefghijklmnopqrstuvwxyz'
	.BYTE $0,$0,$0,$0,$0,$0,'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
	.BYTE $0,$0,$0,$0,$0,$0,$0, ascii_cr, '0123456789.,!?_#', $27, '"', '/', $5C, '-:()'

character_table_len = * - character_table
.if character_table_len != 3*32
.error "Incorrect len ", character_table_len
.endif

print_zstring:
		LDX	#0
		STX	charset_permanent_C9
		STX	zchars_already_output_CD
		DEX
		STX	charset_temporary_CA

print_zstring_main_loop:
		JSR	get_next_zchar
		BCS	locret_19A1		;end of string
		STA	current_zchar_CB
		TAX
		BEQ	output_zscii_space	;0 = space
		CMP	#4			;1-3 = abbrevs
		BCC	process_abbreviations
		CMP	#6			;4-5 = shifts
		BCC	process_shift_characters

		JSR	get_current_charset
		CLC
		ADC	current_zchar_CB
		CMP	#64+6
		BEQ	output_zscii_escape
		CMP	#64+7
		BEQ	output_zscii_eol
		TAX
		LDA	character_table,X

output_one_character:
		JSR	print_a_character
		JMP	print_zstring_main_loop

output_zscii_space:
		LDA	#' '
		BNE	output_one_character

output_zscii_eol:
		LDA	#$d
		BNE	output_one_character

output_zscii_escape:
		JSR	get_next_zchar
		ASL
		ASL
		ASL
		ASL
		ASL
		STA	current_zchar_CB 	;5 upper bits
		JSR	get_next_zchar		;5 lower bits
		ORA	current_zchar_CB 	;should be 10 bits, but it's cut down to 8 (3.8.1 mentions above 256 are undefined)
		JMP	output_one_character

process_shift_characters:
		;( SHIFT - 3 ) * 32 so that we can touch the character table directly
		SEC
		SBC	#3
		ASL
		ASL
		ASL
		ASL
		ASL
		TAY
		JSR	get_current_charset
		BNE	curr_charset_is_1_or_2
		STY	charset_temporary_CA
		JMP	print_zstring_main_loop

curr_charset_is_1_or_2:
		STY	charset_permanent_C9
		CMP	charset_permanent_C9
		BEQ	print_zstring_main_loop
		LDA	#0
		STA	charset_permanent_C9
		BEQ	print_zstring_main_loop

process_abbreviations:
		;formula is (z-1)*32+x
		SEC
		SBC	#1			;now abbrev tbl is 0,1,2 (z-1 in the formula)

		ASL
		ASL
		ASL
		ASL
		ASL
		ASL
		STA	tmp_abbrev_ptr_CC 	;*32 in formula (but *2 to have word pointer)
		JSR	get_next_zchar
		ASL				;+next zchar *2
		CLC
		ADC	tmp_abbrev_ptr_CC
		TAY				;everything is mul by 2 to have pointer loaded

		JSR	get_abbrevs_byte_Y_offs
		STA	temp2_hi_95
		INY
		JSR	get_abbrevs_byte_Y_offs
		STA	temp2_lo_94		;pointer to abbrev

		LDA	zdata_addr_hihi_9E 	;push current string state to stack
		PHA
		LDA	zdata_addr_hi_9D
		PHA
		LDA	zdata_addr_lo_9C
		PHA
		LDA	charset_permanent_C9
		PHA
		LDA	zchars_already_output_CD
		PHA
		LDA	tmp_zchar_lo_CF
		PHA
		LDA	tmp_zchar_hi_CE
		PHA

		;this is not correct from semantic point of view
		;but abbrevs are always *2
		;so for ver3 we misuse paddr conversion (which is also *2)
		;for higher versions, we multiply manually, as paddr is *4
		;data are invalidated in cvt_ functions
		.if ZVER = 3
		JSR	cvt_paddr_in_temp2_to_zdata	;z3 paddr = *2
		.else
		LDA	temp2_lo_94
		STA	zdata_addr_lo_9C
		LDA	temp2_hi_95
		STA	zdata_addr_hi_9D
		LDA	#0
		;##TRACE "*zdata invalidate before abbreviations"
		STA	zdata_addr_hihi_9E
		STA	zdata_buffer_valid_9F

		ASL	zdata_addr_lo_9C
		ROL	zdata_addr_hi_9D
		ROL	zdata_addr_hihi_9E
		.endif

		JSR	print_zstring	; print	it

		PLA			; and restore the string state
		STA	tmp_zchar_hi_CE
		PLA
		STA	tmp_zchar_lo_CF
		PLA
		STA	zchars_already_output_CD
		PLA
		STA	charset_permanent_C9
		PLA
		STA	zdata_addr_lo_9C
		PLA
		STA	zdata_addr_hi_9D
		PLA
		STA	zdata_addr_hihi_9E

		;set charset
		LDX	#$FF
		STX	charset_temporary_CA
		;invalidate data
		INX
		;##TRACE "*zdata invalidate in abbreviations"
		STX	zdata_buffer_valid_9F
		JMP	print_zstring_main_loop

; =============== S U B	R O U T	I N E =======================================

get_abbrevs_byte_Y_offs:
		.if EXTMEM
		TXA
		PHA
		TYA
		CLC
		ADC	ptr_abbrevs_lo
		STA	gabyo+1

		LDA	ptr_abbrevs_hi
		ADC	#0
		TAX

		LDA	extmem_map_portbs,X
		STA	PORTB
		LDA	extmem_map_pgs,X
		STA	gabyo+2
		PLA
		TAX
gabyo:		LDA.a	$0000
		RTS
		.else
		LDA (ptr_abbrevs_lo),Y
		RTS
		.endif


; =============== S U B	R O U T	I N E =======================================

get_current_charset:
		LDA	charset_temporary_CA
		BPL	loc_1A71
		LDA	charset_permanent_C9
		RTS

loc_1A71:
		LDY	#$FF
		STY	charset_temporary_CA
		RTS

; =============== S U B	R O U T	I N E =======================================


get_next_zchar:
		LDA	zchars_already_output_CD
		BPL	not_yet_done
		SEC
		RTS

not_yet_done:
		BNE	zchars_2_and_3
		INC	zchars_already_output_CD
		JSR	get_one_data_zbyte
		STA	tmp_zchar_lo_CF
		JSR	get_one_data_zbyte
		STA	tmp_zchar_hi_CE
		LDA	tmp_zchar_lo_CF
		LSR
		LSR
		JMP	output_zchar

zchars_2_and_3:
		SEC
		SBC	#1
		BNE	zchar_3
		LDA	#2
		STA	zchars_already_output_CD
		LDA	tmp_zchar_hi_CE
		STA	temp2_lo_94
		LDA	tmp_zchar_lo_CF
		ASL	temp2_lo_94
		ROL
		ASL	temp2_lo_94
		ROL
		ASL	temp2_lo_94
		ROL
		JMP	output_zchar

zchar_3:
		LDA	#0
		STA	zchars_already_output_CD
		LDA	tmp_zchar_lo_CF
		BPL	output_tmp_zchar_hi
		LDA	#$FF
		STA	zchars_already_output_CD

output_tmp_zchar_hi:
		LDA	tmp_zchar_hi_CE

output_zchar:
		AND	#$1F
		CLC
		RTS

; =============== S U B	R O U T	I N E =======================================

convert_kwd_buffer_to_zdata:

		LDX	#DICT_WORD_LEN - 1
		LDA	#5
fill_with_5:
		STA	converted_keyword_buffer_B4,X
		DEX
		BPL	fill_with_5

		;we have space for DICT_WORD_LEN chars only
		;since the conversion is not 1:1 (escaped char is 4 bytes for example), we must have at least two different counters
		;and we may end sooner before we actually consume all input chars
		LDA	#DICT_WORD_LEN
		STA	output_buffer_char_count_D0

		LDA	#0
		STA	curr_char_ptr_in_D1
		STA	curr_char_ptr_out_D2

main_conversion_loop:
		LDX	curr_char_ptr_in_D1
		INC	curr_char_ptr_in_D1
		LDA	keyword_buffer,X
		BEQ	output_zero_char
		STA	current_zchar_CB
test_A0:
		LDA	current_zchar_CB
		JSR	is_char_in_A0
		BNE	output_converted_char		;found in A0, just output converted char

test_A1:
		LDA	current_zchar_CB
		JSR	is_char_in_A1
		BEQ	test_A2				;not found in A1

		PHA
		LDA	#4
		BNE	output_shift			;output first shift

test_A2:	LDA	current_zchar_CB
		JSR	is_char_in_A2
		BEQ	output_escape			;not found in A2, continue to escape chars
		PHA
		LDA	#5
output_shift:	LDX	curr_char_ptr_out_D2
		STA	converted_keyword_buffer_B4,X
		PLA	
		INC	curr_char_ptr_out_D2
		DEC	output_buffer_char_count_D0
		BNE	output_converted_char
		JMP	convert_keyword_zchars_to_zdata

output_zero_char:
		;empty char is encoded as 5 always
		LDA	#5
		
output_converted_char:
		LDX	curr_char_ptr_out_D2
		STA	converted_keyword_buffer_B4,X
		INC	curr_char_ptr_out_D2
		DEC	output_buffer_char_count_D0
		BNE	main_conversion_loop
		JMP	convert_keyword_zchars_to_zdata

output_escape:
		LDA	#5
		LDX	curr_char_ptr_out_D2
		STA	converted_keyword_buffer_B4,X
		INC	curr_char_ptr_out_D2
		DEC	output_buffer_char_count_D0
		BEQ	convert_keyword_zchars_to_zdata

		;escape, 10bit character continues
		LDA	#6
		LDX	curr_char_ptr_out_D2
		STA	converted_keyword_buffer_B4,X
		INC	curr_char_ptr_out_D2
		DEC	output_buffer_char_count_D0
		BEQ	convert_keyword_zchars_to_zdata
		LDA	current_zchar_CB
		LSR
		LSR
		LSR
		LSR
		LSR
		AND	#3
		LDX	curr_char_ptr_out_D2
		STA	converted_keyword_buffer_B4,X
		INC	curr_char_ptr_out_D2
		DEC	output_buffer_char_count_D0
		BEQ	convert_keyword_zchars_to_zdata
		LDA	current_zchar_CB
		AND	#$1F
		JMP	output_converted_char

; =============== S U B	R O U T	I N E =======================================

is_char_in_A0:
		LDX	#6
icit0_0:	CMP	character_table,X
		BEQ	icit0_1
		INX
		CPX	#32
		BNE	icit0_0
		;Z = 1 not found
		RTS

icit0_1:	TXA	;z=0, a=zchar
		RTS

is_char_in_A1:
		LDX	#6
icit1_0:	CMP	character_table+32,X
		BEQ	icit0_1
		INX
		CPX	#32
		BNE	icit1_0
		;Z = 1 not found
		RTS

is_char_in_A2:
		LDX	#8
icit2_0:	CMP	character_table+64,X
		BEQ	icit0_1
		INX
		CPX	#32
		BNE	icit2_0
		;Z = 1 not found
		RTS


; ---------------------------------------------------------------------------

.if ZVER = 3
convert_keyword_zchars_to_zdata:
		LDA	converted_keyword_buffer_B4+1
		ASL
		ASL
		ASL

		ASL
		ROL	converted_keyword_buffer_B4
		ASL
		ROL	converted_keyword_buffer_B4

		ORA	converted_keyword_buffer_B4+2
		STA	converted_keyword_buffer_B4+1


		LDA	converted_keyword_buffer_B4+4
		ASL
		ASL
		ASL
		ASL
		ROL	converted_keyword_buffer_B4+3
		ASL
		ROL	converted_keyword_buffer_B4+3
		ORA	converted_keyword_buffer_B4+5
		TAX
		LDA	converted_keyword_buffer_B4+3
		ORA	#$80
		STA	converted_keyword_buffer_B4+2
		STX	converted_keyword_buffer_B4+3

		RTS
.else
convert_keyword_zchars_to_zdata:
		;first 3 chars into first word
		LDA	converted_keyword_buffer_B4+1
		ASL
		ASL
		ASL

		ASL
		ROL	converted_keyword_buffer_B4
		ASL
		ROL	converted_keyword_buffer_B4

		ORA	converted_keyword_buffer_B4+2
		STA	converted_keyword_buffer_B4+1


		;next 3 chars into second word
		LDA	converted_keyword_buffer_B4+4
		ASL
		ASL
		ASL

		ASL
		ROL	converted_keyword_buffer_B4+3
		ASL
		ROL	converted_keyword_buffer_B4+3
		
		ORA	converted_keyword_buffer_B4+5
		TAX
		LDA	converted_keyword_buffer_B4+3
		STA	converted_keyword_buffer_B4+2
		STX	converted_keyword_buffer_B4+3


		;next 3 chars into third, terminating word
		LDA	converted_keyword_buffer_B4+7
		ASL
		ASL
		ASL

		ASL
		ROL	converted_keyword_buffer_B4+6
		ASL
		ROL	converted_keyword_buffer_B4+6

		ORA	converted_keyword_buffer_B4+8
		TAX
		LDA	converted_keyword_buffer_B4+6
		ORA	#$80
		STA	converted_keyword_buffer_B4+4
		STX	converted_keyword_buffer_B4+5

		RTS
.endif


; =============== S U B	R O U T	I N E =======================================

;maybe the whole implementation of properties is wrong
;in this interpreter
;my computation is
;each property could be 1-8 bytes long, +1 of length
;there could be 31 full properties and 1 byte of zero terminator
;totally 31 x (8+1) + 1 = 280 bytes
;which is more than addressable by 8bits in Y register used for this
;OTOH, it will fail only in really extreme testcases

.if ZVER = 3
get_arg1_obj_prop_ptr_to_temp2:
;input - object number in arg1
;output - pointer to properties in temp2_lo/hi
		LDA	arg1_lo_82
		LDY	#OBJ_PROP_OFS		; properties hi ptr
		JSR	get_one_byte_from_object_A_byte_Y_address
		.if !EXTMEM
		CLC
		ADC	game_base_page_A6
		.endif
		PHA

		LDA	arg1_lo_82
		LDY	#OBJ_PROP_OFS+1		; properties lo ptr
		JSR	get_one_byte_from_object_A_byte_Y_address
		STA	temp2_lo_94
		PLA
		STA	temp2_hi_95

		LDY	#0
		JSR	get_property_byte_Y_offs

		;from here is modified behaviour
		;moves temp_obj after the string
		ASL
		BCC	overhop
		INC	temp2_hi_95
overhop:
		;not a mistake - this effectivelly adds 1
		;needed to skip string AND its length
		SEC
		ADC	temp2_lo_94
		STA	temp2_lo_94
		BCC	overhop2
		INC	temp2_hi_95
overhop2:
		RTS

.else
get_arg1_obj_prop_ptr_to_temp2:
		;input - object number in arg1
		;output - pointer to properties in temp2_lo/hi
		LDA	arg1_lo_82
		LDX	arg1_hi_83
		JSR	set_obj_addr_X_A_to_temp2

		LDY	#OBJ_PROP_OFS+1
		JSR	get_one_byte_from_temp2_byte_Y_address
		PHA
		LDY	#OBJ_PROP_OFS
		JSR	get_one_byte_from_temp2_byte_Y_address

		.if !EXTMEM
		CLC
		ADC	game_base_page_A6
		.endif
		STA	temp2_hi_95
		PLA
		STA	temp2_lo_94

		LDY	#0
		JSR	get_property_byte_Y_offs

		;from here is modified behaviour
		;moves temp_obj after the string
		ASL
		BCC	overhop
		INC	temp2_hi_95
overhop:
		;not a mistake - this effectivelly adds 1
		;needed to skip string AND its length
		SEC
		ADC	temp2_lo_94
		STA	temp2_lo_94
		BCC	overhop2
		INC	temp2_hi_95
overhop2:
		RTS

.endif
; =============== S U B	R O U T	I N E =======================================

;quite similar in v3 and later - always in first byte, 5 lower bits in v3, 6 bits in higher versions
decode_property_number_from_temp2_to_A:
		.if EXTMEM
		LDA	temp2_lo_94
		STA	dpnft2a_1+1
		LDY	temp2_hi_95
		LDA	extmem_map_portbs,Y
		STA	PORTB
		LDA	extmem_map_pgs,Y
		STA	dpnft2a_1+2
dpnft2a_1:	LDA.a	$0000
		.else
		LDY	#0
		LDA	(temp2_lo_94),Y
		.endif

		.if ZVER = 3
		AND	#$1F
		.else
		AND	#$3F
		.endif
		RTS

; =============== S U B	R O U T	I N E =======================================

.if ZVER = 3
decode_property_length_from_temp2_to_A:
		.if EXTMEM
		LDA	temp2_lo_94
		STA	dplft2a_1+1
		LDY	temp2_hi_95
		LDA	extmem_map_portbs,Y
		STA	PORTB
		LDA	extmem_map_pgs,Y
		STA	dplft2a_1+2
dplft2a_1:	LDA.a	$0000
		.else
		LDA	#0
		LDA	(temp2_lo_94),Y
		.endif

		LSR
		LSR
		LSR
		LSR
		LSR
		CLC
		ADC	#1				;this could have unforeseen consequences!
		RTS
.else
decode_property_length_from_temp2_to_A:
		.if EXTMEM
		LDA	temp2_lo_94
		STA	dpl_mi+1
		LDY	temp2_hi_95
		LDA	extmem_map_portbs,Y
		STA	PORTB
		LDA	extmem_map_pgs,Y
		STA	dpl_mi+2
dpl_mi:		LDA.a	$0000
		.else
		LDY	#0
		LDA	(temp2_lo_94),Y
		.endif
		BMI	dpl_o1
		;bit 7 is zero
		CMP	#$40
		BCC	dpl_o2
		LDA	#2
		RTS
dpl_o2:		LDA	#1
		RTS
dpl_o1:		

		.if EXTMEM
		LDA	#1
		CLC
		ADC	temp2_lo_94
		STA	dpl_mi2+1
		LDA	temp2_hi_95
		ADC	#0
		TAY
		LDA	extmem_map_portbs,Y
		STA	PORTB
		LDA	extmem_map_pgs,Y
		STA	dpl_mi2+2
dpl_mi2:	LDA.a	$0000
		.else
		LDY	#1
		LDA	(temp2_lo_94),Y
		.endif
		AND	#$3F
		BEQ	dpl_o3		
		RTS
dpl_o3:
		LDA	#64
		RTS
.endif
; =============== S U B	R O U T	I N E =======================================


move_to_next_property:
		JSR	decode_property_length_from_temp2_to_A
		TAY
		INY
		.if ZVER >= 4
		CPY	#4
		BCC	mtnp_1
		INY
		.endif
mtnp_1:		TYA
		CLC
		ADC	temp2_lo_94
		STA	temp2_lo_94
		BCC	loc_1c02
		INC	temp2_hi_95
loc_1c02:
		RTS


; =============== S U B	R O U T	I N E =======================================

aInternalError:	.BYTE 'Internal error '
internal_error_asc:
		.BYTE '00'
		.BYTE '.'
aInternalErrorLen = * - aInternalError


display_internal_error:
		LDY	#1
loc_1C5B:
		LDX	#0
loc_1C5D:
		CMP	#10
		BCC	loc_1C66	; error	less than 10 dec
		SBC	#10
		INX			; upper	error number in	X
		BNE	loc_1C5D

loc_1C66:
		ORA	#'0'
		STA	internal_error_asc,Y
		TXA
		DEY
		BPL	loc_1C5B
		JSR	op0_new_line

		LDA	#0
		STA	transcripting_control_DF

		LDX	#<aInternalError
		LDA	#>aInternalError
		LDY	#aInternalErrorLen
		JSR	print_string_X_lo_A_hi_Y_len

op0_quit:
		JSR	op0_new_line
		LDX	#<aEndOfSession
		LDA	#>aEndOfSession
		LDY	#aEndOfSessionLen
		JSR	print_string_X_lo_A_hi_Y_len
		JSR	op0_new_line

dynamic_halt:
		JMP	dynamic_halt

; ---------------------------------------------------------------------------

aEndOfSession:	.BYTE 'End of session.'
aEndOfSessionLen = * - aEndOfSession

; =============== S U B	R O U T	I N E =======================================

op0_restart:
		.if SD_TWO_SIDE
		JSR	ask_insert_side_1
		.else
		;I don't think any prompt is needed here
		.endif

		.if EXTMEM
		LDA	extmem_map_portbs
		STA	PORTB
		.endif

		LDA	story_hdr_flags2_lo
		AND	#1
		STA	byte_2034
		JMP	game_restart_entry_point

; ---------------------------------------------------------------------------
aAtariVersion:
.if ZVER = 3
		.BYTE 'Atari Version G+'
.else
		interpreter_version = 'H'
		.BYTE 'Atari Version H'
.endif
		.BYTE ', 2023 JK'
                .BYTE atari_eol
		.BYTE '(', version_hihi+'0', '.', version_hi+'0', '.', version_lo+'0'
		.BYTE '/z', ZVER+'0'
		.if EXTMEM
		.BYTE '/ext'
		.else
		.BYTE '/base'
		.endif

		.if SD_ONE_SIDE
		.BYTE '/SD'
		.elseif SD_TWO_SIDE
		.BYTE '/SDd'
		.elseif ED_ONE_SIDE
		.BYTE '/ED'
		.elseif DD_ONE_SIDE
		.BYTE '/DD'
		.else
			.error
		.endif

		.if LONG_MEDIA
		.BYTE 'u'
		.endif

		.if LARGE_STACK
		.BYTE '/lstk'
		.endif

		.if VIDEO = A40
		.BYTE '/a40'
		.elseif VIDEO = S80
		.BYTE '/s80'
		.elseif VIDEO = S64
		.BYTE '/s64'
		.elseif VIDEO = VBXE
		.BYTE '/vbxe'
		.else
			.error
		.endif
		.BYTE ')', atari_eol


aAtariVersionLen = * - aAtariVersion

; =============== S U B	R O U T	I N E =======================================

print_interpreter_version_and_load_s1:
		JSR	op0_new_line

		LDX	#<aAtariVersion
		LDA	#>aAtariVersion
		LDY	#aAtariVersionLen
		JSR	print_string_X_lo_A_hi_Y_len

		.if SD_TWO_SIDE
		JMP	ask_insert_side_1
		.endif
		RTS

; =============== S U B	R O U T	I N E =======================================

get_random_a_x:
		LDA	RANDOM
		NOP
		LDX	RANDOM
		RTS

; =============== S U B	R O U T	I N E =======================================

.if CZ_LANG

convert_to_capek:
	.BYTE $3F, $3F, $3F, $3F, $3F, $3F, $3F, $3F, $3F, $3F, $3F, $3F, $3F, $3F, $3F, $3F
	.BYTE $3F, $3F, $3F, $3F, $3F, $3F, $3F, $3F, $3F, $3F, $3F, $3F, $3F, $3F, $3F, $3F
	.BYTE $20, $21, $22, $23, $07, $3F, $3F, $3F, $06, $24, $08, $02, $2C, $2D, $2E, $2F
	.BYTE $30, $31, $32, $33, $34, $35, $36, $37, $38, $39, $3A, $3B, $3C, $3D, $3E, $3F
	.BYTE $3F, $41, $42, $43, $44, $45, $46, $47, $48, $49, $4A, $4B, $4C, $4D, $4E, $4F
	.BYTE $50, $51, $52, $53, $54, $55, $56, $57, $58, $59, $5A, $3F, $3F, $3F, $3F, $5F
	.BYTE $3F, $61, $62, $63, $64, $65, $66, $67, $68, $69, $6A, $6B, $6C, $6D, $6E, $6F
	.BYTE $70, $71, $72, $73, $74, $75, $76, $77, $78, $79, $7A, $3F, $7C, $7D, $3F, $3F
	.BYTE $3F, $3F, $3F, $3F, $3F, $3F, $3F, $3F, $3F, $3F, $3F, $3F, $3F, $3F, $3F, $3F
	.BYTE $3F, $3F, $3F, $3F, $3F, $3F, $3F, $3F, $3F, $3F, $3F, $3F, $3F, $5C, $3F, $13
	.BYTE $3F, $1D, $3F, $1A, $3F, $3F, $01, $3F, $3F, $5E, $3F, $3F, $3F, $03, $05, $3F
	.BYTE $3F, $0D, $09, $3F, $1F, $3F, $3F, $0A, $0B, $3F, $3F, $3F, $12, $1C, $15, $3F
	.BYTE $7B, $19, $3F, $3F, $3F, $0C, $3F, $26, $3F, $14, $3F, $28, $3F, $3F, $11, $2A
	.BYTE $3F, $3F, $7F, $3F, $3F, $3F, $27, $5B, $3F, $3F, $25, $29, $3F, $04, $3F, $3F
	.BYTE $0E, $0F, $18, $3F, $7E, $40, $2B, $5D, $3F, $10, $60, $3F, $25, $29, $3F, $04
	.BYTE $3F, $3F, $0E, $0F, $18, $3F, $7E, $3F, $40, $2B, $5D, $3F, $10, $60, $3F, $3F
.endif 

print_a_character:
		BEQ	locret_1CFE
		.if ZVER >= 4
		TAX
		;check for stream 3, if selected, just insert byte
		LDA	selected_streams
		AND	#stream_3
		BEQ	pacb_1
pacb_0:
		JSR	stream_3_insert_byte
		TXA
		;with stream 3 no other output is taking place
		RTS

pacb_1:		LDA	selected_streams
		AND	#stream_1
		BNE	pacb_3
		;how about stream 2?
		TXA
		RTS

pacb_3:		TXA
		.endif

		CMP	#ascii_cr
		BEQ	op0_new_line
		CMP	#ascii_space
		BCC	locret_1CFE

.if CZ_LANG
		TAX
		LDA	convert_to_capek,X
.endif
		.if ZVER >= 4
		;we can only display reverse style in Z4+
		ORA	screen_output_reverse

		;window 1 (upper) is non-scrollable, unbuffered, always
		LDX	active_window
		CPX	#1
		BEQ	pac_1
		;check the buffering
		LDX	window0_is_buffered
		BNE	pac_2
pac_1:		JMP	lowlevel_single_char_out_noscroll
pac_2:		
		.endif

		LDX	index_in_string_in_out_buffer_DD
		STA	string_in_out_buffer,X
		CPX	#SCREEN_WIDTH_CHARS_PRINTED
		BCS	loc_1CFF
		INC	index_in_string_in_out_buffer_DD
locret_1CFE:
		RTS

loc_1CFF:
		LDA	#' '

loc_1D01:
		CMP	string_in_out_buffer,X
		BEQ	loc_1D0B
		DEX
		BNE	loc_1D01
		LDX	#SCREEN_WIDTH_CHARS_PRINTED

loc_1D0B:
		STX	byte_DE
		STX	index_in_string_in_out_buffer_DD
		JSR	op0_new_line
		LDX	byte_DE
		LDY	#0
loc_1D16:
		INX
		CPX	#SCREEN_WIDTH_CHARS_PRINTED
		BCC	loc_1D20
		BEQ	loc_1D20
		STY	index_in_string_in_out_buffer_DD
		RTS

loc_1D20:
		LDA	string_in_out_buffer,X
		STA	string_in_out_buffer,Y
		INY
		BNE	loc_1D16

; =============== S U B	R O U T	I N E =======================================


op0_new_line:
		.if ZVER >= 4
		;this basically means that if stream 1 is not selected, don't play with newline counters
		LDA	selected_streams
		AND	#stream_1
		BEQ	no_char_to_print
		.endif

		INC	lines_printed_since_last_pause_E0
		LDA	lines_printed_since_last_pause_E0
		CMP	screen_lines_to_scroll_E1
		BCC	not_at_the_screen_end
op0nl_3
		.if ZVER = 3
		JSR	op0_show_status
		.endif
		LDA	#0
		STA	lines_printed_since_last_pause_E0

		.if !SUPPRESS_MORE
		;print more

		JSR	graphics_display_more

		LDA	#$FF
		STA	CH
loc_1D48:
		LDA	CH
		CMP	#$FF
		BEQ	loc_1D48	; wait for any key

		JSR	graphics_erase_more

		.endif

not_at_the_screen_end:
		LDX	index_in_string_in_out_buffer_DD
		LDA	#atari_eol
		STA	string_in_out_buffer,X
		INC	index_in_string_in_out_buffer_DD

flush_buffer_to_screen:
		LDY	index_in_string_in_out_buffer_DD
		BEQ	no_char_to_print
		STY	char_to_print_EA
		LDX	#0

loop_print_chars:
		LDA	string_in_out_buffer,X
		JSR	lowlevel_single_char_out
		INX
		DEY
		BNE	loop_print_chars
		JSR	string_logging_to_printer
		LDA	#0
		STA	index_in_string_in_out_buffer_DD

no_char_to_print:
		RTS


; =============== S U B	R O U T	I N E =======================================

.if ZVER = 3
op0_show_status:
o0ss_patch1:	RTS
		LDA	COLCRS
		PHA
		LDA	ROWCRS
		PHA
		LDA	index_in_string_in_out_buffer_DD
		PHA
		LDA	zdata_addr_hihi_9E
		PHA
		LDA	zdata_addr_hi_9D
		PHA
		LDA	zdata_addr_lo_9C
		PHA
		LDA	charset_temporary_CA
		PHA
		LDA	charset_permanent_C9
		PHA
		LDA	tmp_zchar_lo_CF
		PHA
		LDA	tmp_zchar_hi_CE
		PHA
		LDA	zchars_already_output_CD
		PHA
		LDA	number_of_significant_figures_DB
		PHA

		LDX	#SCREEN_WIDTH_CHARS_PRINTED
loc_1DA8:
		LDA	string_in_out_buffer,X
		STA	byte_A20,X
		LDA	#' '
		STA	string_in_out_buffer,X
		DEX
		BPL	loc_1DA8

		LDX	#1
		STX	index_in_string_in_out_buffer_DD
		DEX
		STX	transcripting_control_DF
		STX	ROWCRS
		STX	COLCRS

		;displays game name or current's object/room?
		LDA	#16
		JSR	read_global_variable_A_to_temp
		LDA	temp_lo_92
		JSR	print_obj_A_desc 

		LDA	#[SCREEN_WIDTH_CHARS_PRINTED - 16]
		STA	index_in_string_in_out_buffer_DD
		LDA	#' '
		JSR	print_a_character

		LDA	#17
		JSR	read_global_variable_A_to_temp

		LDA	status_type_DC
		BNE	status_type_time

		LDA	#'S'
		JSR	print_a_character
		LDA	#'c'
		JSR	print_a_character
		LDA	#'o'
		JSR	print_a_character
		LDA	#'r'
		JSR	print_a_character
		LDA	#'e'
		JSR	print_a_character
		LDA	#' '
		JSR	print_a_character

		LDA	temp_lo_92
		STA	tmp_number_lo_D3
		LDA	temp_hi_93
		STA	tmp_number_hi_D4

		JSR	print_signed_int_num_internal_D3_D4
		LDA	#'/'
		BNE	print_second_number

status_type_time:
		LDA	#'T'
		JSR	print_a_character
		LDA	#'i'
		JSR	print_a_character
		LDA	#'m'
		JSR	print_a_character
		LDA	#'e'
		JSR	print_a_character
		LDA	#' '
		JSR	print_a_character

		LDA	temp_lo_92
		BNE	loc_1E29
		LDA	#24

loc_1E29:
		CMP	#12+1
		BCC	loc_1E2F
		SBC	#12

loc_1E2F:
		STA	tmp_number_lo_D3
		LDA	#0
		STA	tmp_number_hi_D4
		JSR	print_signed_int_num_internal_D3_D4

		LDA	#':'

print_second_number:
		JSR	print_a_character

		LDA	#18
		JSR	read_global_variable_A_to_temp

		LDA	temp_lo_92
		STA	tmp_number_lo_D3
		LDA	temp_hi_93
		STA	tmp_number_hi_D4

		LDA	status_type_DC
		BNE	status_time2

		JSR	print_signed_int_num_internal_D3_D4
		JMP	status_printed

status_time2:
		LDA	temp_lo_92
		CMP	#10
		BCS	more_than_9
		LDA	#'0'
		JSR	print_a_character

more_than_9:
		JSR	print_signed_int_num_internal_D3_D4

		LDA	#' '
		JSR	print_a_character

		LDA	#17
		JSR	read_global_variable_A_to_temp

		LDA	temp_lo_92
		CMP	#12
		BCS	print_pm
		LDA	#'a'
		BNE	print_am

print_pm:
		LDA	#'p'

print_am:
		JSR	print_a_character
		LDA	#'m'
		JSR	print_a_character

status_printed:
		LDX	#[SCREEN_WIDTH_CHARS_PRINTED]
loop_clear:
		LDA	#' '*
		JSR	lowlevel_single_char_out
		DEX
		BPL	loop_clear
		INX

		LDA	#0
		STA	COLCRS
		STA	ROWCRS

loop_copy_with_invert:
		LDA	string_in_out_buffer,X
		ORA	#$80
		JSR	lowlevel_single_char_out
		INX
		CPX	index_in_string_in_out_buffer_DD
		BCC	loop_copy_with_invert

		LDX	#SCREEN_WIDTH_CHARS_PRINTED
loc_1E9A:
		LDA	byte_A20,X
		STA	string_in_out_buffer,X
		DEX
		BPL	loc_1E9A
		PLA
		STA	number_of_significant_figures_DB
		PLA
		STA	zchars_already_output_CD
		PLA
		STA	tmp_zchar_hi_CE
		PLA
		STA	tmp_zchar_lo_CF
		PLA
		STA	charset_permanent_C9
		PLA
		STA	charset_temporary_CA
		PLA
		STA	zdata_addr_lo_9C
		PLA
		STA	zdata_addr_hi_9D
		PLA
		STA	zdata_addr_hihi_9E
		PLA
		STA	index_in_string_in_out_buffer_DD
		PLA
		STA	ROWCRS
		PLA
		STA	COLCRS
		LDX	#$FF
		STX	transcripting_control_DF
		INX
		;##TRACE "*zdata invalidate in status"
		STX	zdata_buffer_valid_9F
		RTS
.endif

; ---------------------------------------------------------------------------

loc_1ED1:
					; get_one_kbd_char+51j
		JSR	bad_beep
		JMP	loc_1EDC

get_one_kbd_char:

		CLD
		TXA
		PHA
		TYA
		PHA

loc_1EDC:
		LDA	#0
		STA	keydel_lo_f6
		STA	keydel_hi_f7

		graphics_pmg_cursor_on

loc_1EFC:
		LDX	CH
		INC	keydel_lo_f6
		BNE	loc_1F14
		INC	keydel_hi_f7
		BNE	loc_1F14
		LDA	#$80
		STA	keydel_hi_f7

		graphics_pmg_cursor_xor

loc_1F14:
		CPX	#$FF
		BEQ	loc_1EFC
		LDA	#$FF
		STA	CH
		TXA
		BMI	loc_1ED1
		LDA	keycode_to_atascii,X
		CMP	#atari_eol
		BEQ	loc_1F2A
		TAX
		BMI	loc_1ED1

loc_1F2A:
		STA	one_character_E2

		graphics_pmg_cursor_off

		LDY	#$80
loc_1F33:
		STY	CONSOL
		LDX	#8

loc_1F38:
		DEX
		BNE	loc_1F38
		DEY
		BNE	loc_1F33
		PLA
		TAY
		PLA
		TAX
		LDA	one_character_E2
		RTS

; =============== S U B	R O U T	I N E =======================================

lowlevel_single_char_out_noscroll:
		STA	one_character_E2
		TXA
		PHA
		TYA
		PHA
		LDY	ROWCRS
		LDX	COLCRS
		LDA	one_character_E2
		CMP	#atari_eol
		BEQ	newline_out1
		CMP	#ascii_cr
		BEQ	newline_out1

out_one_char1:
		LDA	one_character_E2
		JSR	graphics_PUT_CHAR
		LDA	COLCRS
		CMP	#SCREEN_WIDTH_CHARS_PRINTED
		BEQ	endit1
		INC	COLCRS
		
endit1:
		PLA
		TAY
		PLA
		TAX
		RTS

newline_out1:
		LDA	ROWCRS
		CMP	where_is_window_split_E4
		BCC	endit1
		LDA	#0
		STA	COLCRS
		INC	ROWCRS
		JMP	endit1

; =============== S U B	R O U T	I N E =======================================

lowlevel_single_char_out:
		STA	one_character_E2
		TXA
		PHA
		TYA
		PHA
		LDY	ROWCRS
		LDX	COLCRS
		LDA	one_character_E2
		CMP	#atari_backspace
		BNE	lsco4
		LDA	COLCRS
		BEQ     lsco1
		DEC	COLCRS
		LDA	#' '
		STA	one_character_E2
		JSR	graphics_PUT_CHAR
		JMP	lsco1		
lsco4:		CMP	#atari_eol
		BEQ	newline_out
		CMP	#ascii_cr
		BEQ	newline_out
		CPY	#[SCREEN_LINES_TOTAL-1]		;checks max line
		BCC	out_one_char
		CPX	#SCREEN_WIDTH_CHARS_PRINTED	;checks max width
		BCC	out_one_char

at_the_bottom_of_screen:
		DEY
		STY	ROWCRS
		LDA	#0
		STA	COLCRS
lsco3:		LDX	where_is_window_split_E4

		JSR	graphics_scroll_partially

out_one_char:
		LDA	one_character_E2
		JSR	graphics_PUT_CHAR
		LDA	COLCRS
		CMP	#SCREEN_WIDTH_CHARS_PRINTED
		BEQ	lsco2
		INC	COLCRS
      		BNE	lsco1
lsco2:		LDA	#0
		STA	COLCRS
		LDA	ROWCRS
		CMP	#[SCREEN_LINES_TOTAL-1]
		BEQ     lsco3
		INC	ROWCRS

lsco1:		PLA
		TAY
		PLA
		TAX
		RTS

newline_out:
		LDA	#atari_eol
		STA	one_character_E2
		LDA	#0
		STA	COLCRS
		LDA	ROWCRS
		CMP	#[SCREEN_LINES_TOTAL-1]
		BEQ	lsco5
		INC	ROWCRS
		BNE	lsco1
lsco5:		LDX	where_is_window_split_E4
		JSR	graphics_scroll_partially
		JMP	lsco1

; =============== S U B	R O U T	I N E =======================================

keyboard_input_maxlen: .BYTE 0

;arg1 - text buffer
;todo for z4+ -> timed input
get_keyboard_string_outlen_in_A:
		;first flush everything in buffers
		JSR	flush_buffer_to_screen
		;forget anything pressed
		LDY	#$FF
		STY	CH
		;and zero counter of lines printed (used for [MORE])
		INY
		STY	lines_printed_since_last_pause_E0

		LDY	#0
		JSR	get_arg1_byte_offs_Y
		STA	keyboard_input_maxlen

		.if ZVER >= 5
		LDY	#1
		JSR	get_arg1_byte_offs_Y
		DEY
		TAX
		BEQ	wait_for_next_character	;this means 0 chars present on input
		
		;don't get me started on those inyinydeydey-2 ;o)
		INY
		INY
chbcb1:		JSR	get_arg1_byte_offs_Y
		STA	string_in_out_buffer-2,Y
		INY
		DEX
		BNE	chbcb1
		DEY
		DEY
		.endif

wait_for_next_character:
		JSR	get_one_kbd_char
		CMP	#atari_eol
		BEQ	process_enter
		CMP	#atari_backspace
		BEQ	process_backspace
		STA	string_in_out_buffer,Y
		INY

continue_for_next_character:
		JSR	lowlevel_single_char_out
		CPY	keyboard_input_maxlen
		BEQ	loop_wait_for_last_key
		BCC	wait_for_next_character

loop_wait_for_last_key:
		JSR	get_one_kbd_char ; only	enter or backspace at the end of max long line
		CMP	#atari_eol
		BEQ	process_enter
		CMP	#atari_backspace
		BEQ	process_backspace
		JSR	bad_beep
		JMP	loop_wait_for_last_key ; only enter or backspace at the	end of max long	line

process_backspace:
		DEY
		BPL	continue_for_next_character
		JSR	bad_beep
		LDY	#0
		BEQ	wait_for_next_character

process_enter:
		.if ZVER <= 4
		;stores enter in buffer
		STA	string_in_out_buffer,Y
		INY
		.endif

		STY	chars_in_buffer_C2
		STY	char_to_print_EA
		JSR	lowlevel_single_char_out

		.if ZVER >= 5
		LDY	chars_in_buffer_C2
		BEQ     kinpe
		INY
		.endif

loop_copy_to_dest_var:
		.if ZVER >= 5
		LDA	string_in_out_buffer-2,Y	; this reads the last char
		.else
		LDA	string_in_out_buffer-1,Y	; this reads the last char
		.endif
		CMP	#atari_eol
		BNE	lowercase_single_char ;	noinverse, lowercase

		LDA	#ascii_cr		; converts $9B to $0D
		BNE	copy_buffer_to_dest

lowercase_single_char:
		AND	#$7F		; noinverse, lowercase
		CMP	#'A'
		BCC	copy_buffer_to_dest
		CMP	#'Z'+1
		BCS	copy_buffer_to_dest
		ADC	#' '

copy_buffer_to_dest:
		;STA	(arg1_lo_82),Y
		JSR	set_arg1_byte_A_offs_Y
		DEY
		BNE	loop_copy_to_dest_var ;	this reads the last char

kinpe:		JSR	string_logging_to_printer

		.if ZVER >= 5
		LDA	chars_in_buffer_C2
		LDY	#1
		JSR	set_arg1_byte_A_offs_Y
		.endif

		LDA	chars_in_buffer_C2
		RTS

set_arg1_byte_A_offs_Y:
.if EXTMEM
		PHA
		TXA
		PHA
		TYA
		CLC
		ADC	arg1_lo_82
		STA	sa1baoy+1

		LDA	arg1_hi_83
		ADC	#0
		TAX

		LDA	extmem_map_portbs,X
		STA	PORTB
		LDA	extmem_map_pgs,X
		STA	sa1baoy+2
		PLA
		TAX
		PLA
sa1baoy:	STA.a	$0000
		RTS
.else
		STA (arg1_lo_82),Y
		RTS
.endif

get_arg1_byte_offs_Y:
.if EXTMEM
		TXA
		PHA
		TYA
		CLC
		ADC	arg1_lo_82
		STA	ga1boy+1

		LDA	arg1_hi_83
		ADC	#0
		TAX

		LDA	extmem_map_portbs,X
		STA	PORTB
		LDA	extmem_map_pgs,X
		STA	ga1boy+2
		PLA
		TAX
ga1boy:		LDA.a	$0000
		RTS
.else
		LDA	(arg1_lo_82),Y
		RTS
.endif

; =============== S U B	R O U T	I N E =======================================

print_string_X_lo_A_hi_Y_len:
		STX	load_instruction_to_read_chars+1
		STA	load_instruction_to_read_chars+2
		LDX	#0

load_instruction_to_read_chars:
		LDA.a	$0000,X
		JSR	lowlevel_single_char_out
		INX
		DEY
		BNE	load_instruction_to_read_chars
		RTS

; ---------------------------------------------------------------------------

aP_device_name:	.BYTE 'P:', atari_eol
byte_2034:	.BYTE 0

; =============== S U B	R O U T	I N E =======================================

string_logging_to_printer:
		LDA	transcripting_control_DF
		BEQ	locret_20A4

		.if EXTMEM
		LDA	extmem_map_portbs
		STA	PORTB
		.endif

		LDA	story_hdr_flags2_lo ; is script	allowed	in header?
		AND	#1
		BEQ	locret_20A4
		LDA	is_P_device_open_E9 ; $FF - error, don't try again
					; $00 -	open now
					; $01 -	opened,	print
		BMI	locret_20A4
		BNE	already_open
		JSR	close_dev_1
		LDX	#$10
		LDA	#<aP_device_name
		STA	ICBAL_0,X
		LDA	#>aP_device_name
		STA	ICBAH_0,X
		LDA	#CIO_OPEN
		STA	ICCOM_0,X
		LDA	#8
		STA	ICAX1_0,X
		LDA	#0
		STA	ICAX2_0,X
		JSR	CIOV
		TYA
		BMI	loc_2096
		LDA	#$70
		STA	POKMSK
		STA	IRQEN
		LDA	#1
		STA	is_P_device_open_E9

already_open:
		LDX	#$10
		LDA	#<string_in_out_buffer
		STA	ICBAL_0,X
		LDA	#>string_in_out_buffer
		STA	ICBAH_0,X
		LDA	char_to_print_EA
		STA	ICBLL_0,X
		LDA	#0
		STA	ICBLH_0,X
		LDA	#CIO_PUT_BINARY
		STA	ICCOM_0,X
		JSR	CIOV
		TYA
		BPL	locret_20A4

loc_2096:
		LDA	#$FF
		STA	is_P_device_open_E9

close_dev_1:
		LDX	#$10
		LDA	#CIO_CLOSE
		STA	ICCOM_0,X
		JSR	CIOV

locret_20A4:
		RTS



; =============== S U B	R O U T	I N E =======================================


		;arg1 - lines to split
opvar_split_window:

		LDY	arg1_lo_82			;number of lines to split to upper window
		BEQ	unsplit_window			;if 0, unsplit
int_split_window:
		;this does not work for Zork I z5 invisiclues version, which creates top window of MAX-1 lines
		;CPY	#[SCREEN_LINES_TOTAL-4]		;max size of upper window
		;BCS	ovsw_end			;if over, go away
		STY	where_is_window_split_E4	;splits

		.if ZVER = 3 
		;y = split border
		;in Z3 upper window should be cleared on split
		LDX	#0
		JSR	graphics_cls_partial
		.endif

		LDA	#0
		STA	lines_printed_since_last_pause_E0

loc_20CE:
		LDA	#[SCREEN_LINES_TOTAL-1]
		SEC
		SBC	where_is_window_split_E4
		STA	screen_lines_to_scroll_E1
		DEC	screen_lines_to_scroll_E1

ovsw_end:
		RTS
; ---------------------------------------------------------------------------
active_window:	.BYTE 0

unsplit_window:
		JSR	loc_2103

init_screen_vars:
		LDX	#0
		STX	active_window
		STX	where_is_window_split_E4
		STX	lines_printed_since_last_pause_E0
		LDA	#[SCREEN_LINES_TOTAL-1]
		STA	screen_lines_to_scroll_E1
		RTS

		;arg1 - window
opvar_set_window:
		LDA	where_is_window_split_E4        ;is window split?
		BEQ	ovsw_end			;not split, nothing to do

		LDA	arg1_hi_83			;ignore too high window numbers                 
		BNE	ovsw_end

		.if ZVER >= 4
		LDA	active_window			
		BNE	store_curs_1

		;window0, lower
		LDA	COLCRS
		STA	COLCRS0
		LDA	ROWCRS
		STA	ROWCRS0
store_curs_1:
		.endif

		LDA	arg1_lo_82
		BEQ	opsw_1				;window 0

		CMP	#1
		BNE	ovsw_end			;wrong	window number

		;setting window 1 (upper)
		STA	active_window
		LDY	#0
		STY	screen_lines_to_scroll_E1	;not sure if correct here
		STY	ROWCRS
		STY	COLCRS
		JMP	loc_2105

opsw_1:		;setting window 0 (lower)
		STA	active_window
		JSR	loc_20CE

loc_2103:
		.if ZVER >= 4
		LDY	COLCRS0
		STY	COLCRS
		LDY	ROWCRS0
		STY	ROWCRS
		CPY	where_is_window_split_E4
		BCS	loc_2105
		LDY	where_is_window_split_E4
		STY	ROWCRS
		.endif
		
loc_2105:
		LDX	#0
		STX	lines_printed_since_last_pause_E0

		RTS

; =============== S U B	R O U T	I N E =======================================


bad_beep:
		LDA	#$C8
		STA	AUDF1
		LDA	#$AA
		STA	AUDC1
		LDA	#$FC
		STA	RTCLOK+2

snd_waittime:
		LDA	RTCLOK+2
		BNE	snd_waittime
		STA	AUDC1
		RTS

; =============== S U B	R O U T	I N E =======================================

clear_screen_init_scr_vars:
		JSR	unsplit_window
		.if ZVER = 3
		LDY	#1
		JSR	int_split_window
		.endif
		LDA	#0
		STA	active_window

		.if ZVER >= 4
		;0
		STA	screen_output_reverse
		STA	stream_3_ptrs

		LDA	#stream_1
		STA	selected_streams
		.endif

		JSR	graphics_cls

		LDA	#0
		STA	index_in_string_in_out_buffer_DD
		STA	lines_printed_since_last_pause_E0
		STA	COLCRS

		.if ZVER = 3
		LDA	#1
		.endif
		STA	ROWCRS
		RTS

; ---------------------------------------------------------------------------

;lots of keyboard scancodes are not converted to characters
;contrary to OS 
keycode_to_atascii:
		.BYTE $6C	;00 = l
		.BYTE $6A	;01 = j
		.BYTE $3B	;02 = ;
		.BYTE $FF	;03 = F1
		.BYTE $FF	;04 = F2
		.BYTE $6B	;05 = k
		.BYTE $FF	;06 = +
		.BYTE $FF	;07 = *
		.BYTE $6F	;08 = o
		.BYTE $FF	;09 = ?
		.BYTE $70	;0A = p
		.BYTE $75	;0B = u
		.BYTE $9B	;0C = ENTER, TODO: hm, why $9B and not $0D?
		.BYTE $69	;0D = i
		.BYTE $2D	;0E = -
		.BYTE $FF	;0F = =
		.BYTE $76       ;10 = 
		.BYTE $FF       ;11 = 
		.BYTE $63       ;12 = 
		.BYTE $FF       ;13 = 
		.BYTE $FF       ;14 = 
		.BYTE $62       ;15 = 
		.BYTE $78       ;16 = 
		.BYTE $7A       ;17 = 
		.BYTE $34       ;18 = 
		.BYTE $FF       ;19 = 
		.BYTE $33       ;1A = 
		.BYTE $36       ;1B = 
		.BYTE $FF       ;1C = 
		.BYTE $35       ;1D = 
		.BYTE $32       ;1E = 
		.BYTE $31       ;1F = 
		.BYTE $2C       ;20 = 
		.BYTE $20       ;21 = 
		.BYTE $2E       ;22 = 
		.BYTE $6E       ;23 = 
		.BYTE $FF       ;24 = 
		.BYTE $6D       ;25 = 
		.BYTE $2F       ;26 = 
		.BYTE $FF       ;27 = 
		.BYTE $72       ;28 = 
		.BYTE $FF       ;29 = 
		.BYTE $65       ;2A = 
		.BYTE $79       ;2B = 
		.BYTE $FF       ;2C = 
		.BYTE $74       ;2D = 
		.BYTE $77       ;2E = 
		.BYTE $71       ;2F = 
		.BYTE $39       ;30 = 
		.BYTE $FF       ;31 = 
		.BYTE $30       ;32 = 
		.BYTE $37       ;33 = 
		.BYTE $7E       ;34 = 
		.BYTE $38       ;35 = 
		.BYTE $FF       ;36 = 
		.BYTE $FF       ;37 = 
		.BYTE $66       ;38 = 
		.BYTE $68       ;39 = 
		.BYTE $64       ;3A = 
		.BYTE $FF       ;3B = 
		.BYTE $FF       ;3C = 
		.BYTE $67       ;3D = 
		.BYTE $73       ;3E = 
		.BYTE $61       ;3F =
 
		.BYTE $4C       ;40 = 
		.BYTE $4A       ;41 = 
		.BYTE $3A       ;42 = 
		.BYTE $FF       ;43 = 
		.BYTE $FF       ;44 = 
		.BYTE $4B       ;45 = 
		.BYTE $FF       ;46 = 
		.BYTE $FF       ;47 = 
		.BYTE $4F       ;48 = 
		.BYTE $FF       ;49 = 
		.BYTE $50       ;4A = 
		.BYTE $55       ;4B = 
		.BYTE $9B       ;4C = 
		.BYTE $49       ;4D = 
		.BYTE $2D       ;4E = 
		.BYTE $FF       ;4F = 
		.BYTE $56       ;50 = 
		.BYTE $FF       ;51 = 
		.BYTE $43       ;52 = 
		.BYTE $FF       ;53 = 
		.BYTE $FF       ;54 = 
		.BYTE $42       ;55 = 
		.BYTE $58       ;56 = 
		.BYTE $5A       ;57 = 
		.BYTE $24       ;58 = 
		.BYTE $FF       ;59 = 
		.BYTE $23       ;5A = 
		.BYTE $36       ;5B = 
		.BYTE $FF       ;5C = 
		.BYTE $35       ;5D = 
		.BYTE $22       ;5E = 
		.BYTE $21       ;5F = 
		.BYTE $2C       ;60 = 
		.BYTE $20       ;61 = 
		.BYTE $2E       ;62 = 
		.BYTE $4E       ;63 = 
		.BYTE $FF       ;64 = 
		.BYTE $4D       ;65 = 
		.BYTE $3F       ;66 = 
		.BYTE $FF       ;67 = 
		.BYTE $52       ;68 = 
		.BYTE $FF       ;69 = 
		.BYTE $45       ;6A = 
		.BYTE $59       ;6B = 
		.BYTE $FF       ;6C = 
		.BYTE $54       ;6D = 
		.BYTE $57       ;6E = 
		.BYTE $51       ;6F = 
		.BYTE $39       ;70 = 
		.BYTE $FF       ;71 = 
		.BYTE $30       ;72 = 
		.BYTE $27       ;73 = 
		.BYTE $7E       ;74 = 
		.BYTE $38       ;75 = 
		.BYTE $FF       ;76 = 
		.BYTE $FF       ;77 = 
		.BYTE $46       ;78 = 
		.BYTE $48       ;79 = 
		.BYTE $44       ;7A = 
		.BYTE $FF       ;7B = 
		.BYTE $FF       ;7C = 
		.BYTE $47       ;7D = 
		.BYTE $53       ;7E = 
		.BYTE $41       ;7F = 
keycode_to_atascii_len = * - keycode_to_atascii
.error keycode_to_atascii_len != 128

; =============== S U B	R O U T	I N E =======================================

stop_transcripting:
		JSR	op0_new_line
		LDA	#0
		STA	transcripting_control_DF
		RTS
; ---------------------------------------------------------------------------

aDefaultIs:	.BYTE ' (Default is '
def_value_char:	.BYTE '*'
		.BYTE ') >'
aDefaultIsLen = * - aDefaultIs

; =============== S U B	R O U T	I N E =======================================

print_default_prompt:
		CLC
		ADC	#'1'
		STA	def_value_char
		LDX	#<aDefaultIs
		LDA	#>aDefaultIs
		LDY	#aDefaultIsLen
		JMP	print_string_X_lo_A_hi_Y_len

; ---------------------------------------------------------------------------
aPosition0:	.BYTE atari_eol, 'Position 1-', '0'+savegame_count
aPosition0Len = * - aPosition0

aDrive1Or2:	.BYTE atari_eol, 'Drive 1 or 2'
aDrive1Or2Len = * - aDrive1or2

aSaveSummary:	.BYTE atari_eol, atari_eol, 'Position '
position_num_asc: .BYTE '*'
		.BYTE '; Drive #'
drive_num_asc:	.BYTE '*'
		.BYTE '.', atari_eol, 'Are you sure? (Y/N) >'
aSaveSummaryLen = * - aSaveSummary

.if ( SD_ONE_SIDE || SD_TWO_SIDE || ED_ONE_SIDE )
aInsertDiskPrompt: .BYTE atari_eol, 'Insert SD SAVE disk into Drive #'
.elseif( DD_ONE_SIDE )
aInsertDiskPrompt: .BYTE atari_eol, 'Insert DD SAVE disk into Drive #'
.else
	.error
.endif

drive_num_asc2:	.BYTE '*'
		.BYTE '.'
aInsertDiskPromptLen = * - aInsertDiskPrompt

aYes:	.BYTE 'YES', atari_eol
aYesLen = * - aYes

aNo:	.BYTE 'NO', atari_eol
aNoLen = * - aNo

; =============== S U B	R O U T	I N E =======================================

start_position_drive_questions:
		LDX	#<aPosition0
		LDA	#>aPosition0
		LDY	#aPosition0Len
		JSR	print_string_X_lo_A_hi_Y_len

		LDA	position_default_F1
		JSR	print_default_prompt

get_position_loop:
		JSR	get_one_kbd_char
		CMP	#atari_eol
		BEQ	default_save_position
		SEC
		SBC	#'1'
		CMP	#savegame_count
		BCC	correct_save_position
		JSR	bad_beep
		JMP	get_position_loop

default_save_position:
		LDA	position_default_F1

correct_save_position:
		STA	position_temp_F3
		CLC
		ADC	#'1'
		STA	position_num_asc
		STA	position_num_asc2
		STA	position_num_asc3
		JSR	lowlevel_single_char_out
		LDX	#<aDrive1Or2
		LDA	#>aDrive1Or2
		LDY	#aDrive1Or2Len
		JSR	print_string_X_lo_A_hi_Y_len
		LDA	disk_drive_default_F2
		JSR	print_default_prompt

get_drive_loop:
		JSR	get_one_kbd_char
		CMP	#atari_eol
		BEQ	default_drive
		SEC
		SBC	#'1'
		CMP	#2
		BCC	correct_drive_chosen
		JSR	bad_beep
		JMP	get_drive_loop

default_drive:
		LDA	disk_drive_default_F2

correct_drive_chosen:
		STA	disk_drive_temp_F4
		CLC
		ADC	#'1'
		STA	drive_num_asc2
		STA	drive_num_asc
		JSR	lowlevel_single_char_out
		LDX	#<aSaveSummary
		LDA	#>aSaveSummary
		LDY	#aSaveSummaryLen
		JSR	print_string_X_lo_A_hi_Y_len
		LDA	#$FF
		STA	CH

loop_incorrect_input:
		JSR	get_one_kbd_char
		CMP	#'y'
		BEQ	replied_yes
		CMP	#'Y'
		BEQ	replied_yes
		CMP	#atari_eol
		BEQ	replied_yes
		CMP	#'n'
		BEQ	replied_no
		CMP	#'N'
		BEQ	replied_no
		JSR	bad_beep
		JMP	loop_incorrect_input

replied_no:
		LDX	#<aNo
		LDA	#>aNo
		LDY	#aNoLen
		JSR	print_string_X_lo_A_hi_Y_len
		JMP	start_position_drive_questions

replied_yes:
		LDX	#<aYes
		LDA	#>aYes
		LDY	#aYesLen
		JSR	print_string_X_lo_A_hi_Y_len

		LDA	disk_drive_temp_F4
		STA	disk_drive_default_F2
		STA	disk_drive_F5
		INC	disk_drive_F5
		LDX	position_temp_F3
		STX	position_default_F1
		LDA	savegame_sect_lo,X
		STA	disk_sect_lo_EF
		LDA	savegame_sect_hi,X
		STA	disk_sect_hi_F0
		LDX	#<aInsertDiskPrompt
		LDA	#>aInsertDiskPrompt
		LDY	#aInsertDiskPromptLen
		JSR	print_string_X_lo_A_hi_Y_len

wait_for_return_key:
		JSR	op0_new_line

		LDX	#<aPressReturnToContinue
		LDA	#>aPressReturnToContinue
		LDY	#aPressReturnToContinueLen
		JSR	print_string_X_lo_A_hi_Y_len

		JSR	op0_new_line

		LDA	#'>'
		JSR	lowlevel_single_char_out
		LDA	#$FF
		STA	CH

return_still_not_pressed:
		JSR	get_one_kbd_char
		CMP	#atari_eol
		BEQ	locret_2384
		JSR	bad_beep
		JMP	return_still_not_pressed

locret_2384:
		RTS

; ---------------------------------------------------------------------------
aPressReturnToContinue: .BYTE 'Press [RETURN] to continue.'
aPressReturnToContinueLen = * - aPressReturnToContinue

.if SD_TWO_SIDE
aInsertSide:	.BYTE 'Insert Side '
disk_side_atascii:	.BYTE '2'
		.BYTE ' of the STORY disk into'
aInsertSideLen = * - aInsertSide

aDrive1:	.BYTE 'Drive #1.'
aDrive1Len = * - aDrive1
.endif

; =============== S U B	R O U T	I N E =======================================

.if SD_TWO_SIDE
ask_insert_side_1:
		LDA	#'1'
		BNE	loc_23D3

ask_insert_side_2:
		LDA	#'2'

loc_23D3:
		STA	disk_side_atascii
		LDA	#1
		STA	disk_drive_F5

		JSR	op0_new_line

		LDX	#<aInsertSide
		LDA	#>aInsertSide
		LDY	#aInsertSideLen
		JSR	print_string_X_lo_A_hi_Y_len

		JSR	op0_new_line

		LDX	#<aDrive1
		LDA	#>aDrive1
		LDY	#aDrive1Len
		JSR	print_string_X_lo_A_hi_Y_len

		JSR	wait_for_return_key

		LDA	#$FF
		STA	transcripting_control_DF
		RTS
.else
;this just asks for inserting game disk - after game save/load
aInsertStory	.BYTE 'Insert the STORY disk into'
aInsertStoryLen = * - aInsertStory

aDrive1:	.BYTE 'Drive #1.'
aDrive1Len = * - aDrive1

ask_insert_game_disk:
		LDA	#1
		STA	disk_drive_F5

		JSR	op0_new_line

		LDX	#<aInsertStory
		LDA	#>aInsertStory
		LDY	#aInsertStoryLen
		JSR	print_string_X_lo_A_hi_Y_len

		JSR	op0_new_line

		LDX	#<aDrive1
		LDA	#>aDrive1
		LDY	#aDrive1Len
		JSR	print_string_X_lo_A_hi_Y_len

		JSR	wait_for_return_key

		LDA	#$FF
		STA	transcripting_control_DF
		RTS

.endif

; ---------------------------------------------------------------------------

aSavePosition: .BYTE 'Save Position'
byte_2418:	.BYTE atari_eol
aSavePositionLen = * - aSavePosition

aSavingPosition:	.BYTE atari_eol, atari_eol, 'Saving position '
position_num_asc2:	.BYTE '*'
		.BYTE ' ...', atari_eol
aSavingPositionLen = * - aSavingPosition

; =============== S U B	R O U T	I N E =======================================

op0_save:
		JSR	stop_transcripting

		LDX	#<aSavePosition
		LDA	#>aSavePosition
		LDY	#aSavePositionLen
		JSR	print_string_X_lo_A_hi_Y_len

		JSR	start_position_drive_questions

		LDX	#<aSavingPosition
		LDA	#>aSavingPosition
		LDY	#aSavingPositionLen
		JSR	print_string_X_lo_A_hi_Y_len

		.if EXTMEM
		LDA	extmem_map_portbs
		STA	PORTB
		.endif

		LDX	#0

		;save game release info
		LDA	story_hdr_release_hi
		STA	byte_A20,X
		INX

		LDA	story_hdr_release_lo
		STA	byte_A20,X
		INX

		;save stack info
		LDA	stack_pointer_lo_A2
		STA	byte_A20,X
		INX

		LDA	stack_pointer_function_frame_lo_A4
		STA	byte_A20,X
		INX

		.if LARGE_STACK
		LDA	stack_pointer_hi_A3
		STA	byte_A20,X
		INX

		LDA	stack_pointer_function_frame_hi_A5
		STA	byte_A20,X
		INX
		.endif

		.if ZVER >= 5
		LDA	current_fn_argument_count
		STA	byte_A20,X
		INX

		LDA	store_the_result
		STA	byte_A20,X
		INX
		.endif

		;save pc
		LDA	zcode_addr_lo_96
		STA	byte_A20,X
		INX

		LDA	zcode_addr_hi_97
		STA	byte_A20,X
		INX

		LDA	zcode_addr_hihi_98
		STA	byte_A20,X
		;INX

		;saves sector 1
		;save local variables
		LDA	#>local_vars_lo
		STA	read_buffer_hi_EE
		JSR	dsk_save_one_sector
		BCC	save_locals_okay

savegame_failed:
		.if SD_TWO_SIDE
		JSR	ask_insert_side_2
		.else
		JSR	ask_insert_game_disk
		.endif

		.if ZVER = 3
		JMP	predicate_fails
		.else
		LDA	#0
		JMP	store_value_in_A
		.endif

save_locals_okay:

		;saves whole stack
		LDA	#stack_start_page
		STA	read_buffer_hi_EE
		LDX	#stack_pages

save_2:		TXA
		PHA

		JSR	dsk_save_one_sector
		BCS	savegame_failed

		PLA
		TAX
		DEX
		BNE	save_2

		.if EXTMEM
		LDA	#0
		STA	temp2_hi_95
		.else
		LDA	game_base_page_A6
		STA	read_buffer_hi_EE
		.endif

		.if EXTMEM
		LDA	extmem_map_portbs
		STA	PORTB
		.endif

remains_to_save = SAVEGAME_LENGTH - ( 1 + stack_pages )

		LDX	story_hdr_dynamic_hi
		INX

		CPX	#remains_to_save
		BCC	save_1
		LDX	#remains_to_save
save_1:		STX	temp2_lo_94
loop_over_dynamic_memory:
		.if EXTMEM
		LDX	temp2_hi_95
		LDA	extmem_map_pgs,X
		STA	read_buffer_hi_EE
		LDA	extmem_map_portbs,X
		STA	PORTB
		INC	temp2_hi_95
		.endif

		JSR	dsk_save_one_sector
		BCS	savegame_failed
		DEC	temp2_lo_94
		BNE	loop_over_dynamic_memory


		.if SD_TWO_SIDE
		JSR	ask_insert_side_2
		.else
		JSR	ask_insert_game_disk
		.endif

		.if ZVER = 3
		JMP	predicate_succeeds
		.else
		LDA	#1
		JMP	store_value_in_A
		.endif

; ---------------------------------------------------------------------------

aRestorePosition:	.BYTE 'Restore Position', atari_eol
aRestorePositionLen = * - aRestorePosition

aRestoringPosition:	.BYTE atari_eol, atari_eol, 'Restoring position '
position_num_asc3:	.BYTE '*'
		.BYTE ' ...', atari_eol
aRestoringPositionLen = * - aRestoringPosition

; =============== S U B	R O U T	I N E =======================================

op0_restore:
		JSR	stop_transcripting

		LDX	#<aRestorePosition
		LDA	#>aRestorePosition
		LDY	#aRestorePositionLen
		JSR	print_string_X_lo_A_hi_Y_len

		JSR	start_position_drive_questions

		LDX	#<aRestoringPosition
		LDA	#>aRestoringPosition
		LDY	#aRestoringPositionLen
		JSR	print_string_X_lo_A_hi_Y_len

		;temporarily move local vars aside
		LDX	#$1F
loop_store_locals:
		LDA	local_vars_lo,X
		STA	machine_stack,X
		DEX
		BPL	loop_store_locals

		;read local vars from game
		LDA	#>local_vars_lo
		STA	read_buffer_hi_EE
		JSR	dsk_read_one_sector
		BCS	restore_failed

		.if EXTMEM
		LDA	extmem_map_portbs
		STA	PORTB
		.endif

		;compare savegame vs this game release numbers
		LDA	byte_A20	
		CMP	story_hdr_release_hi
		BNE	restore_failed
		LDA	byte_A21
		CMP	story_hdr_release_lo
		BEQ	releases_match


restore_failed:
		;get locals back in place
		LDX	#$1F
loop_restore_locals:
		LDA	machine_stack,X
		STA	local_vars_lo,X
		DEX
		BPL	loop_restore_locals

		.if SD_TWO_SIDE
		JSR	ask_insert_side_2
		.else
		JSR	ask_insert_game_disk
		.endif

		.if ZVER = 3
		JMP	predicate_fails
		.else
		LDA	#0
		JMP	store_value_in_A
		.endif

releases_match:
		.if EXTMEM
		LDA	extmem_map_portbs
		STA	PORTB
		.endif

		LDA	story_hdr_flags2_hi
		STA	temp2_lo_94
		LDA	story_hdr_flags2_lo
		STA	temp2_hi_95

		;read whole stack
		LDA	#stack_start_page
		STA	read_buffer_hi_EE
		LDX	#stack_pages

rest_2:		TXA
		PHA

		JSR	dsk_read_one_sector
		BCS	restore_failed

		PLA
		TAX
		DEX
		BNE	rest_2

		;read whole dynamic memory
		.if EXTMEM
		LDX	#0
		LDA	extmem_map_portbs,X
		STA	PORTB
		LDA	extmem_map_pgs,X
		STA	read_buffer_hi_EE

		.else
		LDA	game_base_page_A6
		STA	read_buffer_hi_EE
		.endif

		JSR	dsk_read_one_sector
		BCS	restore_failed

		;restore flags
		LDA	temp2_lo_94
		STA	story_hdr_flags2_hi
		LDA	temp2_hi_95
		STA	story_hdr_flags2_lo

remains_to_read = SAVEGAME_LENGTH - ( 1 + stack_pages )

		LDA	story_hdr_dynamic_hi
		CMP	#remains_to_read
		BCC	rest_1
		LDX	#remains_to_read-1
rest_1:		STA	temp2_lo_94

		.if EXTMEM
		LDA	#0
		.else
		LDA	game_base_page_A6
		.endif
		STA     temp2_hi_95
		INC	temp2_hi_95

loop_restore_dynamic:
		.if EXTMEM
		LDX	temp2_hi_95
		LDA	extmem_map_pgs,X
		STA	read_buffer_hi_EE
		LDA	extmem_map_portbs,X
		STA	PORTB
		INC	temp2_hi_95
		.endif

		JSR	dsk_read_one_sector
		BCC	lrs1
		JMP	restore_failed
lrs1:		DEC	temp2_lo_94
		BNE	loop_restore_dynamic

		LDX	#2
		;restore stack ptr
		LDA	byte_A20,X
		INX
		STA	stack_pointer_lo_A2

		LDA	byte_A20,X
		INX
		STA	stack_pointer_function_frame_lo_A4

		.if LARGE_STACK
		LDA	byte_A20,X
		INX
		STA	stack_pointer_hi_A3

		LDA	byte_A20,X
		INX
		STA	stack_pointer_function_frame_hi_A5
		.endif

		.if ZVER >= 5
		LDA	byte_A20,X
		INX
		STA	current_fn_argument_count

		LDA	byte_A20,X
		INX
		STA	store_the_result
		.endif

		LDA	byte_A20,X
		INX
		STA	zcode_addr_lo_96

		LDA	byte_A20,X
		INX
		STA	zcode_addr_hi_97

		LDA	byte_A20,X
		INX
		STA	zcode_addr_hihi_98

		;invalidate current cache
		;##TRACE "*invalidate in restore"
		;##TRACE "*zdata invalidate in restore"
		LDA	#0
		STA	zcode_buffer_valid_99
		STA	zdata_buffer_valid_9F

		.if SD_TWO_SIDE
		JSR	ask_insert_side_2
		.else
		JSR	ask_insert_game_disk
		.endif

		.if ZVER = 3
		JMP	predicate_succeeds
		.else
		LDA	#2
		JMP	store_value_in_A
		.endif

; ---------------------------------------------------------------------------

;it's quite possible this is wrong, as some of the combinations may not work together
;not sure how to test them all correctly
.if( SD_ONE_SIDE || SD_TWO_SIDE || ED_ONE_SIDE )
	SAVEGAME_START = 1
	SAVEGAME_LENGTH = $90	;sd $80 sectors
	savegame_count = 5

.elseif( DD_ONE_SIDE )
	.if ZVER = 3
	SAVEGAME_START = 4
	savegame_count = 5
	SAVEGAME_LENGTH = $48
	.else
	SAVEGAME_START = 4
	savegame_count = 3
	SAVEGAME_LENGTH = $EF
	.endif
.else
	.error "wrong"
.endif

POSITION_1 = SAVEGAME_START + 0*SAVEGAME_LENGTH
POSITION_2 = SAVEGAME_START + 1*SAVEGAME_LENGTH
POSITION_3 = SAVEGAME_START + 2*SAVEGAME_LENGTH
POSITION_4 = SAVEGAME_START + 3*SAVEGAME_LENGTH
POSITION_5 = SAVEGAME_START + 4*SAVEGAME_LENGTH

.if savegame_count = 3
	last_save_sector = position_3 + savegame_length - 1

.elseif savegame_count = 5
	last_save_sector = position_5 + savegame_length - 1
.else
	.error "expecting different savegame_count"
.endif

.if last_save_sector > MAX_SECTORS
	.error "Number of sectors overflown! ", last_save_sector, " > ", MAX_SECTORS
.endif

savegame_sect_lo:
		.if savegame_count >= 3
		.BYTE <POSITION_1
		.BYTE <POSITION_2
		.BYTE <POSITION_3
		.endif

		.if savegame_count >= 5
		.BYTE <POSITION_4
		.BYTE <POSITION_5
		.endif

savegame_sect_hi:
		.if savegame_count >= 3
		.BYTE >POSITION_1
		.BYTE >POSITION_2
		.BYTE >POSITION_3
		.endif

		.if savegame_count >= 5
		.BYTE >POSITION_4
		.BYTE >POSITION_5
		.endif

; =============== S U B	R O U T	I N E =======================================

.if EXTMEM
read_to_extmem:	.BYTE 0
.endif

dsk_read_one_game_sector:
		CLD
		LDA	#1
		STA	disk_drive_F5
		LDX	sector_pointer_lo_EB
		STX	disk_sect_lo_EF
		LDA	sector_pointer_hi_EC
		AND	#MAX_STORY_SIZE_HIHI
		STA	disk_sect_hi_F0

		.if SD_TWO_SIDE
		BNE	loc_259F
		CPX	resident_mem_in_pages_A7
		BCS	loc_259F
		.endif

		.if ( SD_ONE_SIDE || SD_TWO_SIDE || ED_ONE_SIDE )
		ASL	disk_sect_lo_EF			;page -> $80 sd sectors = *2
		ROL	disk_sect_hi_F0
		.endif

		LDA	disk_sect_lo_EF
		CLC
sector_patch1:	ADC	#STARTING_STORY_SECTOR		;starting story sector - on disk
		STA	disk_sect_lo_EF

		LDA	disk_sect_hi_F0
sector_patch2:	ADC	#0
		STA	disk_sect_hi_F0
		JMP	dsk_read_one_sector

loc_259F:
		.if SD_TWO_SIDE
		LDA	disk_sect_lo_EF
		SEC
		SBC	resident_mem_in_pages_A7
		STA	disk_sect_lo_EF
		BCS	loc_25AA
		DEC	disk_sect_hi_F0
		
loc_25AA:
		ASL	disk_sect_lo_EF
		ROL	disk_sect_hi_F0
		INC	disk_sect_lo_EF
		BNE	dsk_read_one_sector
		INC	disk_sect_hi_F0
		.endif

dsk_read_one_sector:
		LDA	#$52
		JSR	sio_cmd_two_sectors
		BCS	locret_25E7

		.if EXTMEM
		;ed is always 0
		LDA	read_buffer_lo_ED
		STA	temp_modded_lo_FA

		LDA	read_to_extmem
		BNE	over_extmem1

		LDA	read_buffer_hi_EE
		STA	temp_modded_hi_FB
		JMP	over_extmem2

over_extmem1:
		LDY	read_buffer_hi_EE
		LDA	extmem_map_pgs,Y
		STA	temp_modded_hi_FB
		LDA	extmem_map_portbs,Y
		STA	PORTB
over_extmem2:

		.else
		;ed is always 0
		;EE is be real in no-extmem scenarios
		LDA	read_buffer_lo_ED
		STA	temp_modded_lo_FA

		LDA	read_buffer_hi_EE
		STA	temp_modded_hi_FB
		.endif

		LDY	#0
loop_cpy_read_data:
		LDA	tmp_disk_buffer,Y
		;STA	(read_buffer_lo_ED),Y
		STA	(temp_modded_lo_FA),Y
		INY
		BNE	loop_cpy_read_data
		BEQ	move_sector_ptrs

dsk_save_one_sector:
		LDY	#0

loop_cpy_save_data:
		LDA	(read_buffer_lo_ED),Y
		STA	tmp_disk_buffer,Y
		INY
		BNE	loop_cpy_save_data
		LDA	#$57
		JSR	sio_cmd_two_sectors
		BCS	locret_25E7

move_sector_ptrs:
		INC	read_buffer_hi_EE
		INC	sector_pointer_lo_EB
		BNE	loc_25E0
		INC	sector_pointer_hi_EC

loc_25E0:
		INC	disk_sect_lo_EF
		BNE	loc_25E6
		INC	disk_sect_hi_F0

loc_25E6:
		CLC

locret_25E7:
		RTS

; =============== S U B	R O U T	I N E =======================================

		;a - sio command
sio_cmd_two_sectors:
		STA	DCOMND
		LDA	disk_drive_F5
		STA	DUNIT
		.if( SD_ONE_SIDE || SD_TWO_SIDE || ED_ONE_SIDE )
	
		.elseif DD_ONE_SIDE 
		LDA	#$31
		STA	DDEVIC
		LDA	#0
		STA	DBYTLO
		LDA	#1
		STA	DBYTHI
		.else
			.error "wrong"
		.endif

		LDX	disk_sect_lo_EF
		LDA	disk_sect_hi_F0
		.if !LONG_MEDIA
		CMP	#>MAX_SECTORS
		BCC	correct_sector
		BNE	int_error_C
		CPX	#<MAX_SECTORS
		BCS	int_error_C
		.endif

correct_sector:
		STX	DAUX1
		STA	DAUX2
		LDA	#<tmp_disk_buffer
		STA	DBUFLO
		LDA	#>tmp_disk_buffer
		STA	DBUFHI
.if( SD_ONE_SIDE || SD_TWO_SIDE || ED_ONE_SIDE )
		JSR	DSKINV
.elseif DD_ONE_SIDE
		LDA	#$40
		LDX	DCOMND
		CPX	#$52
		BEQ	isreading
		LDA	#$80
isreading:	
		STA	DSTATS
		JSR	SIOV
.else
	.error "wrong"
.endif
		TYA
		BMI	dsk_op_error

.if( SD_ONE_SIDE || SD_TWO_SIDE || ED_ONE_SIDE )
		INC	disk_sect_lo_EF
		BNE	loc_261A
		INC	disk_sect_hi_F0
.endif

loc_261A:
.if( SD_ONE_SIDE || SD_TWO_SIDE || ED_ONE_SIDE)
		LDA	disk_sect_lo_EF
		STA	DAUX1
		LDA	disk_sect_hi_F0
		STA	DAUX2
		LDA	#<[tmp_disk_buffer + $80]
		STA	DBUFLO
		LDA	#>[tmp_disk_buffer + $80]
		STA	DBUFHI
		JSR	DSKINV
		TYA
		BMI	dsk_op_error
.endif
		CLC
		RTS

dsk_op_error:
		SEC
		RTS

int_error_C:
		LDA	#12
		JMP	display_internal_error


; ---------------------------------------------------------------------------
last_byte:
end_pad_len = [((last_byte-boot_header+$ff)/$100)*$100+boot_header-last_byte]
	:[end_pad_len] .BYTE 0

end_of_boot = *

.echo 'Interpreter memory: ', boot_header+7, "-", last_byte, ". Padding: ", end_pad_len

.if( last_byte >= $4000 && EXTMEM=1 )
.error "interpreter too long"
.endif

.if EXTMEM
.echo 'freemem_start=', 0x80
.else
.echo 'freemem_start=', >story_hdr_begin
.endif
.echo 'freemem_end=', ramtop_page
