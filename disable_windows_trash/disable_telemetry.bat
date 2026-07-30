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

set services=wuauserv dosvc UsoSvc ClipSVC edgeupdate edgeupdatem MicrosoftEdgeElevationService ClickToRunSvc WaaSMedicSvc

for %%s in (%services%) do (
    echo Disable and stop %%s...
    net stop %%s 2>nul
    sc config %%s start= disabled 2>nul
)

:: ============================================================
:: 1. REGISTRY
:: ============================================================

:: Disable via policies (overrides UI settings)
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f

:: Disable sample submission to SpyNet
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" /v SpyNetReporting /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" /v SubmitSamplesConsent /t REG_DWORD /d 2 /f

:: Disable Intel telemetry (if present)
reg add "HKLM\SYSTEM\CurrentControlSet\Services\IntelTA" /v Start /t REG_DWORD /d 4 /f

:: Disable DiagTrack logger
reg add "HKLM\System\ControlSet001\Control\WMI\AutoLogger\AutoLogger-Diagtrack-Listener" /v Start /t REG_DWORD /d 0 /f

:: ============================================================
:: 2. SERVICES
:: ============================================================

:: Stop and disable telemetry services
sc stop DiagTrack >nul 2>&1
sc config DiagTrack start= disabled

sc stop diagnosticshub.standardcollector.service >nul 2>&1
sc config diagnosticshub.standardcollector.service start= disabled

sc stop WerSvc >nul 2>&1
sc config WerSvc start= disabled

:: ============================================================
:: 3. SCHEDULED TASKS
:: ============================================================

schtasks /Change /TN "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser" /DISABLE
schtasks /Change /TN "\Microsoft\Windows\Application Experience\ProgramDataUpdater" /DISABLE
schtasks /Change /TN "\Microsoft\Windows\Application Experience\AitAgent" /DISABLE
schtasks /Change /TN "\Microsoft\Windows\Application Experience\StartupAppTask" /DISABLE

:: Customer Experience Improvement Program
schtasks /Change /TN "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator" /DISABLE
schtasks /Change /TN "\Microsoft\Windows\Customer Experience Improvement Program\KernelCeipTask" /DISABLE
schtasks /Change /TN "\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip" /DISABLE

:: Disk Diagnostic
schtasks /Change /TN "\Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector" /DISABLE

:: Performance
schtasks /Change /TN "\Microsoft\Windows\Maintenance\WinSAT" /DISABLE
schtasks /Change /TN "\Microsoft\Windows\Power Efficiency Diagnostics\AnalyzeSystem" /DISABLE

:: Error Reporting
schtasks /Change /TN "\Microsoft\Windows\Windows Error Reporting\QueueReporting" /DISABLE

:: Device & Diagnosis
schtasks /Change /TN "\Microsoft\Windows\Device Information\Device" /DISABLE
schtasks /Change /TN "\Microsoft\Windows\Diagnosis\Scheduled" /DISABLE
schtasks /Change /TN "\Microsoft\Windows\RAC\RacTask" /DISABLE
schtasks /Change /TN "\Microsoft\Windows\NetTrace\GatherNetworkInfo" /DISABLE

:: Setup notifications
schtasks /Change /TN "\Microsoft\Windows\Setup\EOSNotify" /DISABLE
schtasks /Change /TN "\Microsoft\Windows\Setup\EOSNotify2" /DISABLE

:: Maps (optional)
schtasks /Change /TN "\Microsoft\Windows\Maps\MapsToastTask" /DISABLE
schtasks /Change /TN "\Microsoft\Windows\Maps\MapsUpdateTask" /DISABLE

:: Speech (optional)
schtasks /Change /TN "\Microsoft\Windows\Speech\SpeechModelDownloadTask" /DISABLE

:: ============================================================
:: 4. FIREWALL RULES
:: ============================================================

:: Remove old rules to avoid duplicates
netsh advfirewall firewall delete rule name="Block Telemetry DiagTrack" >nul 2>&1
netsh advfirewall firewall delete rule name="Block Telemetry CompatTelRunner" >nul 2>&1

:: Block DiagTrack.exe
netsh advfirewall firewall add rule name="Block Telemetry DiagTrack" dir=out program="C:\Windows\System32\DiagTrack.exe" action=block >nul 2>&1
netsh advfirewall firewall add rule name="Block Telemetry DiagTrack" dir=in program="C:\Windows\System32\DiagTrack.exe" action=block >nul 2>&1

:: Block CompatTelRunner.exe
netsh advfirewall firewall add rule name="Block Telemetry CompatTelRunner" dir=out program="C:\Windows\System32\CompatTelRunner.exe" action=block >nul 2>&1
netsh advfirewall firewall add rule name="Block Telemetry CompatTelRunner" dir=in program="C:\Windows\System32\CompatTelRunner.exe" action=block >nul 2>&1

:: ============================================================
:: 5. HOSTS FILE (DNS blocking)
:: ============================================================

:: ============================================================
:: HOSTS FILE - Microsoft Telemetry Blocklist
:: ============================================================

echo. >> %SystemRoot%\System32\drivers\etc\hosts
echo # Microsoft Telemetry and Diagnostics Blocklist >> %SystemRoot%\System32\drivers\etc\hosts

