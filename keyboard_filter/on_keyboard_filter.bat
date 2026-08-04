@echo off
echo on_keyboard_filter.bat

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Administrator rights are required. request...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

sc config MsKeyboardFilter start= auto
net start MsKeyboardFilter

pause