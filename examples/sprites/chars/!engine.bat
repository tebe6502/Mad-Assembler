mads.exe init\init.asm -d:charsBAK=56 -i:global -i:init

mads.exe bcalc.asm -d:bufor=2 -o:b2calc.obx -i:global
mads.exe bcalc.asm -d:bufor=3 -o:b3calc.obx -i:global

mads.exe engine.asm -i:global

pause
