* Program ...: Philes.prg
* Date ......: September 1, 1987
* Note(s) ...: This program demonstrates the use of the low-level
*              file I/O functions to a copy a file.
*
? "Copy a file..."

size = 512
buffer = SPACE(size)
total  = 0
remaining = 0

ACCEPT "Source file:  " TO source
ACCEPT "Target file:  " TO target
?

shandle = FOPEN(source)
IF FERROR() = 0

	thandle = FCREATE(target)
	IF FERROR() = 0

		* Get total source file size.
		total = FSEEK(shandle, 0, 2)
		remaining = total

		* Reset file position.
		FSEEK(shandle, 0)

		DO WHILE (remaining > 0)

			IF (remaining < size)
				size = remaining			&& Last part of file.
			ENDIF

			scount = FREAD(shandle, FWRITE(thandle, buffer, size)
			IF tcount <> size
				? "Error writing", target
				EXIT
			ENDIF

			remaining = remaining - size

		ENDDO

		FCLOSE(thandle)

	ELSE
		? "Cannot create", target, ", DOS error", FERROR()
	ENDIF

	FCLOSE(shandle)

ELSE
	? "Cannot open", source, ", DOS error", FERROR()
ENDIF

? "Total of", total - remaining, "bytes transfered."

* EOP Philes.prg
