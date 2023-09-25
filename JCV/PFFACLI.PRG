*** DIREC.PRG

PROCEDURE DIREC

CLEAR

CONTINUAR=SPACE(1)
@0,0 SAY "¨QUIERES CONTINUAR? (N/S):" GET CONTINUAR
READ

IF CONTINUAR$"Ss"

        STORE "S" TO SIG
        DO WHILE SIG$"Ss"

                APPEND BLANK

                CLEAR
                @0,0 SAY "ENTRADA AL FICHERO DE DIRECCIONES"
                @2,0 SAY "NOMBRE" GET NOMBRE
                @3,0 SAY "APELLIDO O NOMBRE DE LA EMPRESA" GET APELLIDO
                @4,0 SAY "TITULO-SR,SRA,SRTA U OTRO" GET TITULO
                @5,0 SAY "INICIALES" GET INICIALES
                @6,0 SAY "APODO" GET APODO
                @7,0 SAY "PRIMERA LINEA DE DIRECCIONES" GET DIRECCION1
                @8,0 SAY "SEGUNDA LINEA DE DIRECCIONES" GET DIRECCION2
                @9,0 SAY "TERCERA LINEA DE DIRECCIONES" GET DIRECCION3
                @10,0 SAY "DNI/NIF" GET CIF
                @11,0 SAY "NUMERO DE TELEFONO" GET TELEFONO
                @12,0 SAY "FAX" GET FAX

                @14,0 SAY "¨QUIERE INTRODUCIR OTRA FICHA? (S/N):" GET SIG

                READ

        ENDDO

ENDIF

RETURN

*** BUSCA.PRG

PROCEDURE BUSCA

CLEAR

COMP=SPACE(10)
@0,0 SAY "APELLIDO O NOMBRE DE LA EMPRESA A LOCALIZAR:" GET COMP
READ

STORE UPPER(COMP) TO COMPNOMB
FIND &COMPNOMB

STORE "N" TO SIG
DO WHILE SIG$"Nn" .AND..NOT.EOF()

        CLEAR
        @0,0 SAY TITULO
        @1,0 SAY NOMBRE
        @2,0 SAY DIRECCION1
        @3,0 SAY DIRECCION2
        @4,0 SAY DIRECCION3
        @5,0 SAY "DNI/NIF: "+CIF
        @6,0 SAY "NUMERO DE TELEFONO: "+TELEFONO
        @7,0 SAY "FAX: "+FAX

        @9,0 SAY "¨ES ESTE EL PRIMERO? (N/S):" GET SIG
        READ

        IF SIG$"Nn"
                SKIP 1
        ENDIF

ENDDO

IF EOF()

        CLEAR
        @0,0 SAY "FINAL DEL FICHERO, NO SE HA ENCONTRADO LA FICHA BUSCADA."
        @1,0
        WAIT
        RETURN

ENDIF

IMPRIMIR=SPACE(1)
@11,0 SAY "¨QUIERES IMPRIMIR ESTE? (N/S):" GET IMPRIMIR
READ

IF IMPRIMIR$"Ss"

        IMPRIMIR=SPACE(1)
        @13,0 SAY "¨IMPRIMIR CARTAS? (S/N):" GET IMPRIMIR

        IF IMPRIMIR$"Nn"

                SET DEVICE TO PRINT

                @0,0 SAY TITULO
                @1,0 SAY NOMBRE
                @2,0 SAY DIRECCION1
                @3,0 SAY DIRECCION2
                @4,0 SAY DIRECCION3
                @5,0 SAY "DNI/NIF: "+CIF
                @6,0 SAY "NUMERO DE TELEFONO: "+TELEFONO
                @7,0 SAY "FAX: "+FAX
                @8,0

                SET DEVICE TO SCREEN

                RETURN

        ENDIF

        SET DEVICE TO PRINT

        @0,0 SAY TITULO
        @1,0 SAY NOMBRE
        @2,0 SAY DIRECCION1
        @3,0 SAY DIRECCION2
        @4,0 SAY DIRECCION3
        @5,0

        SET DEVICE TO SCREEN

