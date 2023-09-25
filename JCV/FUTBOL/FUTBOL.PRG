**************
* FUTBOL.PRG *
**************

SET SAFETY OFF
SET TALK OFF
SET WRAP ON
SET BELL ON
SET COLOR TO W/B
SET DATE ITALIAN

CLEAR

@0,0 SAY "FUTBOL JCV"
@1,0 SAY "(c) JCV-SOFTWARE, 1996-2002"
@2,0 SAY "ALL RIGHTS RESERVED."
@4,0 SAY "Jos‚ Cruz V zquez"
@5,0 SAY "c/ Fdco. Garc¡a Lorca, 21"
@6,0 SAY "41840 Pilas (Sevilla)"
@7,0 SAY "Tfn.: 657360180"
@8,0

WAIT
CLEAR

DO MENUFUTBOL

SET SAFETY ON
SET TALK ON
SET WRAP OFF
SET BELL OFF
SET COLOR TO

CLEAR
QUIT

**************
* MENUFUTBOL *
**************

PROCEDURE MENUFUTBOL

OPCION0=1

DO WHILE OPCION0 <> 0

        CLEAR

        @ 5,9 TO 7,22
        @6,10 SAY    "MENU GENERAL"
        @9,9 TO 17,36 DOUBLE
        @10,10 PROMPT "(1)................EQUIPOS"
        @12,10 PROMPT "(2)..............JUGADORES"
        @14,10 PROMPT "(3)........EMPAREJAMIENTOS"
        @16,10 PROMPT "(4)...........REINDEXACION"

        MENU TO OPCION0

                DO CASE
                        CASE OPCION0=1
                                DO MENUEQUIPOS
                        CASE OPCION0=2
                                DO MENUJUGADORES
                        CASE OPCION0=3
                                DO MENUEMPAREJAMIENTOS
                        CASE OPCION0=4
                                DO REINDEXACION
                ENDCASE

ENDDO

RETURN

***************
* MENUEQUIPOS *
***************

PROCEDURE MENUEQUIPOS

OPCION1=1

DO WHILE OPCION1 <> 0

        CLEAR

        @ 5,9 TO 7,25
        @6,10 SAY     "MENU DE EQUIPOS"
        @ 9,9 TO 19,47 DOUBLE
        @10,10 PROMPT "(1)................VISUALIZAR EQUIPOS"
        @12,10 PROMPT "(2).................MODIFICAR EQUIPOS"
        @14,10 PROMPT "(3)...........INTRODUCIR NUEVO EQUIPO"
        @16,10 PROMPT "(4)...................ELIMINAR EQUIPO"
        @18,10 PROMPT "(5)............CLASIFICACIONES (PRN.)"

        MENU TO OPCION1

        DO CASE

                CASE OPCION1=1
                        DO VISUALIZAR
                CASE OPCION1=2
                        DO MODIFICAR
                CASE OPCION1=3
                        DO INTRODUCIR
                CASE OPCION1=4
                        DO ELIMINAR
                CASE OPCION1=5
                        DO CLASIFICACIONES

        ENDCASE

ENDDO

RETURN

*****************
* MENUJUGADORES *
*****************

PROCEDURE MENUJUGADORES

OPCION2=1

DO WHILE OPCION2 <> 0

        CLEAR

        @ 5,9 TO 7,27
        @6,10 SAY     "MENU DE JUGADORES"
        @ 9,9 TO 19,41 DOUBLE
        @10,10 PROMPT "(1)....VISUALIZAR FICHAS (PRN.)"
        @12,10 PROMPT "(2)............MODIFICAR FICHAS"
        @14,10 PROMPT "(3)...........INTRODUCIR FICHAS"
        @16,10 PROMPT "(4).............ELIMINAR FICHAS"
        @18,10 PROMPT "(5)............SANCIONES (PRN.)"

        MENU TO OPCION2

        DO CASE

                CASE OPCION2=1
                        DO VFICHAS
                CASE OPCION2=2
                        DO MFICHAS
                CASE OPCION2=3
                        DO IFICHAS
                CASE OPCION2=4
                        DO EFICHAS
                CASE OPCION2=5
                        DO SANCIONES
        ENDCASE

ENDDO

RETURN

*******************
* EMPAREJAMIENTOS *
*******************

PROCEDURE MENUEMPAREJAMIENTOS

OPCION3=1

DO WHILE OPCION3 <> 0

        CLEAR

        @ 5,9 TO 7,25
        @6,10 SAY     "EMPAREJAMIENTOS"
        @ 9,9 TO 15,41 DOUBLE
        @10,10 PROMPT "(1).........VISUALIZAR JORNADAS"
        @12,10 PROMPT "(4)....ELIMINAR EMPAREJAMIENTOS"
        @14,10 PROMPT "(5)....IMPRIMIR JORNADAS (PRN.)"

        MENU TO OPCION3

        DO CASE

                CASE OPCION3=1
                        DO VJORNADA
                CASE OPCION3=2
                        DO EEQUIPO
                CASE OPCION3=3
                        DO IMPRIMIRJORNADAS
        ENDCASE

ENDDO

RETURN

****************
* REINDEXACION *
****************

PROCEDURE REINDEXACION

CLEAR

CONTINUAR=SPACE(1)
@0,0 SAY "¨QUIERE CONTINUAR? (N/S):" GET CONTINUAR
READ

IF CONTINUAR$"Ss"

        CLEAR
        @2,3 SAY "REGENERANDO INDICES..."

        USE EQUIPOS
        INDEX ON EQUIPO TO EQUIPO

        USE JUGADORE
        INDEX ON NOMBRE TO NOMBRE
        INDEX ON EQUIPO+NOMBRE TO EQUINOM
        INDEX ON SANCIONES TO SANCION

        USE JORNADAS
        INDEX ON JORNADA TO JORNADA
        INDEX ON EQUIPO1 TO EQUIPO1
        INDEX ON EQUIPO2 TO EQUIPO2

        USE

ENDIF

RETURN
