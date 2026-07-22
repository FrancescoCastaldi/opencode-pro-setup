@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul

:: ============================================================
:: OpenCode PRO - Windows launcher for install.ps1
:: ============================================================
:: Right-click this file and select "Run as administrator", or
:: simply double-click it to auto-elevate.
:: ============================================================

net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [INFO] Requesting administrator privileges...
    powershell -Command "Start-Process -FilePath '%~f0' -Verb runAs -ArgumentList '%*'"
    exit /b
)

cd /d "%~dp0"

cls
echo ============================================
echo    OpenCode PRO - Windows Installer
echo ============================================
echo.

:: Pass through any command-line arguments (e.g. -DryRun)
powershell -ExecutionPolicy Bypass -File "%~dp0install.ps1" %*
set EXIT_CODE=%errorLevel%

echo.
echo ============================================
if %EXIT_CODE% equ 0 (
    echo Installation completed successfully.
) else (
    echo Installation failed. Check the messages above.
)
echo ============================================
echo.
pause
exit /b %EXIT_CODE%
