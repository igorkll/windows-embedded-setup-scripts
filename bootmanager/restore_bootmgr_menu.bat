@echo off
echo restore_bootmgr_menu.bat

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Administrator rights are required. request...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

bcdedit /deletevalue {bootmgr} displaybootmenu

pause