#Requires -Version 5.1
<#
.SYNOPSIS
    OpenCode PRO - Single PowerShell Installer for Windows.
.DESCRIPTION
    Installs OpenCode AI editor with the PRO configuration.
    - No backup of existing installations (they are deleted directly).
    - Installs opencode-ai globally via npm.
    - Copies the bundled config/ directory to ~\.config\opencode.
    - Installs plugin dependencies, MCP servers and LSP servers globally.
    - Prompts for OpenCode Zen, OpenCode Go and GitHub API keys.
    - Verifies the installation.
    Use -DryRun to simulate without making any changes.
.PARAMETER DryRun
    Simulate the installation without deleting, installing or writing files.
.PARAMETER Force
    Skip interactive confirmations (API keys are still prompted unless -DryRun).
.PARAMETER SkipClean
    Skip deletion of existing OpenCode directories.
.PARAMETER Offline
    Use only the local config/ folder; do not download from GitHub.
.PARAMETER RepoUrl
    Repository URL to download config from when running online.
.NOTES
    Author: Francesco Castaldi
    Repo:   https://github.com/FrancescoCastaldi/opencode-pro-setup
    Version: 3.0.0
    Usage:  powershell -ExecutionPolicy Bypass -File install.ps1
#>

param(
    [switch]$DryRun,
    [switch]$Force,
    [switch]$SkipClean,
    [switch]$Offline,
    [string]$RepoUrl = "https://github.com/FrancescoCastaldi/opencode-pro-setup"
)

# ============================================================
# AUTO-ELEVATION
# ============================================================
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "  [INFO] Requesting administrator privileges..." -ForegroundColor Cyan
    $argList = @()
    if ($DryRun) { $argList += "-DryRun" }
    if ($Force) { $argList += "-Force" }
    if ($SkipClean) { $argList += "-SkipClean" }
    if ($Offline) { $argList += "-Offline" }
    if ($RepoUrl -ne "https://github.com/FrancescoCastaldi/opencode-pro-setup") { $argList += "-RepoUrl `"$RepoUrl`"" }
    Start-Process powershell -Verb runAs -ArgumentList @("-NoProfile", "-ExecutionPolicy", "Bypass", "-File", "`"$PSCommandPath`"") + $argList
    exit
}

$ErrorActionPreference = "Stop"
$Host.UI.RawUI.WindowTitle = "OpenCode PRO Setup for Windows"

# ============================================================
# CONFIGURATION
# ============================================================
$CONFIG_DIR       = "$env:USERPROFILE\.config\opencode"
$OPENCODE_DIR     = "$env:USERPROFILE\.opencode"
$OPENCODE_MEM_DIR = "$env:USERPROFILE\.opencode-mem"
$LOCAL_APP_DIR    = "$env:LOCALAPPDATA\opencode"
$ROAMING_APP_DIR  = "$env:APPDATA\opencode"
$SCRIPT_DIR       = if ($PSCommandPath) { Split-Path -Parent $PSCommandPath } else { Split-Path -Parent ([System.Reflection.Assembly]::GetEntryAssembly().Location) }
$LOCAL_CONFIG_SRC = Join-Path $SCRIPT_DIR "config"
$MIN_NODE_MAJOR   = 18

# ============================================================
# LOGGING
# ============================================================
function Write-Info    { Write-Host "  [INFO] $($args -join ' ')" -ForegroundColor Cyan }
function Write-Ok      { Write-Host "  [OK]   $($args -join ' ')" -ForegroundColor Green }
function Write-Warn    { Write-Host "  [WARN] $($args -join ' ')" -ForegroundColor Yellow }
function Write-Err     { Write-Host "  [ERR]  $($args -join ' ')" -ForegroundColor Red }
function Write-Step    { Write-Host "`n  => $($args -join ' ')" -ForegroundColor Magenta }
function Write-DryRun  { Write-Host "  [DRY]  $($args -join ' ')" -ForegroundColor DarkYellow }

function Show-Progress {
    param([int]$Percent, [string]$Label)
    Write-Progress -Activity "OpenCode PRO Installation" -Status $Label -PercentComplete $Percent
}

function Test-CommandAvailable {
    param([string]$Command)
    $old = $ErrorActionPreference
    $ErrorActionPreference = 'SilentlyContinue'
    try {
        $null = Get-Command $Command -ErrorAction Stop
        return $true
    } catch {
        return $false
    } finally {
        $ErrorActionPreference = $old
    }
}

