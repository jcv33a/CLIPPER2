****************
* PFFUTBOL.PRG *
****************

**************
* VISUALIZAR *
**************

PROCEDURE VISUALIZAR

USE EQUIPOSI INDEX EQUIPO

CLEAR
BROWSE()
CLEAR

SET CURSOR OFF
SET CURSOR ON

USE
RETURN

*************
* MODIFICAR *
*************

PROCEDURE MODIFICAR

USE EQUIPOSI INDEX EQUIPO

STORE "S" TO SIG
DO WHILE SIG$"Ss"

        CLEAR
        @0,0 SAY "MODIFICAR EQUIPOS"
        EQ=SPACE(15)
        @2,0 SAY "EQUIPO" GET EQ
        READ
        STORE UPPER(EQ) TO EQQ

        FIND &EQQ

        IF EOF()
                CLEAR
                ?"SE HA ALCANZADO EL FINAL DEL FICHERO"
                ?
                WAIT
                USE
                RETURN
        ENDIF

        JOR=0
        FALT=0
        FAVOR=0
        CONTRA=0

        @3,0 SAY "JORNADA" GET JOR
        @4,0 SAY "FALTAS" GET FALT
        @5,0 SAY "GOLES A FAVOR" GET FAVOR
        @6,0 SAY "GOLES EN CONTRA" GET CONTRA

        READ

        CLEAR

        ?"DATOS DEL ULTIMO PARTIDO JUGADO"
        ?"-------------------------------"
        ?
        REPORT FORM E1 FOR EQUIPO=EQQ NOEJECT PLAIN
        ?

        FIND &EQQ

        REPLACE PJ WITH JOR
        REPLACE FALTAS WITH FALTAS+FALT

        IF FALT > 0

                REPLACE PUNTOS WITH PUNTOS-FALT

        ENDIF

        IF FAVOR > CONTRA

                REPLACE PG WITH PG+1
                REPLACE GF WITH GF+FAVOR
                REPLACE GC WITH GC+CONTRA
                REPLACE DIFERENCIA WITH GF-GC
                REPLACE PUNTOS WITH PUNTOS+3

        ENDIF

        IF FAVOR < CONTRA

                REPLACE PP WITH PP+1
                REPLACE GF WITH GF+FAVOR
                REPLACE GC WITH GC+CONTRA
                REPLACE DIFERENCIA WITH GF-GC

        ENDIF

        IF FAVOR = CONTRA

                REPLACE PE WITH PE+1
                REPLACE GF WITH GF+FAVOR
                REPLACE GC WITH GC+CONTRA
                REPLACE DIFERENCIA WITH GF-GC
                REPLACE PUNTOS WITH PUNTOS+1

        ENDIF


        ?"DATOS ACTUALIZADOS"
        ?"------------------"
        ?
        REPORT FORM E1 FOR EQUIPO=EQQ NOEJECT PLAIN
        ?

        WAIT

        CLEAR
        @0,0 SAY "¨QUIERE MODIFICAR OTRO EQUIPO? (S/N):" GET SIG
        READ

ENDDO

USE
RETURN

**************
* INTRODUCIR *
**************

PROCEDURE INTRODUCIR

CLEAR

CONTINUAR=SPACE(1)
@0,0 SAY "¨QUIERE CONTINUAR? (N/S):" GET CONTINUAR
READ

IF CONTINUAR$"Ss"

        USE EQUIPOSI INDEX EQUIPO

        STORE "S" TO SIG
        DO WHILE SIG$"Ss"

                APPEND BLANK

                CLEAR
                @0,0 SAY "ENTRADA AL FICHERO DE EQUIPOS"
                @2,0 SAY "CATEGORIA" GET CATEGORIA
                @3,0 SAY "EQUIPO" GET EQUIPO
                READ

                CLEAR
                STORE "N" TO SIG
                @0,0 SAY "¨QUIERE INTRODUCIR OTRO EQUIPO? (N/S): " GET SIG
                READ

        ENDDO

        USE

ENDIF

RETURN

************
* ELIMINAR *
************

PROCEDURE ELIMINAR

USE EQUIPOSI INDEX EQUIPO

