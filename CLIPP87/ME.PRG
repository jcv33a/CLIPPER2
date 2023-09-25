****
*	me.prg
*
*	test MEMOEDIT
****
PARAMETERS memofile

IF TYPE("memofile") <> "C"
	memofile = "none"

ENDIF

prev_memo = ""
ret_val = 0
deja_vu = .F.
eresume = .F.
altered = .F.

t = 0
l = 0
b = 23
r = 79
update = .T.
browse = .T.
line_length = 132
use_func = .T.
ufunc = "mfunc"
ins_on = .F.
scrl_on = .F.
word_wrap = .F.
tabsize = 4

SET BELL ON
SET SCOREBOARD OFF

DO WHILE .T.

	IF .NOT. eresume
		DO config

		IF LASTKEY() = 27
			@ b + 1, 79 SAY ""
			QUIT

		ENDIF

		IF use_func
			ufunc = "mfunc"
			SET SCOREBOARD OFF

		ELSE

			IF browse
				ufunc = ""

			ELSE
				ufunc = .F.

			ENDIF

			IF t = 0
				SET SCOREBOARD OFF

			ELSE
				SET SCOREBOARD ON

			ENDIF
		ENDIF

		IF .NOT. (prev_memo == memofile)
			usr_memo = MEMOREAD(memofile)
			prev_memo = memofile
			line_num = 1
			col_num = 0
			rel_row = 0
			rel_col = 0
			altered = .F.

		ENDIF

		msg_len = r - l - 25

		CLEAR
		@ t, l, b, r BOX "’Õ∏≥æÕ‘≥"

		@ b + 1, l SAY pad(LOWER(memofile), msg_len)

	ENDIF

	init_count = 1
	deja_vu = .F.
	eresume = .F.

	usr_memo = MEMOEDIT(usr_memo, t + 1, l + 1, b - 1, r - 1, update, ufunc,;
						line_length, tabsize,;
						line_num, col_num, rel_row, rel_col)

	IF .NOT. memofile == "none" .AND. .NOT. EMPTY(usr_memo) .AND. ret_val = 23
		altered = .F.

		IF .NOT. MEMOWRIT(memofile, usr_memo)
			SET COLOR TO w*+
			@ 24,79 SAY ""
			? "DISK WRITE ERROR"
			SET COLOR TO
			CLOSE DATABASES
			QUIT

		ENDIF

		@ b + 1, l SAY pad("Write successful.", msg_len)

	ENDIF
ENDDO


****
*	mfunc()
*
*	memoedit user function
****
FUNCTION mfunc

PARAMETERS mode, line, col
PRIVATE keypress

ret_val = 0