function Get-NpmGlobalPrefix {
    $prefix = $null
    try { $prefix = (npm config get prefix 2>$null).Trim() } catch {}
    if (-not $prefix) { $prefix = "$env:APPDATA\npm" }
    return $prefix
}

function Add-NpmGlobalToPath {
    $prefix = Get-NpmGlobalPrefix
    if (-not (Test-Path $prefix)) { return }
    $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
    $machinePath = [Environment]::GetEnvironmentVariable("Path", "Machine")
    if ($userPath -notlike "*$prefix*") {
        [Environment]::SetEnvironmentVariable("Path", "$userPath;$prefix", "User")
    }
    $env:Path = "$machinePath;$userPath;$prefix"
}

function Invoke-IfNotDryRun {
    param([scriptblock]$Action, [string]$DryRunMessage)
    if ($DryRun) {
        Write-DryRun $DryRunMessage
        return $null
    }
    return & $Action
}

# ============================================================
# STEP 0: PREREQUISITES
# ============================================================
function Step-Prerequisites {
    Write-Step "STEP 0 - Checking prerequisites"
    Show-Progress -Percent 5 -Label "Checking prerequisites"

    if ($PSVersionTable.PSVersion.Major -lt 5) {
        Write-Err "PowerShell 5.1 or newer is required."
        exit 1
    }

    # Node.js
    $nodeVersion = $null
    try { $nodeVersion = node --version 2>$null } catch {}
    if (-not $nodeVersion) {
        Write-Warn "Node.js was not found."
        $install = $Force
        if (-not $Force) {
            $answer = Read-Host "Install Node.js LTS via winget? (Y/N)"
            $install = ($answer -match '^(Y|y|Yes|yes)$')
        }
        if ($install) {
            Invoke-IfNotDryRun -DryRunMessage "Would install Node.js via winget" -Action {
                try {
                    winget install "OpenJS.NodeJS.LTS" --silent --accept-package-agreements 2>&1 | Out-Null
                    refreshenv 2>$null
                    $env:Path = [Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [Environment]::GetEnvironmentVariable("Path", "User")
                } catch {
                    Write-Err "Failed to install Node.js via winget. Install it manually and re-run."
                    exit 1
                }
            }
        } else {
            Write-Err "Node.js is required. Install it manually and re-run."
            exit 1
        }
    }

    try { $nodeVersion = node --version 2>$null } catch {}
    if (-not $nodeVersion) {
        Write-Err "Node.js is still not available after installation attempt."
        exit 1
    }
    Write-Ok "Node.js $nodeVersion"

    # npm
    $npmVersion = $null
    try { $npmVersion = npm --version 2>$null } catch {}
    if (-not $npmVersion) {
        Write-Err "npm is required but was not found."
        exit 1
    }
    Write-Ok "npm v$npmVersion"

    Add-NpmGlobalToPath
    Show-Progress -Percent 10 -Label "Prerequisites OK"
}

# ============================================================
# STEP 1: CLEAN EXISTING INSTALLATION
# ============================================================
function Step-Clean {
    param([array]$ExistingDirs)
    Write-Step "STEP 1 - Cleaning existing OpenCode installation"
    Show-Progress -Percent 20 -Label "Cleaning existing installation"

    if ($SkipClean) {
        Write-Info "Skipping cleanup because -SkipClean was specified."
        return
    }

    $doClean = $Force
    if (-not $Force -and -not $DryRun) {
        $response = Read-Host "Delete existing OpenCode config and data directories? (Y/N) [Y]"
        $doClean = ($response -eq "" -or $response -match '^(Y|y|Yes|yes)$')
    }
    if (-not $doClean -and -not $DryRun) {
        Write-Info "Skipping cleanup."
        return
    }

    # Kill running processes
    $procs = Get-Process -Name "*opencode*" -ErrorAction SilentlyContinue
    if ($procs) {
        Invoke-IfNotDryRun -DryRunMessage "Would stop running opencode processes" -Action {
            $procs | Stop-Process -Force -ErrorAction SilentlyContinue
            Start-Sleep -Seconds 2
        }
    }

    # Uninstall global npm package
    if (Test-CommandAvailable "npm") {
        $npmGlobal = $null
        try { $npmGlobal = npm list -g --depth=0 2>$null | Select-String "opencode" } catch {}
        if ($npmGlobal) {
            Invoke-IfNotDryRun -DryRunMessage "Would uninstall npm global opencode-ai" -Action {
                npm uninstall -g opencode-ai 2>&1 | Out-Null
                Write-Ok "Uninstalled global opencode-ai"
            }
        }
    }

    # Remove directories
    foreach ($d in $ExistingDirs) {
        if (Test-Path $d) {
            Invoke-IfNotDryRun -DryRunMessage "Would delete directory: $d" -Action {
                try {
                    Remove-Item -Path $d -Recurse -Force -ErrorAction SilentlyContinue
                    Write-Ok "Removed: $d"
                } catch {
                    Write-Warn "Could not remove $d : $_"
                }
            }
        }
    }

    Show-Progress -Percent 30 -Label "Cleanup done"
}

# ============================================================
# STEP 2: INSTALL OPENCODE AI
# ============================================================
function Step-InstallOpenCode {
    Write-Step "STEP 2 - Installing OpenCode AI"
    Show-Progress -Percent 35 -Label "Installing OpenCode"

    $installed = $false
    try {
        $ver = opencode --version 2>$null
        if ($ver) { $installed = $true; Write-Ok "opencode-ai already available (v$ver)" }
    } catch {}

    if (-not $installed) {
        Invoke-IfNotDryRun -DryRunMessage "Would install opencode-ai globally" -Action {
            $output = npm install -g --no-fund --no-audit opencode-ai@latest 2>&1
            if ($LASTEXITCODE -ne 0) {
                Write-Warn "Retrying opencode-ai installation with --force..."
                $output = npm install -g --no-fund --no-audit --force opencode-ai@latest 2>&1
            }
            if ($LASTEXITCODE -ne 0) {
                Write-Err "Failed to install opencode-ai. Error: $output"
                exit 1
            }
            Add-NpmGlobalToPath
            Write-Ok "opencode-ai installed globally"
        }
    }

    # Verify
    $version = $null
    try { $version = opencode --version 2>$null } catch {}
    if (-not $version) {
        Add-NpmGlobalToPath
        try { $version = opencode --version 2>$null } catch {}
    }
    if ($version) {
        Write-Ok "OpenCode CLI: v$version"
    } else {
        Write-Warn "OpenCode CLI version could not be verified."
    }

    Show-Progress -Percent 40 -Label "OpenCode installed"
}

# ============================================================
# STEP 3: CREATE DIRECTORY STRUCTURE
# ============================================================
function Step-CreateDirectories {
    Write-Step "STEP 3 - Creating directory structure"
    Show-Progress -Percent 45 -Label "Creating directories"

    $subDirs = @('agents', 'plugins', 'skills', 'snippet', 'memory', 'commands')
    foreach ($sub in $subDirs) {
        $path = Join-Path $CONFIG_DIR $sub
        Invoke-IfNotDryRun -DryRunMessage "Would create directory: $path" -Action {
            if (-not (Test-Path $path)) {
                New-Item -ItemType Directory -Path $path -Force | Out-Null
                Write-Ok "Created: $path"
            }
        }
    }

    foreach ($d in @($OPENCODE_DIR, $OPENCODE_MEM_DIR)) {
        Invoke-IfNotDryRun -DryRunMessage "Would create directory: $d" -Action {
            if (-not (Test-Path $d)) {
                New-Item -ItemType Directory -Path $d -Force | Out-Null
            }
        }
    }

    Show-Progress -Percent 50 -Label "Directories ready"
}

# ============================================================
# STEP 4: DEPLOY CONFIGURATION
# ============================================================
function Step-DeployConfiguration {
    Write-Step "STEP 4 - Deploying PRO configuration"
    Show-Progress -Percent 55 -Label "Deploying configuration"

    $configSource = $null

    if (-not $Offline -and (Test-Path $LOCAL_CONFIG_SRC)) {
        $configSource = $LOCAL_CONFIG_SRC
        Write-Info "Using local config from: $configSource"
    }

    if (-not $configSource -and -not $Offline) {
        Invoke-IfNotDryRun -DryRunMessage "Would download configuration from $RepoUrl" -Action {
            $tmpZip = "$env:TEMP\opencode-config.zip"
            $tmpExtract = "$env:TEMP\opencode-config-extracted"
            if (Test-Path $tmpExtract) { Remove-Item -Path $tmpExtract -Recurse -Force }
            if (Test-Path $tmpZip) { Remove-Item -Path $tmpZip -Force }

            Invoke-WebRequest -Uri "$RepoUrl/archive/main.zip" -OutFile $tmpZip -UseBasicParsing
            Expand-Archive -Path $tmpZip -DestinationPath $tmpExtract -Force
            $repoRoot = Get-ChildItem "$tmpExtract\*" -Directory | Select-Object -First 1
            $configSource = Join-Path $repoRoot.FullName "config"
            if (-not (Test-Path $configSource)) {
                throw "Config directory not found in downloaded archive"
            }
            Write-Ok "Configuration downloaded"
        }
    }

    if (-not $configSource) {
        Write-Err "No configuration source available. Run without -Offline or place a 'config' folder next to install.ps1."
        exit 1
    }

    Invoke-IfNotDryRun -DryRunMessage "Would copy '$configSource' to '$CONFIG_DIR'" -Action {
        if (-not (Test-Path $CONFIG_DIR)) {
            New-Item -ItemType Directory -Path $CONFIG_DIR -Force | Out-Null
        }
        # Copy all except any secrets that might have slipped into the repo
        Copy-Item -Path "$configSource\*" -Destination $CONFIG_DIR -Recurse -Force -Exclude @('.env', '.github-token')
        Write-Ok "Configuration deployed to $CONFIG_DIR"
    }

    Show-Progress -Percent 70 -Label "Configuration deployed"
}

# ============================================================
# STEP 5: INSTALL PLUGIN DEPENDENCIES
# ============================================================
function Step-InstallPluginDependencies {
    Write-Step "STEP 5 - Installing plugin dependencies"
    Show-Progress -Percent 75 -Label "Installing plugin dependencies"

    Invoke-IfNotDryRun -DryRunMessage "Would run npm install in $CONFIG_DIR" -Action {
        Push-Location $CONFIG_DIR
        try {
            $output = npm install --no-fund --no-audit 2>&1
            if ($LASTEXITCODE -ne 0) {
                Write-Warn "npm install returned a non-zero exit code. Output: $output"
            } else {
                Write-Ok "Plugin dependencies installed"
            }
        } catch {
            Write-Warn "npm install failed: $_"
        } finally {
            Pop-Location
        }
    }

    Show-Progress -Percent 80 -Label "Plugin dependencies installed"
}

# ============================================================
# STEP 6: INSTALL MCP SERVERS AND LSP SERVERS
# ============================================================
function Step-InstallGlobalPackages {
    Write-Step "STEP 6 - Installing MCP servers and LSP servers globally"
    Show-Progress -Percent 85 -Label "Installing MCP/LSP servers"

    $mcpPackages = @(
        "@modelcontextprotocol/server-filesystem",
        "@playwright/mcp",
        "@modelcontextprotocol/server-github",
        "@modelcontextprotocol/server-puppeteer",
        "@negokaz/excel-mcp-server",
        "opencode-mcp",
        "html-extractor-mcp",
        "@modelcontextprotocol/server-sequential-thinking",
        "@modelcontextprotocol/server-memory"
    )

    $lspPackages = @(
        "typescript-language-server",
        "vscode-langservers-extracted",
        "yaml-language-server"
    )

    Install-GlobalPackages -Name "MCP server" -Packages $mcpPackages
    Install-GlobalPackages -Name "LSP server" -Packages $lspPackages

    # Playwright browser binaries
    Invoke-IfNotDryRun -DryRunMessage "Would install Playwright Chromium browser" -Action {
        try {
            $output = npx -y playwright install chromium 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-Ok "Playwright Chromium browser installed"
            } else {
                Write-Warn "Playwright browser install returned a non-zero exit code."
            }
        } catch {
            Write-Warn "Playwright browser install failed: $_"
        }
    }

    Show-Progress -Percent 90 -Label "MCP/LSP servers installed"
}