ENDIF

RETURN

*** FACT.PRG

PROCEDURE FACT

CONTADOR=0

CLEAR

OPCION=SPACE(1)
@0,0 SAY "¨REALIZARA EL PAGO A PLAZOS? (N/S):" GET OPCION
READ

IF OPCION$"Ss"

        DO PLAZOS
        RETURN

ENDIF

CLEAR
SELECT 1
USE FICHDIRE INDEX APELLIDO

COMP=SPACE(10)
@0,0 SAY "NOMBRE DE LA EMPRESA O APELLIDO DEL CLIENTE:" GET COMP
READ
COMPNOMB=UPPER(COMP)
FIND &COMPNOMB

STORE "N" TO SIG
DO WHILE SIG$"Nn" .AND..NOT.EOF()

        CLEAR
        @0,0 SAY TITULO
        @1,0 SAY NOMBRE
        @2,0 SAY DIRECCION1
        @3,0 SAY DIRECCION2
        @4,0 SAY DIRECCION3
        @5,0 SAY "DNI/NIF: "+CIF
        @6,0 SAY "NUMERO DE TELEFONO: "+TELEFONO
        @7,0 SAY "FAX: "+FAX

        @9,0 SAY "¨ES ESTE EL PRIMERO? (N/S):" GET SIG
        READ

        IF SIG$"Nn"
                SKIP 1
        ENDIF

        IF EOF()
                CLEAR
                @0,0 SAY "SE HA ALCANZADO EL FINAL DEL FICHERO, NO SE HA ENCONTRADO EL CLIENTE."
                @1,0
                WAIT
                RETURN
        ENDIF

ENDDO

IF EOF()
        CLEAR
        @0,0 SAY "SE HA ALCANZADO EL FINAL DEL FICHERO, NO SE HA ENCONTRADO EL CLIENTE."
        @1,0
        WAIT
        RETURN
ENDIF

CONTINUAR=SPACE(1)
@11,0 SAY "¨QUIERE CONTINUAR? (N/S):" GET CONTINUAR
READ

