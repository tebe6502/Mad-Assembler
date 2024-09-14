## @Atari8BitBot assembly code examples

Normally I use the [xasm](https://github.com/pfusik/xasm) cross-assembler for my Atari 8-bit projects. But in this case because the bot uses Atari Assembler Editor to compile and execute the code I decided to use [OMC65](https://github.com/pkali/omc65) assembler from Our 5oft because this cross-assembler have the syntax compatible with MAC/65 Macro assembler, that is very similar to the Atari Assembler Editor used by [Atari8BitBot](https://atari8bitbot.com/). This gives me a possibility to compile and test code before posting it to the twitter bot.

To compile code use the following command line: `omc fire.m65 fire.xex`,  then the `.xex` can be run from [Atari800](https://atari800.github.io/) emulator under Linux, or [Altirra](http://virtualdub.org/altirra.html) emulator under Windows enviroment.

The code in this repo is different form that I'm posting to the Twitter bot. The code here is more commented and not so hard optimized. I hope this will help understand the code and some dirty-hacks that I used to optimize the size of source or the output file.