function Install-GlobalPackages {
    param([string]$Name, [array]$Packages)

    $prefix = Get-NpmGlobalPrefix
    $globalModules = Join-Path $prefix "node_modules"

    $missing = @()
    foreach ($pkg in $Packages) {
        $modulePath = Join-Path $globalModules $pkg
        if (Test-Path $modulePath) {
            Write-Ok "$pkg already installed"
        } else {
            $missing += $pkg
        }
    }

    if ($missing.Count -eq 0) {
        Write-Info "All $Name packages are already installed."
        return
    }

    Invoke-IfNotDryRun -DryRunMessage "Would install $Name packages globally: $($missing -join ', ')" -Action {
        Write-Info "Installing $Name packages: $($missing -join ', ')"
        $output = npm install -g --no-fund --no-audit @missing 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-Warn "Batch install failed. Retrying packages individually..."
            foreach ($pkg in $missing) {
                $pkgOut = npm install -g --no-fund --no-audit $pkg 2>&1
                if ($LASTEXITCODE -ne 0) {
                    Write-Warn "Could not install $pkg. Output: $pkgOut"
                } else {
                    Write-Ok "$pkg installed"
                }
            }
        } else {
            foreach ($pkg in $missing) { Write-Ok "$pkg installed" }
        }
    }
}

