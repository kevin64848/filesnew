Set WshShell = CreateObject("WScript.Shell")
tempPath = WshShell.ExpandEnvironmentStrings("%TEMP%")
WshShell.Run tempPath & "\file44.bat", 0, False