# WSL-Dev-Startup

![Static Badge](https://img.shields.io/badge/Version-0.2.2-orange)
![Static Badge](https://img.shields.io/badge/Latest_Release-v0.2.2-green)

A PowerShell startup script for a Windows + WSL local development environment. It starts WSL services, rebuilds the Windows hosts file from configured source blocks, imports enabled Apache virtual hosts, and refreshes Windows `netsh interface portproxy` mappings so stable local IPs can forward traffic into WSL.

## What It Does

Each run performs this sequence:

1. Resolve the target WSL distro.
2. Restart configured services inside that distro.
3. Back up the current Windows hosts file.
4. Rebuild the Windows hosts file from the configured header and discovered host-part files.
5. Optionally import enabled Apache `ServerName` and `ServerAlias` values from WSL.
6. Refresh configured portproxy rules.

The hosts file is rebuilt from scratch, but the script now creates a timestamped backup first:

```text
data\backups\hosts-YYYYMMDD-HHMMSS.bak
```

Generated backups are ignored by Git.

## Prerequisites

This project assumes:

* Windows with WSL2 installed.
* A Debian-based WSL distribution. The default config auto-selects your default WSL distro.
* Any services listed in `WSLServices` installed in that WSL distribution.
* An elevated Windows PowerShell session, or a Scheduled Task configured to run with highest privileges.

The script must run elevated because it writes to:

```text
C:\Windows\System32\drivers\etc\hosts
```

and updates Windows portproxy rules with:

```powershell
netsh interface portproxy
```

The script starts WSL services as WSL `root`, so `/etc/sudoers` `NOPASSWD` entries are not required for configured service restart commands.

## Manual Run

Open Windows PowerShell or Command Prompt as Administrator, then run:

```powershell
& "C:\Scripts\WSL-Dev-Startup\WSL-Dev-Startup.cmd"
```

The `.cmd` launcher runs:

```powershell
powershell.exe -NoProfile -ExecutionPolicy RemoteSigned -File WSL-Dev-Startup.ps1 -PauseOnExit
```

Manual runs pause at the end. On success, the script shows a green framed message. On failure, it shows red unframed error text with possible causes and fixes.

## Scheduled Startup

For scheduled startup, call the PowerShell script directly so the task can finish without waiting for a keypress:

```powershell
$action = New-ScheduledTaskAction `
  -Execute "powershell.exe" `
  -Argument '-NoProfile -ExecutionPolicy RemoteSigned -File "C:\Scripts\WSL-Dev-Startup\WSL-Dev-Startup.ps1"' `
  -WorkingDirectory "C:\Scripts\WSL-Dev-Startup"

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
  -Force
```

To update an existing task action:

```powershell
Set-ScheduledTask -TaskPath "\Scripts\" -TaskName "WSL-Dev-Startup" -Action $action
```

To run the task manually:

```powershell
Start-ScheduledTask -TaskPath "\Scripts\" -TaskName "WSL-Dev-Startup"
```

## Configuration

The main config file is:

```text
data\Config.psd1
```

In this repo, that file lives at `assets\data\Config.psd1`. After installation, it lives at `data\Config.psd1` inside the selected install folder.

Upgrade note: older versions fell back to `data\Config.example.psd1`. That fallback has been removed. Existing users must keep a tracked `Config.psd1` in the installable payload or pass `-ConfigPath` to `WSL-Dev-Startup.ps1`.

Keep shared defaults in `Config.psd1`. Put machine-specific settings in a gitignored local override file:

```text
data\Config.local.psd1
```

In the source repo, the local override path is `assets\data\Config.local.psd1`.

When no explicit config path is supplied, the script loads `Config.psd1` first, then overlays any keys from `Config.local.psd1`.

Pass `-ConfigPath` to use a specific config file:

```powershell
.\WSL-Dev-Startup.ps1 -ConfigPath "C:\Scripts\WSL-Dev-Startup\data\Config.psd1"
```

Config preference order:

1. `-ConfigPath`, when provided.
2. `data\Config.psd1` plus `data\Config.local.psd1` overrides, when present.
3. `data\Config.psd1`.

Example `Config.local.psd1`:

```powershell
@{
    WSLDist = "Ubuntu"
    HeaderLocalhost = "HeaderLocalhost.txt"
    ImpHeadMsg = " * Imported HeaderLocalhost.txt to Windows host file. Resuming script in 3 seconds..."
    PortProxies = @(
        @{
            Name = "Apache"
            ListenAddress = "127.65.43.21"
            ListenPort = "80"
            ConnectPort = "80"
        }
    )
}
```

Important values:

* `WSLDist`: WSL distribution name. Leave empty to use the default WSL distro.
* `WSLDistPrompt`: set to `$true` to choose from installed distros each time the script runs.
* `WSLServices`: WSL service names restarted during startup.
* `WinHostsFile`: path to the Windows hosts file.
* `Backups`: folder where timestamped hosts-file backups are written.
* `PauseOnExit`: default pause behavior for direct `.ps1` runs. The `.cmd` launcher also passes `-PauseOnExit`.
* `ImportApacheVHosts`: set to `$true` to add enabled Apache `ServerName` and `ServerAlias` values from WSL.
* `ApacheSitesEnabledPath`: WSL path scanned for enabled Apache vhosts.
* `PortProxies`: configured Windows listen addresses/ports and WSL connect ports.
* `ApacheIP`, `NginxIP`, `MERNIP`, `RailsIP`: stable local listen IPs available for host-part files.
* `HeaderLocalhost`: header file written first during the hosts rebuild.
* `HostParts`: folder scanned for additional `.ps1` and `.txt` host-part files.

### WSL Distro Selection

The default configuration is:

```powershell
WSLDist = ""
WSLDistPrompt = $false
```

With those values, the script uses the default distro reported by WSL. This is the best setting for Scheduled Task startup because it does not wait for input.

To pin the script to a specific distro:

```powershell
WSLDist = "Ubuntu"
WSLDistPrompt = $false
```

To choose from installed distros during manual runs:

```powershell
WSLDist = ""
WSLDistPrompt = $true
```

`WSLDistPrompt` requires an interactive session. Scheduled or non-interactive runs should set `WSLDistPrompt = $false` and either leave `WSLDist` empty to use the default distro or set `WSLDist` explicitly.

Check installed distro names with:

```powershell
wsl -l -v
```

## File Layout

The project root contains:

* `CHANGELOG.md`: release notes.
* `CONTRIBUTING.md`: contribution guidance and upstream-first expectations.
* `HANDOFF.md`: project handoff notes.
* `install.cmd`: double-clickable installer launcher.
* `LICENSE`: GPLv3 license text.
* `README.md`: this documentation.

The `assets` folder contains the installable application payload:

* `install.ps1`: installs WSL-Dev-Startup to a user-selected folder.
* `WSL-Dev-Startup.cmd`: manual launcher that pauses on success/failure.
* `WSL-Dev-Startup.ps1`: main script.

The `assets/data` folder contains:

* `Config.psd1`: main configuration.
* `Config.local.psd1`: optional gitignored local override configuration.
* `host-parts/`: files used to rebuild the Windows hosts file.
* `ui-elements/Colors.ps1`: terminal color variables.
* `backups/`: runtime hosts-file backups. This folder is ignored by Git.

The `assets/modules` folder contains:

* `Utilities/Utilities.psm1`: output styling, progress display, distro selection, and pause handling.
* `WSLServices/WSLServices.psm1`: restarts configured services inside the resolved WSL distro.
* `ImportHosts/ImportHosts.psm1`: backs up, clears, and rebuilds the Windows hosts file.
* `NetConfig/NetConfig.psm1`: detects the current WSL IP and refreshes portproxy mappings.

## Install And Update

Install WSL-Dev-Startup to any folder you use for scripts:

```powershell
.\install.cmd
.\assets\install.ps1 -InstallPath "C:\Scripts\WSL-Dev-Startup"
```

Use `install.cmd` for a double-clickable installer window. The launcher runs `assets\install.ps1` with pause behavior so success and failure messages stay visible.

On Windows, double-clicking `assets\install.ps1` may open it in an editor, depending on file associations. Use `install.cmd` for Explorer-based installs.

If the installer is not already running as administrator, it relaunches itself and shows the normal Windows UAC prompt.

The installer copies files from `assets` to the selected folder, excluding `install.ps1`, generated install helpers, and generated backups. It also builds install-specific `update.ps1` and `uninstall.ps1` helpers in the selected folder. Those helper scripts are generated during installation and are not tracked as repo files.

During installation, the installer can also:

* Create a desktop shortcut to the installed `WSL-Dev-Startup.cmd` launcher. The shortcut is configured to run as administrator.
* Register a `\Scripts\WSL-Dev-Startup` scheduled task that runs at logon with highest privileges.

For non-interactive installs, use switches:

```powershell
.\assets\install.ps1 -InstallPath "C:\Scripts\WSL-Dev-Startup" -CreateDesktopShortcut -RegisterStartupTask
.\assets\install.ps1 -InstallPath "C:\Scripts\WSL-Dev-Startup" -NoDesktopShortcut -NoStartupTask
```

After installation, update from the repo with:

```powershell
C:\Scripts\WSL-Dev-Startup\update.ps1
C:\Scripts\WSL-Dev-Startup\update.ps1 -OverwriteAll
C:\Scripts\WSL-Dev-Startup\update.ps1 -OverwriteAllExceptHostParts
C:\Scripts\WSL-Dev-Startup\update.ps1 -ApproveEachFile
```

When no mode switch is provided, the update script presents three choices: override all files, override all except host-parts, or approve each file one by one. Generated backups are always protected.

To remove installed files:

```powershell
C:\Scripts\WSL-Dev-Startup\uninstall.ps1
```

## Host Parts

The header file configured by `HeaderLocalhost` is always written first.

`assets/data/host-parts/HeaderLocalhost.txt` is tracked by the repo. To avoid merge conflicts, keep project-wide header changes in that file and keep machine-specific banner/header changes out of commits. For local-only branding, copy the header to a different filename, such as `HeaderLocalhost.local.txt`, point `HeaderLocalhost` to that file from `data\Config.local.psd1`, and leave the local copy untracked.

After the header, the script scans the configured `HostParts` folder for `.ps1` and `.txt` files. Each imported file must include a numeric order flag:

```text
# HostPartOrder: 10
```

Files are imported in ascending `HostPartOrder` value. Each order value must be unique; if two files use the same value, the script fails and names the conflicting files.

Only `.ps1` and `.txt` files are imported. The configured header file is skipped during dynamic import so it is not written twice. Enabled Apache vhosts are imported after ordered host parts when `ImportApacheVHosts = $true`.

`.ps1` host-part files define a `$hosts` array. Each object currently uses `Action = 'add'`, plus a `Name` and `IP`. Blank `Name` values can be used for comment/header lines.

When `ImportApacheVHosts` is enabled, the script reads:

```text
ApacheSitesEnabledPath
```

Any enabled Apache `ServerName` or `ServerAlias` values are written to the Windows hosts file using `ApacheIP`. Keep `.ps1` host-part files for manual entries, non-Apache apps, blocked hosts, or names that do not appear in Apache vhost config.

## Network Behavior

`NetConfig.psm1` deletes and recreates the configured `PortProxies` rules each time the script runs. This matters because WSL2 IP addresses can change between sessions.

Each mapping uses:

```powershell
@{
    Name = "Apache"
    ListenAddress = "127.65.43.21"
    ListenPort = "80"
    ConnectPort = "80"
}
```

The default mappings are:

```text
127.65.43.21:80 -> <current WSL IP>:80
127.65.43.22:80 -> <current WSL IP>:81
127.65.43.23:80 -> <current WSL IP>:3000
127.65.43.24:80 -> <current WSL IP>:10524
```

To inspect all portproxy rules:

```powershell
netsh interface portproxy show all
```

To remove all portproxy rules:

```powershell
netsh interface portproxy reset
```

Only use `reset` if you do not need any existing portproxy rules.

## Troubleshooting

If the script exits immediately with an Administrator error, reopen PowerShell or Command Prompt using **Run as administrator**.

If service startup fails, confirm the configured distro exists:

```powershell
wsl -l -v
```

Then check configured services inside WSL:

```powershell
wsl -d <distro> -- service <service-name> status
```

If host writes fail, close editors or security tools that may temporarily lock:

```text
C:\Windows\System32\drivers\etc\hosts
```

If DNS resolution seems stale after a host rebuild:

```powershell
ipconfig /flushdns
```

If portproxy output contains old malformed values such as `System.Collections.Hashtable.ApacheIP`, remove those rules or reset portproxy, then rerun the script.

## Upstream First

Forks are welcome, but this project is healthiest when useful fixes, compatibility updates, and workflow improvements make their way back upstream.

If you improve the script, please open a pull request against the main repository. Keeping improvements centralized helps prevent stale forks and makes the tool better for everyone. See `CONTRIBUTING.md` for contribution notes.

## Notes

Update `Config.local.psd1` for machine-specific configuration and keep shared defaults in `Config.psd1`. In the repo, those files live under `assets\data`; after installation, they live under the selected install folder. Update host-part files to match your local domains, service ports, and desired host blocks.