# ============================================================
# STEP 7: CONFIGURE API KEYS
# ============================================================
function Step-ConfigureAPIKeys {
    Write-Step "STEP 7 - Configuring API keys"
    Show-Progress -Percent 92 -Label "Configuring API keys"

    $opencodeZen = $null
    $opencodeGo = $null
    $githubToken = $null

    if (-not $DryRun) {
        $opencodeZen = Read-Host "Enter OpenCode Zen API key (or press Enter to skip)"
        $opencodeGo  = Read-Host "Enter OpenCode Go API key (or press Enter to skip)"
        $githubToken = Read-Host "Enter GitHub Personal Access Token (or press Enter to skip)"
    } else {
        Write-DryRun "Would prompt for OpenCode Zen, OpenCode Go and GitHub API keys"
    }

    if (-not $DryRun) {
        $envLines = @(
            "# OpenCode PRO environment - generated by install.ps1"
        )
        if ($opencodeZen) { $envLines += "OPENCODE_API_KEY=$opencodeZen" }
        if ($opencodeGo)  { $envLines += "OPENCODE_GO_API_KEY=$opencodeGo" }
        if ($githubToken) { $envLines += "GITHUB_TOKEN=$githubToken" }

        $envFile = Join-Path $CONFIG_DIR ".env"
        Set-Content -Path $envFile -Value ($envLines -join "`n") -Force
        Write-Ok "Wrote $envFile"

        # Persist environment variables for the user
        if ($opencodeZen) {
            [Environment]::SetEnvironmentVariable("OPENCODE_API_KEY", $opencodeZen, "User")
            $env:OPENCODE_API_KEY = $opencodeZen
        }
        if ($opencodeGo) {
            [Environment]::SetEnvironmentVariable("OPENCODE_GO_API_KEY", $opencodeGo, "User")
            $env:OPENCODE_GO_API_KEY = $opencodeGo
        }
        if ($githubToken) {
            [Environment]::SetEnvironmentVariable("GITHUB_TOKEN", $githubToken, "User")
            $env:GITHUB_TOKEN = $githubToken
            # Also set the var expected by the GitHub MCP server
            [Environment]::SetEnvironmentVariable("GITHUB_PERSONAL_ACCESS_TOKEN", $githubToken, "User")
            $env:GITHUB_PERSONAL_ACCESS_TOKEN = $githubToken

            $tokenFile = Join-Path $CONFIG_DIR ".github-token"
            Set-Content -Path $tokenFile -Value $githubToken -Force
            Write-Ok "Wrote $tokenFile"
        }

        if (-not $opencodeZen -and -not $opencodeGo -and -not $githubToken) {
            Write-Warn "No API keys were provided. You can configure them later with 'opencode providers add'."
        }
    }

    Show-Progress -Percent 94 -Label "API keys configured"
}