:: Core telemetry (main data collection)
echo 127.0.0.1 vortex.data.microsoft.com >> %SystemRoot%\System32\drivers\etc\hosts
echo 127.0.0.1 vortex-win.data.microsoft.com >> %SystemRoot%\System32\drivers\etc\hosts
echo 127.0.0.1 v10.events.data.microsoft.com >> %SystemRoot%\System32\drivers\etc\hosts
echo 127.0.0.1 v20.events.data.microsoft.com >> %SystemRoot%\System32\drivers\etc\hosts
echo 127.0.0.1 telecommand.telemetry.microsoft.com >> %SystemRoot%\System32\drivers\etc\hosts
echo 127.0.0.1 telemetry.microsoft.com >> %SystemRoot%\System32\drivers\etc\hosts
echo 127.0.0.1 settings-win.data.microsoft.com >> %SystemRoot%\System32\drivers\etc\hosts
echo 127.0.0.1 self.events.data.microsoft.com >> %SystemRoot%\System32\drivers\etc\hosts
echo 127.0.0.1 functional.events.data.microsoft.com >> %SystemRoot%\System32\drivers\etc\hosts

:: Regional & CDN telemetry endpoints
echo 127.0.0.1 de.vortex-win.data.microsoft.com >> %SystemRoot%\System32\drivers\etc\hosts
echo 127.0.0.1 de-v20.events.data.microsoft.com >> %SystemRoot%\System32\drivers\etc\hosts
echo 127.0.0.1 cy2.vortex.data.microsoft.com.akadns.net >> %SystemRoot%\System32\drivers\etc\hosts
echo 127.0.0.1 geo.vortex.data.microsoft.com.akadns.net >> %SystemRoot%\System32\drivers\etc\hosts
echo 127.0.0.1 geo.settings-win.data.microsoft.com.akadns.net >> %SystemRoot%\System32\drivers\etc\hosts
echo 127.0.0.1 db5.settings-win.data.microsoft.com.akadns.net >> %SystemRoot%\System32\drivers\etc\hosts
echo 127.0.0.1 db5.vortex.data.microsoft.com.akadns.net >> %SystemRoot%\System32\drivers\etc\hosts
echo 127.0.0.1 db5-eap.settings-win.data.microsoft.com.akadns.net >> %SystemRoot%\System32\drivers\etc\hosts
echo 127.0.0.1 asimov-win.settings.data.microsoft.com.akadns.net >> %SystemRoot%\System32\drivers\etc\hosts
echo 127.0.0.1 v10-win.vortex.data.microsoft.com.akadns.net >> %SystemRoot%\System32\drivers\etc\hosts

:: Error Reporting (Watson)
echo 127.0.0.1 watson.telemetry.microsoft.com >> %SystemRoot%\System32\drivers\etc\hosts
echo 127.0.0.1 watson.events.data.microsoft.com >> %SystemRoot%\System32\drivers\etc\hosts
echo 127.0.0.1 modern.watson.data.microsoft.com.akadns.net >> %SystemRoot%\System32\drivers\etc\hosts
echo 127.0.0.1 survey.watson.microsoft.com >> %SystemRoot%\System32\drivers\etc\hosts
echo 127.0.0.1 watson.microsoft.com >> %SystemRoot%\System32\drivers\etc\hosts

:: Additional telemetry / SQM
echo 127.0.0.1 sqm.telemetry.microsoft.com >> %SystemRoot%\System32\drivers\etc\hosts
echo 127.0.0.1 oca.telemetry.microsoft.com >> %SystemRoot%\System32\drivers\etc\hosts
echo 127.0.0.1 oca.telemetry.microsoft.us >> %SystemRoot%\System32\drivers\etc\hosts
echo 127.0.0.1 umwatsonc.telemetry.microsoft.us >> %SystemRoot%\System32\drivers\etc\hosts

:: SmartScreen & Defender
echo 127.0.0.1 www.smartscreen.microsoft.com >> %SystemRoot%\System32\drivers\etc\hosts
echo 127.0.0.1 smartscreen.microsoft.com >> %SystemRoot%\System32\drivers\etc\hosts
echo 127.0.0.1 smartscreen-prod.microsoft.com >> %SystemRoot%\System32\drivers\etc\hosts
echo 127.0.0.1 go.microsoft.com >> %SystemRoot%\System32\drivers\etc\hosts
echo 127.0.0.1 wdcp.microsoft.com >> %SystemRoot%\System32\drivers\etc\hosts
echo 127.0.0.1 wdcpalt.microsoft.com >> %SystemRoot%\System32\drivers\etc\hosts

:: Windows Update (blocking updates - optional)
echo 127.0.0.1 www.update.microsoft.com >> %SystemRoot%\System32\drivers\etc\hosts
echo 127.0.0.1 update.microsoft.com >> %SystemRoot%\System32\drivers\etc\hosts
echo 127.0.0.1 windowsupdate.microsoft.com >> %SystemRoot%\System32\drivers\etc\hosts
echo 127.0.0.1 www.windowsupdate.com >> %SystemRoot%\System32\drivers\etc\hosts
echo 127.0.0.1 dl.delivery.mp.microsoft.com >> %SystemRoot%\System32\drivers\etc\hosts
echo 127.0.0.1 delivery.mp.microsoft.com >> %SystemRoot%\System32\drivers\etc\hosts
echo 127.0.0.1 prod.do.dsp.mp.microsoft.com >> %SystemRoot%\System32\drivers\etc\hosts

:: Windows Store telemetry & licensing
echo 127.0.0.1 displaycatalog.mp.microsoft.com >> %SystemRoot%\System32\drivers\etc\hosts
echo 127.0.0.1 licensing.mp.microsoft.com >> %SystemRoot%\System32\drivers\etc\hosts
echo 127.0.0.1 storesdk.dsx.mp.microsoft.com >> %SystemRoot%\System32\drivers\etc\hosts

:: Microsoft Office / 365 telemetry
echo 127.0.0.1 hubblecontent.osi.office.net >> %SystemRoot%\System32\drivers\etc\hosts

echo # End of blocklist >> %SystemRoot%\System32\drivers\etc\hosts

pause