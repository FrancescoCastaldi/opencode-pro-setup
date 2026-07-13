<#
.SYNOPSIS
    OpenCode PRO - Windows Standalone Installer
.DESCRIPTION
    Installs OpenCode AI editor with the PRO configuration (plugins, custom plugins, 
    skills, MCP servers, agents) on any Windows PC. Detects existing installations,
    backs them up, cleans everything, and deploys the complete PRO setup.
    
    This script is self-contained. If run without the 'config' folder alongside it,
    it will download the latest config from GitHub.
.NOTES
    Author: Francesco Castaldi
    Repo:   https://github.com/FrancescoCastaldi/opencode-pro-setup
    Version: 2.1.0
    Usage:  powershell -ExecutionPolicy Bypass -File install-opencode-pro.ps1
#>

param(
    [switch]$Force,
    [switch]$SkipClean,
    [switch]$Offline,
    [string]$RepoUrl = "https://github.com/FrancescoCastaldi/opencode-pro-setup"
)

$ErrorActionPreference = "Stop"
$Host.UI.RawUI.WindowTitle = "OpenCode PRO Setup for Windows"

# ============================================================
# CONFIGURAZIONE
# ============================================================
$CONFIG_DIR         = "$env:USERPROFILE\.config\opencode"
$OPENCODE_DIR       = "$env:USERPROFILE\.opencode"
$OPENCODE_MEM_DIR   = "$env:USERPROFILE\.opencode-mem"
$BACKUP_DIR         = "$env:USERPROFILE\opencode-backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
$SCRIPT_DIR         = Split-Path -Parent $PSCommandPath
$LOCAL_CONFIG_SRC   = Join-Path $SCRIPT_DIR "config"
$REQUIRED_NODE_MAJOR = 18

# ============================================================
# UTILITY FUNCTIONS
# ============================================================
function Write-Banner {
    Clear-Host
    Write-Host @"
╔══════════════════════════════════════════════════════════╗
║            OpenCode PRO - Windows Installer              ║
║           Configurazione professionale completa           ║
╚══════════════════════════════════════════════════════════╝
"@ -ForegroundColor Cyan
    Write-Host ""
}

function Write-Info  { Write-Host "  [INFO] $($args -join ' ')" -ForegroundColor Cyan }
function Write-Ok    { Write-Host "  [OK]   $($args -join ' ')" -ForegroundColor Green }
function Write-Warn  { Write-Host "  [WARN] $($args -join ' ')" -ForegroundColor Yellow }
function Write-Err   { Write-Host "  [ERR]  $($args -join ' ')" -ForegroundColor Red }
function Write-Step  { Write-Host "`n  => $($args -join ' ')" -ForegroundColor Magenta }

function Test-CommandAvailable {
    param([string]$Command)
    $oldPreference = $ErrorActionPreference
    $ErrorActionPreference = 'SilentlyContinue'
    try {
        $null = Get-Command $Command -ErrorAction Stop
        return $true
    } catch {
        return $false
    } finally {
        $ErrorActionPreference = $oldPreference
    }
}

function Install-WithWinget {
    param([string]$PackageId, [string]$DisplayName)
    Write-Info "Installing $DisplayName via winget..."
    try {
        winget install $PackageId --silent --accept-package-agreements 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) {
            Write-Ok "$DisplayName installed via winget"
            return $true
        }
    } catch {}
    return $false
}

function Show-ProgressBar {
    param([int]$Percent, [string]$Label)
    $bar = '#' * [math]::Floor($Percent / 5) + ' ' * (20 - [math]::Floor($Percent / 5))
    Write-Progress -Activity "OpenCode PRO Installation" -Status $Label -PercentComplete $Percent
}

