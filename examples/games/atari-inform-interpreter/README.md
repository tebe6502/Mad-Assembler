
# atari-inform-interpreter

#### Overview:
This repository hosts an *Infocom* Z-Machine interpreter for Atari systems. The project began by disassembling
 the latest official version G two-side interpreter, originally sourced from one of the latest Atari 8-bit *Infocom*
 releases, Plundered Hearts. Subsequent updates have expanded its compatibility to run official Z4 and Z5 games,
 though Z6 games (Arthur, Journey, Shogun & Zork Zero) are not supported. Additionally, Z7 & Z8 story files are compatible.

#### Purpose:
This interpreter empowers Atari users to experience official Z4 & Z5 games by *Infocom,* previously unavailable
 on this platform. It also opens the door to a wide array of modern homebrew games crafted in the Inform language..

#### Projects using this code:
This is a multi-menu containing all original Infocom games (except 4 Z6 games):

https://forums.atariage.com/topic/353724-the-incomplete-works-of-infocom-inc/

This is an online generator allowing to upload story file from versions 3, 4, 5, 7 and 8, and generates ZIP file
with all possible interpreter combinations in ATR format.

https://forums.atariage.com/topic/354888-infocoms-z-machine-atr-generator/

#### Licensing:
This code is derived from the work of others without their permission, so no specific licensing terms are 
imposed on it. However, all the portions I added or rewrote are placed in the public domain.

#### Source package structure:
Main code is in boot.asm, which contains all common code and many conditional assembly commands for
extended memory, large stack and disk formats. This is the only source which should be assembled, as other
asm files are directly included (despite their asm extensions).

The files drv_\*.asm and drv_\*.fnt are included depending on VIDEO symbol setting. Asm files contain code for
each video driver, using unified interface. FNT files are the binary images of the fonts, sourced from 
various other programs and modified for use with this package.

Release notes (sometimes quite verbose) are in the beginning of boot.asm file.

#### Building:
To compile the code, use MADS and configure various command-line settings:
 - selection of disk format: SD_ONE_SIDE, SD_TWO_SIDE, ED_ONE_SIDE, DD_ONE_SIDE, LONG_MEDIA
 - selection of Z-Machine: ZVER=X, where X is 3, 4, 5, 7, 8
 - selection of video mode: VIDEO=X, where X could be
   - 1 = hardware 40 column mode (fast, low memory requirements)
   - 2 = VBXE mode (fast, low memory requirements, best for Z4+ games)
   - 3 = software 80 column mode (medium speed, high memory requirements)
   - 4 = software 64 column mode (medium speed, high memory requirements)
 - selection of memory accesses: EXTMEM=X (0 for 48KB base memory, 1 for 130XE compatible extended memory)
 - selection of size of stack: LARGE_STACK=X, where 0 means using 2 pages (256 words) stack, 1 means 8
 pages (1024 words) stack. Large stack is recommended for Z4+ games.

Example build command:

    mads boot.asm -d:DD_ONE_SIDE=1 -d:LONG_MEDIA=1 -d:VIDEO=4 -d:ZVER=4 -d:LARGE_STACK=1 -d:EXTMEM=1 -t:boot.lab -l:boot.lst

This example builds **boot.obx**, which should be placed on a double-density ATR image of 'any' 
non-standard size. It uses a software 64-column driver, a large stack, extended memory, and supports Z4 games.
Adding the story file and necessary ATR headers is the next step, left as an exercise for the user.

Running the code in Altirra with symbols and source code view:

    altirra64.exe /debugcmd:".loadsym boot.lab" /debugcmd:".loadsym boot.lst" /debugcmd ".sourcemode on" test.atr

#### Side note:
This project represents my first 'large' assembly project for 6502. I haven't worked on Atari programming for over two 
decades, and even in the eighties, my subroutines were at most 100 instructions long. Expect errors and clumsiness, 
especially considering I no longer possess any Atari hardware for testing. You've been warned.

#### Contributing:
Feel free to ask any questions, create pull requests etc. It'd be great if you'd have first created the testing environment
capable of running tests on Czech and/or other testing suites.

#### Links:
[MADS Assembler](https://github.com/tebe6502/Mad-Assembler/releases)

[MADS Assembler English Manual](https://mads.atari8.info/mads_eng.html)

[Altirra](https://www.virtualdub.org/altirra.html)

[Annotated Z-Machine Standards document v1.1](https://zspec.jaredreisinger.com/)

[Inform6](https://github.com/DavidKinder/Inform6/releases)

[PunyInform Library](https://github.com/johanberntsson/PunyInform/releases)

Testing suites: [Czech](http://ifarchive.org/if-archive/infocom/interpreters/tools/czech_0_8.zip), [Praxix](https://ifarchive.org/if-archive/infocom/interpreters/tools/praxix.zip), [Etude](https://ifarchive.org/if-archive/infocom/interpreters/tools/etude.tar.Z), [Strictz](https://ifarchive.org/if-archive/infocom/interpreters/tools/strictz.inf).

[Z-Tools](http://www.inform-fiction.org/zmachine/ztools.html)

#### Special Thanks To:
- Avery Lee for the Altirra emulator
- Graham Nelson for contributions to Inform and Z-Machine documentation
- Authors of Z-Machine testing suites like Czech, Praxix, Etude, and others
- Mark Howell & Matthew Russotto for ZTools
- Authors of MADS
- Betatesters of this code
