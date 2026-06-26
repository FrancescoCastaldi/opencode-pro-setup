# 🔑 API Keys Reference

## Required

### GitHub Token
- **Env var:** `GITHUB_TOKEN`
- **Create at:** https://github.com/settings/tokens
- **Required scopes:** `repo`, `read:user`, `read:org`
- **Used by:** GitHub MCP server (PRs, issues, code search)

## Optional

### Anthropic
- **Env var:** `ANTHROPIC_API_KEY`
- **Get at:** https://console.anthropic.com
- **Used for:** Claude models (Sonnet, Haiku)
- **Config via:** `opencode providers add anthropic`

### OpenAI
- **Env var:** `OPENAI_API_KEY`
- **Get at:** https://platform.openai.com/api-keys
- **Used for:** GPT models
- **Config via:** `opencode providers add openai`

### Google / Gemini
- **Env var:** `GOOGLE_API_KEY`
- **Get at:** https://aistudio.google.com/apikey
- **Used for:** Gemini models
- **Config via:** `opencode providers add google`

### Local Models (Ollama)
```bash
# Install Ollama
curl -fsSL https://ollama.ai/install.sh | sh
# Pull a model
ollama pull codellama
# Configure in OpenCode
opencode providers add ollama
```

## Auto-Capture Memory (opencode-mem)
For AI-powered auto-capture of memories:
- `MEMORY_API_KEY` — API key for the LLM provider
- `MEMORY_MODEL` — Model (e.g., `gpt-4o-mini`)
- `MEMORY_API_URL` — API endpoint URL

## How to Set API Keys

### Method 1: Installer Prompts
The setup scripts will ask you interactively.

### Method 2: Environment Variables
```bash
# Windows PowerShell
[Environment]::SetEnvironmentVariable("GITHUB_TOKEN", "ghp_...", "User")

# macOS/Linux
echo 'export GITHUB_TOKEN="ghp_..."' >> ~/.zshrc
source ~/.zshrc
```

### Method 3: .env File
```bash
echo "GITHUB_TOKEN=ghp_..." > ~/.config/opencode/.env
```

### Method 4: OpenCode CLI
```bash
opencode providers add anthropic  # Interactive
opencode mcp auth github          # OAuth flow
```
