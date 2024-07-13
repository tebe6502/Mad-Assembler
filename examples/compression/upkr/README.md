6502 unpacker for Upkr
======================

This is a [Upkr](https://github.com/exoticorn/upkr) unpacker in 6502 assembly language.

Compilation
-----------

Use [MADS](http://mads.atari8.info) or [xasm](https://github.com/pfusik/xasm).

Three memory areas are used:

* `unupkr` - 218 bytes of code, not modified (can be put in ROM)
* `unupkr_probs` - 319 bytes of uninitialized data (place on page boundary for smallest and fastest code)
* `unupkr_zp` - 15 bytes of zero-page variables

[unupkr.asx](unupkr.asx) uses `opt ?+`. If you use `?`-prefixed
labels in MADS, you might want to follow the include with `opt ?-`.

Usage
-----

The unpacked assumes that the compressed and the uncompressed data fit in the memory. 
Before calling `unupkr`, set the locations in the zero-page variables:

    lda #<packed_data
    sta unupkr_zp
    lda #>packed_data
    sta unupkr_zp+1
    lda #<unpacked_data
    sta unupkr_zp+2
    lda #>unpacked_data
    sta unupkr_zp+3
    jsr unupkr

As the compressed data is read sequentially and only once, it is possible to overlap
the compressed and uncompressed data. That is, the data being uncompressed can be stored
in place of some compressed data which has been already read.

See [test.asx](test.asx) for an example for Atari 8-bit.

Acceleration
------------

The routine requires 8-bit by 8-bit multiplication.

For small, portable and slow code, define `unupkr_mul` as zero.
The multiplication will be performed with a standard 6502 loop.

For faster execution, point `unupkr_mul` to a temporary page-aligned 2 KB area.
The code will grow to 296 bytes, become self-modifying, but execute about 50% faster.
As a bonus, you can use the lookup tables for fast multiplication in your code
after the routine returns.

[Atari Lynx](https://en.wikipedia.org/wiki/Atari_Lynx),
[SNES](https://en.wikipedia.org/wiki/Super_Nintendo_Entertainment_System)
and [X65](https://x65.zone)
all have hardware multiply. Define `unupkr_mul` to a magic value to take advantage of it.

| Platform   | `unupkr_mul` | Multiplication           |
| ---------- | ------------:| ------------------------ |
| any 6502   |            0 | slow                     |
| any 6502   |        $hh00 | with a 2 KB lookup table |
| Atari Lynx |        -1989 | Suzy                     |
| SNES       |       -$5a22 | Ricoh 5A22               |
| X65        |          -65 | RIA                      |

Compression
-----------

Download the packer from https://github.com/exoticorn/upkr

Use as follows:

    upkr -9 --big-endian-bitstream --invert-new-offset-bit --invert-continue-value-bit --simplified-prob-update INPUT_FILE OUTPUT_FILE

If `OUTPUT_FILE` is skipped, it defaults to `INPUT_FILE.upk`.

License
-------

This code is licensed under the standard zlib license.

Copyright (C) 2024 Piotr '0xF' Fusik

This software is provided 'as-is', without any express or implied
warranty.  In no event will the authors be held liable for any damages
arising from the use of this software.

Permission is granted to anyone to use this software for any purpose,
including commercial applications, and to alter it and redistribute it
freely, subject to the following restrictions:

1. The origin of this software must not be misrepresented; you must not
   claim that you wrote the original software. If you use this software
   in a product, an acknowledgment in the product documentation would be
   appreciated but is not required.

2. Altered source versions must be plainly marked as such, and must not be
   misrepresented as being the original software.

3. This notice may not be removed or altered from any source distribution.