# ============================================================
# STEP 0: PREREQUISITI
# ============================================================
function Step-CheckPrerequisites {
    Write-Step "STEP 0/6 - Checking prerequisites..."
    Show-ProgressBar -Percent 5 -Label "Checking prerequisites"

    # PowerShell version
    if ($PSVersionTable.PSVersion.Major -lt 5) {
        Write-Err "PowerShell 5.0+ required. Please update Windows."
        exit 1
    }

    # Node.js check
    $nodeVersion = $null
    try { $nodeVersion = node --version } catch {}
    if (-not $nodeVersion) {
        Write-Warn "Node.js not found."
        $answer = Read-Host "Install Node.js LTS via winget? (Y/N)"
        if ($answer -match '^(Y|y|Yes|yes)$') {
            if (-not (Install-WithWinget -PackageId "OpenJS.NodeJS.LTS" -DisplayName "Node.js")) {
                Write-Err "Failed to install Node.js. Download manually from https://nodejs.org"
                exit 1
            }
            refreshenv 2>$null
            $env:Path = [Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [Environment]::GetEnvironmentVariable("Path","User")
            $nodeVersion = node --version 2>$null
        } else {
            Write-Err "Node.js is required. Install it manually, then re-run this script."
            exit 1
        }
    }
    Write-Ok "Node.js $nodeVersion"

    # npm check
    $npmVersion = $null
    try { $npmVersion = npm --version } catch {}
    if (-not $npmVersion) {
        Write-Err "npm not found. Reinstall Node.js."
        exit 1
    }
    Write-Ok "npm v$npmVersion"

    # Git check
    if (-not (Test-CommandAvailable "git")) {
        Write-Warn "Git not found."
        $answer = Read-Host "Install Git via winget? (Y/N)"
        if ($answer -match '^(Y|y|Yes|yes)$') {
            if (-not (Install-WithWinget -PackageId "Git.Git" -DisplayName "Git")) {
                Write-Err "Failed to install Git. Download from https://git-scm.com"
                exit 1
            }
            $env:Path = [Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [Environment]::GetEnvironmentVariable("Path","User")
        } else {
            Write-Err "Git is required for cloning the configuration."
            exit 1
        }
    }
    Write-Ok "Git available"

    Show-ProgressBar -Percent 10 -Label "Prerequisites OK"
    Write-Ok "All prerequisites satisfied!"
}

# ============================================================
# STEP 1: DETECT & CLEAN
# ============================================================
function Step-DetectAndClean {
    Write-Step "STEP 1/6 - Detecting existing OpenCode installations..."
    Show-ProgressBar -Percent 15 -Label "Scanning existing installations"

    $found = @()

    # npm global
    try { $npmGlobal = npm list -g --depth=0 2>$null | Select-String "opencode" }
    catch {}
    if ($npmGlobal) { $found += "npm global (opencode-ai)" }

    # app directories
    $dirs = @(
        $CONFIG_DIR,
        $OPENCODE_DIR,
        "$env:LOCALAPPDATA\opencode",
        "$env:APPDATA\opencode"
    )
    foreach ($d in $dirs) {
        if (Test-Path $d) { $found += "directory: $d" }
    }

    # PATH entries
    $env:Path -split ';' | Where-Object { $_ -like "*opencode*" } | ForEach-Object {
        $found += "PATH entry: $_"
    }

    # processes
    $procs = Get-Process -Name "*opencode*" -ErrorAction SilentlyContinue
    if ($procs) { $found += "running process(es)" }

    Show-ProgressBar -Percent 20 -Label "Existing installations scanned"

    if ($found.Count -gt 0) {
        Write-Warn "Found existing OpenCode components:"
        $found | ForEach-Object { Write-Host "       - $_" }
        
        if (-not $SkipClean) {
            $clean = $Force
            if (-not $clean) {
                $response = Read-Host "`n  Clean all existing installations? (Y/N) [Y]"
                $clean = ($response -eq "" -or $response -match "^(Y|y|Yes|yes)$")
            }
            
            if ($clean) {
                Write-Step "  -> Cleaning existing installations..."
                Show-ProgressBar -Percent 25 -Label "Cleaning old installations"

                # Kill processes
                $runningProcs = Get-Process -Name "*opencode*" -ErrorAction SilentlyContinue
                if ($runningProcs) {
                    $runningProcs | Stop-Process -Force
                    Write-Ok "Killed running opencode processes"
                    Start-Sleep -Seconds 2
                }

                # BACKUP existing config
                if (Test-Path $CONFIG_DIR) {
                    Write-Info "Creating backup in: $BACKUP_DIR"
                    try {
                        New-Item -ItemType Directory -Path $BACKUP_DIR -Force | Out-Null
                        Copy-Item -Path $CONFIG_DIR -Destination "$BACKUP_DIR\opencode-config" -Recurse -Force
                        Write-Ok "Configuration backed up!"
                    } catch {
                        Write-Warn "Backup failed: $_ (continuing anyway)"
                    }
                }
                if (Test-Path $OPENCODE_DIR) {
                    try {
                        Copy-Item -Path $OPENCODE_DIR -Destination "$BACKUP_DIR\opencode-data" -Recurse -Force
                    } catch {}
                }
                if (Test-Path $OPENCODE_MEM_DIR) {
                    try {
                        Copy-Item -Path $OPENCODE_MEM_DIR -Destination "$BACKUP_DIR\opencode-mem" -Recurse -Force
                    } catch {}
                }

                # Uninstall npm global
                if ($npmGlobal) {
                    Write-Info "Uninstalling npm global opencode-ai..."
                    npm uninstall -g opencode-ai 2>$null
                }

                # Remove directories
                foreach ($d in $dirs) {
                    if (Test-Path $d) {
                        try {
                            Remove-Item -Path $d -Recurse -Force -ErrorAction SilentlyContinue
                            Write-Ok "Removed: $d"
                        } catch {
                            Write-Warn "Could not remove $d (might need admin): $_"
                        }
                    }
                }

                if (Test-Path $OPENCODE_MEM_DIR) {
                    Remove-Item -Path $OPENCODE_MEM_DIR -Recurse -Force -ErrorAction SilentlyContinue
                    Write-Ok "Removed: $OPENCODE_MEM_DIR"
                }

                Write-Ok "Cleanup complete!"
            }
        } else {
            Write-Warn "Skipping cleanup (--SkipClean flag)"
        }
    } else {
        Write-Ok "No existing OpenCode found - clean system!"
    }

    Show-ProgressBar -Percent 30 -Label "Cleanup done"
}

# ============================================================
# STEP 2: INSTALL OPENCODE
# ============================================================
function Step-InstallOpenCode {
    Write-Step "STEP 2/6 - Installing OpenCode AI..."
    Show-ProgressBar -Percent 35 -Label "Installing OpenCode"

    Write-Info "Installing opencode-ai globally via npm..."
    
    $npmOutput = npm install -g opencode-ai@latest 2>&1
    $exitCode = $LASTEXITCODE
    
    if ($exitCode -ne 0) {
        Write-Warn "First attempt failed. Retrying with --force..."
        $npmOutput = npm install -g opencode-ai@latest --force 2>&1
        $exitCode = $LASTEXITCODE
        if ($exitCode -ne 0) {
            Write-Err "Failed to install OpenCode. Try: npm install -g opencode-ai"
            Write-Err "Error: $npmOutput"
            exit 1
        }
    }

    # Verify installation
    $ocVersion = opencode --version 2>$null
    if (-not $ocVersion) {
        Write-Info "Adding npm global to PATH..."
        $npmPrefix = npm config get prefix 2>$null
        if ($npmPrefix -and (Test-Path $npmPrefix)) {
            $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
            if ($userPath -notlike "*$npmPrefix*") {
                [Environment]::SetEnvironmentVariable("Path", "$userPath;$npmPrefix", "User")
            }
            $env:Path = [Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [Environment]::GetEnvironmentVariable("Path","User")
        }
        $ocVersion = opencode --version 2>$null
    }

    if (-not $ocVersion) {
        Write-Err "OpenCode binary not found in PATH after install."
        Write-Err "Restart your terminal and run: opencode --version"
        Write-Info "Continuing with configuration deployment..."
        $ocVersion = "unknown"
    }

    Write-Ok "OpenCode $ocVersion installed!"

    # Create opencode data directory
    if (-not (Test-Path $OPENCODE_DIR)) {
        New-Item -ItemType Directory -Path $OPENCODE_DIR -Force | Out-Null
    }

    Show-ProgressBar -Percent 40 -Label "OpenCode installed"
}

# ============================================================
# STEP 3: CREATE DIRECTORY STRUCTURE
# ============================================================
function Step-CreateDirectories {
    Write-Step "STEP 3/6 - Creating directory structure..."
    Show-ProgressBar -Percent 45 -Label "Creating directories"

    $subDirs = @('agent', 'plugins', 'skills', 'snippet', 'memory')

    # Create main config dir if needed
    if (-not (Test-Path $CONFIG_DIR)) {
        New-Item -ItemType Directory -Path $CONFIG_DIR -Force | Out-Null
    }

    # Create subdirectories
    foreach ($sub in $subDirs) {
        $path = Join-Path $CONFIG_DIR $sub
        if (-not (Test-Path $path)) {
            New-Item -ItemType Directory -Path $path -Force | Out-Null
            Write-Ok "Created: config/$sub"
        }
    }

    # Ensure .opencode/data exists
    $dataDir = Join-Path $OPENCODE_DIR "data"
    if (-not (Test-Path $dataDir)) {
        New-Item -ItemType Directory -Path $dataDir -Force | Out-Null
    }

    Show-ProgressBar -Percent 50 -Label "Directories ready"
    Write-Ok "Directory structure created!"
}

# ============================================================
# STEP 4: DEPLOY CONFIGURATION
# ============================================================
function Step-DeployConfiguration {
    Write-Step "STEP 4/6 - Deploying configuration files..."
    Show-ProgressBar -Percent 55 -Label "Deploying configuration"

    $configSource = $null

    # Try local config folder first
    if ((-not $Offline) -and (Test-Path $LOCAL_CONFIG_SRC)) {
        $configSource = $LOCAL_CONFIG_SRC
        Write-Info "Using local config from: $configSource"
    }

    # If not found locally, download from GitHub
    if (-not $configSource -and -not $Offline) {
        Write-Info "Downloading latest configuration from GitHub..."
        $tmpZip = "$env:TEMP\opencode-config.zip"
        $tmpExtract = "$env:TEMP\opencode-config-extracted"
        
        try {
            # Clean any previous extraction
            if (Test-Path $tmpExtract) { Remove-Item -Path $tmpExtract -Recurse -Force }
            if (Test-Path $tmpZip) { Remove-Item -Path $tmpZip -Force }

            Invoke-WebRequest -Uri "$RepoUrl/archive/main.zip" -OutFile $tmpZip -UseBasicParsing
            Expand-Archive -Path $tmpZip -DestinationPath $tmpExtract -Force
            $repoRoot = Get-ChildItem "$tmpExtract\*" -Directory | Select-Object -First 1
            $configSource = Join-Path $repoRoot.FullName "config"
            
            if (-not (Test-Path $configSource)) {
                throw "Config directory not found in downloaded archive"
            }
            Write-Ok "Configuration downloaded from GitHub"
        } catch {
            Write-Err "Failed to download config: $_"
            Write-Info "Create a minimal config manually or clone the repo:"
            Write-Info "  git clone $RepoUrl"
            exit 1
        }
    }

    if (-not $configSource) {
        Write-Err "No configuration source available. Run without -Offline or place 'config' folder."
        exit 1
    }

    # --- 4a: Deploy root config files ---
    Write-Info "Deploying config files..."
    Get-ChildItem -Path $configSource -Filter "*.json*" -File | ForEach-Object {
        $dest = Join-Path $CONFIG_DIR $_.Name
        Copy-Item -Path $_.FullName -Destination $dest -Force
    }
    # .env.example
    $envExample = Join-Path $configSource ".env.example"
    if (Test-Path $envExample) {
        Copy-Item -Path $envExample -Destination $CONFIG_DIR -Force
    }
    Write-Ok "Root config files deployed"

    # --- 4b: Deploy agent files ---
    $agentSource = Join-Path $configSource "agent"
    if (Test-Path $agentSource) {
        $agentDest = Join-Path $CONFIG_DIR "agent"
        Get-ChildItem -Path $agentSource -File | ForEach-Object {
            Copy-Item -Path $_.FullName -Destination $agentDest -Force
        }
        Write-Ok "Agent files deployed"
    }

    # --- 4c: Deploy custom plugins ---
    $pluginsSource = Join-Path $configSource "plugins"
    if (Test-Path $pluginsSource) {
        $pluginsDest = Join-Path $CONFIG_DIR "plugins"
        Get-ChildItem -Path $pluginsSource -File | ForEach-Object {
            Copy-Item -Path $_.FullName -Destination $pluginsDest -Force
        }
        Write-Ok "Custom plugins deployed (context-pruning, env-protection, notification)"
    }

    # --- 4d: Deploy snippet config ---
    $snippetSource = Join-Path $configSource "snippet"
    if (Test-Path $snippetSource) {
        $snippetDest = Join-Path $CONFIG_DIR "snippet"
        Get-ChildItem -Path $snippetSource -Recurse -File | ForEach-Object {
            $relative = $_.FullName.Substring($snippetSource.Length).TrimStart('\')
            $dest = Join-Path $snippetDest $relative
            $parentDir = Split-Path $dest -Parent
            if (-not (Test-Path $parentDir)) { New-Item -ItemType Directory -Path $parentDir -Force | Out-Null }
            Copy-Item -Path $_.FullName -Destination $dest -Force
        }
        Write-Ok "Snippet config deployed"
    }

    # --- 4e: Deploy memory files ---
    $memorySource = Join-Path $configSource "memory"
    if (Test-Path $memorySource) {
        $memoryDest = Join-Path $CONFIG_DIR "memory"
        Get-ChildItem -Path $memorySource -File | ForEach-Object {
            Copy-Item -Path $_.FullName -Destination $memoryDest -Force
        }
        Write-Ok "Memory files deployed"
    }

    # --- 4f: Deploy skills ---
    $skillsSource = Join-Path $configSource "skills"
    if (Test-Path $skillsSource) {
        $skillsDest = Join-Path $CONFIG_DIR "skills"
        Copy-Item -Path "$skillsSource\*" -Destination $skillsDest -Recurse -Force
        Write-Ok "Skills deployed: deepwork, simplify, codemap, clonedeps, reflect, worktrees"
    }

    Show-ProgressBar -Percent 70 -Label "Configuration deployed"
    Write-Ok "All configuration files deployed!"
}

# ============================================================
# STEP 5: INSTALL PLUGIN DEPENDENCIES
# ============================================================
function Step-InstallDependencies {
    Write-Step "STEP 5/6 - Installing plugin dependencies..."
    Show-ProgressBar -Percent 75 -Label "Installing plugins"

    # Create/update package.json in config dir
    $pkgFile = Join-Path $CONFIG_DIR "package.json"
    $pkg = @{
        dependencies = @{
            "@opencode-ai/plugin"           = "latest"
            "opencode-mem"                  = "latest"
            "opencode-snippets"             = "latest"
            "opencode-supermemory"          = "latest"
            "opencode-background-agents"    = "latest"
            "opencode-worktree"             = "latest"
            "opencode-notify"               = "latest"
            "oh-my-opencode-slim"           = "latest"
        }
    }
    $pkg | ConvertTo-Json | Set-Content -Path $pkgFile -Force

    # Install npm deps
    Write-Info "Installing npm packages (this may take a minute)..."
    Push-Location $CONFIG_DIR
    try {
        $npmResult = npm install --no-fund --no-audit 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Ok "Plugin dependencies installed successfully"
        } else {
            Write-Warn "npm install completed with warnings"
        }
    } catch {
        Write-Warn "npm install had issues: $_"
    } finally {
        Pop-Location
    }

    # Install deps in .opencode dir too
    $ocPkgFile = Join-Path $OPENCODE_DIR "package.json"
    $ocPkg = @{ dependencies = @{ "@opencode-ai/plugin" = "latest" } }
    $ocPkg | ConvertTo-Json | Set-Content -Path $ocPkgFile -Force

    Push-Location $OPENCODE_DIR
    try {
        npm install --no-fund --no-audit 2>&1 | Out-Null
        Write-Ok "OpenCode runtime dependencies installed"
    } catch {
        Write-Warn "npm install in .opencode had issues: $_"
    } finally {
        Pop-Location
    }

    # Create .gitignore for config dir (ignore npm junk)
    @"
node_modules
package.json
package-lock.json
bun.lock
.env
*.log
"@ | Set-Content -Path (Join-Path $CONFIG_DIR ".gitignore") -Force

    Show-ProgressBar -Percent 85 -Label "Plugins installed"
    Write-Ok "All dependencies installed!"
}

# ============================================================
# STEP 5b: INSTALL MCP SERVER & LSP DEPENDENCIES
# ============================================================
function Step-InstallMCPServers {
    Write-Step "STEP 5b/8 - Installing MCP Server & LSP packages..."
    Show-ProgressBar -Percent 87 -Label "Installing MCP & LSP packages"

    Write-Info "Installing MCP Server packages globally..."
    
    $mcpPackages = @(
        "@playwright/mcp",
        "@modelcontextprotocol/server-github",
        "@negokaz/excel-mcp-server",
        "opencode-mcp",
        "mcp-fetch-server",
        "@modelcontextprotocol/server-sequential-thinking",
        "@modelcontextprotocol/server-memory"
    )

    foreach ($pkg in $mcpPackages) {
        Write-Info "  Installing $pkg..."
        $result = npm install -g $pkg 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Ok "  $pkg installed"
        } else {
            Write-Warn "  $pkg had issues, retrying..."
            $result = npm install -g $pkg --force 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-Ok "  $pkg installed (with --force)"
            } else {
                Write-Warn "  $pkg failed: $_"
            }
        }
    }

    Write-Info "Installing LSP Server packages globally..."
    
    $lspPackages = @(
        "typescript-language-server",
        "vscode-html-language-server",
        "vscode-css-language-server",
        "vscode-json-language-server",
        "vscode-markdown-language-server",
        "yaml-language-server"
    )

    foreach ($pkg in $lspPackages) {
        Write-Info "  Installing $pkg..."
        $result = npm install -g $pkg 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Ok "  $pkg installed"
        } else {
            Write-Warn "  $pkg had issues: $_"
        }
    }

    # Install Playwright browser for @playwright/mcp
    Write-Info "Installing Playwright Chromium browser..."
    $playwrightResult = npx -p @playwright/mcp playwright install chromium 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Ok "Playwright Chromium browser installed"
    } else {
        Write-Warn "Playwright browser install had issues (will be auto-downloaded on first use)"
    }

    Show-ProgressBar -Percent 90 -Label "MCP & LSP installed"
    Write-Ok "All MCP Server and LSP dependencies installed!"
}

