<#
.SYNOPSIS
    Clears the "New" Teams cache for all user profiles on the system.

.DESCRIPTION
    This script forcibly stops any processes named "ms-teams" when the -Force switch is used. It checks the registry to find the location of the Users folder (e.g., C:\Users\), 
    iterates through each user folder, removes the specified folder if it exists, and provides feedback on the status of each removal operation.

.PARAMETER Force
    If specified, forcibly stops the "ms-teams" process.

.NOTES
    File Name: ClearTeamsCacheForAllUsers.ps1
    Author   : Devon
    Version  : 1.0
    Date     : May 8, 2024

#>

[CmdletBinding()]
param (
    [switch]$Force
)

# Function to stop "ms-teams" process with retry logic
function Stop-MSTeamsProcess {
    $retryCount = 0
    $maxRetries = 3
    $retryInterval = 10  # Seconds

    do {
        # Stop any processes named "ms-teams"
        $msTeamsProcesses = Get-Process -Name "ms-teams" -ErrorAction SilentlyContinue

        if ($msTeamsProcesses) {
            if ($Force) {
                # Stop each "ms-teams" process
                $msTeamsProcesses | ForEach-Object {
                    $_ | Stop-Process -Force
                    Write-Host "Process $($_.Name) stopped forcefully."
                }
            } else {
                throw "Microsoft Teams is currently running. Please close Teams or re-run the script with the -Force switch."
            }
        } else {
            Write-Host 'No Microsoft Teams ("ms-teams") process found.'
            return
        }

        # Wait for a while before checking again
        Start-Sleep -Seconds $retryInterval

        # Check if "ms-teams" process still exists
        $msTeamsProcesses = Get-Process -Name "ms-teams" -ErrorAction SilentlyContinue

        $retryCount++
    } while ($msTeamsProcesses -and $retryCount -lt $maxRetries)

    if ($msTeamsProcesses) {
        throw "Failed to stop ms-teams after $maxRetries attempts."
    }
}

# Call function to stop "ms-teams" process with error trapping
try {
    Stop-MSTeamsProcess
} catch {
    Write-Error $_
    exit 1
}

# Check registry to find location of Users folder (e.g., C:\Users\)
$profilesDirectory = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList").ProfilesDirectory

# Get all user folders
$userFolders = Get-ChildItem -Path $profilesDirectory -Directory

# Iterate through each user folder
foreach ($folder in $userFolders) {
    # Build the path to the folder to be removed
    $folderPath = Join-Path -Path $folder.FullName -ChildPath "AppData\Local\Packages\MSTeams_8wekyb3d8bbwe"

    # Check if the folder exists
    if (Test-Path $folderPath -PathType Container) {
        # Remove all items within the folder
        Remove-Item -Path "$folderPath\*" -Recurse -Force

        # Remove the folder itself
        Remove-Item -Path $folderPath -Force
        Write-Host "Folder removed for $($folder.Name)"
    } else {
        Write-Host "Folder not found for $($folder.Name)"
    }
}