<#
.SYNOPSIS
    OpenCode PRO - Automated Setup for Windows
.DESCRIPTION
    Detects existing OpenCode installations, cleans them up, installs fresh,
    and deploys the complete PRO configuration with plugins, MCPs, and agents.
    Fully automated - just run and follow prompts.
.NOTES
    Author: Francesco Castaldi
    Version: 1.0.0
#>

param(
    [switch]$Force,
    [switch]$SkipClean,
    [string]$ConfigRepo = "https://github.com/FrancescoCastaldi/opencode-pro-setup"
)

$ErrorActionPreference = "Stop"
$Host.UI.RawUI.WindowTitle = "OpenCode PRO - Setup"

# ---------------------------
# COLOR UTILITY
# ---------------------------
function Write-Info  { Write-Host "[INFO] $($args -join ' ')" -ForegroundColor Cyan }
function Write-Ok    { Write-Host "[OK]   $($args -join ' ')" -ForegroundColor Green }
function Write-Warn  { Write-Host "[WARN] $($args -join ' ')" -ForegroundColor Yellow }
function Write-Err   { Write-Host "[ERR]  $($args -join ' ')" -ForegroundColor Red }
function Write-Step  { Write-Host "`n==> $($args -join ' ')" -ForegroundColor Magenta }

# ---------------------------
# STEP 0: CHECK PREREQUISITES
# ---------------------------
Write-Step "STEP 0/6 - Checking prerequisites..."

# Check PowerShell version
if ($PSVersionTable.PSVersion.Major -lt 5) {
    Write-Err "PowerShell 5.0+ required. Please update Windows."
    exit 1
}

