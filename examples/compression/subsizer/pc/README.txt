README.txt
----------
subsizer 0.6 by Daniel Kahlin (aka tlr), 2017-04-21

subsizer: CBM packer/cruncher

FEATURES

  - fast depack
  - good compression
  - automatic folding allows full mem operation ($0000-$ffff)

Compression is slightly worse than for example exomizer but generally better
than pucrunch.   Decrunch speed is fairly fast.


USAGE

raw:
  # subsizer -r [-o<output>] <file>
mem:
  # subsizer -m [-o<output>] <file>
sfx:
  # subsizer -x [-X[jmp=<addr>][,mem=<mem>][,sei]] [-o<output>] <file>

Loading:
  normal:   <file>[,,[<offs>][,<len>]]
  override: <file>,<addr>[,[<offs>][,<len>]]
  raw:      <file>@<addr>[,[<offs>][,<len>]]


EXAMPLES

$ subsizer -otest.prg file1.prg file2.prg,0x1000
$ subsizer -otest.prg file1.prg,,0x20 file2.prg
$ subsizer file.prg -Xjmp=0x0801,sei


SFX DECRUNCHER

  The self extracting binary options are set with the -X flag.

  header options: (default: normal basic header)
    load=<addr>     - start address of decruncher (implies sysless)
    sysless         - do not begin with a sys line.

  starting options:
    mem=<val>       - $01 value after decrunch   (default: mem=0x37)
    sei             - exit with interrupts disabled.
                      (default: interrupts enabled)
    jmp=<addr>      - jump address after decrunch (default: find sys)

  decruncher options:  (default: dirty if start address is below $0400)
    clean           - "clean" decruncher.  A little slower but avoids most
                      of zp and other system areas.  Can crunch $0400-$ffff.
    dirty           - "dirty" decruncher.  Much faster but costs a few
                      bytes more due to inlining.  Will clobber most of zp
                      + stack.  Can crunch $0200-$ffff.

  folding options:  (default: automatically fold if required)
    fold=<addr>     - fold data below <addr> into the RLE areas higher up
                      before crunching.  This allows $0000-$ffff operation
                      for any decruncher.
    nofold          - do not fold.


COMPARISON

The statistics for executable decrunchers below are on two of the files
originally selected as test corpus by j0x for his unreleased cruncher.

