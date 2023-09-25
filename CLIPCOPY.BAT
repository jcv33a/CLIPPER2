echo off
cls 
type clipcopy.hlp
if "==%1" goto Help1
echo Clipper will be installed to the default directory.  ^C to abort or
pause 
copy read_me.1st %1:>NUL
copy clipper.exe %1:>NUL
copy cl.bat %1:>NUL
copy cld.bat %1:>NUL
copy dbu.* %1>NUL
echo -
echo Insert System Disk 2 in drive A:
pause 
copy CLIPPER.LIB %1:>NUL
copy DEBUG.OBJ %1:>NUL
copy MEMO.LIB %1:>NUL
echo -
echo Insert PLINK86 and UTILITIES disk in drive A:
pause
copy *.prg %1:>NUL
copy PLINK86.EXE %1:>NUL
copy OVERLAY.LIB %1:>NUL
copy CREATE.EXE %1:>NUL
copy LABEL.EXE %1:>NUL
copy REPORT.EXE %1:>NUL
echo ******* Installation procedure complete. *******
echo -                   
echo You have now installed a working copy of the Clipper compiler.  
echo You may use the DOS "COPY" command to copy other files on the
echo distribution diskette.  
echo -
pause 
%1:
dir
goto end
:help1
echo -
echo ***** No drive letter specified - CLIPCOPY terminated.
goto End
:End
