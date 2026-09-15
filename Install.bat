@echo off
REM XefuAuto - one-click installer
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0Install-XefuAuto.ps1" %*
pause
