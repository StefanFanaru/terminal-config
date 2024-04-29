$existingPath = [System.Environment]::GetEnvironmentVariable('Path', 'User')
$newPath = "$existingPath;X:\CLI\bin\fd"
$newPath = "$newPath;X:\CLI\bin\w64devkit\bin"
$newPath = "$newPath;X:\CLI\bin\nvim\bin"
$newPath = "$newPath;C:\Program Files\7-Zip"
[System.Environment]::SetEnvironmentVariable('Path', $newPath, 'User')


$currentDirectory = Get-Location
$parentDirectory = Split-Path -Path $currentDirectory -Parent
[System.Environment]::SetEnvironmentVariable('XDG_CONFIG_HOME', $parentDirectory, 'Machine')
