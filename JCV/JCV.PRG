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
@1,0 SAY "(c) JCV-SOFTWARE 1994-99"
@2,0 SAY "ALL RIGHTS RESERVED."
@4,0 SAY "Jos‚ Cruz V zquez"
@5,0 SAY "c/ Fdco. Garc¡a Lorca, 21"
@6,0 SAY "41840 Pilas (Sevilla)"
@7,0 SAY "Tfn.: 954 750 792, 657 360 180, 610 04 05 28"
?
WAIT

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
        @2,0 PROMPT "(1)........ALMACEN"
        @3,0 PROMPT "(2)....FACTURACION"
        @4,0 PROMPT "(3)...CONTABILIDAD"
        @5,0 PROMPT "(4).....UTILIDADES"

        MENU TO OPCION0

                DO CASE
                        CASE OPCION0=1
                                DO STOCK
                        CASE OPCION0=2
                                DO FACTURA
                        CASE OPCION0=3
                                DO CONTABILIDAD
                        CASE OPCION0=4
                                DO UTILIDADES
                ENDCASE

ENDDO

RETURN

*** STOCK.PRG

PROCEDURE STOCK

USE STOCK

OPCION1=1

DO WHILE OPCION1 <> 0

        SET INDEX TO REF,CLASE
        CLEAR

        @0,0 SAY    "MENU ALMACEN"
        @1,0 SAY    "------------------------------------"
        @2,0 PROMPT "(1)............................STOCK"
        @3,0 PROMPT "(2).................INTRODUCIR STOCK"
        @4,0 PROMPT "(3)..................MODIFICAR STOCK"
        @5,0 PROMPT "(4).....PRODUCTOS BAJO MINIMO (PRN.)"
        @6,0 PROMPT "(5)...LISTADO DE STOCK ACTUAL (PRN.)"

        MENU TO OPCION1

        DO CASE

                CASE OPCION1=1
                        DO MODIFY
                CASE OPCION1=2
                        DO MODSTOCK
                CASE OPCION1=3
                        DO STOCKENT
                CASE OPCION1=4
                        DO STOCKBAJ
                CASE OPCION1=5
                        DO LISACT

        ENDCASE

ENDDO

USE

RETURN

*** FACTURA.PRG

PROCEDURE FACTURA

OPCION2=1

DO WHILE OPCION2 <> 0

        CLEAR

        @0,0 SAY    "FACTURACION"
        @1,0 SAY    "------------------------------"
        @2,0 PROMPT "(1).........MODIFICAR FACTURAS"
        @3,0 PROMPT "(2).........INTRODUCIR FICHA/S"
        @4,0 PROMPT "(3)...........MODIFICAR FICHAS"
        @5,0 PROMPT "(4)....BUSCAR UNA FICHA (PRN.)"
        @6,0 PROMPT "(5)......HACER FACTURAS (PRN.)"
        @7,0 PROMPT "(6)...IMPRIMIR FACTURAS (PRN.)"
        @8,0 PROMPT "(7).....PIEZAS VENDIDAS (PRN.)"

        MENU TO OPCION2

        DO CASE

               CASE OPCION2=1
                        USE FACTURAS INDEX NUMFA,FECHA
                        CLEAR
                        BROWSE()
                        CLEAR
                        BORRAR=SPACE(1)
                        @0,0 SAY "¨QUIERE BORRAR LAS FICHAS MARCADAS? (N/S):" GET BORRAR
                        READ
                        IF BORRAR$"Ss"
                                PACK
                        ENDIF
                        SET CURSOR OFF
                        SET CURSOR ON
                        USE
               CASE OPCION2=2
                        USE FICHDIRE INDEX APELLIDO
                        DO DIREC
                        USE
               CASE OPCION2=3
                        USE FICHDIRE INDEX APELLIDO
                        CLEAR
                        BROWSE()
                        CLEAR
                        BORRAR=SPACE(1)
                        @0,0 SAY "¨QUIERE BORRAR LAS FICHAS MARCADAS? (N/S):" GET BORRAR
                        READ
                        IF BORRAR$"Ss"
                                PACK
                        ENDIF
                        SET CURSOR OFF
                        SET CURSOR ON
                        USE
                CASE OPCION2=4
                        USE FICHDIRE INDEX APELLIDO
                        DO BUSCA
                        USE
                CASE OPCION2=5
                        DO FACT
                        SELECT 3
                        USE
                        SELECT 2
                        USE
                        SELECT 1
                        USE
                CASE OPCION2=6
                        DO PRNFACT
                CASE OPCION2=7
                        USE FACTURAS INDEX FECHA
                        DO PVEND
                        USE

        ENDCASE

ENDDO

RETURN

*** CONTABILIDAD.PRG

PROCEDURE CONTABILIDAD

USE BAN

CLEAR
BROWSE()

CLEAR
BORRAR=SPACE(1)
@0,0 SAY "¨QUIERE BORRAR LAS FICHAS MARCADAS? (N/S):" GET BORRAR
READ
IF BORRAR$"Ss"
        PACK
ENDIF

CLEAR
VER=SPACE(1)
@0,0 SAY "¨QUIERE VER UN REPORT? (N/S):" GET VER
READ
IF VER$"Ss"
        REPORT FORM BAN NOEJECT
        ?
        WAIT
ENDIF

CLEAR
IMPRIMIR=SPACE(1)
@0,0 SAY "¨QUIERE IMPRIMIR UN REPORT? (N/S):" GET IMPRIMIR
READ
IF IMPRIMIR$"Ss"
        REPORT FORM BAN NOEJECT TO PRINT
ENDIF

SET CURSOR OFF
SET CURSOR ON

USE

RETURN

*** UTILIDADES.PRG

PROCEDURE UTILIDADES

OPCION3=1

DO WHILE OPCION3 <> 0

        CLEAR

        @0,0 SAY    "UTILIDADES"
        @1,0 SAY    "---------------------------------"
        @2,0 PROMPT "(1).........REINDEXACION DE STOCK"
        @3,0 PROMPT "(2)...REINDEXACION DE DIRECCIONES"
        @4,0 PROMPT "(3)......REINDEXACION DE FACTURAS"

        MENU TO OPCION3

        DO CASE

                CASE OPCION3=1
                        DO INDSTOCK
                CASE OPCION3=2
                        DO INDDIREC
                CASE OPCION3=3
                        DO INDFACT

        ENDCASE

ENDDO

RETURN
