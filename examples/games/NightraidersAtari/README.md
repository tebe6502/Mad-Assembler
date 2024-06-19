# Nightraiders Atari
Nightraiders Atari computer game written in 6502 assemgbly language in 1982-1983, originally was a vertical scrolling game like Xevious but Datamost wanted to do "3D" like Zaxxon, Peter was requested to redo the game as it is seen here. More about the game at https://en.wikipedia.org/wiki/Nightraiders

![alt text](https://github.com/styck/NightraidersAtari/blob/main/Images/NightRaidersTitleScreen.png?raw=true "NightRaider Title Screen")

Download Visual Code from Microsoft : https://code.visualstudio.com/Download
Install the Atasm Altirra Bridge Visual Code Extension from the Extension manager, source code availble here: https://github.com/CycoPH/atasm-altirra-bridge

## ATasm Assembler (version included with Altirra Bridge)

The single file nightraider.asm can be assembled and ran using the ATasm assembler that is built into the Altirra Extension, full debugging is supported.

The required build configurtion in atasm-build.json should look like this, the Atasm Altirra Bridge Etxension settings should be checked to make sure ATasm is selected as well as other paramters specific to your emulation, such as NTSC/PAL.

{
	"comment": "Altirra configuration file.",

	"_1": "Which asm file is to be compiled?",
	"input": "nightraider.asm", 

	"_2": "Array of folders that will be searched when files are .include(d)",
	"includes": [],

	"_3": "Which folder will all the output files be written to. 'out' by default. Always in the workspace!",
	"outputFolder": "out",

	"_4": "Additional atasm parameters:-v -s -u -r -fvalue",
	"params": "-hv -s",

	"_5": "List of symbols to be set via the parameter list",
	"symbols": [],

	"_6": "If debug is enabled then symbol table and listings are generated for Altirra debugging",
	"withDebug": true
}

Once the atasm-build.json is complete (there is also an ATasm command to help create it), within Visual Code to to View -> Command Palette, type ATasm to see the available commands, use "Atasm: Assemble source code and debug in Altirra" to run and debug the game.

![alt text](https://github.com/styck/NightraidersAtari/blob/main/Images/NightRaidersGameStart.png?raw=true "NightRaider Game play")


## MADs assembler V2.1.5 (2/21/2022) - https://mads.atari8.info/mads_eng.html

To build with the MADs assember you will need to download it from https://github.com/tebe6502/Mad-Assembler and in the Atasm Altirra Bridge Extension settings, select "Which Assembler" to Mads and in the "Mads Path" provide the path to where the mads.exe is.

The atasm-build.json for the Mads build will look as shown below, it does not use the file nightraider.asm, only the night1.asm which includes the other required assembly files.

{
	"comment": "Altirra configuration file.",

	"_1": "Which asm file is to be compiled?",
	"input": "night1.asm", 

	"_2": "Array of folders that will be searched when files are .include(d)",
	"includes": [],

	"_3": "Which folder will all the output files be written to. 'out' by default. Always in the workspace!",
	"outputFolder": "out",

	"_4": "Additional atasm parameters:-v -s -u -r -fvalue",
	"params": "",

	"_5": "List of symbols to be set via the parameter list",
	"symbols": [],

	"_6": "If debug is enabled then symbol table and listings are generated for Altirra debugging",
	"withDebug": true
}



