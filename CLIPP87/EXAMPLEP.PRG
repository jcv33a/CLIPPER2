***
*   examplep.prg
*
*   Sample Clipper User Defined Functions
*
**


******
*	BROWSE([t, l, b, r])
*
*	Dennis L. Dias
*
******
FUNCTION browse

PARAMETERS t, l, b, r
PRIVATE n,move_chrs,force_rec,ntx_expr,ntx_eval,prev_rec,;
		is_append,any_append,keystroke,e_field,get_data

IF EMPTY(FIELDNAME(1))
	* no database in use
	RETURN .F.

ENDIF

SAVE SCREEN

IF PCOUNT() < 4
	t = 1
	l = 0
	b = 23
	r = 79

ELSE
	* window specified
	@ M->t, M->l, M->b, M->r BOX "ÕÍ¸³¾ÍÔ³"
	@ M->t + 3, M->l SAY "Æ"
	@ M->t + 3, M->r SAY "µ"

	* shrink
	t = M->t + 1
	l = M->l + 1
	b = M->b - 1
	r = M->r - 1

ENDIF

DECLARE field_list[FCOUNT()]

FOR n = 1 TO FCOUNT()
	* each element contains one field name
	field_list[M->n] = FIELDNAME(M->n)

NEXT

* record movement keystroke values
move_chrs = CHR(24) + CHR(5) + CHR(3) + CHR(18) + CHR(31) + CHR(30)

IF EOF()
	GO TOP

ENDIF

* init
force_rec = .T.
is_append = .F.
any_append = .F.
prev_rec = 0

IF LASTREC() = 0
	* empty file..force append mode
	KEYBOARD CHR(24)

ENDIF

@ M->t, M->l SAY SPACE(M->r - M->l + 1)
DBEDIT(M->t + 1, M->l, M->b, M->r, M->field_list, "xbrowse", 0, 0, " Í", " ")

RESTORE SCREEN
RETURN .T.


******
*	xbrowse()
*
*	handle special keys and displays during dbedit
******
FUNCTION xbrowse

PARAMETERS mode, f_script
PRIVATE ret_val

* assume normal return
ret_val = 1

* save last keystroke
keystroke = LASTKEY()

* get fieldspec into normal variable
e_field = field_list[M->f_script]

IF M->prev_rec <> RECNO()
	* record pointer has been moved
	prev_rec = RECNO()
	force_rec = .T.

ENDIF

