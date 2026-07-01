# 🔑 API Keys Reference

## Required

### GitHub Token
- **Env var:** `GITHUB_TOKEN`
- **Create at:** https://github.com/settings/tokens
- **Required scopes:** `repo`, `read:user`
- **Used by:** gh_grep MCP server (code search)

## Optional

### Anthropic
- **Env var:** `ANTHROPIC_API_KEY`
- **Get at:** https://console.anthropic.com
- **Used for:** Claude models
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

## Auto-Capture Memory (opencode-supermemory)

For AI-powered auto-capture of memories:
- Configure provider in `opencode-mem.jsonc`
- Uses `opencodeProvider` + `opencodeModel` to reuse OpenCode auth
- Or set `memoryApiKey`, `memoryModel`, `memoryApiUrl` manually

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

### Method 3: OpenCode CLI
```bash
opencode providers add anthropic  # Interactive
```
