****************************************************************
* MENU.PRG                                                     *
* Demonstrates the use of the following commands:              *
*    SET MESSAGE TO                                            *
*    @...PROMPT                                                *
*    MENU TO                                                   *
*    SET KEY                                                   *
*    KEYBOARD                                                  *
****************************************************************
CLEAR

level1 = 1                 && memvar for 1st menu
level2 = 1                 && memvar for nested menus

SET MESSAGE TO 24          && display MESSAGEs on line 24

DO WHILE (level1 != 0)

   @ 01,10 PROMPT "one" MESSAGE "first menu"
   @ 01,20 PROMPT "two" MESSAGE "second menu"
   @ 01,30 PROMPT "three" MESSAGE "third menu"
   @ 01,40 PROMPT "four" MESSAGE "forth menu"
   MENU to level1

   IF (level1 != 0)            && esc to exit
      DO sub_menu WITH level1
   ENDIF

ENDDO


* sub_menu
PROCEDURE sub_menu

PARAMETER menu_number

PRIVATE eye

FOR eye = 1 to 9
	@ eye+2, menu_number*10 PROMPT REPLICATE(STR(eye, 1), 8)
NEXT

* assign to cursor keys procedures for shifting right and left
SET KEY 19 TO left_arrow
SET KEY 4 TO right_arrow

MENU TO level2

* release left and right arrow keys
SET KEY 19 to
SET KEY 4 to

@ 3,0 CLEAR

RETURN
*EOP sub_menu


* left_arrow
PROCEDURE left_arrow

PARAMETER pn, pl, rv

* return, up arrow, return
KEYBOARD chr(13) + chr(5) + chr(13)

RETURN
*EOP left_arrow


* right_arrow
PROCEDURE	right_arrow

PARAMETER	pn, pl, rv

* return, right arrow, return
KEYBOARD chr(13) + chr(4) + chr(13)

RETURN
* EOP right_arrow

* EOF MENU.PRG