IF CONTINUAR$"Ss"

        SELECT 4
        USE FACTURAS
        GOTO BOTTOM
        @13,0 SAY "ULTIMO NUMERO DE FACTURA: "+NUMFA
        USE
        NUMF=SPACE(4)
        @15,0 SAY "NUMERO DE FACTURA:" GET NUMF
        READ

        STORE "S" TO MAS
        DO WHILE MAS$"Ss"

                NUMPIEZA=0
                CONTADOR=CONTADOR+1

                CLEAR

                IF CONTADOR>10
                        @0,0 SAY "NO SE PUEDEN A¥ADIR MAS ARTICULOS EN ESTA FACTURA."
                        @1,0
                        WAIT
                        STORE "N" TO MAS
                        LOOP
                ENDIF

                SELECT 2
                USE STOCK INDEX REF

                PIEZA=SPACE(6)
                @0,0 SAY "REFERENCIA:" GET PIEZA
                READ
                FIND &PIEZA
                @1,0 SAY "ARTICULO: "+COMENT1
                @2,0 SAY "PRECIO DE VENTA: "+STR(PVP)
                @3,0 SAY "¨CUANTAS?" GET NUMPIEZA PICTURE "999.99"
                READ

                IF NUMPIEZA>NUMERO

                        @4,0 SAY "NO HAY SUFICIENTE CANTIDAD EN STOCK, SOLO HAY: "+STR(NUMERO)

                        IF NUMERO<1
                                @5,0 SAY "NO SE PUEDE SERVIR ESTA CANTIDAD, REPONGA EL ARTICULO."
                                @7,0 SAY "¨SE PIDE OTRA PIEZA? (S/N):" GET MAS
                                READ
                                LOOP
                        ENDIF

                        OPCION=SPACE(1)
                        @5,0 SAY "¨SE SIRVE ESTA CANTIDAD? (S/N):" GET OPCION
                        READ

                        IF OPCION$"Nn"
                                @7,0 SAY "¨SE PIDE OTRA PIEZA? (S/N):" GET MAS
                                READ
                                LOOP
                        ENDIF

                        STORE NUMERO TO NUMPIEZA

                ENDIF

                @6,0 SAY "TOTAL: "+STR(NUMPIEZA*PVP)

                REPLACE NUMERO WITH NUMERO-NUMPIEZA
                REPLACE PIEZVEND WITH PIEZVEND+NUMPIEZA

                STORE PVP*NUMPIEZA TO ABONAR

                SELECT 3
                USE FACTURAS INDEX NUMFA,FECHA
                APPEND BLANK
                REPLACE TITULO WITH A->TITULO
                REPLACE NOMBRE WITH A->NOMBRE
                REPLACE DIRECCION1 WITH A->DIRECCION1
                REPLACE DIRECCION2 WITH A->DIRECCION2
                REPLACE DIRECCION3 WITH A->DIRECCION3
                REPLACE CIF WITH A->CIF
                REPLACE TELEFONO WITH A->TELEFONO
                REPLACE FAX WITH A->FAX
                REPLACE REF WITH B->REF
                REPLACE PRECIO WITH B->PVP
                REPLACE COMENT1 WITH B->COMENT1
                REPLACE FECHA WITH DATE()
                REPLACE NUMPIEZAS WITH NUMPIEZA
                REPLACE NUMFA WITH NUMF
                REPLACE ABONO WITH ABONAR
                USE

                @8,0 SAY "¨SE PIDE OTRA PIEZA? (S/N):" GET MAS
                READ
        ENDDO

        CLEAR
        IMPRIMIR=SPACE(1)
        @0,0 SAY "¨QUIERE IMPRIMIR LA FACTURA? (N/S):" GET IMPRIMIR
        READ

        IF IMPRIMIR$"Ss"

                @1,0
                WAIT
                SET DEVICE TO PRINT
                SET PRINT ON
                SET CONSOLE OFF
                @1,1 SAY " "

        ENDIF

        CLEAR

        SELECT 3
        USE FACTURAS INDEX NUMFA

        FIND &NUMF
        @1,5 SAY "F A C T U R A"
        @3,5 SAY "SANTA ELENA (FONTANERIA Y SANEAMIENTOS)"
        @4,5 SAY "C/ CONCEPCION RODRIGUEZ SOLIS No. 5, SANLUCAR M. (SEVILLA)"
        @5,5 SAY "CIF.: B-41629247, TFN. Y FAX: (95)-5702017"
        @7,5 SAY "CLIENTE:"
                @7,55 SAY "FECHA (DD-MM-AA):"
        @8,5 SAY TITULO
                @8,55 SAY FECHA
        @9,5 SAY NOMBRE
                @9,55 SAY "FACT. Nø:"
                @9,65 SAY NUMFA
        @10,5 SAY DIRECCION1
                @10,55 SAY "FORMA DE PAGO:"
        @11,5 SAY DIRECCION2
                @11,55 SAY "CONTADO"
        @12,5 SAY DIRECCION3
        @13,5 SAY "TELEFONO: "+TELEFONO
        @14,5 SAY "No. FAX: "+FAX
        @15,5 SAY "DNI/NIF: "+CIF

        ?
        FIND &NUMF
        REPORT FORM FACTUR WHILE NUMFA=NUMF NOEJECT PLAIN

        FIND &NUMF
        SUM NUMPIEZAS*PRECIO TO TOTAL WHILE NUMFA=NUMF

        STORE TOTAL*0.07 TO IVA
        STORE TOTAL+IVA TO TOTAL2

        ?
        ?"     SUBTOTAL:"
        ??TOTAL
        ?
        ?"     IVA(7%):"
        ??IVA
        ?
        ?"     TOTAL:"
        ??TOTAL2
        ?

        SET DEVICE TO SCREEN
        SET PRINT OFF
        SET CONSOLE ON
        ?
        WAIT

ENDIF

RETURN

*** PLAZOS.PRG

PROCEDURE PLAZOS

CLEAR

