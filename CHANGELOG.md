# Changelog

All notable changes to this project will be documented in this file.

This project starts tracked versioning at `0.2.0`.

## [0.2.2] - 2026-04-19

### Added

* Added dynamic host-part discovery for `.ps1` and `.txt` files in the configured host-parts folder.
* Added `HostPartOrder` flags for dynamic host-part ordering.
* Added support for `Config.psd1` as the preferred local active config, with `Config.example.psd1` as fallback.
* Added configurable WSL service restart lists via `WSLServices`.
* Added configurable portproxy mappings via `PortProxies`.
* Added configurable Apache enabled-sites path via `ApacheSitesEnabledPath`.
* Added `CONTRIBUTING.md` with upstream-first contribution guidance.

### Changed

* Changed hosts rebuild ordering so the configured header is written first, followed by host-part files in ascending `HostPartOrder`.
* Removed static config targets for individual non-header host-part files.
* Changed WSL service startup and portproxy refresh to loop over configured entries instead of hardcoded Apache/MySQL and Apache/Nginx/MERN/Rails assumptions.
* Updated README documentation for dynamic config, ordered host parts, configurable services, configurable portproxy mappings, and upstream-first contribution guidance.

### Fixed

* Fixed dynamic host-part imports to fail clearly when order flags are missing or duplicated.

## [0.2.1] - 2026-04-19

### Added

* No new features.

### Changed

* Updated the manual `.cmd` launcher to use the `RemoteSigned` execution policy.
* Removed an outdated launcher note about hosts-array comments.
* Updated hosts-file writes to use UTF-8 without BOM.
* Updated hosts backup path construction to use `Join-Path`.
* Improved WSL service startup so native command error preference is restored after service commands run.

### Fixed

* Fixed Apache vhost dedupe so existing hosts-file lines with multiple hostnames are detected correctly.
* Fixed an unused `AddWSLHost` parameter and updated its call site.
* Fixed non-interactive WSL distro prompt behavior so scheduled/non-interactive runs fail with a clear configuration message.

## [0.2.0] - 2026-04-18

### Added

* Added automatic Windows hosts file backups before each rebuild.
* Added timestamped backup output under `data/backups`.
* Added dynamic Apache vhost import from enabled WSL Apache configs.
* Added support for Apache `ServerName` and `ServerAlias` discovery.
* Added configurable WSL distro resolution with default-distro auto-detection.
* Added optional installed-distro prompt via `WSLDistPrompt`.
* Added Rails portproxy support with `RailsIP` and `RailsPort`.
* Added manual-run success/failure pause behavior via `-PauseOnExit`.
* Added aligned `[ OK ]` status output.
* Added framed green success output.
* Added red failure output with troubleshooting hints.
* Added `.gitignore` coverage for generated backup files.

### Changed

* Updated manual `.cmd` launcher to pass `-PauseOnExit`.
* Updated Scheduled Task guidance to call `WSL-Dev-Startup.ps1` directly.
* Updated WSL service startup to run commands as WSL `root`.
* Updated host file writes to use explicit file write/append helpers instead of `Add-Content`.
* Updated portproxy creation to validate `netsh` failures.
* Updated WSL service startup to validate `wsl.exe` failures.
* Updated PowerShell module imports to use `-Force`.
* Updated runtime config/color/module values so PowerShell 7 module scope resolves them consistently.
* Updated example host entries to use local development naming.
* Updated README to reflect current behavior and setup.

### Fixed

* Fixed PowerShell 7 module-scope issues that caused missing distro, color, and hosts-path values.
* Fixed malformed portproxy rules using `System.Collections.Hashtable.*` literal values.
* Fixed Redmine/Rails host entries resolving to `0.0.0.0`.
* Fixed Scheduled Task hangs caused by interactive pause behavior.
* Fixed duplicate success confirmation output.
* Fixed uneven `[ OK ]` status alignment.
* Fixed hosts file append failures caused by brittle `Add-Content` behavior.

### Notes

* Generated files under `data/backups` are intentionally local runtime artifacts and should not be committed.