DO CASE

	CASE mode = 3
		* initialization..global variables "init_count" and "deja_vu"
		*	 control the initialization process..note that this is
		*	 much simpler when the parameters passed to MEMOEDIT
		*	 are known in advance (which is usually true)

		IF init_count = 1
			* set initial insert mode
			ins_mode = READINSERT()

			IF (ins_on .AND. .NOT. ins_mode) .OR.;
			   (.NOT. ins_on .AND. ins_mode)
				* toggle insert mode
				ret_val = 22

			ELSE
				* insert mode correct
				init_count = 2
				@ b + 1, r - 25 SAY IF(ins_on, "I", " ")

			ENDIF
		ENDIF

		IF init_count = 2
			* set initial scroll state (defaults ON if update OFF)

			IF ((.NOT. scrl_on .AND. .NOT. update) .OR.;
				(scrl_on .AND. update)) .AND. .NOT. deja_vu
				* need to toggle
				deja_vu = .T.
				ret_val = 35

			ELSE
				* scroll state correct
				init_count = 3
				deja_vu = .F.
				@ b + 1, r - 24 SAY IF(scrl_on, "S", " ")

			ENDIF
		ENDIF

		IF init_count = 3
			* set initial word wrap..always defaults ON

			IF .NOT. word_wrap .AND. .NOT. deja_vu
				* need to toggle
				deja_vu = .T.
				ret_val = 34

			ELSE
				* word wrap correct
				init_count = 4
				deja_vu = .F.
				@ b + 1, r - 23 SAY IF(word_wrap, "W", " ")

			ENDIF
		ENDIF

		IF init_count = 4
			* finished initialization..note that if all defaults are
			*	correct we reach this point on the first call
			ret_val = 0

		ENDIF

	CASE mode = 0
		* idle
		@ b + 1, r - 20 SAY "Line: " + pad(LTRIM(STR(line)), 4)
		@ b + 1, r - 8 SAY "Col: " + pad(LTRIM(STR(col)), 3)

	OTHERWISE
		* keystroke exception
		keypress = LASTKEY()

		* save values to possibly resume edit
		line_num = line
		col_num = col
		rel_row = ROW() - t - 1
		rel_col = COL() - l - 1

		IF mode = 2
			altered = .T.

		ENDIF

		DO CASE

			CASE keypress = 23
				* ^W..ignore (disable)
				ret_val = 32

			CASE keypress = 273
				* Alt-W..write file
				IF .NOT. altered
					* no changes to write
					@ b + 1, l SAY pad("No changes to write.", msg_len)

				ELSE
					* write and resume
					@ b + 1, l SAY SPACE(msg_len)
					@ b + 1, l SAY "Writing " + LOWER(memofile) + "..."
					ret_val = 23
					eresume = .T.

				ENDIF

			CASE keypress = 301 .OR. keypress = 27
				* Esc/Alt-X..exit
				IF .NOT. altered
					* no change
					ret_val = 27

				ELSE
					* changes have been made to memo
					@ b + 1, l SAY SPACE(msg_len)
					@ b + 1, l SAY "Abandon [ynw]? "

					response = " "
					DO WHILE .NOT. response $ "YNW"
						response = UPPER(CHR(INKEY(0)))

					ENDDO

					@ b + 1, l SAY SPACE(msg_len)

					DO CASE

						CASE response = "Y"
							* abort
							ret_val = 27

						CASE response = "N"
							* ignore
							ret_val = 32

						CASE response = "W"
							* save and exit
							@ b + 1, l SAY SPACE(msg_len)
							@ b + 1, l SAY "Writing " + LOWER(memofile)+"..."
							ret_val = 23

					ENDCASE
				ENDIF

			CASE keypress = 289
				* Alt-F..display file name
				@ b + 1, l SAY pad(LOWER(memofile), msg_len)

			CASE keypress = -2
				* F3..delete line
				ret_val = 25

			CASE keypress = -3
				* F4..insert line
				ret_val = 14

			CASE keypress = -4 .AND. update
				* F5..toggle word wrap
				word_wrap = .NOT. word_wrap
				@ b + 1, r - 23 SAY IF(word_wrap, "W", " ")
				ret_val = 34

			CASE keypress = -5
				* F6..toggle scroll lock
				scrl_on = .NOT. scrl_on
				@ b + 1, r - 24 SAY IF(scrl_on, "S", " ")
				ret_val = 35

			CASE (keypress = 279 .OR. keypress = 22) .AND. update
				* ^V/Ins/Alt-I..toggle insert mode
				ins_on = .NOT. ins_on
				@ b + 1, r - 25 SAY IF(ins_on, "I", " ")
				ret_val = 22

		ENDCASE
ENDCASE

RETURN ret_val


****
*	pad()
*
*	pad with spaces
****
FUNCTION pad

PARAMETERS string, length
RETURN SUBSTR(string + SPACE(length), 1, length)


****
*	config
*
*	set parameters for simulation
****
PROCEDURE config

memofile = pad(memofile, 64)
CLEAR

@ 1, 0 SAY "File To Edit_" GET memofile PICTURE "@K"
@ 3, 0 SAY "Window Coordinates:"
@ 5, 5 SAY "Top_____________________" GET t
@ 6, 5 SAY "Left____________________" GET l
@ 7, 5 SAY "Bottom__________________" GET b
@ 8, 5 SAY "Right___________________" GET r

@ 10, 5 SAY "Line Length (memowidth)_" GET line_length
@ 11, 5 SAY "Tab Size________________" GET tabsize

@ 13, 5 SAY "Allow Updates [yn]______" GET update
@ 14, 5 SAY "Allow Browse [yn]_______" GET browse
@ 15, 5 SAY "Use User Function [yn]__" GET use_func

@ 17, 5 SAY "Insert Mode On [yn]_____" GET ins_on
@ 18, 5 SAY "Scroll State On [yn]____" GET scrl_on
@ 19, 5 SAY "Word Wrap On [yn]_______" GET word_wrap
READ

memofile = LTRIM(TRIM(memofile))
RETURN


* eof me.prg
