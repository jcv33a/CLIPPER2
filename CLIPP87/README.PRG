* Readme.prg
* Displays text files without allowing updates.

PARAMETERS file

IF PCOUNT() = 0               && File not on command line
   CLEAR
   SET MESSAGE TO 23
   @ 6,30 SAY "Select file"
   @ 8,30 SAY REPLICATE(CHR(196),11)
   @ 10,30 PROMPT "READ_ME.1ST" MESSAGE;
      Center("List of files on distribution disks")
   @ 12,30 PROMPT "ADDENDUM.DOC" MESSAGE;
      Center("New commands and functions, documentation changes, and errata")
   @ 14,30 PROMPT "ERROR.DOC" MESSAGE;
      Center("The new Clipper Error System")
   @ 16,30 PROMPT "EXTEND.DOC" MESSAGE;
      Center("The Extendy System - C and Assembly interface")
   MENU TO choice
   DO CASE
      CASE choice = 1
	     file = "READ_ME.1ST"
      CASE choice = 2
	     file = "ADDENDUM.DOC"
      CASE choice = 3
	     file = "ERROR.DOC"
      CASE choice = 4
	     file = "EXTEND.DOC"
      OTHERWISE
	     RETURN
   ENDCASE
ENDIF

IF .NOT. FILE("&file")
   ? "&file not found"
   RETURN
ENDIF

SET CURSOR OFF
CLEAR
SET COLOR TO W+/N
@ 0,0 SAY UPPER(file)
@ 1,0 TO 1,79
@ 23,0 TO 23,79
@ 24,0 SAY SPACE(7) + CHR(24) + SPACE(14) + CHR(25) + SPACE(14) +;
   + "PgUp          PgDn          Esc"
SET COLOR TO

* memoedit(file,t,l,b,r,browse,user function,line length)
MEMOEDIT(MEMOREAD(file),2,0,22,79,.F.,"",80)

SET CURSOR ON
CLEAR
QUIT

FUNCTION Center
* Syntax:   Center(<expC>,<expN>)
* Centers <expC> in width of <exp> by padding with leading spaces.
PRIVATE string, width
PARAMETERS string, width
IF PCOUNT() = 1               && If only string is passed
   width = 80                 && assume screen width
ENDIF
IF LEN(string) >= width       &&  Too long to center
   RETURN string
ENDIF
RETURN SPACE(INT(width/2) - INT(LEN(string)/2)) + string