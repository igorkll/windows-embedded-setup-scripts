@echo off
echo disable_windows_bootui_and_allow_uefi_logo.bat

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Administrator rights are required. request...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

bcdedit /deletevalue {globalsettings} custom:16000067
bcdedit /deletevalue {globalsettings} custom:16000068
bcdedit /deletevalue {globalsettings} custom:16000069
bcdedit /set {globalsettings} bootuxdisabled true

pause