DO CASE

	CASE M->mode = 0
		* idle

		IF CHR(M->keystroke) $ M->move_chrs .OR. M->force_rec
			* need to update status line
			statline()

		ENDIF

	CASE M->mode = 1
		* bof bang

		IF M->is_append
			* no more append mode..refresh if any new records
			ret_val = IF(M->any_append, 2, 3)
			is_append = .F.
			any_append = .F.

		ELSE

			IF .NOT. EOF()
				* just display "bof bang" status
				@ M->t, M->r - 20 SAY pad(LTRIM(STR(RECNO())) + "/" +;
									  LTRIM(STR(LASTREC())), 15) + " <bof>"

			ENDIF
		ENDIF

		force_rec = .T.

	CASE M->mode = 2
		* eof bang

		IF M->is_append
			* append mode active

			IF M->keystroke = 24 .AND. .NOT. EOF()
				* down arrow...do it again
				ret_val = 3

			ELSE

				IF M->keystroke = 30
					* ^PgDn..no more append mode..refresh if any new records
					ret_val = IF(M->any_append, 2, 3)
					is_append = .F.
					any_append = .F.

				ELSE
					* someone is standing on the down arrow

					IF M->force_rec
						* need to update status line
						statline()

					ENDIF
				ENDIF
			ENDIF

		ELSE

			IF M->keystroke = 24
				* enter append mode
				ret_val = 3
				is_append = .T.

			ELSE

				IF .NOT. EOF()
					* just display "eof bang" status
					@ M->t, M->r - 20 SAY pad(LTRIM(STR(RECNO())) + "/" +;
										 LTRIM(STR(LASTREC())), 15) + " <eof>"

				ENDIF
			ENDIF
		ENDIF

		force_rec = .T.

	CASE M->mode = 3
		* file is empty

		IF M->keystroke = 24
			* enter append mode
			ret_val = 3
			is_append = .T.
			force_rec = .T.

		ELSE
			* just display status
			statline()

		ENDIF

	CASE M->mode = 4
		* keystroke exception

		DO CASE

			CASE M->keystroke = 27
				* exit requested..quit dbedit
				ret_val = 0

			CASE M->keystroke = 7 .AND. .NOT. EOF() .AND. LASTREC() <> 0
				* delete key..toggle deleted() flag

				IF DELETED()
					RECALL

				ELSE
					DELETE

				ENDIF

				* show the new deleted status
				statline()

			CASE M->keystroke = 13 .AND.;
				 (M->is_append .OR. (.NOT. EOF() .AND. LASTREC() <> 0))
				* edit the current field
				ntx_expr = INDEXKEY(0)		&& get the controlling index key

				IF .NOT. EMPTY(M->ntx_expr)
					* expand key for comparison after edit
					ntx_eval = &ntx_expr

				ENDIF

				SET CURSOR ON

				* use memory variable for data entry
				get_data = &e_field

				* up and down arrows will exit read
				SET KEY 5 TO clear_gets
				SET KEY 24 TO clear_gets

				* data entry
				@ ROW(),COL() GET get_data PICTURE get_pic(M->e_field)
				READ
				keystroke = LASTKEY()		&& save exit key

				* release keys
				SET KEY 5 TO
				SET KEY 24 TO

				IF M->keystroke <> 27 .AND. UPDATED()
					* new data confirmed

					IF M->is_append .AND. EOF()
						* first data in new record
						APPEND BLANK
						any_append = .T.

						* update status line
						statline()

					ENDIF

					* put it there
					REPLACE &e_field WITH M->get_data

				ENDIF

				SET CURSOR OFF

				IF .NOT. EMPTY(M->ntx_expr) .AND. .NOT. M->is_append
					* file indexed..check for altered key field

					IF M->ntx_eval <> (&ntx_expr)
						* key field altered..re-draw screen
						ret_val = 2

					ENDIF
				ENDIF

				IF M->ret_val <> 2
					* certain keys move cursor after edit if no refresh

					DO CASE

						CASE M->keystroke = 5
							* up arrow

							IF M->is_append
                    			* no more append mode..refresh if new records
                    			ret_val = IF(M->any_append, 2, 3)
                    			is_append = .F.
                    			any_append = .F.

							ELSE
								* move up one row
								KEYBOARD CHR(5)

							ENDIF

						CASE M->keystroke = 18
							* PgUp

							IF M->is_append
                    			* no more append mode..refresh if new records
                    			ret_val = IF(M->any_append, 2, 3)
                    			is_append = .F.
                    			any_append = .F.

							ELSE
								* return up arrow
								KEYBOARD CHR(5)

							ENDIF

						CASE M->keystroke = 24
							* down arrow
							KEYBOARD CHR(24)

						CASE M->keystroke = 3 .AND. .NOT. M->is_append
							* PgDn..return down arrow if not append mode
							KEYBOARD CHR(24)

						CASE M->keystroke = 13
							* return..move right
							KEYBOARD CHR(4)

					ENDCASE
				ENDIF
		ENDCASE
ENDCASE

RETURN M->ret_val


******
*	statline()
*
*	update the status line in the browse window
******
FUNCTION statline

* display record pointer information
@ M->t, M->r - 27 SAY "Record "

IF LASTREC() = 0 .AND. .NOT. M->is_append
	* file is empty
	@ M->t, M->r - 20 SAY "<none>               "

