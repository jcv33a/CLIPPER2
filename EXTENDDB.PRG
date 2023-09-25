* Filename: EXTENDDB.PRG
* Program.: Clipper Extended Library
* Author..: Tom Rettig
* Date....: November 1, 1985, September 1, 1986
* Notice..: Placed in the public domain by Tom Rettig Associates.
*           Clipper is a trademark of Nantucket.
*           dBASE and dBASE III are trademarks of Ashton-Tate.
* Notes...: User defined functions for upgrading Clipper to
*           the *latest* version of dBASE III...and beyond.
*
*   dBASE III functions:
*      ISALPHA()   ::= True if a character is alpha
*      ISLOWER()   ::= True if a character is lowercase
*      ISUPPER()   ::= True if a character is uppercase
*      LEFT()      ::= Leftmost portion of a string
*      MOD()       ::= Modulus of a number
*      READKEY()   ::= Keypress used to exit full-screen edits
*      RIGHT()     ::= Rightmost portion of a string
*      STUFF()     ::= Replace portion of a string
*
*   dBASE III functions simulated with a constant:
*      DBF()       ::= Name of the database file in use
*      FKLABEL()   ::= Name of a function key
*      FKMAX()     ::= Maximum number of function keys
*      NDX()       ::= Name of an index file in use
*      OS()        ::= Name of the operating system
*      VERSION()   ::= Name of the version of Clipper
*
*   Functions not in dBASE III or Clipper:
*      Miscellaneous:
*      --------------
*      ALLTRIM()   ::= String with leading and trailing blanks removed
*      LENNUM()    ::= Length of numeric number
*      SOUNDEX()   ::= Soundex code of a word
*      STRZERO()   ::= STR() of number with leading zeros instead of blanks
*
*      Time Data:
*      ----------
*      AMPM()      ::= 12-hour time string with "am" or "pm"
*      DAYS()      ::= Numeric days from numeric seconds
*      ELAPTIME()  ::= Time string showing elapsed time
*      TSTRING()   ::= Time string from numeric seconds
*
*
*******************************************************************************


***********************
*  dBASE III functions:
***********************

FUNCTION ISALPHA
* Syntax: ISALPHA( <expC> )
* Return: Logical true if the first character in <expC> is alpha
*
PARAMETERS cl_string
RETURN UPPER(SUBSTR(cl_string,1,1)) $ [ABCDEFGHIJKLMNOPQRSTUVWXYZ]

FUNCTION ISLOWER
* Syntax: ISLOWER( <expC> )
* Return: Logical true if the first character in <expC> is lowercase
*
PARAMETERS cl_string
RETURN SUBSTR(cl_string,1,1) $ [abcdefghijklmnopqrstuvwxyz]

FUNCTION ISUPPER
* Syntax: ISUPPER( <expC> )
* Return: Logical true if the first character in <expC> is uppercase
*
PARAMETERS cl_string
RETURN SUBSTR(cl_string,1,1) $ [ABCDEFGHIJKLMNOPQRSTUVWXYZ]

FUNCTION LEFT
* Syntax: LEFT( <expC>, <expN> )
* Return: The leftmost <expN> characters of <expC>
*
PARAMETERS cl_string, cl_len
RETURN SUBSTR(cl_string, 1, cl_len)

FUNCTION MOD
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
PARAMETERS cl_num, cl_base
PRIVATE cl_result
cl_result = cl_num % cl_base
RETURN IF( cl_base = 0, cl_num,; 
           IF(cl_result * cl_base < 0, cl_result + cl_base, cl_result) )


FUNCTION READKEY
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
ENDCASE

FUNCTION RIGHT
* Syntax: RIGHT( <expC>, <expN> )
* Return: The rightmost <expN> characters of <expC>
*
PARAMETERS cl_string, cl_len
RETURN SUBSTR(cl_string, LEN(cl_string)-cl_len+1)

