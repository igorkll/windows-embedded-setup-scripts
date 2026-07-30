@echo off
echo disable_keyboard_filter.bat

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Administrator rights are required. request...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

dism /online /disable-feature /featurename:Client-KeyboardFilter

pause