# ZX02: 6502 optimized compression

This is a modified version of the [ZX0](https://github.com/einar-saukas/ZX0)
and [ZX1](https://github.com/einar-saukas/ZX1) compressors to make the
decompressor smaller and faster on a 6502.

The intended use is compressing data up to about 16kB, or where the
decompressor size should be as small as possible.

**The compression format is not compatible with ZX0**


## Features

Compared to ZX0, the differences are:

* The Elias gamma codes are limited to 8 bits (from 1 to 256). This makes
  decoding simpler and faster in the 6502, as all registers are 8-bit.

* Allowed to encode matches with 1 byte length. This is needed as the encoder
  can't output more than 256 literal bytes, so at least one match is needed to
  separate two literal runs. This has the added advantage of allowing new
  match lengths for the repeated offset matches.

* Offsets are stored as positive integers (minus one). This is faster in the
  6502 because a SBC instruction can subtract one more than the value.

* The Elias gamma codes are stored with a 0 bit at the end.

* It is possible to start with any initial offset, the 6502 decoders included
  assume initial offset 1, but changing it does not make the decoder bigger.

With the above changes, compared with the original `ZX02` have:

* Worst case expansion for random data is bigger than the original, 1.01% for
  `ZX02` compared with 0.8% for `ZX0`

* Compression for long repeated runs is also lower, original can encode runs
  of 1K with 4 bytes, we need 12 bytes.

* Code and 16 bit data can compress a lot more than with the original, as it
  is possible to change the offset at any place in the input.

So, this compressor is better suited to smaller data, and specially when you
need the de-compressor code to be as small as possible.

In the `ZX1` mode, in addition to the changes above, the format also differs on
how the offsets are stored:

 * For offsets up to 127, the offset is stored as one byte, multiplied by 2.

 * For offsets greater than 127, two bytes are stored, the first byte is the
   high part of the offset (with the bit 0 set) and the second byte is the
   low part of the offset.


## 6502 decompressors

There are three 6502 assembly decoders, all with ROM-able code and using 8
bytes of zero-page:

* Fast and small decoder, 138 bytes: [zx02-optim.asm](6502/zx02-optim.asm)
  **This is the recommended decompressor for most users**
* Smallest decoder, 130 bytes: [zx02-small.asm](6502/zx02-small.asm)
* Faster decoder, 175 bytes: [zx02-fast.asm](6502/zx02-fast.asm)


## C decompressor

There is a C decompressor command `dzx02` that supports all variations of the
format, including starting offsets and backward encode/decode.


## Downloads

You can download pre-compiled compressor and decompressor binaries in the
[GitHub releases area](https://github.com/dmsc/zx02/releases/).


## Compressor usage

The compressor accepts the following options:

### Standard Options

* **-f**

  Force overwrite of output file if it exists already.

* **-q**

  Use a quick non-optimal compression, useful during development to avoid
  waiting for the compression of long files.

* **-1**

  Compress in the `ZX1` mode, this is a simple format that sacrifices about
  1.5% compression but decodes faster.


### Advanced Compression Options

* **-p _n_**

  Skip the first `n` bytes of the input file when compressing, but use it as a
  *dictionary* for the following data. This is useful to make the compressed
  file smaller if you have fixes data already in memory just before the data to
  decompress.

* **-o _n_**

  Use `n` as starting offset. The standard decompressor uses the value `1` as
  starting offset for matches - this is a good overall value, but certain files
  could compress better with a different value - for example, 16 bit data could
  benefit using a starting offset of `2`.

  To decompress a file compressed with this option, you need to alter the
  decompressor code, in the `zx0_ini_block` the first byte is the starting
  offset minus 1.


### Options incompatible with standard decompressor

* **-b**

  Compress *backwards*, from the end of the file to the start.  This needs a
  decompressor that also reads the data from the end, would probably be bigger
  and slower in 6502 assembly, so it is not supported in the ASM code.

* **-s**

  Use shorted Elias codes. This produces files that are very slightly smaller,
  by limiting the Elias gamma code lengths - but the decompressor would be
  bigger.

* **-e**

  Inverted Elias code end bit. This option changes the format so that a `1` bit
  ends the Elias gamma codes - the default was chosen to make the 6502 decoder
  one byte shorter.

