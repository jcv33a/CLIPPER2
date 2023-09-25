;------------------------------------------------------------------------------
; Filename: EXTENDA.ASM
; Program.: Clipper Extended Library
; Authors.: Tom Rettig, Brian Russell
; Date....: November 1, 1985
; Notice..: Placed in the public domain by Tom Rettig Associates.
;           Clipper is a trademark of Nantucket.
;           dBASE and dBASE III are trademarks of Ashton-Tate.
; Notes...: User-defined dBASE functions in 8086 assembly for Clipper.
;
;   Functions not in dBASE III or Clipper:
;      ISPRINTER() ::= True if parallel printer is online and ready.
;

   NAME   EXTENDA

   PUBLIC ISPRINTER


; Clipper return value calls
   EXTRN   _RETC:FAR    ; return character string
   EXTRN   _RETDS:FAR   ; return date type from date string "YYYYMMDD"
   EXTRN   _RETL:FAR    ; return logical true or false
   EXTRN   _RETNI:FAR   ; return word as numeric
   EXTRN   _RETNL:FAR   ; return double word as numeric
   EXTRN   _RETND:FAR   ; return floating point as numeric

_PROG SEGMENT

         ASSUME CS:_PROG

;------------------------------------------------------------------------------
;  ISPRINTER()
;  Syntax: ISPRINTER()
;  Return: Logical true if the printer is online and ready, otherwise false

ISPRINTER PROC FAR

         MOV      AH,2H          ; printer status function
         MOV      DX,0H          ; which printer to check
         INT      17H            ; read printer status

         XOR      BX,BX          ; false
         CMP      AH,90H         ; not busy or selected (90h = 10010000)
         JNE      RET_ISPRINTER  ; return false if other than above
         MOV      BX,1           ; true

RET_ISPRINTER:
         PUSH     BX             ; put return value on the stack
         CALL     _RETL          ; return logical value to Clipper
         POP      BX             ; restore the stack

         RET

ISPRINTER ENDP

_PROG ENDS

         END

; EOF Extenda.asm -------------------------------------------------------------