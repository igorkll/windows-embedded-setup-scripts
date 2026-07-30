@echo off
echo bypass_powershell_script_verify.bat

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Administrator rights are required. request...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

powershell -Command "Set-ExecutionPolicy -Scope LocalMachine -ExecutionPolicy Bypass -Force"

pause