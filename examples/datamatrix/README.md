6502 Data Matrix encoder
========================

This projects implements [Data Matrix barcode](http://en.wikipedia.org/wiki/Data_Matrix)
in the [6502](http://en.wikipedia.org/wiki/6502) assembly language.

Supported are square ECC 200 symbol sizes up to 48x48.
Symbol size limits the length of the encoded message and must be selected at compile time:

* 10x10 (max 3 characters)
* 12x12 (max 5 characters)
* 14x14 (max 8 characters)
* 16x16 (max 12 characters)
* 18x18 (max 18 characters)
* 20x20 (max 22 characters)
* 22x22 (max 30 characters)
* 24x24 (max 36 characters)
* 26x26 (max 44 characters)
* 32x32 (max 62 characters)
* 36x36 (max 86 characters)
* 40x40 (max 114 characters)
* 44x44 (max 144 characters)
* 48x48 (max 174 characters)

Compilation
-----------

The routine uses two memory areas:

* `DataMatrix_code` - self-modifying code
* `DataMatrix_data` - uninitialized data, including the input message and the resulting symbol

The size of code and data depends on the symbol size and can be estimated as follows:
* Code always fits in 768 bytes (512 for symbols up to 26x26).
* Data fits in 768 or `256+DataMatrix_SIZE*DataMatrix_SIZE` bytes, whichever is more.

The routine doesn't use zero page. There are no restrictions on the alignment of code or data.

In addition to code and data locations, you must select the desired symbol size:
10, 12, 14, 16, 18, 20, 22, 24, 26, 32, 36, 40, 44 or 48.

So, a valid compilation command-line is:

    xasm datamatrix.asx /l /d:DataMatrix_code=$b600 /d:DataMatrix_data=$b900 /d:DataMatrix_SIZE=20

(escape the dollars if in Unix shell or Makefile).

Source code uses [xasm](https://github.com/pfusik/xasm) syntax.
This cross-assembler includes many original syntax extensions.

Usage
-----

1. Store ASCII message at `DataMatrix_data`.
The message must be terminated with `DataMatrix_EOF` (255)
and short enough to fit in the desired symbol size (see above, the terminator doesn't count).
Please note that the routine will destroy the input message, so you need to recreate it every time.
It is possible to store two consecutive digits in one byte: `129+first_digit*10+second_digit`,
e.g. 129+65 carries identical information to '6','5'.

2. Call the routine:

    jsr DataMatrix_code

3. Get the square array of `DataMatrix_SIZE*DataMatrix_SIZE` bytes starting from
`DataMatrix_data+$100`. Information about the x,y pixel is at `DataMatrix_data+$100+y*DataMatrix_SIZE+x`.
Zero means background color, one means ink color, other values mean a bug in my code (file a report).

4. Use big pixels, high contrast and a border in the background color around the symbol, at least one pixel wide.

If that was not clear enough, you can look at
[example-atari.asx](https://github.com/pfusik/datamatrix6502/blob/master/example-atari.asx).
and [example-atari-gfx.asx](https://github.com/pfusik/datamatrix6502/blob/master/example-atari-gfx.asx).

WTF is 6502?
------------

If you prefer C, Java, C#, JavaScript, ActionScript, Perl or [D](http://dlang.org/)
Data Matrix encoder, see [DataMatrix.ci](https://github.com/pfusik/datamatrix-ci).
