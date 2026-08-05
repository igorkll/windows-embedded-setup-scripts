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
schtasks /Change /TN "\Microsoft\Windows\UpdateOrchestrator\" /DISABLE
schtasks /Change /TN "\Microsoft\Windows\WindowsUpdate\" /DISABLE
schtasks /Change /TN "\Microsoft\EdgeUpdate\" /DISABLE
schtasks /Change /TN "\Microsoft\Windows\UpdateOrchestrator\Schedule Scan" /DISABLE
schtasks /Change /TN "\Microsoft\Windows\UpdateOrchestrator\USO_UxBroker" /DISABLE

echo Registry modification...
:: ========== Ветка 1 ==========
:: HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "DisableWindowsUpdateAccess" /t REG_DWORD /d 0x1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "DoNotConnectToWindowsUpdateInternetLocations" /t REG_DWORD /d 0x1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "SetDisableUXWUAccess" /t REG_DWORD /d 0x1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "AUState" /t REG_DWORD /d 0x0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "AUOptions" /t REG_DWORD /d 0x1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "NoAutoUpdate" /t REG_DWORD /d 0x1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "NoAutoRebootWithLoggedOnUsers" /t REG_DWORD /d 0x1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "DeferFeatureUpdates" /t REG_DWORD /d 0x1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "DeferQualityUpdates" /t REG_DWORD /d 0x1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "DeferFeatureUpdatesPeriodInDays" /t REG_DWORD /d 0x165 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "DeferQualityUpdatesPeriodInDays" /t REG_DWORD /d 0x1e /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "BranchReadinessLevel" /t REG_DWORD /d 0x14 /f

:: ========== Ветка 2 ==========
:: HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "DisableWindowsUpdateAccess" /t REG_DWORD /d 0x1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "DoNotConnectToWindowsUpdateInternetLocations" /t REG_DWORD /d 0x1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "SetDisableUXWUAccess" /t REG_DWORD /d 0x1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "AUState" /t REG_DWORD /d 0x0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "AUOptions" /t REG_DWORD /d 0x1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "NoAutoUpdate" /t REG_DWORD /d 0x1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "NoAutoRebootWithLoggedOnUsers" /t REG_DWORD /d 0x1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "DeferFeatureUpdates" /t REG_DWORD /d 0x1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "DeferQualityUpdates" /t REG_DWORD /d 0x1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "DeferFeatureUpdatesPeriodInDays" /t REG_DWORD /d 0x165 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "DeferQualityUpdatesPeriodInDays" /t REG_DWORD /d 0x1e /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "BranchReadinessLevel" /t REG_DWORD /d 0x14 /f

:: ========== Ветка 3 ==========
:: HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update" /v "DisableWindowsUpdateAccess" /t REG_DWORD /d 0x1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update" /v "DoNotConnectToWindowsUpdateInternetLocations" /t REG_DWORD /d 0x1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update" /v "SetDisableUXWUAccess" /t REG_DWORD /d 0x1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update" /v "AUState" /t REG_DWORD /d 0x0 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update" /v "AUOptions" /t REG_DWORD /d 0x1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update" /v "NoAutoUpdate" /t REG_DWORD /d 0x1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update" /v "NoAutoRebootWithLoggedOnUsers" /t REG_DWORD /d 0x1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update" /v "DeferFeatureUpdates" /t REG_DWORD /d 0x1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update" /v "DeferQualityUpdates" /t REG_DWORD /d 0x1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update" /v "DeferFeatureUpdatesPeriodInDays" /t REG_DWORD /d 0x165 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update" /v "DeferQualityUpdatesPeriodInDays" /t REG_DWORD /d 0x1e /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update" /v "BranchReadinessLevel" /t REG_DWORD /d 0x14 /f

:: ========== Ветка 4 ==========
:: HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings
reg add "HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" /v "FlightSettingsMaxPauseDays" /t REG_DWORD /d 0xe42 /f

pause