FUNCTION STUFF
* Syntax: STUFF( <expC1>, <expN1>, <expN2>, <expC2> )
* Return: <expC1> with the portion starting at <expN1> and
*         going for a length of <expN2> being replaced by <expC2>
*
PARAMETERS cl_string, cl_start, cl_len, cl_replace
RETURN SUBSTR(cl_string,1,cl_start-1) + cl_replace +;
       SUBSTR(cl_string,cl_start+cl_len)


*************************************************
*  dBASE III functions simulated with a constant:
*************************************************

FUNCTION DBF
* Syntax: DBF()
* Return: The alias of the currently selected database.
* Note..: Supposed to return the name of the currently selected database file.
*
RETURN ALIAS()

FUNCTION FKLABEL
* Syntax: FKLABEL( <expN> )
* Return: The name of the <expN>th programmable function key
*
PARAMETERS cl_1
RETURN IF(cl_1<=40 .AND. cl_1 > 0, "F"+LTRIM(STR(cl_1)), [])

FUNCTION FKMAX
* Syntax: FKMAX()
* Return: The maximum number of programmable function keys on the computer
* Note..: This is specific to IBM PC/XT/AT and clones.
*
RETURN 40          && IBM specific

FUNCTION NDX
* Syntax: NDX( <expN> )
* Return: The string "NTX<expN>" 
* Note..: Supposed to return the name of the index file in the <expN> position
*         of the index file list of the command that opened the index files.
*
PARAMETERS cl_1
RETURN "NTX" + LTRIM(STR(cl_1))

FUNCTION OS
* Syntax OS()
* Return: The name of the operating system
*
RETURN "MS/PC-DOS"    && DOS specific, MicroSoft or IBM

FUNCTION VERSION
* Syntax: VERSION()
* Return: The name of current dBASE III or Clipper version
* Note..: Remember to change this when you update your Clipper version.
*
RETURN "Clipper, Autumn '86"



*****************************************
*  Functions not in dBASE III or Clipper:
*****************************************

FUNCTION ALLTRIM
* Syntax: ALLTRIM( <expC> )
* Return: The <expC> without leading or trailing blanks
*
PARAMETERS cl_string
RETURN LTRIM(TRIM(cl_string))

FUNCTION LENNUM
* Syntax: LENNUM( <expN> )
* Return: The length of <expN>
*
PARAMETERS cl_number
RETURN LEN(LTRIM(STR(cl_number)))

