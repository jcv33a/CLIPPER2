************
*
*	Filename..:  DBEDDEMO.PRG
*	Author....:  Dennis L. Dias
*	Date......:  11/18/86
*
*	Purpose...:  demonstrate DBEDIT
*
************
PARAMETERS datafile

IF TYPE("datafile") = "U"
	?
	? "Must enter name of data file on command line."
	?
	QUIT

ENDIF

IF .NOT. (FILE(datafile) .OR. FILE(datafile + ".DBF"))
	?
	? "File not found."
	?
	QUIT

ENDIF

CLEAR

* file exists
USE &datafile

* create an array of field names
DECLARE field_list[FCOUNT()]

FOR n = 1 TO FCOUNT()
	* each element contains one field name
	field_list[n] = FIELDNAME(n)

NEXT

* edit the file
DBEDIT(4, 0, 22, 79, field_list, "ed")

CLEAR ALL
@ 23,0
QUIT


******
*	ed()
*
*	user defined function to be called from DBEDIT
******
FUNCTION ed

PARAMETERS mode,i
PRIVATE cur_field

* get the name of the current field into a regular variable
cur_field = field_list[i]

DO CASE

	CASE mode = 0
		* idle mode..display record number
		@ 3,67 SAY "Record " + LTRIM(STR(RECNO()))
		RETURN(1)

	CASE mode < 4
		* case action can be implemented for each mode
		RETURN(1)

	* mode 4..a keystroke not handled by DBEDIT
	CASE LASTKEY() = 27
		* escape key..quit
		RETURN(0)

	CASE LASTKEY() = 13
		* enter key..edit the current field
		* ..current row and col are correct
		@ ROW(), COL() GET &cur_field
		READ

		* return a right arrow to advance cursor on return
		* ..any cursor key can be returned this way
		KEYBOARD CHR(4)

		* don't quit
		RETURN(1)

	OTHERWISE
		* don't quit
		RETURN(1)

ENDCASE


* EOF DBEDDEMO.PRG