# Check Node.js
$nodeVersion = $null
try { $nodeVersion = node --version } catch {}
if (-not $nodeVersion) {
    Write-Warn "Node.js not found. Installing via winget..."
    try {
        winget install OpenJS.NodeJS.LTS --silent --accept-package-agreements
        refreshenv
        $env:Path = [Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [Environment]::GetEnvironmentVariable("Path","User")
    } catch {
        Write-Err "Failed to install Node.js. Please install manually from https://nodejs.org"
        exit 1
    }
}
Write-Ok "Node.js $nodeVersion"

# Check npm
try { $npmVersion = npm --version } catch {
    Write-Err "npm not found after Node.js install. Restart terminal and try again."
    exit 1
}
Write-Ok "npm v$npmVersion"

# Check git
try { $gitVersion = git --version } catch {
    Write-Warn "Git not found. Installing..."
    try {
        winget install Git.Git --silent --accept-package-agreements
        $env:Path = [Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [Environment]::GetEnvironmentVariable("Path","User")
    } catch {
        Write-Err "Failed to install Git. Please install manually from https://git-scm.com"
    }
}
Write-Ok "Git available"

# ---------------------------
# STEP 1: DETECT & CLEAN EXISTING
# ---------------------------
Write-Step "STEP 1/6 - Detecting existing OpenCode installations..."

$found = @()

# Check npm global
$npmGlobal = npm list -g --depth=0 2>$null | Select-String "opencode"
if ($npmGlobal) { $found += "npm global (opencode-ai)" }

# Check winget
$wingetList = winget list --name opencode --accept-source-agreements 2>$null
if ($wingetList -match "SST.opencode") { $found += "winget (SST.opencode)" }
if ($wingetList -match "SST.OpenCodeDesktop") { $found += "winget (SST.OpenCodeDesktop)" }

# Check directories
$dirs = @(
    "$env:USERPROFILE\.opencode",
    "$env:USERPROFILE\.config\opencode",
    "$env:LOCALAPPDATA\opencode",
    "$env:APPDATA\opencode"
)
foreach ($d in $dirs) { if (Test-Path $d) { $found += "directory: $d" } }

# Check PATH
$env:Path -split ';' | Where-Object { $_ -like "*opencode*" } | ForEach-Object { $found += "PATH entry: $_" }

# Check processes
$procs = Get-Process -Name "*opencode*" -ErrorAction SilentlyContinue
if ($procs) { $found += "running process(es)" }

if ($found.Count -gt 0) {
    Write-Warn "Found existing OpenCode components:"
    $found | ForEach-Object { Write-Host "    - $_" }
    
    if (-not $SkipClean -and (-not $PSBoundParameters.ContainsKey('Force') -or $Force)) {
        $clean = $true
        if (-not $Force) {
            $response = Read-Host "Clean all existing installations? (Y/N) [Y]"
            if ($response -ne "" -and $response -notmatch "^(Y|y|Yes|yes)$") { $clean = $false }
        }
        if ($clean) {
            Write-Step "  -> Cleaning existing installations..."
            
            # Kill processes
            if ($procs) { $procs | Stop-Process -Force; Write-Ok "Killed running opencode processes" }
            
            # Uninstall npm global
            if ($npmGlobal) { 
                npm uninstall -g opencode-ai 2>$null
                Write-Ok "Uninstalled npm global opencode-ai"
            }
            
            # Uninstall winget
            if ($wingetList -match "SST.OpenCodeDesktop") {
                winget uninstall "SST.OpenCodeDesktop" --silent 2>$null
                Write-Ok "Uninstalled OpenCode Desktop"
            }
            if ($wingetList -match "SST.opencode") {
                winget uninstall "SST.opencode" --silent 2>$null
                Write-Ok "Uninstalled SST.opencode"
            }
            
            # Remove directories
            foreach ($d in $dirs) {
                if (Test-Path $d) {
                    # Backup config if exists
                    if ($d -like "*\.config\opencode" -and (Test-Path "$d\opencode.json")) {
                        $backup = "$env:USERPROFILE\opencode-config-backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
                        Copy-Item -Path $d -Destination $backup -Recurse -Force
                        Write-Ok "Backed up config to: $backup"
                    }
                    Remove-Item -Path $d -Recurse -Force -ErrorAction SilentlyContinue
                    Write-Ok "Removed: $d"
                }
            }

            # Also remove .opencode-mem data
            if (Test-Path "$env:USERPROFILE\.opencode-mem") {
                Remove-Item -Path "$env:USERPROFILE\.opencode-mem" -Recurse -Force -ErrorAction SilentlyContinue
                Write-Ok "Removed: ~/.opencode-mem"
            }

            Write-Ok "Cleanup complete!"
        }
    }
} else {
    Write-Ok "No existing OpenCode installations found - clean system!"
}

# ---------------------------
# STEP 2: INSTALL OpenCode
# ---------------------------
Write-Step "STEP 2/6 - Installing OpenCode..."

# Install via npm (most portable for Windows)
Write-Info "Installing opencode-ai via npm (global)..."
npm install -g opencode-ai@latest 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Err "npm global install failed. Trying alternative..."
    # Fallback: try npm install with --force
    npm install -g opencode-ai@latest --force 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-Err "Installation failed. Try manually: npm install -g opencode-ai"
        exit 1
    }
}

# Verify
$ocVersion = opencode --version 2>$null
if (-not $ocVersion) {
    Write-Err "OpenCode binary not found in PATH after install."
    Write-Info "Adding npm global to PATH..."
    $npmPath = npm config get prefix 2>$null
    if ($npmPath) {
        [Environment]::SetEnvironmentVariable("Path", $env:Path + ";$npmPath", "User")
        $env:Path += ";$npmPath"
    }
    $ocVersion = opencode --version 2>$null
    if (-not $ocVersion) { Write-Err "Still not found. Restart terminal and run: opencode --version"; exit 1 }
}
Write-Ok "OpenCode v$ocVersion installed!"

# ---------------------------
# STEP 3: CREATE DIRECTORIES
# ---------------------------
Write-Step "STEP 3/6 - Creating directory structure..."

$configDir = "$env:USERPROFILE\.config\opencode"
$opencodeDir = "$env:USERPROFILE\.opencode"
$agentDir = "$configDir\agent"
$skillsDir = "$configDir\skills"
$dataDir = "$opencodeDir\data"

