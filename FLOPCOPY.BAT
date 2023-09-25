echo off
cls 
type flopcopy.hlp
if "==%1" goto Help1
echo You will need 3 formatted diskettes.  Place the first in drive %1
echo If you have not prepared diskettes press Ctrl-C to exit or
pause 
echo -
echo Copying CLIPPER.EXE
copy clipper.exe %1:>NUL
copy read_me.1st %1:>NUL
echo - 
echo Insert System Disk 2 in drive A:
echo Insert your second formatted diskette in drive %1
pause 
echo -
echo Copying Libraries and DEBUG.OBJ
copy CLIPPER.LIB %1:>NUL
copy DEBUG.OBJ %1:>NUL
copy MEMO.LIB %1:>NUL
echo - 
echo Insert PLINK86 and UTILITIES disk in drive A:
echo Insert your third formatted diskette in drive %1
pause 
echo -
echo Copying PLINK86.EXE
copy PLINK86.EXE %1:>NUL
echo -
echo ******* Installation procedure complete. *******
echo -
echo  You have now installed a working copy of the Clipper compiler.  
echo  You may use the DOS "COPY" command to copy other files on the
echo  distribution diskette.  
echo -
goto end
:help1
echo -
echo ***** No drive letter specified - FLOPCOPY terminated.
:End
