************
*
*	Program....:  DBU
*	Filename...:  DBUEDIT.PRG
*	Author.....:  Dennis L. Dias
*	Date.......:  06/18/86
*	Purpose....:  Data File Editing Module
*
*	Copyright (c) 1986,1987 Nantucket Corp., All Rights Reserved.
*
************


******
*	browse
*
*	browse one file or the entire View
******
PROCEDURE browse

PRIVATE old_help,move_chrs,force_rec,ntx_expr,ntx_eval,ntx,k_filter,field_a,;
		i,prev_alias,prev_rec,browse_buf,prim_area,prim_dbf,hsep_row,;
		can_append,is_append,any_append

old_help = M->help_code

* save, clear, and frame the window
browse_buf = SAVESCREEN(8, 0, 23, 79)

* array to save move_ptr expressions
DECLARE k_exp[4]
STORE "" TO k_exp[1],k_exp[2],k_exp[3],k_exp[4]

* record movement keystroke values
move_chrs = CHR(24) + CHR(5) + CHR(3) + CHR(18) + CHR(31) + CHR(30)

* heading separator row if only one database
hsep_row = 11

IF M->func_sel = 1
	* browse one file
	prim_area = M->cur_area
	field_a = "field_n" + SUBSTR("123456", M->cur_area, 1)
	k_filter = "kf" + SUBSTR("123456", M->cur_area, 1)
	ntx = "ntx" + SUBSTR("123456", M->cur_area, 1)
	cur_ntx = &ntx[1]
	prim_dbf = SUBSTR(M->cur_dbf, RAT("\", M->cur_dbf) + 1)
	can_append = .T.

ELSE
	* browse the entire view
	prim_area = 1
	field_a = "field_list"
	k_filter = "kf1"
	cur_ntx = ntx1[1]
	prim_dbf = SUBSTR(dbf[1], RAT("\", dbf[1]) + 1)
	can_append = .F.

	IF "->" $ field_list[afull(M->field_list)]
		hsep_row = 12

	ENDIF
ENDIF

SELECT (M->prim_area)

IF EOF()
	GO TOP

ENDIF

* misc
force_rec = .T.
is_append = .F.
any_append = .F.
prev_alias = ""
prev_rec = 0

* initialize parts of screen not handled by dbedit
stat_msg("")
scroll(8, 0, 23, 79, 0)
@ 8, 0, 23, 79 BOX M->frame
@ M->hsep_row, 0 SAY "ф"
@ M->hsep_row, 79 SAY "╣"

IF LASTREC() = 0 .AND. M->can_append
	* empty file..force append mode
	KEYBOARD CHR(24)

ENDIF

dbedit(10, 1, 23, 78, &field_a, "xbrowse", .T., .T., .T., .T., "мом")

* restore the screen
RESTSCREEN(8, 0, 23, 79, M->browse_buf)
stat_msg("")
RETURN


******
*	xbrowse()
*
*	handle special keys and displays during dbedit
******
FUNCTION xbrowse

PARAMETERS mode, f_script
PRIVATE e_field, t_field, cur_alias, memo_buff, get_data, r

* assume normal return
r = 1

* save last keystroke
keystroke = LASTKEY()

* get fieldspec into normal variable
e_field = &field_a[M->f_script]

* separate the field name from the alias (if any)
t_field = SUBSTR(M->e_field, AT(">", M->e_field) + 1)
cur_alias = IF("->" $ M->e_field,;
			   SUBSTR(M->e_field, 1, AT("->", M->e_field) - 1),"")

IF .NOT. EMPTY(M->cur_alias)
	* select the secondary work area
	SELECT &cur_alias

ENDIF

IF .NOT. (M->cur_alias == M->prev_alias)
	* cursor has moved onto a different file
	prev_alias = M->cur_alias
	force_rec = .T.
	k_filter = "kf" + SUBSTR("123456", SELECT(), 1)

ENDIF

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
			r = IF(M->any_append, 2, 3)
			is_append = .F.
			any_append = .F.

		ELSE

			IF .NOT. EOF()
				* just display "bof bang" status
				@ 9,58 SAY pad(LTRIM(STR(RECNO())) + "/" + LTRIM(STR(LASTREC())),;
						   15) + " <bof>"

			ENDIF
		ENDIF

		force_rec = .T.

	CASE M->mode = 2
		* eof bang

		IF M->is_append
			* append mode active

			IF M->keystroke = 24 .AND. .NOT. EOF()
				* down arrow...do it again
				r = 3

			ELSE

				IF M->keystroke = 30
					* ^PgDn..no more append mode..refresh if any new records
					r = IF(M->any_append, 2, 3)
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

			IF M->keystroke = 24 .AND. M->can_append
				* enter append mode
				r = 3
				is_append = .T.

			ELSE

				IF .NOT. EOF()
					* just display "eof bang" status
					@ 9,58 SAY pad(LTRIM(STR(RECNO())) + "/" +;
							   LTRIM(STR(LASTREC())), 15) + " <eof>"

				ENDIF
			ENDIF
		ENDIF

		force_rec = .T.

	CASE M->mode = 3
		* file is empty

		IF M->keystroke = 24 .AND. M->can_append
			* enter append mode
			r = 3
			is_append = .T.
			force_rec = .T.

		ELSE
			* just display status
			statline()

		ENDIF

	CASE M->mode = 4
		* keystroke exception..check for menu request
		sysmenu()

		DO CASE

			CASE M->local_func = 1
				* help requested
				DO syshelp

			CASE local_func = 7
				* move option selected..only the primary can be moved
				SELECT (M->prim_area)
				move_ptr()

				IF .NOT. EMPTY(M->cur_alias)
					* re-select secondary for screen update below
					SELECT &cur_alias

				ENDIF

				IF M->prev_rec <> RECNO() .AND. M->is_append
					* no more append mode..refresh to ensure correct display
					r = 2
					is_append = .F.
					any_append = .F.

				ENDIF

				* status may have changed
				statline()

			CASE q_check()
				* exit requested..quit dbedit
				SELECT (M->prim_area)
				r = 0

			CASE M->keystroke = 7 .AND. .NOT. EOF() .AND. LASTREC() <> 0
				* delete key..toggle deleted() flag

				IF DELETED()
					RECALL

				ELSE
					DELETE

				ENDIF

				* show the new deleted status
				statline()

			CASE M->keystroke = 22
				*toggle insert mode
				tog_insert()

			CASE (M->keystroke = 13 .OR. isdata(M->keystroke)) .AND.;
				 (M->is_append .OR. (.NOT. EOF() .AND. LASTREC() <> 0))
				* edit the current field
				ntx_expr = INDEXKEY(0)		&& get the controlling index key

				IF .NOT. EMPTY(M->ntx_expr)
					* expand key for comparison after edit
					ntx_eval = &ntx_expr

				ENDIF

				IF M->keystroke <> 13
					* forward data keystroke to GET system
					KEYBOARD CHR(M->keystroke)

				ENDIF

				SET CURSOR ON
				curs_on = .T.

				IF TYPE(M->t_field) = "M"
					* edit memo field
					help_code = 19
					box_open = .T.

					* save, clear, and frame window for memoedit
					memo_buff = SAVESCREEN(10, 7, 22, 72)

					scroll(10, 7, 22, 72, 0)
					@ 11, 10, 21, 69 BOX M->frame

					* use fieldspec for title
					syscolor(2)
					@ 11,((76 - LEN(M->e_field)) / 2) SAY "  " + M->e_field +;
														  "  "
					syscolor(1)

					* edit the memo field
					get_data = MEMOEDIT(&e_field, 12, 11, 20, 68,.T.,"xmemo")

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
					box_open = .F.
					keystroke = 0

				ELSE
					* use memory variable for data entry
					get_data = &e_field

					* set certain keys to exit read
					SET KEY 5 TO clear_gets
					SET KEY 24 TO clear_gets
					xkey_clear()

					* keep insert mode visible
					SET KEY 22 TO tog_insert

					* data entry
					@ ROW(),COL() GET get_data PICTURE get_pic(M->t_field)
					READ
					keystroke = LASTKEY()		&& save exit key

					* release keys
					SET KEY 22 TO
					xkey_norm()
					SET KEY 5 TO
					SET KEY 24 TO

					IF M->keystroke <> 27 .AND. menu_key() = 0 .AND. UPDATED()
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
				curs_on = .F.
				help_code = M->old_help

				IF .NOT. EMPTY(M->ntx_expr) .AND. .NOT. M->is_append
					* file indexed..check for altered key field

					IF M->ntx_eval <> (&ntx_expr)
						* key field altered..re-draw screen
						r = 2

					ENDIF
				ENDIF

				IF M->r <> 2
					* certain keys move cursor after edit if no refresh

					DO CASE

						CASE M->keystroke = 5
							* up arrow

							IF M->is_append
                    			* no more append mode..refresh if new records
                    			r = IF(M->any_append, 2, 3)
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
                    			r = IF(M->any_append, 2, 3)
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

						CASE M->keystroke = 13 .OR. isdata(M->keystroke)
							* return or type out..move right
							KEYBOARD CHR(4)

						CASE menu_key() <> 0
							* menu request will abort edit
							KEYBOARD CHR(M->keystroke)

					ENDCASE
				ENDIF
		ENDCASE
ENDCASE

SELECT (M->prim_area)
RETURN M->r


****
*	xmemo()
*
*	memoedit user function
****
FUNCTION xmemo

PARAMETERS mmode, line, col
PRIVATE ret_val

ret_val = 0

IF M->mmode <> 0
	* keystroke exception..check for menu request
	keystroke = LASTKEY()
	sysmenu()

	DO CASE

		CASE M->local_func = 1
			* help requested
			DO syshelp

		CASE M->keystroke = 22
			* insert key pressed
			tog_insert()
			ret_val = 32

		CASE M->keystroke = 27
			* escape key pressed

			IF M->mmode = 2
				* memo has been altered

				IF rsvp("Ok To Lose Changes? (Y/N)") <> "Y"
					* no exit if not confirmed (32 = ignore)
					ret_val = 32

				ENDIF
			ENDIF
	ENDCASE
ENDIF

RETURN M->ret_val


******
*	tog_insert()
*
*	ditto
******
FUNCTION tog_insert

READINSERT(.NOT. READINSERT())
SET CURSOR OFF
show_insert()

IF M->curs_on
	SET CURSOR ON

ENDIF

RETURN 0

******
*	show_insert()
*
*	display current insert mode
******
FUNCTION show_insert

@ 9,4 SAY IF(READINSERT(), "<Insert>", "        ")
RETURN 0

******
*	statline()
*
*	update the status line in the browse window
******
FUNCTION statline

* current mode
show_insert()

* show filter status
@ 9,16 SAY IF(EMPTY(&k_filter), "        ", "<Filter>")

* display record pointer information
@ 9,41 SAY IF(EMPTY(M->cur_alias), SPACE(10), lpad(M->cur_alias + "->", 10));
		   + "Record "

IF LASTREC() = 0 .AND. .NOT. M->is_append
	* file is empty
	@ 9,58 SAY "<none>               "

ELSE

	IF EOF()
		* no record number if eof
		@ 9,28 SAY "         "
		@ 9,58 SAY "                " + IF(M->is_append, "<new>", "<eof>")

	ELSE
		* normal record..display recno()/lastrec() and deleted()
		@ 9,28 SAY IF(DELETED(), "<Deleted>", "         ")
		@ 9,58 SAY pad(LTRIM(STR(RECNO())) + "/" + LTRIM(STR(LASTREC())), 21)

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


******
*	move_ptr()
*
*	seek, goto, locate, skip
*
*	the following array is defined and initialized in browse:
*		k_exp[1] = the last SEEK expression
*		k_exp[2] = the last GOTO value
*		k_exp[3] = the last LOCATE expressions
*		k_exp[4] = the last SKIP value
******
FUNCTION move_ptr

PRIVATE old_help, okee_dokee, k_trim, movp_sel, titl_str, exp_label

old_help = M->help_code

* save function select number
movp_sel = M->local_sel

* initialize expression to previous value, if any
k_trim = k_exp[M->movp_sel]

* set up for multibox
DECLARE boxarray[4]

boxarray[1] = "movp_title(sysparam)"
boxarray[2] = "movp_exp(sysparam)"
boxarray[3] = "ok_button(sysparam)"
boxarray[4] = "can_button(sysparam)"

DO CASE

	CASE M->movp_sel = 1
		* seek
		okee_dokee = "do_seek()"
		titl_str = "Seek in file " + M->prim_dbf + "..."
		exp_label = "Expression"
		ntx_expr = INDEXKEY(0)
		help_code = 13

	CASE M->movp_sel = 2
		* goto
		okee_dokee = "do_goto()"
		titl_str = "Move pointer in file " + M->prim_dbf + " to..."
		exp_label = "Record#"
		help_code = 14

	CASE M->movp_sel = 3
		* locate
		okee_dokee = "do_locate()"
		titl_str = "Locate in file " + M->prim_dbf + "..."
		exp_label = "Expression"
		help_code = 10

	CASE M->movp_sel = 4
		* skip
		okee_dokee = "do_skip()"
		titl_str = "Skip records in file " + M->prim_dbf + "..."
		exp_label = "Number"
		help_code = 20

ENDCASE

* do it
multibox(14, 17, 5, 2, M->boxarray)

* save expression for next time
k_exp[M->movp_sel] = M->k_trim

help_code = M->old_help
RETURN 0


******
*	movp_title()
*
*	display title for move pointer functions
******
FUNCTION movp_title

PARAMETERS sysparam

RETURN box_title(M->sysparam, M->titl_str)


******
*	movp_exp()
*
*	get parameter for move pointer
******
FUNCTION movp_exp

PARAMETERS sysparam

RETURN get_k_trim(M->sysparam, M->exp_label)


******
*	do_seek()
*
*	seek to expression
******
FUNCTION do_seek

PRIVATE done, org_rec, s_type

done = .F.

IF EMPTY(M->k_trim)
	error_msg("Expression not entered")

ELSE
	stat_msg("Searching...")

	* save record number in case no find
	org_rec = RECNO()

	* determine type for seek
	s_type = TYPE(M->ntx_expr)

	* try it
	DO CASE

		CASE M->s_type = "C"
			* character search
			SEEK M->k_trim

		CASE M->s_type = "N"
			* numeric search
			SEEK VAL(M->k_trim)

		CASE M->s_type = "D"
			* date search
			SEEK CTOD(M->k_trim)

	ENDCASE

	IF FOUND()
		* operation complete
		stat_msg("Found")
		done = .T.

	ELSE
		* consider this an error..start over
		error_msg("Not found")
		GOTO M->org_rec

	ENDIF
ENDIF

RETURN M->done


******
*	do_goto()
*
*	go to record number
******
FUNCTION do_goto

PRIVATE done, which

done = .F.
which = VAL(M->k_trim)		&& convert to number

DO CASE

	CASE EMPTY(M->k_trim)
		error_msg("Record number not entered")

	CASE .NOT. SUBSTR(LTRIM(M->k_trim), 1, 1) $ "-+1234567890"
		error_msg("Record number not numeric")

	CASE M->which <= 0 .OR. M->which > LASTREC()
		error_msg("Record out of range")

	OTHERWISE
		* operation complete
		GOTO M->which
		done = .T.

ENDCASE

RETURN M->done


******
*	do_locate()
*
*	locate expression
******
FUNCTION do_locate

PRIVATE done, org_rec

done = .F.

DO CASE

	CASE EMPTY(M->k_trim)
		error_msg("Expression not entered")

	CASE TYPE(M->k_trim) <> "L"
		error_msg("Expression Type must be Logical")

	OTHERWISE
		* save record number in case no find
		org_rec = RECNO()
		stat_msg("Searching...")

		IF &k_trim
			* current record meets the condition
			SKIP

		ENDIF

		* search forward to end of file
		LOCATE FOR &k_trim WHILE .T.

		IF FOUND()
			* operation complete
			stat_msg("Found")
			done = .T.

		ELSE
			* consider this an error..start over
			error_msg("Not found")
			GOTO M->org_rec

		ENDIF
ENDCASE

RETURN M->done


******
*	do_skip()
*
*	skip number of records
******
FUNCTION do_skip

PRIVATE done, skip_val

done = .F.
skip_val = VAL(M->k_trim)		&& convert to number

DO CASE

	CASE EMPTY(M->k_trim)
		error_msg("Skip value not entered")

	CASE .NOT. SUBSTR(LTRIM(M->k_trim), 1, 1) $ "-+1234567890"
		error_msg("Skip value not numeric")

	CASE M->skip_val = 0
		error_msg("Skip value zero")

	OTHERWISE
		* no out of range or over-skip error
		done = .T.

		SKIP M->skip_val

		IF EOF()
			* over-skip..clear eof flag
			GO BOTTOM

		ENDIF

		IF BOF()
			* over-skip..clear bof flag
			GO TOP

		ENDIF
ENDCASE

RETURN M->done


* EOF DBUEDIT.PRG
