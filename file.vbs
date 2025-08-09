Set WshShell = CreateObject("WScript.Shell")
tempPath = WshShell.ExpandEnvironmentStrings("%LocalAppData%")
WshShell.Run tempPath & "\file.bat", 0, False
