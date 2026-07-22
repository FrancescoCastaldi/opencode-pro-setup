---
name: site-health-checker
description: Health-check websites hosted on GitHub. Verifies GitHub Pages deployment, SSL, DNS, links, robots/sitemap, HTTPS redirects, and CORS; then generates a site health report.
license: MIT
metadata:
  author: Francesco Castaldi
  tags: [website, health-check, github-pages, ssl, dns, links, seo, github]
---

# site-health-checker

## What I do

I check the health of a website hosted from a GitHub repository. I verify GitHub Pages deployment status, SSL certificate validity, DNS, broken links, SEO metadata files, HTTPS redirects, and security headers.

## When to use

- After deploying a site or changing DNS/domain settings
- For periodic monitoring and health checks
- When a site appears unreachable or broken
- When auditing a GitHub Pages / custom-domain setup

## Workflow

### Step 1: Get site information

1. Identify the repository and domain.
2. Use `gh` to read GitHub Pages configuration and deployment status.

```bash
gh api repos/owner/repo/pages
gh api repos/owner/repo/pages/health
```

### Step 2: Check SSL certificate

1. Use `webfetch` or `openssl` to verify the certificate validity and expiration.
2. Check for mixed-content warnings.

### Step 3: Scan for broken links

1. Crawl the site with the Playwright MCP.
2. Check internal links (relative) and external links (absolute).
3. Record HTTP status codes and failures.

### Step 4: Check DNS configuration

1. Verify A/AAAA/CNAME records point to GitHub Pages IPs.
2. Check `www` vs apex domain handling.

### Step 5: Verify metadata files

1. Check `/robots.txt` exists and is valid.
2. Check `/sitemap.xml` exists and is valid.
3. Check `/.well-known/` endpoints if applicable.

### Step 6: Test HTTPS and CORS

1. Verify HTTP -> HTTPS redirect.
2. Verify HSTS, security headers, and CORS headers.
3. Check for CSP if present.

### Step 7: Generate site health report

1. Create `SITE_HEALTH_REPORT.md`.
2. Include:
   - Deployment status
   - SSL certificate status
   - DNS summary
   - Broken link list
   - robots/sitemap status
   - HTTPS/CORS findings
   - Recommended fixes

## Dependencies

- `gh` CLI
- `webfetch` for HTTP checks and metadata
- Playwright MCP (`@playwright/mcp`) for link crawling
- `openssl` or certificate metadata tools (optional)

## Example Interaction

```
User: Is my GitHub Pages site healthy?

Agent: I'm using the site-health-checker skill. I'll inspect GitHub Pages, SSL, DNS, links, and headers.

[gh pages status: deployed]
[SSL certificate: valid, expires in 60 days]
[DNS: CNAME points to user.github.io]
[Broken links: 2 external links return 404]
[robots.txt and sitemap.xml present]
[HTTPS redirect: working, HSTS enabled]
[Generates SITE_HEALTH_REPORT.md]

Agent: Site is mostly healthy. Fix 2 broken external links and renew SSL before expiry.
```
