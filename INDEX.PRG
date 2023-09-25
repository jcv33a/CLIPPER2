* Index creation program
PARAMETERS dbf

IF PCOUNT() = 0
   ? "SYNTAX: >INDEX <filename>"
   ?
   RETURN
ENDIF

IF .NOT. FILE("&dbf..DBF")
   ? "&dbf..DBF not found"
   RETURN
ENDIF

STORE SPACE(8) TO ntx
CLEAR
@ 1,0 SAY "Name of index file:" GET ntx
READ
@ 1,27 SAY ""
ACCEPT "Key expression: " TO key

USE &dbf
INDEX ON &key TO &ntx
? RECCOUNT(), " Records indexed"