@echo off
title OpenCode PRO - Installer
chcp 65001 >nul

:: ============================================================
:: OpenCode PRO - Double-Click Installer for Windows
:: ============================================================
:: Basta fare doppio click su questo file per installare
:: automaticamente OpenCode con configurazione PRO completa.
:: ============================================================

:: Controlla se siamo in admin, altrimenti auto-eleva
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [INFO] Richiedo privilegi di amministratore...
    powershell start-process -FilePath "%~f0" -Verb runAs
    exit /b
)

cd /d "%~dp0"

cls
echo ============================================
echo    OpenCode PRO - Windows Installer
echo    Doppio click setup - configurazione PRO
echo ============================================
echo.
echo Installazione in corso... Attendere.
echo.

:: Lancia il setup PowerShell automatico (senza conferme)
powershell -ExecutionPolicy Bypass -File "%~dp0setup.ps1" -Force

echo.
echo ============================================
if %errorLevel% equ 0 (
    echo Installazione completata con successo!
    echo Puoi chiudere questa finestra.
) else (
    echo Installazione fallita. Controlla i messaggi sopra.
)
echo ============================================
echo.
pause
