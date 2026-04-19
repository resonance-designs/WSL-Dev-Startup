param(
    [string]$InstallPath = "",
    [string]$SourceRepo = $PSScriptRoot,
    [switch]$Force,
    [switch]$CreateDesktopShortcut,
    [switch]$NoDesktopShortcut,
    [switch]$RegisterStartupTask,
    [switch]$NoStartupTask,
    [switch]$PauseOnExit
)

#######################################################################################
# WSL-Dev-Startup Installer
#
# Usage:
#   ..\install.cmd
#   .\install.ps1
#   .\install.ps1 -InstallPath "C:\Scripts\WSL-Dev-Startup"
#   .\install.ps1 -InstallPath "D:\DevTools\WSL-Dev-Startup" -Force
#   .\install.ps1 -InstallPath "C:\Scripts\WSL-Dev-Startup" -CreateDesktopShortcut -RegisterStartupTask
#
# This installer copies WSL-Dev-Startup to the selected install folder, excluding this
# installer script, generated install helpers, and generated backups. It then builds
# install-specific update.ps1 and uninstall.ps1 helpers inside the selected folder.
# The installer can also create an elevated desktop shortcut and a highest-privilege
# scheduled startup task for the installed script.
#######################################################################################

$ErrorActionPreference = "Stop"

function Wait-ForInstallerExit($Prompt = "Press Enter to close this window") {
    if ($PauseOnExit) {
        Write-Host ""
        Read-Host $Prompt | Out-Null
    }
}

trap {
    Write-Host ""
    Write-Host "WSL-Dev-Startup installer failed." -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Wait-ForInstallerExit "Press Enter to close this window"
    exit 1
}