OPCION=SPACE(1)
@0,0 SAY "¨ES ESTE EL PRIMER PLAZO? (S/N):" GET OPCION
READ

IF OPCION$"Nn"

        DO PLAZOS2
        RETURN

ENDIF

CLEAR
SELECT 1
USE FICHDIRE INDEX APELLIDO

COMP=SPACE(10)
@0,0 SAY "NOMBRE DE LA EMPRESA O APELLIDO DEL CLIENTE:" GET COMP
READ
COMPNOMB=UPPER(COMP)
FIND &COMPNOMB

STORE "N" TO SIG
DO WHILE SIG$"Nn" .AND..NOT.EOF()

        CLEAR
        @0,0 SAY TITULO
        @1,0 SAY NOMBRE
        @2,0 SAY DIRECCION1
        @3,0 SAY DIRECCION2
        @4,0 SAY DIRECCION3
        @5,0 SAY "TELEFONO: "+TELEFONO
        @6,0 SAY "FAX: "+FAX
        @7,0 SAY "DNI/NIF: "+CIF

        @9,0 SAY "¨ES ESTE EL PRIMERO? (S/N):" GET SIG
        READ

        IF SIG$"Nn"
                SKIP 1
        ENDIF

        IF EOF()
                CLEAR
                @0,0 SAY "SE HA ALCANZADO EL FINAL DEL FICHERO, NO SE HA ENCONTRADO EL CLIENTE."
                @1,0
                WAIT
                RETURN
        ENDIF

ENDDO

IF EOF()
        CLEAR
        @0,0 SAY "SE HA ALCANZADO EL FINAL DEL FICHERO, NO SE HA ENCONTRADO EL CLIENTE."
        @1,0
        WAIT
        RETURN
ENDIF

CONTINUAR=SPACE(1)
@11,0 SAY "¨QUIERE CONTINUAR? (N/S):" GET CONTINUAR
READ