ELSE

	IF EOF()
		* no record number if eof
		@ M->t, M->r - 40 SAY "         "
		@ M->t, M->r - 20 SAY "                " +;
							  IF(M->is_append, "<new>", "<eof>")

	ELSE
		* normal record..display recno()/lastrec() and deleted()
		@ M->t, M->r - 40 SAY IF(DELETED(), "<Deleted>", "         ")
		@ M->t, M->r - 20 SAY pad(LTRIM(STR(RECNO())) + "/" +;
								  LTRIM(STR(LASTREC())), 21)

	ENDIF
ENDIF

* status line is current
force_rec = .F.
RETURN 0


******
*	get_pic()
*
*	return matching picture string for specified field
******
FUNCTION get_pic

PARAMETERS field
PRIVATE pstring, s

DO CASE

	CASE TYPE(M->field) = "C"
		* character field is bounded by window width
		pstring = "@KS" + LTRIM(STR(MIN(LEN(&field), 78)))

	CASE TYPE(M->field) = "N"
		* convert to character to help format picture string
		s = STR(&field)

		IF "." $ M->s
			* decimals in numeric...use the form "9999.99"
			pstring = REPLICATE("9", AT(".", M->s) - 1) + "."
			pstring = pstring + REPLICATE("9", LEN(M->s) - LEN(M->pstring))

		ELSE
			* no decimals...only need the correct length
			pstring = REPLICATE("9", LEN(M->s))

		ENDIF

	OTHERWISE
		* no picture
		pstring = ""

ENDCASE

RETURN pstring


****
*	pad()
*
*	pad with spaces
****
FUNCTION pad

PARAMETERS string, length
RETURN SUBSTR(string + SPACE(length), 1, length)


******
*	clear_gets
*
*	set keystrokes to this procedure to exit a READ
******
PROCEDURE clear_gets
PARAMETERS dummy1,dummy2,dummy3

CLEAR GETS
RETURN


***
*   AMPM()
*   Tom Rettig
*   11/01/85, 09/01/86
*
*   Returns an 11 byte character string with the time in
*       a 12-hour am/pm format. 
*
*   time_ampm = AMPM(time_24)
*
*       time_ampm   -   character string.
*       time_24     -   character string.
*
*   Placed in the public domain by Tom Rettig Associates.
*
*

FUNCTION AMPM

PARAMETERS cl_time

RETURN IF(        VAL(cl_time)<12, cl_time + " am",;
           IF(    VAL(cl_time)=12, cl_time + " pm",;
              STR(VAL(cl_time)-12,2) + SUBSTR(cl_time,3) + " pm" ) )

*
*
** eofunc AMPM()


****
*   STRZERO()
*   Tom Rettig
*   11/01/85, 09/01/86
*
*   The STR() of <expN> with leading zeros instead of blanks.
*
*   string = STRZERO( <expN>, [<length> [,<decimals>]] )
*
*       string      -   character string.
*       expN        -   numeric.
*       length      -   numeric.
*       decimals    -   numeric.
*
*   Placed in the public domain by Tom Rettig Associates.
*

FUNCTION STRZERO

PARAMETERS cl_num, cl_len, cl_dec

PRIVATE cl_str

DO CASE
   CASE PCOUNT()=3
      cl_str = STR(cl_num,cl_len,cl_dec)

   CASE PCOUNT()=2
      cl_str = STR(cl_num,cl_len)

   OTHERWISE
      cl_str = STR(cl_num)

ENDCASE

IF "-" $ cl_str    && negative number
   * Move the minus sign in front of zeros.
   RETURN "-" + REPLICATE( "0", LEN(cl_str)-LEN(LTRIM(cl_str)) ) +;
                SUBSTR( cl_str, AT("-",cl_str)+1 )
ELSE   && positive number
   RETURN REPLICATE( "0", LEN(cl_str)-LEN(LTRIM(cl_str)) ) + LTRIM(cl_str)
ENDIF

*
*
** eofunc STRZERO()


****
*
*	DAYS()
*
***


FUNCTION DAYS
* Syntax: DAYS( <seconds> )
* Return: Integer number of days from numeric seconds
* Note..: The remainder under 24 hours is returned by the TSTRING() function.
*
PARAMETERS cl_secs
RETURN INT( cl_secs / 86400 )


