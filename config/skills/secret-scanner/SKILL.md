# Secret Scanner

Scan a repository for accidentally committed API keys, tokens, passwords, private keys, and other sensitive material.

## When to Use

- Before pushing a branch that might contain credentials
- When onboarding to a new/untrusted repo
- As a pre-commit or pre-PR check
- When investigating a potential leak
- During security audits

## What It Detects

| Category | Patterns |
|---|---|
| **GitHub tokens** | `ghp_`, `gho_`, `ghu_`, `ghs_`, `ghr_` + 36 char |
| **OpenAI keys** | `sk-...` (proprietary format), `sk-proj-` |
| **Stripe keys** | `sk_live_`, `pk_live_`, `rk_live_`, `wh_` |
| **AWS keys** | `AKIA`, `ASIA` + 16 char |
| **Google API** | `AIza` + 35 char |
| **Slack tokens** | `xoxb-`, `xoxa-`, `xoxp-`, `xoxr-`, `xoxs-` |
| **JWT tokens** | `eyJ...` JWT-format tokens |
| **SendGrid** | `SG.` + key |
| **Facebook** | `EAAC...` tokens |
| **Generic patterns** | api_key, api_secret, secret_key, access_token, auth_token, bearer, password, private_key |
| **Private keys** | `-----BEGIN ... PRIVATE KEY-----` |
| **Connection strings** | `mongodb://`, `postgres://`, `mysql://`, `redis://`, `amqp://`, `smtp://` with credentials |
| **.env files** | Stale or committed `.env` files |
| **Hardcoded secrets** | Any value longer than 30 chars near secret-related keys in config files |
| **Placeholder values** | `your_token`, `your_key`, `changeme`, `xxx` in config files |

## Workflow

### 1. Scan for known API key formats

Run all of these in parallel:

```bash
# GitHub tokens
rg -n '(?:gh[opsur]_[a-zA-Z0-9]{36}|github_pat_[a-zA-Z0-9]{22,})' --no-ignore

# OpenAI keys
rg -n '(?:sk-[a-zA-Z0-9]{20,}|sk-proj-[a-zA-Z0-9_-]{20,})' --no-ignore

# Stripe
rg -n '(?:sk_live_|pk_live_|rk_live_|wh_[a-zA-Z0-9]{20,})' --no-ignore

# AWS
rg -n '(?:AKIA[0-9A-Z]{16}|ASIA[0-9A-Z]{16})' --no-ignore

# Google API
rg -n 'AIza[0-9A-Za-z_-]{35}' --no-ignore

# Slack tokens
rg -n 'xox[baprs]-[a-zA-Z0-9-]{10,}' --no-ignore

# JWT
rg -n '(?:eyJ[a-zA-Z0-9_-]{20,}\.[a-zA-Z0-9_-]{10,})' --no-ignore

# SendGrid, Facebook, other short formats
rg -n '(?:SG\.[a-zA-Z0-9_-]{20,}|EAAC[A-Za-z0-9]{40,})' --no-ignore

# Private keys
rg -n '(?:-----BEGIN (?:RSA |EC |DSA |OPENSSH )?PRIVATE KEY-----)' --no-ignore
```

### 2. Scan for secrets near config keys

Look for values suspiciously close to secret key names in structured files:

```bash
# Config files with secrets referenced
rg -n '(?:api[_-]?key|apikey|api[_-]?secret|secret[_-]?key|access[_-]?key|access[_-]?token|auth[_-]?token|bearer|password|passwd|pwd|secret|token|credential|private[_-]?key)' \
  --include='*.{json,jsonc,yaml,yml,toml,ini,env,conf,config}' --no-ignore
```

Flag any match where the value assigned is not:
- A placeholder (`your_*`, `...`, `changeme`, `xxx`)
- A file reference (`{file:...}`)
- An env variable reference (`{env:...}`, `${{ ... }}`)
- A commented/example line

### 3. Check for committed .env files

```bash
# Any .env file (not .env.example)
rg -l '^[A-Z_]+=' --include='.env' 2>/dev/null || find . -name '.env' -not -name '*.example' 2>/dev/null

# Check .gitignore covers .env
rg '^\.env$' .gitignore
```

### 4. Check for connection strings with credentials

```bash
rg -n '(?:mongodb(?:\+srv)?://[a-zA-Z0-9]+:|postgres://[a-zA-Z0-9]+:|mysql://[a-zA-Z0-9]+:)' --no-ignore
```

### 5. Flag long hex/base64 values in config

```bash
rg -n '"([A-Za-z0-9_-]{30,})"' --include='*.{json,jsonc,yaml,yml,env,conf}' --no-ignore
```

### 6. Check for placeholder values that look real

```bash
rg -in '(placeholder|your_token|your_key|changeme|CHANGE_ME|PUT_YOUR)'
```

## Classification Rules

For each finding, classify as:

| Severity | Criteria | Action |
|---|---|---|
| 🔴 **CRITICAL** | Real API key / token / private key in tracked file | Rotate immediately, remove from git history |
| 🟠 **HIGH** | Connection string with embedded credentials | Rotate if still valid, remove from repo |
| 🟡 **MEDIUM** | Placeholder with real-looking value | Verify it's actually a placeholder |
| 🟢 **LOW** | `{file:...}` or `{env:...}` references | Safe pattern — no action |
| ⚪ **INFO** | Comment/example mentioning secrets | Verifiy it's truly example-only |

## Git History Remediation

If a real secret was committed:

```bash
# Remove from git history (BFG is faster)
java -jar bfg.jar --replace-text secrets.txt my-repo.git

# Or use git-filter-repo
git filter-repo --replace-text <(echo "sk-real...=>REVOKED")
```

## Safety Rules

- **Read-only scan** — never modify files or git history without explicit user approval
- Do **not** print full secret values in output — show only first 4 and last 4 chars
- When a real secret is found, advise rotation and BFG/filter-repo cleanup
- Always check `.gitignore` coverage as part of the report

## Output Format

```markdown
# Secret Scan Report: <repo>

## Summary
- 🔴 Critical: N
- 🟠 High: N
- 🟡 Medium: N
- 🟢 Low: N
- ⚪ Info: N

## Findings

### 🔴 Critical
| File | Line | Type | Note |
|---|---|---|---|
| src/config.js | 42 | GitHub Token | `ghp_1234...abcd` — ROTATE IMMEDIATELY |

### 🟡 Medium
...

## .gitignore Status
- .env covered: ✅ / ❌
- *.key covered: ✅ / ❌

## Recommendations
1. Rotate any critical/high findings
2. Purge from git history with BFG
3. Add missing .gitignore entries
4. Review any medium findings manually
```