source file: "zorrounpacked.prg" 54105 (214 blks)
(Remember's crack of Zorro (Data East) including intro. Not (pre-)compressed.)

  sorted on size:
                                               crunch       sfx
    cruncher   size  (blks)   left    gain   time   mem     time
    --------------------------------------------------------------
         alz:  30095 (119)   55.62%  44.38%  0.97s  1.32M   76.04s
      exo209:  30690 (121)   56.72%  43.28%  1.64s  34.28M  9.19s
      sbsz06:  30713 (121)   56.77%  43.23%  2.16s  36.27M  7.59s
    sbsz06-d:  30724 (121)   56.79%  43.21%  2.13s  37.05M  5.68s
      sbsz05:  30756 (122)   56.85%  43.15%  1.97s  37.44M  7.32s
    sbsz05-d:  30777 (122)   56.88%  43.12%  1.95s  37.29M  5.58s
       lzmpi:  32101 (127)   59.33%  40.67%  1.50s  12.75M  14.71s
     pucrn-d:  32135 (127)   59.39%  40.61%  0.07s  2.01M   10.16s
     pucrn-s:  32195 (127)   59.50%  40.50%  0.01s  1.75M   12.65s
       pucrn:  32219 (127)   59.55%  40.45%  0.01s  1.75M   9.94s
     pucrn-f:  32242 (127)   59.59%  40.41%  0.01s  1.75M   9.17s
    bitnax06:  33060 (131)   61.10%  38.90%  0.03s  1.11M   4.33s
    doynam11:  33154 (131)   61.28%  38.72%  0.05s  1.08M   4.46s
        bb20:  33301 (132)   61.55%  38.45%  0.02s  2.60M   7.27s
        bb11:  35227 (139)   65.11%  34.89%  0.15s  0.71M   9.82s
    --------------------------------------------------------------

  sorted on sfx time:
                                               crunch       sfx
    cruncher   size  (blks)   left    gain   time   mem     time
    --------------------------------------------------------------
    bitnax06:  33060 (131)   61.10%  38.90%  0.03s  1.11M   4.33s
    doynam11:  33154 (131)   61.28%  38.72%  0.05s  1.08M   4.46s
    sbsz05-d:  30777 (122)   56.88%  43.12%  1.95s  37.29M  5.58s
    sbsz06-d:  30724 (121)   56.79%  43.21%  2.13s  37.05M  5.68s
        bb20:  33301 (132)   61.55%  38.45%  0.02s  2.60M   7.27s
      sbsz05:  30756 (122)   56.85%  43.15%  1.97s  37.44M  7.32s
      sbsz06:  30713 (121)   56.77%  43.23%  2.16s  36.27M  7.59s
     pucrn-f:  32242 (127)   59.59%  40.41%  0.01s  1.75M   9.17s
      exo209:  30690 (121)   56.72%  43.28%  1.64s  34.28M  9.19s
        bb11:  35227 (139)   65.11%  34.89%  0.15s  0.71M   9.82s
       pucrn:  32219 (127)   59.55%  40.45%  0.01s  1.75M   9.94s
     pucrn-d:  32135 (127)   59.39%  40.61%  0.07s  2.01M   10.16s
     pucrn-s:  32195 (127)   59.50%  40.50%  0.01s  1.75M   12.65s
       lzmpi:  32101 (127)   59.33%  40.67%  1.50s  12.75M  14.71s
         alz:  30095 (119)   55.62%  44.38%  0.97s  1.32M   76.04s
    --------------------------------------------------------------


source file: "tunnel.prg" 59394 (234 blks)
(Demopart containing lots of unrolled loops.)

  sorted on size:
                                               crunch       sfx
    cruncher   size  (blks)   left    gain   time   mem     time
    --------------------------------------------------------------
         alz:  19384 (77)    32.64%  67.36%  0.71s  1.34M   63.32s
      sbsz06:  22098 (88)    37.21%  62.79%  2.42s  70.79M  6.08s
    sbsz06-d:  22109 (88)    37.22%  62.78%  2.41s  72.32M  4.48s
      exo209:  22161 (88)    37.31%  62.69%  3.72s  31.59M  7.74s
      sbsz05:  22192 (88)    37.36%  62.64%  1.68s  71.47M  5.95s
    sbsz05-d:  22213 (88)    37.40%  62.60%  1.68s  70.36M  4.48s
       lzmpi:  23104 (91)    38.90%  61.10%  1.25s  11.14M  11.58s
     pucrn-d:  24487 (97)    41.23%  58.77%  0.08s  2.03M   8.65s
     pucrn-s:  24834 (98)    41.81%  58.19%  0.01s  2.01M   10.42s
       pucrn:  24858 (98)    41.85%  58.15%  0.02s  2.01M   8.50s
     pucrn-f:  24881 (98)    41.89%  58.11%  0.02s  2.01M   7.59s
    bitnax06:  25156 (100)   42.35%  57.65%  0.24s  1.16M   4.00s
    doynam11:  25160 (100)   42.36%  57.64%  0.34s  1.13M   4.12s
        bb20:  25244 (100)   42.50%  57.50%  0.03s  2.61M   6.60s
        bb11:  26782 (106)   45.09%  54.91%  0.12s  0.71M   8.97s
    --------------------------------------------------------------

  sorted on sfx time:
                                               crunch       sfx
    cruncher   size  (blks)   left    gain   time   mem     time
    --------------------------------------------------------------
    bitnax06:  25156 (100)   42.35%  57.65%  0.24s  1.16M   4.00s
    doynam11:  25160 (100)   42.36%  57.64%  0.34s  1.13M   4.12s
    sbsz05-d:  22213 (88)    37.40%  62.60%  1.68s  70.36M  4.48s
    sbsz06-d:  22109 (88)    37.22%  62.78%  2.41s  72.32M  4.48s
      sbsz05:  22192 (88)    37.36%  62.64%  1.68s  71.47M  5.95s
      sbsz06:  22098 (88)    37.21%  62.79%  2.42s  70.79M  6.08s
        bb20:  25244 (100)   42.50%  57.50%  0.03s  2.61M   6.60s
     pucrn-f:  24881 (98)    41.89%  58.11%  0.02s  2.01M   7.59s
      exo209:  22161 (88)    37.31%  62.69%  3.72s  31.59M  7.74s
       pucrn:  24858 (98)    41.85%  58.15%  0.02s  2.01M   8.50s
     pucrn-d:  24487 (97)    41.23%  58.77%  0.08s  2.03M   8.65s
        bb11:  26782 (106)   45.09%  54.91%  0.12s  0.71M   8.97s
     pucrn-s:  24834 (98)    41.81%  58.19%  0.01s  2.01M   10.42s
       lzmpi:  23104 (91)    38.90%  61.10%  1.25s  11.14M  11.58s
         alz:  19384 (77)    32.64%  67.36%  0.71s  1.34M   63.32s
    --------------------------------------------------------------


STANDALONE

The statistics for the stand alone decruncher below is run on the
"Pearls for Pigs" benchmark as selected by WVL together with his LZWVL
compressor.  A simple get byte from memory in reverse routine is used and
included in the timing figures.

                                        duration      outspd    inspd
     file       size  (blks)   left   cycles  frms  k/s   cy/b  cy/b
    ------------------------------------------------------------------
     pfp1.bin:  2961 (12)     26.90%  724217  36.8  14.6  65.8  244.6
     pfp2.bin:  2201 (9)      44.26%  414274  21.1  11.5  83.3  188.2
     pfp3.bin:  1786 (8)      45.23%  308675  15.7  12.3  78.2  172.8
     pfp4.bin:  3438 (14)     49.00%  613097  31.2  11.0  87.4  178.3
     pfp5.bin:  19631 (78)    56.48%  3497850 178.0 9.6   100.6 178.2
     pfp6.bin:  8407 (34)     26.60%  1803984 91.8  16.9  57.1  214.6
     pfp7.bin:  8768 (35)     43.00%  1661112 84.5  11.8  81.5  189.5
     pfp8.bin:  3086 (13)     54.02%  500954  25.5  11.0  87.7  162.3
     pfp9.bin:  5313 (21)     59.30%  934362  47.5  9.2   104.3 175.9
    ------------------------------------------------------------------


INSPIRATION
  - the neverending rants of Charles Bloom
  - Exomizer / Magnus Lind
  - Pucrunch / Pasi Ojala
  - doynax lz + bitnax / Doynax & Bitbreaker
  - ByteBoiler / Oneway
  - Cruelcrunch / Galleon
  - Bitimploder / PET
  - Time Cruncher / Matcham
  - Cardcruncher / 1001
  ... and many more!


HISTORY

subsizer 0.6, 2017-04-21
  - improved first pass cost model
  - cleaned up verbose output a bit
  - saved 10 bytes in the dirty sfx decruncher
  - added stand alone decruncher source

subsizer 0.5.1, 2017-03-21
  - added LICENSE.txt
  - give error if no end marker can be found.
  - got rid of a few warnings as reported by soci.
  - fixed issue with uninitialized memory as reported by compyx.
  - added decruncher source due to popular demand.  well, only bitbreaker. :)
    (caution: encoding may change between versions)

subsizer 0.5, 2017-03-18
  - implemented working folding, full mem crunching possible
  - working loadback and sysless
  - implemented memory crunch
  - BUG: corrected problem with $0200 decrunch and a large safeuncr together
    with the dirty decruncher. 

subsizer 0.4, 2015-11-20
  - added dirty decruncher ($0200-$ffff)
  - improved decrunch speed a lot.

subsizer 0.3, 2015-09-14
  - first somewhat complete version



eof
