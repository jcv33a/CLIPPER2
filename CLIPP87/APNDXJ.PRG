
* SAMPLE FUNCTIONS FROM APPENDIX J
* User-defined functions that serve both as examples and
* workarounds for common programming problems.  The examples are
* divided into sections based the category of usage as follows:

* dBASE III PLUS Compatibility
* Dbf()					Name of current alias.
* FkLabel()				Function key name.
* FkMax()				Number of function keys constant.
* Mod()					Modulus of two numbers.
* Os()					Operating system name constant.
* ReadKey()				Similar to dBASE III PLUS READKEY().
* Version()				Clipper version constant.

* User Interface
* Dup_Chk()				Duplicate entry check.
* Multi_Form()			Multiple-page format screens.
* ValidTime()			Valid time string entry check.
* AcceptAt()			Keyboard input at a screen location.

* String Functions
* Currency()			Numeric to dollar format.
* StrZero()				Numeric to string with leading zeros.

* Time Functions
* AmPm()				Time string to 12-hour format.
* Days()				Numeric seconds to days.
* ElapTime()			Difference between time	strings.
* Secs()				Seconds from midnight given a time string.
* Tstring()				Numeric seconds to time string.

* Numeric Function

* LenNum()				Length of numeric including decimals.

* Arrays
* Dim2()				Array addressing with 2-dimensions.

* dBASE III PLUS COMPATIBILITY 

* The following user-defined functions provide added
* compatibility with dBASE III PLUS.   All functions in this
* section are provided on disk in the file Examplep.prg and already
* linked into EXTEND.LIB.

FUNCTION Dbf
* Syntax ...: string = Dbf()
* Author ...: Tom Rettig
* Date .....: 11/01/85, 09/01/86
*
RETURN ALIAS()

FUNCTION FkLabel
* Syntax ...: string = FkLabel(<expN>)
* Author ...: Tom Rettig
* Date .....: 11/01/85, 09/01/86
*
PARAMETERS cl_1
RETURN IF(cl_1 <= 40 .AND. cl_1 > 0, "F" + LTRIM(STR(cl_1)), [])

FUNCTION FkMax
* Syntax ...: n = FkMax()
* Author ...: Tom Rettig
* Date .....: 11/01/85, 09/01/86
*
RETURN 40		&& IBM specific

FUNCTION Mod
* Syntax ...: n = Mod(<expN1>, <expN2>)
* Author ...: Tom Rettig
* Date .....: 11/01/85, 09/01/86
*
PARAMETERS cl_num, cl_base
PRIVATE cl_result
cl_result = cl_num % cl_base
RETURN IF(cl_base = 0, cl_num,; 
         IF(cl_result * cl_base<0, cl_result + cl_base,	cl_result))

FUNCTION Os
* Syntax ...: string = Os()
* Author ...: Tom Rettig
* Date .....: 11/01/85, 09/01/86
*
RETURN "MS/PC-DOS"    && DOS specific, MicroSoft or IBM

FUNCTION ReadKey
* Syntax ...: n = ReadKey()
* Author ...: Tom Rettig
* Date .....: 11/01/85, 09/01/86
*
DO CASE
CASE LASTKEY() = 18                           && PgUp
	RETURN  6 + IF(UPDATED(), 256, 0)
CASE LASTKEY() =  3                           && PgDn
	RETURN  7 + IF(UPDATED(), 256, 0)
CASE LASTKEY() = 27                           && Esc
	RETURN 12 + IF(UPDATED(), 256, 0)
CASE LASTKEY() = 23                           && Ctrl-W
	RETURN 14 + IF(UPDATED(), 256, 0)
CASE LASTKEY() = 13                           && Enter
	RETURN 15 + IF(UPDATED(), 256, 0)
CASE LASTKEY() = 31                           && Ctrl-PgUp
   RETURN 34 + IF(UPDATED(), 256, 0)
CASE LASTKEY() = 30                           && Ctrl-PgDn
   RETURN 35 + IF(UPDATED(), 256, 0)
