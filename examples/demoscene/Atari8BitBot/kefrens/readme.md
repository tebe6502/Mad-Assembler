# Kefrens Bars in one Twit

This is an example of kefrens bars routine that fits in 133 bytes. This can be fitted in one twit and executed by [Atari8BitBot](https://twitter.com/Atari8BitBot). In this folder the three versions of code is present:

* `kefrens_1st_twt.xsm` - 1st version (every second line is blank)
* `kefrens_interlaced.xsm` - 2nd version (interlaced version)
* `kefrens_final.xsm` - 3rd and final version (no half-lines, no interlace)

I have tried three different approaches, because the video codec can't keep good quality of video when the "scan-lines" are present, the interlace mode, doesn't help also. Only when plain (solid lines) display mode is used, the codec generated a good quality image. But on real hardware, all those modes looks nice and smooth.

To compile this code please use [xasm](https://github.com/pfusik/xasm) assembler (e.g. `xasm kefrens_final.xsm -o kefrens_final.xex`).

How this effect works? This is simpler than it looks. At the start of each frame we clear the line buffer. This "one line buffer" is displayed across whole screen (Thanks do ANTIC display-list that is prepared in this way).
On each scan-line this "one line buffer" is modified (new pixel is added to the buffer), so on each line the buffer contains previous pixels and the new ones. This repeats till the end of screen.