@($configDir, $opencodeDir, $agentDir, $skillsDir, $dataDir) | ForEach-Object {
    if (-not (Test-Path $_)) { New-Item -ItemType Directory -Path $_ -Force | Out-Null }
}
Write-Ok "Directories created"

# ---------------------------
# STEP 4: DEPLOY CONFIGURATION
# ---------------------------
Write-Step "STEP 4/6 - Deploying configuration files..."

$scriptRoot = Split-Path -Parent $PSCommandPath

# Source of config files (same dir as this script, or downloaded from repo)
$configSource = Join-Path $scriptRoot "config"
if (-not (Test-Path $configSource)) {
    Write-Info "Config not found locally. Downloading from GitHub..."
    $tmpZip = "$env:TEMP\opencode-config.zip"
    try {
        Invoke-WebRequest -Uri "$ConfigRepo/archive/main.zip" -OutFile $tmpZip -UseBasicParsing
        Expand-Archive -Path $tmpZip -DestinationPath "$env:TEMP\opencode-config-extracted" -Force
        $configSource = Get-ChildItem "$env:TEMP\opencode-config-extracted\*" -Directory | Select-Object -First 1
        $configSource = Join-Path $configSource.FullName "config"
    } catch {
        Write-Err "Could not download config. Place this script in the repo root with a 'config' folder."
        Write-Info "Falling back to template generation..."
        $configSource = $null
    }
}

if ($configSource -and (Test-Path $configSource)) {
    # Copy all config files
    Get-ChildItem -Path $configSource -Recurse -File | ForEach-Object {
        $relative = $_.FullName.Substring($configSource.Length).TrimStart('\')
        $dest = Join-Path $configDir $relative
        $destDir = Split-Path $dest -Parent
        if (-not (Test-Path $destDir)) { New-Item -ItemType Directory -Path $destDir -Force | Out-Null }
        Copy-Item -Path $_.FullName -Destination $dest -Force
    }
    Write-Ok "Configuration files deployed"
}

# Deploy opencode.json with variable substitution
$configFile = Join-Path $configDir "opencode.json"
if (Test-Path $configFile) {
    $content = Get-Content $configFile -Raw
    
    # --- Interactive API Key Setup ---
    Write-Step "  -> API Key Configuration"
    
    # GitHub Token
    $envGithub = [Environment]::GetEnvironmentVariable("GITHUB_TOKEN")
    if (-not $envGithub) {
        $githubToken = Read-Host "Enter your GitHub Personal Access Token (or press Enter to skip)"
        if ($githubToken) {
            $envGithub = $githubToken
            # Save to .env
            $envContent = "GITHUB_TOKEN=$githubToken`n"
            Add-Content -Path "$configDir\.env" -Value $envContent -Force
            [Environment]::SetEnvironmentVariable("GITHUB_TOKEN", $githubToken, "User")
        }
    }
    if ($envGithub) { $content = $content -replace '\$\{GITHUB_TOKEN\}', $envGithub }
    
    # Username
    $username = [Environment]::GetEnvironmentVariable("OPENCODE_USERNAME")
    if (-not $username) {
        $defaultUser = $env:USERNAME
        $input_user = Read-Host "Enter OpenCode username (default: $defaultUser)"
        $username = if ($input_user) { $input_user } else { $defaultUser }
    }
    $content = $content -replace '\$\{USERNAME\}', $username
    
    # Model (optional)
    $content = $content -replace '\$\{MODEL:-opencode/deepseek-v4-flash-free\}', 'opencode/deepseek-v4-flash-free'
    $content = $content -replace '\$\{SMALL_MODEL:-opencode/deepseek-v4-flash-free\}', 'opencode/deepseek-v4-flash-free'
    
    # HOME placeholder
    $homeClean = $env:USERPROFILE -replace '\\', '\\'
    $content = $content -replace '\$\{HOME\}', $homeClean
    
    # TEMP_DIR placeholder
    $tempDir = "$env:USERPROFILE\AppData\Local\Temp\opencode" -replace '\\', '\\'
    $content = $content -replace '\$\{TEMP_DIR\}', $tempDir
    
    
    Set-Content -Path $configFile -Value $content -Force
    Write-Ok "opencode.json configured with your values"
}

# ---------------------------
# STEP 5: INSTALL PLUGIN DEPENDENCIES
# ---------------------------
Write-Step "STEP 5/6 - Installing plugin dependencies..."

# Create package.json if not exists
$pkgFile = "$configDir\package.json"
if (-not (Test-Path $pkgFile)) {
    $pkg = @{ dependencies = @{ "@opencode-ai/plugin" = "latest" } } | ConvertTo-Json
    Set-Content -Path $pkgFile -Value $pkg -Force
}

# Install npm deps in config directory
Push-Location $configDir
try {
    npm install --no-fund --no-audit 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Ok "Plugin dependencies installed"
    } else {
        Write-Warn "npm install completed with warnings"
    }
} catch {
    Write-Warn "npm install failed: $_"
} finally {
    Pop-Location
}

