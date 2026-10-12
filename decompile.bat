@echo off
rem FFdec decompile runner for FarmGame.swf — large heap to avoid the OOM seen in hs_err logs.
setlocal
set JAVA_HOME=%USERPROFILE%\tools\jdk-21
set PATH=%JAVA_HOME%\bin;%PATH%

rem locate java
where java >nul 2>nul
if errorlevel 1 (
  echo [ERROR] java not found on PATH. Install JDK and re-run, or set JAVA_HOME.
  exit /b 1
)
java -version

set SWF=C:\Farmville\xampp\htdocs\public\farmville\embeds\Flash\v855037.855026\FarmGame.855037.855026.swf
set PRELOADER=C:\Farmville\xampp\htdocs\public\farmville\embeds\Flash\v855037.855026\FV_Preloader.swf
set OUT=C:\Users\Remote\Desktop\FV-NG\decompiled

if not exist "%OUT%" mkdir "%OUT%"
if not exist "%OUT%\farmgame" mkdir "%OUT%\farmgame"
if not exist "%OUT%\preloader" mkdir "%OUT%\preloader"

echo.
echo === Dumping ABC/sprite symbol list (fast) ===
java -jar "C:\Program Files (x86)\FFdec\ffdec.jar" -dumpAS3 "%SWF%" > "%OUT%\farmgame_abc_list.txt" 2>nul

echo.
echo === Decompiling FarmGame.swf (this is the big one; watch memory) ===
java -Xmx12g -jar "C:\Program Files (x86)\FFdec\ffdec.jar" ^
  -export script "%OUT%\farmgame" ^
  "%SWF%"

echo.
echo === Decompiling FV_Preloader.swf ===
java -Xmx2g -jar "C:\Program Files (x86)\FFdec\ffdec.jar" ^
  -export script "%OUT%\preloader" ^
  "%PRELOADER%"

echo.
echo === Done. Outputs under: %OUT% ===
dir /s /b "%OUT%\*.as" 2>nul | find /c ".as"
endlocal
