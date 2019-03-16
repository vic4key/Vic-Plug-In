@ECHO OFF
SET NAME=APPLYUPDATE

IF EXIST %NAME%.exe DEL %NAME%.exe

G++ -Wl,--subsystem,windows %NAME%.cpp -lCatEngine -lpsapi -o %NAME%.exe
IF EXIST %NAME%.obj DEL %NAME%.obj

UPX %NAME%.exe

BRCC32 -32 %NAME%.rc

CP %NAME%.res .\..\..\Vic.Plug-In.2.xx\

PAUSE