FUNCTION SOUNDEX
* Syntax: SOUNDEX( <expC> )
* Return: A code in the form A9999 from a name
* Note..: This soundex algorithm is by Donald E. Knuth from The Art of
*         Computer Programming, Volume 3, "Sorting and Searching", page 392.
*
PARAMETERS cl_name
PRIVATE cl_name, cl_code, cl_pointer
cl_name = UPPER(cl_name)
cl_code = SUBSTR(cl_name,1,1)
cl_pointer = 2
DO WHILE cl_pointer <= LEN(cl_name) .AND. LEN(cl_code) < 5
   DO CASE
      CASE SUBSTR(cl_name,cl_pointer,1) $ "BFPV"
         cl_code = cl_code + IF(SUBSTR(cl_code,LEN(cl_code),1)#"1","1",[])
      CASE SUBSTR(cl_name,cl_pointer,1) $ "CGJKQSXZ"
         cl_code = cl_code + IF(SUBSTR(cl_code,LEN(cl_code),1)#"2","2",[])
      CASE SUBSTR(cl_name,cl_pointer,1) $ "DT"
         cl_code = cl_code + IF(SUBSTR(cl_code,LEN(cl_code),1)#"3","3",[])
      CASE SUBSTR(cl_name,cl_pointer,1) $ "L"
         cl_code = cl_code + IF(SUBSTR(cl_code,LEN(cl_code),1)#"4","4",[])
      CASE SUBSTR(cl_name,cl_pointer,1) $ "MN"
         cl_code = cl_code + IF(SUBSTR(cl_code,LEN(cl_code),1)#"5","5",[])
      CASE SUBSTR(cl_name,cl_pointer,1) $ "R"
         cl_code = cl_code + IF(SUBSTR(cl_code,LEN(cl_code),1)#"6","6",[])
   ENDCASE
   cl_pointer = cl_pointer + 1
ENDDO
RETURN cl_code + TRIM(SUBSTR( "0000 ", LEN(cl_code) ))

FUNCTION STRZERO
* Syntax: STRZERO( <expN>, [<length> [,<decimals>]] )
* Return: The STR() of <expN> with leading zeros instead of blanks
*
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
   * Move the minus sign to appear in front of the zeros.
   RETURN "-" + REPLICATE( "0", LEN(cl_str)-LEN(LTRIM(cl_str)) ) +;
                SUBSTR( cl_str, AT("-",cl_str)+1 )
ELSE   && positive number
   RETURN REPLICATE( "0", LEN(cl_str)-LEN(LTRIM(cl_str)) ) + LTRIM(cl_str)
ENDIF

************
* Time data:
************

* A valid time string comprises eight characters in the
*   form HH:MM:SS with the range 00:00:00 to 23:59:59.
*
* Expression to validate a time string entry.
* timestring = [  :  :  ]
* @...GET timestring PICTURE [99:99:99] ;
*                    VALID VAL(       timestring   ) < 24 .AND.;
*                          VAL(SUBSTR(timestring,4)) < 60 .AND.;
*                          VAL(SUBSTR(timestring,7)) < 60

FUNCTION AMPM
* Syntax: AMPM( <time string> )
* Return: An 11 byte character string with the time in a 12-hour am/pm format. 
*
PARAMETERS cl_time
RETURN IF(        VAL(cl_time)<12, cl_time + " am",;
           IF(    VAL(cl_time)=12, cl_time + " pm",;
              STR(VAL(cl_time)-12,2) + SUBSTR(cl_time,3) + " pm" ) )

FUNCTION DAYS
* Syntax: DAYS( <seconds> )
* Return: Integer number of days from numeric seconds
* Note..: The remainder under 24 hours is returned by the TSTRING() function.
*
PARAMETERS cl_secs
RETURN INT( cl_secs / 86400 )

FUNCTION ELAPTIME
* Syntax: ELAPTIME( <start time>, <end time> )
* Return: A time string showing the difference between start and end times
* Note..: If start time is greater than end time, this algorithm assumes
*         that the day changed at midnight.  Only for timings under 24 hours.
*         86400 is the number of seconds in 24 hours.
*
PARAMETERS cl_start, cl_end
RETURN TSTRING( IF(cl_end<cl_start,86400,0)+SECS(cl_end)-SECS(cl_start) )


FUNCTION SECS
* Syntax: SECS( <time string> )
* Return: Numeric seconds as a quantity of the time string
* Note..: Seconds in time period
*         -------    -----------
*              60    1 minute
*            3600    1 hour
*           86400    1 day
*
PARAMETERS cl_time
RETURN VAL(       cl_time   ) * 3600 +;
       VAL(SUBSTR(cl_time,4)) *   60 +;
       VAL(SUBSTR(cl_time,7))


FUNCTION TSTRING
* Syntax: TSTRING( <seconds> )
* Return: A 24-hour time string from numeric seconds
* Note..: Time quantities over 24 hours are returned by the DAYS() function.
*
PARAMETERS cl_secs
RETURN STRZERO( INT(MOD(cl_secs/3600, 24)), 2, 0 ) +':'+;
       STRZERO( INT(MOD(cl_secs/  60, 60)), 2, 0 ) +':'+;
       STRZERO( INT(MOD(cl_secs     , 60)), 2, 0 )


*************************
*  External declarations:
*************************

* User-defined functions written in other languages where the object
* file is included at link time must be declared external in order for
* them to be used in a "non-explicit" syntax such as in an index
* <expression> or within a report or label form.
*
EXTERNAL DISKSPACE, GETE, HEADER, LUPDATE, RECSIZE   && in Extendc.c

* EOF: Extenddb.prg **********************************************************

