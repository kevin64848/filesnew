@echo off
echo Disabling Windows 11 notifications for all users...

:: Disable toast notifications machine-wide
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\PushNotifications" /v ToastEnabled /t REG_DWORD /d 0 /f

:: Optional: suppress Windows tips/hints
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Explorer" /v DisableNotificationCenter /t REG_DWORD /d 1 /f

echo Done! Machine-wide notifications disabled.
echo Restarting system to apply changes...

:: Force restart immediately without waiting for user input
shutdown /r /f /t 0
