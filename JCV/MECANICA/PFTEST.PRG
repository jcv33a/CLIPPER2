**************
* PFTEST.PRG *
**************

*** MODIFY.PRG

PROCEDURE MODIFY

SET KEY 28 TO HELP

CLEAR

@0,0 SAY "[F1] = Ayuda"

BROWSE()

CLEAR

BORRAR=SPACE(1)
@0,0 SAY "®QUIERE BORRAR LAS FICHAS MARCADAS? (N/S):" GET BORRAR
READ

IF BORRAR$"Ss"
        PACK
ENDIF

CLEAR

SET CURSOR OFF
SET CURSOR ON
SET KEY 28 TO

RETURN

*** HACERTEST.PRG

PROCEDURE HACERTEST

CONTADOR=0
ACIERTO=0

CLEAR

CONTINUAR=SPACE(1)
@0,0 SAY "®QUIERE CONTINUAR? (N/S):" GET CONTINUAR
READ

IF CONTINUAR$"Ss"

        STORE "S" TO SIG
        DO WHILE SIG$"Ss"

                STORE "N" TO SIG

                IF EOF()

                        GO TOP

                ENDIF

                CLEAR

                @0,0 SAY "PREGUNTA NÈMERO: "+STR(NUMERO)
                @0,30 SAY "Nß REGISTRO: "+STR(RECNO())
                @2,0 SAY "    "+PREGUNTA1
                @3,0 SAY "    "+PREGUNTA2
                @4,0 SAY "    "+PREGUNTA3
                @6,0 SAY "(A) "+OPCIONA1
                @7,0 SAY "    "+OPCIONA2
                @8,0 SAY "    "+OPCIONA3
                @10,0 SAY "(B) "+OPCIONB1
                @11,0 SAY "    "+OPCIONB2
                @12,0 SAY "    "+OPCIONB3
                @14,0 SAY "(C) "+OPCIONC1
                @15,0 SAY "    "+OPCIONC2
                @16,0 SAY "    "+OPCIONC3

                REPLACE SUOPCION WITH ""

                @18,0 SAY "RESPUESTA: " GET SUOPCION

                READ

                @20,0 SAY "RESPUESTA CORRECTA: "+LAOPCION

                READ

                        IF SUOPCION=LAOPCION

                                ACIERTO=ACIERTO+1
                                @22,25 SAY "≠≠≠RESPUESTA CORRECTA!!!"

                        ELSE

                                @22,25 SAY "≠≠≠NOOO!!!"

                        ENDIF

                SKIP 1

                CONTADOR=CONTADOR+1

                @24,0 SAY "®QUIERE HACER OTRA PREGUNTA? (S/N): " GET SIG

                READ

        ENDDO

ENDIF

CLEAR

@0,0 SAY "RESULTADOS:"
@2,0 SAY "PREGUNTAS REALIZADAS" GET CONTADOR
@4,0 SAY "PREGUNTAS ACERTADAS" GET ACIERTO
ERROR=CONTADOR-ACIERTO
@6,0 SAY "PREGUNTAS ERRONEAS" GET ERROR
?
WAIT

RETURN

*** REPASARTEST.PRG

PROCEDURE REPASARTEST

CONTADOR=0
ACIERTO=0

CLEAR

CONTINUAR=SPACE(1)
@0,0 SAY "®QUIERE CONTINUAR? (N/S):" GET CONTINUAR
READ

IF CONTINUAR$"Ss"

GO TOP

        STORE "S" TO SIG
        DO WHILE SIG$"Ss"

                IF EOF()

                        CLEAR

                        @0,0 SAY "HA LLEGADO AL FINAL DEL FICHERO..."
                        @1,0 SAY "PUEDE VOLVER A EMPEZAR SI LO DESEA"
                        @3,0 SAY "RESULTADOS:"
                        @5,0 SAY "PREGUNTAS REALIZADAS" GET CONTADOR
                        @7,0 SAY "PREGUNTAS ACERTADAS" GET ACIERTO
                        ERROR=CONTADOR-ACIERTO
                        @9,0 SAY "PREGUNTAS ERRONEAS" GET ERROR
                        ?
                        WAIT

                        RETURN

                ENDIF

                IF SUOPCION<>LAOPCION

                STORE "N" TO SIG

                CLEAR

                @0,0 SAY "PREGUNTA NÈMERO: "+STR(NUMERO)
                @0,30 SAY "Nß REGISTRO: "+STR(RECNO())
                @2,0 SAY "    "+PREGUNTA1
                @3,0 SAY "    "+PREGUNTA2
                @4,0 SAY "    "+PREGUNTA3
                @6,0 SAY "(A) "+OPCIONA1
                @7,0 SAY "    "+OPCIONA2
                @8,0 SAY "    "+OPCIONA3
                @10,0 SAY "(B) "+OPCIONB1
                @11,0 SAY "    "+OPCIONB2
                @12,0 SAY "    "+OPCIONB3
                @14,0 SAY "(C) "+OPCIONC1
                @15,0 SAY "    "+OPCIONC2
                @16,0 SAY "    "+OPCIONC3

                REPLACE SUOPCION WITH ""

                @18,0 SAY "RESPUESTA: " GET SUOPCION

                READ

                @20,0 SAY "RESPUESTA CORRECTA: "+LAOPCION

                READ

                        IF SUOPCION=LAOPCION

                                ACIERTO=ACIERTO+1
                                @22,25 SAY "≠≠≠RESPUESTA CORRECTA!!!"

                        ELSE

                                @22,25 SAY "≠≠≠NOOO!!!"

                        ENDIF

                CONTADOR=CONTADOR+1

                @24,0 SAY "®QUIERE HACER OTRA PREGUNTA? (S/N): " GET SIG

                READ

                ENDIF

                SKIP 1

        ENDDO

