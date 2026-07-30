@echo off
echo disable_updates.bat

:: ----------------- get system rights
if "%1"=="--system" goto :system_mode

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Administrator rights are required. request...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

echo Creating scheduled task to run as SYSTEM...
set "SCRIPT_PATH=%~f0"
set "SCRIPT_ARGS=--system"

schtasks /create /tn "TempSysRun" /tr "%SCRIPT_PATH% %SCRIPT_ARGS%" /sc once /st 00:00 /ru SYSTEM /f
if errorlevel 1 (
    echo Failed to create scheduled task.
    exit /b
)

schtasks /run /tn "TempSysRun"
schtasks /delete /tn "TempSysRun" /f

pause
exit /b

:system_mode
:: ----------------- code

echo Disable tasks...
schtasks /Change /TN "\Microsoft\Windows\AppID\SmartScreenSpecific" /DISABLE

pause