<#
.SYNOPSIS
    .
.DESCRIPTION
    The purpose of this script is installing Putty and 7-Zip apps to remote computer
    Source Server name is: SERVER1
    Target Server name is: SERVER2

.PROJECTNAME
    Name of the target project GIBRALTAR TECHNOLOGIES.
.PARAMETER TO TEMP DIRECTORY
    Output file will contain installed applications on pointed machine
    PATH for output is C:/soft/report.txt

.EXAMPLE
    !!! For the running procedures there necessary .exe and .msi files are mandatory
    !!! Also the script included servers.txt where project holder can add new alternate machin names e.g SERVER1, SERVER2, SERVER3...
    !!! In my case I have added remote server as Trusted host on my current PC using:
            winrm set winrm/config/client ‘@{TrustedHosts="SERVER2"}’

.NOTES
    Author: FAKHRI HUSEYNOV
    Date:   27.03.2022
#>

$Servers = Get-Content "C:\listservers\servers.txt"
$MySession = New-PSSession -ComputerName $Servers
$Apps = "C:\soft\7zip.exe", "C:\soft\Putty.msi"
$Report = "C:\soft"
$newPath = "\\$Servers\c$"

Foreach ($Server in $Servers) {
    $MySession | Invoke-Command -ComputerName $Servers -ArgumentList $Servers, $Apps, $newPath -ScriptBlock {
        
        Param ( 
            $Server,
            $Apps,
            $newPath
        )
        
        $destination = Test-Path -Path $newPath\temp
        if ($destination -eq $true) { 
            Write-Host -ForegroundColor  Green "-> Path is existing. Now copying files to ------: $Server" 
        }
        else {
            Write-Host -ForegroundColor  Yellow "-> Creating ---------------: Temp folder for the apps"
            New-Item -ItemType Directory -Name "Temp" -Path $newPath -Force
            Write-Host -ForegroundColor  Yellow "-> Now copying the files to ------------------------: $Server"
        }
    }
    Copy-Item  $Apps $newPath\temp
    Write-Host -ForegroundColor Yellow "-> Installing Applications to ----------------------: $Server "
    Invoke-Command -ComputerName $Servers -ArgumentList $Servers -ScriptBlock { 
        Param(
            $Servers
        )
        Start-Process -Wait -FilePath "C:\Temp\7zip.exe" -ArgumentList "/S"
        Start-Process -Wait -FilePath "C:\Temp\Putty.msi" -ArgumentList "/qn"

        $checkPutty = Get-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName | Select-String Putty
        $check7zip = Get-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName | Select-String 7-Zip

        if ($checkPutty -match "Putty" -and $check7zip -match "7-Zip" ) {
            Write-Host -ForegroundColor Green "-> Congratulaions !!! Applications are installed !!"
            Write-Host -ForegroundColor Yellow "-> Now removing Temp folder from -------------------: $Servers "
        }
        else {
            Write-Host -ForegroundColor Red "-> One or more applications are not matched !!"
        }
        Remove-Item -Path $newPath\Temp -Recurse -Force
        $destination = Test-Path -Path $newPath\temp
        if ($destination -eq $false) {
            Write-Host -ForegroundColor Green "-> Temp folder is removed from the -----------------: $Servers "
        }
        else {
            Write-Host -ForegroundColor Red "-> Temp Folder is still existing "
        }
    }
    Invoke-Command -ComputerName $Servers -ScriptBlock { 
        Get-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName } | Select-String -Pattern "Putty", "7-Zip" | Out-File "$Report\report.txt"
}