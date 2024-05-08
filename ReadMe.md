# Clear Teams Cache For All Users

## Synopsis
Clears the "New" Teams cache for all user profiles on the system.

## Description
This script forcibly stops any processes named "ms-teams" when the -Force switch is used. It checks the registry to find the location of the Users folder (e.g., C:\Users\), iterates through each user folder, removes the specified folder if it exists, and provides feedback on the status of each removal operation.

## Parameters
- **Force**: If specified, forcibly stops the "ms-teams" process.

## Notes
- **File Name**: ClearTeamsCacheForAllUsers.ps1
- **Author**: DPO
- **Version**: 1.0
- **Date**: May 8, 2024

## Usage
```powershell
.\ClearTeamsCacheForAllUsers.ps1 [-Force]