IF CONTINUAR$"Ss"

        SELECT 4
        USE FACTURAS
        GOTO BOTTOM
        @13,0 SAY "ULTIMO NUMERO DE FACTURA: "+NUMFA
        USE
        NUMF=SPACE(4)
        @15,0 SAY "NUMERO DE FACTURA:" GET NUMF
        READ

        STORE "S" TO MAS
        DO WHILE MAS$"Ss"

                ABONAR=0
                NUMPIEZA=0
                CONTADOR=CONTADOR+1

                CLEAR

                IF CONTADOR>10
                        @0,0 SAY "NO SE PUEDEN A¥ADIR MAS ARTICULOS EN ESTA FACTURA."
                        @1,0
                        WAIT
                        STORE "N" TO MAS
                        LOOP
                ENDIF

                SELECT 2
                USE STOCK INDEX REF

                PIEZA=SPACE(6)
                @0,0 SAY "REFERENCIA:" GET PIEZA
                READ
                FIND &PIEZA
                @1,0 SAY "ARTICULO: "+COMENT1
                @2,0 SAY "PRECIO DE VENTA: "+STR(PVP)
                @3,0 SAY "¨CUANTAS?" GET NUMPIEZA PICTURE "999.99"

                IF NUMPIEZA>NUMERO

                        @4,0 SAY "NO HAY SUFICIENTE CANTIDAD EN STOCK, SOLO HAY: "+STR(NUMERO)

                        IF NUMERO<1
                                @5,0 SAY "NO SE PUEDE SERVIR ESTA CANTIDAD, REPONGA EL ARTICULO."
                                @7,0 SAY "¨SE PIDE OTRA PIEZA? (S/N):" GET MAS
                                READ
                                LOOP
                        ENDIF

                        OPCION=SPACE(1)
                        @5,0 SAY "¨SE SIRVE ESTA CANTIDAD? (S/N):" GET OPCION
                        READ

                        IF OPCION$"Nn"
                                @7,0 SAY "¨SE PIDE OTRA PIEZA? (S/N):" GET MAS
                                READ
                                LOOP
                        ENDIF

                        STORE NUMERO TO NUMPIEZA

                ENDIF

                @6,0 SAY "TOTAL: "+STR(NUMPIEZA*PVP)
                @7,0 SAY "¨CANTIDAD A ABONAR?" GET ABONAR PICTURE "999999.99"
                READ

                REPLACE NUMERO WITH NUMERO-NUMPIEZA
                REPLACE PIEZVEND WITH PIEZVEND+NUMPIEZA

                SELECT 3
                USE FACTURAS INDEX NUMFA,FECHA
                APPEND BLANK
                REPLACE TITULO WITH A->TITULO
                REPLACE NOMBRE WITH A->NOMBRE
                REPLACE DIRECCION1 WITH A->DIRECCION1
                REPLACE DIRECCION2 WITH A->DIRECCION2
                REPLACE DIRECCION3 WITH A->DIRECCION3
                REPLACE CIF WITH A->CIF
                REPLACE TELEFONO WITH A->TELEFONO
                REPLACE FAX WITH A->FAX
                REPLACE REF WITH B->REF
                REPLACE PRECIO WITH B->PVP
                REPLACE COMENT1 WITH B->COMENT1
                REPLACE FECHA WITH DATE()
                REPLACE NUMPIEZAS WITH NUMPIEZA
                REPLACE NUMFA WITH NUMF
                REPLACE ABONO WITH ABONAR
                USE

                @9,0 SAY "¨SE PIDE OTRA PIEZA? (N/S):" GET MAS
                READ

        ENDDO

        CLEAR
        IMPRIMIR=SPACE(1)
        @0,0 SAY "¨QUIERE IMPRIMIR LA FACTURA? (N/S):" GET IMPRIMIR
        READ

        IF IMPRIMIR$"Ss"

                @1,0
                WAIT
                SET DEVICE TO PRINT
                SET PRINT ON
                SET CONSOLE OFF
                @1,1 SAY " "

        ENDIF

        CLEAR

        SELECT 3
        USE FACTURAS INDEX NUMFA

        FIND &NUMF
        @1,5 SAY "F A C T U R A"
        @3,5 SAY "SANTA ELENA (FONTANERIA Y SANEAMIENTOS)"
        @4,5 SAY "C/ CONCEPCION RODRIGUEZ SOLIS No. 5, SANLUCAR M. (SEVILLA)"
        @5,5 SAY "CIF.: B-41629247, TFN. Y FAX: (95)-5702017"
        @7,5 SAY "CLIENTE:"
                @7,55 SAY "FECHA (DD-MM-AA):"
        @8,5 SAY TITULO
                @8,55 SAY FECHA
        @9,5 SAY NOMBRE
                @9,55 SAY "FACT. Nø:"
                @9,65 SAY NUMFA
        @10,5 SAY DIRECCION1
                @10,55 SAY "FORMA DE PAGO:"
        @11,5 SAY DIRECCION2
                @11,55 SAY "A PLAZOS"
        @12,5 SAY DIRECCION3
        @13,5 SAY "TELEFONO: "+TELEFONO
        @14,5 SAY "No. FAX: "+FAX
        @15,5 SAY "DNI/NIF: "+CIF

        ?
        FIND &NUMF
        REPORT FORM FACTUR2 WHILE NUMFA=NUMF NOEJECT PLAIN

        FIND &NUMF
        SUM NUMPIEZAS*PRECIO TO TOTAL WHILE NUMFA=NUMF
        FIND &NUMF
        SUM ABONO TO ABONOTOTAL WHILE NUMFA=NUMF

        STORE TOTAL-ABONOTOTAL TO DEBER

        ?
        ?"     DEBE:"
        ??DEBER
        ?

        SET DEVICE TO SCREEN
        SET PRINT OFF
        SET CONSOLE ON
        ?
        WAIT

ENDIF

RETURN

*** PLAZOS2.PRG

PROCEDURE PLAZOS2

CLEAR

USE FACTURAS INDEX NUMFA

NUMF=SPACE(4)
@0,0 SAY "NUMERO DE FACTURA:" GET NUMF
READ
FIND &NUMF