****
*
* Syntax: DBF()
* Return: The alias of the currently selected database.
* Note..: Supposed to return the name of the currently selected database file.
*
***

FUNCTION DBF
RETURN ALIAS()


****
* Syntax: ELAPTIME( <start time>, <end time> )
* Return: A time string showing the difference between start and end times
* Note..: If start time is greater than end time, this algorithm assumes
*         that the day changed at midnight.  Only for timings under 24 hours.
*         86400 is the number of seconds in 24 hours.
***

FUNCTION ELAPTIME
PARAMETERS cl_start, cl_end

RETURN TSTRING( IF(cl_end<cl_start,86400,0)+SECS(cl_end)-SECS(cl_start) )


****
* Syntax: FKLABEL( <expN> )
* Return: The name of the <expN>th programmable function key
***
FUNCTION FKLABEL
PARAMETERS cl_1

RETURN IF(cl_1<=40 .AND. cl_1 > 0, "F"+LTRIM(STR(cl_1)), [])


****
*
* Syntax: FKMAX()
* Return: The maximum number of programmable function keys on the computer
* Note..: This is specific to IBM PC/XT/AT and clones.
*
***
FUNCTION FKMAX

RETURN 40          && IBM specific


****
* Syntax: LENNUM( <expN> )
* Return: The length of <expN>
*
***
FUNCTION LENNUM
PARAMETERS cl_number

RETURN LEN(LTRIM(STR(cl_number)))


****
* Syntax: MOD( <expN1>, <expN2> )
* Return: The remainder of <expN1> divided by <expN2>
* Note..: Difference between the dBASE modulus function and the Clipper 
*         modulus operator is indicated by an arrow <-->:
*
*         Clipper operator:        dBASE function:
*         -----------------        -----------------
*          3 %  3 ::=  0.00        MOD( 3, 3) ::=  0      
*          3 %  2 ::=  1.00        MOD( 3, 2) ::=  1      
*          3 %  1 ::=  0.00        MOD( 3, 1) ::=  0      
*          3 %  0 ::=  0.00  <-->  MOD( 3, 0) ::=  3      
*          3 % -1 ::=  0.00        MOD( 3,-1) ::=  0      
*          3 % -2 ::=  1.00  <-->  MOD( 3,-2) ::= -1      
*          3 % -3 ::=  0.00        MOD( 3,-3) ::=  0      
*                                                            
*         -3 %  3 ::=  0.00        MOD(-3, 3) ::=  0      
*         -3 %  2 ::= -1.00  <-->  MOD(-3, 2) ::=  1      
*         -3 %  1 ::=  0.00        MOD(-3, 1) ::=  0      
*         -3 %  0 ::=  0.00  <-->  MOD(-3, 0) ::= -3      
*         -3 % -1 ::=  0.00        MOD(-3,-1) ::=  0      
*         -3 % -2 ::= -1.00        MOD(-3,-2) ::= -1      
*         -3 % -3 ::=  0.00        MOD(-3,-3) ::=  0      
*                                                            
*          3 %  3 ::=  0.00        MOD( 3, 3) ::=  0      
*          2 %  3 ::=  2.00        MOD( 2, 3) ::=  2      
*          1 %  3 ::=  1.00        MOD( 1, 3) ::=  1      
*          0 %  3 ::=  0.00        MOD( 0, 3) ::=  0      
*         -1 %  3 ::= -1.00  <-->  MOD(-1, 3) ::=  2      
*         -2 %  3 ::= -2.00  <-->  MOD(-2, 3) ::=  1      
*         -3 %  3 ::=  0.00        MOD(-3, 3) ::=  0      
*                                                            
*          3 % -3 ::=  0.00        MOD( 3,-3) ::=  0      
*          2 % -3 ::=  2.00  <-->  MOD( 2,-3) ::= -1      
*          1 % -3 ::=  1.00  <-->  MOD( 1,-3) ::= -2      
*          0 % -3 ::=  0.00        MOD( 0,-3) ::=  0      
*         -1 % -3 ::= -1.00        MOD(-1,-3) ::= -1      
*         -2 % -3 ::= -2.00        MOD(-2,-3) ::= -2      
*         -3 % -3 ::=  0.00        MOD(-3,-3) ::=  0      
*
***
FUNCTION MOD
PARAMETERS cl_num, cl_base

