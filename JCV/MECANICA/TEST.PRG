************
* TEST.PRG *
************

SET SAFETY OFF
SET TALK OFF
SET BELL OFF
SET WRAP ON
SET DATE ITALIAN
SET DECIMALS TO 2
SET KEY 28 TO
SET COLOR TO W/B

CLEAR

@0,0 SAY "GESTION JCV"
@1,0 SAY "(c) JCV-SOFTWARE 2005"
@2,0 SAY "ALL RIGHTS RESERVED."
@4,0 SAY "JosÇ Cruz V†zquez"
@5,0 SAY "c/ Granada, 9B"
@6,0 SAY "41840 Pilas (Sevilla)"
@7,0 SAY "Tfn.: 657360180"
@9,0 SAY "≠≠≠ATENCI‡N: EL PROGRAMA DISTINGUE MAYÈSCULAS DE MINÈSCULAS!!!"
?
wait

CLEAR

USE TEST

INDEX ON NUMERO TO NUMERO

OPCION1=1

DO WHILE OPCION1 <> 0

        CLEAR

        @0,0 SAY    "MENU TEST"
        @1,0 SAY    "---------------------------"
        @2,0 SAY    "___________________________"
        @3,0 PROMPT "(1)....................TEST"
        @4,0 SAY    "___________________________"
        @5,0 PROMPT "(2)..............HACER TEST"
        @6,0 PROMPT "(3)............REPASAR TEST"
        @7,0 SAY    "___________________________"
        @8,0 PROMPT "(4).........INTRODUCIR TEST"
        @9,0 PROMPT "(5)..........MODIFICAR TEST"
        @10,0 SAY   "___________________________"

        MENU TO OPCION1

        DO CASE

                CASE OPCION1=1
                        DO MODIFY
                CASE OPCION1=2
                        DO HACERTEST
                CASE OPCION1=3
                        DO REPASARTEST
                CASE OPCION1=4
                        DO INTROTEST
                CASE OPCION1=5
                        DO MODIFYTEST

        ENDCASE

ENDDO

SET COLOR TO

CLEAR

USE

QUIT
