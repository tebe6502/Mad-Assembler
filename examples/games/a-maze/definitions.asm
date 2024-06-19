; Definitions

.IFNDEF DEFINITIONS
.DEF DEFINITIONS

ICCOM 			= $0342
CIOV  			= $E456
ICBAL 			= $0344
ICBAH			= $0345
ICAX1 			= $034A
ICAX2 			= $034B

wall_left  		= %0001
wall_right 		= %0010
wall_up			= %0100
wall_down		= %1000
walled_in		= wall_left + wall_right + wall_up + wall_down
no_walls		= 0
bytes_per_row	= 40
bytes_per_col	= 1
num_rows		= 24
num_cols		= 40

.ENDIF