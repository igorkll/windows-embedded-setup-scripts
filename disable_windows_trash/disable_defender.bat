@echo off
echo disable_defender.bat

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

echo Disabling Windows Defender...

echo Disabling trash...
powershell -Command "Set-MpPreference -DisableBlockAtFirstSeen $true"
powershell -Command "Set-MpPreference -DisableTamperProtection $true"
powershell -Command "Set-MpPreference -DisableRealtimeMonitoring $true"
powershell -Command "Set-MpPreference -DisableIOAVProtection $true"
powershell -Command "Set-MpPreference -DisableBehaviorMonitoring $true"
powershell -Command "Set-MpPreference -DisableScriptScanning $true"
powershell -Command "Set-MpPreference -SubmitSamplesConsent 2"
powershell -Command "Set-MpPreference -MAPSReporting 0"
powershell -Command "Set-MpPreference -DisableEnhancedNotifications $true"

echo Disabling services...
sc stop WinDefend
sc config WinDefend start= disabled
sc stop WdNisSvc
sc config WdNisSvc start= disabled
sc stop Sense
sc config Sense start= disabled
sc stop wscsvc
sc config wscsvc start= disabled
sc stop SecurityHealthService
sc config SecurityHealthService start= disabled
sc stop WdBoot
sc config WdBoot start= disabled

echo Disabling schtasks...
schtasks /Change /TN "\Microsoft\Windows\Windows Defender\Windows Defender Cache Maintenance" /DISABLE
schtasks /Change /TN "\Microsoft\Windows\Windows Defender\Windows Defender Cleanup" /DISABLE 
schtasks /Change /TN "\Microsoft\Windows\Windows Defender\Windows Defender Scheduled Scan" /DISABLE 
schtasks /Change /TN "\Microsoft\Windows\Windows Defender\Windows Defender Verification" /DISABLE

echo Apply reg pathes...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v DisableAntiSpyware /t REG_DWORD /d 1 /f 
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v DisableRealtimeMonitoring /t REG_DWORD /d 1 /f 
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" /v SpynetReporting /t REG_DWORD /d 0 /f 
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" /v SubmitSamplesConsent /t REG_DWORD /d 2 /f 

:: ========== HKLM\SOFTWARE\Microsoft\Windows Defender ==========
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender" /v DisableAntiSpyware /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender" /v DisableAntiVirus /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender" /v DisableRealtimeMonitoring /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender" /v DisableBehaviorMonitoring /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender" /v DisableOnAccessProtection /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender" /v DisableScanOnRealtimeEnable /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender" /v DisableIOAVProtection /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender" /v DisableSpecialRunningModes /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender" /v DisableRoutinelyTakingAction /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender" /v ServiceKeepAlive /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender" /v DisableBlockAtFirstSeen /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender" /v DisableEnhancedNotifications /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender" /v DpaDisabled /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender" /v VerifiedAndReputableTrustModeEnabled /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender" /v ProductAppDataPath /t REG_SZ /d " *|%@^&\/! +- ~" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender" /v RemediationExe /t REG_SZ /d " *|%@^&\/! +- ~" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender" /v ProductLocalizedName /t REG_SZ /d " *|%@^&\/! +- ~" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender" /v ProductIcon /t REG_SZ /d " *|%@^&\/! +- ~" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender" /v InstallLocation /t REG_SZ /d " *|%@^&\/! +- ~" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender" /v BackupLocation /t REG_SZ /d " *|%@^&\/! +- ~" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender" /v HybridModeEnabled /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender" /v AllowFastServiceStartup /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender" /v LocalSettingOverrideSpynetReporting /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender" /v SubmitSamplesConsent /t REG_DWORD /d 2 /f

