$currentDirectory = Get-Location
$parentDirectory = Split-Path -Path $currentDirectory -Parent
[System.Environment]::SetEnvironmentVariable('XDG_CONFIG_HOME', $parentDirectory, 'Machine')
