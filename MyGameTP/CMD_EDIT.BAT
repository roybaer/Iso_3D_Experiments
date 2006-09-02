@ECHO OFF

:BLOCK1
CLS
ECHO MyGame-Kommandozeileneditor          b:beenden
ECHO ===========================          ---------
ECHO.
ECHO Spielauflîsung
ECHO --------------
ECHO  [1]: 320x200
ECHO  [2]: 640x200
ECHO  [3]: 640x350
ECHO  [4]: 640x400
ECHO  [5]: 640x480
ECHO  [6]: 800x600
ECHO  [7]: 1024x768  (Standard)
ECHO  [8]: 1280x1024
CHOICE /N /C12345678b
IF ERRORLEVEL 9 GOTO ENDE
IF ERRORLEVEL 1 SET MYGAMERES=320x200
IF ERRORLEVEL 2 SET MYGAMERES=640x200
IF ERRORLEVEL 3 SET MYGAMERES=640x350
IF ERRORLEVEL 4 SET MYGAMERES=640x400
IF ERRORLEVEL 5 SET MYGAMERES=640x480
IF ERRORLEVEL 6 SET MYGAMERES=800x600
IF ERRORLEVEL 7 SET MYGAMERES=1024x768
IF ERRORLEVEL 8 SET MYGAMERES=1280x1024
ECHO.
ECHO.
ECHO Auflîsung: %MYGAMERES%

:BLOCK2
CLS
ECHO MyGame-Kommandozeileneditor          b:beenden   z:zurÅck
ECHO ===========================          ---------   --------
ECHO.
ECHO Spielauflîsung                Farbtiefe
ECHO --------------                ---------
ECHO  [1]: 320x200                  [1]: 1Bit-CGA (S/W)
ECHO  [2]: 640x200                  [2]: 4Bit-(S)VGA
ECHO  [3]: 640x350                  [3]: 4Bit-(S)VGA (Grau)
ECHO  [4]: 640x400                  [4]: 8Bit-(S)VGA
ECHO  [5]: 640x480                  [5]: 8Bit-(S)VGA (Grau)
ECHO  [6]: 800x600                  [6]: 15Bit-SVGA
ECHO  [7]: 1024x768  (Standard)     [7]: 16Bit-SVGA  (Standard)
ECHO  [8]: 1280x1024                [8]: 24Bit-SVGA
ECHO.
ECHO.
ECHO Auflîsung: %MYGAMERES%
CHOICE /N /C12345678bz
IF ERRORLEVEL 10 GOTO BLOCK1
IF ERRORLEVEL 9 GOTO ENDE
IF ERRORLEVEL 1 SET MYGAMEC=1bit
IF ERRORLEVEL 2 SET MYGAMEC=4bit
IF ERRORLEVEL 3 SET MYGAMEC=4bit-grey
IF ERRORLEVEL 4 SET MYGAMEC=8bit
IF ERRORLEVEL 5 SET MYGAMEC=8bit-grey
IF ERRORLEVEL 6 SET MYGAMEC=15bit
IF ERRORLEVEL 7 SET MYGAMEC=16bit
IF ERRORLEVEL 8 SET MYGAMEC=24bit
ECHO Farbtiefe: %MYGAMEC%

:BLOCK3
ECHO.
ECHO.
CHOICE /N /Cjnbz "Soll das Spiel mit diesen Einstellungen gestartet werden? [J|N]"
IF ERRORLEVEL 4 GOTO BLOCK2
IF ERRORLEVEL 3 GOTO ENDE
IF ERRORLEVEL 2 GOTO BLOCK1
CLS
MYGAME.EXE %MYGAMERES% %MYGAMEC%

:ENDE
CLS
SET MYGAMERES=
SET MYGAMEC=
ECHO MyGame-Kommandozeileneditor wurde beendet.
