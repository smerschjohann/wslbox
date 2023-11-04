
$wslInstallDir = "$(Get-Content env:USERPROFILE)\wsl"
$wslImage = "devbox-fedora-wsl.tar"

#########

# Check if running as administrator

function Get-ScriptDirectory
{
  $Invocation = (Get-Variable MyInvocation -Scope 1).Value
  Split-Path $Invocation.MyCommand.Path
}

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    # Relaunch as an admin
    #$CommandLine = "-File `"" + $MyInvocation.MyCommand.Path + "`" " + $MyInvocation.UnboundArguments
    #Start-Process -FilePath PowerShell.exe -WorkingDirectory $(Get-ScriptDirectory)  -Verb Runas -ArgumentList $CommandLine
    Write-Host "please run with UAC rights."
    exit
}

$console = ([console]::OutputEncoding)
[console]::OutputEncoding = New-Object System.Text.UnicodeEncoding
$wslList = (wsl.exe --list)
[console]::OutputEncoding = $console

if ($wslList -match 'wsl-data') {
    Write-Host "WSL data for /home already exists."
} else {
    Write-Host "WSL data for /home does not exist. And must be created."
    Write-Host "Creating wsl-data distribution from wsl-data.tar"
    
    $importPath = "$wslInstallDir/wsl-data"
	Write-Host "wsl path $importPath"
    wsl.exe --import wsl-data $importPath "./wsl-data.tar"
}

try {
    # Prompt the user for the WSL name
    Write-Host "New WSL distribution will be installed."
    $wslName = Read-Host -Prompt "Please enter the wanted WSL name"

    # Check if the user provided a name
    if (-not $wslName) {
        Write-Output "No WSL name provided. Exiting..."
        exit
    }

    Write-Output "installing as: $wslName"
    $importPath = "$wslInstallDir\$wslName"
	Write-Host "wsl path $importPath"

    wsl.exe --unregister $wslName
    wsl.exe --import $wslName $importPath "$(Get-ScriptDirectory)/$wslImage"
    wsl.exe -d $wslName
    wsl.exe -t $wslName
    Write-Host "Setup complete."
	Write-Host "Please note that the zsh installation might download a few extra script on first start."
    Write-Host "After download you have to exit ones more."
    Write-Host ""
    Write-Host "Enjoy!"
	pause
} catch {
    Write-Output "An error occurred: $_"
    pause
}

