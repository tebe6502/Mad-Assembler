" Vim syntax file for Mad Assembler
" Language: mads
" Maintainer: Jakub Skrzypnik <jot.skrzyp@gmail.com>
" Inspired and initally based on vim-xasm
" Some fragments are snippets from ACME, ca65 or ATasm syntaxes, heavily
" modified

" TODO: Add indentation guide

if version < 600                     
    syntax clear                       
elseif exists("b:current_syntax")    
    finish                             
endif                                

let s:cpo_save = &cpo                
set cpo&vim                          


syn case ignore

" syn match madsWord "\h\w*" " Prevent Number from matching inside word
syn region madsComment start="/\*" end="\*/" contains=madsTodo
syn region madsComment start="//" end="$" keepend contains=madsTodo
syn region madsComment start=";" end="$" keepend  contains=madsTodo

syn match madsDirective "\.macro\>"
syn match madsDirective "\.endm\>" 
syn match madsDirective "\.proc\>" 
syn match madsDirective "\.endp\>" 
syn match madsDirective "\.rept\>" 
syn match madsDirective "\.endr\>" 
syn match madsDirective "\.exit\>" 
syn match madsDirective "\.local\>" 
syn match madsDirective "\.endl\>" 
syn match madsDirective "\.struct\>" 
syn match madsDirective "\.ends\>" 
syn match madsDirective "\.error\>" 
syn match madsDirective "\.printf\>"  
syn match madsDirective "\.if\>" 
syn match madsDirective "\.else\>"  
syn match madsDirective "\.elseif\>" 
syn match madsDirective "\.endif\>" 
syn match madsDirective "\.byte\>" 
syn match madsDirective "\.word\>" 
syn match madsDirective "\.long\>" 
syn match madsDirective "\.dword\>" 
syn match madsDirective "\.or\>" 
syn match madsDirective "\.and\>" 
syn match madsDirective "\.xor\>" 
syn match madsDirective "\.not\>" 
syn match madsDirective "\.ds\>" 
syn match madsDirective "\.dbyte\>" 
syn match madsDirective "\.def\>" 
syn match madsDirective "\.array\>" 
syn match madsDirective "\.enda\>" 
syn match madsDirective "\.hi\>" 
syn match madsDirective "\.lo\>" 
syn match madsDirective "\.get\>" 
syn match madsDirective "\.put\>" 
syn match madsDirective "\.sav\>" 
syn match madsDirective "\.pages\>" 
syn match madsDirective "\.endpg\>" 
syn match madsDirective "\.reloc\>" 
syn match madsDirective "\.extrn\>" 
syn match madsDirective "\.public\>" 
syn match madsDirective "\.var\>" 
syn match madsDirective "\.reg\>" 
syn match madsDirective "\.while\>" 
syn match madsDirective "\.endw\>" 
syn match madsDirective "\.by\>" 
syn match madsDirective "\.wo\>" 
syn match madsDirective "\.he\>" 
syn match madsDirective "\.en\>" 
syn match madsDirective "\.sb\>" 
syn match madsDirective "\.test\>" 
syn match madsDirective "\.endt\>" 
syn match madsDirective "\.switch\>"  
syn match madsDirective "\.case\>" 
syn match madsDirective "\.endsw\>" 
syn match madsDirective "\.lend\>" 
syn match madsDirective "\.pend\>" 
syn match madsDirective "\.aend\>" 
syn match madsDirective "\.wend\>" 
syn match madsDirective "\.tend\>" 
syn match madsDirective "\.send\>" 
syn match madsDirective "\.fl\>" 
syn match madsDirective "\.symbol\>" 
syn match madsDirective "\.link\>" 
syn match madsDirective "\.global\>" 
syn match madsDirective "\.globl\>" 
syn match madsDirective "\.adr\>" 
syn match madsDirective "\.len\>" 
syn match madsDirective "\.mend\>" 
syn match madsDirective "\.pgend\>" 
syn match madsDirective "\.rend\>" 
syn match madsDirective "\.using\>" 
syn match madsDirective "\.use\>" 
syn match madsDirective "\.echo\>" 
syn match madsDirective "\.align\>" 
syn match madsDirective "\.zpvar\>" 
syn match madsDirective "\.enum\>" 
syn match madsDirective "\.ende\>" 
syn match madsDirective "\.eend\>" 
syn match madsDirective "\.elif\>" 
syn match madsDirective "\.exitm\>" 
syn match madsDirective "\.nowarn\>" 
syn match madsDirective "\.segdef\>" 
syn match madsDirective "\.segment\>" 
syn match madsDirective "\.endseg\>" 
syn match madsDirective "\.sizeof\>" 
syn match madsDirective "\.filesize\>" 
syn match madsDirective "\#IF\>" 
syn match madsDirective "\#ELSE\>" 
syn match madsDirective "\#END\>" 
syn match madsDirective "\#WHILE\>" 
syn match madsDirective "\#CYCLE\>" 

