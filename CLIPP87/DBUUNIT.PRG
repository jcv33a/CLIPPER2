************
*
*	Program....:  DBU
*	Filename...:  DBU.PRG
*	Author.....:  Dennis L. Dias
*	Date.......:  06/18/86
*	Purpose....:  Main Module
*
*	Copyright (c) 1986,1987 Nantucket Corp., All Rights Reserved.
*
************

PARAMETERS param1, param2

PUBLIC n_files,keystroke,lkey,frame,sframe,cur_dir,more_up,more_down,;
	   kf1,kf2,kf3,kf4,kf5,kf6,need_field,need_ntx,need_relat,need_filtr,;
	   help_code,view_err,cur_area,cur_dbf,cur_ntx,cur_fields,error_on,;
	   exit_str,page,sysfunc,func_sel,cur_func,local_func,local_sel,box_open,;
	   com_line,color1,color2,color3,color4,color5,curs_on,helpfile

******
*	The parameters are optional and have the following meaning:
*
*	- filename (.VEW or .DBF) to Browse
*
*	- color directive where:
*		/C = use color even if monochrome
*		/M = monochrome (don't use color)
*
*	Parameters may be specified in either order
******

* avoid a type mismatch
IF TYPE("param1") <> "C"
	param1 = ""

ENDIF

IF TYPE("param2") <> "C"
	param2 = ""

ENDIF

* accept parameters in either order
IF "/C" $ UPPER(param1) .OR. "/M" $ UPPER(param1)
	* color directive in param1..swap
	com_line = param2
	param2 = param1

ELSE
	* normal order
	com_line = param1

ENDIF

SET CURSOR OFF					&& cursors are for gets
SAVE SCREEN						&& the screen you save...
SET SCOREBOARD OFF				&& who's keeping score, anyhow
SET KEY 28 TO					&& some folks need help

IF (ISCOLOR() .OR. "/C" $ UPPER(param2)) .AND. .NOT. "/M" $ UPPER(param2)
	* make it pretty
	color1 = "W+/B,W+/R,B"		&& normal
	color2 = "W+/R"				&& item hilite
	color3 = "N/GR"				&& error or high intensity
	color4 = "W+/B,,,,W+/B"		&& achoice/list array..unselected is normal
	color5 = "W+/B,,,,BG/B"		&& achoice/sysmenu..true unselected

ELSE
	* monochrome
	color1 = ""
	color2 = "I"
	color3 = "W+"
	color4 = "W,,,,W"
	color5 = "W+,,,,W"

ENDIF

* let's get this baby off the ground
syscolor(1)
CLEAR

* system constants
more_up = CHR(24)			&& visual up arrow
more_down = CHR(25)			&& visual down arrow
frame = "ีอธณพอิณ"			&& box characters
lframe = "ัอธณพอฯณ"
mframe = "ยฤยณูฤภณ"
sframe = "ฺฤฟณูฤภณ"

* global variables
STORE .F. TO need_field,need_ntx,need_relat,need_filtr,box_open
STORE "" TO kf1,kf2,kf3,kf4,kf5,kf6
help_code = 0				&& let them eat cake
curs_on = .F.				&& what cursor?
cur_dir = ""				&& current directory
cur_dbf = ""				&& current data file
cur_ntx = ""				&& current controlling index file
cur_fields = ""				&& fields array for current area
cur_area = 0				&& current work area
page = 1					&& active view screen
n_files = 0					&& 14 user files max
view_file = ""				&& file to save view
view_err = ""				&& displayed by "set_view"

view_err = "by Dennis L. Dias - Copyright (c) 1986,1987 Nantucket Corp., " +;
		   "All Rights Reserved"

* search for help file
IF FILE("dbu.hlp")
	helpfile = "dbu.hlp"

ELSE

	IF FILE("\clipper\dbu.hlp")
		helpfile = "\clipper\dbu.hlp"

	ELSE
		* no help
		helpfile = ""

	ENDIF
ENDIF

**
*	Arrays declared in main module are considered public and
*	may be accessed or altered by any module in the system. The
*	matrix defines 6 work areas with 7 indexes and 64 fields
*	for each. 15 relations are also provided. All elements are
*	initialized to avoid a type mismatch.
**

* names of data files
DECLARE dbf[6]

* names of index files
DECLARE ntx1[7]
DECLARE ntx2[7]
DECLARE ntx3[7]
DECLARE ntx4[7]
DECLARE ntx5[7]
DECLARE ntx6[7]

* 15 relations
DECLARE s_relate[15]		&& source of relation
DECLARE k_relate[15]		&& key to relation
DECLARE t_relate[15]		&& target of relation

* individual field names for active list
DECLARE field_n1[64]
DECLARE field_n2[64]
DECLARE field_n3[64]
DECLARE field_n4[64]
DECLARE field_n5[64]
DECLARE field_n6[64]

* master field list..128 fields overall max
DECLARE field_list[128]

* first and last row of each screen section
DECLARE row_a[3]				&& first row of each screen section
DECLARE row_x[3]				&& last row of each screen sectionn

* constant values
row_a[1] = 6
row_x[1] = 6
row_a[2] = 10
row_x[2] = 12
row_a[3] = 16
row_x[3] = 22

* col() of data file columns
DECLARE column[6]

* current row for each data column and each screen section
DECLARE cr1[3]
DECLARE cr2[3]
DECLARE cr3[3]
DECLARE cr4[3]
DECLARE cr5[3]
DECLARE cr6[3]

* current element for each data column and each screen section
DECLARE el1[3]
DECLARE el2[3]
DECLARE el3[3]
DECLARE el4[3]
DECLARE el5[3]
DECLARE el6[3]

* titles for function keys and help screens
DECLARE func_title[8]
DECLARE menu_deflt[8]
DECLARE help_title[22]

**
* initialize arrays
**

* active data files
afill(dbf, "")

* index files for each data file
afill(ntx1, "")
afill(ntx2, "")
afill(ntx3, "")
afill(ntx4, "")
afill(ntx5, "")
afill(ntx6, "")

* fields for each data file
afill(field_n1, "")
afill(field_n2, "")
afill(field_n3, "")
afill(field_n4, "")
afill(field_n5, "")
afill(field_n6, "")

* source, key, and target for relations
afill(s_relate, "")
afill(k_relate, "")
afill(t_relate, "")

* master field list
afill(field_list, "")

* titles for function keys
func_title[1] = "Help"
func_title[2] = "Open"
func_title[3] = "Create"
func_title[4] = "Save"
func_title[5] = "Browse"
func_title[6] = "Utility"
func_title[7] = "Move"
func_title[8] = "Set"

afill(menu_deflt, 1)

* draw top of screen rows 0 thru 3
@ 0,0 SAY " F1        F2        F3        F4        F5        F6        " +;
		  "F7        F8       "
show_keys()
@ 2,0 SAY REPLICATE("ฤ", 80)
error_msg(view_err)

* when to bubble up
exit_str = "356"

* pop-up menus with parallel boolean arrays for achoice()
DECLARE help_m[1]
DECLARE help_b[1]
help_m[1] = "Help"
help_b[1] = .T.

DECLARE open_m[3]
DECLARE open_b[3]
open_m[1] = "Database"
open_m[2] = "Index"
open_m[3] = "View"
open_b[1] = "sysfunc = 0 .AND. .NOT. box_open"
open_b[2] = "sysfunc = 0 .AND. .NOT. box_open .AND. .NOT. EMPTY(cur_dbf)"
open_b[3] = "sysfunc = 0 .AND. .NOT. box_open"

DECLARE create_m[2]
DECLARE create_b[2]
create_m[1] = "Database"
create_m[2] = "Index"
create_b[1] = "sysfunc = 0"
create_b[2] = "sysfunc = 0 .AND. .NOT. EMPTY(cur_dbf)"

DECLARE save_m[2]
DECLARE save_b[2]
save_m[1] = "View"
save_m[2] = "Struct"
save_b[1] = "sysfunc = 0 .AND. .NOT. box_open"
save_b[2] = "sysfunc = 3 .AND. func_sel = 1 .AND. .NOT. box_open"

DECLARE browse_m[2]
DECLARE browse_b[2]
browse_m[1] = "Database"
browse_m[2] = "View"
browse_b[1] = "sysfunc = 0 .AND. .NOT. EMPTY(cur_dbf)"
browse_b[2] = "sysfunc = 0 .AND. .NOT. EMPTY(dbf[1])"

DECLARE utility_m[6]
DECLARE utility_b[6]
utility_m[1] = "Copy"
utility_m[2] = "Append"
utility_m[3] = "Replace"
utility_m[4] = "Pack"
utility_m[5] = "Zap"
utility_m[6] = "Run"
afill(utility_b, "sysfunc = 0 .AND. .NOT. EMPTY(cur_dbf)", 1, 5)
utility_b[6] = "sysfunc = 0"

DECLARE move_m[4]
DECLARE move_b[4]
move_m[1] = "Seek"
move_m[2] = "Goto"
move_m[3] = "Locate"
move_m[4] = "Skip"
afill(move_b, "sysfunc = 5 .AND. .NOT. box_open")
move_b[1] = move_b[1] + " .AND. .NOT. EMPTY(cur_ntx)"

DECLARE set_m[3]
DECLARE set_b[3]
set_m[1] = "Relation"
set_m[2] = "Filter"
set_m[3] = "Fields"
set_b[1] = "sysfunc = 0 .AND. .NOT. box_open .AND. .NOT. EMPTY(dbf[2])"
set_b[2] = "sysfunc = 0 .AND. .NOT. box_open .AND. .NOT. EMPTY(cur_dbf)"
set_b[3] = "sysfunc = 0 .AND. .NOT. box_open .AND. .NOT. EMPTY(cur_dbf)"

* titles for help screens
help_title[1] = "GENERAL INFORMATION"
help_title[2] = "FIELDS LISTS"
help_title[3] = "BROWSE"
help_title[4] = "CREATE / MODIFY STRUCTURE"
help_title[5] = "CREATE INDEX"
help_title[6] = "OPEN DATABASE"
help_title[7] = "FILTERS"
help_title[8] = "OPEN INDEX"
help_title[9] = "SET RELATIONSHIP"
help_title[10] = "LOCATE EXPRESSION"
help_title[11] = "SDF / DELIMITED"
help_title[12] = "COPY"
help_title[13] = "SEEK EXPRESSION"
help_title[14] = "GO TO RECORD NUMBER"
help_title[15] = "APPEND"
help_title[16] = "FOR / WHILE"
help_title[17] = "SCOPE"
help_title[18] = "DOS WINDOW"
help_title[19] = "MEMO EDITOR"
help_title[20] = "SKIP <n> RECORDS"
help_title[21] = "SAVE / RESTORE VIEW"
help_title[22] = "REPLACE"

* arrays for file names in default directory
DECLARE dbf_list[adir("*.DBF") + 20]			&& directory of data files
DECLARE ntx_list[adir("*" + INDEXEXT()) + 20]	&& directory of index files
DECLARE vew_list[adir("*.VEW") + 20]			&& directory of view files

* fill the arrays with filenames
array_dir("*.DBF",dbf_list)
array_dir("*" + INDEXEXT(),ntx_list)
array_dir("*.VEW",vew_list)

* default to set view
local_func = 0				&& local menu
local_sel = 1				&& local menu item
keystroke = 0				&& current keystroke
lkey = 0					&& previous keystroke
sysfunc = 0					&& system menu
func_sel = 1				&& system menu item

* clean up and process command line if entered
com_line = LTRIM(TRIM(UPPER(com_line)))

IF .NOT. EMPTY(com_line)

	DO CASE

		CASE RAT(".", com_line) > RAT("\", com_line)
			* file extension entered
			IF .NOT. FILE(com_line)
				* file must exist
				com_line = ""

			ENDIF

		CASE FILE(com_line + ".VEW")
			* look for file name with .VEW extension
			com_line = com_line + ".VEW"

		CASE FILE(com_line + ".DBF")
			* look for file name with .DBF extension
			com_line = com_line + ".DBF"

		OTHERWISE
			* file not found..ignore command line
			com_line = ""

	ENDCASE

	IF .NOT. EMPTY(com_line)
		* command line file exists

		IF RAT(".VEW", com_line) = LEN(com_line) - 3
			* assume a valid .VEW file
			view_file = com_line
			set_from(.F.)							&& restore view
			KEYBOARD CHR(-4) + CHR(24) + CHR(13)	&& browse view

		ELSE
			* assume a valid .DBF file
			dbf[1] = com_line						&& primary database
			USE &com_line							&& open data file
			all_fields(1, M->field_n1)				&& all fields active
			KEYBOARD CHR(-4) + CHR(13)				&& browse database

		ENDIF

		IF .NOT. EMPTY(dbf[1])
			* view established..cancel display of message
			view_err = ""

		ENDIF
	ENDIF
ENDIF

DO WHILE .T.
	* forever
	cur_func = M->sysfunc		&& to recognize a change

	DO CASE

		CASE M->sysfunc = 5
			* browse

			IF .NOT. EMPTY(dbf[1])
				* there is a view..do the set up
				setup()

				IF EMPTY(M->view_err)
					* set up successful so far
					cur_fields = "field_n" + SUBSTR("123456", M->cur_area, 1)

					DO CASE

						CASE M->func_sel = 1 .AND. EMPTY(M->cur_dbf)
							* browse one file
							view_err = "No data file in current select area"

						CASE M->func_sel = 1 .AND. EMPTY(&cur_fields[1])
							* browse one file
							view_err = "No active field list in current select area"

						CASE EMPTY(field_list[1])
							* browse entire view
							view_err = "No active field list"

						OTHERWISE
							* ok to browse

							IF M->func_sel = 1
								* browse one file..hi-lite the name
								hi_cur()

							ENDIF

							help_code = 3
							DO browse
							dehi_cur()

					ENDCASE
				ENDIF

			ELSE
				view_err = "No database in use"

			ENDIF

			sysfunc = 0			&& back to the main view screen

		CASE M->sysfunc = 3

			IF M->func_sel = 1
				* modify structure
				hi_cur()
				help_code = 4
				DO modi_stru
				dehi_cur()

				IF EMPTY(M->cur_dbf)
					* new structure not created..kill dummy View channel
					cur_area = 0

				ENDIF

			ELSE
				* create or re-create index

				IF EMPTY(M->cur_dbf)
					view_err = "No data file in current select area"

				ELSE
					help_code = 5
					DO make_ntx

				ENDIF
			ENDIF

			sysfunc = 0			&& back to the main view screen

		CASE M->sysfunc = 6 .AND. M->func_sel <> 6
			* copy/append/replace/pack/zap

			IF EMPTY(M->cur_dbf)
				view_err = "No data file in current select area"
				sysfunc = 0		&& back to the main view screen
				LOOP

			ENDIF

			IF .NOT. EMPTY(dbf[1])
				* do view set up
				setup()

			ENDIF

			IF .NOT. EMPTY(M->view_err)
				* error in set up
				sysfunc = 0		&& back to the main view screen
				LOOP

			ENDIF

			hi_cur()

			DO CASE

				CASE M->func_sel < 4
					* copy, append, or replace
					DO capprep

				CASE M->func_sel = 4
					* pack command

					IF rsvp("Pack " + M->cur_dbf + "? (Y/N)") = "Y"
						* pack confirmed
						stat_msg("Packing " + M->cur_dbf)
						SELECT (M->cur_area)
						PACK
						stat_msg(M->cur_dbf + " Packed")

					ENDIF

				CASE M->func_sel = 5
					* zap command

					IF rsvp("Zap " + M->cur_dbf + "? (Y/N)") = "Y"
						* zap confirmed
						stat_msg("Zapping " + M->cur_dbf)
						SELECT (M->cur_area)
						ZAP
						stat_msg(M->cur_dbf + " Zapped")

					ENDIF

			ENDCASE

			dehi_cur()
			sysfunc = 0			&& back to the main view screen

		CASE M->sysfunc = 6 .AND. M->func_sel = 6
			* run a DOS command or program
			@ 4,0 CLEAR

			IF .NOT. EMPTY(dbf[1])
				* set view before a possible chdir
				setup()

			ENDIF

			IF .NOT. EMPTY(M->view_err)
				* display message and continue for possible
				* correction of "File not found", etc.
				error_msg(M->view_err, 24, 7)
				view_err = ""

			ENDIF

			run_com = ""
			com_line = ""
			help_code = 18

			DO WHILE .NOT. q_check()
				* re-draw top 3 rows after each command
				@ 0,0 SAY " F1        F2        F3        F4        " +;
						  "F5        F6        F7        F8       "
				show_keys()
				@ 2,0 SAY REPLICATE("ฤ", 80)
				@ 24,0 SAY "Run อ" + CHR(16) + " "

				* accept command entry
				run_com = enter_rc(M->com_line,24,7,127,"@KS73")

				IF .NOT. EMPTY(M->run_com) .AND. M->keystroke = 13
					* only the enter key will run the command
					com_line = M->run_com		&& preserve previous command
					@ 24,0						&& clear the command entry

					SET CURSOR ON
					RUN &run_com
					SET CURSOR OFF

				ELSE
					* check for menu request
					sysmenu()

					IF M->local_func = 1
						DO syshelp

					ENDIF
				ENDIF
			ENDDO

			* re-establish the environment
			@ 3,0 CLEAR

			* rebuild directory arrays..must keep current
			DECLARE dbf_list[adir("*.DBF") + 20]
			DECLARE ntx_list[adir("*" + INDEXEXT()) + 20]
			DECLARE vew_list[adir("*.VEW") + 20]

			* fill the arrays with filenames..data files
			array_dir("*.DBF",dbf_list)

			* index files
			array_dir("*" + INDEXEXT(),ntx_list)

			* view files
			array_dir("*.VEW",vew_list)
			cur_area = 0		&& re-draw view screen
			sysfunc = 0			&& back to the main view screen

		OTHERWISE
			* main view screen..sysfunc = 0
			help_code = 1
			DO set_view

			IF M->keystroke = 27
				* exit confirmed in set_view
				SET TYPEAHEAD TO 0	&& remaining keystrokes to DOS
				CLOSE DATABASES		&& kill the view
				RESTORE SCREEN		&& ...may be your own
				SET CURSOR ON		&& always leave them laughing
				SET COLOR TO		&& back to normal
				QUIT				&& -=[Bye]=-

			ENDIF
	ENDCASE
ENDDO


* EOF DBU.PRG
************
*
*	Program....:  DBU
*	Filename...:  DBUVIEW.PRG
*	Author.....:  Dennis L. Dias
*	Date.......:  06/18/86
*	Purpose....:  View Maintenance Module
*
*	Copyright (c) 1986,1987 Nantucket Corp., All Rights Reserved.
*
************


******
*	set_view
*
*	select files, set fields, relations, filters
*
*	note: only data files are opened and closed when
*		  requested..all other aspects of the View are
*		  set when needed by calling the setup() function
*		  in the utilities module
******
PROCEDURE set_view

PRIVATE bar_line,empty_line,ntx,field_n,el,cur_row,t_row,ch_draw,;
		strn,is_redraw,is_insert,horiz_keys,prev_area,i

* establish local array for index file names (no path or extension)
DECLARE d_array[LEN(M->ntx1)]

* initialize local variables
horiz_keys = CHR(4) + CHR(19) + CHR(1) + CHR(6)	&& quick return from bar_menu
bar_line = ""		&& built by bline()
empty_line = ""		&& ditto
prev_area = 0		&& detect horizontal movement (zero to initialize)
ch_draw = .F.		&& switch for channel function

* global help code
help_code = 1

* global key value..zero is convenient for branch to "otherwise" case below
keystroke = 0

* special attention for open and create menu defaults
set_deflt()

IF .NOT. EMPTY(M->view_err)
	* with soap it's loaded
	error_msg(M->view_err)
	view_err = ""

ENDIF

DO WHILE .NOT. q_check()
	* one big switch..exit condition determined elsewhere

	DO CASE

		CASE M->cur_area = 0
			* draw View screen..see if complete reset needed
			cur_area = aseek(M->dbf, M->cur_dbf)

			IF M->cur_area = 0
				* complete reset needed

				FOR i = 1 TO 3
					* current rows and current elements
					STORE row_a[M->i] TO cr1[M->i],cr2[M->i],cr3[M->i],;
										 cr4[M->i],cr5[M->i],cr6[M->i]
					STORE 1 TO el1[M->i],el2[M->i],el3[M->i],el4[M->i],;
							   el5[M->i],el6[M->i]

				NEXT

				* global variables
				cur_dbf = dbf[1]
				STORE 1 TO cur_area, page

				* set default for open and create menus
				set_deflt()

			ENDIF

			* draw the main View screen
			draw_view(0)

		CASE M->cur_area <> M->prev_area
			* horizontal movement detected (or initial entry)
			cur_dbf = dbf[M->cur_area]	&& current data file

			* save on function calls
			strn = SUBSTR("123456", M->cur_area, 1)

			* set variables to matrix into current data channel
			ntx = "ntx" + strn
			field_n = "field_n" + strn
			el = "el" + strn

			* use temporary variable for adjustment
			t_row = "cr" + strn

			IF M->page > 1 .AND. M->prev_area <> 0
				* adjust element by (old row - new row)
				&el[M->page] = &el[M->page] +;
							   &cur_row[M->page] - &t_row[M->page]

				* new row = old row
				&t_row[M->page] = &cur_row[M->page]

			ENDIF

			* set to current data channel
			cur_row = M->t_row

			* clear for next loop
			prev_area = M->cur_area

		CASE M->keystroke = 19
			* left arrow..move one channel to the left

			IF M->cur_area > 1
				* ok to move left
				cur_area = M->cur_area - 1

			ENDIF

			keystroke = 0

		CASE M->keystroke = 1
			* home key..extreme left
			cur_area = 1
			keystroke = 0

		CASE M->keystroke = 4
			* right arrow..move one channel to the right

			IF M->cur_area < 6 .AND. .NOT. EMPTY(M->cur_dbf)
				* ok to move right..next channel
				cur_area = M->cur_area + 1

				IF EMPTY(dbf[M->cur_area])
					* inactive channel..cannot enter indexes or fields
					page = 1
					set_deflt()

				ENDIF
			ENDIF

			keystroke = 0

		CASE M->keystroke = 6
			* end key..move to extreme right

			IF M->cur_area < 6 .AND. .NOT. EMPTY(M->cur_dbf)
				* ok to move right..determine last active channel
				i = afull(M->dbf)

				IF M->i < 6 .AND. (M->page = 1 .OR. M->cur_area = M->i)
					* move to inactive channel
					cur_area = M->i + 1

					* cannot enter indexes or fields
					page = 1
					set_deflt()

				ELSE
					* move to last active channel
					cur_area = M->i

				ENDIF

			ENDIF

			keystroke = 0

		CASE M->keystroke = 18 .OR. M->keystroke = 5
			* PgUp or up arrow

			IF M->page > 1
				* ok to move up
				page = M->page - 1
				set_deflt()

			ENDIF

			keystroke = 0

		CASE M->keystroke = 3 .OR. M->keystroke = 24
			* PgDn or down arrow

			IF M->page < 3 .AND. .NOT. EMPTY(M->cur_dbf)
				* ok to move down
				page = M->page + 1
				set_deflt()

				* adjust row and element for smooth cursor movement
				&el[M->page] = &el[M->page] -;
							   (&cur_row[M->page] - row_a[M->page])
				&cur_row[M->page] = row_a[M->page]

			ENDIF

			keystroke = 0

		CASE M->keystroke = 22 .OR. M->keystroke = 13 .OR.;
			 isdata(M->keystroke) .OR. (M->local_func = 2 .AND.;
			 (M->local_sel = 1 .OR. M->local_sel = 2)) .OR.;
			 (M->local_func = 8 .AND. M->local_sel = 3)
			* insert or enter or local menu item

			IF M->local_func <> 0
				* local menu item..set page to menu selection
				page = M->local_sel
				set_deflt()

				* menu select behaves like insert
				keystroke = 22

			ENDIF

			IF M->page = 1 .AND. M->n_files < 14
				* open a data file
				is_redraw = M->cur_area < 6 .AND. (M->keystroke = 22 .OR.;
												  EMPTY(M->cur_dbf))

				is_insert = (M->keystroke = 22 .AND.;
							.NOT. EMPTY(M->cur_dbf) .AND. M->cur_area < 6)

				IF M->is_redraw
					* open up dummy channel on screen
					draw_view(M->cur_area)

					* a dummy for a dummy
					syscolor(2)
					@ row_a[1], column[M->cur_area] + 2 SAY SPACE(8)
					syscolor(1)

				ELSE
					* hilite the affected View item
					hi_cur()

				ENDIF

				* call the open function and save the return status
				ch_draw = open_dbf(M->is_insert, .F.)

				IF M->ch_draw
					* update screen with "channel" function
					channel(&ntx, &field_n, &el, &cur_row,;
							M->cur_area, M->cur_area)

					* new current data file
					cur_dbf = dbf[M->cur_area]

				ELSE
					* put the screen back the way it was

					IF M->is_redraw
						* kill the dummy
						draw_view(0)

					ELSE
						* un-hilite
						dehi_cur()

					ENDIF
				ENDIF

			ELSE

				IF M->page > 1
					* pages 2 and 3 handled by channel function
					channel(&ntx, &field_n, &el, &cur_row,;
							M->cur_area, M->cur_area)

				ELSE
					error_msg("Too many files open")

				ENDIF
			ENDIF

			keystroke = 0

		CASE M->keystroke = 7
			* delete

			IF M->page = 1 .AND. .NOT. EMPTY(M->cur_dbf)
				* close this work area and shift subsequent ones down
				stat_msg("Closing File")
				clear_dbf(M->cur_area, 2)

				IF M->cur_area = 6
					* no need to re-write screen..clear windows
					ch_draw = .T.
					channel(&ntx, &field_n, &el, &cur_row,;
							M->cur_area, M->cur_area)

				ELSE
					* re-write screen
					draw_view(0)

				ENDIF

				* new current data file
				cur_dbf = dbf[M->cur_area]

				* clear status message
				stat_msg("")

			ELSE

				IF M->page > 1
					* pages 2 and 3 handled by channel function
					channel(&ntx, &field_n, &el, &cur_row,;
							M->cur_area, M->cur_area)

				ENDIF
			ENDIF

			keystroke = 0

		CASE M->local_func = 8 .AND. M->local_sel = 1
			* "set_relation" selected from pull-down menu
			set_relation()
			keystroke = 0

		CASE M->local_func = 8 .AND. M->local_sel = 2
			* "set filter" selected from pull-down menu
			get_filter()
			keystroke = 0

		CASE M->local_func = 2 .AND. M->local_sel = 3
			* "restore View from .VEW file" selected from pull-down menu
			set_from(.T.)

			IF .NOT. EMPTY(M->view_file) .AND. M->keystroke = 13
				* View set..re-write screen
				cur_area = 0
				cur_dbf = ""

			ENDIF

			keystroke = 0

		CASE M->local_func = 4
			* "save View" selected from pull-down menu
			save_view()
			keystroke = 0

		CASE M->local_func = 1
			* "help" selected from pull-down menu
			DO syshelp
			keystroke = 0

		OTHERWISE
			* all pending cases have been processed

			DO CASE

				CASE M->page = 1
					* get keystroke if pending

					IF .NOT. key_ready()
						* no key pending..hilite the current item
						hi_cur()

						* wait for keystroke
						read_key()

						* re-write the current item as normal
						dehi_cur()

					ENDIF

				CASE M->page = 2
					* copy index file names to "name only" array
					d_copy(&ntx)

					* do the menu selection on the main View screen
					bar_menu(column[M->cur_area] + 2,;
							 column[M->cur_area] + 9, M->d_array)

				CASE M->page = 3
					* do the menu selection on the main View screen
					bar_menu(column[M->cur_area] + 1,;
							 column[M->cur_area] + 10, &field_n)

			ENDCASE

			IF M->keystroke = 27

				IF rsvp("Exit to DOS? (Y/N)") <> "Y"
					keystroke = 0

				ENDIF
			ENDIF
	ENDCASE
ENDDO

IF M->sysfunc = 3 .AND. M->func_sel = 1 .AND. EMPTY(M->cur_dbf)
	* indicate create structure by opening a dummy channel
	draw_view(M->cur_area)

ENDIF

RETURN


******
*	channel()
*
*	process one channel for "set view"
*
*	note: the array identifiers associated with the current
*		  channel are passed to this function in order to
*		  avoid the repeated macro expansion inherent in
*		  constructs like &ntx[&el[]]
******
FUNCTION channel

PARAMETERS ch_ntx, ch_field_n, ch_el, ch_cur_row, n, dbf_num
PRIVATE f_n, is_ins, temp_buff, d_item

DO CASE

	CASE M->ch_draw
		* update the screen for channel "n"..clear windows
		scroll(row_a[2], column[M->n], row_x[2], column[M->n] + 11, 0)
		scroll(row_a[3], column[M->n], row_x[3], column[M->n] + 11, 0)

		* display the specified file name "dbf_num"
		@ row_a[1],column[M->n] + 2 SAY pad(name(dbf[M->dbf_num]), 8)

		IF .NOT. EMPTY(ch_ntx[1])
			* list the index files if any
			d_copy(M->ch_ntx)
			list_array(row_a[2],column[M->n] + 2,row_x[2],column[M->n] + 9,;
					   M->d_array,ch_el[2] - (ch_cur_row[2] - row_a[2]))

		ENDIF

		* display field list
		list_array(row_a[3], column[M->n] + 1, row_x[3], column[M->n] + 10,;
				   M->ch_field_n, ch_el[3] - (ch_cur_row[3] - row_a[3]))

		ch_draw = .F.				&& reset the screen update flag

	CASE M->keystroke = 22 .OR. M->keystroke = 13 .OR. isdata(M->keystroke)
		* insert or enter or character key

		IF isdata(M->keystroke)
			* forward character to GET system
			KEYBOARD CHR(M->keystroke)

		ENDIF

		* remember if insert
		is_ins = (M->keystroke = 22)

		DO CASE

			CASE M->page = 2 .AND. (M->n_files < 14 .OR. (M->keystroke <> 22;
				 .AND. .NOT. EMPTY(ch_ntx[ch_el[2]])))
				* add or change an index file in the current list..save window
				temp_buff = SAVESCREEN(row_a[2], column[M->n] + 1,;
									   row_x[2], column[M->n] + 11)

				IF M->is_ins
					* insert

					IF ch_el[2] + row_x[2] - ch_cur_row[2] = afull(M->ch_ntx)
						* last filename will scroll off the window
						@ row_x[2], column[M->n] + 11 SAY M->more_down

					ENDIF

					IF ch_cur_row[2] < row_x[2]
						* open a blank row..scroll down
						scroll(ch_cur_row[2], column[M->n] + 1,;
									row_x[2], column[M->n] + 10, -1)

					ENDIF

					* show entry blank
					d_item = SPACE(8)

				ELSE
					* show the affected View item
					d_item = pad(name(ch_ntx[ch_el[2]]), 8)

				ENDIF

				* hilite the affected View item
				syscolor(2)
				@ ch_cur_row[2],column[M->n] + 2 SAY M->d_item
				syscolor(1)

				* get selection
				f_n = get_ntx(ch_cur_row[2], column[M->n] + 2,;
							  ch_ntx[ch_el[2]], M->is_ins)

				IF .NOT. M->f_n == ch_ntx[ch_el[2]] .AND. .NOT. EMPTY(M->f_n)
					* index file added to list
					need_ntx = .T.

					IF M->is_ins
						* make room for new index file name
						array_ins(M->ch_ntx,ch_el[2])

					ENDIF

					* assign filename to array element
					ch_ntx[ch_el[2]] = M->f_n

					IF ch_el[2] = 1
						* controlling index..remove relations where target
						not_target(M->n, .T.)

					ENDIF

					* display the name of the newly selected index file
					@ ch_cur_row[2],column[M->n] + 2;
					SAY pad(name(ch_ntx[ch_el[2]]), 8)

				ELSE
					* aborted entry..restore the window as it was
					RESTSCREEN(row_a[2], column[M->n] + 1,;
							   row_x[2], column[M->n] + 11, M->temp_buff)

				ENDIF

			CASE M->page = 3
				* add or change a fieldname in the current list..save window
				temp_buff = SAVESCREEN(row_a[3], column[M->n] + 1,;
									   row_x[3], column[M->n] + 11)

				IF M->is_ins
					* insert

					IF ch_el[3] + row_x[3] - ch_cur_row[3] = afull(M->ch_field_n)
						* last fieldname will scroll off the window
						@ row_x[3], column[M->n] + 11 SAY M->more_down

					ENDIF

					IF ch_cur_row[3] < row_x[3]
						* open a blank row..scroll down
						scroll(ch_cur_row[3], column[M->n] + 1,;
									row_x[3], column[M->n] + 10, -1)

					ENDIF

					* show entry blank
					d_item = SPACE(10)

				ELSE
					* show the affected View item
					d_item = pad(ch_field_n[ch_el[3]], 10)

				ENDIF

				* hilite the affected View item
				syscolor(2)
				@ ch_cur_row[3],column[M->n] + 1 SAY M->d_item
				syscolor(1)

				* get selection
				f_n = get_field(ch_cur_row[3], column[M->n] + 1, M->n,;
								ch_field_n[ch_el[3]])

				IF (M->is_ins .OR. .NOT. M->f_n == ch_field_n[ch_el[3]]);
				   .AND. .NOT. EMPTY(M->f_n)
					* fieldname added to list
					need_field = .T.

					IF M->is_ins
						* make room for new field name
						array_ins(M->ch_field_n,ch_el[3])

					ENDIF

					* assign fieldname to array element
					ch_field_n[ch_el[3]] = M->f_n

					* display the name of the newly selected field
					@ ch_cur_row[3],column[M->n] + 1;
					SAY pad(ch_field_n[ch_el[3]], 10)

				ELSE
					* aborted entry..restore the window as it was
					RESTSCREEN(row_a[3], column[M->n] + 1,;
							   row_x[3], column[M->n] + 11, M->temp_buff)

				ENDIF
		ENDCASE

	CASE M->keystroke = 7
		* delete

		DO CASE

			CASE M->page = 2 .AND. .NOT. EMPTY(ch_ntx[ch_el[2]])
				* remove index file from list
				need_ntx = .T.	&& must reset

				IF ch_el[2] = 1
					* primary index..remove relations where target
					not_target(M->n, .T.)

				ENDIF

				* select work area n
				SELECT (M->n)

				* ensure that n_files does not exceed actual open files
				CLOSE INDEX

				* remove the filename from the list
				array_del(M->ch_ntx,ch_el[2])

				* decrement global file counter
				n_files = M->n_files - 1

				IF ch_cur_row[2] < row_x[2]
					* scroll up to remove filename from screen
					scroll(ch_cur_row[2],column[M->n] + 1,;
								row_x[2],column[M->n] + 9,1)

				ENDIF

				* fill in blank row at bottom of window
				@ row_x[2],column[M->n] + 2;
				SAY pad(name(ch_ntx[ch_el[2] + row_x[2] - ch_cur_row[2]]), 8)

				IF afull(M->ch_ntx) - ch_el[2] = row_x[2] - ch_cur_row[2]
					* remove the "more_down" indicator from the screen
					@ row_x[2],column[M->n] + 11 SAY " "

				ENDIF

			CASE M->page = 3 .AND. .NOT. EMPTY(ch_field_n[ch_el[3]])
				* delete a fieldname from the current list
				need_field = .T.	&& must reset

				* remove the fieldname from the list
				array_del(M->ch_field_n,ch_el[3])

				IF ch_cur_row[3] < row_x[3]
					* scroll up to remove fieldname from screen
					scroll(ch_cur_row[3],column[M->n] + 1,;
								row_x[3],column[M->n] + 10,1)

				ENDIF

				* fill in blank row at bottom of window
				@ row_x[3],column[M->n] + 1;
				SAY pad(ch_field_n[ch_el[3] + row_x[3] - ch_cur_row[3]], 10)

				IF afull(M->ch_field_n) - ch_el[3] = row_x[3] - ch_cur_row[3]
					* remove the "more_down" indicator from the screen
					@ row_x[3],column[M->n] + 11 SAY " "

				ENDIF
		ENDCASE
ENDCASE

RETURN 0


******
*	bar_menu()
*
*	verticle light bar selection menu for the main View screen
*
*	note: this routine is expected to return a value in "keystroke"
*		  to be processed by "set_view"
******
FUNCTION bar_menu

PARAMETERS l, r, array
PRIVATE num_d, num_full, cur_el, rel_row, x, t, b

* look ahead at next keystroke
keystroke = NEXTKEY()

IF CHR(M->keystroke) $ M->horiz_keys
	* improve performance of horizontal cursor movement with quick return
	INKEY()		&& remove character from typeahead buffer
	RETURN 0

ENDIF

* avoid costly array access by getting top and bottom of window to "t" and "b"
t = row_a[M->page]
b = row_x[M->page]

* get the number of active elements
num_full = afull(M->array)

* and the number of displayable elements
num_d = M->num_full

IF M->num_d < LEN(M->array)
	* first empty element is included
	num_d = M->num_d + 1

	* achoice() won't display a null string
	array[M->num_d] = " "

ENDIF

* determine column offset to put "more_up" and "more_down" indicators
x = IF(M->r - M->l > 7, 1, 2)

* it's all relative to achoice()
rel_row = &cur_row[M->page] - M->t

* discard returned value
achoice(M->t, M->l, M->b, M->r, M->array, .T.,;
		"bar_func", &el[M->page], M->rel_row)

* change back to absolute
&cur_row[M->page] = M->rel_row + M->t

IF array[M->num_d] == " "
	* kill the dummy
	array[M->num_d] = ""

ENDIF

* check for menu request
sysmenu()

RETURN 0


******
*	bar_func()
*
*	function to be called from achoice() specifically for bar_menu()
******
FUNCTION bar_func

PARAMETERS mode, bar_el, row
PRIVATE ret_code

* get keystroke
keystroke = LASTKEY()

* assume continue
ret_code = 2

* maintain variables from above
&el[M->page] = M->bar_el
rel_row = M->row

IF M->error_on
	* erase error message
	error_off()

ENDIF

DO CASE

	CASE M->mode = 0
		* idle..maintain correct "more_up" and "more_down" indicators
		@ M->t, M->r + M->x SAY IF(M->bar_el > M->row + 1, M->more_up, " ")
		@ M->b, M->r + M->x SAY IF(M->num_full >;
								   (M->bar_el + M->b - M->t - M->row),;
								M->more_down, " ")

	CASE M->mode = 1 .OR. M->mode = 2
		* attempt to cursor past top or end of list
		ret_code = 0

	CASE M->mode = 3
		* keystroke exception

		DO CASE

			CASE CHR(M->keystroke) $ M->horiz_keys
				* horizontal cursor key
				ret_code = 0

			CASE M->keystroke = 27
				* abort selection
				ret_code = 0

			CASE M->keystroke = 13
				* replace a View item
				ret_code = 1

			CASE isdata(M->keystroke)
				* character key...entry in place
				ret_code = 1

			CASE M->keystroke = 22 .OR. M->keystroke = 7
				* ins, del
				ret_code = 1

			CASE menu_key() <> 0
				* menu request
				ret_code = 0

		ENDCASE

	CASE M->mode = 4
		* nothing selectable
		ret_code = 0

ENDCASE

RETURN M->ret_code


******
*	list_array()
*
*	list array elements vertically in window
******
FUNCTION list_array

PARAMETERS t, l, b, r, array, top_el
PRIVATE bottom_el, num_full, x

IF .NOT. EMPTY(array[M->top_el])
	* something to list..calculate number of last element in window
	bottom_el = M->top_el + M->b - M->t

	* get number of non-empty elements
	num_full = afull(M->array)

	* determine column offset of "more_up" and "more_down" indicators
	x = IF(M->r - M->l > 7, 1, 2)

	IF M->top_el > 1 .AND. M->bottom_el = M->num_full + 1
		* prevent achoice() from making adjustments
		array[M->bottom_el] = " "

	ENDIF

	* display only and return without waiting for a keystroke
	syscolor(4)
	achoice(M->t, M->l, M->b, M->r, M->array, .F., "", M->top_el)
	syscolor(1)

	* update status of "more_up" and "more_down" indicators
	@ M->t, M->r + M->x SAY IF(M->top_el > 1, M->more_up, " ")
	@ M->b, M->r + M->x SAY IF(M->bottom_el < M->num_full, M->more_down, " ")

	IF array[M->bottom_el] == " "
		* restore to null string
		array[M->bottom_el] = ""

	ENDIF
ENDIF

RETURN 0


******
*	set_deflt()
*
*	set defaults for open and create pull-down menus
******
FUNCTION set_deflt

IF M->page = 2
	* cursor in index file list..default to open index and create index
	STORE 2 TO menu_deflt[2], menu_deflt[3]

ELSE
	* default to open database and create database
	STORE 1 TO menu_deflt[2], menu_deflt[3]

ENDIF

RETURN 0


******
*	bline()
*
*	build a new bar line for the main View screen
******
FUNCTION bline

PARAMETERS num_slots
PRIVATE i, k

IF num_slots < 6
	* add one empty slot
	num_slots = num_slots + 1

ENDIF

* the first slot is diferent than the rest
bar_line = "ออออออออออออ"
empty_line = ""

k = 1

DO WHILE M->k < M->num_slots
	* each new slot separated from previous by a vertical line
	bar_line = M->bar_line + "ัออออออออออออ"
	empty_line = M->empty_line + SPACE(12) + "ณ"

	* next
	k = M->k + 1

ENDDO

* calculate value to center the entire View screen
i = INT((80 - LEN(M->bar_line)) / 2)

FOR k = 1 TO M->num_slots
	* establish screen columns for all active slots
	column[M->k] = M->i + (13 * (M->k - 1))

NEXT

RETURN 0


******
*	draw_view()
*
*	fill the main View screen
*
*	note: the parameter indicates which channel is to be the
*		  dummy for operations in progress, zero for no dummy
******
FUNCTION draw_view

PARAMETERS blank_area
PRIVATE i, j, ntx, field_n, el, cur_row, strnum

* get number of active work areas
i = afull(M->dbf)

IF M->i < 6 .AND. blank_area <> 0
	* add one for the dummy
	i = M->i + 1

ENDIF

* build the bar_line and empty_line strings
bline(M->i)

* clear the deck and draw a blank template
@ 4,0 CLEAR

* page 1..names of data files
@ row_a[1] - 2,37 SAY "Files"
@ row_a[1] - 1,column[1] SAY M->bar_line
@ row_a[1],column[1] SAY M->empty_line

* page 2..names of index files
@ row_a[2] - 2,36 SAY "Indexes"
@ row_a[2] - 1,column[1] SAY M->bar_line
@ row_a[2],column[1] SAY M->empty_line
@ row_a[2] + 1,column[1] SAY M->empty_line
@ row_a[2] + 2,column[1] SAY M->empty_line

* page 3..active fields lists
@ row_a[3] - 2,37 SAY "Fields"
@ row_a[3] - 1,column[1] SAY M->bar_line

FOR i = row_a[3] TO row_x[3]
	* complete the blank template
	@ M->i,column[1] SAY M->empty_line

NEXT

i = 1
j = 1

DO WHILE M->j <= 6

	IF EMPTY(dbf[M->i])
		* no more active work areas
		EXIT

	ENDIF

	IF M->j <> M->blank_area
		* channel needs filling
		strnum = SUBSTR("123456", M->i, 1)

		* set to channel "i"
		ntx = "ntx" + strnum
		field_n = "field_n" + strnum
		el = "el" + strnum
		cur_row = "cr" + strnum

		* fill the channel
		ch_draw = .T.
		channel(&ntx, &field_n, &el, &cur_row, M->j, M->i)

		* next real channel
		i = M->i + 1

	ENDIF

	* next display channel
	j = M->j + 1

ENDDO

RETURN 0


******
*	d_copy()
*
*	create a filename only array (no paths or extensions)
******
FUNCTION d_copy

PARAMETERS array
PRIVATE i

* clear the dedicated array
afill(M->d_array, "")

i = 1

DO WHILE M->i <= LEN(M->array)

	IF EMPTY(array[M->i])
		* end of active list
		EXIT

	ENDIF

	* assign the extracted name
	d_array[M->i] = name(array[M->i])

	* next
	i = M->i + 1

ENDDO

RETURN 0


******
*	open_dbf()
*
*	open data file in the specified work area
******
FUNCTION open_dbf

PARAMETERS is_insert, not_view
PRIVATE shift, filename, a_temp, f_row, d_col, ret_val, old_help

IF M->n_files >= 14
	error_msg("Too many files open")
	RETURN .F.

ENDIF

* save old and set new help codes
old_help = M->help_code
help_code = 6

* initialize private variables
filename = ""

* coordinate of filename on View screen
f_row = cr1[1]
d_col = column[M->cur_area] + 2

* shift = 1 for major insertion
shift = IF(M->is_insert, 1, 0)

* select the current work area
SELECT (M->cur_area)

IF M->not_view
	* not called from "set_view"
	filename = M->cur_dbf
	ret_val = do_opendbf()

ELSE
	* assume file not opened
	ret_val = .F.

	IF isdata(M->keystroke)
		* forward the data character to the GET system
		KEYBOARD CHR(M->keystroke)

		* entry in place
		filename = enter_rc(dbf[M->cur_area],M->f_row,M->d_col,64,"@K!S8")

		IF .NOT. EMPTY(M->filename)
			* something entered

			IF .NOT. (RAT(".", M->filename) > RAT("\", M->filename))
				* no extension entered..provide default
				filename = M->filename + ".DBF"

			ENDIF

			* try to open the file
			ret_val = do_opendbf()

			IF .NOT. M->ret_val
				* failed..restore the screen
				@ M->f_row, M->d_col SAY pad(name(M->cur_dbf), 8)

			ENDIF

		ELSE
			* aborted entry..restore the screen
			@ M->f_row, M->d_col SAY pad(name(M->cur_dbf), 8)

		ENDIF

		IF menu_key() <> 0
			* forward menu key to "set_view"
			KEYBOARD CHR(M->keystroke)

		ELSE
			* avoid confusion
			keystroke = 0

		ENDIF

	ELSE
		* insert or enter or menu selection..use filebox
		ret_val = filebox(".DBF", "dbf_list", "dopen_titl",;
						  "do_opendbf", .F., 8) <> 0

	ENDIF
ENDIF

IF M->ret_val
	* default field arrays to all fields
	a_temp = "field_n" + SUBSTR("123456", M->cur_area, 1)
	all_fields(M->cur_area, &a_temp)

	* re-set current row for indexes and fields
	a_temp = "cr" + SUBSTR("123456", M->cur_area, 1)
	&a_temp[2] = row_a[2]
	&a_temp[3] = row_a[3]

	* re-set current elements
	a_temp = "el" + SUBSTR("123456", M->cur_area, 1)
	afill(&a_temp, 1)

ENDIF

* restore help code
help_code = M->old_help

RETURN M->ret_val


******
*	dopen_titl()
*
*	display title for data file to open
******
FUNCTION dopen_titl

PARAMETERS sysparam

RETURN box_title(M->sysparam, "Open data file...")


******
*	do_opendbf()
*
*	set up and open a data file
******
FUNCTION do_opendbf

PRIVATE done

DO CASE

	CASE EMPTY(M->filename)
		error_msg("Data file not selected")
		done = .F.

	CASE .NOT. FILE(M->filename)
		error_msg("Can't open " + M->filename)
		done = .F.

	CASE aseek(M->dbf, M->filename) > 0 .AND.;
		 .NOT. (dbf[M->cur_area] == M->filename .AND. M->shift = 0)
		error_msg("Data file would be open in two areas")
		done = .F.

	OTHERWISE
		stat_msg("Opening File")

		IF .NOT. EMPTY(dbf[M->cur_area])
			* clear the current work area
			clear_dbf(M->cur_area, M->shift)

		ENDIF

		* adjust global variable
		n_files = M->n_files + 1

		* assign the filename to global array
		dbf[M->cur_area] = M->filename

		* open the file in the current area
		SELECT (M->cur_area)
		USE &filename

		* clear the message
		stat_msg("")

		done = .T.

ENDCASE

RETURN M->done


******
*	get_ntx()
*
*	select index files for the current work area
******
FUNCTION get_ntx

PARAMETERS d_row, d_col, org_file, is_ins
PRIVATE filename, old_help

IF M->n_files >= 14
	error_msg("Too many files open")
	RETURN ""

ENDIF

* save old and set new help codes
old_help = M->help_code
help_code = 8

* initialize private variable
filename = ""

IF isdata(M->keystroke)
	* forward data keystroke to GET system
	KEYBOARD CHR(M->keystroke)

	* entry in place
	filename = enter_rc(M->org_file,M->d_row,M->d_col,64,"@K!S8")

	IF .NOT. EMPTY(M->filename)
		* something entered

		IF .NOT. (RAT(".", M->filename) > RAT("\", M->filename))
			* extension not entered..provide default
			filename = filename + INDEXEXT()

		ENDIF

		IF .NOT. do_openntx()
			* failed..return null string
			filename = ""

		ENDIF
	ENDIF

	IF menu_key() <> 0
		* forward menu request to "set_view"
		KEYBOARD CHR(M->keystroke)

	ELSE
		* avoid confusion
		keystroke = 0

	ENDIF

ELSE

	IF filebox(INDEXEXT(),"ntx_list","xopen_titl","do_openntx",.F.,13) = 0
		* no selection..return null string
		filename = ""

	ENDIF
ENDIF

* restore help code
help_code = M->old_help

RETURN M->filename


******
*	xopen_titl()
*
*	display title for index file to open
******
FUNCTION xopen_titl

PARAMETERS sysparam

RETURN box_title(M->sysparam, "Open index file...")


******
*	do_openntx()
*
*	verify the selectability of an index file
******
FUNCTION do_openntx

PRIVATE done

DO CASE

	CASE EMPTY(M->filename)
		error_msg("Index file not selected")
		done = .F.

	CASE .NOT. FILE(M->filename)
		error_msg("Can't open " + M->filename)
		done = .F.

	CASE dup_ntx(M->filename) <> 0 .AND.;
		 (M->is_ins .OR. .NOT. M->filename == M->org_file)
		error_msg("Index file already open")
		done = .F.

	OTHERWISE
		* filename may be selected

		IF EMPTY(M->org_file) .OR. M->is_ins
			* adjust global variable
			n_files = M->n_files + 1

		ENDIF

		done = .T.

ENDCASE

RETURN M->done


******
*	get_field()
*
*	add a field to an individual field list
******
FUNCTION get_field

PARAMETERS f_row, d_col, work_area, org_field
PRIVATE field_mvar, rel_row, cur_el, okee_dokee, fi_disp, old_help

* save old and set new help codes
old_help = M->help_code
help_code = 2

* initialize variable to contain fieldname
field_mvar = ""

* select the specified work area
SELECT (M->work_area)

* get master field list into local array for selection
DECLARE field_m[FCOUNT()]
all_fields(M->work_area, M->field_m)

IF isdata(M->keystroke)
	* forward the data keystroke to the GET system
	KEYBOARD CHR(M->keystroke)

	* entry in place
	field_mvar = enter_rc(M->org_field,M->f_row,M->d_col,10,"@K!")

	IF .NOT. EMPTY(M->field_mvar)
		* something entered

		IF .NOT. do_fsel()
			* failed..return null string
			field_mvar = ""

		ENDIF

	ENDIF

	IF menu_key() <> 0
		* forward the menu request to "set_view"
		KEYBOARD CHR(M->keystroke)

	ELSE
		* avoid confusion
		keystroke = 0

	ENDIF

ELSE
	* establish arrays for multibox
	DECLARE boxarray[5]

	boxarray[1] = "fsel_title(sysparam)"
	boxarray[2] = "getfield(sysparam)"
	boxarray[3] = "ok_button(sysparam)"
	boxarray[4] = "can_button(sysparam)"
	boxarray[5] = "fieldlist(sysparam)"

	* initialize private variables
	cur_el = 1
	rel_row = 0

	* where the action is
	okee_dokee = "do_fsel()"
	fi_disp = "getfield(3)"

	IF multibox(7, 17, 5, 5, M->boxarray) = 0
		* failed or aborted..return null string
		field_mvar = ""

	ENDIF
ENDIF

* restore help code
help_code = M->old_help

RETURN M->field_mvar


******
*	getfield()
*
*	process fieldname entry blank (called from multibox)
******
FUNCTION getfield

PARAMETERS sysparam

RETURN genfield(M->sysparam, .F.)


******
*	fsel_title()
*
*	display title for field selection
******
FUNCTION fsel_title

PARAMETERS sysparam

RETURN box_title(M->sysparam, "Select field...")


******
*	do_fsel()
*
*	validate field selection
******
FUNCTION do_fsel

PRIVATE done

DO CASE

	CASE EMPTY(M->field_mvar)
		error_msg("Field name not selected")
		done = .F.

	CASE aseek(M->field_m, M->field_mvar) = 0
		* needed for entry in place
		error_msg(M->field_mvar + " does not exist")
		done = .F.

	OTHERWISE
		* field exists..no problem
		done = .T.

ENDCASE

RETURN M->done


******
*	set_relation()
*
*	interface for editing the list of relations
*
*	note: the relations window can display a maximum
*		  of six (6) relationships at one time
******
FUNCTION set_relation

PRIVATE c_row, c_el, rel_buff, pos_r, width, old_help, k, n_area, ls, lk, lt

* save old and set new help codes
old_help = M->help_code
help_code = 9

* prevent certain menu selections with multibox mechanism
box_open = .T.

IF EMPTY(M->bar_line)
	* need bar line for vertical reference
	bline(afull(M->dbf))

ENDIF

* window has variable width
width = LEN(M->bar_line) - 1

* establish easy reference to right most column
pos_r = column[1] + M->width

* save the window
rel_buff = SAVESCREEN(8, column[1] - 1, 23, M->pos_r + 1)

* clear and frame the window
scroll(8, column[1] - 1, 23, M->pos_r + 1, 0)
@ 8, column[1] - 1, 23, M->pos_r + 1 BOX M->frame

* display the heading and bar line
@ 9,35 SAY "Relations"
@ 10,column[1] SAY M->bar_line

* initialize current row and element
c_row = 11
c_el = 1

* initial window fill
draw_relat(1)

* global key value..zero is convenient for branch to "otherwise" case below
keystroke = 0

DO WHILE .NOT. q_check()
	* one big switch..exit condition determined elsewhere

	DO CASE

		CASE M->keystroke = 18
			* PgUp

			IF M->c_el > ((M->c_row - 11) / 2) + 1
				* elements off screen..move up one page
				c_el = M->c_el - 5

				IF M->c_el < ((M->c_row - 11) / 2) + 1
					* minimum element for this row
					c_el = ((M->c_row - 11) / 2) + 1

				ENDIF

				* re-write relations window
				draw_relat(M->c_el - ((M->c_row - 11) / 2))

			ELSE
				* first element is on screen

				IF M->c_el > 1
					* move to top of list
					c_el = 1
					c_row = 11

				ENDIF
			ENDIF

			keystroke = 0

		CASE M->keystroke = 3
			* PgDn..determine maximum allowable cursor element
			k = afull(M->k_relate)

			IF M->k < LEN(M->k_relate)
				* first empty element is allowed
				k = M->k + 1

			ENDIF

			IF M->c_el < M->k - ((21 - M->c_row) / 2)
				* elements off screen..down one page
				c_el = M->c_el + 5

				IF M->c_el > M->k - ((21 - M->c_row) / 2)
					* maximum element for this row
					c_el = M->k - ((21 - M->c_row) / 2)

				ENDIF

				* re-write relations window
				draw_relat(M->c_el - ((M->c_row - 11) / 2))

			ELSE
				* last allowable element is on screen

				IF M->c_el < M->k
					* move to bottom of list
					c_row = M->c_row + ((M->k - M->c_el) * 2)
					c_el = M->k

				ENDIF
			ENDIF

			keystroke = 0

		CASE M->keystroke = 22 .OR. isdata(M->keystroke)
			* insert or character key..insert a relation

			* k = number of first relation off screen
			k = M->c_el + ((21 - M->c_row) / 2 ) + 1

			* save the last relationship
			ls = s_relate[LEN(M->s_relate)]
			lk = k_relate[LEN(M->k_relate)]
			lt = t_relate[LEN(M->t_relate)]

			* do the insert..assume relation will be entered
			array_ins(M->s_relate, M->c_el)
			array_ins(M->k_relate, M->c_el)
			array_ins(M->t_relate, M->c_el)

			IF M->c_row < 21
				* make room on screen..scroll down 2 lines
				scroll(M->c_row, column[1], 22, M->pos_r - 1, -2)

			ELSE
				* clear the last row
				@ M->c_row + 1,column[1] SAY SPACE(M->width)

			ENDIF

			IF M->k <= LEN(M->k_relate)
				* k is within subscript range

				IF .NOT. EMPTY(k_relate[M->k])
					* off-screen element is active
					@ 22, M->pos_r SAY M->more_down

				ENDIF
			ENDIF

			* accept input of new relation
			get_relation(M->c_row, M->c_el)

			IF .NOT. EMPTY(k_relate[M->c_el])
				* relation has been entered..show it
				disp_relation(M->c_row, M->c_el, 1)

			ELSE
				* relation not entered..cannot delete a null string
				STORE "x" TO s_relate[M->c_el],;
							 k_relate[M->c_el], t_relate[M->c_el]

				* restore arrays
				array_del(M->s_relate, M->c_el)
				array_del(M->k_relate, M->c_el)
				array_del(M->t_relate, M->c_el)

				* restore last relationship
				s_relate[LEN(M->s_relate)] = M->ls
				k_relate[LEN(M->k_relate)] = M->lk
				t_relate[LEN(M->t_relate)] = M->lt

				IF M->c_row < 21
					* close the gap on the screen..scroll up 2 lines
					scroll(M->c_row, column[1], 22, M->pos_r - 1, 2)

				ELSE
					* erase the deleted relation from screen
					@ 21,column[1] SAY SPACE(M->width)
					@ 22,column[1] SAY SPACE(M->width)

				ENDIF

				* fill in the last relation on screen
				disp_relation(21, M->c_el + ((21 - M->c_row) / 2), 1)

			ENDIF

			IF M->k <= LEN(M->k_relate)
				* k is within subscript range

				IF EMPTY(k_relate[M->k])
					* off-screen element not active
					@ 22, M->pos_r SAY " "

				ENDIF
			ENDIF

			keystroke = 0

		CASE M->keystroke = 13
			* enter key..change a relationship
			get_relation(M->c_row, M->c_el)

			* display the change
			disp_relation(M->c_row, M->c_el, 1)

			keystroke = 0

		CASE M->keystroke = 7 .AND. .NOT. EMPTY(k_relate[M->c_el])
			* remove a relation from the list
			need_relat = .T.	&& will need to reset

			* select the source work area
			n_area = ASC(s_relate[M->c_el]) - ASC("A") + 1
			SELECT (M->n_area)

			* turn off relations from this work area
			SET RELATION TO

			* remove the relation from list
			array_del(M->s_relate, M->c_el)
			array_del(M->k_relate, M->c_el)
			array_del(M->t_relate, M->c_el)

			IF M->c_row < 21
				* close the gap on the screen
				scroll(M->c_row, column[1], 22, M->pos_r - 1, 2)

			ELSE
				* last row erase the deleted relation from screen
				@ 21,column[1] SAY SPACE(M->width)
				@ 22,column[1] SAY SPACE(M->width)

			ENDIF

			* fill in the last relation on screen
			disp_relation(21, M->c_el + ((21 - M->c_row) / 2), 1)

			IF M->c_el < LEN(M->k_relate) - ((21 - M->c_row) / 2)
				* off-screen element is within subscript range

				IF EMPTY(k_relate[M->c_el + ((21 - M->c_row) / 2) + 1])
					* remove "more_down" indicator from screen
					@ 22, M->pos_r SAY " "

				ENDIF
			ENDIF

			keystroke = 0

		CASE M->keystroke = 5 .AND. M->c_el > 1
			* up arrow..move up one element
			c_el = M->c_el - 1

			IF M->c_row > 11
				* room to move up on screen
				c_row = M->c_row - 2

			ELSE
				* scroll entire window down 2 lines
				scroll(11, column[1], 22, M->pos_r - 1, -2)

				* fill in the top row
				disp_relation(11, M->c_el, 1)

				IF M->c_el <= LEN(M->k_relate) - 6
					* off-screen element within subscript range

					IF .NOT. EMPTY(k_relate[M->c_el + 6])
						* off-screen element is active
						@ 22, M->pos_r SAY M->more_down

					ENDIF
				ENDIF

				IF M->c_el = 1
					* first element brought onto screen..no "more_up"
					@ 11,M->pos_r SAY " "

				ENDIF
			ENDIF

			keystroke = 0

		CASE M->keystroke = 24 .AND. .NOT.;
			 (EMPTY(k_relate[M->c_el]) .OR. M->c_el = LEN(M->k_relate))
			* down arrow..move down one element
			c_el = M->c_el + 1

			IF c_row < 22 - 2
				* room to move down on screen
				c_row = M->c_row + 2

			ELSE
				* scroll entire window up 2 lines
				scroll(11, column[1], 22, M->pos_r - 1, 2)

				* definitely more up
				@ 11,M->pos_r SAY M->more_up

				IF .NOT. EMPTY(k_relate[M->c_el])
					* fill in the bottom row
					disp_relation(21, M->c_el, 1)

				ENDIF

				IF M->c_el < LEN(M->k_relate)
					* off-screen element within subscript range

					IF EMPTY(k_relate[M->c_el + 1])
						* erase "more_down" indicator from screen
						@ 22,M->pos_r SAY " "

					ENDIF

				ELSE
					* no off-screen element..erase "more_down" indicator
					@ 22,M->pos_r SAY " "

				ENDIF
			ENDIF

			keystroke = 0

		CASE M->local_func = 1
			* "help" selected from pull-down menu
			DO syshelp
			keystroke = 0

		OTHERWISE
			* get new keystroke

			IF .NOT. key_ready()
				* no key pending..hilite the current item
				disp_relation(M->c_row, M->c_el, 2)

				* display a blob of light if element empty
				syscolor(2)
				@ M->c_row,column[1] + 2;
				SAY IF(EMPTY(k_relate[M->c_el]), " ", "")
				syscolor(1)

				* wait for keystroke
				read_key()

				* re-write the current item as normal
				disp_relation(M->c_row, M->c_el, 1)

				@ M->c_row, column[1] + 2 SAY ""

			ENDIF
	ENDCASE
ENDDO

* restore the window
RESTSCREEN(8, column[1] - 1, 23, M->pos_r + 1, M->rel_buff)

* restore the help code
help_code = M->old_help

* restore access to menu options
box_open = .F.

* avoid confusion
keystroke = 0

RETURN 0


******
*	draw_relat()
*
*	fill the relations window
******
FUNCTION draw_relat

PARAMETERS start_el
PRIVATE i

* clear the window
scroll(11, column[1], 22, M->pos_r, 0)

i = 0

DO WHILE M->i < 6 .AND. M->start_el + M->i <= LEN(M->k_relate)

	IF EMPTY(k_relate[M->start_el + M->i])
		* end of active list
		EXIT

	ENDIF

	* display one relation
	disp_relation(11 + (2 * M->i), M->start_el + M->i, 1)

	* next
	i = M->i + 1

ENDDO

IF M->start_el > 1
	* indicate active elements above window
	@ 11, M->pos_r SAY M->more_up

ENDIF

IF M->start_el + M->i <= LEN(M->k_relate)
	* off-screen element within subscript range

	IF .NOT. EMPTY(k_relate[M->start_el + M->i])
		* indicate active elements below window
		@ 22, M->pos_r SAY M->more_down

	ENDIF
ENDIF

RETURN 0


******
*	get_relation()
*
*	accept entry of one relationship
*
*	note: a character key may be used to select a file whose
*		  name begins with that letter
******
FUNCTION get_relation

PARAMETERS row_n, element
PRIVATE stroke, k_input, k_trim, s_alias, t_alias, i, j, q, pos_c,;
		ntx_expr, k_type, ok

IF isdata(M->keystroke)
	* character key..look for matching filename
	i = c_search(UPPER(CHR(M->keystroke)), M->dbf, 0, afull(M->dbf))

	IF SUBSTR(dbf[M->i],1,1) = UPPER(CHR(M->keystroke))
		* found..make the selection as the source file
		KEYBOARD CHR(13)

	ENDIF

ELSE

	IF EMPTY(k_relate[M->element])
		* brand new..start at the beginning
		i = 1

	ELSE
		* relation exists..begin with source file
		i = ASC(s_relate[M->element]) - ASC("A") + 1

	ENDIF
ENDIF

j = 0
stroke = 0

DO WHILE .NOT. (M->j > 0 .AND. M->stroke = 13)
	* till both source and target files are selected

	DO CASE

		CASE M->stroke = 13
			* enter key..select source

			IF M->i < 6
				* can only select if another file is open to the right

				IF .NOT. EMPTY(dbf[M->i + 1])

					IF .NOT. EMPTY(k_relate[M->element])
						* assume same target for existing relation
						j = ASC(t_relate[M->element]) - ASC("A") + 1

					ENDIF

					IF M->j <= M->i
						* target must be to the right of the source
						j = M->i + 1

					ENDIF
				ENDIF
			ENDIF

			stroke = 0

		CASE M->stroke = 4
			* right arrow

			IF M->j = 0 .AND. M->i < 6
				* source not selected..change source

				IF .NOT. EMPTY(dbf[M->i + 1])
					* only open files are selectable
					i = M->i + 1

				ENDIF

			ELSE

				IF M->j > 0 .AND. M->j < 6
					* source selected..change target

					IF .NOT. EMPTY(dbf[M->j + 1])
						* only open files are selectable
						j = M->j + 1

					ENDIF
				ENDIF
			ENDIF

			stroke = 0

		CASE M->stroke = 19
			* left arrow

			IF M->j = 0 .AND. M->i > 1
				* source not selected..change source
				i = M->i - 1

			ELSE

				IF M->j > 0
					* source selected..change target
					j = M->j - 1

					IF M->j = M->i
						* target must be to the right
						j = 0	&& revert to unselected source

					ENDIF
				ENDIF
			ENDIF

			stroke = 0

		CASE isdata(M->stroke)
			* character key..perform character search
			q = c_search(UPPER(CHR(M->stroke)),M->dbf,M->i,afull(M->dbf))

			IF SUBSTR(dbf[M->q],1,1) = UPPER(CHR(M->stroke))
				* found

				IF M->j = 0
					* source not selected..make selection
					i = M->q
					KEYBOARD CHR(13)

				ELSE

					IF M->q > M->i
						* found file is acceptable as target..make selection
						j = M->q
						KEYBOARD CHR(13)

					ELSE
						* found file cannot be target
						j = 0		&& revert to unselected source
						i = M->q	&& found file is current s_alias

					ENDIF
				ENDIF
			ENDIF

			stroke = 0

		CASE M->stroke = 27
			* escape..abort
			@ M->row_n,column[1] SAY SPACE(M->width)
			RETURN 0

		CASE M->stroke = 28
			* "help" selected from pull-down menu
			DO syshelp
			stroke = 0

		OTHERWISE
			* update screen and get new stroke

			IF M->j = 0
				* source file not selected..clear the row
				@ M->row_n,column[1] SAY SPACE(M->width)

				* extract the current source alias
				s_alias = name(dbf[M->i])

				* display it as intense
				syscolor(3)
				@ M->row_n,column[M->i] + 2 SAY M->s_alias
				syscolor(1)

			ELSE
				* source selected (do not disturb)..extract target alias
				t_alias = name(dbf[M->j])

				* calculate column after s_alias
				pos_c = column[M->i] + 2 + LEN(M->s_alias)

				* clear to right edge of window
				@ M->row_n,M->pos_c SAY SPACE(M->pos_r - M->pos_c)

				* draw line and arrow pointing to target alias
				@ M->row_n,M->pos_c;
				SAY REPLICATE("ฤ", column[M->j] - M->pos_c + 1) + CHR(16)

				* display target alias as intense
				syscolor(3)
				?? t_alias
				syscolor(1)

			ENDIF

			* get new stroke
			stroke = raw_key()

	ENDCASE
ENDDO

* hilite source and target in reverse video to indicate both selected
syscolor(2)
@ M->row_n,column[M->i] + 2 SAY M->s_alias
@ M->row_n,column[M->j] + 2 SAY M->t_alias
syscolor(1)

* determine correct type for relation expression
SELECT (M->j)
ntx_expr = ctrl_key()		&& get the controlling index key

IF EMPTY(M->ntx_expr)
	* target not indexed..must be numeric or recno()
	k_type = "N"

ELSE
	* same type as target index key
	k_type = TYPE(M->ntx_expr)

ENDIF

* select source work area to test key expression
SELECT (M->i)

* start with previous expression
k_trim = k_relate[M->element]
ok = .F.

DO WHILE .NOT. M->ok
	* accept input of key expression
	k_trim = enter_rc(M->k_trim, M->row_n + 1, column[M->i] + 2,;
					  127, "@KS" + LTRIM(STR(M->pos_r - column[M->i] - 2)))

	* empty expression will abort, else must be correct type
	ok = EMPTY(M->k_trim) .OR. TYPE(M->k_trim) = M->k_type

	IF .NOT. M->ok
		error_msg("Invalid Expression")

	ENDIF
ENDDO

* clear the expression row
@ M->row_n + 1,column[1] SAY SPACE(M->width)

IF EMPTY(M->k_trim)
	* abort
	RETURN 0

ENDIF

* will need to set relations
need_relat = .T.

* store defined relation in global arrays
k_relate[M->element] = M->k_trim
s_relate[M->element] = CHR(M->i + ASC("A") - 1) + M->s_alias
t_relate[M->element] = CHR(M->j + ASC("A") - 1) + M->t_alias

RETURN 0


******
*	disp_relation()
*
*	display the specified relation on the specified row in the specified color
******
FUNCTION disp_relation

PARAMETERS disp_row, element, color_num
PRIVATE j, k

IF EMPTY(k_relate[M->element])
	* clear lines only
	@ M->disp_row,column[1] SAY SPACE(M->width)
	@ M->disp_row + 1,column[1] SAY SPACE(M->width)
	RETURN 0

ENDIF

* calculate the work areas of the related files
j = ASC(s_relate[M->element]) - ASC("A") + 1	&& source
k = ASC(t_relate[M->element]) - ASC("A") + 1	&& target

* display the source alias in the specified color
syscolor(M->color_num)
@ M->disp_row, column[M->j] + 2 SAY SUBSTR(s_relate[M->element], 2)
syscolor(1)

* display an arrow (always normal color)
?? REPLICATE("ฤ", column[M->k] - COL() + 1) + CHR(16)

* display the target alias in the specified color
syscolor(M->color_num)
?? SUBSTR(t_relate[M->element], 2)
syscolor(1)

* display the key on the next line (always normal color)
@ M->disp_row + 1, column[M->j] + 2;
SAY pad(k_relate[M->element], M->pos_r - column[M->j] - 2)

RETURN 0


******
*	c_search()
*
*	find the next array element with a matching first character
******
FUNCTION c_search

PARAMETERS c, array, cur_el, num_d
PRIVATE chr_el

* begin with next element
chr_el = M->cur_el + 1

DO WHILE M->chr_el <= M->num_d
	* forward search..exit if found

	IF UPPER(SUBSTR(array[M->chr_el], 1, 1)) = UPPER(M->c)
		EXIT

	ENDIF

	* next
	chr_el = M->chr_el + 1

ENDDO

IF M->chr_el > M->num_d
	* not found..search from beginning
	chr_el = 1

	DO WHILE M->chr_el < M->cur_el .AND.;
			 UPPER(SUBSTR(array[M->chr_el], 1, 1)) <> UPPER(M->c)

		* next
		chr_el = M->chr_el + 1

	ENDDO
ENDIF

RETURN M->chr_el


******
*	ctrl_key()
*
*	return controlling index key for the current work area
******
FUNCTION ctrl_key

PRIVATE key, ntx

IF M->need_ntx
	* index may be specified but not set
	ntx = "ntx" + LTRIM(STR(SELECT()))

	* read key directly from file
	key = ntx_key(&ntx[1])

ELSE
	* get key from system if index already set
	key = INDEXKEY(0)

ENDIF

RETURN M->key


******
*	get_filter()
*
*	accept entry of filter expression for the current work area
******
FUNCTION get_filter

PRIVATE k_filter,k_trim,old_help

* save old and set new help codes
old_help = M->help_code
help_code = 7

* get the current contents of the filter expression
k_filter = "kf" + SUBSTR("123456", M->cur_area, 1)
k_trim = &k_filter

* select the current work area for testing of filter expression
SELECT (M->cur_area)

* hilite the affected data file
hi_cur()

* establish array for mulitbox
DECLARE boxarray[4]

boxarray[1] = "fltr_title(sysparam)"
boxarray[2] = "getfilter(sysparam)"
boxarray[3] = "ok_button(sysparam)"
boxarray[4] = "can_button(sysparam)"

* indicate the function that will complete the process
okee_dokee = "do_filter()"

* open the box
multibox(7, 17, 5, 2, M->boxarray)

* restore help code
help_code = M->old_help

* un-hilite the name of the current data file
dehi_cur()

RETURN 0


******
*	fltr_title()
*
*	display title for filter entry
******
FUNCTION fltr_title

PARAMETERS sysparam

* title includes filename.ext but no path
RETURN box_title(M->sysparam, "Set filter for " +;
							  SUBSTR(M->cur_dbf, RAT("\", M->cur_dbf) + 1) +;
							  " to...")


******
*	getfilter()
*
*	accept input of filter expression to the temporary variable "k_trim"
******
FUNCTION getfilter

PARAMETERS sysparam

RETURN get_k_trim(M->sysparam, "Condition")


******
*	do_filter()
*
*	complete the filter entry
******
FUNCTION do_filter

PRIVATE done, k_sample

IF EMPTY(M->k_trim)
	* a confirmed empty expression means eliminate the current filter
	done = .T.

	IF .NOT. EMPTY(&k_filter)
		* cancel any filter that may be active
		SET FILTER TO

		* set global filter expression to nul
		&k_filter = ""

	ENDIF

ELSE

	IF TYPE(M->k_trim) = "L"
		* expression evaluates ok
		done = .T.

		IF .NOT. (&k_filter == M->k_trim)
			* change in filter expression..set global variables
			need_filtr = .T.
			&k_filter = M->k_trim

		ENDIF

	ELSE
		done = .F.
		error_msg("Filter must be a Logical expression")

	ENDIF
ENDIF

RETURN M->done


******
*	clear_dbf()
*
*	clear specified work area..shift higher work areas if requested
*
*	shift values:
*		0  =  no shift
*		1  =  shift right (insert)
*		2  =  shift left (delete)
******
FUNCTION clear_dbf

PARAMETERS work_area, shift
PRIVATE s_alias,c_area,temp,xtemp,i,file_name,alias_6,n_active

* determine number of active work areas
n_active = afull(M->dbf)

* extract alias of specified work area
s_alias = name(dbf[M->work_area])

* area 6 could be affected if shifting due to insert
alias_6 = ""

* access the list of index files for the current area
temp = "ntx" + SUBSTR("123456", M->work_area, 1)

DO CASE

	CASE M->shift = 0
		* no shift..no problem
		dbf[M->work_area] = ""

		* reduce number of open files by no. of index files + 1
		n_files = M->n_files - afull(&temp) - 1

	CASE M->shift = 1
		* shift right..current data file (if any) will remain open

		IF .NOT. EMPTY(dbf[6])
			* remember the alias
			alias_6 = name(dbf[6])

			* reduce number of open files by no. of index files + 1
			n_files = M->n_files - afull(M->ntx6) - 1

		ENDIF

		* shift may not be needed after all
		shift = IF(EMPTY(dbf[M->work_area]) .OR. M->work_area = 6, 0, 1)

		* open an empty element in global array of data files
		array_ins(M->dbf, M->work_area)

	CASE M->shift = 2
		* shift left..current data file will be closed
		array_del(M->dbf, M->work_area)

		* shift may not be needed after all
		shift = IF(EMPTY(dbf[M->work_area]), 0, 2)

		* reduce number of open files by no. of index files + 1
		n_files = M->n_files - afull(&temp) - 1

ENDCASE

i = 1

DO WHILE M->i <= M->n_active
	* select area i
	c_area = CHR(M->i + ASC("A") - 1)
	SELECT (M->i)

	IF M->i = M->work_area .OR. (M->i > M->work_area .AND. M->shift <> 0)
		* close all work areas to be shifted or closed
		USE

	ENDIF

	* search filters in all active areas for disappearing aliases
	temp = "kf" + SUBSTR("123456", M->i, 1)

	IF (((M->s_alias + "->" $ UPPER(&temp)) .OR.;
	   (M->i = M->work_area .AND. .NOT. EMPTY(&temp)));
	   .AND. M->shift <> 1) .OR. (.NOT. EMPTY(M->alias_6) .AND.;
	   M->alias_6 + "->" $ UPPER(&temp) .AND. M->shift = 1)
		* data file was part of filter expression or none can exist

		* turn of the filter
		SET FILTER TO

		* will need to reset
		need_filtr = .T.

		* set global filter expression to nul
		&temp = ""

	ENDIF

	* next
	i = M->i + 1

ENDDO

DO CASE

	CASE M->shift = 0
		* clear array of index files
		temp = "ntx" + SUBSTR("123456", M->work_area, 1)
		afill(&temp, "")

		* clear field list
		temp = "field_n" + SUBSTR("123456", M->work_area, 1)
		afill(&temp, "")

		* clear filter
		temp = "kf" + SUBSTR("123456", M->work_area, 1)
		&temp = ""

	CASE M->shift = 1
		* shift right
		need_filtr = .T.	&& will need to reset
		need_ntx = .T.		&& ditto

		* count backwards..dbf array may not be contiguous
		i = 6

		DO WHILE EMPTY(dbf[M->i])
			* find highest active area
			i = M->i - 1

		ENDDO

		DO WHILE M->i > M->work_area
			* shift all higher work areas..list of index files
			temp = "ntx" + SUBSTR("123456", M->i, 1)
			xtemp = "ntx" + SUBSTR("123456", M->i - 1, 1)
			acopy(&xtemp,&temp)

			* active fields list
			temp = "field_n" + SUBSTR("123456", M->i, 1)
			xtemp = "field_n" + SUBSTR("123456", M->i - 1, 1)
			acopy(&xtemp,&temp)

			* current rows
			temp = "cr" + SUBSTR("123456", M->i, 1)
			xtemp = "cr" + SUBSTR("123456", M->i - 1, 1)
			acopy(&xtemp,&temp)

			* current elements
			temp = "el" + SUBSTR("123456", M->i, 1)
			xtemp = "el" + SUBSTR("123456", M->i - 1, 1)
			acopy(&xtemp,&temp)

			* filter expressions
			temp = "kf" + SUBSTR("123456", M->i, 1)
			xtemp = "kf" + SUBSTR("123456", M->i - 1, 1)
			&temp = &xtemp

			* next
			i = M->i - 1

		ENDDO

		* clear the specified work area (i = work_area)
		xtemp = SUBSTR("123456", M->i, 1)	&& str(i) for convenience

		* clear index files list
		temp = "ntx" + xtemp
		afill(&temp, "")

		* clear active fields list
		temp = "field_n" + xtemp
		afill(&temp, "")

		* clear filter expression
		temp = "kf" + xtemp
		&temp = ""

		* reset current rows
		temp = "cr" + xtemp
		&temp[2] = row_a[2]
		&temp[3] = row_a[3]

		* reset current elements
		temp = "el" + xtemp
		afill(&temp, 1)

	CASE M->shift = 2
		* shift left
		need_filtr = .T.	&& will need to reset
		need_ntx = .T.		&& ditto

		i = M->work_area

		DO WHILE M->i < 6 .AND. .NOT. EMPTY(dbf[M->i])
			* shift all higher work areas..list of index files
			temp = "ntx" + SUBSTR("123456", M->i, 1)
			xtemp = "ntx" + SUBSTR("123456", M->i + 1, 1)
			acopy(&xtemp,&temp)

			* active fields list
			temp = "field_n" + SUBSTR("123456", M->i, 1)
			xtemp = "field_n" + SUBSTR("123456", M->i + 1, 1)
			acopy(&xtemp,&temp)

			* current rows
			temp = "cr" + SUBSTR("123456", M->i, 1)
			xtemp = "cr" + SUBSTR("123456", M->i + 1, 1)
			acopy(&xtemp,&temp)

			* current elements
			temp = "el" + SUBSTR("123456", M->i, 1)
			xtemp = "el" + SUBSTR("123456", M->i + 1, 1)
			acopy(&xtemp,&temp)

			* filter expressions
			temp = "kf" + SUBSTR("123456", M->i, 1)
			xtemp = "kf" + SUBSTR("123456", M->i + 1, 1)
			&temp = &xtemp

			* next
			i = M->i + 1

		ENDDO

		* clear the last (previously active) work area
		xtemp = SUBSTR("123456", M->i, 1)	&& str(i) for convenience

		* clear index files list
		temp = "ntx" + M->xtemp
		afill(&temp, "")

		* clear active fields list
		temp = "field_n" + M->xtemp
		afill(&temp, "")

		* clear filter expression
		temp = "kf" + M->xtemp
		&temp = ""

		* reset current rows
		temp = "cr" + M->xtemp
		&temp[2] = row_a[2]
		&temp[3] = row_a[3]

		* reset current elements
		temp = "el" + M->xtemp
		afill(&temp, 1)

ENDCASE

* will need to reset
need_field = .T.

**
*	note: the source and target of relations are identified
*		  by the letter of the work area + the alias
**

* get letter of cleared work area
c_area = CHR(M->work_area + ASC("A") - 1)

i = 1

DO WHILE M->i <= LEN(M->k_relate)
	* search all active relations

	IF EMPTY(k_relate[M->i])
		* no more active relations
		EXIT

	ENDIF

	IF ((SUBSTR(s_relate[M->i], 1, 1) = M->c_area .OR.;
	   SUBSTR(t_relate[M->i], 1, 1) = M->c_area) .AND. M->shift <> 1) .OR.;
	   (M->shift = 1 .AND. SUBSTR(t_relate[M->i], 1, 1) = "F")
		* relation must be removed from list

		array_del(M->s_relate, M->i)
		array_del(M->k_relate, M->i)
		array_del(M->t_relate, M->i)
		need_relat = .T.

	ELSE

		IF (M->shift = 2 .AND. SUBSTR(s_relate[M->i], 1, 1) > M->c_area) .OR.;
		   (M->shift = 1 .AND. SUBSTR(s_relate[M->i], 1, 1) >= M->c_area)
			* source work area was shifted..adjust source area

			s_relate[M->i] = CHR(ASC(SUBSTR(s_relate[M->i], 1, 1)) +;
							 IF(M->shift = 1, 1, -1)) +;
							 SUBSTR(s_relate[M->i], 2)
			need_relat = .T.

		ENDIF

		IF (M->shift = 2 .AND. SUBSTR(t_relate[M->i], 1, 1) > M->c_area) .OR.;
		   (M->shift = 1 .AND. SUBSTR(t_relate[M->i], 1, 1) >= M->c_area)
			* target work area was shifted..adjust target area

			t_relate[M->i] = CHR(ASC(SUBSTR(t_relate[M->i], 1, 1)) +;
							 IF(M->shift = 1, 1, -1)) +;
							 SUBSTR(t_relate[M->i], 2)
			need_relat = .T.

		ENDIF

		* next
		i = M->i + 1

	ENDIF
ENDDO

IF M->shift <> 0
	* re-open active data files in new work areas
	i = 6

	DO WHILE M->i >= M->work_area
		* search all shifted work areas

		IF .NOT. EMPTY(dbf[M->i])
			* open data file
			c_area = CHR(M->i + ASC("A") - 1)
			SELECT (M->i)
			file_name = dbf[M->i]
			USE &file_name

		ENDIF

		* next
		i = M->i - 1

	ENDDO
ENDIF

RETURN 0


******
*	save_view()
*
*	save the current view in a ".VEW" file
*
*	note: - the view file is a data base file with a default extension
*			of ".VEW" and 2 fields: "item_name" and "contents".
*		  -	the first 2 items are reserved for the global variables
*			"cur_dir", and "n_files"..then a variable number of
*			filter expressions..the remaining items are arrays.
*		  -	if the contents of an item will not fit in the contents
*			field, it will be continued in the next record where
*			the item_name will be left blank.
*		  -	for arrays, only the identifier is saved..the number of
*			items is the number of elements to fill
******
FUNCTION save_view

PRIVATE filename, old_help

* save old and set new help codes
old_help = M->help_code
help_code = 21

* get user entered file name..will default to primary + ".VEW"
IF EMPTY(M->view_file) .AND. .NOT. EMPTY(dbf[1])
	* default to name of primary data file
	filename = name(dbf[1]) + ".VEW"

ELSE
	* whatever the last view was
	filename = M->view_file

ENDIF

* it's better in a box
filebox(".VEW", "vew_list", "vcrea_titl", "do_creavew", .T., 8)

* restore help code
help_code = M->old_help

RETURN 0


******
*	vcrea_titl()
*
*	display title for save view
******
FUNCTION vcrea_titl

PARAMETERS sysparam

RETURN box_title(M->sysparam, "Save view as...")


******
*	do_creavew()
*
*	save the current view in a .VEW file
******
FUNCTION do_creavew

PRIVATE i, j, k, m_name, l_name, add_name

IF EMPTY(M->filename)
	error_msg("View file not selected")
	RETURN .F.

ENDIF

* select system reserved work area
SELECT 10

stat_msg("Generating View File")

* add new .VEW files to vew_list if created in current directory only
add_name = .NOT. FILE(name(filename) + ".VEW")

* create structure extended template
CREATE ddbbuuuu.ext

* define 2 fields
APPEND BLANK
REPLACE field_name WITH "ITEM_NAME",field_type WITH "C",field_len WITH 10

APPEND BLANK
REPLACE field_name WITH "CONTENTS",field_type WITH "C",field_len WITH 10

* create the view file
USE
CREATE &filename FROM ddbbuuuu.ext

* set global variable
view_file = M->filename

* open view file..avoid alias conflict
USE &view_file ALIAS ddbbuuuu

* erase template
ERASE ddbbuuuu.ext

* 2 global variables always saved
APPEND BLANK
REPLACE item_name WITH "cur_dir"
put_line(cur_dir)

APPEND BLANK
REPLACE item_name WITH "n_files"
put_line(LTRIM(STR(n_files)))

i = 1

DO WHILE i <= 6
	* filters

	IF EMPTY(dbf[i])
		* no more data files
		EXIT

	ENDIF

	* get variable name for macro expansion
	m_name = "kf" + SUBSTR("123456", i, 1)

	IF .NOT. EMPTY(&m_name)
		* only save active filters
		APPEND BLANK
		REPLACE item_name WITH m_name
		put_line(&m_name)

	ENDIF

	* next
	i = i + 1

ENDDO

* save arrays..avoid saving empty elements
i = 1

DO WHILE i <= 6
	* data file filespecs

	IF EMPTY(dbf[i])
		* no more data files
		EXIT

	ENDIF

	* save one filespec
	APPEND BLANK
	REPLACE item_name WITH "dbf"
	put_line(dbf[i])

	* next
	i = i + 1

ENDDO

* save index lists and fields lists
l_name = "ntx"

FOR k = 1 TO 2
	* first the indexed, then the fields
	i = 1

	DO WHILE i <= 6
		* index or field list for each data file

		IF EMPTY(dbf[i])
			* no more data files
			EXIT

		ENDIF

		* get array identifier for macro expansion
		m_name = l_name + SUBSTR("123456", i, 1)

		j = 1

		DO WHILE j <= LEN(&m_name)
			* index or field list for one data file

			IF EMPTY(&m_name[j])
				* an early exit saves time and disk space
				EXIT

			ENDIF

			* save one index filespec or one field name
			APPEND BLANK
			REPLACE item_name WITH m_name
			put_line(&m_name[j])

			* next element
			j = j + 1

		ENDDO

		* next work area
		i = i + 1

	ENDDO

	* switch to field lists
	l_name = "field_n"

NEXT

i = 1

DO WHILE i <= 3
	* relations in 3 arrays..s_relate, k_relate, and t_relate
	m_name = SUBSTR("skt", i, 1) + "_relate"
	j = 1

	DO WHILE j <= LEN(&m_name)
		* one array

		IF EMPTY(&m_name[j])
			* an early exit saves time and disk space
			EXIT

		ENDIF

		* one item
		APPEND BLANK
		REPLACE item_name WITH m_name
		put_line(&m_name[j])

		* next element
		j = j + 1

	ENDDO

	* next array
	i = i + 1

ENDDO

* close view file
USE

* add file name to array of view files
IF AT(".VEW", filename) = LEN(filename) - 3 .AND.;
   FILE(name(filename) + ".VEW") .AND. add_name
	* add only new .VEW files in the current directory

	* determine number of first empty element
	i = afull(vew_list) + 1

	IF i <= LEN(vew_list)
		* room for one more
		vew_list[i] = filename

		* must be alphabetical
		array_sort(vew_list)

	ENDIF
ENDIF

stat_msg("")

RETURN .T.


******
*	put_line()
*
*	store string in contents field(s) of open view file
******
FUNCTION put_line

PARAMETERS line
PRIVATE pos

* assign contents to the current record
REPLACE contents WITH line

* position to begin fragmentation
pos = LEN(contents) + 1

DO WHILE pos <= LEN(line)
	* continue contents in next record
	APPEND BLANK
	REPLACE contents WITH SUBSTR(line, pos)

	* next chunk
	pos = pos + LEN(contents)

ENDDO

RETURN 0


******
*	set_from()
*
*	restore View from .VEW file
******
FUNCTION set_from

PARAMETERS from_view
PRIVATE filename, old_help

* save old and set new help codes
old_help = M->help_code
help_code = 21

* default to previous View file if any
filename = M->view_file

IF M->from_view
	* called from set_view

	IF filebox(".VEW", "vew_list", "vopen_titl", "do_openvew", .F., 8) <> 0
		* indicate new View has been set
		keystroke = 13

	ENDIF

ELSE
	* just do it
	do_openvew()

ENDIF

* restore help code
help_code = M->old_help

RETURN 0


******
*	vopen_titl()
*
*	display title for restore view
******
FUNCTION vopen_titl

PARAMETERS sysparam

RETURN box_title(M->sysparam, "Restore view from...")


******
*	do_openvew()
*
*	restore view from .VEW file
*
*	note: this function is called when the enter key is
*		  pressed while the cursor is on the Ok button
******
FUNCTION do_openvew

PRIVATE m_name, i, done

DO CASE

	CASE EMPTY(M->filename)
		error_msg("View file not selected")
		done = .F.

	CASE .NOT. FILE(M->filename)
		error_msg("Can't open " + M->filename)
		done = .F.

	OTHERWISE
		* select system reserved work area
		SELECT 10

		* open .VEW file..avoid alias conflict
		USE &filename ALIAS ddbbuuuu

		IF .NOT. (TYPE("item_name") = "C" .AND. TYPE("contents") = "C")
			USE
			error_msg("Invalid view file")
			RETURN .F.

		ENDIF

		* ok to restore View..set global variable
		view_file = M->filename

		* entire View will need setup
		STORE .T. TO need_field,need_ntx,need_relat,need_filtr
		stat_msg("Restoring view")

		* clear the current view if any
		i = 6

		DO WHILE M->i > 0

			IF .NOT. EMPTY(dbf[M->i])
				* clear one work area
				clear_dbf(M->i, 0)

			ENDIF

			* next
			i = M->i - 1

		ENDDO

		* select system reserved work area
		SELECT 10

		* "cur_dir" and "n_files" always saved first
		cur_dir = get_line()
		n_files = VAL(get_line())

		IF TRIM(item_name) == "k_filter"
			* continued support for old format
			REPLACE item_name WITH "kf1"
			kf1 = get_line()

		ELSE

			DO WHILE SUBSTR(item_name, 1, 2) == "kf"
				* get one filter expression
				m_name = TRIM(item_name)

				* assign the expression
				&m_name = get_line()

			ENDDO
		ENDIF

		* all remaining information to be stored in global arrays
		DO WHILE .NOT. EOF()
			* get next array identifier and initialize subscript
			m_name = TRIM(item_name)
			i = 1

			* fill one array
			DO WHILE TRIM(item_name) == m_name
				* fill one element of array
				&m_name[i] = get_line()

				* next element
				i = i + 1

			ENDDO
		ENDDO

		* close the view file
		USE

		* open all data files in their select areas
		i = 1

		DO WHILE M->i <= 6

			IF EMPTY(dbf[M->i])
				* no more data files to open
				EXIT

			ENDIF

			* select the corresponding work area
			SELECT (M->i)

			* open the data file
			filename = dbf[M->i]
			USE &filename

			* next work area
			i = M->i + 1

		ENDDO

		stat_msg("")
		done = .T.

ENDCASE

RETURN M->done


******
*	get_line()
*
*	assemble contents of variable from .VEW file
******
FUNCTION get_line

PRIVATE line

* assign contents from first record
line = TRIM(contents)
SKIP

DO WHILE LEN(TRIM(item_name)) = 0 .AND. .NOT. EOF()
	* blank name field means contents are continued in next record
	line = line + TRIM(contents)
	SKIP

ENDDO

RETURN line


* EOF DBUVIEW.PRG
************
*
*	Program....:  DBU
*	Filename...:  DBUSTRU.PRG
*	Author.....:  Dennis L. Dias
*	Date.......:  06/18/86
*	Purpose....:  Create/Modify Structure Module
*
*	Copyright (c) 1986,1987 Nantucket Corp., All Rights Reserved.
*
************


******
*	modi_stru
*
*	create or modify the structure of a database file
******
PROCEDURE modi_stru

PRIVATE filename,fill_row,cur_row,rec1,m_item,i,n,f_name,f_type,f_len,f_dec,;
		prev_rec,field_id,stru_ok,is_insert,is_append,altered,type_n,;
		empty_row,not_empty,old_help,chg_name,len_temp,stru_name,;
		wstru_buff

* save help code
old_help = help_code

* allocate buffer and save window
wstru_buff = SAVESCREEN(8, 20, 23, 59)

* local arrays..constant values
DECLARE ffield[4]
DECLARE field_col[4]
DECLARE data_type[5]
DECLARE l_usr[5]

* field list for structure file
ffield[1] = "field_name"
ffield[2] = "field_type"
ffield[3] = "field_len"
ffield[4] = "field_dec"

* display columns for ffield[]
field_col[1] = 22
field_col[2] = 35
field_col[3] = 48
field_col[4] = 55

* data types as character strings
data_type[1] = "Character"
data_type[2] = "Numeric  "
data_type[3] = "Date     "
data_type[4] = "Logical  "
data_type[5] = "Memo     "

* last user definable ffield for each data type
l_usr[1] = 3			&& character - variable len
l_usr[2] = 4			&& numeric - variable len and dec
l_usr[3] = 2			&& date - fixed len - 8
l_usr[4] = 2			&& logical - fixed len - 1
l_usr[5] = 2			&& memo - fixed len - 10

* initialize local variables
type_n = 1				&& index into data types
altered = .F.			&& any changes?
chg_name = .T.			&& possible to change field names?
prev_rec = 0			&& detect record movement
n = 1					&& current cursor column (1 - 4)
i = 0					&& invalid field aspect
cur_row = 13			&& current cursor row
is_insert = .F.			&& .T. if insert new field
keystroke = 999			&& for initial screen fill
filename = ""			&& variable for "filebox" function

* sigle row templates
empty_row = "           ณ           ณ       ณ    "
not_empty = "           ณ Character ณ    10 ณ    "

IF .NOT. EMPTY(M->cur_dbf)
	* modify structure
	stat_msg("Reading file structure")
	stru_name = M->cur_dbf
	SELECT (M->cur_area)

	* create system structure extended file
	COPY TO ddbbuuuu.ext STRUCTURE EXTENDED

	* open structure extended file in system reserved select area
	SELECT 10
	USE ddbbuuuu.ext

	* structure is valid and no new fields added
	stru_ok = .T.
	is_append = .F.

	* update screen header
	stat_msg("")

ELSE
	* create structure
	SELECT 10
	CREATE ddbbuuuu.ext

	* add first new field as yet undefined
	APPEND BLANK
	REPLACE field_type WITH "C",field_len WITH 10,field_dec WITH 0

	* structure is not valid
	stru_ok = .F.
	is_append = .T.
	stru_name = ""

ENDIF

* clear and frame window
scroll(8, 20, 23, 59, 0)
@ 8, 20, 23, 59 BOX M->frame

* establish window heading
@ 9,field_col[1];
SAY "Structure of " + pad(IF(EMPTY(stru_name), "<new file>",;
							SUBSTR(stru_name, RAT("\", stru_name) + 1)), 13)

@ 11,22 SAY   "Field Name   Type        Width   Dec"
@ 12,20 SAY "ฦออออออออออออัอออออออออออัอออออออัอออออต"
@ 23,33 SAY              "ฯอออออออออออฯอออออออฯ"

DO WHILE .NOT. q_check()
	* the big switch

	DO CASE

		CASE keystroke = 999
			* draw window
			scroll(13, 21, 22, 58, 0)			&& clear window
			rec1 = RECNO()						&& first record in window
			fill_row = 13						&& first row to fill

			DO WHILE .NOT. EOF() .AND. fill_row <= 22
				* fill the window
				stru_row(fill_row)

				* next field/record number
				SKIP
				fill_row = fill_row + 1

			ENDDO

			DO WHILE fill_row <= 22
				* end of file..complete vertical bar lines
				@ fill_row,field_col[1] SAY empty_row
				fill_row = fill_row + 1

			ENDDO

			* adjust record pointer to current row
			GOTO rec1
			fill_row = 13

			DO WHILE fill_row < cur_row
				* move to same row if possible
				SKIP

				IF EOF()
					* can't go all the way
					cur_row = fill_row
					GO BOTTOM
					EXIT

				ENDIF

				fill_row = fill_row + 1

			ENDDO

			keystroke = 0			&& get new keystroke

		CASE keystroke = 13 .OR. isdata(keystroke)
			* enter/select something

			IF n = 2
				* field_type gets special treatment
				type_n = AT(field_type, "CNDLM")

			ELSE
				* turn on cursor for GET
				SET CURSOR ON

				IF keystroke <> 13
					* forward data character to GET system
					KEYBOARD CHR(keystroke)

				ENDIF
			ENDIF

			* get descriptor fieldname to normal variable for macro expansion
			field_id = ffield[n]

			* save item to test for change
			m_item = &field_id

			* set up and down arrows and menu keys to exit read
			SET KEY 5 TO clear_gets
			SET KEY 24 TO clear_gets
			xkey_clear()

			DO CASE

				CASE n = 1
					* get is for field_name..force all caps
					@ cur_row,field_col[1] GET field_name PICTURE "@!K"
					READ
					keystroke = LASTKEY()

				CASE n = 2
					* special treatment for field_type

					DO CASE

						CASE UPPER(CHR(keystroke)) $ "CNDLM"
							* set field type to one of C, N, D, L, or M
							type_n = AT(UPPER(CHR(keystroke)), "CNDLM")
							keystroke = 13

						CASE keystroke = 32
							* space bar..revolving field types
							type_n = IF(type_n = 5, 1, type_n + 1)

						CASE keystroke <> 13
							* return key behaves like right arrow
							keystroke = 0

					ENDCASE

					IF m_item <> SUBSTR("CNDLM", type_n, 1)
						* set new field_type from type_n
						REPLACE field_type WITH SUBSTR("CNDLM", type_n, 1)

						DO CASE
							* set field_len and field_dec according to type

							CASE field_type = "C"
								* character..any len will do, but not any dec
								REPLACE field_dec WITH 0

							CASE field_type = "N"
								* numeric

								IF m_item = "C" .AND. (field_dec <> 0 .OR.;
								   field_len > 19)
									* too long or Clipper extended len
									REPLACE field_len WITH 10,field_dec WITH 0

								ENDIF

							CASE field_type = "D"
								* date..always 8
								REPLACE field_len WITH 8,field_dec WITH 0

							CASE field_type = "L"
								* logical..always 1
								REPLACE field_len WITH 1,field_dec WITH 0

							CASE field_type = "M"
								* memo..always 10
								REPLACE field_len WITH 10,field_dec WITH 0

						ENDCASE

						* display new field_len
						@ cur_row,field_col[3] SAY STR(field_len,4)

						IF field_type = "N"
							* display new field_dec
							@ cur_row,field_col[4] SAY field_dec

						ELSE
							* ensure a blank field_dec column
							@ cur_row,field_col[4] SAY "   "

						ENDIF
					ENDIF new type

				CASE n = 3
					* get is for field_len

					IF field_type = "C"
						* get Clipper extended field length into memvar
						len_temp = (256 * field_dec) + field_len

					ELSE
						* normal field_len
						len_temp = field_len

					ENDIF

					* get the new length
					@ cur_row,field_col[n] GET len_temp PICTURE "9999"
					READ
					keystroke = LASTKEY()

					IF menu_key() = 0
						* no menu request

						IF field_type = "C"
							* put Clipper extended field length into len/dec
							REPLACE field_len WITH (len_temp % 256)
							REPLACE field_dec WITH INT(len_temp / 256)

						ELSE

							IF len_temp < 256
								* may not be a valid length
								REPLACE field_len WITH len_temp

							ELSE
								* entry not accepted
								keystroke = 0

							ENDIF
						ENDIF
					ENDIF

				CASE n = 4
					* get is for field_dec
					@ cur_row,field_col[n] GET field_dec
					READ
					keystroke = LASTKEY()

			ENDCASE

			* release keys and wipe that cursor off the screen
			SET KEY 5 TO
			SET KEY 24 TO
			xkey_norm()
			SET CURSOR OFF

			IF menu_key() <> 0
				* restore the item and forward the menu key
				REPLACE &field_id WITH m_item
				KEYBOARD CHR(keystroke)

			ENDIF

			IF m_item <> &field_id
				* something has been changed
				stru_ok = .F.		&& fieldspec may not be valid
				altered = .T.		&& structure is altered

				IF n > 1
					* can no longer change field names
					chg_name = .F.

				ENDIF
			ENDIF

			DO CASE

				CASE keystroke = 18 .OR. keystroke = 5
					* up arrow or PgUp...move up
					keystroke = 5

				CASE keystroke = 3 .OR. keystroke = 24
					* down arrow or PgDn...move down
					keystroke = 24

				CASE keystroke = 13 .OR.;
					 (isdata(keystroke) .AND. keystroke <> 32)
					* next field..space bar is used for revolving data types
					keystroke = 4

				OTHERWISE
					* same field
					keystroke = 0

			ENDCASE

			* de-hilite the current item 
			stru_item()

		CASE keystroke = 5 .AND. RECNO() > 1
			* up arrow

			IF is_append
				* test newly appended field

				IF .NOT. stru_ck(.F.)
					* delete newly appended field if exit up
					no_append()

				ENDIF
			ENDIF

			IF stru_ck(.T.)
				* move up one field
				SKIP -1

				IF cur_row = 13
					* scroll required
					scroll(13, 21, 22, 58, -1)

					* fill the blank row
					stru_row(13)

				ELSE
					cur_row = cur_row - 1

				ENDIF

				is_append = .F.
				is_insert = .F.

			ELSE
				* fieldspec no good
				n = i

			ENDIF

			keystroke = 0

		CASE keystroke = 24
			* down arrow

			IF stru_ck(RECNO() < LASTREC())
				* ok to move down one field
				SKIP

				IF EOF()
					* down arrow will append
					APPEND BLANK
					REPLACE field_type WITH "C",field_len WITH 10,;
							field_dec WITH 0
					is_append = .T.
					stru_ok = .F.
					n = 1

					IF cur_row < 22
						* show new field template
						@ cur_row + 1, field_col[1] SAY not_empty

					ENDIF

				ELSE
					is_insert = .F.

				ENDIF

				IF cur_row = 22
					* scroll required
					scroll(13, 21, 22, 58, 1)

					* fill the blank row
					stru_row(22)

				ELSE
					cur_row = cur_row + 1

				ENDIF

			ELSE
				* fieldspec no good
				n = i

			ENDIF

			keystroke = 0

		CASE keystroke = 4
			* right arrow

			IF n < l_usr[AT(field_type, "CNDLM")]
				n = n + 1

			ENDIF

			keystroke = 0

		CASE keystroke = 19
			* left arrow

			IF n > 1
				n = n - 1

			ENDIF

			keystroke = 0

		CASE keystroke = 18
			* PgUp
			keystroke = 0

			IF RECNO() = 1
				* avoid re-draw if top of file
				LOOP

			ENDIF

			IF is_append
				* test newly appended field

				IF .NOT. stru_ck(.F.)
					* delete newly appended field if exit up
					no_append()

				ENDIF
			ENDIF

			IF stru_ck(.T.)
				is_append = .F.
				is_insert = .F.

				IF RECNO() = cur_row - 12
					* record 1 is on screen..no re-draw
					GO TOP
					cur_row = 13

				ELSE
					* skip one page up and re-draw
					SKIP -(9 + cur_row - 13)
					keystroke = 999

				ENDIF

			ELSE
				* fieldspec no good..no page up
				n = i

			ENDIF

		CASE keystroke = 3
			* PgDn
			keystroke = 0

			IF is_append
				* avoid error messages
				LOOP

			ENDIF

			IF stru_ck(.T.)
				is_insert = .F.

				IF LASTREC() - RECNO() <= 22 - cur_row
					* last field is on screen
					cur_row = cur_row + LASTREC() - RECNO()
					GO BOTTOM

				ELSE
					* skip one page down
					keystroke = 999			&& cause re-draw of window
					SKIP 9 - (cur_row - 13)

					IF EOF()
						* skip incomplete
						GO BOTTOM

					ENDIF
				ENDIF

			ELSE
				* fieldspec no good
				n = i

			ENDIF

		CASE keystroke = 31
			* ^PgUp..go to top of structure file
			keystroke = 0

			IF RECNO() = 1
				* top of file
				LOOP

			ENDIF

			IF is_append
				* test newly appended field

				IF .NOT. stru_ck(.F.)
					* delete newly appended field if exit up
					no_append()

				ENDIF
			ENDIF

			IF stru_ck(.T.)
				is_append = .F.
				is_insert = .F.

				IF RECNO() > cur_row - 12
					* record 1 is not on screen
					keystroke = 999

				ENDIF

				GO TOP
				cur_row = 13

			ELSE
				* fieldspec no good
				n = i

			ENDIF

		CASE keystroke = 30
			* ^PgDn
			keystroke = 0

			IF is_append
				* avoid error messages
				LOOP

			ENDIF

			IF stru_ck(.T.)
				is_insert = .F.

				IF LASTREC() - RECNO() <= 22 - cur_row
					* last field is on screen
					cur_row = cur_row + LASTREC() - RECNO()
					GO BOTTOM

				ELSE
					* re-draw window with lastrec on last row
					keystroke = 999
					GO BOTTOM
					SKIP -9
					cur_row = 22

				ENDIF

			ELSE
				* fieldspec no good
				n = i

			ENDIF

		CASE keystroke = 6 .OR. keystroke = 23
			* end or ^end
			keystroke = 0
			n = l_usr[AT(field_type, "CNDLM")]

		CASE keystroke = 1 .OR. keystroke = 29
			* home or ^home
			keystroke = 0
			n = 1

		CASE keystroke = 22
			* insert a new field before cursor

			IF stru_ck(.T.)
				n = 1					&& cursor on field name
				stru_ok = .F.			&& fieldspec not valid
				is_append = .F.			&& not append
				is_insert = .T.			&& new field inserted
				rec1 = RECNO()			&& remember which field

				* insert blank not available..do it the hard way
				APPEND BLANK

				DO WHILE rec1 < RECNO()
					* shift up for insert
					SKIP -1

					* get previous fieldspec
					f_name = field_name
					f_type = field_type
					f_len = field_len
					f_dec = field_dec

					* put into current fieldspec
					SKIP
					REPLACE field_name WITH f_name,field_type WITH f_type,;
							field_len WITH f_len,field_dec WITH f_dec

					* next
					SKIP -1

				ENDDO

				* make current fieldspec look like new
				REPLACE field_name WITH SPACE(10),field_type WITH "C",;
						field_len WITH 10,field_dec WITH 0

				IF cur_row < 22
					* scroll down for insert
					scroll((cur_row), 21, 22, 58, -1)

				ENDIF

				* newly added field looks like this
				@ cur_row,field_col[1] SAY not_empty

			ELSE
				* fieldspec no good
				n = i

			ENDIF

			keystroke = 0

		CASE keystroke = 7 .AND. LASTREC() > 1
			* delete..only the current record can be invalid
			rec1 = RECNO()
			DELETE
			PACK

			IF rec1 > LASTREC()
				* last record has been deleted
				GO BOTTOM

				IF cur_row = 13
					* top of window
					stru_row(13)

				ELSE
					@ cur_row,field_col[1] SAY empty_row
					cur_row = cur_row - 1

				ENDIF

			ELSE

				IF cur_row < 22
					* scroll bottom part of window up
					scroll((cur_row), 21, 22, 58, 1)

				ENDIF

				* go to last field on screen
				GOTO rec1
				SKIP 22 - cur_row

				IF .NOT. EOF()
					* fill bottom row
					stru_row(22)

				ELSE
					* put blank template on last row
					@ 22,field_col[1] SAY empty_row

				ENDIF

				* move pointer to current record
				GOTO rec1

				* same recno, but not the same record
				prev_rec = 0

			ENDIF

			IF .NOT. is_append .AND. .NOT. is_insert
				* structure is altered..cannot change names
				altered = .T.
				chg_name = .F.

			ENDIF

			* re-set tracking variables
			is_append = .F.				&& append is off
			is_insert = .F.				&& insert is off
			stru_ok = .T.				&& only current record can be invalid
			keystroke = 0

		CASE prev_rec <> RECNO()
			* record pointer has been moved and all cascading
			*	 keystrokes have been processed
			prev_rec = RECNO()

			* update field/record number on screen
			@ 9,field_col[1] + 26 SAY "Field " + pad(LTRIM(STR(RECNO())), 5)

			IF n > l_usr[AT(field_type, "CNDLM")]
				* check for n out of range
				n = l_usr[AT(field_type, "CNDLM")]

			ENDIF

		CASE local_func = 4
			* "save structure" selected from pull down menu..keystroke = 0
			local_func = 0

			IF .NOT. stru_ck(.T.)
				* fieldspec no good
				n = i
				LOOP

			ENDIF

			is_append = .F.
			is_insert = .F.
			filename = stru_name

			IF filebox(".DBF", "dbf_list", "stru_title",;
					   "do_modstru", .T., 13) <> 0
				* structure created or altered
				stru_name = filename

				* re-write name at top of window
				@ 9,field_col[1] + 13;
				SAY pad(IF(EMPTY(stru_name), "<new file>",;
							SUBSTR(stru_name, RAT("\", stru_name) + 1)), 13)

				IF aseek(dbf, filename) = 0
					* bring new file into view
					cur_dbf = filename

					open_dbf(.F., .T.)

					* select system reserved work area
					SELECT 10

				ENDIF

				* exit to main View screen
				keystroke = 27	&& exit this routine
				cur_area = 0	&& re-draw View screen

			ENDIF

			* clear message from screen
			stat_msg("")

		CASE local_func = 1
			* "help" selected from pull down menu..keystroke = 0
			local_func = 0
			DO syshelp

		OTHERWISE
			* get new keystroke

			IF .NOT. key_ready()
				* hi-lite the current item as reverse
				syscolor(2)
				stru_item()
				syscolor(1)

				* wait for keystroke
				read_key()

				IF .NOT. (keystroke = 13 .OR. isdata(keystroke))
					* this is not a GET..re-write as normal
					stru_item()

				ENDIF
			ENDIF

			IF keystroke = 27 .AND. altered
				* warning

				IF rsvp("Ok To Lose Changes? (Y/N)") <> "Y"
					keystroke = 0

				ENDIF
			ENDIF
	ENDCASE
ENDDO create/modify structure

* close and erase structure file..all done
USE
ERASE ddbbuuuu.ext

* clear status line
stat_msg("")

* restore window
RESTSCREEN(8, 20, 23, 59, M->wstru_buff)

RETURN


*******************
* local functions *
*******************

******
*	stru_row()
*
*	fill one row in structure window
******
FUNCTION stru_row

PARAMETERS fill_row

@ fill_row,field_col[1];
SAY field_name + " ณ " + data_type[AT(field_type, "CNDLM")] + " ณ "

IF field_type = "C"
	* display Clipper extended field length
	@ fill_row,field_col[3] SAY STR(((256 * field_dec) + field_len), 4) +;
								" ณ    "

ELSE
	* normal field length
	@ fill_row,field_col[3] SAY STR(field_len, 4) + " ณ    "

	IF field_type = "N"
		* display decimals for numeric field
		@ fill_row,field_col[4] SAY field_dec

	ENDIF
ENDIF

RETURN 0


******
*	stru_item()
*
*	display item in structure window
******
FUNCTION stru_item

DO CASE

	CASE n = 1
		* field_name
		@ cur_row,field_col[1] SAY field_name

	CASE n = 2
		* display field_type as character string
		@ cur_row,field_col[2] SAY data_type[AT(field_type, "CNDLM")]

	CASE n = 3

		IF field_type = "C"
			* display Clipper extended field length
			@ cur_row,field_col[n] SAY STR(((256 * field_dec) +;
										   field_len),4)

		ELSE
			* normal field_len
			@ cur_row,field_col[n] SAY STR(field_len,4)

		ENDIF

	CASE n = 4
		* field_dec
		@ cur_row,field_col[4] SAY field_dec

ENDCASE

RETURN 0


******
*	no_append()
*
*	eliminate newly appended field/record
******
FUNCTION no_append

DELETE
PACK
GO BOTTOM
SKIP

IF (RECNO() = cur_row - 12) .OR. keystroke = 5
	* blank the current row
	@ cur_row,field_col[1] SAY empty_row

ENDIF

stru_ok = .T.

RETURN 0


******
*	stru_ck()
*
*	test fieldspec if needed
******
FUNCTION stru_ck

PARAMETERS disp_err

IF .NOT. stru_ok
	* fieldspec needs testing
	i = field_check(disp_err)
	stru_ok = (i = 0)

ENDIF

RETURN stru_ok


******
*	field_check()
*
*	return number of invalid field aspect (field_name = 1, etc.), 0 if ok
******
FUNCTION field_check

PARAMETERS disp_err
PRIVATE pos,test_num,test_name,status,err_msg

* initialize local variables
status = 0
err_msg = ""

* test for valid field name
pos = LEN(TRIM(field_name))

IF pos = 0
	* blank
	status = 1
	err_msg = "Blank Field Name"

ENDIF

IF status = 0

	DO WHILE pos > 0 .AND. SUBSTR(field_name, pos, 1) $;
						   "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_"
		* validate all characters except trailing spaces
		pos = pos - 1

	ENDDO

	* the first character must be a letter
	IF pos > 0 .OR. SUBSTR(field_name, 1, 1) $ "0123456789_"
		* invalid character
		status = 1
		err_msg = "Illegal Field Name"

		IF keystroke = 24
			* force error display for illegal down arrow
			disp_err = .T.

		ENDIF
	ENDIF
ENDIF

IF status = 0
	* look for duplicate field name
	test_num = RECNO()
	test_name = field_name
	LOCATE FOR field_name = test_name .AND. RECNO() <> test_num

	IF FOUND()
		* duplicate field name
		status = 1
		err_msg = "Duplicate Field Name"

		IF keystroke = 24
			* force error display for illegal down arrow
			disp_err = .T.

		ENDIF
	ENDIF

	* re-set pointer to current record
	GOTO test_num

ENDIF

IF status = 0
	* test for valid field_len

	IF field_type = "C"
		test_num = (256 * field_dec) + field_len

		IF test_num <= 0 .OR. test_num > 1024
			* invalid field width
			status = 3
			err_msg = "Invalid Field Width"

			IF keystroke = 24
				* force error display for illegal down arrow
				disp_err = .T.

			ENDIF
		ENDIF

	ELSE

		IF field_len <= 0 .OR. field_len > 19
			* invalid field width
			status = 3
			err_msg = "Invalid Field Width"

			IF keystroke = 24
				* force error display for illegal down arrow
				disp_err = .T.

			ENDIF
		ENDIF
	ENDIF
ENDIF

IF field_type = "N" .AND. status = 0
	* test for valid field_dec

	IF field_dec > IF(field_len < 3, 0, IF(field_len > 17, 15, field_len - 2))
		* invalid decimal width
		status = 4
		err_msg = "Invalid Decimal Width"

		IF keystroke = 24
			* force error display for illegal down arrow
			disp_err = .T.

		ENDIF
	ENDIF
ENDIF

IF status > 0 .AND. disp_err
	* something not right that ought to be shown
	error_msg(err_msg)

ENDIF

RETURN status


*********************************
* functions called from filebox *
*********************************

******
*	stru_title()
*
*	display title for save structure filebox
******
FUNCTION stru_title

PARAMETERS sysparam

RETURN box_title(M->sysparam, "Save structure as...")


******
*	do_modstru()
*
*	create/modify structure
******
FUNCTION do_modstru

PRIVATE stru_done, i, is_open, new_name, name_temp, add_name,;
		dbt_spec, dbt_temp, rec1

DO CASE

	CASE EMPTY(filename)
		error_msg("File name not entered")
		stru_done = .F.

	OTHERWISE
		* determine if structure to be created is currently open
		i = aseek(dbf, filename)
		is_open = (i > 0)

		IF FILE(filename) .AND. .NOT. (filename == cur_dbf)
			* file exists and is not the current data file being modified

			IF rsvp(filename + IF(is_open, " Is Currently Open",;
										   " Already Exists") +;
					"...Overwrite? (Y/N)") <> "Y"
				* oops
				RETURN .F.

			ENDIF
		ENDIF

		IF is_open
			* can't really modify an open file, but we make it look that way
			name_temp = "ntx" + SUBSTR("123456", i, 1)
			need_ntx = need_ntx .OR. .NOT. EMPTY(&name_temp[1])

			* temporarily disable any relations targeted at the open file
			not_target(i, .F.)

			* close the file
			SELECT (M->i)
			USE

			name_temp = "kf" + SUBSTR("123456", i, 1)

			IF .NOT. EMPTY(&name_temp)
				* will need to re-set the filter for the open file
				need_filtr = .T.

			ENDIF

			* select system reserved work area
			SELECT 10

		ENDIF

		* remember the current field number and close structure file
		rec1 = RECNO()
		USE

		* remember if file existed in current directory before
		add_name = .NOT. FILE(name(filename) + ".DBF")

		IF FILE(filename)
			* file exists..modify structure and save old data
			new_name = " "

			IF chg_name .AND. altered
				* rsvp change of field names
				new_name = rsvp("Change Field Name(s)? (Y/N)")

				IF .NOT. new_name $ "YN"
					* Escape key will cancel the operation
					USE ddbbuuuu.ext
					GOTO rec1
					RETURN .F.

				ENDIF
			ENDIF

			* establish temp filespec and dbt specs in same directory
			name_temp = SUBSTR(filename, 1, RAT("\", filename)) +;
						"DDBBUUUU.TMP"
			dbt_spec = SUBSTR(filename, 1, RAT(".", filename)) +;
					   "DBT"
			dbt_temp = SUBSTR(name_temp, 1, RAT(".", name_temp)) +;
					   "DBT"

			IF FILE(dbt_spec)
				* data file contains memo fields

				IF new_name = "Y"
					* field_name change will lose memos during SDF copy
					new_name = rsvp("Warning: Memos Will Be Lost" +;
									"...Proceed? (Y/N)")

					IF new_name <> "Y"
						* abort operation
						USE ddbbuuuu.ext
						GOTO rec1
						RETURN .F.

					ENDIF
				ENDIF

				* every dbt has its dbf
				RENAME &dbt_spec TO &dbt_temp

			ENDIF

			stat_msg(IF(new_name <> "Y", "Altering file structure",;
						"Changing field name(s)"))

			* save the old and create the new
			RENAME &filename TO &name_temp
			CREATE &filename FROM ddbbuuuu.ext

			IF new_name = "Y"
				* change field names by copying SDF
				USE &name_temp
				COPY TO ddbbuuuu.txt SDF
				USE &filename
				APPEND FROM ddbbuuuu.txt SDF
				ERASE ddbbuuuu.txt

			ELSE
				* normal modify structure
				APPEND FROM &name_temp

			ENDIF

			IF FILE(name_temp)
				* delete temp file
				ERASE &name_temp

			ENDIF

			IF FILE(dbt_temp)
				* delete temp dbt file
				ERASE &dbt_temp

			ENDIF

			IF is_open
				* re-establish file in its original select area
				USE					&& close in system reserved area
				SELECT (M->i)		&& select the correct area
				USE &filename		&& re-open the file

				* establish new field list for new structure
				name_temp = "field_n" + SUBSTR("123456", M->i, 1)
				all_fields(M->i, &name_temp)

				* re-select system reserved area
				SELECT 10

			ENDIF

		ELSE
			* create new file
			stat_msg("Creating new data file")
			CREATE &filename FROM ddbbuuuu.ext
			USE

			IF AT(".DBF", filename) = LEN(filename) - 3 .AND.;
			   FILE(name(filename) + ".DBF") .AND. add_name
				* add only .dbf files in the current directory
				i = afull(dbf_list) + 1

				IF i <= LEN(dbf_list)
					* add new file name to list
					dbf_list[i] = filename
					array_sort(dbf_list)

				ENDIF
			ENDIF
		ENDIF

		* close newly created or modified file
		USE
		stru_done = .T.

ENDCASE

RETURN stru_done


* EOF DBUSTRU.PRG
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
@ M->hsep_row, 0 SAY "ฦ"
@ M->hsep_row, 79 SAY "ต"

IF LASTREC() = 0 .AND. M->can_append
	* empty file..force append mode
	KEYBOARD CHR(24)

ENDIF

dbedit(10, 1, 23, 78, &field_a, "xbrowse", .T., .T., .T., .T., "อฯอ")

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
************
*
*	Program....:  DBU
*	Filename...:  DBUINDX.PRG
*	Author.....:  Dennis L. Dias
*	Date.......:  06/18/86
*	Purpose....:  Index Read/Write Module
*
*	Copyright (c) 1986,1987 Nantucket Corp., All Rights Reserved.
*
************


******
*	make_ntx
*
*	create index file
*
*	note: see multibox in DBUUTIL.PRG
******
PROCEDURE make_ntx

PRIVATE filename, files, fi_disp, okee_dokee, cur_el, rel_row, def_ext,;
		bcur, fi_done, el, cr, ntx, k_exp

* set local variables to macro reference specific arrays
cr = "cr" + SUBSTR("123456", M->cur_area, 1)
el = "el" + SUBSTR("123456", M->cur_area, 1)
ntx = "ntx" + SUBSTR("123456", M->cur_area, 1)

* get name of current index file
filename = &ntx[&el[2]]

* hi-lite the current index file..even if empty
syscolor(2)
@ &cr[2], column[M->cur_area] + 2 SAY pad(name(M->filename), 8)
syscolor(1)

* temporarily disable any relations and filters that may be active
SELECT (M->cur_area)
SET FILTER TO
CLOSE INDEX
need_filtr = .T.
need_ntx = .T.
not_target(SELECT(), .F.)
SELECT (M->cur_area)

* initialize variables for multibox sub-system
cur_el = 1
rel_row = 0
files = "ntx_list"
def_ext = INDEXEXT()

IF .NOT. EMPTY(M->filename)
	* set up for quick re-index
	k_exp = ntx_key(M->filename)
	bcur = 4

ELSE
	* assume new file to be created
	k_exp = ""
	bcur = 2

ENDIF

* establish array of functions for multi-box
DECLARE boxarray[6]

boxarray[1] = "ntx_title(sysparam)"
boxarray[2] = "ntx_getfil(sysparam)"
boxarray[3] = "ntx_exp(sysparam)"
boxarray[4] = "ok_button(sysparam)"
boxarray[5] = "can_button(sysparam)"
boxarray[6] = "filelist(sysparam)"

* define certain sub-processes
fi_disp = "ntx_exist()"
fi_done = "ntx_done()"
okee_dokee = "do_index()"

IF multibox(13, 17, 9, M->bcur, M->boxarray) <> 0 .AND.;
   aseek(&ntx, M->filename) = 0
	* index file generated and not open

	IF M->n_files < 14 .OR. .NOT. EMPTY(&ntx[&el[2]])
		* room for one more..bring index file into View

		IF EMPTY(&ntx[&el[2]])
			* keep track of number of open files
			n_files = M->n_files + 1

		ENDIF

		* place in global array
		&ntx[&el[2]] = M->filename

	ENDIF
ENDIF

* re-write index filename as normal
@ &cr[2], column[M->cur_area] + 2 SAY pad(name(&ntx[&el[2]]), 8)

RETURN


*******************************
* support functions for INDEX *
*******************************

******
*	ntx_title()
*
*	display title for "index"
******
FUNCTION ntx_title

PARAMETERS sysparam

RETURN box_title(M->sysparam, "Index " +;
							  SUBSTR(M->cur_dbf, RAT("\", M->cur_dbf) + 1) +;
							  " to...")


******
*	ntx_getfil()
*
*	get target filename for "index"
******
FUNCTION ntx_getfil

PARAMETERS sysparam

RETURN getfile(M->sysparam, 4)


******
*	ntx_done()
*
*	preliminary test of filename typed into entry field
******
FUNCTION ntx_done

PRIVATE done_ok

done_ok = .NOT. EMPTY(M->filename)

IF M->done_ok
	* filename entered

	IF FILE(M->filename) .AND. EMPTY(M->k_exp)
		* read and display the key expression from the index file
		k_exp = ntx_key(M->filename)
		ntx_exp(3)

	ENDIF

	IF EMPTY(M->k_exp)
		* move cursor to expression field
		KEYBOARD CHR(24)

	ELSE
		* expression entered..move cursor to the "Ok" button
		to_ok()

	ENDIF
ENDIF

RETURN M->done_ok


******
*	ntx_exp()
*
*	get key expression for "index"
******
FUNCTION ntx_exp

PARAMETERS sysparam

RETURN get_exp(M->sysparam, "KEY    ", 6, "k_exp")


******
*	ntx_exist()
*
*	display filename selected from list and get key from file
******
FUNCTION ntx_exist

IF EMPTY(M->k_exp)
	* expression not entered..read it from the selected index file
	k_exp = ntx_key(M->filename)

ENDIF

* display the filename and key
ntx_getfil(3)
ntx_exp(3)

RETURN 0


******
*	do_index()
*
*	do the index command
*
*	note: this function is called when <enter> is pressed
*		  while the cursor is on the "Ok" button
******
FUNCTION do_index

PRIVATE done, n_dup, new_el, add_name

* get number of select area using this index if any
n_dup = dup_ntx(M->filename)

DO CASE

	CASE EMPTY(M->filename)
		error_msg("Index file not selected")
		done = .F.

	CASE M->n_dup > 0 .AND. M->n_dup <> SELECT()
		error_msg("Index in use by another data file")
		done = .F.

	CASE EMPTY(M->k_exp)
		error_msg("Index key not entered")
		done = .F.

	CASE .NOT. TYPE(M->k_exp) $ "CND"
		error_msg("Key expression not valid")
		done = .F.

	OTHERWISE
		* ok to generate index
		stat_msg("Generating index file")
		add_name = .NOT. FILE(name(M->filename) + INDEXEXT())
		INDEX ON &k_exp TO &filename
		CLOSE INDEX

		IF AT(INDEXEXT(), M->filename) = LEN(M->filename) - 3 .AND.;
		   FILE(name(M->filename) + INDEXEXT()) .AND. M->add_name
			* add only .ntx files in the current directory

			new_el = afull(M->ntx_list) + 1

			IF M->new_el <= LEN(M->ntx_list)
				* add file to array
				ntx_list[M->new_el] = M->filename
				array_sort(M->ntx_list)

			ENDIF
		ENDIF

		stat_msg("File indexed")
		done = .T.

ENDCASE

RETURN M->done


* EOF DBUINDX.PRG
************
*
*	Program....:  DBU
*	Filename...:  DBUCOPY.PRG
*	Author.....:  Dennis L. Dias
*	Date.......:  06/18/86
*	Purpose....:  Copy and Append Module
*
*	Copyright (c) 1986,1987 Nantucket Corp., All Rights Reserved.
*
************


******
*	capprep
*
*	copy/append/replace
*
*	note: see multibox in DBUUTIL.PRG
******
PROCEDURE capprep

PRIVATE filename, files, fi_disp, okee_dokee, cur_el, rel_row, def_ext, mode,;
		fi_done, for_cond, while_cond, how_many, bcur, for_row, height,;
		field_mvar, with_what

IF M->func_sel = 3
	* replace command
	help_code = 22

	* select current work area
	SELECT (M->cur_area)

	* initialize variables to contain fieldname and replace expression
	field_mvar = ""
	with_what = ""

	* get master field list into local array for selection
	DECLARE field_m[FCOUNT()]
	all_fields(M->cur_area, M->field_m)

	* set up for multi-box
	DECLARE boxarray[9]
	boxarray[1] = "repl_title(sysparam)"
	boxarray[2] = "repl_field(sysparam)"
	boxarray[3] = "with_exp(sysparam)"
	boxarray[4] = "for_exp(sysparam)"
	boxarray[5] = "while_exp(sysparam)"
	boxarray[6] = "scope_num(sysparam)"
	boxarray[7] = "ok_button(sysparam)"
	boxarray[8] = "can_button(sysparam)"
	boxarray[9] = "fieldlist(sysparam)"

	* size and configuration
	bcur = 9			&& beginning cursor on field list
	for_row = 6
	height = 10
	okee_dokee = "do_replace()"
	fi_disp = "repl_field(3)"

ELSE
	* initialize filename variable
	filename = ""

	* only copy and append use a list of text files
	DECLARE txt_list[adir("*.TXT") + 20]		&& directory of text files
	array_dir("*.TXT",txt_list)					&& fill array with filenames

	* set up for multi-box
	DECLARE boxarray[10]

	IF M->func_sel = 1
		* copy command
		help_code = 12
		bcur = 2			&& beginning cursor on filename entry field
		boxarray[1] = "copy_title(sysparam)"
		boxarray[2] = "trg_getfil(sysparam)"
		fi_disp = "trg_getfil(3)"
		okee_dokee = "do_copy()"

	ELSE
		* append command
		help_code = 15
		bcur = 10			&& beginning cursor on selection list
		boxarray[1] = "appe_title(sysparam)"
		boxarray[2] = "src_getfil(sysparam)"
		fi_disp = "src_getfil(3)"
		okee_dokee = "do_append()"

	ENDIF

	* remainder of setup common to copy and append
	boxarray[3] = "for_exp(sysparam)"
	boxarray[4] = "while_exp(sysparam)"
	boxarray[5] = "scope_num(sysparam)"
	boxarray[6] = "tog_sdf(sysparam)"
	boxarray[7] = "ok_button(sysparam)"
	boxarray[8] = "tog_delim(sysparam)"
	boxarray[9] = "can_button(sysparam)"
	boxarray[10] = "filelist(sysparam)"

	* size and configuration
	for_row = 5
	height = 11

	* DBF for normal mode
	files = "dbf_list"
	def_ext = ".DBF"

	* when is a filename acceptable?
	fi_done = "not_empty('filename')"

ENDIF

* initialize local variables
STORE "" TO for_cond, while_cond

* normal mode, scope = ALL, top of selection list
STORE 1 TO mode,cur_el
rel_row = 0
how_many = 0

* do it with the all-purpose switchbox
multibox(8, 17, M->height, M->bcur, M->boxarray)
RETURN


******************************
* functions specific to COPY *
******************************

******
*	copy_title()
*
*	display title for "copy"
******
FUNCTION copy_title

PARAMETERS sysparam

RETURN box_title(M->sysparam, "Copy " +;
							  SUBSTR(M->cur_dbf, RAT("\", M->cur_dbf) + 1) +;
							  " to...")


******
*	trg_getfil()
*
*	get target filename for "copy"
******
FUNCTION trg_getfil

PARAMETERS sysparam

help_code = M->prime_help
RETURN getfile(M->sysparam, 3)


******
*	do_copy()
*
*	do the copy command
*
*	note: this function is called when <enter> is pressed
*		  while the cursor is on the "Ok" button
******
FUNCTION do_copy

PRIVATE done, add_name, new_el

* assume incomplete
done = .F.

DO CASE

	CASE EMPTY(M->filename)
		error_msg("Target not selected")

	CASE M->filename == M->cur_dbf
		error_msg("File cannot be coppied onto itself")

	CASE .NOT. EMPTY(M->for_cond) .AND. TYPE(M->for_cond) <> "L"
		error_msg("FOR condition must be a Logical expression")

	CASE .NOT. EMPTY(M->while_cond) .AND. TYPE(M->while_cond) <> "L"
		error_msg("WHILE condition must be a Logical expression")

	OTHERWISE
		* ok to copy file

		IF FILE(M->filename)

			IF rsvp("Target File " + IF(aseek(M->dbf, M->filename) > 0,;
					"Is Open", "Exists") + "...Overwrite? (Y/N)") <> "Y"
				RETURN .F.

			ENDIF
		ENDIF

		stat_msg("Copying")

		IF aseek(M->dbf, M->filename) > 0
			* copying to an open file...good luck!
			SELECT (aseek(M->dbf, M->filename))
			USE
			STORE .T. TO need_field,need_ntx,need_relat,need_filtr

		ENDIF

		SELECT (M->cur_area)

		IF RAT(M->def_ext, M->filename) = LEN(M->filename) - 3
			* target has default extension..does it exists in current dir?
			add_name = .NOT. FILE(name(M->filename) + M->def_ext)

		ELSE
			add_name = .F.

		ENDIF

		IF EMPTY(M->for_cond)
			* literal true is the same as no FOR condition
			for_cond = ".T."

		ENDIF

		IF EMPTY(M->while_cond)
			* literal true is correct only from top of file
			while_cond = ".T."

			IF M->how_many = 0
				* unless a scope has been entered
				GO TOP

			ENDIF
		ENDIF

		DO CASE

			CASE M->mode = 1 .AND. M->how_many = 0
				COPY TO &filename WHILE &while_cond FOR &for_cond

			CASE M->mode = 1 .AND. M->how_many > 0
				COPY TO &filename NEXT M->how_many WHILE &while_cond;
						FOR &for_cond

			CASE M->mode = 2 .AND. M->how_many = 0
				COPY TO &filename WHILE &while_cond FOR &for_cond;
						SDF

			CASE M->mode = 2 .AND. M->how_many > 0
				COPY TO &filename NEXT M->how_many WHILE &while_cond;
						FOR &for_cond SDF

			CASE M->mode = 3 .AND. M->how_many = 0
				COPY TO &filename WHILE &while_cond FOR &for_cond;
						DELIMITED

			CASE M->mode = 3 .AND. M->how_many > 0
				COPY TO &filename NEXT M->how_many WHILE &while_cond;
						FOR &for_cond DELIMITED

		ENDCASE

		IF aseek(M->dbf, M->filename) > 0
			* copying to an open file...good luck again!
			SELECT (aseek(M->dbf, M->filename))
			USE &filename

		ENDIF

		IF FILE(name(M->filename) + M->def_ext) .AND. M->add_name
			* add only .dbf files in the current directory
			new_el = afull(&files) + 1

			IF M->new_el <= LEN(&files)
				&files[M->new_el] = M->filename
				array_sort(&files)

			ENDIF
		ENDIF

		stat_msg("File copied")
		done = .T.

ENDCASE

RETURN M->done


********************************
* functions specific to APPEND *
********************************

******
*	appe_title()
*
*	display title for "append"
******
FUNCTION appe_title

PARAMETERS sysparam

RETURN box_title(M->sysparam, "Append to " +;
							  SUBSTR(M->cur_dbf, RAT("\", M->cur_dbf) + 1) +;
							  " from")


******
*	src_getfil()
*
*	get source filename for "append"
******
FUNCTION src_getfil

PARAMETERS sysparam

help_code = M->prime_help
RETURN getfile(M->sysparam, 3)


******
*	do_append()
*
*	do the append command
*
*	note: this function is called when <enter> is pressed
*		  while the cursor is on the "Ok" button
******
FUNCTION do_append

PRIVATE done

* assume incomplete
done = .F.

DO CASE

	CASE EMPTY(M->filename)
		error_msg("Source not selected")

	CASE M->filename == M->cur_dbf
		error_msg("File cannot be appended from itself")

	CASE .NOT. FILE(M->filename)
		error_msg("Can't open " + M->filename)

	CASE .NOT. EMPTY(M->for_cond) .AND. TYPE(M->for_cond) <> "L"
		error_msg("FOR condition must be a Logical expression")

	CASE .NOT. EMPTY(M->while_cond) .AND. TYPE(M->while_cond) <> "L"
		error_msg("WHILE condition must be a Logical expression")

	OTHERWISE
		* ok to append

		IF aseek(M->dbf, M->filename) > 0
			* appending from an open file
			SELECT (aseek(M->dbf, M->filename))
			USE
			STORE .T. TO need_field,need_ntx,need_relat,need_filtr

		ENDIF

		stat_msg("Appending")
		SELECT (M->cur_area)

		IF EMPTY(M->for_cond)
			* literal true is the same as no FOR condition
			for_cond = ".T."

		ENDIF

		IF EMPTY(M->while_cond)
			* literal true is the same as no WHILE condition
			while_cond = ".T."

		ENDIF

		DO CASE

			CASE M->mode = 1 .AND. M->how_many = 0
				APPEND FROM &filename WHILE &while_cond FOR;
							&for_cond

			CASE M->mode = 1 .AND. M->how_many > 0
				APPEND FROM &filename NEXT M->how_many WHILE;
							&while_cond FOR &for_cond

			CASE M->mode = 2 .AND. M->how_many = 0
				APPEND FROM &filename WHILE &while_cond FOR;
							&for_cond SDF

			CASE M->mode = 2 .AND. M->how_many > 0
				APPEND FROM &filename NEXT M->how_many WHILE;
							&while_cond FOR &for_cond SDF

			CASE M->mode = 3 .AND. M->how_many = 0
				APPEND FROM &filename WHILE &while_cond FOR;
							&for_cond DELIMITED

			CASE M->mode = 3 .AND. M->how_many > 0
				APPEND FROM &filename NEXT M->how_many WHILE;
							&while_cond FOR &for_cond DELIMITED

		ENDCASE

		IF aseek(M->dbf, M->filename) > 0
			* appending from an open file
			SELECT (aseek(M->dbf, M->filename))
			USE &filename

		ENDIF

		stat_msg("Append completed")
		done = .T.

ENDCASE

RETURN M->done


*********************************
* functions specific to REPLACE *
*********************************

******
*	repl_title()
*
*	display title for "replace"
******
FUNCTION repl_title

PARAMETERS sysparam

RETURN box_title(M->sysparam, "Replace in " +;
							  SUBSTR(M->cur_dbf, RAT("\", M->cur_dbf) + 1) +;
							  "...")


******
*	repl_field()
*
*	get fieldname for replace (only one field can be replaced at a time)
******
FUNCTION repl_field

PARAMETERS sysparam

help_code = M->prime_help
RETURN genfield(M->sysparam, .T.)


******
*	with_exp()
*
*	get "with" expression for replace
******
FUNCTION with_exp

PARAMETERS sysparam
PRIVATE rval

help_code = M->prime_help
rval = get_exp(M->sysparam, "WITH   ", 4, "with_what")

IF M->sysparam = 4 .AND. LASTKEY() = 13 .AND. .NOT. EMPTY(M->with_what)
	* expression just entered..dehilite and jump to 'Ok'
	get_exp(3, "WITH   ", 4, "with_what")
	to_ok()

ENDIF

RETURN M->rval


******
*	do_replace()
*
*	do the replace command
*
*	note: this function is called when <enter> is pressed
*		  while the cursor is on the "Ok" button
******
FUNCTION do_replace

PRIVATE done

* assume incomplete
done = .F.

DO CASE

	CASE EMPTY(M->field_mvar)
		error_msg("Field not selected")

	CASE EMPTY(M->with_what)
		error_msg("Replace expression not entered")

	CASE TYPE(M->with_what) <> TYPE(M->field_mvar)
		error_msg("Type mismatch between replace expression and field")

	CASE .NOT. EMPTY(M->for_cond) .AND. TYPE(M->for_cond) <> "L"
		error_msg("FOR condition must be a Logical expression")

	CASE .NOT. EMPTY(M->while_cond) .AND. TYPE(M->while_cond) <> "L"
		error_msg("WHILE condition must be a Logical expression")

	OTHERWISE
		* ok to replace
		stat_msg("Replacing data")

		IF EMPTY(M->for_cond)
			* literal true is the same as no FOR condition
			for_cond = ".T."

		ENDIF

		IF EMPTY(M->while_cond)
			* literal true is the same as no WHILE condition
			while_cond = ".T."

			IF M->how_many = 0
				* unless a scope has been entered
				GO TOP

			ENDIF
		ENDIF

		IF M->how_many = 0
			REPLACE &field_mvar WITH &with_what;
					WHILE &while_cond FOR &for_cond

		ELSE
			REPLACE NEXT M->how_many &field_mvar WITH &with_what;
					WHILE &while_cond FOR &for_cond

		ENDIF

		stat_msg("Replace completed")
		done = .T.

ENDCASE

RETURN M->done


*************************************************
* functions common to COPY, APPEND, and REPLACE *
*************************************************

******
*	for_exp()
*
*	get "for" expression
******
FUNCTION for_exp

PARAMETERS sysparam

help_code = 16
RETURN get_exp(M->sysparam, "FOR    ", M->for_row, "for_cond")


******
*	while_exp()
*
*	get "while" expression
******
FUNCTION while_exp

PARAMETERS sysparam

help_code = 16
RETURN get_exp(M->sysparam, "WHILE  ", M->for_row + 1, "while_cond")


******
*	scope_num()
*
*	get scope
******
FUNCTION scope_num

PARAMETERS sysparam
PRIVATE old_scope

help_code = 17

DO CASE

	CASE M->sysparam = 1 .OR. M->sysparam = 3
		* normal display
		@ M->wt + M->for_row + 2, M->wl + 2;
		SAY "SCOPE  " + pad(IF(M->how_many = 0, "ALL",;
							"NEXT " + LTRIM(STR(M->how_many))), 20)

		IF M->sysparam = 1
			* report position
			@ M->wt + M->for_row + 2, M->wl + 9 SAY ""

		ENDIF

	CASE M->sysparam = 2
		* hi-lite
		syscolor(2)
		@ M->wt + M->for_row + 2, M->wl + 9;
		SAY pad(IF(M->how_many = 0,;
				   "ALL", "NEXT " + LTRIM(STR(M->how_many))), 20)
		syscolor(1)

	CASE M->sysparam = 4
		* selected

		IF CHR(M->keystroke) $ "0123456789" + CHR(13)
			* numeric digit or <enter>

			IF M->keystroke <> 13
				* include initial digit in entry
				KEYBOARD CHR(M->keystroke)

			ENDIF

			old_scope = M->how_many		&& in case of abort

			* set certain keys to exit the READ
			SET KEY 5 TO clear_gets
			SET KEY 24 TO clear_gets
			xkey_clear()

			* image is important
			syscolor(2)
			@ M->wt + M->for_row + 2, M->wl + 9 SAY pad("NEXT",20)
			syscolor(1)

			@ M->wt + M->for_row + 2, M->wl + 14;
			GET M->how_many PICTURE "99999999"

			SET CURSOR ON
			READ
			SET CURSOR OFF

			* remember the exit key
			keystroke = LASTKEY()

			* restore keys to normal
			SET KEY 5 TO
			SET KEY 24 TO
			xkey_norm()

			IF M->keystroke = 13
				* jump to "Ok" button
				to_ok()
				@ M->wt + M->for_row + 2, M->wl + 9;
				SAY pad(IF(M->how_many = 0, "ALL", "NEXT " +;
						LTRIM(STR(M->how_many))), 20)

			ELSE

				IF menu_key() <> 0
					* menu request
					how_many = M->old_scope

				ENDIF

				IF M->keystroke <> 27 .AND. .NOT. isdata(M->keystroke)
					* forward the request
					KEYBOARD CHR(M->keystroke)

				ENDIF
			ENDIF

		ELSE
			* character key..scope = 0 = ALL
			how_many = 0

		ENDIF
ENDCASE

RETURN 2


***************************************
* functions common to COPY and APPEND *
***************************************

******
*	tog_sdf()
*
*	toggle sdf mode
******
FUNCTION tog_sdf

PARAMETERS sysparam

help_code = 11

DO CASE

	CASE M->sysparam = 1 .OR. M->sysparam = 3
		* normal display
		@ M->wt + 9, M->wl + 8 SAY " SDF "

		IF M->mode = 2
			* SDF is current mode
			@ M->wt + 8, M->wl + 7, M->wt + 10, M->wl + 13 BOX sframe

		ENDIF

		IF M->sysparam = 1
			* report position
			@ M->wt + 9, M->wl + 9 SAY ""

		ENDIF

	CASE M->sysparam = 2
		* hi-lite
		syscolor(2)
		@ M->wt + 9, M->wl + 8 SAY " SDF "
		syscolor(1)

	CASE M->sysparam = 4 .AND. M->keystroke = 13
		* selected..no character keys accepted here

		IF M->mode = 2
			* SDF...toggle off
			@ M->wt + 8, M->wl + 7, M->wt + 10, M->wl + 13 BOX "        "
			mode = 1

			* change from .TXT to .DBF
			cur_el = 1
			rel_row = 0
			files = "dbf_list"
			def_ext = ".DBF"
			filelist(1)			&& display new list

		ELSE
			* toggle SDF on

			IF M->mode = 3
				* toggle DELIMITED off
				@ M->wt + 8, M->wl + 16, M->wt + 10, M->wl + 28 BOX "        "

			ELSE
				* normal mode..change from .DBF to .TXT
				cur_el = 1
				rel_row = 0
				files = "txt_list"
				def_ext = ".TXT"
				filelist(1)		&& display new list

			ENDIF

			* indicate SDF on
			@ M->wt + 8, M->wl + 7, M->wt + 10, M->wl + 13 BOX sframe
			mode = 2

		ENDIF
ENDCASE

RETURN 2


******
*	tog_delim
*
*	toggle delimited mode
******
FUNCTION tog_delim

PARAMETERS sysparam

help_code = 11

DO CASE

	CASE M->sysparam = 1 .OR. M->sysparam = 3
		* normal display
		@ M->wt + 9, M->wl + 17 SAY " DELIMITED "

		IF M->mode = 3
			* DELIMITED is current mode
			@ M->wt + 8, M->wl + 16, M->wt + 10, M->wl + 28 BOX sframe

		ENDIF

		IF M->sysparam = 1
			* report position
			@ M->wt + 9, M->wl + 17 SAY ""

		ENDIF

	CASE M->sysparam = 2
		* hi-lite
		syscolor(2)
		@ M->wt + 9, M->wl + 17 SAY " DELIMITED "
		syscolor(1)

	CASE M->sysparam = 4 .AND. M->keystroke = 13
		* selected..no character keys accepted here

		IF M->mode = 3
			* DELIMITED...toggle off
			@ M->wt + 8, M->wl + 16, M->wt + 10, M->wl + 28 BOX "        "
			mode = 1

			* change from .TXT to .DBF
			cur_el = 1
			rel_row = 0
			files = "dbf_list"
			def_ext = ".DBF"
			filelist(1)			&& display new list

		ELSE
			* toggle DELIMITED on

			IF M->mode = 2
				* toggle SDF off
				@ M->wt + 8, M->wl + 7, M->wt + 10, M->wl + 13 BOX "        "

			ELSE
				* normal mode..change from .DBF to .TXT
				cur_el = 1
				rel_row = 0
				files = "txt_list"
				def_ext = ".TXT"
				filelist(1)		&& display new list

			ENDIF

			* indicate DELIMITED on
			@ M->wt + 8, M->wl + 16, M->wt + 10, M->wl + 28 BOX sframe
			mode = 3

		ENDIF
ENDCASE

RETURN 2


* EOF DBUCOPY.PRG
************
*
*	Program....:  DBU
*	Filename...:  DBUUTIL.PRG
*	Author.....:  Dennis L. Dias
*	Date.......:  06/18/86
*	Purpose....:  Utilities Module
*
*	Copyright (c) 1986,1987 Nantucket Corp., All Rights Reserved.
*
************


******
*	setup()
*
*	put the current View into effect
*
*	note: - data files are open and closed at the time of
*			selection, but everything else is done here
*		  - the global variables need_field, need_ntx,
*			need_relat, and need_filtr prevent re-setting
*			those portions of the View already in effect
******
FUNCTION setup

PRIVATE k, t, n, i, j, field_n, s_alias, k_filter, ntx, file_name,;
		k_1, k_2, k_3, k_4, k_5, k_6, k_7

stat_msg("Setting View")

IF M->need_field
	* assemble master field list
	need_field = .F.

	* get number of fields in old list
	k = afull(M->field_list)

	n = 1
	i = 1

	DO WHILE M->n <= 6 .AND. M->i <= LEN(M->field_list)

		IF EMPTY(dbf[M->n])
			* no more active work areas
			EXIT

		ENDIF

		* access one field list
		field_n = "field_n" + SUBSTR("123456", M->n, 1)

		IF .NOT. EMPTY(&field_n[1])
			* include "alias->" if work area > 1
			s_alias = IF(M->n > 1, name(dbf[M->n]) + "->", "")
			afill(M->field_list, M->s_alias, M->i, afull(&field_n))

			j = 1

			DO WHILE M->j <= LEN(&field_n) .AND. M->i <= LEN(M->field_list)

				IF EMPTY(&field_n[M->j])
					* no more fields in list
					EXIT

				ENDIF

				* "alias->" + fieldname
				field_list[M->i] = field_list[M->i] + &field_n[M->j]

				* next
				i = M->i + 1
				j = M->j + 1

			ENDDO
		ENDIF

		* next work area
		n = M->n + 1

	ENDDO

	IF M->i <= M->k
		* clear fieldnames from longer previous list
		afill(M->field_list, "", M->i)

	ENDIF
ENDIF

IF M->need_ntx
	* set all indexes
	need_ntx = .F.

	n = 1

	DO WHILE M->n <= 6

		IF EMPTY(dbf[M->n])
			* no more active work areas
			EXIT

		ENDIF

		* access one index file list
		ntx = "ntx" + SUBSTR("123456", M->n, 1)

		IF .NOT. EMPTY(&ntx[1])
			* index(s) selected..set 7 variables to index file names
			STORE "" TO k_1,k_2,k_3,k_4,k_5,k_6,k_7

			* select the proper work area
			SELECT (M->n)

			i = 1

			DO WHILE M->i <= 7 .AND. EMPTY(M->view_err)
				* index files must exist

				IF EMPTY(&ntx[M->i])
					* no more files in list
					EXIT

				ENDIF

				* save costly macro-array access
				file_name = &ntx[M->i]

				IF FILE(M->file_name)
					* file exists..place filename in proper variable
					k = "k_" + SUBSTR("1234567", M->i, 1)
					&k = M->file_name
					i = M->i + 1

				ELSE
					view_err = "Can't open index file " + M->file_name

				ENDIF
			ENDDO

			IF EMPTY(M->view_err)
				* null strings are acceptable between the commas
				SET INDEX TO &k_1,&k_2,&k_3,&k_4,&k_5,&k_6,&k_7

			ELSE
				* return with error message
				need_ntx = .T.
				RETURN 0

			ENDIF
		ENDIF

		* next work area
		n = M->n + 1

	ENDDO
ENDIF

IF M->need_relat
	* set all relations
	need_relat = .F.

	* out with the old
	FOR j = 1 TO 5
		SELECT (M->j)
		SET RELATION TO

	NEXT

	j = 1

	DO WHILE M->j <= LEN(M->k_relate)
		* scan the entire active list

		IF EMPTY(k_relate[M->j])
			* no more relations in list
			EXIT

		ENDIF

		* select the source work area
		n = ASC(s_relate[M->j]) - ASC("A") + 1
		SELECT (M->n)

		* key and target to standard variables for macro expansion
		k = k_relate[M->j]
		t = SUBSTR(t_relate[M->j], 2)

		* this additive option is really nice
		SET RELATION ADDITIVE TO &k INTO &t

		* next
		j = M->j + 1

	ENDDO

	* align the entire chain of relations
	SELECT 1
	GO TOP

ENDIF

IF M->need_filtr
	* set all filters
	need_filtr = .F.

	n = 1

	DO WHILE M->n <= 6

		IF EMPTY(dbf[M->n])
			* no more active work areas
			EXIT

		ENDIF

		* access one global filter expression
		k_filter = "kf" + SUBSTR("123456", M->n, 1)

		IF .NOT. EMPTY(&k_filter)
			* set filter to global variable
			SELECT (M->n)

			* expressions must remain in global variables
			DO CASE

				CASE M->n = 1
					SET FILTER TO &kf1

				CASE M->n = 2
					SET FILTER TO &kf2

				CASE M->n = 3
					SET FILTER TO &kf3

				CASE M->n = 4
					SET FILTER TO &kf4

				CASE M->n = 5
					SET FILTER TO &kf5

				CASE M->n = 6
					SET FILTER TO &kf6

			ENDCASE

			* move pointer to first record that meets the condition
			GO TOP

		ENDIF

		* next work area
		n = M->n + 1

	ENDDO
ENDIF

* clear message
stat_msg("")
RETURN 0


**********************
* multibox subsystem *
**********************

******
*	multibox()
*
*	user entry/selection subsystem
*
*	sysparam values:
*		1	=	initialize, display, and report position
*		2	=	hilite (become the current item)
*		3	=	dehilite (become a non-current item)
*		4	=	become a selected item and return a new state
*
*	states:
*		0	=	abort the process
*		1	=	initialization
*		2	=	pointing (cursor)
*		3	=	entry/selection
*		4	=	complete the process
*
*	note: - boxarray[] is an array of character strings that contain
*			the names of functions with one predefined parameter like
*			this: "function(sysparam)"
*		  - each function owns a screen coordinate which it must
*			report during initialization
*		  - each higher element of boxarray[] must have its coordinate at
*			the same or higher column (relative to the previous element)
*			with no two elements having the same row/column combination
******
FUNCTION multibox

PARAMETERS wt, wl, wh, beg_c, boxarray
PRIVATE sysparam, state, cursor, funcn, winbuff, save_help, prime_help, x

* global variable eliminates recursive calls
box_open = .T.

* help codes can be set freely within multibox subsystem
save_help = M->help_code
prime_help = M->help_code

* establish parallel arrays for row and column of each object
DECLARE box_row[LEN(M->boxarray)]
DECLARE box_col[LEN(M->boxarray)]

* save the window
winbuff = SAVESCREEN(M->wt, M->wl, M->wt + M->wh + 1, M->wl + 45)

* clear and frame the window (fixed width, variable height and location)
scroll(M->wt, M->wl, M->wt + M->wh + 1, M->wl + 45, 0)
@ M->wt, M->wl, M->wt + M->wh + 1, M->wl + 45 BOX frame

* initialize, display, and report position
sysparam = 1

FOR cursor = 1 TO LEN(M->boxarray)
	* call all functions in list
	funcn = boxarray[M->cursor]	&& to normal variable for macro
	x = &funcn					&& call the function
	box_row[M->cursor] = ROW()	&& save row coordinate
	box_col[M->cursor] = COL()	&& save col coordinate

NEXT

cursor = M->beg_c				&& caller decides where to start
state = 2						&& begin with pointing state

DO WHILE M->state <> 0 .AND. M->state <> 4
	* loop until select or abort
	funcn = boxarray[M->cursor]	&& get current function from list

	DO CASE

		CASE M->state = 2
			* pointing state

			IF .NOT. key_ready()
				* hilite
				sysparam = 2
				x = &funcn

				* wait for key
				read_key()

			ENDIF

			DO CASE

				CASE M->keystroke = 13 .OR. isdata(M->keystroke)
					* change to selection state
					state = 3

				CASE M->local_func = 1
					* "help" selected from pull-down menu
					DO syshelp

				CASE q_check()
					* process aborted
					state = 0

				OTHERWISE
					* un-hilite
					sysparam = 3
					x = &funcn

					* move cursor to new object
					cursor = matrix(M->cursor, M->keystroke)

			ENDCASE

		CASE M->state = 3
			* selection state
			sysparam = 4

			* all functions return a state value of 0, 2, or 4
			state = &funcn

	ENDCASE
ENDDO

* restore the window
RESTSCREEN(M->wt, M->wl, M->wt + M->wh + 1, M->wl + 45, M->winbuff)

* reset global variables
keystroke = 0				&& not to get confused
box_open = .F.				&& box is closed
help_code = M->save_help	&& original help code

* a returned state of 0 means process aborted
RETURN M->state


******
*	matrix()
*
*	relocate cursor for multibox relative to current position
*
*	note: - the cursor value is a subscript into an array of function
*			names passed to multibox (ex. boxarray[cursor])
*		  - each function owns a screen coordinate which is saved
*			in the arrays box_row[] and box_col[]
*		  - since there is often a function that handles a list, the
*			actual screen row is used to determine vertical position
*		  - since the actual cursor could be anywhere on that row, the
*			reported column in box_col[] is used to determine horizontal
*			position
*		  - the new cursor is a "best guess" move in one of four directions
******
FUNCTION matrix

PARAMETERS old_curs, k
PRIVATE old_row, old_col, test_curs, new_curs

* get current position
old_row = ROW()					&& actual screen row is better for lists
old_col = box_col[M->old_curs]	&& col array..actual cursor could be anywhere

* new value same as old if no movement possible
new_curs = M->old_curs

* beginning value for test probe
test_curs = M->old_curs

DO CASE

	CASE M->k = 19 .OR. M->k = 219
		* left arrow

		DO WHILE M->test_curs > 2
			* test all lower elements except 1 which is always the title
			test_curs = M->test_curs - 1

			IF box_col[M->test_curs] < M->old_col .AND.;
			   box_row[M->test_curs] >= M->old_row
				* never move up while moving left

				IF box_row[M->test_curs] < box_row[M->new_curs];
				   .OR. M->new_curs = M->old_curs
					* but no further down than we have to
					new_curs = M->test_curs

				ENDIF
			ENDIF
		ENDDO

	CASE M->k = 4
		* right arrow

		DO WHILE M->test_curs < LEN(M->box_col)
			* test all higher elements
			test_curs = M->test_curs + 1

			IF box_col[M->test_curs] > M->old_col .AND.;
			   box_row[M->test_curs] <= M->old_row
				* never move down while moving right

				IF box_row[M->test_curs] > box_row[M->new_curs];
				   .OR. M->new_curs = M->old_curs
					* but no further up than we have to
					new_curs = M->test_curs

				ENDIF
			ENDIF
		ENDDO

	CASE M->k = 5
		* up arrow

		DO WHILE M->test_curs > 2
			* test all lower elements except 1 which is always the title
			test_curs = M->test_curs - 1

			IF box_row[M->test_curs] < M->old_row .AND.;
			   box_col[M->test_curs] <= M->old_col
				* never move right while moving up

				IF box_col[M->test_curs] > box_col[M->new_curs];
				   .OR. M->new_curs = M->old_curs
					* but no further left than we have to
					new_curs = M->test_curs

				ENDIF
			ENDIF
		ENDDO

	CASE M->k = 24
		* down arrow

		DO WHILE M->test_curs < LEN(M->box_row)
			* test all higher elements
			test_curs = M->test_curs + 1

			IF box_row[M->test_curs] > M->old_row .AND.;
			   box_col[M->test_curs] >= M->old_col
				* never move left while moving down

				IF box_col[M->test_curs] < box_col[M->new_curs];
				   .OR. M->new_curs = M->old_curs
					* but no further right than we have to
					new_curs = M->test_curs

				ENDIF
			ENDIF
		ENDDO
ENDCASE

RETURN M->new_curs


******
*	to_ok()
*
*	go directly to ok button
*
*	note: this routine depends upon things known and unknown
******
FUNCTION to_ok

* set the cursor to the element before the ok button
cursor = ascan(M->boxarray, "ok_button(sysparam)") - 1

* put a down arrow into the keyboard buffer
KEYBOARD CHR(24)

RETURN 0


******
*	to_can()
*
*	go directly to cancel button
*
*	note: this routine depends  p n th ngs kn wn  nd  nkn wn
******
FUNCTION to_can

* set the cursor to the cancel button
cursor = ascan(M->boxarray, "can_button(sysparam)")

* put a down arrow into the keyboard buffer
KEYBOARD CHR(24)

RETURN 0


******
*	ok_button
*
*	that's a wrap
*
*	note: - the caller of multibox must define the variable
*			"okee_dokee" which contains a character string
*			with the name of a function that takes no
*			parameters (ex. "function()")
*		  - that function will either do whatever it is that
*			multibox was called to do and return logical true,
*			or return logical false meaning incomplete
******
FUNCTION ok_button

PARAMETERS sysparam
PRIVATE ok, reply

* some boxes have secondary help
help_code = M->prime_help

* initialize private variables
ok = " Ok "		&& some button eh?
reply = 2		&& assume incomplete

DO CASE

	CASE M->sysparam = 1 .OR. M->sysparam = 3
		* initialize or un-hilite
		@ M->wt + M->wh, M->wl + 8 SAY M->ok

		IF M->sysparam = 1
			* report position
			@ M->wt + M->wh, M->wl + 9 SAY ""

		ENDIF

	CASE M->sysparam = 2
		* hilite
		syscolor(2)
		@ M->wt + M->wh, M->wl + 8 SAY M->ok
		syscolor(1)

	CASE M->sysparam = 4 .AND. M->keystroke = 13
		* selected, but only if enter key

		IF &okee_dokee
			* process completed
			reply = 4

		ENDIF
ENDCASE

RETURN M->reply


******
*	can_button()
*
*	note: pressing Escape has the same effect
*		  as selecting the cancel button
******
FUNCTION can_button

PARAMETERS sysparam
PRIVATE can, reply

* some boxes have secondary help
help_code = M->prime_help

* initialize private variables
can = " Cancel "	&& a button
reply = 2			&& assume incomplete

DO CASE

	CASE M->sysparam = 1 .OR. M->sysparam = 3
		* initialize or un-hilite
		@ M->wt + M->wh, M->wl + 17 SAY M->can

		IF M->sysparam = 1
			* report position
			@ M->wt + M->wh, M->wl + 17 SAY ""

		ENDIF

	CASE M->sysparam = 2
		* hilite
		syscolor(2)
		@ M->wt + M->wh, M->wl + 17 SAY M->can
		syscolor(1)

	CASE M->sysparam = 4 .AND. M->keystroke = 13
		* selected with the enter key..abort the process
		reply = 0

ENDCASE

RETURN M->reply


******
*	filelist()
*
*	select file from list
******
FUNCTION filelist

PARAMETERS sysparam

RETURN itemlist(M->sysparam, 32, "filename", M->files, "*" + M->def_ext, .T.)


******
*	fieldlist()
*
*	select field from list
******
FUNCTION fieldlist

PARAMETERS sysparam

RETURN itemlist(M->sysparam, 34, "field_mvar", "field_m", "Fields", .F.)


******
*	itemlist()
*
*	select item from list
*
*	note: - this list handler only responds to sysparam
*			values of 1 (initialize) and 2 (hilite)
*		  - since both multibox() and achoice() wait for keystrokes,
*			it is necessary to mediate for a smooth user interface
*		  - when sysparam = 2, achoice() is given control after
*			which the select/abort status is resolved before
*			returning control to multibox()
******
FUNCTION itemlist

PARAMETERS sysparam, l_rel, mvar, items, i_title, go_ok
PRIVATE n, x, i_full

* some boxes have secondary help
help_code = M->prime_help

* get size of list
i_full = afull(&items)

DO CASE

	CASE M->sysparam = 1
		* clear and frame the list portion of the box
		scroll(M->wt + 1, M->wl + M->l_rel - 1, M->wt + M->wh, M->wl + 44, 0)
		@ M->wt, M->wl + M->l_rel - 2, M->wt + M->wh + 1, M->wl + 45;
		BOX M->lframe

		* format the list title
		i_title = REPLICATE("ฤ", ((46 - M->l_rel - LEN(M->i_title)) / 2) - 1);
				  + " " + M->i_title + " "
		i_title = M->i_title + REPLICATE("ฤ", (46 - M->l_rel - LEN(M->i_title)))

		* display the list title
		@ M->wt + 1, M->wl + M->l_rel - 1 SAY M->i_title

		IF .NOT. EMPTY(&items[1])
			* display only..do not wait for keystrokes
			syscolor(4)
			achoice(M->wt + 2, M->wl + M->l_rel, M->wt + M->wh, M->wl + 43,;
					&items, .F., "i_func", M->cur_el, M->rel_row)
			syscolor(1)

		ENDIF

		* report position
		@ M->wt + 2, M->wl + M->l_rel SAY ""

	CASE M->sysparam = 2
		* hilite

		IF EMPTY(&items[1])
			* no list..go left
			KEYBOARD(CHR(219))

		ELSE
			* standard list selection..get starting element and row
			cur_el = M->cur_el - M->rel_row + ROW() - M->wt - 2
			rel_row = ROW() - M->wt - 2

			* get selected element or zero if abort
			n = achoice(M->wt + 2, M->wl + M->l_rel, M->wt + M->wh,;
						M->wl + 43, &items, .T., "i_func", M->cur_el,;
						M->rel_row)

			* check for menu request
			sysmenu()

			DO CASE

				CASE M->keystroke = 13
					* item selected..place in variable
					&mvar = &items[M->n]

					* call the specified function to display the selection
					x = &fi_disp

					IF M->go_ok
						* go directly to the ok button for convenience
						to_ok()

					ELSE
						* just move over and down
						KEYBOARD CHR(219) + CHR(24)

					ENDIF

				CASE M->keystroke = 19
					* left arrow..move off list by forwarding to multibox
					* cannot directly keyboard chr(19) because it would be
					*    handled like ^S and halt the system
					KEYBOARD CHR(219)

				CASE M->keystroke = 0
					* menu system has returned either select or abort

					IF M->local_func = 1
						* "help" selected from pull-down menu
						DO syshelp

					ENDIF

					* forward a "do nothing" keystroke to re-enter achoice
					KEYBOARD CHR(11)

				OTHERWISE
					* let multibox() decide
					KEYBOARD CHR(M->keystroke)

			ENDCASE
		ENDIF
ENDCASE

RETURN 2


******
*	i_func()
*
*	achoice user function for item list in multibox
******
FUNCTION i_func

PARAMETERS amod, sel, rel
PRIVATE r, srow, scol

* multibox looks at screen coordinates..must save
srow = ROW()
scol = COL()

IF M->error_on
	* erase error message
	error_off()

ENDIF

IF M->amod = 4
	* nothing selectable
	r = 0

ELSE
	* maintain row and element variables
	cur_el = M->sel
	rel_row = M->rel

	* assume continue
	r = 2

	* get latest keystroke
	keystroke = LASTKEY()

ENDIF

IF M->cur_el > M->rel_row + 1
	* first element not on screen
	@ M->wt + 2, M->wl + 44 SAY M->more_up

ELSE
	* first element is on screen
	@ M->wt + 2, M->wl + 44 SAY " "

ENDIF

IF M->i_full - M->cur_el > M->wh - 2 - M->rel_row
	* last element not on screen
	@ M->wt + M->wh, M->wl + 44 SAY M->more_down

ELSE
	* last element is on screen
	@ M->wt + M->wh, M->wl + 44 SAY " "

ENDIF

IF M->amod = 3
	* keystroke exception

	DO CASE

		CASE M->keystroke = 27
			* escape..abort
			r = 0

		CASE M->keystroke = 13 .OR. M->keystroke = 19 .OR. M->keystroke = 219
			* quit achoice no abort..only the enter key will cause selection
			r = 1

		CASE M->keystroke = 1
			* home key..top of list
			KEYBOARD CHR(31)	&& ^PgUp

		CASE M->keystroke = 6
			* end key..end of list
			KEYBOARD CHR(30)	&& ^PgDn

		CASE isdata(M->keystroke)
			* request character search
			r = 3

		CASE menu_key() <> 0
			* abort to menu system
			r = 0

	ENDCASE
ENDIF

* restore screen coordinate
@ M->srow, M->scol SAY ""

RETURN M->r


******
*	getfile()
*
*	accept direct entry of filename in entry field
*
*	note: - the caller of multibox must establish the variables
*			"filename", "def_ext", and "fi_done"
*		  - fi_done contains the name of a function that will
*			decide if a filename is ready to be confirmed
******
FUNCTION getfile

PARAMETERS sysparam, row_off
PRIVATE irow, name_temp

* some boxes have secondary help
help_code = M->prime_help

* calculate absolute row
irow = M->wt + M->row_off

DO CASE

	CASE M->sysparam = 1 .OR. M->sysparam = 3
		* display
		@ M->irow, M->wl + 2 SAY "File   " + pad(M->filename, 20)

		IF M->sysparam = 1
			* report position
			@ M->irow, M->wl + 9 SAY ""

		ENDIF

	CASE M->sysparam = 2
		* hilite
		syscolor(2)
		@ M->irow, M->wl + 9 SAY pad(M->filename, 20)
		syscolor(1)

	CASE M->sysparam = 4
		* selected..accept input

		IF M->keystroke <> 13
			* forward data keystroke to GET system
			KEYBOARD CHR(M->keystroke)

		ENDIF

		* down arrow will exit READ
		SET KEY 24 TO clear_gets

		* call entry in place function
		name_temp = enter_rc(M->filename, M->irow, M->wl + 9, 64, "@K!S20")

		* release down arrow
		SET KEY 24 TO

		IF .NOT. EMPTY(M->name_temp)
			* something entered

			IF .NOT. (RAT(".", M->name_temp) > RAT("\", M->name_temp))
				* extnesion not entered..provide default
				name_temp = M->name_temp + M->def_ext

			ENDIF

			* place in variable
			filename = M->name_temp

		ELSE

			IF M->keystroke = 13 .OR. M->keystroke = 24
				* accept blank entry
				M->filename = ""

			ENDIF
		ENDIF

		IF M->keystroke = 13
			* entry is deliberate

			IF &fi_done
				* entry is acceptable
				@ M->irow, M->wl + 9 SAY pad(M->filename, 20)

			ENDIF

		ELSE

			IF M->keystroke <> 27 .AND. .NOT. isdata(M->keystroke)
				* something else..forward the keystroke to multibox
				KEYBOARD CHR(M->keystroke)

			ENDIF
		ENDIF
ENDCASE

RETURN 2


******
*	g_getfile()
*
*	get filename for filebox function
******
FUNCTION g_getfile

PARAMETERS sysparam

RETURN getfile(M->sysparam, 4)


******
*	genfield()
*
*	process fieldname entry blank (called indirectly from multibox)
******
FUNCTION genfield

PARAMETERS sysparam, is_replace

DO CASE

	CASE M->sysparam = 1 .OR. M->sysparam = 3
		* display
		@ M->wt + 3, M->wl + 2 SAY "Field  " + pad(M->field_mvar, 20)

		IF M->sysparam = 1
			* report position
			@ M->wt + 3, M->wl + 9 SAY ""

		ENDIF

	CASE M->sysparam = 2 .OR. M->sysparam = 4
		* no user entry allowed..deflect the cursor

		IF M->lkey = 5
			* upward movement..bounce right to list
			KEYBOARD CHR(4)

		ELSE
			* moving left from list..bounce down

			IF M->is_replace
				* replace option..move down to expression
				KEYBOARD CHR(24)

			ELSE
				* getfield via set_view

				IF EMPTY(M->field_mvar)
					* nothing to select..go to Cancel
					to_can()

				ELSE
					* go to Ok for confirmation
					to_ok()

				ENDIF
			ENDIF
		ENDIF
ENDCASE

RETURN 2


******
*	get_exp()
*
*	accept input of a general dBASE expression
*
*	note: - the caller of multibox must establish the variable
*			whose name is in the "mvar" parameter
*		  - this function is used for copy, append, replace, and create index
******
FUNCTION get_exp

PARAMETERS sysparam, xlable, row_off, mvar
PRIVATE erow, k_input

* calculate absolute row
erow = M->wt + M->row_off

DO CASE

	CASE M->sysparam = 1 .OR. M->sysparam = 3
		* display
		@ M->erow, M->wl + 2 SAY M->xlable + pad(&mvar, 20)

		IF M->sysparam = 1
			* report position
			@ M->erow, M->wl + 9 SAY ""

		ENDIF

	CASE M->sysparam = 2
		* hilite
		syscolor(2)
		@ M->erow, M->wl + 9 SAY pad(&mvar, 20)
		syscolor(1)

	CASE M->sysparam = 4
		* selected..accept input

		IF M->keystroke <> 13
			* forward data keystroke to GET system
			KEYBOARD CHR(M->keystroke)

		ENDIF

		* up and down arrows will exit READ
		SET KEY 5 TO clear_gets
		SET KEY 24 TO clear_gets

		* call entry in place function
		k_input = enter_rc(&mvar, M->erow, M->wl + 9, 127, "@KS20")

		* release up and down arrows
		SET KEY 5 TO
		SET KEY 24 TO

		IF .NOT. EMPTY(M->k_input)
			* something entered..place in variable
			&mvar = M->k_input

			IF M->keystroke <> 5 .AND. .NOT. isdata(M->keystroke)
				* move down to next entry field
				keystroke = 24

			ENDIF

		ELSE

			IF M->keystroke = 13 .OR. M->keystroke = 5 .OR. M->keystroke = 24
				* accept blank entry
				&mvar = ""

			ENDIF
		ENDIF

		IF M->keystroke <> 13 .AND. M->keystroke <> 27 .AND.;
		   .NOT. isdata(M->keystroke)
			* something else..forward the keystroke to multibox
			KEYBOARD CHR(M->keystroke)

		ENDIF
ENDCASE

RETURN 2


******
*	not_empty()
*
*	general item entry preliminary test
******
FUNCTION not_empty

PARAMETERS mvar
PRIVATE done_ok

* accept anything but a blank entry
done_ok = .NOT. EMPTY(&mvar)

IF M->done_ok
	* ready for confirmation
	to_ok()

ENDIF

RETURN M->done_ok


******
*	filebox()
*
*	general file selection using multibox
******
FUNCTION filebox

PARAMETERS def_ext, files, titl_func, do_func, creat_flag, box_top
PRIVATE rel_row, cur_el, fi_disp, okee_dokee, fi_done, bcur

* establish array for multibox
DECLARE boxarray[5]

boxarray[1] = M->titl_func + "(sysparam)"
boxarray[2] = "g_getfile(sysparam)"
boxarray[3] = "ok_button(sysparam)"
boxarray[4] = "can_button(sysparam)"
boxarray[5] = "filelist(sysparam)"

* initialize private variables
cur_el = 1
rel_row = 0
fi_disp = "g_getfile(3)"
fi_done = "not_empty('filename')"
okee_dokee = M->do_func + "()"

IF M->creat_flag
	* assume new filename to be entered

	IF EMPTY(filename)
		* beginning cursor on entry field
		bcur = 2

	ELSE
		* begin on ok button for fast confirmation
		bcur = 3

	ENDIF

ELSE
	* assume list selection preferred
	bcur = 5

ENDIF

* return same value as multibox
RETURN multibox(M->box_top, 17, 7, M->bcur, M->boxarray)


******
*	box_title()
*
*	display the specified title for a selection box
******
FUNCTION box_title

PARAMETERS sysparam, boxtitle

IF M->sysparam = 1
	@ M->wt + 1, M->wl + 2 SAY M->boxtitle
	@ M->wt + 1, M->wl + 2 SAY ""

ENDIF

RETURN 2


******
*	get_k_trim()
*
*	accept character input to the pre-defined variable k_trim
*
*	note: this function is used for the "move" menu options
*		  as well as entry of filter expressions
******
FUNCTION get_k_trim

PARAMETERS sysparam, k_label
PRIVATE k_input

DO CASE

	CASE M->sysparam = 1 .OR. M->sysparam = 3
		* display
		@ M->wt + 3, M->wl + 2 SAY pad(M->k_label, 12) + pad(M->k_trim, 30)

		IF M->sysparam = 1
			* report position
			@ M->wt + 3, M->wl + 9 SAY ""

		ENDIF

	CASE M->sysparam = 2
		* hilite
		syscolor(2)
		@ M->wt + 3, M->wl + 14 SAY pad(M->k_trim, 30)
		syscolor(1)

	CASE M->sysparam = 4
		* selected..accept input

		IF M->keystroke <> 13
			* forward data keystroke to GET system
			KEYBOARD CHR(M->keystroke)

		ENDIF

		* down arrow will exit READ
		SET KEY 24 TO clear_gets

		* call entry in place function
		k_input = enter_rc(M->k_trim, M->wt + 3, M->wl + 14, 127, "@KS30")

		* release down arrow
		SET KEY 24 TO

		IF .NOT. EMPTY(M->k_input)
			* something entered..place in variable
			k_trim = M->k_input

			* move to ok button
			keystroke = 24

		ELSE

			IF M->keystroke = 13 .OR. M->keystroke = 24
				* accept blank entry
				k_trim = ""

				* move to ok button
				keystroke = 24

			ENDIF
		ENDIF

		IF M->keystroke <> 13 .AND. M->keystroke <> 27 .AND.;
		   .NOT. isdata(M->keystroke)
			* something else..forward the keystroke to multibox
			KEYBOARD CHR(M->keystroke)

		ENDIF
ENDCASE

RETURN 2


*************************
* pull-down menu system *
*************************

******
*	sysmenu()
*
*	administrate pull-down menu system
*
*	return: logical true if menu selection or keystroke available
*
*	note: - the menu titles are the same as the function key labels that
*			appear at the top of the screen
*		  - these titles are stored in a global array called func_title[]
*		  - for each title there is a corresponding pair of arrays whose
*			names are &a._m[] and &a._b[] where a = func_title[curr menu]
*		  - the _m arrays contain the menu options and the _b arrays
*			determine the selectability of those options according to
*			the rules of the achoice() function
******
FUNCTION sysmenu

PRIVATE menu_func,menu_sel,menu_buf,a,ml,mr,mb,prev_func,sav_row,sav_col,x

IF M->keystroke = 0
	* nothing happening
	RETURN .F.

ENDIF

* which menu?
menu_func = menu_key()

* always re-set this global selection variable
local_func = 0

IF M->menu_func = 0
	* no menu..regular keystroke
	RETURN .T.

ENDIF

************************
* entering menu system *
************************

* save screen coordinate
sav_row = ROW()
sav_col = COL()

IF M->error_on
	* erase error message
	error_off()

ENDIF

* establish buffer to save windows
**. menu_buf = SPACE(300)

* initialize variables for selection process
menu_sel = 0
prev_func = 0
x = M->menu_func

DO WHILE M->menu_func > 0 .AND. M->menu_sel = 0
	* abort or select

	* avoid re-draw if menu already displayed
	IF M->menu_func <> M->prev_func
		* pull it on down
		lite_fkey(M->menu_func)				&& hilite title
		prev_func = M->menu_func			&& remember for next loop
		a = func_title[M->menu_func]		&& get name of current menu
		ml = (10 * (M->menu_func - 1)) + 1	&& calculate left coordinate
		mr = ((10 * M->menu_func) - 2)		&& calculate right coordinate
		mb = (2 + LEN(&a._m))				&& calculate bottom coordinate

		* save the window
		menu_buf = SAVESCREEN(2, M->ml - 1, M->mb + 1, M->mr + 1)

		* draw frame for current menu
		@ 2, M->ml - 1, M->mb + 1, M->mr + 1 BOX M->mframe

	ENDIF

	* set color to bright for selectables, inverse for
	*   light bar, dull (normal) for unselectables
	syscolor(5)

	* call achoice() for selection
	menu_sel = achoice(3, M->ml, M->mb, M->mr, &a._m, &a._b, "mu_func",;
					   menu_deflt[M->menu_func], menu_deflt[M->menu_func] - 1)
	syscolor(1)

	* see mu_func() below for setting of keystroke and x
	DO CASE

		CASE M->keystroke = 27
			* abort
			menu_func = 0

		CASE M->keystroke = 4
			* right arrow..next menu with wrap around
			menu_func = IF(M->menu_func < 8, M->menu_func + 1, 1)

		CASE M->keystroke = 19
			* left arrow..previous menu with wrap around
			menu_func = IF(M->menu_func > 1, M->menu_func - 1, 8)

		CASE M->x <> 0
			* directly to a different menu
			menu_func = M->x

	ENDCASE

	IF M->menu_func <> M->prev_func .OR. M->menu_sel <> 0
		* new menu or no menu..restore the screen
		dim_fkey(M->prev_func)
		RESTSCREEN(2, M->ml - 1, M->mb + 1, M->mr + 1, M->menu_buf)

	ENDIF
ENDDO

IF M->menu_func <> 0
	* most recently selected is the new default
	menu_deflt[M->menu_func] = M->menu_sel

ENDIF

IF LTRIM(STR(M->menu_func)) $ M->exit_str
	* selection requires a top level branch
	sysfunc = M->menu_func
	func_sel = M->menu_sel

ELSE
	* selection to be handled locally
	local_func = M->menu_func
	local_sel = M->menu_sel

ENDIF

* restore screen coordinate
@ M->sav_row,M->sav_col SAY ""

* not to be confused
keystroke = 0

* return logical true if selection made
RETURN menu_func <> 0


******
*	menu_key()
*
*	translate keystroke into menu number, zero if none
******
FUNCTION menu_key

PRIVATE num

* assume no menu request
num = 0

DO CASE

	CASE M->keystroke = 28
		* F1
		num = 1

	CASE M->keystroke < 0 .AND. M->keystroke > -8
		* F2 - F8 (ex. 1 - (-1) = 2)
		num = 1 - M->keystroke

	CASE M->keystroke >= 249 .AND. M->keystroke < 256
		* F2 - F8..function keys get truncated by the chr() function
		*	(ex. chr(-1) = chr(255)..257 - 255 = 2)
		num = 257 - M->keystroke

ENDCASE

RETURN M->num


******
*	mu_func()
*
*	achoice user function for pull-down menu system
******
FUNCTION mu_func

PARAMETERS amod, sel, rel
PRIVATE r

IF M->amod = 4
	* none selectable..wait for keystroke
	keystroke = INKEY(0)

	* abort selection process
	r = 0

ELSE
	* get latest keystroke
	keystroke = LASTKEY()

	* assume continue selection process
	r = 2

ENDIF

* in case menu key pressed
x = menu_key()

IF M->amod = 3
	* keystroke exception

	DO CASE

		CASE M->keystroke = 13 .OR. M->x = menu_func
			* enter key or same function key..select
			r = 1

		CASE M->keystroke = 27 .OR. M->keystroke = 19 .OR.;
			 M->keystroke = 4 .OR. M->x <> 0
			* different menu or no menu..abort from current menu
			r = 0

		CASE M->keystroke = 1
			* home key..top of list (^PgUp)
			KEYBOARD CHR(31)

		CASE M->keystroke = 6
			* end key..end of list (^PgDn)
			KEYBOARD CHR(30)

		CASE isdata(M->keystroke)
			* request character search
			r = 3

	ENDCASE
ENDIF

RETURN M->r


******
*	show_keys()
*
*	display the available function menus
******
FUNCTION show_keys

PRIVATE n

* clear the row
@ 1, 0

FOR n = 1 TO 8
	* display the function key titles
	@ 1,1 + (10 * (M->n - 1)) SAY func_title[M->n]

NEXT

RETURN 0


******
*	xkey_clear()
*
*	cause all menu keys to clear gets and exit a read
******
FUNCTION xkey_clear

PRIVATE i

* F1
SET KEY 28 TO clear_gets

FOR i = 1 TO 7
	* F2 - F8
	SET KEY -(M->i) TO clear_gets

NEXT

RETURN 0


******
*	xkey_norm()
*
*	cause all menu keys to return to normal after xkey_clear
******
FUNCTION xkey_norm

PRIVATE i

* F1
SET KEY 28 TO

FOR i = 1 TO 7
	* F2 - F8
	SET KEY -(M->i) TO

NEXT

RETURN 0


******
*	lite_fkey()
*
*	hilite the specified function key label in reverse
******
FUNCTION lite_fkey

PARAMETERS k_num

syscolor(2)
@ 1, 1 + (10 * (M->k_num - 1)) SAY func_title[M->k_num]
syscolor(1)

RETURN 0


******
*	dim_fkey()
*
*	un-hilite the specified function key label
******
FUNCTION dim_fkey

PARAMETERS k_num

syscolor(1)
@ 1, 1 + (10 * (M->k_num - 1)) SAY func_title[M->k_num]

RETURN 0


******
*	key_ready()
*
*	return true if key ready or menu select
******
FUNCTION key_ready

* save the previous keystroke
lkey = M->keystroke

* get new keystroke if ready
keystroke = INKEY()

RETURN (sysmenu() .OR. M->keystroke <> 0)


******
*	read_key()
*
*	wait for keystroke or menu select
******
FUNCTION read_key

DO WHILE .NOT. key_ready()
	* wait for keystroke or menu select

ENDDO

IF M->error_on
	* erase error message
	error_off()

ENDIF

RETURN M->keystroke


******
*	raw_key()
*
*	wait for and return next key without checking for menu selection
******
FUNCTION raw_key

PRIVATE k

* wait for key
k = INKEY(0)

IF M->error_on
	* erase error message
	error_off()

ENDIF

RETURN k


******
*	q_check()
*
*	return true to cause exit from a routine
*
*	note: cur_func is set equal to sysfunc at the
*		  top of the main loop of the program
******
FUNCTION q_check

RETURN (M->cur_func <> M->sysfunc .OR. M->keystroke = 27)


******
*	clear_gets
*
*	set keystrokes to this procedure to exit a READ
******
PROCEDURE clear_gets
PARAMETERS dummy1,dummy2,dummy3

CLEAR GETS
RETURN


******
*	all_fields()
*
*	fill field array with all fields for individual work area
******
FUNCTION all_fields

PARAMETERS work_area,field_a

stat_msg("Reading file structure")

* will need to assemble master field list
need_field = .T.

* select the specified work area
SELECT (M->work_area)

* fill the array with field names..fill leftover elements with null strings
afill(M->field_a, "", afields(M->field_a) + 1)

* clear the status message and return
stat_msg("")
RETURN 0


******
*	not_target()
*
*	remove relations where specified work area is target
******
FUNCTION not_target

PARAMETERS n, do_del
PRIVATE i

i = 1

DO WHILE M->i <= LEN(M->k_relate)
	* search the entire list of relations

	IF EMPTY(k_relate[M->i])
		* end of list
		EXIT

	ENDIF

	IF t_relate[M->i] == CHR(M->n + ASC("A") - 1) + name(dbf[M->n])
		* alias is target of relation
		need_relat = .T.

		* select the source work area for this relation
		SELECT (M->n)

		* turn off the relation
		SET RELATION TO

		IF M->do_del
			* relation will not be re-set..remove from list
			array_del(M->s_relate,M->i)
			array_del(M->k_relate,M->i)
			array_del(M->t_relate,M->i)

		ELSE
			* next element
			i = M->i + 1

		ENDIF

	ELSE
		* alias is not target of relation..next element
		i = M->i + 1

	ENDIF
ENDDO

RETURN 0


******
*	dup_ntx()
*
*	return work area where index is in use, zero if not found
******
FUNCTION dup_ntx

PARAMETERS ntx_file
PRIVATE ntx, i

i = 1

DO WHILE M->i <= 6

	IF EMPTY(dbf[M->i])
		* no more active work areas
		EXIT

	ENDIF

	* access one index file list
	ntx = "ntx" + SUBSTR("123456", M->i, 1)

	IF aseek(&ntx, M->ntx_file) > 0
		* index file in use
		RETURN M->i

	ENDIF

	* next work area
	i = M->i + 1

ENDDO

RETURN 0


******
*	stat_msg()
*
*	display status message
******
FUNCTION stat_msg

PARAMETERS string

* overwrite the entire row
@ 3,0 SAY pad(M->string,80)

RETURN 0


******
*	error_msg()
*
*	display error message and set global variable
*	  to erase message with next keystroke
******
FUNCTION error_msg

PARAMETERS string

* high intensity for error message
syscolor(3)
@ 3,0 SAY M->string

* clear rest of message row
syscolor(1)
@ ROW(), COL()

* next key stroke will erase message
error_on = .T.

RETURN 0


******
*	error_off()
*
*	erase error message
******
FUNCTION error_off

* set global variable false
error_on = .F.

* clear the message row
@ 3,0

RETURN 0


******
*	rsvp()
*
*	get and return a Yes or No response (or Esc)
******
FUNCTION rsvp

PARAMETERS string
PRIVATE c

* initialize local variable
c = " "

* Yes/No/Esc
DO WHILE .NOT. (M->c $ "YN" + CHR(27))
	* display message bright like error message
	error_msg(M->string + "  ")

	* place the cursor at the end of the message
	@ 3,LEN(M->string) + 1 SAY ""

	* make the cursor visible
	SET CURSOR ON

	* get the response and erase the message
	c = UPPER(CHR(raw_key()))

	IF .NOT. M->curs_on
		* get rid of the cursor
		SET CURSOR OFF

	ENDIF
ENDDO

RETURN M->c


******
*	name()
*
*	extract filename from d:\path\filename.ext
******
FUNCTION name

PARAMETERS spec
PRIVATE p

* isolate filename and extension from path
p = SUBSTR(M->spec, RAT("\", M->spec) + 1)

IF "." $ M->p
	* there is an extension..chop it off
	p = SUBSTR(M->p, 1, AT(".", M->p) - 1)

ENDIF

RETURN M->p


******
*	pad()
*
*	force a string to a specified length
*
*	note: - if the string is longer than the specified
*			length it will be truncated
*		  - if the string is shorter than the specified length
*			it will be padded with spaces on the right
******
FUNCTION pad

PARAMETERS s, n

RETURN SUBSTR(M->s + SPACE(M->n), 1, M->n)


******
*	aseek()
*
*	search for matching array element..return zero if not found
*
*	note: only non-empty elements are searched
******
FUNCTION aseek

PARAMETERS array, exp
PRIVATE pos, num_el

* get number of non-empty elements
num_el = afull(M->array)

IF M->num_el = 0
	* not found if all empty
	RETURN 0

ENDIF

* perform exact search
SET EXACT ON

* ascan will return 0 if not found
pos = ascan(M->array, M->exp, 1, M->num_el)

* back to normal
SET EXACT OFF

RETURN M->pos


******
*	array_ins()
*
*	shift elements up and set array[pos] = ""
*
*	note: the only difference between this function and the ains()
*		  function is that here we set the inserted element to type C
******
FUNCTION array_ins

PARAMETERS array, pos

* insert a new element
ains(M->array, M->pos)

* assign null string to new element
array[M->pos] = ""

RETURN 0


******
*	array_del()
*
*	shift elements down and set array[len(array)] = ""
*
*	note: the only difference between this function and the adel()
*		  function is that here we set the last element to type C
******
FUNCTION array_del

PARAMETERS array, pos

* delete the specified element
adel(M->array, M->pos)

* assign null string to last element
array[LEN(M->array)] = ""

RETURN 0


******
*	afull()
*
*	find the number of contiguous full elements before the first null string
******
FUNCTION afull

PARAMETERS array
PRIVATE i

* perform exact search
SET EXACT ON

* search for null string
i = ascan(M->array, "")

* back to normal
SET EXACT OFF

IF M->i = 0
	* no null strings means completely full
	i = LEN(M->array)

ELSE
	* element of first null string - 1
	i = M->i - 1

ENDIF

RETURN M->i


******
*	array_sort()
*
*	sort the contiguous full elements before the first null string
******
FUNCTION array_sort

PARAMETERS array

* sort only the full elements
asort(M->array, 1, afull(M->array))

RETURN 0


******
*	array_dir()
*
*	prepare a sorted array of filenames that match a skeleton
******
FUNCTION array_dir

PARAMETERS skeleton, array

* begin with an empty array
afill(M->array, "")

* fill the array with filenames
adir(M->skeleton, M->array)

* sort the array
array_sort(M->array)

RETURN 0


******
*	ntx_key(filename)
*
*	read the key from an index file
*
*	note: this function assumes a valid index file
******
FUNCTION ntx_key

PARAMETERS filename
PRIVATE k, buffer, handle, k_pos

* initialize variable to hold key expression
k = ""

IF FILE(M->filename)
	* only if the file exists

	IF INDEXEXT() = ".NTX"
		* Clipper index file format
		k_pos = 23

	ELSE
		* .NDX..dBASE index file format
		k_pos = 25

	ENDIF

	* open the file and get handle
	handle = FOPEN(M->filename)

	IF FERROR() = 0
		* allocate 512 byte buffer
		buffer = SPACE(512)

		* read the index file header into memory
		FREAD(M->handle, @buffer, 512)

		* discard all bytes before the key expression
		k = SUBSTR(M->buffer, M->k_pos)

		* the expression is terminated with a zero byte (chr(0))
		k = TRIM(SUBSTR(M->k, 1, AT(CHR(0), M->k) - 1))

	ENDIF

	* close the file and release the handle
	FCLOSE(M->handle)

ENDIF

RETURN M->k


******
*	isdata()
*
*	determine if a key is data suitable for entry in place
******
FUNCTION isdata

PARAMETERS k

RETURN (M->k >= 32 .AND. M->k < 249 .AND. M->k <> 219 .AND. CHR(M->k) <> ";")


******
*	lpad()
*
*	pad with spaces on the left
*
*	note: this routine will fail if the requested len() is
*		  less than len(string)
******
FUNCTION lpad

PARAMETERS string,n

RETURN (SPACE(M->n - LEN(M->string)) + M->string)


******
*	hi_cur()
*
*	hilite the current data file in reverse video
******
FUNCTION hi_cur

IF M->cur_area > 0
	syscolor(2)

	* write on the main View screen
	@ row_a[1], column[M->cur_area] + 2 SAY pad(name(M->cur_dbf), 8)

	syscolor(1)

ENDIF

RETURN 0


******
*	dehi_cur()
*
*	display the current data file to un-hilite
******
FUNCTION dehi_cur

IF M->cur_area > 0
	* write on the main View screen
	@ row_a[1], column[M->cur_area] + 2 SAY pad(name(M->cur_dbf), 8)

ENDIF

RETURN 0


******
*	syscolor()
*
*	set the specified color
******
FUNCTION syscolor

PARAMETERS num

* cases yield better performance than double macro expansion
DO CASE

	CASE M->num = 1
		SET COLOR TO &color1

	CASE M->num = 2
		SET COLOR TO &color2

	CASE M->num = 3
		SET COLOR TO &color3

	CASE M->num = 4
		SET COLOR TO &color4

	CASE M->num = 5
		SET COLOR TO &color5

ENDCASE

RETURN 0


******
*	enter_rc()
*
*	entry in place
******
FUNCTION enter_rc

PARAMETERS org_str, r, c, max_len, pfunc
PRIVATE wk_str

* set menu keys to exit READ
xkey_clear()

* set initial work string from original string
wk_str = pad(M->org_str, M->max_len)
SET CURSOR ON

IF .NOT. EMPTY(M->pfunc)
	* perform GET with picture clause
	@ r, c GET M->wk_str PICTURE M->pfunc

ELSE
	* no picture clause
	@ r, c GET M->wk_str

ENDIF

* accept data input
READ
SET CURSOR OFF

* set global variable to exit key
keystroke = LASTKEY()

* release menu keys
xkey_norm()

IF M->error_on
	* erase error message
	error_off()

ENDIF

IF M->keystroke = 27 .OR. menu_key() <> 0
	* aborted entry..return null string
	wk_str = ""

ENDIF

RETURN TRIM(M->wk_str)


* EOF DBUUTIL.PRG
************
*
*	Program....:  DBU
*	Filename...:  DBUHELP.PRG
*	Author.....:  Dennis L. Dias
*	Date.......:  06/18/86
*	Purpose....:  Help Module
*
*	Copyright (c) 1986,1987 Nantucket Corp., All Rights Reserved.
*
************


******
*	syshelp
*
*	Display help screens contained in the file DBU.HLP.
*	The help file can be in one of these places:
*
*		<current directory>
*		\CLIPPER\
*
*	The global variable "helpfile" contains the
*	path\filename, or a null string if not found.
******
PROCEDURE syshelp

PRIVATE hrow, hcol, hwbuf, htext

IF EMPTY(M->helpfile)
	error_msg("Can't find DBU.HLP")

ELSE
	* save current row and column
	hrow = ROW()
	hcol = COL()

	* save screen in memvar
	hwbuf = SAVESCREEN(7, 7, 23, 72)

	* clear window and draw box
	scroll(7, 7, 23, 72, 0)
	@ 8,10,22,69 BOX M->frame

	* display help title
	syscolor(2)
	@ 8,(76 - LEN(help_title[M->help_code])) / 2;
	SAY "  " + help_title[M->help_code] + "  "
	syscolor(1)

	* get the help text
	htext = helptext(M->helpfile, M->help_code)

	* scroll state makes eliminates the need for a cursor
	SET CURSOR OFF

	* use editor in browse only mode
	MEMOEDIT(M->htext, 9, 11, 21, 68, .F.)

	* restore window
	RESTSCREEN(7, 7, 23, 72, M->hwbuf)

	* restore cursor
	@ M->hrow,M->hcol SAY ""
	IF M->curs_on
		SET CURSOR ON

	ENDIF
ENDIF

* reset global variable
local_func = 0
RETURN


******
*	helptext()
*
*	extract help text from a helpfile in the following format:
*
*	o	At the beginning of the help file is a table which contains
*		the offset and length of each block of help text in the file.
*
*	o	A table entry is 4 bytes long and consists of two 16 bit unsigned
*		numbers in binary format.  The first number is the offset within
*		the file where the corresponding help text begins; the second
*		number is the length of the text in bytes.
*
*	o	Table entries and related help text are arranged in numeric order
*		according to the global variable "help_code" which is used to
*		access the correct block of text.
*
*	o	Binary numbers at the beginning of the file are assumed to be
*		in standard Intel format where the Least Significant Byte (LSB)
*		is stored first and the Most Significant Byte (MSB) is second.
******
FUNCTION helptext

PARAMETERS hfile, hnum
PRIVATE htbuf, hoff, hlen, hhandle

* open the file and get handle
hhandle = FOPEN(M->hfile)

IF FERROR() = 0
	* allocate 512 byte buffer
	htbuf = SPACE(512)

	* read the file header into memory
	FREAD(M->hhandle, @htbuf, 512)

	* isolate the correct 4 byte table entry
	htbuf = SUBSTR(M->htbuf, (4 * (M->hnum - 1)) + 1, 4)

	* convert binary numbers (LSB, MSB) to Clipper numerics
	hoff = ASC(M->htbuf) + (256 * ASC(SUBSTR(M->htbuf, 2)))
	hlen = ASC(SUBSTR(M->htbuf, 3)) + (256 * ASC(SUBSTR(M->htbuf, 4)))

	* allocate buffer
	htbuf = SPACE(M->hlen)

	* position file to the correct offset
	FSEEK(M->hhandle, M->hoff)

	* read text into buffer
	FREAD(M->hhandle, @htbuf, M->hlen)

ELSE
	* return null string if error
	htbuf = ""

ENDIF

* close the file and release the handle
FCLOSE(M->hhandle)
RETURN M->htbuf


* EOF DBUHELP.PRG