STORE "S" TO SIG
DO WHILE SIG$"Ss"

        CLEAR

        @0,0 SAY "ELIMINAR EQUIPO DE LA CLASIFICACION"
        EQ=SPACE(15)
        @2,0 SAY "NOBRE DEL EQUIPO A ELIMINAR" GET EQ
        READ
        STORE UPPER(EQ) TO EQQ

        FIND &EQQ

        IF EOF()
                CLEAR
                ?"SE HA ALCANZADO EL FINAL DEL FICHERO"
                ?
                WAIT
                USE
                RETURN
        ENDIF

        DELETE ALL FOR EQUIPO=EQQ

        PACK

        ?
        ?"EQUIPO ELIMINADO"
        ?
        WAIT

        CLEAR
        STORE "N" TO SIG
        @0,0 SAY "¨QUIERE ELIMINAR OTRO EQUIPO? (N/S):" GET SIG
        READ

ENDDO

USE
RETURN

*******************
* CLASIFICACIONES *
*******************

PROCEDURE CLASIFICACIONES

USE EQUIPORI
ZAP

USE EQUIPOSI

SORT ON CATEGORIA,PUNTOS /D,DIFERENCIA /D TO EQUIPORI

USE EQUIPORI

M=0
N=0

COUNT ALL FOR CATEGORIA="ALEVIN" TO A
COUNT ALL FOR CATEGORIA="BENJAMIN" TO B
COUNT ALL FOR CATEGORIA="CADETE" TO C
COUNT ALL FOR CATEGORIA="INFANTIL" TO I

STORE "S" TO SIG
DO WHILE SIG$"Ss"

        IF A=0
                STORE "N" TO SIG
        ENDIF

        M=M+1
        N=N+1
        GO TOP
        SKIP M-1
        REPLACE POSICION WITH N

        IF N=A
                N=0
                STORE "N" TO SIG
        ENDIF

ENDDO

STORE "S" TO SIG
DO WHILE SIG$"Ss"

        IF B=0
                STORE "N" TO SIG
        ENDIF

        M=M+1
        N=N+1
        GO TOP
        SKIP M-1
        REPLACE POSICION WITH N

        IF N=B
                N=0
                STORE "N" TO SIG
        ENDIF

ENDDO

STORE "S" TO SIG
DO WHILE SIG$"Ss"

        IF C=0
                STORE "N" TO SIG
        ENDIF

        M=M+1
        N=N+1
        GO TOP
        SKIP M-1
        REPLACE POSICION WITH N

        IF N=C
                N=0
                STORE "N" TO SIG
        ENDIF

ENDDO

STORE "S" TO SIG
DO WHILE SIG$"Ss"

        IF I=0
                STORE "N" TO SIG
        ENDIF

        M=M+1
        N=N+1
        GO TOP
        SKIP M-1
        REPLACE POSICION WITH N

        IF N=I
                N=0
                STORE "N" TO SIG
        ENDIF

ENDDO

CLEAR

?"                        LIGA LOCAL DE FUTBITO. A¥O"
??YEAR(DATE())
?"                        -------------------------------"
?
?"                                     Benjam¡n"
?"                              Clasificaci¢n General"
?
REPORT FORM E1 FOR CATEGORIA="BENJAMIN" NOEJECT PLAIN
?
?"  Organiza: Delegaci¢n de Deportes del Excmo. Ayuntamiento de Pilas (Sevilla)."
?"            (c) JCV.SOFT, 1996-2002, Pilas (Sevilla), Tfn.: 657360180"

?
WAIT

CLEAR

?"                        LIGA LOCAL DE FUTBITO. A¥O"
??YEAR(DATE())
?"                        -------------------------------"
?
?"                                      Alev¡n"
?"                              Clasificaci¢n General"
?
REPORT FORM E1 FOR CATEGORIA="ALEVIN" NOEJECT PLAIN
?
?"  Organiza: Delegaci¢n de Deportes del Excmo. Ayuntamiento de Pilas (Sevilla)."
?"            (c) JCV.SOFT, 1996-2002, Pilas (Sevilla), Tfn.: 657360180"

?
WAIT

CLEAR

?"                        LIGA LOCAL DE FUTBITO. A¥O"
??YEAR(DATE())
?"                        -------------------------------"
?
?"                                     Infantil"
?"                              Clasificaci¢n General"
?
REPORT FORM E1 FOR CATEGORIA="INFANTIL" NOEJECT PLAIN
?
?"  Organiza: Delegaci¢n de Deportes del Excmo. Ayuntamiento de Pilas (Sevilla)."
?"            (c) JCV.SOFT, 1996-2002, Pilas (Sevilla), Tfn.: 657360180"