ENDIF

CLEAR

@0,0 SAY "RESULTADOS:"
@2,0 SAY "PREGUNTAS REALIZADAS" GET CONTADOR
@4,0 SAY "PREGUNTAS ACERTADAS" GET ACIERTO
ERROR=CONTADOR-ACIERTO
@6,0 SAY "PREGUNTAS ERRONEAS" GET ERROR
?
WAIT

RETURN

*** INTROTEST.PRG

PROCEDURE INTROTEST

CONTADOR=0
ACIERTO=0
PREGUNTA=0

CLEAR

CONTINUAR=SPACE(1)
@0,0 SAY "®QUIERE CONTINUAR? (N/S):" GET CONTINUAR
READ

IF CONTINUAR$"Ss"

        STORE "S" TO SIG
        DO WHILE SIG$"Ss"

                STORE "N" TO SIG

                APPEND BLANK

                REPLACE NUMERO WITH PREGUNTA

                CLEAR

                @0,0 SAY "PREGUNTA NÈMERO: " GET NUMERO
                @0,30 SAY "Nß REGISTRO: "+STR(RECNO())
                @2,0 SAY "    " GET PREGUNTA1
                @3,0 SAY "    " GET PREGUNTA2
                @4,0 SAY "    " GET PREGUNTA3
                @6,0 SAY "(A) " GET OPCIONA1
                @7,0 SAY "    " GET OPCIONA2
                @8,0 SAY "    " GET OPCIONA3
                @10,0 SAY "(B) " GET OPCIONB1
                @11,0 SAY "    " GET OPCIONB2
                @12,0 SAY "    " GET OPCIONB3
                @14,0 SAY "(C) " GET OPCIONC1
                @15,0 SAY "    " GET OPCIONC2
                @16,0 SAY "    " GET OPCIONC3

                REPLACE SUOPCION WITH ""

                @18,0 SAY "RESPUESTA: " GET SUOPCION

                READ

                @20,0 SAY "RESPUESTA CORRECTA: " GET LAOPCION

                READ

                        IF SUOPCION=LAOPCION

                                ACIERTO=ACIERTO+1
                                @22,25 SAY "≠≠≠RESPUESTA CORRECTA!!!"

                        ELSE

                                @22,25 SAY "≠≠≠NOOO!!!"

                        ENDIF

                PREGUNTA=NUMERO+1

                SKIP 1

                CONTADOR=CONTADOR+1

                @24,0 SAY "®QUIERE INTRODUCIR OTRA PREGUNTA? (S/N): " GET SIG

                READ

        ENDDO

ENDIF

CLEAR

@0,0 SAY "RESULTADOS:"
@2,0 SAY "PREGUNTAS REALIZADAS" GET CONTADOR
@4,0 SAY "PREGUNTAS ACERTADAS" GET ACIERTO
ERROR=CONTADOR-ACIERTO
@6,0 SAY "PREGUNTAS ERRONEAS" GET ERROR
?
WAIT

RETURN

*** MODIFYTEST.PRG

PROCEDURE MODIFYTEST

CONTADOR=0
ACIERTO=0

CLEAR

CONTINUAR=SPACE(1)
@0,0 SAY "®QUIERE CONTINUAR? (N/S):" GET CONTINUAR
READ

IF CONTINUAR$"Ss"

        STORE "S" TO SIG
        DO WHILE SIG$"Ss"

                STORE "N" TO SIG

                IF EOF()

                        GO TOP

                ENDIF

                CLEAR

                @0,0 SAY "PREGUNTA NÈMERO: " GET NUMERO
                @0,30 SAY "Nß REGISTRO: "+STR(RECNO())
                @2,0 SAY "    " GET PREGUNTA1
                @3,0 SAY "    " GET PREGUNTA2
                @4,0 SAY "    " GET PREGUNTA3
                @6,0 SAY "(A) " GET OPCIONA1
                @7,0 SAY "    " GET OPCIONA2
                @8,0 SAY "    " GET OPCIONA3
                @10,0 SAY "(B) " GET OPCIONB1
                @11,0 SAY "    " GET OPCIONB2
                @12,0 SAY "    " GET OPCIONB3
                @14,0 SAY "(C) " GET OPCIONC1
                @15,0 SAY "    " GET OPCIONC2
                @16,0 SAY "    " GET OPCIONC3

                REPLACE SUOPCION WITH ""

                @18,0 SAY "RESPUESTA: " GET SUOPCION

                READ

                @20,0 SAY "RESPUESTA CORRECTA: " GET LAOPCION

                READ

                        IF SUOPCION=LAOPCION

                                ACIERTO=ACIERTO+1
                                @22,25 SAY "≠≠≠RESPUESTA CORRECTA!!!"

                        ELSE

                                @22,25 SAY "≠≠≠NOOO!!!"

                        ENDIF

                SKIP 1

                CONTADOR=CONTADOR+1

                @24,0 SAY "®QUIERE INTRODUCIR OTRA PREGUNTA? (S/N): " GET SIG

                READ

        ENDDO

ENDIF

CLEAR

@0,0 SAY "RESULTADOS:"
@2,0 SAY "PREGUNTAS REALIZADAS" GET CONTADOR
@4,0 SAY "PREGUNTAS ACERTADAS" GET ACIERTO
ERROR=CONTADOR-ACIERTO
@6,0 SAY "PREGUNTAS ERRONEAS" GET ERROR
?
WAIT

RETURN
