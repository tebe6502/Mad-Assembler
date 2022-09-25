ST2VBXE
=======

ST2VBXE shows pictures in formats native to
[Atari ST](http://en.wikipedia.org/wiki/Atari_ST)
and [Atari Falcon](http://en.wikipedia.org/wiki/Atari_Falcon)
on an [Atari 8-bit](http://en.wikipedia.org/wiki/Atari_8-bit_family)
enhanced with the [VBXE video card](http://spiflash.org/node/10).

Supported formats:

* *.PI1 = "DEGAS", 320x200, 16 colors from 4096
* *.PI2 = "DEGAS", 640x200, 4 colors from 4096
* *.PI3 = "DEGAS", 640x400, black and white
* *.DOO = "Doodle", 640x400, black and white
* *.NEO = "NEOchrome", any of the above resolutions
* *.PI4, *.PI9 = "Fuckpaint", 320x200, 256 colors from 262144
* *.DG1 = "DuneGraph", 320x200, 256 colors from 262144

This is my first code for VBXE.
The image filename must be passed on the command line.
(tested with SpartaDOS, DOS II+/D, MyDOS)

Cross-assemble with [xasm](https://github.com/pfusik/xasm).

If you want to view the above formats (plus three hundred others)
on a more popular platform such as Windows, Android, macOS or Linux,
try my other project called [RECOIL](http://recoil.sourceforge.net/).
