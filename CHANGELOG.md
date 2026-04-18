# Changelog

All notable changes to this project will be documented in this file.

This project starts tracked versioning at `0.2.0`.

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