IF EOF()

        @2,0 SAY "NO EXISTE ESA FACTURA."
        @3,0
        WAIT
        RETURN

ENDIF

STORE "S" TO MAS
DO WHILE MAS$"S" .AND..NOT.EOF()

        IF NUMFA=NUMF

                @2,0 SAY "ARTICULO: "+COMENT1
                @3,0 SAY "PRECIO DE VENTA: "+STR(PRECIO)
                @4,0 SAY "CANTIDAD: "+STR(NUMPIEZAS)
                @5,0 SAY "TOTAL: "+STR(NUMPIEZAS*PRECIO)
                @6,0 SAY "ABONO: "+STR(ABONO)

                ABONAR=0
                @7,0 SAY "¨CANTIDAD A ABONAR?" GET ABONAR PICTURE "999999.99"
                READ

                REPLACE ABONO WITH ABONO+ABONAR
                @8,0
                WAIT
                @2,0 CLEAR
                SKIP 1

        ELSE

                STORE "N" TO MAS

        ENDIF

ENDDO

IMPRIMIR=SPACE(1)
@2,0 SAY "¨QUIERE IMPRIMIR LA FACTURA? (N/S):" GET IMPRIMIR
READ

IF IMPRIMIR$"Ss"

        @3,0
        WAIT
        SET DEVICE TO PRINT
        SET PRINT ON
        SET CONSOLE OFF
        @1,1 SAY " "

ENDIF

CLEAR
FIND &NUMF
@1,5 SAY "F A C T U R A"
@3,5 SAY "SANTA ELENA (FONTANERIA Y SANEAMIENTOS)"
@4,5 SAY "C/ CONCEPCION RODRIGUEZ SOLIS No. 5, SANLUCAR M. (SEVILLA)"
@5,5 SAY "CIF.: B-41629247, TFN. Y FAX: (95)-5702017"
@7,5 SAY "CLIENTE:"
        @7,55 SAY "FECHA (DD-MM-AA):"
@8,5 SAY TITULO
        @8,55 SAY FECHA
@9,5 SAY NOMBRE
        @9,55 SAY "FACT. Nø:"
        @9,65 SAY NUMFA
@10,5 SAY DIRECCION1
        @10,55 SAY "FORMA DE PAGO:"
@11,5 SAY DIRECCION2
        @11,55 SAY "A PLAZOS"
@12,5 SAY DIRECCION3
@13,5 SAY "TELEFONO: "+TELEFONO
@14,5 SAY "No. FAX: "+FAX
@15,5 SAY "DNI/NIF: "+CIF

?
FIND &NUMF
REPORT FORM FACTUR2 WHILE NUMFA=NUMF NOEJECT PLAIN

FIND &NUMF
SUM NUMPIEZAS*PRECIO TO TOTAL WHILE NUMFA=NUMF
FIND &NUMF
SUM ABONO TO ABONOTOTAL WHILE NUMFA=NUMF

STORE TOTAL-ABONOTOTAL TO DEBER

?
?"     DEBE:"
??DEBER
?

SET DEVICE TO SCREEN
SET PRINT OFF
SET CONSOLE ON
?
WAIT
RETURN

*** PRNFACT.PRG

PROCEDURE PRNFACT

CLEAR
USE FACTURAS INDEX NUMFA

NUMF=SPACE(4)
@0,0 SAY "NUMERO DE FACTURA:" GET NUMF
READ
FIND &NUMF

IF EOF()

        @2,0 SAY "NO EXISTE ESA FACTURA."
        @3,0
        WAIT
        USE
        RETURN

ENDIF

IMPRIMIR=SPACE(1)
@2,0 SAY "¨QUIERE IMPRIMIR LA FACTURA? (N/S):" GET IMPRIMIR
READ

IF IMPRIMIR$"Ss"

        @3,0
        WAIT
        SET DEVICE TO PRINT
        SET PRINT ON
        SET CONSOLE OFF
        @1,1 SAY " "

ENDIF