CASE LASTKEY() >= 32                          && type past end
   RETURN 15 + IF(UPDATED(), 256, 0)
ENDCASE

FUNCTION Version
* Syntax ...: string = Version()
*
RETURN "Clipper, Summer '87"


*** USER INTERFACE 

* The following are user-defined functions that
* demonstrate various user-interface applications.

FUNCTION Dup_Chk
* Syntax ...: logical = Dup_Chk(<variable>, <work area>)
* Author ...: Ray Love
* Date .....: June 1, 1986 modified September 1, 1987
*
PARAMETERS dup_no, workarea

* An empty value is acceptable.
IF EMPTY(dup_no)
	RETURN .T.
ENDIF

* Integrity check.
IF LEN(TRIM(dup_no)) < LEN(dup_no)
	Err_msg("Field not completely filled")
	RETURN .F.
ENDIF

* Duplicate check.
lastarea = SELECT()
SELECT workarea
SEEK dup_no
IF FOUND()
	Err_msg("Already on file")
	validation = .F.
ELSE
	validation = .T.
ENDIF
SELECT (lastarea)
RETURN validation

FUNCTION Err_msg
PARAMETERS msg
SAVE SCREEN
row = 7
msg = msg + ", press any key..."
col = INT((80 - LEN(msg))/2) - 2
@ row, col CLEAR TO row + 2, col + LEN(msg) + 4
@ row, col TO row + 2, col + LEN(msg) + 4 DOUBLE
@ row + 1, col + 2 SAY msg
INKEY(0)
RESTORE SCREEN
RETURN ""

FUNCTION Multi_Form
* Syntax ...: n = Multi_Form(<arrayC>)
* Author ...: Ira Emus
* Date .....: December 3, 1986, modified September 1, 1987
* Note(s) ..: Paging mechanism for screen formats.
*
PARAMETERS scr_arry
PRIVATE pg_count, form
*
maxpage  = LEN(scr_arry)
pg_count = 1
DO WHILE .T.
	CLEAR
	form = scr_arry[pg_count]
	SET FORMAT TO &form.
	READ
	DO CASE
	CASE LASTKEY() = 27
		*
		* Esc key.
		EXIT
	CASE LASTKEY() = 18
		*
		* PgUp key.
		IF pg_count > 1
			pg_count = pg_count - 1
		ELSE
			EXIT
		ENDIF
	OTHERWISE
		*
		* Any other key.
		IF pg_count < maxpage
			pg_count = pg_count + 1
		ELSE
			EXIT
		ENDIF
	ENDCASE
ENDDO
RETURN pg_count

FUNCTION ValidTime
* Syntax ...: logical = ValidTime(<time string>)
* Author ...: Tom Rettig
* Date .....: 11/01/85, 09/01/86
*
PARAMETERS timestring
RETURN VAL(timestring)            < 24 .AND.;
       VAL(SUBSTR(timestring, 4)) < 60 .AND.;
       VAL(SUBSTR(timestring, 7)) < 60

FUNCTION AcceptAt
* Syntax ...: string = AcceptAt(<row>, <col>, <prompt>)
* Author(s).: Ray Love and Fred Ho
* Date .....: December 1, 1986 modified September 1, 1987
*
PARAMETERS row, col, prompt
PRIVATE char, string
*
STORE "" TO char, string
@ row,col SAY prompt
DO WHILE .T.
	char = INKEY(0)
	DO CASE
	CASE char = 13
		*
		* Return key.
		EXIT
	CASE char > 31 .AND. char < 127
		*
		* Printable characters.
		string = string + CHR(char)
		@ ROW(), COL() SAY CHR(char)
	CASE (char = 8 .OR. char = 19) .AND. LEN(string) > 0
		*
		* Backspace or Leftarrow keys.
		@ ROW(), COL() - 1 SAY " "
		@ ROW(), COL() - 1 SAY ""
		string = SUBSTR(string, 1, LEN(string) - 1)
	ENDCASE
