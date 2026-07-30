@echo off
echo disable_defender.bat

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

echo Disabling Windows Defender...

echo Disabling trash...
powershell -Command "Set-MpPreference -DisableBlockAtFirstSeen $true"
powershell -Command "Set-MpPreference -DisableTamperProtection $true"
powershell -Command "Set-MpPreference -DisableRealtimeMonitoring $true"
powershell -Command "Set-MpPreference -DisableIOAVProtection $true"
powershell -Command "Set-MpPreference -DisableBehaviorMonitoring $true"
powershell -Command "Set-MpPreference -DisableScriptScanning $true"
powershell -Command "Set-MpPreference -SubmitSamplesConsent 2"
powershell -Command "Set-MpPreference -MAPSReporting 0"
powershell -Command "Set-MpPreference -DisableEnhancedNotifications $true"

echo Disabling services...
sc stop WinDefend
sc config WinDefend start= disabled
sc stop WdNisSvc
sc config WdNisSvc start= disabled
sc stop Sense
sc config Sense start= disabled
sc stop wscsvc
sc config wscsvc start= disabled
sc stop SecurityHealthService
sc config SecurityHealthService start= disabled
sc stop WdBoot
sc config WdBoot start= disabled

echo Disabling schtasks...
schtasks /Change /TN "\Microsoft\Windows\Windows Defender\Windows Defender Cache Maintenance" /DISABLE
schtasks /Change /TN "\Microsoft\Windows\Windows Defender\Windows Defender Cleanup" /DISABLE 
schtasks /Change /TN "\Microsoft\Windows\Windows Defender\Windows Defender Scheduled Scan" /DISABLE 
schtasks /Change /TN "\Microsoft\Windows\Windows Defender\Windows Defender Verification" /DISABLE 

echo Apply reg pathes...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v DisableAntiSpyware /t REG_DWORD /d 1 /f 
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v DisableRealtimeMonitoring /t REG_DWORD /d 1 /f 
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" /v SpynetReporting /t REG_DWORD /d 0 /f 
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" /v SubmitSamplesConsent /t REG_DWORD /d 2 /f 

pause