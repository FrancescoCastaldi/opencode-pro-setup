---
name: site-deployer
description: Deploy websites to GitHub Pages and integrate with Vercel/Netlify when detected. Configures GitHub Pages, custom domains, 404 pages, GitHub Actions workflows, and deploy previews.
license: MIT
metadata:
  author: Francesco Castaldi
  tags: [deploy, github-pages, vercel, netlify, actions, custom-domain, website]
---

# site-deployer

## What I do

I configure and deploy websites to GitHub Pages from a repository. I can also set up Vercel or Netlify integration when those platforms are detected, configure custom domains, 404 pages, and deploy previews for PRs.

## When to use

- Setting up a new site on GitHub Pages
- Migrating a site to GitHub Pages
- Configuring a custom domain or HTTPS
- Adding CI/CD deployment workflows
- Enabling PR previews for a static site

## Workflow

### Step 1: Detect site framework

1. Check for static site generator or framework files:
   - Jekyll: `_config.yml`, `Gemfile`
   - Hugo: `hugo.toml`, `config.toml`
   - Next.js: `next.config.js` / `next.config.ts`
   - Nuxt: `nuxt.config.ts`
   - Astro: `astro.config.mjs`
   - Vite: `vite.config.*`
   - Plain HTML: `index.html`

### Step 2: Configure GitHub Pages

1. Use `gh` or GitHub MCP to enable Pages:

```bash
gh api repos/owner/repo/pages --method POST \
  -f source='{ "branch": "gh-pages", "path": "/" }'
```

Or set source to `{ "branch": "main", "path": "/docs" }`.

2. Configure custom domain in repository settings.
3. Add `CNAME` file if a custom domain is used.

### Step 3: Configure build and deploy workflow

1. Create `.github/workflows/deploy.yml` that:
   - Triggers on push to `main` and on PRs
   - Sets up the framework runtime
   - Builds the site
   - Deploys to GitHub Pages using `actions/deploy-pages`
   - Optionally uploads artifacts for PR previews

### Step 4: Set up 404 page

1. Ensure a `404.html` page is generated at the site root.
2. For Jekyll, add `permalink: /404.html`.
3. For Next.js, add `pages/404.tsx` or use `not-found.tsx`.

### Step 5: Integrate Vercel/Netlify if detected

1. If `next.config.js` or `vercel.json` exists, offer Vercel integration.
2. If `netlify.toml` exists, offer Netlify integration.
3. Generate the appropriate configuration file and suggest adding the GitHub app.

### Step 6: Enable PR deploy previews

1. For GitHub Pages, add a PR preview job that uploads the built site to a preview path.
2. For Vercel/Netlify, PR previews are usually automatic after integration.

### Step 7: Verify deployment

1. Wait for the workflow to finish.
2. Check the Pages URL or custom domain.
3. Use the `site-health-checker` skill to confirm the live site is healthy.

## Dependencies

- `gh` CLI
- GitHub MCP server (`@modelcontextprotocol/server-github`)
- `webfetch` for post-deploy verification
- Playwright MCP for full-page verification

## Example Interaction

```
User: Deploy my Next.js site to GitHub Pages.

Agent: I'm using the site-deployer skill. I'll configure GitHub Pages, add a deploy workflow, and verify the live site.

[Detects Next.js with static export configured]
[Enables Pages with source branch gh-pages]
[Creates .github/workflows/deploy.yml with build and deploy steps]
[Adds 404.html fallback]
[Workflow runs successfully]
[Verifies site with site-health-checker]

Agent: Site deployed to https://owner.github.io/repo. The custom domain and 404 page are configured.
```
