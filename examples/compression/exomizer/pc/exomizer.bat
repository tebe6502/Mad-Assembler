rem https://bitbucket.org/magli143/exomizer/wiki/Home

rem exomizer sfx sys -t 168 -Di_ram_enter=0xff -Di_ram_exit=0xff -Di_table_addr=0xbc40 -c -n %1.obx -o %1.xex

exomizer mem -l none -c filename.mic -o filename.pck

pause
