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

echo Apply reg pathes...
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" /v SmartScreenEnabled /t REG_SZ /d "Off" /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v EnableSmartScreen /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v ShellSmartScreenLevel /t REG_SZ /d "Off" /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\AppHost" /v EnableWebContentEvaluation /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\microsoft.microsoftedge_8wekyb3d8bbwe\MicrosoftEdge\PhishingFilter" /v EnabledV9 /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v SmartScreenEnabled /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v PreventSmartScreenPromptOverride /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v PreventSmartScreenPromptOverrideForFiles /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" /v SpyNetReporting /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" /v SubmitSamplesConsent /t REG_DWORD /d 2 /f

pause