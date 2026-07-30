@echo off
echo fullrestore_bootui.bat

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Administrator rights are required. request...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

bcdedit /deletevalue {globalsettings} custom:16000067
bcdedit /deletevalue {globalsettings} custom:16000068
bcdedit /deletevalue {globalsettings} custom:16000069
bcdedit /deletevalue {globalsettings} bootuxdisabled

pause