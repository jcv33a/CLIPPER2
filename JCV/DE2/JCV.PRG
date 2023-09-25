***********
* JCV.PRG *
***********

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
@1,0 SAY "(c) JCV-SOFTWARE 2002"
@2,0 SAY "ALL RIGHTS RESERVED."
@4,0 SAY "Jos‚ Cruz V zquez"
@5,0 SAY "c/ Fdco. Garc¡a Lorca, 21"
@6,0 SAY "41840 Pilas (Sevilla)"
@7,0 SAY "Tfn.: 954 750 792, 657 360 180, 610 04 05 28"
?
wait

CLEAR

DO CLAVE

CLEAR

DO MENU

SET COLOR TO

CLEAR

QUIT

*** MENU.PRG

PROCEDURE MENU

OPCION0=1

DO WHILE OPCION0 <> 0

        CLEAR

        @0,0 SAY    "MENU GENERAL"
        @1,0 SAY    "------------------"
        @2,0 PROMPT "(1).......CLIENTES"
        @3,0 PROMPT "(2).....REINDEXADO"

        MENU TO OPCION0

                DO CASE
                        CASE OPCION0=1
                                DO CLIENTES
                        CASE OPCION0=2
                                DO INDCLIENTES
                ENDCASE

ENDDO

RETURN

*** CLIENTES.PRG

PROCEDURE CLIENTES

USE MOROSOS

OPCION1=1

DO WHILE OPCION1 <> 0

        SET INDEX TO REF
        CLEAR

        @0,0 SAY    "MENU CLIENTES"
        @1,0 SAY    "------------------------------------"
        @2,0 PROMPT "(1).........................CLIENTES"
        @3,0 PROMPT "(2)..............INTRODUCIR CLIENTES"
        @4,0 PROMPT "(3).......LISTADO DE CLIENTES (PRN.)"

        MENU TO OPCION1

        DO CASE

                CASE OPCION1=1
                        DO MODIFY
                CASE OPCION1=2
                        DO INTROCLIENTES
                CASE OPCION1=3
                        DO LISACT

        ENDCASE

ENDDO

USE

RETURN
