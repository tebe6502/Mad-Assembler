@echo off

setlocal
:Environment changes made after setlocal are local to the batch file.
:Cmd.exe restores previous settings when it either encounters an endlocal command or reaches the end of the batch file.
:This feature allows keeping long names in current dir variable (%CD%,%~dp0,%~f0) and thus in prompt
:though they are switched to short because of running 'old' DOS executable like AS65.

:use this line if assembler executable in project's main folder
:set asmexe=%CD%\mads.exe

:use this line if assembler executable on system path
set asmexe=mads.exe

cd src

set asmfile=checks
call :ASM
if errorlevel 1 goto :EOF

set asmfile=demomain
rem call :ASM_CHK_OVRLAP
rem if errorlevel 1 goto :EOF
call :ASM
if errorlevel 1 goto :EOF

echo Assembly OK.            

cd ..

set asmfile=knight
echo Building executable '%asmfile%.xex'
call %asmexe% %asmfile%.asm -l:%asmfile%.lst -o:%asmfile%.xex
call :HND_ERRORS
goto :EOF

:ASM_CHK_OVRLAP
echo Assembling '%asmfile%.asm' with checking for overlapping areas
call %asmexe% %asmfile%.asm -l:..\%asmfile%.lst -o:..\%asmfile%.obj -d:chk_ovrlap
call :HND_ERRORS
goto :EOF

:ASM
echo Assembling '%asmfile%.asm'
call %asmexe% %asmfile%.asm -l:..\%asmfile%.lst -o:..\%asmfile%.obj
call :HND_ERRORS
goto :EOF

:HND_ERRORS
if errorlevel 3 goto INV_PARAM
if errorlevel 2 goto ASM_ERR
if errorlevel 1 goto OTHER_ERR
goto :EOF

:ASM_ERR
echo.
echo Assembly gave errors.
goto :EOF

:INV_PARAM
echo Incorrect parameter specified on the commandline.
goto :EOF

:OTHER_ERR
echo Unexpected error occurred.
goto :EOF