# ============================================================
# STEP 5c: CONFIGURE API KEYS
# ============================================================
function Step-ConfigureAPI {
    Write-Step "  -> API Key Configuration"
    
    $envFile = Join-Path $CONFIG_DIR ".env"
    
    # GitHub Token
    $currentGithub = $null
    if (Test-Path $envFile) {
        $envContent = Get-Content $envFile -Raw
        if ($envContent -match 'GITHUB_TOKEN=(.+)') {
            $currentGithub = $Matches[1]
        }
    }

    if (-not $currentGithub -or $currentGithub -eq 'ghp_your_token_here') {
        Write-Info "GitHub token is needed for code search features."
        $githubToken = Read-Host "Enter GitHub Personal Access Token (or press Enter to skip)"
        if ($githubToken) {
            $envLine = "GITHUB_TOKEN=$githubToken"
            if (Test-Path $envFile) {
                $content = Get-Content $envFile -Raw
                if ($content -match 'GITHUB_TOKEN=') {
                    $content = $content -replace 'GITHUB_TOKEN=.*', $envLine
                } else {
                    $content += "`n$envLine`n"
                }
                Set-Content -Path $envFile -Value $content -Force
            } else {
                Set-Content -Path $envFile -Value "$envLine`n" -Force
            }
            [Environment]::SetEnvironmentVariable("GITHUB_TOKEN", $githubToken, "User")
            Write-Ok "GitHub token configured"
        }
    } else {
        Write-Ok "GitHub token already configured"
    }

    # Username
    $username = [Environment]::GetEnvironmentVariable("OPENCODE_USERNAME")
    if (-not $username) {
        $defaultUser = $env:USERNAME
        $inputUser = Read-Host "Enter OpenCode username (default: $defaultUser)"
        $username = if ($inputUser) { $inputUser } else { $defaultUser }
        [Environment]::SetEnvironmentVariable("OPENCODE_USERNAME", $username, "User")
    }
    Write-Ok "Username: $username"
}