?
WAIT

CLEAR

?"                        LIGA LOCAL DE FUTBITO. A¥O"
??YEAR(DATE())
?"                        -------------------------------"
?
?"                                      Cadete"
?"                              Clasificaci¢n General"
?
REPORT FORM E1 FOR CATEGORIA="CADETE" NOEJECT PLAIN
?
?"  Organiza: Delegaci¢n de Deportes del Excmo. Ayuntamiento de Pilas (Sevilla)."
?"            (c) JCV.SOFT, 1996-2002, Pilas (Sevilla), Tfn.: 657360180"

?
WAIT

CLEAR

IMPRIMIR=SPACE(1)
@0,0 SAY "¨IMPRIMIR CLASIFICACIONES? (N/S):" GET IMPRIMIR
READ

IF IMPRIMIR$"Ss"

        SET DEVICE TO PRINT
        SET PRINT ON

        CLEAR

        ?"                        LIGA LOCAL DE FUTBITO. A¥O"
        ??YEAR(DATE())
        ?"                        -------------------------------"
        ?
        ?"                                     Benjam¡n"
        ?"                              Clasificaci¢n General"
        ?
        REPORT FORM E1 FOR CATEGORIA="BENJAMIN" NOEJECT PLAIN
        ?
        ?"                                      Alev¡n"
        ?"                              Clasificaci¢n General"
        ?
        REPORT FORM E1 FOR CATEGORIA="ALEVIN" NOEJECT PLAIN
        ?
        ?"  Organiza: Delegaci¢n de Deportes del Excmo. Ayuntamiento de Pilas (Sevilla)."
        ?"            (c) JCV.SOFT, 1996-2002, Pilas (Sevilla), Tfn.: 657360180"

        EJECT

        SET DEVICE TO SCREEN
        SET PRINT OFF
        ?
        WAIT
        SET DEVICE TO PRINT
        SET PRINT ON

        CLEAR

        ?"                        LIGA LOCAL DE FUTBITO. A¥O"
        ??YEAR(DATE())
        ?"                        -------------------------------"
        ?
        ?"                                     Infantil"
        ?"                              Clasificaci¢n General"
        ?
        REPORT FORM E1 FOR CATEGORIA="INFANTIL" NOEJECT PLAIN
        ?
        ?"                                      Cadete"
        ?"                              Clasificaci¢n General"
        ?
        REPORT FORM E1 FOR CATEGORIA="CADETE" NOEJECT PLAIN
        ?
        ?"  Organiza: Delegaci¢n de Deportes del Excmo. Ayuntamiento de Pilas (Sevilla)."
        ?"            (c) JCV.SOFT, 1996-2002, Pilas (Sevilla), Tfn.: 657360180"

        EJECT

        SET DEVICE TO SCREEN
        SET PRINT OFF
        ?
        WAIT

ENDIF

SORT ON CATEGORIA,PUNTOS /D,DIFERENCIA /D TO EQUIPOSI

USE
RETURN

***********
* VFICHAS *
***********

PROCEDURE VFICHAS

CLEAR
OPCION=SPACE(1)
@0,0 SAY "¨JUGADORES ORDENADOS POR NOMBRE? (N/S):" GET OPCION
READ

IF OPCION$"Ss"

        USE JUGADORI INDEX NOMBRE,EQUINOM,CATEGORI,GOLES

ELSE

        USE JUGADORI INDEX EQUINOM,NOMBRE,CATEGORI,GOLES

ENDIF

CLEAR
BROWSE()
CLEAR

SET CURSOR OFF
SET CURSOR ON

IMPRIMIR=SPACE(1)
@0,0 SAY "¨IMPRIMIR JUGADORES? (N/S):" GET IMPRIMIR
READ

