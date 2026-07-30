@echo off
echo disable_boot_messages.bat

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Administrator rights are required. request...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

bcdedit /set {globalsettings} custom:16000068 true

pause