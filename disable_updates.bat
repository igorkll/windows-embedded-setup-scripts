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

set services=wuauserv dosvc UsoSvc ClipSVC edgeupdate edgeupdatem MicrosoftEdgeElevationService ClickToRunSvc WaaSMedicSvc

for %%s in (%services%) do (
    echo Disable and stop %%s...
    net stop %%s 2>nul
    sc config %%s start= disabled 2>nul
)

echo Disable tasks...
schtasks /Change /TN "\Microsoft\Windows\UpdateOrchestrator\" /DISABLE 2>nul
schtasks /Change /TN "\Microsoft\Windows\WindowsUpdate\" /DISABLE 2>nul
schtasks /Change /TN "\Microsoft\EdgeUpdate\" /DISABLE 2>nul

echo Registry modification...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v NoAutoUpdate /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v AUOptions /t REG_DWORD /d 2 /f

pause