***
*   browse.prg
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

PUBLIC frame

PRIVATE n,move_chrs,force_rec,ntx_expr,ntx_eval,prev_rec,;
		is_append,any_append,keystroke,e_field,get_data

* system constants
frame = "’Õ∏≥æÕ‘≥"                      && box characters

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
	@ M->t, M->l, M->b, M->r BOX "’Õ∏≥æÕ‘≥"
	@ M->t + 3, M->l SAY "∆"
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
DBEDIT(M->t + 1, M->l, M->b, M->r, M->field_list, "xbrowse", 0, 0, " Õ", " ")

RESTORE SCREEN
RETURN .T.


******
*	xbrowse()
*
*	handle special keys and displays during dbedit
******
FUNCTION xbrowse

PARAMETERS mode, f_script
PRIVATE ret_val, memo_buff

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

                                IF TYPE(M->e_field) = "M"
                                        * edit memo field
					* save, clear, and frame window for memoedit
                                        memo_buff = SAVESCREEN(10, 7, 22, 72)

					scroll(10, 7, 22, 72, 0)
					@ 11, 10, 21, 69 BOX M->frame

					* use fieldspec for title
                                        @ 11,((76 - LEN(M->e_field)) / 2) SAY " " + M->e_field + " "

					* edit the memo field
                                        get_data = MEMOEDIT(&e_field, 12, 11, 20, 68,.T.)

					IF LASTKEY() = 23
						* ^W..new memo confirmed

						IF M->is_append .AND. EOF()
							* first data in new record
							APPEND BLANK
							any_append = .T.

							* update status line
							statline()

						ENDIF

						* put it there
						REPLACE &e_field WITH M->get_data

						* move to next field
						KEYBOARD CHR(4)

					ENDIF

					* restore the window
					RESTSCREEN(10, 7, 22, 72, M->memo_buff)
					keystroke = 0

				ELSE

                                        * use memory variable for data entry
                                        get_data = &e_field

                                        * up and down arrows will exit read
                                        SET KEY 5 TO clear_gets
                                        SET KEY 24 TO clear_gets

                                        * data entry
                                        @ ROW(),COL() GET get_data PICTURE get_pic(M->e_field)
                                        READ
                                        keystroke = LASTKEY()           && save exit key

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

************
* HELP.PRG *
************

PROCEDURE HELP

SET CURSOR OFF

SAVE SCREEN
@0,0 CLEAR TO 24,79
@1,10 SAY "MEMOAYUDA"
@3,10 SAY "[" +CHR(24)+ "]"+"         = Sube una linea"
@4,10 SAY "[" +CHR(25)+ "]"+"         = Baja una linea"
@5,10 SAY "[" +CHR(27)+ "]"+"         = Car†cter a la izquierda"
@6,10 SAY "[" +CHR(26)+ "]"+"         = Car†cter a la derecha"
@7,10 SAY "[^" +CHR(27)+ "]"+"        = Palabra a la izquierda"
@8,10 SAY "[^" +CHR(25)+ "]"+"        = Palabra a la derecha"
@9,10 SAY "[Home]      = Principio de linea"
@10,10 SAY "[End]       = Final de linea"
@11,10 SAY "[^Home]     = Principio de texto"
@12,10 SAY "[^End]      = Final de texto"
@13,10 SAY "[PgUp]      = P†gina arriba"
@14,10 SAY "[PgDn]      = P†gina abajo"
@15,10 SAY "[^PgUp]     = Principio de p†gina"
@16,10 SAY "[^PgDn]     = Final de p†gina"
@17,10 SAY "[^W]        = Salvar y salir"
@18,10 SAY "[Esc]       = Aborta y sale"
@19,10 SAY "[^Y]        = Borra linea"
@20,10 SAY "[^T]        = Borra palabra a la derecha"
@21,10 SAY "[^G]        = Marca una ficha para borrarla"
@23,10 SAY "Pulsa una tecla para volver a la edici¢n"

* esta funci¢n hace que nuestra ayuda permanezca
* un minuto en pantalla o hasta que pulsemos una tecla
INKEY(60)

SET CURSOR ON

RESTORE SCREEN

RETURN