ENDDO
RETURN string


*** STRING FUNCTIONS 

FUNCTION Currency
* Syntax .: string = Currency(<expN>)
* Date ...: September 1, 1987
*
PARAMETERS p1
PRIVATE outstr
outstr = LTRIM(TRANSFORM(p1, "999,999,999,999.99"))
RETURN(SPACE(LEN(STR(p1)) - LEN(outstr) + 1) + "$" + outstr)

FUNCTION StrZero
* Syntax ...: string = StrZero(<expN1> [,<expN2> [,<expN3>]])
* Author ...: Tom Rettig
* Date .....: 11/01/85, 09/01/86
*
PARAMETERS cl_num, cl_len, cl_dec
PRIVATE cl_str
*
DO CASE
CASE PCOUNT() = 3
	cl_str = STR(cl_num, cl_len, cl_dec)
CASE PCOUNT() = 2
   cl_str = STR(cl_num,cl_len)
OTHERWISE
   cl_str = STR(cl_num)
ENDCASE

IF "-" $ cl_str
	* Negative number, move the minus sign in front of zeros.
   RETURN "-" + REPLICATE("0", LEN(cl_str) - LEN(LTRIM(cl_str))) +;
                SUBSTR( cl_str, AT("-", cl_str) + 1)
ELSE
	* Positive number.
   RETURN REPLICATE("0", LEN(cl_str) - LEN(LTRIM(cl_str))) + LTRIM(cl_str)
ENDIF

*** TIME FUNCTIONS

FUNCTION AmPm
* Syntax ...: string = AmPm(<time string>)
* Author ...: Tom Rettig
* Date .....: 11/01/85, 09/01/86
*
PARAMETERS cl_time
RETURN IF(        VAL(cl_time) < 12, cl_time + " am",;
           IF(    VAL(cl_time) = 12, cl_time + " pm",;
              STR(VAL(cl_time) - 12, 2) + SUBSTR(cl_time, 3) + " pm" ))

FUNCTION Days
* Syntax ...: n = Days(<expN>)
* Author ...: Tom Rettig
* Date .....: 11/01/85, 09/01/86
*
PARAMETERS cl_secs
RETURN INT(cl_secs / 86400)

FUNCTION ElapTime
* Syntax ...: timestring = ElapTime(<expC1>, <expC2>)
* Author ...: Tom Rettig
* Date .....: 11/01/85, 09/01/86
*
PARAMETERS cl_start, cl_end
RETURN Tstring(IF(cl_end < cl_start, 86400 , 0) +;
		 			Secs(cl_end) - Secs(cl_start))

FUNCTION Secs
* Syntax ...: n = Secs(<expC>)
* Author ...: Tom Rettig
* Date .....: 11/01/85, 09/01/86
*
PARAMETERS cl_time
RETURN VAL(       cl_time   ) * 3600 +;
       VAL(SUBSTR(cl_time,4)) *   60 +;
       VAL(SUBSTR(cl_time,7))

FUNCTION Tstring
* Syntax ...: time string = Tstring(<expN>)
* Author ...: Tom Rettig
* Date .....: 11/01/85, 09/01/86
*
PARAMETERS cl_secs
RETURN StrZero(INT(Mod(cl_secs/3600, 24)), 2, 0) + ":" +;
       StrZero(INT(Mod(cl_secs/  60, 60)), 2, 0) + ":" +;
       StrZero(INT(Mod(cl_secs     , 60)), 2, 0)

FUNCTION LenNum
* Syntax ...: n = LenNum(<expN>)
* Author ...: Tom Rettig
* Date .....: 11/01/85, 09/01/86
*
PARAMETERS cl_number
RETURN LEN(LTRIM(STR(cl_number)))

*** ARRAYS

FUNCTION Dim2
* Syntax ..: n = Dim2(<expN1>, <expN2>)
* Author...: Fred Ho
* Date ....: September 9, 1986
*
PARAMETERS x, y
RETURN (((x - 1) * rows) + y)