function Test-IsAdmin {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]::new($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function ConvertTo-NativeArgument($Value) {
    return '"' + ([string]$Value -replace '"', '\"') + '"'
}

function Get-CurrentPowerShellPath {
    if ($PSVersionTable.PSVersion.Major -ge 6 -and [System.Environment]::ProcessPath) {
        return [System.Environment]::ProcessPath
    }

    return "powershell.exe"
}

function Invoke-SelfElevated {
    $arguments = @(
        "-NoProfile",
        "-ExecutionPolicy",
        "RemoteSigned",
        "-File",
        (ConvertTo-NativeArgument $PSCommandPath),
        "-SourceRepo",
        (ConvertTo-NativeArgument $SourceRepo)
    )

    if (-not [string]::IsNullOrWhiteSpace($InstallPath)) {
        $arguments += @("-InstallPath", (ConvertTo-NativeArgument $InstallPath))
    }

    if ($Force) {
        $arguments += "-Force"
    }

    if ($CreateDesktopShortcut) {
        $arguments += "-CreateDesktopShortcut"
    }

    if ($NoDesktopShortcut) {
        $arguments += "-NoDesktopShortcut"
    }

    if ($RegisterStartupTask) {
        $arguments += "-RegisterStartupTask"
    }

    if ($NoStartupTask) {
        $arguments += "-NoStartupTask"
    }

    if ($PauseOnExit) {
        $arguments += "-PauseOnExit"
    }

    Write-Host "Administrator privileges are required. Requesting elevation..." -ForegroundColor Yellow
    $process = Start-Process -FilePath (Get-CurrentPowerShellPath) -ArgumentList ($arguments -join " ") -WorkingDirectory $PSScriptRoot -Verb RunAs -PassThru -Wait
    exit $process.ExitCode
}

if ($CreateDesktopShortcut -and $NoDesktopShortcut) {
    throw "Choose either -CreateDesktopShortcut or -NoDesktopShortcut, not both."
}

if ($RegisterStartupTask -and $NoStartupTask) {
    throw "Choose either -RegisterStartupTask or -NoStartupTask, not both."
}

if (-not [string]::IsNullOrWhiteSpace($SourceRepo)) {
    $SourceRepo = [System.IO.Path]::GetFullPath($SourceRepo)
}

if (-not [string]::IsNullOrWhiteSpace($InstallPath)) {
    $InstallPath = [System.IO.Path]::GetFullPath($InstallPath)
}

if (-not (Test-IsAdmin)) {
    Invoke-SelfElevated
}

if ([string]::IsNullOrWhiteSpace($InstallPath)) {
    $InstallPath = Read-Host "Install WSL-Dev-Startup to which folder?"
}

if ([string]::IsNullOrWhiteSpace($InstallPath)) {
    throw "InstallPath is required."
}

$SourceRepo = [System.IO.Path]::GetFullPath($SourceRepo)
$InstallPath = [System.IO.Path]::GetFullPath($InstallPath)

if (-not (Test-Path -LiteralPath $SourceRepo -PathType Container)) {
    throw "Source repo directory was not found: $SourceRepo"
}

if (-not (Test-Path -LiteralPath $InstallPath -PathType Container)) {
    New-Item -ItemType Directory -Path $InstallPath -Force | Out-Null
}

if (-not $Force -and (Get-ChildItem -LiteralPath $InstallPath -Force | Select-Object -First 1)) {
    $answer = Read-Host "Install folder is not empty. Continue and overwrite matching files (preserving data\Config.psd1 and data\Config.local.psd1)? [Y]es/[N]o"
    if ($answer.ToLowerInvariant() -notin @("y", "yes")) {
        Write-Host "Installation cancelled." -ForegroundColor Yellow
        exit 1
    }
}

$excludeDirs = @(".git", ".github", "data\backups")
$excludeFiles = @("install.ps1", "install.cmd", "update.ps1", "uninstall.ps1")

function Get-FullPath($Path) {
    return [System.IO.Path]::GetFullPath($Path)
}

function Get-RelativePath($BasePath, $Path) {
    $baseFullPath = Get-FullPath $BasePath
    if (-not $baseFullPath.EndsWith([System.IO.Path]::DirectorySeparatorChar)) {
        $baseFullPath += [System.IO.Path]::DirectorySeparatorChar
    }

    $pathFullPath = Get-FullPath $Path
    $baseUri = New-Object System.Uri($baseFullPath)
    $pathUri = New-Object System.Uri($pathFullPath)

    return [System.Uri]::UnescapeDataString($baseUri.MakeRelativeUri($pathUri).ToString()).Replace("/", "\")
}

function Test-ExcludedPath($RelativePath, $PreserveConfigFiles = $false) {
    if ($excludeFiles -contains $RelativePath) {
        return $true
    }

    if ($PreserveConfigFiles) {
        if ($RelativePath -eq "data\Config.psd1" -or $RelativePath -eq "data\Config.local.psd1") {
            return $true
        }
    }

    foreach ($excludeDir in $excludeDirs) {
        if ($RelativePath -eq $excludeDir -or $RelativePath.StartsWith("$excludeDir\")) {
            return $true
        }
    }

    return $false
}

function ConvertTo-SingleQuotedPowerShellString($Value) {
    return "'" + ($Value -replace "'", "''") + "'"
}

function Read-YesNo($Prompt) {
    while ($true) {
        $answer = Read-Host "$Prompt [Y]es/[N]o"
        switch ($answer.ToLowerInvariant()) {
            "y" { return $true }
            "yes" { return $true }
            "n" { return $false }
            "no" { return $false }
            default { Write-Host "Please enter Y or N." -ForegroundColor Yellow }
        }
    }
}

function Resolve-YesNoOption($YesSwitch, $NoSwitch, $Prompt) {
    if ($YesSwitch) {
        return $true
    }

    if ($NoSwitch) {
        return $false
    }

    return Read-YesNo $Prompt
}

function Set-ShortcutRunAsAdmin($ShortcutPath) {
    $bytes = [System.IO.File]::ReadAllBytes($ShortcutPath)
    if ($bytes.Length -lt 22) {
        throw "Shortcut file is too small to update run-as-admin flag: $ShortcutPath"
    }

    $bytes[21] = $bytes[21] -bor 0x20
    [System.IO.File]::WriteAllBytes($ShortcutPath, $bytes)
}

function New-DesktopShortcut($InstallPath) {
    $cmdPath = Join-Path $InstallPath "WSL-Dev-Startup.cmd"
    if (-not (Test-Path -LiteralPath $cmdPath -PathType Leaf)) {
        throw "Cannot create desktop shortcut because WSL-Dev-Startup.cmd was not found at: $cmdPath"
    }

    $desktopPath = [Environment]::GetFolderPath("Desktop")
    $shortcutPath = Join-Path $desktopPath "WSL-Dev-Startup.lnk"
    $shell = New-Object -ComObject WScript.Shell
    $shortcut = $shell.CreateShortcut($shortcutPath)
    $shortcut.TargetPath = $cmdPath
    $shortcut.WorkingDirectory = $InstallPath
    $shortcut.Description = "Run WSL-Dev-Startup as administrator"
    $shortcut.IconLocation = "$cmdPath,0"
    $shortcut.Save()

    Set-ShortcutRunAsAdmin $shortcutPath
    return $shortcutPath
}

function Register-WSLDevStartupTask($InstallPath) {
    $scriptPath = Join-Path $InstallPath "WSL-Dev-Startup.ps1"
    if (-not (Test-Path -LiteralPath $scriptPath -PathType Leaf)) {
        throw "Cannot register startup task because WSL-Dev-Startup.ps1 was not found at: $scriptPath"
    }

    $action = New-ScheduledTaskAction `
        -Execute "powershell.exe" `
        -Argument "-NoProfile -ExecutionPolicy RemoteSigned -File `"$scriptPath`"" `
        -WorkingDirectory $InstallPath

    $trigger = New-ScheduledTaskTrigger -AtLogOn

    $principal = New-ScheduledTaskPrincipal `
        -UserId $env:USERNAME `
        -LogonType Interactive `
        -RunLevel Highest

    $settings = New-ScheduledTaskSettingsSet `
        -AllowStartIfOnBatteries `
        -DontStopIfGoingOnBatteries `
        -ExecutionTimeLimit (New-TimeSpan -Minutes 30)

    Register-ScheduledTask `
        -TaskPath "\Scripts\" `
        -TaskName "WSL-Dev-Startup" `
        -Action $action `
        -Trigger $trigger `
        -Principal $principal `
        -Settings $settings `
        -Description "Start WSL development services, rebuild hosts, and refresh portproxy mappings." `
        -Force | Out-Null

    return "\Scripts\WSL-Dev-Startup"
}

function New-UpdateScriptContent($SourceRepo, $InstallPath) {
    $template = @'
param(
    [string]$SourceRepo = __SOURCE_REPO__,
    [string]$InstallPath = __INSTALL_PATH__,
    [switch]$OverwriteAll,
    [switch]$OverwriteAllExceptHostParts,
    [switch]$ApproveEachFile
)

#######################################################################################
# WSL-Dev-Startup Update Helper
#
# This generated script updates an installed WSL-Dev-Startup folder from the source
# repo/worktree selected during installation.
#
# Usage:
#   .\update.ps1
#   .\update.ps1 -OverwriteAll
#   .\update.ps1 -OverwriteAllExceptHostParts
#   .\update.ps1 -ApproveEachFile
#
# Sync modes:
#   1. Override All
#      Copy every changed/new project file except generated backups and install helpers.
#   2. Override All Except Host-Parts
#      Copy changed/new files but skip data\host-parts for local host customizations.
#   3. Override File-By-File Approval
#      Prompt before each changed/new file is copied.
#
# Generated backups under data\backups are always protected. The install, update, and
# uninstall helper scripts are generated by install.ps1 and are not copied from the repo.
#######################################################################################

$ErrorActionPreference = "Stop"

function Assert-Directory($Path, $Label) {
    if (-not (Test-Path -LiteralPath $Path -PathType Container)) {
        throw "$Label directory was not found: $Path"
    }
}

Assert-Directory $SourceRepo "Source repo"
Assert-Directory $InstallPath "Install"

$excludeDirs = @(".git", ".github", "data\backups")
$excludeFiles = @("install.ps1", "install.cmd", "update.ps1", "uninstall.ps1")

function Get-FullPath($Path) {
    return [System.IO.Path]::GetFullPath($Path)
}

function Get-RelativePath($BasePath, $Path) {
    $baseFullPath = Get-FullPath $BasePath
    if (-not $baseFullPath.EndsWith([System.IO.Path]::DirectorySeparatorChar)) {
        $baseFullPath += [System.IO.Path]::DirectorySeparatorChar
    }

    $pathFullPath = Get-FullPath $Path
    $baseUri = New-Object System.Uri($baseFullPath)
    $pathUri = New-Object System.Uri($pathFullPath)

    return [System.Uri]::UnescapeDataString($baseUri.MakeRelativeUri($pathUri).ToString()).Replace("/", "\")
}

function Test-ExcludedPath($RelativePath, $ExtraExcludeDirs = @()) {
    if ($excludeFiles -contains $RelativePath) {
        return $true
    }

    $allExcludeDirs = @($excludeDirs) + @($ExtraExcludeDirs)
    foreach ($excludeDir in $allExcludeDirs) {
        if ($RelativePath -eq $excludeDir -or $RelativePath.StartsWith("$excludeDir\")) {
            return $true
        }
    }

    return $false
}

function Test-SameFile($SourceFile, $DestinationFile) {
    if (-not (Test-Path -LiteralPath $DestinationFile -PathType Leaf)) {
        return $false
    }

    $sourceItem = Get-Item -LiteralPath $SourceFile
    $destinationItem = Get-Item -LiteralPath $DestinationFile

    if ($sourceItem.Length -ne $destinationItem.Length) {
        return $false
    }

    return (Get-FileHash -LiteralPath $SourceFile).Hash -eq (Get-FileHash -LiteralPath $DestinationFile).Hash
}

function Confirm-Copy($RelativePath, $DestinationFile) {
    $action = if (Test-Path -LiteralPath $DestinationFile -PathType Leaf) { "Overwrite" } else { "Create" }

    while ($true) {
        $answer = Read-Host "$action '$RelativePath'? [Y]es/[N]o/[A]ll/[Q]uit"
        switch ($answer.ToLowerInvariant()) {
            "y" { return "Yes" }
            "yes" { return "Yes" }
            "n" { return "No" }
            "no" { return "No" }
            "a" { return "All" }
            "all" { return "All" }
            "q" { return "Quit" }
            "quit" { return "Quit" }
            default { Write-Host "Please enter Y, N, A, or Q." -ForegroundColor Yellow }
        }
    }
}

function Select-SyncMode() {
    $selectedModes = @($OverwriteAll, $OverwriteAllExceptHostParts, $ApproveEachFile) | Where-Object { $_ }
    if ($selectedModes.Count -gt 1) {
        throw "Choose only one sync mode: -OverwriteAll, -OverwriteAllExceptHostParts, or -ApproveEachFile."
    }

    if ($OverwriteAll) {
        return "OverwriteAll"
    }

    if ($OverwriteAllExceptHostParts) {
        return "OverwriteAllExceptHostParts"
    }

    if ($ApproveEachFile) {
        return "ApproveEachFile"
    }

    Write-Host ""
    Write-Host "Choose update mode:" -ForegroundColor Cyan
    Write-Host "1. Override All"
    Write-Host "2. Override All Except Host-Parts"
    Write-Host "3. Override File-By-File Approval"

    while ($true) {
        $answer = Read-Host "Select 1, 2, or 3"
        switch ($answer) {
            "1" { return "OverwriteAll" }
            "2" { return "OverwriteAllExceptHostParts" }
            "3" { return "ApproveEachFile" }
            default { Write-Host "Please enter 1, 2, or 3." -ForegroundColor Yellow }
        }
    }
}

$syncMode = Select-SyncMode
$extraExcludeDirs = @()
$copyAll = $false

switch ($syncMode) {
    "OverwriteAll" {
        $copyAll = $true
    }
    "OverwriteAllExceptHostParts" {
        $copyAll = $true
        $extraExcludeDirs += "data\host-parts"
    }
}

$copied = 0
$skipped = 0
$unchanged = 0

Write-Host "Updating WSL-Dev-Startup..." -ForegroundColor Cyan
Write-Host "Source:  $SourceRepo"
Write-Host "Install: $InstallPath"
Write-Host "Protecting generated backups and install helpers. Tracked config and host-parts will be synced unless skipped by mode." -ForegroundColor Yellow

switch ($syncMode) {
    "OverwriteAll" {
        Write-Host "Mode: override all changed files." -ForegroundColor Yellow
    }
    "OverwriteAllExceptHostParts" {
        Write-Host "Mode: override all changed files except data\host-parts." -ForegroundColor Yellow
    }
    "ApproveEachFile" {
        Write-Host "Mode: approve each changed file." -ForegroundColor Yellow
    }
}

foreach ($sourceFile in Get-ChildItem -LiteralPath $SourceRepo -File -Recurse) {
    $relativePath = Get-RelativePath $SourceRepo $sourceFile.FullName
    if (Test-ExcludedPath $relativePath $extraExcludeDirs) {
        continue
    }

    $destinationFile = Join-Path $InstallPath $relativePath
    if (Test-SameFile $sourceFile.FullName $destinationFile) {
        $unchanged++
        continue
    }

    if (-not $copyAll) {
        $decision = Confirm-Copy $relativePath $destinationFile
        switch ($decision) {
            "No" {
                $skipped++
                continue
            }
            "All" {
                $copyAll = $true
            }
            "Quit" {
                Write-Host "Update cancelled." -ForegroundColor Yellow
                Write-Host "Copied: $copied; skipped: $skipped; unchanged: $unchanged"
                exit 1
            }
        }
    }

    $destinationDir = Split-Path -Path $destinationFile -Parent
    if (-not (Test-Path -LiteralPath $destinationDir -PathType Container)) {
        New-Item -ItemType Directory -Path $destinationDir -Force | Out-Null
    }

    Copy-Item -LiteralPath $sourceFile.FullName -Destination $destinationFile -Force
    $copied++
    Write-Host "Updated: $relativePath" -ForegroundColor Green
}

Write-Host "Update completed successfully." -ForegroundColor Green
Write-Host "Copied: $copied; skipped: $skipped; unchanged: $unchanged"
exit 0
'@

    return $template.
        Replace("__SOURCE_REPO__", (ConvertTo-SingleQuotedPowerShellString $SourceRepo)).
        Replace("__INSTALL_PATH__", (ConvertTo-SingleQuotedPowerShellString $InstallPath))
}

Write-Host "Installing WSL-Dev-Startup..." -ForegroundColor Cyan
Write-Host "Source:  $SourceRepo"
Write-Host "Install: $InstallPath"

$isUpgrade = (Get-ChildItem -LiteralPath $InstallPath -Force | Select-Object -First 1) -ne $null
$preserveConfigFiles = $isUpgrade -and -not $Force

$copied = 0
foreach ($sourceFile in Get-ChildItem -LiteralPath $SourceRepo -File -Recurse) {
    $relativePath = Get-RelativePath $SourceRepo $sourceFile.FullName
    if (Test-ExcludedPath $relativePath $preserveConfigFiles) {
        continue
    }

    $destinationFile = Join-Path $InstallPath $relativePath
    $destinationDir = Split-Path -Path $destinationFile -Parent
    if (-not (Test-Path -LiteralPath $destinationDir -PathType Container)) {
        New-Item -ItemType Directory -Path $destinationDir -Force | Out-Null
    }

    Copy-Item -LiteralPath $sourceFile.FullName -Destination $destinationFile -Force
    $copied++
}

$shouldCreateDesktopShortcut = Resolve-YesNoOption $CreateDesktopShortcut $NoDesktopShortcut "Do you want to create a desktop shortcut?"
$shouldRegisterStartupTask = Resolve-YesNoOption $RegisterStartupTask $NoStartupTask "Do you want this to run at login/startup?"

$updatePath = Join-Path $InstallPath "update.ps1"
$updateContent = New-UpdateScriptContent $SourceRepo $InstallPath
Set-Content -LiteralPath $updatePath -Value $updateContent -Encoding UTF8

$uninstallPath = Join-Path $InstallPath "uninstall.ps1"
$quotedInstallPath = ConvertTo-SingleQuotedPowerShellString $InstallPath
$uninstallContent = @"
param(
    [switch]`$Force
)

`$ErrorActionPreference = "Stop"
`$InstallPath = $quotedInstallPath

if (-not (Test-Path -LiteralPath `$InstallPath -PathType Container)) {
    Write-Host "Install folder was not found: `$InstallPath" -ForegroundColor Yellow
    exit 0
}

if (-not `$Force) {
    `$answer = Read-Host "Remove all WSL-Dev-Startup files from '`$InstallPath'? [Y]es/[N]o"
    if (`$answer.ToLowerInvariant() -notin @("y", "yes")) {
        Write-Host "Uninstall cancelled." -ForegroundColor Yellow
        exit 1
    }
}

Get-ChildItem -LiteralPath `$InstallPath -Force | Remove-Item -Recurse -Force

`$shortcutPath = Join-Path ([Environment]::GetFolderPath("Desktop")) "WSL-Dev-Startup.lnk"
if (Test-Path -LiteralPath `$shortcutPath -PathType Leaf) {
    `$expectedTarget = Join-Path `$InstallPath "WSL-Dev-Startup.cmd"
    `$shell = New-Object -ComObject WScript.Shell
    `$shortcut = `$shell.CreateShortcut(`$shortcutPath)
    if (`$shortcut.TargetPath -eq `$expectedTarget) {
        Remove-Item -LiteralPath `$shortcutPath -Force
        Write-Host "Removed desktop shortcut: `$shortcutPath" -ForegroundColor Green
    }
}

try {
    `$task = Get-ScheduledTask -TaskPath "\Scripts\" -TaskName "WSL-Dev-Startup" -ErrorAction SilentlyContinue
    `$expectedScriptPath = Join-Path `$InstallPath "WSL-Dev-Startup.ps1"
    `$taskMatchesInstall = `$false
    if (`$task) {
        foreach (`$action in `$task.Actions) {
            `$arguments = [string]`$action.Arguments
            if (`$arguments.Contains(`$expectedScriptPath)) {
                `$taskMatchesInstall = `$true
            }
        }
    }
    if (`$taskMatchesInstall) {
        Unregister-ScheduledTask -TaskPath "\Scripts\" -TaskName "WSL-Dev-Startup" -Confirm:`$false
        Write-Host "Removed startup task: \Scripts\WSL-Dev-Startup" -ForegroundColor Green
    }
} catch {
    Write-Host "Could not remove startup task automatically: `$(`$_.Exception.Message)" -ForegroundColor Yellow
}

Write-Host "WSL-Dev-Startup files removed from `$InstallPath." -ForegroundColor Green
"@
Set-Content -LiteralPath $uninstallPath -Value $uninstallContent -Encoding UTF8

$shortcutPath = $null
if ($shouldCreateDesktopShortcut) {
    $shortcutPath = New-DesktopShortcut $InstallPath
}

$startupTaskPath = $null
if ($shouldRegisterStartupTask) {
    $startupTaskPath = Register-WSLDevStartupTask $InstallPath
}

Write-Host "Installation completed successfully." -ForegroundColor Green
Write-Host "Copied: $copied"
Write-Host "Update helper: $updatePath"
Write-Host "Uninstall helper: $uninstallPath"
if ($shortcutPath) {
    Write-Host "Desktop shortcut: $shortcutPath"
}
if ($startupTaskPath) {
    Write-Host "Startup task: $startupTaskPath"
}

Wait-ForInstallerExit