IF IMPRIMIR$"Ss"

        USE JUGADORI INDEX EQUINOM,NOMBRE,CATEGORI,GOLES

        STORE "S" TO SIG
        DO WHILE SIG$"Ss"

                CLEAR

                EQ=SPACE(15)
                @0,0 SAY "EQUIPO A IMPRIMIR" GET EQ
                READ
                STORE UPPER(EQ) TO EQQ

                CLEAR
                REPORT FORM J2 FOR EQUIPO=EQQ NOEJECT
                ?
                WAIT

                CLEAR

                IMPRIMIR=SPACE(1)
                @0,0 SAY "¨QUIERE IMPRIMIR LA LISTA? (N/S):" GET IMPRIMIR
                READ

                IF IMPRIMIR$"Ss"

                        CLEAR

                        SET DEVICE TO PRINT
                        SET PRINT ON

                        REPORT FORM J2 FOR EQUIPO=EQQ NOEJECT
                        EJECT

                        SET DEVICE TO SCREEN
                        SET PRINT OFF

                        ?
                        WAIT

                ENDIF

                CLEAR
                STORE "N" TO SIG
                @0,0 SAY "¨QUIERE IMPRIMIR LOS JUGADORES DE OTRO EQUIPO? (N/S):" GET SIG
                READ

        ENDDO

ENDIF

CLEAR

USE
RETURN

***********
* MFICHAS *
***********

PROCEDURE MFICHAS

USE JUGADORI INDEX NOMBRE,EQUINOM,CATEGORI,GOLES

STORE "S" TO SIG
DO WHILE SIG$"Ss"

        CLEAR

        @0,0 SAY "MODIFICAR FICHAS"
        APEL=SPACE(35)
        @2,0 SAY "APELLIDOS Y NOMBRE" GET APEL
        READ
        STORE UPPER(APEL) TO APELL

        FIND &APELL

        IF EOF()
                CLEAR
                ?"SE HA ALCANZADO EL FINAL DEL FICHERO"
                ?
                WAIT
                USE
                RETURN
        ENDIF

        CLEAR

        @0,0 SAY "ENTRADA AL FICHERO DE JUGADORES"
        @2,0 SAY "APELLIDOS Y NOMBRE" GET NOMBRE
        @3,0 SAY "EDAD" GET EDAD
        @4,0 SAY "DNI" GET DNI
        @5,0 SAY "DIRECCION" GET DIRECCION
        @6,0 SAY "LOCALIDAD" GET LOCALIDAD
        @7,0 SAY "PROVINCIA" GET PROVINCIA
        @8,0 SAY "TELEFONO" GET TELEFONO
        @9,0 SAY "EQUIPO" GET EQUIPO
        @10,0 SAY "CATEGORIA" GET CATEGORIA
        @11,0 SAY "CARGO" GET CARGO
        @12,0 SAY "GOLES: "+STR(GOLES)

        GO=0

        @14,0 SAY "DATOS DEL ULTIMO PARTIDO JUGADO"
        @16,0 SAY "GOLES" GET GO

        READ

        REPLACE GOLES WITH GOLES+GO

        CLEAR
        STORE "N" TO SIG
        @0,0 SAY "¨QUIERE MODIFICAR OTRO JUGADOR? (N/S):" GET SIG
        READ

ENDDO

USE
RETURN

***********
* IFICHAS *
***********

PROCEDURE IFICHAS

CLEAR

CONTINUAR=SPACE(1)
@0,0 SAY "¨QUIERE CONTINUAR? (N/S):" GET CONTINUAR
READ

IF CONTINUAR$"Ss"

        USE JUGADORI INDEX EQUINOM,NOMBRE,CATEGORI,GOLES

        STORE "S" TO SIG
        DO WHILE SIG$"Ss"

                APPEND BLANK

                CLEAR

                @0,0 SAY "ENTRADA AL FICHERO DE JUGADORES"
                @2,0 SAY "APELLIDOS Y NOMBRE" GET NOMBRE
                @3,0 SAY "EDAD" GET EDAD
                @4,0 SAY "DNI" GET DNI
                @5,0 SAY "DIRECCION" GET DIRECCION
                @6,0 SAY "LOCALIDAD" GET LOCALIDAD
                @7,0 SAY "PROVINCIA" GET PROVINCIA
                @8,0 SAY "TELEFONO" GET TELEFONO
                @9,0 SAY "EQUIPO" GET EQUIPO
                @10,0 SAY "CATEGORIA" GET CATEGORIA
                @11,0 SAY "CARGO" GET CARGO
                @12,0 SAY "GOLES" GET GOLES

                READ

                CLEAR
                STORE "N" TO SIG
                @0,0 SAY "¨QUIERE INTRODUCIR OTRO JUGADOR? (N/S):" GET SIG
                READ

        ENDDO

        USE

ENDIF

RETURN

***********
* EFICHAS *
***********

PROCEDURE EFICHAS

