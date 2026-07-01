# 🛠️ Customization Guide

## Changing the AI Model

Edit `~/.config/opencode/opencode.json`:

```json
{
  "model": "anthropic/claude-sonnet-4-6",
  "small_model": "anthropic/claude-haiku-4-5"
}
```

Available providers: `anthropic/`, `openai/`, `google/`, `opencode/`, `ollama/`, etc.

List all available models:
```bash
opencode models
```

## Adding/Removing Plugins

Edit the `plugin` array in `opencode.json`:

```json
{
  "plugin": [
    "opencode-snippets",
    "opencode-supermemory",
    // Add plugin name here
  ]
}
```

Then reinstall dependencies:
```bash
cd ~/.config/opencode && npm install
```

## Adding/Removing MCP Servers

Edit the `mcp` object in `opencode.json`:

```json
{
  "mcp": {
    "my-server": {
      "type": "local",
      "command": ["npx", "-y", "@org/my-mcp-server"]
    },
    "remote-api": {
      "type": "remote",
      "url": "https://api.example.com/mcp"
    }
  }
}
```

> Each MCP server adds context tokens. Too many will consume your context window.

## Custom Plugins

Custom plugins go in `~/.config/opencode/plugins/`:

```javascript
// my-plugin.js
export const MyPlugin = async ({ $ }) => {
  return {
    "event": async ({ event }) => {
      if (event.type === "session.start") {
        console.log("Session started!")
      }
    },
  }
}
```

Reference them from `opencode.json` by adding to the `plugin` array:
```json
{
  "plugin": [
    "plugins/my-plugin.js"
  ]
}
```

## Custom Agents

Add agent files in `~/.config/opencode/agent/`:

```markdown
---
description: My custom agent
mode: subagent
permission:
  read: allow
  edit: allow
---
You are a specialized agent for...
```

Register them in `opencode.json`:

```json
{
  "agent": {
    "my-agent": {
      "description": "My custom agent",
      "mode": "subagent",
      "permission": { "read": "allow", "edit": "allow" }
    }
  }
}
```

## Custom Commands

Define reusable commands in `opencode.json`:

```json
{
  "command": {
    "lint": {
      "description": "Run linter",
      "template": "Run eslint on the project and fix any issues"
    },
    "typecheck": {
      "description": "TypeScript type check",
      "template": "Run TypeScript compiler check and report errors"
    }
  }
}
```

Use them via:
```bash
opencode /lint
opencode /typecheck
```

## Permission Tweaks

Adjust security in `opencode.json`:

```json
{
  "permission": {
    "bash": {
      "rm *": "deny",
      "git push * --force*": "deny",
      "*": "allow"
    },
    "external_directory": {
      "~/.ssh/**": "deny",
      "~/.config/**": "ask",
      "*": "allow"
    }
  }
}
```

Values: `allow`, `deny`, `ask`

## Adding Skills

Place skill files in `~/.config/opencode/skills/`:

```bash
# Add a custom skill
mkdir -p ~/.config/opencode/skills/my-workflow
cat > ~/.config/opencode/skills/my-workflow/SKILL.md << 'EOF'
---
description: My custom workflow
---
Follow these steps when...
EOF
```

## Troubleshooting

### "Command not found" after install
Restart your terminal or run:
```bash
export PATH="$(npm config get prefix)/bin:$PATH"
```

### Plugin not loading
```bash
cd ~/.config/opencode && npm install
```

### MCP server error
Check the server is installed:
```bash
npx -y @server/name --help
```

### Reset everything
```bash
# Backup first!
cp -r ~/.config/opencode ~/opencode-backup

# Remove and reinstall
rm -rf ~/.config/opencode ~/.opencode ~/.opencode-mem
npm uninstall -g opencode-ai
# Run setup again
```