# ============================================================
# STEP 8: CONFIGURE PROVIDERS
# ============================================================
function Step-ConfigureProviders {
    Write-Step "STEP 8 - Configuring OpenCode providers"
    Show-Progress -Percent 96 -Label "Configuring providers"

    if ($DryRun) {
        Write-DryRun "Would add 'opencode' and 'opencode-go' providers if missing"
        return
    }

    if (-not (Test-CommandAvailable "opencode")) {
        Write-Warn "OpenCode CLI not found in PATH. Provider configuration skipped."
        return
    }

    try {
        $providers = opencode providers list 2>$null
    } catch {
        Write-Warn "Could not list providers: $_"
        return
    }

    foreach ($name in @("opencode", "opencode-go")) {
        if ($providers -match $name) {
            Write-Ok "Provider '$name' already configured"
        } else {
            try {
                $output = opencode providers add $name 2>&1
                if ($LASTEXITCODE -eq 0) {
                    Write-Ok "Provider '$name' added"
                } else {
                    Write-Warn "Could not add provider '$name'. Output: $output"
                }
            } catch {
                Write-Warn "Could not add provider '$name': $_"
            }
        }
    }
}

# ============================================================
# STEP 9: VERIFY
# ============================================================
function Step-Verify {
    Write-Step "STEP 9 - Verifying installation"
    Show-Progress -Percent 98 -Label "Verifying installation"

    $allOk = $true
    $report = @()

    $version = $null
    try { $version = opencode --version 2>$null } catch {}
    if ($version) {
        $report += "OpenCode CLI: v$version"
    } else {
        $report += "OpenCode CLI: NOT FOUND"
        $allOk = $false
    }

    if ($DryRun) {
        $report += "Config: would be deployed to $CONFIG_DIR"
    } elseif (Test-Path (Join-Path $CONFIG_DIR "opencode.jsonc")) {
        $report += "Config: opencode.jsonc"
    } elseif (Test-Path (Join-Path $CONFIG_DIR "opencode.json")) {
        $report += "Config: opencode.json"
    } else {
        $report += "Config: MISSING"
        $allOk = $false
    }

    if (Test-Path (Join-Path $CONFIG_DIR "agents\orchestrator.md")) {
        $report += "Agent: orchestrator"
    }

    $pluginCount = @(Get-ChildItem -Path (Join-Path $CONFIG_DIR "plugins") -Filter "*.js" -ErrorAction SilentlyContinue).Count
    if ($pluginCount -gt 0) { $report += "Custom plugins: $pluginCount" }

    $skillCount = @(Get-ChildItem -Path (Join-Path $CONFIG_DIR "skills") -Directory -ErrorAction SilentlyContinue).Count
    if ($skillCount -gt 0) { $report += "Skills: $skillCount" }

    if ($DryRun -or (Test-Path (Join-Path $CONFIG_DIR "node_modules"))) {
        $report += "Plugin deps: installed"
    } else {
        $report += "Plugin deps: MISSING"
        $allOk = $false
    }

    Show-Progress -Percent 100 -Label "Installation complete"

    Write-Host ""
    Write-Host "  ==========================================" -ForegroundColor Green
    Write-Host "   OpenCode PRO - Installation Complete!" -ForegroundColor Green
    Write-Host "  ==========================================" -ForegroundColor Green
    Write-Host ""
    $report | ForEach-Object { Write-Host "    $_" -ForegroundColor White }
    Write-Host ""
    Write-Host "    Run: opencode" -ForegroundColor Green
    Write-Host ""

    if (-not $allOk -and -not $DryRun) {
        Write-Warn "Some verification checks failed."
        exit 1
    }
}

