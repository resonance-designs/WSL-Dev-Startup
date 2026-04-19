::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: WSL-Dev-Startup Installer
:: Double-clickable launcher for install.ps1.
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

@echo off
Powershell -NoProfile -ExecutionPolicy RemoteSigned -File "%~dp0assets\install.ps1" %* -PauseOnExit
exit /b %ERRORLEVEL%
