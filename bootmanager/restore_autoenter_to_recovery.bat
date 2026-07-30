@echo off
echo restore_autoenter_to_recovery.bat

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Administrator rights are required. request...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

bcdedit /deletevalue {current} bootstatuspolicy

pause