# ============================================================
# MAIN
# ============================================================
try {
    Write-Host ""
    Write-Host "  ==========================================" -ForegroundColor Cyan
    if ($DryRun) {
        Write-Host "   OpenCode PRO - DRY RUN INSTALLER" -ForegroundColor Cyan
    } else {
        Write-Host "   OpenCode PRO - Windows Installer" -ForegroundColor Cyan
    }
    Write-Host "  ==========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Info "Repository: $RepoUrl"
    if ($DryRun)   { Write-Info "Mode: DRY RUN (no changes will be made)" }
    if ($Force)    { Write-Info "Mode: Force (skip confirmations)" }
    if ($SkipClean){ Write-Info "Mode: Skip clean" }
    if ($Offline)  { Write-Info "Mode: Offline (local config only)" }
    Write-Host ""

    $existingDirs = @($CONFIG_DIR, $OPENCODE_DIR, $OPENCODE_MEM_DIR, $LOCAL_APP_DIR, $ROAMING_APP_DIR)

    Step-Prerequisites
    Step-Clean -ExistingDirs $existingDirs
    Step-InstallOpenCode
    Step-CreateDirectories
    Step-DeployConfiguration
    Step-InstallPluginDependencies
    Step-InstallGlobalPackages
    Step-ConfigureAPIKeys
    Step-ConfigureProviders
    Step-Verify

} catch {
    Write-Err "Installation failed!"
    Write-Err "Error: $_"
    Write-Err "Line: $($_.InvocationInfo.ScriptLineNumber)"
    exit 1
}