CLEAR
FIND &NUMF
@1,5 SAY "F A C T U R A"
@3,5 SAY "SANTA ELENA (FONTANERIA Y SANEAMIENTOS)"
@4,5 SAY "C/ CONCEPCION RODRIGUEZ SOLIS No. 5, SANLUCAR M. (SEVILLA)"
@5,5 SAY "CIF.: B-41629247, TFN. Y FAX: (95)-5702017"
@7,5 SAY "CLIENTE:"
        @7,55 SAY "FECHA (DD-MM-AA):"
@8,5 SAY TITULO
        @8,55 SAY FECHA
@9,5 SAY NOMBRE
        @9,55 SAY "FACT. Nø:"
        @9,65 SAY NUMFA
@10,5 SAY DIRECCION1
        @10,55 SAY "FORMA DE PAGO:"
@11,5 SAY DIRECCION2

FIND &NUMF
SUM ABONO TO ABONOTOTAL WHILE NUMFA=NUMF
FIND &NUMF
SUM NUMPIEZAS*PRECIO TO TOTAL WHILE NUMFA=NUMF

IF ABONOTOTAL=TOTAL

        @11,55 SAY "CONTADO"

ELSE

        @11,55 SAY "A PLAZOS"

ENDIF

FIND &NUMF
@12,5 SAY DIRECCION3
@13,5 SAY "TELEFONO: "+TELEFONO
@14,5 SAY "No. FAX: "+FAX
@15,5 SAY "DNI/NIF: "+CIF

IF ABONOTOTAL=TOTAL

        ABONOTOTAL=0
        ?
        FIND &NUMF
        REPORT FORM FACTUR WHILE NUMFA=NUMF NOEJECT PLAIN

ELSE

        ?
        FIND &NUMF
        REPORT FORM FACTUR2 WHILE NUMFA=NUMF NOEJECT PLAIN

ENDIF

STORE TOTAL-ABONOTOTAL TO DEBER
STORE DEBER*0.07 TO IVA
STORE DEBER+IVA TO TOTALDEBE

?
?"     SUBTOTAL:"
??DEBER
?
?"     IVA(7%):"
??IVA
?
?"     TOTAL:"
??TOTALDEBE
?

SET DEVICE TO SCREEN
SET PRINT OFF
SET CONSOLE ON
?
WAIT
USE
RETURN

*** PVEND.PRG

PROCEDURE PVEND

CLEAR

F1=SPACE(10)
F2=SPACE(10)
@0,0 SAY "PRIMERA FECHA (DD-MM-AA):" GET F1 PICTURE "##-##-##"
@2,0 SAY "SEGUNDA FECHA (DD-MM-AA):" GET F2 PICTURE "##-##-##"
READ
FA=CTOD(F1)
FB=CTOD(F2)

@3,0
REPORT FORM FACTURAS FOR FA<=FECHA .AND. FB>=FECHA

SUM NUMPIEZAS*PRECIO TO TOTAL FOR FA<=FECHA .AND. FB>=FECHA

STORE TOTAL*1 TO TOTAL1
STORE TOTAL*0.07 TO IVA
STORE TOTAL+IVA TO TOTAL2

?
?"VALOR TOTAL DE VENTAS (SIN IVA):"
??TOTAL1
?
?"IVA(7%):"
??IVA
?
?"VALOR TOTAL DE VENTAS (CON IVA):"
??TOTAL2

?
WAIT

CLEAR
IMPRIMIR=SPACE(1)
@0,0 SAY "¨QUIERES IMPRIMIRLO? (N/S):" GET IMPRIMIR
READ

IF IMPRIMIR$"Ss"

        REPORT FORM FACTURAS FOR FA<=FECHA .AND. FB>=FECHA NOEJECT TO PRINT
        SET PRINT ON
        ?
        ?"VALOR TOTAL DE VENTAS (SIN IVA):"
        ??TOTAL1
        ?
        ?"IVA(7%):"
        ??IVA
        ?
        ?"VALOR TOTAL DE VENTAS (CON IVA):"
        ??TOTAL2
        ?
        SET PRINT OFF

ENDIF

@1,0
WAIT
RETURN