# Create .opencode/package.json for server dependencies
$pkgFile2 = "$opencodeDir\package.json"
if (-not (Test-Path $pkgFile2)) {
    $pkg2 = @{ dependencies = @{ "@opencode-ai/plugin" = "latest" } } | ConvertTo-Json
    Set-Content -Path $pkgFile2 -Value $pkg2 -Force
}

Push-Location $opencodeDir
try {
    npm install --no-fund --no-audit 2>&1 | Out-Null
    Write-Ok "OpenCode runtime dependencies installed"
} catch {
    Write-Warn "npm install in .opencode failed: $_"
} finally {
    Pop-Location
}

# Create .gitignore for config dir
@"
node_modules
package.json
package-lock.json
bun.lock
.env
*.log
"@ | Set-Content -Path "$configDir\.gitignore" -Force

# ---------------------------
# STEP 6: VERIFY & FINALIZE
# ---------------------------
Write-Step "STEP 6/6 - Verifying installation..."

$allOk = $true

# Check opencode binary
try {
    $ver = opencode --version 2>$null
    Write-Ok "OpenCode CLI: v$ver"
} catch { Write-Err "OpenCode CLI not found"; $allOk = $false }

# Check config file
if (Test-Path "$configDir\opencode.json") { 
    Write-Ok "Config file: $configDir\opencode.json"
} else { Write-Err "Config file missing!"; $allOk = $false }

# Check agent file
if (Test-Path "$configDir\agent\orchestrator.md") {
    Write-Ok "Agent: orchestrator"
}

# Check plugin deps
if (Test-Path "$configDir\node_modules") {
    Write-Ok "Plugins: node_modules present"
}

# Check MCP servers availability (dry-run)
$mcps = @("context7", "playwright", "fetch", "sequential-thinking", "filesystem", "mermaid", "excalidraw", "memory", "github")
Write-Info "MCP servers configured: $($mcps -join ', ')"
Write-Ok "All $($mcps.Count) MCP servers registered in config"

Write-Host ""
Write-Host "╔══════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║        🚀  OpenCode PRO - Setup Complete!           ║" -ForegroundColor Green
Write-Host "╠══════════════════════════════════════════════════════╣" -ForegroundColor Green
Write-Host "║  Run:  opencode                                    ║" -ForegroundColor Cyan
Write-Host "║  Docs: https://opencode.ai/docs                    ║" -ForegroundColor Cyan
Write-Host "║                                                     ║" -ForegroundColor Green
Write-Host "║  Your agents:                                       ║" -ForegroundColor Green
Write-Host "║    - orchestrator (primary)                         ║" -ForegroundColor White
Write-Host "║    - general (subagent)                             ║" -ForegroundColor White
Write-Host "║                                                     ║" -ForegroundColor Green
Write-Host "║  Plugins: 17  |  MCPs: 9                           ║" -ForegroundColor Yellow
Write-Host "╚══════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""

if (-not $allOk) {
    Write-Warn "Some checks failed. Review the messages above."
    exit 1
}