syn keyword madsOpCode ADC AND ASL BCC BCS BEQ BIT BMI BNE BPL
syn keyword madsOpCode BRK BVC BVS CLC CLD CLI CLV CMP CPX CPY
syn keyword madsOpCode DEC DEX DEY EOR INC INX INY JMP JSR LDA
syn keyword madsOpCode LDX LDY LSR NOP ORA PHA PHP PLA PLP ROL
syn keyword madsOpCode ROR RTI RTS SBC SEC SED SEI STA STX STY
syn keyword madsOpCode TAX TAY TSX TXA TXS TYA
syn keyword madsIllegalOp ASO RLN LSE RRD SAX LAX DCP ISB ANC ALR
syn keyword madsIllegalOp ARR ANE ANX SBX LAS SHA SHS SHX SHY NPO
syn keyword madsIllegalOp CIM

syn keyword mads16OpCode STZ SEP REP TRB TSB BRA COP MVN MVP PEA
syn keyword mads16OpCode PHB PHD PHK PHX PHY PLB PLD PLX PLY RTL
syn keyword mads16OpCode STP TCD TCS TDC TSC TXY TYX WAI WDM XBA
syn keyword mads16OpCode XCE DEA INA BRL JSL JML PER PEI

syn keyword madsVirtOp ADD INW JCC JCS JEQ JMI JNE JPL JVC JVS
syn keyword madsVirtOp MVA MVX MVY MWA MWX MWY RCC RCS REQ RMI
syn keyword madsVirtOp RNE RPL RVC RVS SCC SCS SEQ SMI SNE SPL
syn keyword madsVirtOp SUB SVC SVS ADB SBB ADW SBW PHR PLR INL
syn keyword madsVirtOp IND DEW DEL DED CPB CPW CPL CPD

syn keyword madsPreProc DTA EIF ELI ELS END EQU ERT ICL IFT INI
syn keyword madsPreProc INS OPT ORG RUN BLK END SET EXT SIN COS
syn keyword madsPreProc RND NMB RMB LMB

syn keyword madsRegister x y a

" Not officially standarized, but very helpful sometimes "
syn keyword madsTodo contained TODO FIXME XXX DANGER NOTE NOTICE BUG

syn match madsLabel      "^[a-z_][a-z0-9_]*"
syn match madsLocalLabel      "^?[a-z_][a-z0-9_]*"
syn match madsAnonLabel "@[+-]\="

syn match decNumber     "\<\d\+\>"        
syn match hexNumber     "\$\x\+\>"        
syn match binNumber     "%[01]\+\>"       
syn match madsImmediate      "#\$\x\+\>"   
syn match madsImmediate      "#\d\+\>"     
syn match madsImmediate      "<\$\x\+\>"   
syn match madsImmediate      "<\d\+\>"     
syn match madsImmediate      ">\$\x\+\>"   
syn match madsImmediate      ">\d\+\>"     
syn match madsImmediate      "#<\$\x\+\>"  
syn match madsImmediate      "#<\d\+\>"    
syn match madsImmediate  "#>\$\x\+\>" 
syn match madsImmediate  "#>\d\+\>"   


syn match madsTrailingSpace " \+$"
syn match madsRepeat ":[0-9]\+"
syn region madsString start=/[cd]\?'/ end=/'/
syn region madsString start=/[cd]\?"/ end=/"/

hi def link madsComment Comment
hi def link decNumber Number
hi def link hexNumber Number
hi def link binNumber Number
hi def link madsImmediate Number
hi def link madsRegister Number
hi def link madsIndex Type
hi def link madsTrailingSpace Error
hi def link madsLabel Identifier
hi def link madsLocalLabel Macro
hi def link madsAnonLabel Macro
hi def link madsOpCode Keyword
hi def link madsIllegalOp Underlined
hi def link madsDirective Conditional
hi def link mads16OpCode Keyword
hi def link madsVirtOp PreProc
hi def link madsPreProc Statement
hi def link madsOperator PreProc
hi def link madsTodo Todo
hi def link madsDirective PreProc
hi def link madsRepeat PreProc
hi def link madsString String

let b:current_syntax = "mads"
let &cpo = s:cpo_save
unlet s:cpo_save