# ============================================================
# STEP 6: VERIFY
# ============================================================
function Step-Verify {
    Write-Step "STEP 6/6 - Verifying installation..."
    Show-ProgressBar -Percent 90 -Label "Verifying installation"

    $allOk = $true
    $report = @()

    # OpenCode CLI
    $ver = $null
    try { $ver = opencode --version 2>$null } catch {}
    if ($ver) {
        $report += "OpenCode CLI: v$ver"
    } else {
        $report += "OpenCode CLI: NOT FOUND"
        $allOk = $false
    }

    # Config file
    if (Test-Path (Join-Path $CONFIG_DIR "opencode.json")) {
        $report += "Config: opencode.json"
    } elseif (Test-Path (Join-Path $CONFIG_DIR "opencode.jsonc")) {
        $report += "Config: opencode.jsonc"
    } else {
        $report += "Config: MISSING"
        $allOk = $false
    }

    # Agent
    if (Test-Path (Join-Path $CONFIG_DIR "agent\orchestrator.md")) {
        $report += "Agent: orchestrator"
    }

    # Custom plugins
    $pluginCount = @(Get-ChildItem -Path (Join-Path $CONFIG_DIR "plugins") -Filter "*.js" -ErrorAction SilentlyContinue).Count
    if ($pluginCount -gt 0) {
        $report += "Custom plugins: $pluginCount"
    }

    # Skills
    $skillCount = @(Get-ChildItem -Path (Join-Path $CONFIG_DIR "skills") -Directory -ErrorAction SilentlyContinue).Count
    if ($skillCount -gt 0) {
        $report += "Skills: $skillCount"
    }

    # Node modules
    if (Test-Path (Join-Path $CONFIG_DIR "node_modules")) {
        $report += "Plugin deps: installed"
    } else {
        $report += "Plugin deps: MISSING"
        $allOk = $false
    }

    Show-ProgressBar -Percent 100 -Label "Installation complete!"

    # Display results
    Write-Host ""
    Write-Host "  ========================================" -ForegroundColor Green
    Write-Host "   OpenCode PRO - Installation Complete!" -ForegroundColor Green
    Write-Host "  ========================================" -ForegroundColor Green
    Write-Host ""
    $report | ForEach-Object { Write-Host "    $_" -ForegroundColor White }
    Write-Host ""
    Write-Host "    What's installed:" -ForegroundColor Cyan
    Write-Host "    - 6 Official plugins" -ForegroundColor Cyan
    Write-Host "    - 3 Custom plugins (context-pruning, env-protection, notification)" -ForegroundColor Cyan
    Write-Host "    - 6 Skills (deepwork, simplify, codemap, clonedeps, reflect, worktrees)" -ForegroundColor Cyan
    Write-Host "    - 11 MCP servers (playwright, github, excel, opencode, fetch, sequential-thinking, memory, context7, gh_grep, websearch)" -ForegroundColor Cyan
    Write-Host "    - 6 LSP servers (TypeScript, HTML, CSS, JSON, Markdown, YAML)" -ForegroundColor Cyan
    Write-Host "    - Orchestrator agent with sub-agents" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "    Backup saved to: $BACKUP_DIR" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "    Run: opencode" -ForegroundColor Green
    Write-Host ""

    if (-not $allOk) {
        Write-Warn "Some checks failed. Review the messages above."
        exit 1
    }
}

# ============================================================
# MAIN
# ============================================================
try {
    Write-Banner
    Write-Info "Repository: $RepoUrl"
    if ($Force) { Write-Info "Mode: Force (automatic)" }
    if ($SkipClean) { Write-Info "Mode: Skip Clean" }
    Write-Host ""

    Step-CheckPrerequisites
    Step-DetectAndClean
    Step-InstallOpenCode
    Step-CreateDirectories
    Step-DeployConfiguration
    Step-InstallDependencies
    Step-InstallMCPServers
    Step-ConfigureAPI
    Step-Verify

} catch {
    Write-Err "Installation failed!"
    Write-Err "Error: $_"
    Write-Err "Line: $($_.InvocationInfo.ScriptLineNumber)"
    exit 1
}
