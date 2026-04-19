# Handoff: WSL-Dev-Startup To devcntrl

## Big Picture

This repository currently contains `WSL-Dev-Startup`, a standalone PowerShell utility for Windows + WSL local development environments.

The larger project direction is to fork or evolve this work into a new repo/project named `devcntrl`.

`devcntrl` is intended to become a local development control dashboard. It should provide a graphical interface for installing, configuring, starting, stopping, inspecting, and maintaining local development tooling. The planned stack is:

* Tauri desktop app
* Vue
* Vite
* Material-style UI
* Local command execution layer

The key architectural idea: `devcntrl` should be a UI/orchestration layer over standalone CLI/script projects. The scripts should remain independently useful from PowerShell, shell, or other CLI environments.

In other words:

```text
devcntrl = dashboard + orchestration + local UX
scripts  = standalone engines that can run without devcntrl
```

`WSL-Dev-Startup` is the first script/tooling package to be unified under that larger dashboard.

## Current Repository Role

This repo should remain a usable standalone tool. It should not become tightly coupled to `devcntrl`.

Good future integration points:

* `devcntrl` can call `WSL-Dev-Startup.ps1`.
* `devcntrl` can inspect/edit config files.
* `devcntrl` can render host-part files in a UI.
* `devcntrl` can run sync/install/update actions.
* `devcntrl` can parse command output or, ideally later, consume structured output from scripts.

Avoid:

* Making this script require the Tauri app.
* Moving all business logic into the UI.
* Making config only editable through the GUI.
* Breaking direct PowerShell usage.

## Current State

The repo is on `dev`.

Tracked versioning started at `0.2.0`.

Known release history:

* `v0.2.0`: first tracked release; modernized WSL startup workflow.
* `v0.2.1`: patch release; reliability, docs, PowerShell behavior cleanup.
* `v0.2.2`: dynamic configuration, ordered host parts, and contribution docs.

Current major capabilities:

* Resolves the target WSL distro dynamically or via config.
* Restarts configured WSL services.
* Backs up the Windows hosts file before rewriting it.
* Rebuilds the Windows hosts file from a static header plus dynamic ordered host-part files.
* Imports enabled Apache virtual hosts from WSL.
* Refreshes Windows `netsh interface portproxy` mappings.
* Supports local active config via `data\Config.psd1`.
* Falls back to `data\Config.example.psd1`.

## Important Files

Project root:

* `WSL-Dev-Startup.ps1`: main script entrypoint.
* `WSL-Dev-Startup.cmd`: manual Windows launcher.
* `README.md`: user-facing docs.
* `CHANGELOG.md`: release notes.
* `CONTRIBUTING.md`: upstream-first contribution expectations.
* `LICENSE`: currently GPLv3.
* `HANDOFF.md`: this file.

Config/data:

* `data\Config.example.psd1`: repo template config.
* `data\Config.psd1`: preferred local active config; ignored by Git.
* `data\host-parts\`: host file source parts.
* `data\backups\`: generated Windows hosts backups; ignored by Git.
* `data\ui-elements\Colors.ps1`: terminal color variables.

Modules:

* `modules\Utilities\Utilities.psm1`: output formatting, progress, WSL distro resolution, pause behavior.
* `modules\WSLServices\WSLServices.psm1`: restarts configured WSL services.
* `modules\ImportHosts\ImportHosts.psm1`: hosts backup, clear, rebuild, host-part import, Apache vhost import.
* `modules\NetConfig\NetConfig.psm1`: WSL IP detection and portproxy refresh.

Local install helper:

* `C:\Scripts\sync.ps1`: syncs repo files to `C:\Scripts\WSL-Dev-Startup` while protecting local config, host-parts, and backups by default.

## Configuration Model

The main script now resolves config in this order:

```text
1. -ConfigPath argument, if provided
2. data\Config.psd1, if present
3. data\Config.example.psd1
```

`data\Config.psd1` should be used for local machine-specific settings and is ignored by Git.

Important config keys:

* `WSLDist`: explicit WSL distro name, or empty for default distro.
* `WSLDistPrompt`: interactive distro chooser.
* `WSLServices`: array of WSL service names to restart.
* `WinHostsFile`: Windows hosts file path.
* `Backups`: backup directory path.
* `HostParts`: host-part folder path.
* `HeaderLocalhost`: static header file written first.
* `ImportApacheVHosts`: enables Apache vhost import.
* `ApacheSitesEnabledPath`: WSL path for enabled Apache vhost configs.
* `PortProxies`: configured portproxy mappings.
* `ApacheIP`, `NginxIP`, `MERNIP`, `RailsIP`: stable local IP values still useful inside host-part `.ps1` files.

Example dynamic service config:

```powershell
WSLServices = @(
    "apache2"
    "mysql"
)
```

Example dynamic portproxy config:

```powershell
PortProxies = @(
    @{
        Name = "Apache"
        ListenAddress = "127.65.43.21"
        ListenPort = "80"
        ConnectPort = "80"
    }
)
```

## Host-Part Model

The Windows hosts file is rebuilt from scratch on each run.

Order:

1. Static header configured by `HeaderLocalhost`.
2. Dynamic `.ps1` and `.txt` files in `HostParts`, ordered by `HostPartOrder`.
3. Enabled Apache vhosts, if `ImportApacheVHosts = $true`.

Every non-header `.ps1` and `.txt` host-part file must include:

```text
# HostPartOrder: 10
```

Rules:

* Order value must be numeric.
* Order value must be unique.
* Lower numbers import earlier.
* Missing order flags cause a clear error.
* Duplicate order flags cause a clear error naming the conflicting files.
* `.txt` `HostPartOrder` lines are stripped from generated hosts output.

`.ps1` host-part files define a `$hosts` array:

```powershell
$hosts = @(
    [PSCustomObject]@{Action = 'add'; Name = 'example.local'; IP = $config.ApacheIP}
)
```

Only `Action = 'add'` is currently supported.

## Licensing Direction

Current license: GPLv3.

The intent is:

* anyone can use the project freely
* credit/copyright notices must be preserved
* distributed modifications should remain FOSS

GPLv3 fits that intent better than MIT because GPLv3 is copyleft.

Do not add a license requirement forcing forks to open PRs upstream. That would move away from standard FOSS/open-source norms. Instead, the project now uses an `Upstream First` contribution norm in `CONTRIBUTING.md` and `README.md`.

## devcntrl Integration Vision

`devcntrl` should eventually provide UI surfaces for this script’s responsibilities:

* Pick or detect WSL distro.
* View configured WSL services.
* Start/restart services.
* View/edit `PortProxies`.
* Inspect current `netsh interface portproxy show all`.
* View/edit host-part files.
* Validate `HostPartOrder`.
* Show generated hosts preview.
* Trigger hosts backup/rebuild.
* Show latest backup files.
* Import/discover Apache vhosts.
* Display script run logs and failure hints.

Best future improvement for UI integration:

Add a structured output mode to scripts:

```powershell
.\WSL-Dev-Startup.ps1 -OutputJson
```

or command-specific modes:

```powershell
.\WSL-Dev-Startup.ps1 -ListConfig -OutputJson
.\WSL-Dev-Startup.ps1 -ValidateHostParts -OutputJson
.\WSL-Dev-Startup.ps1 -ShowPortProxies -OutputJson
```

This would let `devcntrl` consume stable JSON instead of parsing human console output.

## Recommended Next Steps For devcntrl

1. Create/fork the new `devcntrl` repo.
2. Keep this repo as a standalone script package.
3. Decide whether `devcntrl` vendors this repo, uses Git submodules/subtrees, downloads releases, or shells out to an installed script path.
4. Start with a Tauri/Vue/Vite app shell.
5. Create a command execution abstraction in the Tauri backend.
6. Add a `WSL-Dev-Startup` integration module that can:
   * locate the installed script
   * run it
   * sync/update it
   * inspect config
   * validate host parts
7. Add structured-output commands to this script repo before building heavy UI around it.
8. Keep CLI-first behavior as a non-negotiable constraint.

## Current Cautions

* The repo and installed copy are intentionally different in places.
* The installed copy at `C:\Scripts\WSL-Dev-Startup` uses local non-example host-part names.
* Do not blindly overwrite installed `data\Config.psd1`, `data\Config.example.psd1`, or `data\host-parts`.
* Use `C:\Scripts\sync.ps1` for syncing repo changes to the local install.
* The sync script protects local config, host-parts, and backups by default.
* If syncing new host-part code, ensure installed non-header host-part files include `HostPartOrder` flags.

## Useful Validation Commands

PowerShell parse check:

```powershell
$files = @(
    "WSL-Dev-Startup.ps1",
    "modules\ImportHosts\ImportHosts.psm1",
    "modules\NetConfig\NetConfig.psm1",
    "modules\WSLServices\WSLServices.psm1",
    "modules\Utilities\Utilities.psm1"
)

foreach ($file in $files) {
    $tokens = $null
    $errors = $null
    [System.Management.Automation.Language.Parser]::ParseFile(
        (Resolve-Path $file),
        [ref]$tokens,
        [ref]$errors
    ) | Out-Null

    if ($errors) {
        $errors | ForEach-Object { $_.Message }
        exit 1
    }
}

"Parse OK"
```

Inspect git status:

```powershell
git status --short --branch
```

Run local install sync:

```powershell
C:\Scripts\sync.ps1
```

Force syncing local config and host-parts only when intentional:

```powershell
C:\Scripts\sync.ps1 -IncludeLocalData
```