PRIVATE cl_result
cl_result = cl_num % cl_base
RETURN IF( cl_base = 0, cl_num,; 
           IF(cl_result * cl_base < 0, cl_result + cl_base, cl_result) )


****
* Syntax OS()
* Return: The name of the operating system
*
***
FUNCTION OS

RETURN "MS/PC-DOS"    && DOS specific, MicroSoft or IBM


****
* Syntax: READKEY()
* Return: A number representing the key pressed to exit from full-screen mode
* Note..: Differences between dBASE's READKEY() and Clipper's LASTKEY():
*
*         Exit Key:      dBASE:      Clipper:
*         ---------      ------      --------
*         Backspace         0        no exit
*         ^D, ^L            1        no exit
*         Lt arrow          2        no exit
*         Rt arrow          3        no exit
*         Up arrow          4        no exit
*         Dn arrow          5        no exit
*         PgUp              6          18
*         PgDn              7           3
*         Esc, ^Q          12          27 (Esc only)
*         ^End, ^W         14          23 (^W only)
*         type past end    15        ascii of last char typed
*         Enter            15          13
*         ^Home            33        no exit
*         ^PgUp            34        no exit
*         ^PgDn            35        no exit
*         F1               36        no exit
*
*         dBASE III adds 256 to the exit code if the user changed anything.
*         Clipper uses its UPDATED() function to determine if anything changed.
*
***
FUNCTION READKEY

DO CASE
   CASE LASTKEY() = 18                           && PgUp
      RETURN  6 + IF(UPDATED(),256,0)
   CASE LASTKEY() =  3                           && PgDn
      RETURN  7 + IF(UPDATED(),256,0)
   CASE LASTKEY() = 27                           && Esc
      RETURN 12 + IF(UPDATED(),256,0)
   CASE LASTKEY() = 23                           && ^W
      RETURN 14 + IF(UPDATED(),256,0)
   CASE LASTKEY() = 13                           && Enter
      RETURN 15 + IF(UPDATED(),256,0)
   CASE LASTKEY() = 31                           && ^PgUp
      RETURN 34 + IF(UPDATED(),256,0)
   CASE LASTKEY() = 30                           && ^PgDn
      RETURN 35 + IF(UPDATED(),256,0)
   CASE LASTKEY() >= 32                          && type past end
      RETURN 15 + IF(UPDATED(),256,0)
   OTHERWISE
      RETURN 0
ENDCASE


****
* Syntax: SECS( <time string> )
* Return: Numeric seconds as a quantity of the time string
* Note..: Seconds in time period
*         -------    -----------
*              60    1 minute
*            3600    1 hour
*           86400    1 day
*
***
FUNCTION SECS
PARAMETERS cl_time

RETURN VAL(       cl_time   ) * 3600 +;
       VAL(SUBSTR(cl_time,4)) *   60 +;
       VAL(SUBSTR(cl_time,7))

****
* Syntax: TSTRING( <seconds> )
* Return: A 24-hour time string from numeric seconds
* Note..: Time quantities over 24 hours are returned by the DAYS() function.
*
***
FUNCTION TSTRING
PARAMETERS cl_secs

RETURN STRZERO( INT(MOD(cl_secs/3600, 24)), 2, 0 ) +':'+;
       STRZERO( INT(MOD(cl_secs/  60, 60)), 2, 0 ) +':'+;
       STRZERO( INT(MOD(cl_secs     , 60)), 2, 0 )


****
* Syntax: VERSION()
* Return: The name of current dBASE III or Clipper version
* Note..: Remember to change this when you update your Clipper version.
***
FUNCTION VERSION

RETURN "Clipper, Summer '87"

