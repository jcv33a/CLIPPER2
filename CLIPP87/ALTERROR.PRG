***
*	ALTERROR
*
*	Clipper error system.  Debugging version.
*

PROCEDURE errorsys

ALTD()

RETURN


***
*	expr_error(name, line, info, model, _1, _2, _3)
*

FUNCTION expr_error
PARAM name, line, info, model, _1, _2, _3
PRIVATE result, sample

IF M->info = "zero divide"
	IF "%" $ M->model
		RETURN M->_1
	ELSE
		RETURN 0
	END
END

ALTD(2)

IF TYPE("M->result") != "U"
	RETURN M->result
END


SET DEVICE TO SCREEN
@ 0, 0

IF info = "type mismatch"
	M->sample = M->model
	M->sample = strtran(M->sample, "_1", type("M->_1"))
	M->sample = strtran(M->sample, "_2", type("M->_2"))
	M->sample = strtran(M->sample, "_3", type("M->_3"))

	@ 0, 0 SAY "Proc " + M->name + " line " + LTRIM(STR(M->line)) + ", " +;
				M->info + ": " + M->sample

ELSE
	@ 0, 0 SAY "Proc " + M->name + " line " + LTRIM(STR(M->line)) + ", " +;
				M->info

END

BREAK

RETURN .T.


***
*	misc_error(name, line, info, model)
*

FUNCTION misc_error
PARAM name, line, info, model

ALTD(2)

SET DEVICE TO SCREEN
@ 0, 0
@ 0, 0 SAY "Proc " + M->name + " line " + LTRIM(STR(M->line)) + ", " +;
			M->info + ": " + M->model

BREAK

RETURN .F.


***
*	open_error(name, line, info, model, _1)
*

FUNCTION open_error
PARAM name, line, info, model, _1

ALTD(2)

SET DEVICE TO SCREEN
@ 0, 0
@ 0, 0 SAY "Proc " + M->name + " line " + LTRIM(STR(M->line)) + ", "  +;
			M->info + ": " + M->model + " " + M->_1
@ 1, 0 SAY "Press Esc to abort, any other key to retry..."

IF (INKEY(0) == 27)
	@ 0,0
	@ 1,0
	RETURN .F.
END

@ 0,0
@ 1,0
RETURN .T.


***
*	undef_error(name, line, info, model, _1)
*

FUNCTION undef_error
PARAM name, line, info, model, _1

ALTD(2)

SET DEVICE TO SCREEN
@ 0, 0
@ 0, 0 SAY "Proc " + M->name + " line " + LTRIM(STR(M->line)) + ", "  +;
			M->info + ": " + " " + M->_1
@ 1, 0 SAY "Press Esc to abort, any other key to retry..."

IF (INKEY(0) == 27)
	@ 0,0
	@ 1,0
	BREAK
END

@ 0,0
@ 1,0
RETURN .T.


***
*	print_error(name, line)
*

FUNCTION print_error
PARAM name, line
PRIVATE key, file

SET DEVICE TO SCREEN
@ 0, 0
@ 0, 0 SAY "Proc " + M->name + " line " + LTRIM(STR(M->line)) +;
			", printer not ready"
@ 1, 0 SAY "Press <I>gnore, <R>etry, <B>REAK, F<ile>, <Q>uit..."

DO WHILE .T.
	key = UPPER(CHR(INKEY(0)))

	IF (M->key == "Q")
		QUIT

	ELSEIF (M->key == "I")
		@ 0,0
		@ 1,0
		RETURN .F.

	ELSEIF (M->key == "R")
		@ 0,0
		@ 1,0
		RETURN .T.

	ELSEIF (M->key == "B")
		@ 0,0
		@ 1,0
		BREAK

	ELSEIF (M->key == "F")
		@ 0, 0
		@ 1,0
		ACCEPT "Filename - " TO file
		SET PRINTER TO (M->file)
		@ 0,0
		@ 1,0
		RETURN .T.

	END
END

RETURN .F.


***
*	db_error(name, line, info)
*

FUNCTION db_error
PARAM name, line, info

ALTD(2)

SET DEVICE TO SCREEN
@ 0, 0
@ 0, 0 SAY "Proc " + M->name + " line " + LTRIM(STR(M->line)) +;
			", " + M->info

BREAK

RETURN .F.

