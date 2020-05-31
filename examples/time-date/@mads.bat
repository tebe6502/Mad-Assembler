
For /f "tokens=1-4 delims=/-" %%a in ("%DATE%") do (
    SET YYYY=%%a
    SET MM=%%b
    SET DD=%%c
)
For /f "tokens=1-4 delims=/:.," %%a in ("%TIME%") do (
    SET HH24=%%a
    SET MI=%%b
    SET SS=%%c
    SET FF=%%d
)

mads.exe time.asm -pl -d:year=%YYYY% -d:month=%MM% -d:day=%DD% -d:hour=%HH24% -d:minute=%MI% -d:second=%SS%

pause