USE JUGADORI INDEX NOMBRE,EQUINOM,CATEGORI,GOLES

STORE "S" TO SIG
DO WHILE SIG$"Ss"

        CLEAR

        @0,0 SAY "ELIMINAR JUGADOR"
        APEL=SPACE(35)
        @2,0 SAY "APELLIDOS Y NOMBRE" GET APEL
        READ
        STORE UPPER(APEL) TO APELL

        FIND &APELL

        IF EOF()
                CLEAR
                ?"SE HA ALCANZADO EL FINAL DEL FICHERO"
                ?
                WAIT
                USE
                RETURN
        ENDIF

        DELETE ALL FOR NOMBRE=APELL

        PACK

        ?
        ?"JUGADOR ELIMINADO"
        ?
        WAIT

        CLEAR
        STORE "N" TO SIG
        @0,0 SAY "¨QUIERE ELIMINAR OTRO JUGADOR? (N/S):" GET SIG
        READ

ENDDO

USE
RETURN

*********
* GOLES *
*********

PROCEDURE GOLES

USE JUGADORI INDEX GOLES

CLEAR

?"                                  GOLEADORES"
?"                                  ----------"
?
?"                               Fecha: "
??DATE()
?
REPORT FORM J1 FOR GOLES >= 1 .AND. CATEGORIA="BENJAMIN" NOEJECT PLAIN
REPORT FORM J1 FOR GOLES >= 1 .AND. CATEGORIA="ALEVIN" NOEJECT PLAIN
REPORT FORM J1 FOR GOLES >= 1 .AND. CATEGORIA="INFANTIL" NOEJECT PLAIN
REPORT FORM J1 FOR GOLES >= 1 .AND. CATEGORIA="CADETE" NOEJECT PLAIN
?
?"  Organiza: Delegaci¢n de Deportes del Excmo. Ayuntamiento de Pilas (Sevilla)."
?"            (c) JCV.SOFT, 1996-2002, Pilas (Sevilla), Tfn.: 657360180"

?
WAIT

CLEAR

IMPRIMIR=SPACE(1)
@0,0 SAY "¨IMPRIMIR SANCIONES? (N/S):" GET IMPRIMIR
READ

IF IMPRIMIR$"Ss"

        SET DEVICE TO PRINT
        SET PRINT ON

        CLEAR

        ?"                                  GOLEADORES"
        ?"                                  ----------"
        ?
        ?"                               Fecha: "
        ??DATE()
        ?
        REPORT FORM J1 FOR GOLES >= 1 .AND. CATEGORIA="BENJAMIN" NOEJECT PLAIN
        REPORT FORM J1 FOR GOLES >= 1 .AND. CATEGORIA="ALEVIN" NOEJECT PLAIN
        REPORT FORM J1 FOR GOLES >= 1 .AND. CATEGORIA="INFANTIL" NOEJECT PLAIN
        REPORT FORM J1 FOR GOLES >= 1 .AND. CATEGORIA="CADETE" NOEJECT PLAIN
        ?
        ?"  Organiza: Delegaci¢n de Deportes del Excmo. Ayuntamiento de Pilas (Sevilla)."
        ?"            (c) JCV.SOFT, 1996-2002, Pilas (Sevilla), Tfn.: 657360180"

        EJECT

        SET DEVICE TO SCREEN
        SET PRINT OFF

        ?
        WAIT

ENDIF

USE
RETURN

************
* VJORNADA *
************

PROCEDURE VJORNADA

USE JORNADAI

CLEAR
BROWSE()
CLEAR

SET CURSOR OFF
SET CURSOR ON

USE
RETURN

***********
* EEQUIPO *
***********

PROCEDURE EEQUIPO

USE JORNADAI
INDEX ON EQUIPO1 TO EQUIPO1
INDEX ON EQUIPO2 TO EQUIPO2

USE JORNADAI INDEX EQUIPO1,EQUIPO2