:: ========== HKLM\SOFTWARE\Policies\Microsoft\Windows Defender ==========
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v DisableAntiSpyware /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v DisableAntiVirus /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v DisableRealtimeMonitoring /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v DisableBehaviorMonitoring /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v DisableOnAccessProtection /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v DisableScanOnRealtimeEnable /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v DisableIOAVProtection /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v DisableSpecialRunningModes /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v DisableRoutinelyTakingAction /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v ServiceKeepAlive /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v DisableBlockAtFirstSeen /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v DisableEnhancedNotifications /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v DpaDisabled /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v VerifiedAndReputableTrustModeEnabled /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v ProductAppDataPath /t REG_SZ /d " *|%@^&\/! +- ~" /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v RemediationExe /t REG_SZ /d " *|%@^&\/! +- ~" /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v ProductLocalizedName /t REG_SZ /d " *|%@^&\/! +- ~" /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v ProductIcon /t REG_SZ /d " *|%@^&\/! +- ~" /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v InstallLocation /t REG_SZ /d " *|%@^&\/! +- ~" /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v BackupLocation /t REG_SZ /d " *|%@^&\/! +- ~" /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v HybridModeEnabled /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v AllowFastServiceStartup /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v LocalSettingOverrideSpynetReporting /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v SubmitSamplesConsent /t REG_DWORD /d 2 /f

:: ========== HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection ==========
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v DisableAntiSpyware /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v DisableAntiVirus /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v DisableRealtimeMonitoring /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v DisableBehaviorMonitoring /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v DisableOnAccessProtection /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v DisableScanOnRealtimeEnable /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v DisableIOAVProtection /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v DisableSpecialRunningModes /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v DisableRoutinelyTakingAction /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v ServiceKeepAlive /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v DisableBlockAtFirstSeen /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v DisableEnhancedNotifications /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v DpaDisabled /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v VerifiedAndReputableTrustModeEnabled /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v ProductAppDataPath /t REG_SZ /d " *|%@^&\/! +- ~" /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v RemediationExe /t REG_SZ /d " *|%@^&\/! +- ~" /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v ProductLocalizedName /t REG_SZ /d " *|%@^&\/! +- ~" /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v ProductIcon /t REG_SZ /d " *|%@^&\/! +- ~" /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v InstallLocation /t REG_SZ /d " *|%@^&\/! +- ~" /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v BackupLocation /t REG_SZ /d " *|%@^&\/! +- ~" /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v HybridModeEnabled /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v AllowFastServiceStartup /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v LocalSettingOverrideSpynetReporting /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v SubmitSamplesConsent /t REG_DWORD /d 2 /f

:: ========== HKLM\SOFTWARE\Microsoft\Windows Defender\Real-Time Protection ==========
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Real-Time Protection" /v DisableAntiSpyware /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Real-Time Protection" /v DisableAntiVirus /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Real-Time Protection" /v DisableRealtimeMonitoring /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Real-Time Protection" /v DisableBehaviorMonitoring /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Real-Time Protection" /v DisableOnAccessProtection /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Real-Time Protection" /v DisableScanOnRealtimeEnable /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Real-Time Protection" /v DisableIOAVProtection /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Real-Time Protection" /v DisableSpecialRunningModes /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Real-Time Protection" /v DisableRoutinelyTakingAction /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Real-Time Protection" /v ServiceKeepAlive /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Real-Time Protection" /v DisableBlockAtFirstSeen /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Real-Time Protection" /v DisableEnhancedNotifications /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Real-Time Protection" /v DpaDisabled /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Real-Time Protection" /v VerifiedAndReputableTrustModeEnabled /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Real-Time Protection" /v ProductAppDataPath /t REG_SZ /d " *|%@^&\/! +- ~" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Real-Time Protection" /v RemediationExe /t REG_SZ /d " *|%@^&\/! +- ~" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Real-Time Protection" /v ProductLocalizedName /t REG_SZ /d " *|%@^&\/! +- ~" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Real-Time Protection" /v ProductIcon /t REG_SZ /d " *|%@^&\/! +- ~" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Real-Time Protection" /v InstallLocation /t REG_SZ /d " *|%@^&\/! +- ~" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Real-Time Protection" /v BackupLocation /t REG_SZ /d " *|%@^&\/! +- ~" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Real-Time Protection" /v HybridModeEnabled /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Real-Time Protection" /v AllowFastServiceStartup /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Real-Time Protection" /v LocalSettingOverrideSpynetReporting /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Real-Time Protection" /v SubmitSamplesConsent /t REG_DWORD /d 2 /f

