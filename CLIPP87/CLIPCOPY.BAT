echo off
cls 
type clipcopy.hlp
if "==%1" goto Help1
echo Clipper will be installed to the default directory.  ^C to abort or
pause 
copy read_me.1st %1:>NUL
copy *.exe %1:>NUL
copy cl.bat %1:>NUL
copy cld.bat %1:>NUL
copy debug.obj %1>NUL
copy *.lib %1>NUL
echo -  
echo Insert Disk 2 in drive A:
pause 
copy clipper.lib %1:>NUL
copy me.prg %1:>NUL
copy ndx.OBJ %1:>NUL
echo -  
echo Insert Disk 3 in drive A:
pause
copy dbu*.* %1:>NUL
copy makedbu.bat %1:>NUL
copy rl*.prg %1:>NUL
copy makerl.bat %1:>NUL
copy readme.prg %1:>NUL
copy *.exe %1:>NUL
echo -  
echo Insert Disk 4 in drive A:
pause
copy *.doc %1:>NUL
copy *.obj %1:>NUL
copy *.prg %1:>NUL
copy *.asm %1:>NUL
copy *.c %1:>NUL
copy *.h %1:>NUL
copy *.mac %1:>NUL
copy *.inc %1:>NUL
copy *.exe %1:>NUL
echo ******* Installation procedure complete. *******
echo - 
echo You have now installed a working copy of the Clipper compiler.  
echo -  
%1:
goto end
:help1
echo -  
echo ***** No drive letter specified - CLIPCOPY terminated.
goto End
:End