STORE "S" TO SIG
DO WHILE SIG$"Ss"

        CLEAR

        @0,0 SAY "ELIMINAR EQUIPO DEL CALENDARIO"
        EQ=SPACE(15)
        @2,0 SAY "EQUIPO" GET EQ
        READ

        IF EQ=SPACE(15)

                CLEAR
                ?"SE HA ALCANZADO EL FINAL DEL FICHERO"
                ?
                WAIT
                USE
                RETURN

        ENDIF

        STORE UPPER(EQ) TO EQQ

        FIND &EQQ

        IF EOF()

                USE JORNADAI INDEX EQUIPO2,EQUIPO1

                FIND &EQQ

                IF EOF()
                        CLEAR
                        ?"SE HA ALCANZADO EL FINAL DEL FICHERO"
                        ?
                        WAIT
                        USE
                        RETURN
                ENDIF

        ENDIF

        DELETE ALL FOR EQUIPO1=EQQ .OR. EQUIPO2=EQQ

        PACK

        ?
        ?"EQUIPO ELIMINADO"
        ?
        WAIT

        CLEAR
        STORE "N" TO SIG
        @0,0 SAY "¨QUIERE ELIMINAR OTRO EQUIPO? (N/S):" GET SIG
        READ

ENDDO

USE
RETURN

********************
* IMPRIMIRJORNADAS *
********************

PROCEDURE IMPRIMIRJORNADAS

USE JORNADAI
INDEX ON JORNADA TO JORNADA

CLEAR

@0,0 SAY "IMPRIMIR JORNADAS"

J=SPACE(2)
@2,0 SAY "JORNADA" GET J
READ

MODO=SPACE(1)
@3,0 SAY "¨JORNADA INTERMEDIA/COMPRIMIDA(C) O ULTIMA/EXPANDIDA(E)?" GET MODO
READ

IF MODO$"Ee"

        AR=SPACE(1)
        @4,0 SAY "¨IMPRIMIR ARBITROS? (S/N):" GET AR
        READ

ENDIF

CLEAR

FIND &J

IF MODO$"Cc"

        ?"                              LIGA LOCAL DE FUTBITO"
        ?"                              ---------------------"
        ?
        ?"                  Resultados de la Jornada: "
        ??JORNADA
        ??" Fecha: "
        ??FECHA
        ?
        REPORT FORM JOIC FOR JORNADA=J NOEJECT PLAIN

ENDIF

IF MODO$"Ee"

        ?"                              LIGA LOCAL DE FUTBITO"
        ?"                              ---------------------"
        ?
        ?"                       Pr¢xima Jornada: "
        ??JORNADA
        ??" Fecha: "
        ??FECHA
        ?
        IF AR$"Ss"

                REPORT FORM JOFE FOR JORNADA=J NOEJECT PLAIN
        ELSE

                REPORT FORM JOFE2 FOR JORNADA=J NOEJECT PLAIN

        ENDIF

ENDIF

?
?"  Organiza: Delegaci¢n de Deportes del Excmo. Ayuntamiento de Pilas (Sevilla)."
?"            (c) JCV.SOFT, 1996-2002, Pilas (Sevilla), Tfn.: 657360180"

?
WAIT

CLEAR

IMPRIMIR=SPACE(1)
@0,0 SAY "¨IMPRIMIR JORNADA? (N/S):" GET IMPRIMIR
READ

IF IMPRIMIR$"Ss"

        SET DEVICE TO PRINT
        SET PRINT ON

        CLEAR

        FIND &J

        IF MODO$"Cc"

                ?"                              LIGA LOCAL DE FUTBITO"
                ?"                              ---------------------"
                ?
                ?"                  Resultados de la Jornada: "
                ??JORNADA
                ??" Fecha: "
                ??FECHA
                ?
                REPORT FORM JOIC FOR JORNADA=J NOEJECT PLAIN

        ENDIF

        IF MODO$"Ee"

                ?"                              LIGA LOCAL DE FUTBITO"
                ?"                              ---------------------"
                ?
                ?"                       Pr¢xima Jornada: "
                ??JORNADA
                ??" Fecha: "
                ??FECHA
                ?
                IF AR$"Ss"

                        REPORT FORM JOFE FOR JORNADA=J NOEJECT PLAIN
                ELSE

                        REPORT FORM JOFE2 FOR JORNADA=J NOEJECT PLAIN

                ENDIF


        ENDIF

        ?
        ?"  Organiza: Delegaci¢n de Deportes del Excmo. Ayuntamiento de Pilas (Sevilla)."
	  ?"            (c) JCV.SOFT, 1996-2002, Pilas (Sevilla), Tfn.: 657360180"

        EJECT

        SET DEVICE TO SCREEN
        SET PRINT OFF

        ?
        WAIT

ENDIF

USE
RETURN