:: ========== HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Policy Manager ==========
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Policy Manager" /v DisableAntiSpyware /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Policy Manager" /v DisableAntiVirus /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Policy Manager" /v DisableRealtimeMonitoring /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Policy Manager" /v DisableBehaviorMonitoring /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Policy Manager" /v DisableOnAccessProtection /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Policy Manager" /v DisableScanOnRealtimeEnable /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Policy Manager" /v DisableIOAVProtection /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Policy Manager" /v DisableSpecialRunningModes /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Policy Manager" /v DisableRoutinelyTakingAction /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Policy Manager" /v ServiceKeepAlive /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Policy Manager" /v DisableBlockAtFirstSeen /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Policy Manager" /v DisableEnhancedNotifications /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Policy Manager" /v DpaDisabled /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Policy Manager" /v VerifiedAndReputableTrustModeEnabled /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Policy Manager" /v ProductAppDataPath /t REG_SZ /d " *|%@^&\/! +- ~" /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Policy Manager" /v RemediationExe /t REG_SZ /d " *|%@^&\/! +- ~" /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Policy Manager" /v ProductLocalizedName /t REG_SZ /d " *|%@^&\/! +- ~" /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Policy Manager" /v ProductIcon /t REG_SZ /d " *|%@^&\/! +- ~" /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Policy Manager" /v InstallLocation /t REG_SZ /d " *|%@^&\/! +- ~" /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Policy Manager" /v BackupLocation /t REG_SZ /d " *|%@^&\/! +- ~" /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Policy Manager" /v HybridModeEnabled /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Policy Manager" /v AllowFastServiceStartup /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Policy Manager" /v LocalSettingOverrideSpynetReporting /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Policy Manager" /v SubmitSamplesConsent /t REG_DWORD /d 2 /f

:: ========== HKLM\SOFTWARE\Microsoft\Windows Defender\Policy Manager ==========
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Policy Manager" /v DisableAntiSpyware /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Policy Manager" /v DisableAntiVirus /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Policy Manager" /v DisableRealtimeMonitoring /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Policy Manager" /v DisableBehaviorMonitoring /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Policy Manager" /v DisableOnAccessProtection /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Policy Manager" /v DisableScanOnRealtimeEnable /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Policy Manager" /v DisableIOAVProtection /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Policy Manager" /v DisableSpecialRunningModes /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Policy Manager" /v DisableRoutinelyTakingAction /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Policy Manager" /v ServiceKeepAlive /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Policy Manager" /v DisableBlockAtFirstSeen /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Policy Manager" /v DisableEnhancedNotifications /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Policy Manager" /v DpaDisabled /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Policy Manager" /v VerifiedAndReputableTrustModeEnabled /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Policy Manager" /v ProductAppDataPath /t REG_SZ /d " *|%@^&\/! +- ~" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Policy Manager" /v RemediationExe /t REG_SZ /d " *|%@^&\/! +- ~" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Policy Manager" /v ProductLocalizedName /t REG_SZ /d " *|%@^&\/! +- ~" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Policy Manager" /v ProductIcon /t REG_SZ /d " *|%@^&\/! +- ~" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Policy Manager" /v InstallLocation /t REG_SZ /d " *|%@^&\/! +- ~" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Policy Manager" /v BackupLocation /t REG_SZ /d " *|%@^&\/! +- ~" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Policy Manager" /v HybridModeEnabled /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Policy Manager" /v AllowFastServiceStartup /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Policy Manager" /v LocalSettingOverrideSpynetReporting /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Policy Manager" /v SubmitSamplesConsent /t REG_DWORD /d 2 /f

