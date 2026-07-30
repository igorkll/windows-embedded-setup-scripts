@echo off
echo disable_exe_from_internet_warning.bat

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Administrator rights are required. request...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:: ----------------- code

reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\Attachments" /v SaveZoneInformation /t REG_DWORD /d 1 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Attachments" /v SaveZoneInformation /t REG_DWORD /d 1 /f

reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\Associations" /v LowRiskFileTypes /t REG_SZ /d ".bat;.exe;.reg;.vbs;.chm;.msi;.js;.cmd" /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Associations" /v LowRiskFileTypes /t REG_SZ /d ".bat;.exe;.reg;.vbs;.chm;.msi;.js;.cmd" /f

reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\Associations" /v ModRiskFileTypes /t REG_SZ /d "" /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Associations" /v ModRiskFileTypes /t REG_SZ /d "" /f

reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\Attachments" /v "DoNotPreserveZoneInformation" /t REG_DWORD /d 1 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Attachments" /v "DoNotPreserveZoneInformation" /t REG_DWORD /d 1 /f

reg add "HKLM\SOFTWARE\Policies\Microsoft\Internet Explorer\Security" /v DisableSecuritySettingsCheck /t REG_DWORD /d 1 /f
reg add "HKCU\SOFTWARE\Policies\Microsoft\Internet Explorer\Security" /v DisableSecuritySettingsCheck /t REG_DWORD /d 1 /f

pause