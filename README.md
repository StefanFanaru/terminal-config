# GitBash config

Git bash has a default $HOME variable to C:/Users/<user-name>
You want to customize the $HOME variable to a different value. I my case X:
Go to this path
```C:\Program Files\Git\etc\profile.d```
and change the file git-prompt.sh
Add these two lines at the end 
```source /x/CLI/terminal-config/git-bash/.inputrc```
```source /x/CLI/terminal-config/git-bash/.bashrc ```
This will make .bashrc and .inputrc work again even if $HOME is changed.


# Windows terminal
Windows terminal gets it's settings by default here
```%LocalAppData%\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState```
To take the settings from the windows-terminal folder you have to 
delete the LocalState folder and then make a link to the windows-terminal
with this command
```mklink /d "%LocalAppData%\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState" "X:\CLI\terminal-config\windows-terminal"```

# Others
Run env-variables.ps1 to add needed binaries to PATH and to set XDG_CONFIG_HOME for nvim configuration