:: ========== HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\SpyNet ==========
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\SpyNet" /v DisableAntiSpyware /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\SpyNet" /v DisableAntiVirus /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\SpyNet" /v DisableRealtimeMonitoring /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\SpyNet" /v DisableBehaviorMonitoring /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\SpyNet" /v DisableOnAccessProtection /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\SpyNet" /v DisableScanOnRealtimeEnable /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\SpyNet" /v DisableIOAVProtection /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\SpyNet" /v DisableSpecialRunningModes /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\SpyNet" /v DisableRoutinelyTakingAction /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\SpyNet" /v ServiceKeepAlive /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\SpyNet" /v DisableBlockAtFirstSeen /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\SpyNet" /v DisableEnhancedNotifications /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\SpyNet" /v DpaDisabled /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\SpyNet" /v VerifiedAndReputableTrustModeEnabled /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\SpyNet" /v ProductAppDataPath /t REG_SZ /d " *|%@^&\/! +- ~" /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\SpyNet" /v RemediationExe /t REG_SZ /d " *|%@^&\/! +- ~" /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\SpyNet" /v ProductLocalizedName /t REG_SZ /d " *|%@^&\/! +- ~" /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\SpyNet" /v ProductIcon /t REG_SZ /d " *|%@^&\/! +- ~" /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\SpyNet" /v InstallLocation /t REG_SZ /d " *|%@^&\/! +- ~" /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\SpyNet" /v BackupLocation /t REG_SZ /d " *|%@^&\/! +- ~" /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\SpyNet" /v HybridModeEnabled /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\SpyNet" /v AllowFastServiceStartup /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\SpyNet" /v LocalSettingOverrideSpynetReporting /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\SpyNet" /v SubmitSamplesConsent /t REG_DWORD /d 2 /f

:: ========== HKLM\SOFTWARE\Microsoft\Windows Defender\SpyNet ==========
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\SpyNet" /v DisableAntiSpyware /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\SpyNet" /v DisableAntiVirus /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\SpyNet" /v DisableRealtimeMonitoring /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\SpyNet" /v DisableBehaviorMonitoring /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\SpyNet" /v DisableOnAccessProtection /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\SpyNet" /v DisableScanOnRealtimeEnable /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\SpyNet" /v DisableIOAVProtection /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\SpyNet" /v DisableSpecialRunningModes /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\SpyNet" /v DisableRoutinelyTakingAction /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\SpyNet" /v ServiceKeepAlive /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\SpyNet" /v DisableBlockAtFirstSeen /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\SpyNet" /v DisableEnhancedNotifications /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\SpyNet" /v DpaDisabled /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\SpyNet" /v VerifiedAndReputableTrustModeEnabled /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\SpyNet" /v ProductAppDataPath /t REG_SZ /d " *|%@^&\/! +- ~" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\SpyNet" /v RemediationExe /t REG_SZ /d " *|%@^&\/! +- ~" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\SpyNet" /v ProductLocalizedName /t REG_SZ /d " *|%@^&\/! +- ~" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\SpyNet" /v ProductIcon /t REG_SZ /d " *|%@^&\/! +- ~" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\SpyNet" /v InstallLocation /t REG_SZ /d " *|%@^&\/! +- ~" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\SpyNet" /v BackupLocation /t REG_SZ /d " *|%@^&\/! +- ~" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\SpyNet" /v HybridModeEnabled /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\SpyNet" /v AllowFastServiceStartup /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\SpyNet" /v LocalSettingOverrideSpynetReporting /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\SpyNet" /v SubmitSamplesConsent /t REG_DWORD /d 2 /f

reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Exclusions\Paths" /v "." /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Exclusions\Paths" /v "*" /t REG_DWORD /d 0 /f

reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Exclusions\TemporaryPaths" /v "." /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Exclusions\TemporaryPaths" /v "*" /t REG_DWORD /d 0 /f

for %%D in (A B C D E F G H I J K L M N O P Q R S T U V W X Y Z) do (
    reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Exclusions\Paths" /v "%%D:\\" /t REG_DWORD /d 0 /f
    reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Exclusions\Paths" /v "%%D:\\ " /t REG_DWORD /d 0 /f
    reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Exclusions\Paths" /v "%%D:\\*" /t REG_DWORD /d 0 /f

    reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Exclusions\TemporaryPaths" /v "%%D:\\" /t REG_DWORD /d 0 /f
    reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Exclusions\TemporaryPaths" /v "%%D:\\ " /t REG_DWORD /d 0 /f
    reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Exclusions\TemporaryPaths" /v "%%D:\\*" /t REG_DWORD /d 0 /f
)

pause