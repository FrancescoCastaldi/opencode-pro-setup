---
name: web-architect
description: Design and document website architecture for GitHub-hosted projects. Analyzes existing site architecture, recommends hosting strategies, plans CI/CD, migrations, and preview environments.
license: MIT
metadata:
  author: Francesco Castaldi
  tags: [architecture, website, github-pages, vercel, ci-cd, migration, preview]
---

# web-architect

## What I do

I design and document website architecture for GitHub-hosted projects. I analyze the current architecture (SSG, SSR, SPA, static), recommend the best hosting strategy, design CI/CD pipelines, plan migrations, and set up preview environments.

## When to use

- When starting a new website project
- When choosing or changing hosting strategy
- When planning a migration (e.g., Jekyll → Next.js)
- When setting up CI/CD or preview environments
- When documenting architecture decisions

## Workflow

### Step 1: Analyze existing site architecture

1. Detect framework and build approach:
   - Static site generator (Jekyll, Hugo, Eleventy, Astro)
   - React framework (Next.js, Gatsby, Remix)
   - Vue/Nuxt or Svelte/SvelteKit
   - Plain static HTML
   - Single-page application (SPA)
2. Identify rendering strategy:
   - Static site generation (SSG)
   - Server-side rendering (SSR)
   - Client-side rendering (SPA)
   - Hybrid / islands architecture
3. Note dependencies, build output, and routing.

### Step 2: Recommend hosting strategy

1. Compare options:
   - **GitHub Pages**: ideal for static/Jekyll sites, free, custom domain support.
   - **Vercel**: ideal for Next.js, SSR, edge functions, previews.
   - **Netlify**: ideal for static/SSG, forms, edge functions.
   - **Hybrid**: SSG on Pages + dynamic functions on Vercel/Netlify.
2. Consider traffic, build time, dynamic features, and budget.
3. Recommend the best option and justify.

### Step 3: Design CI/CD pipeline

1. Define triggers: push, pull request, release.
2. Define stages:
   - Install dependencies
   - Lint and type-check
   - Build
   - Test (optional)
   - Deploy (staging / production)
3. Choose GitHub Actions workflows and deployment targets.

### Step 4: Plan migration between frameworks

1. Document current and target architecture.
2. Identify content, routes, assets, and SEO that must migrate.
3. Plan phases: content export, template rebuild, asset move, URL redirects, SEO preservation.
4. Estimate risks and rollback strategy.

### Step 5: Set up preview environments

1. For GitHub Pages, create a workflow that deploys PRs to a subdirectory or separate staging repo.
2. For Vercel/Netlify, enable automatic branch previews.
3. Add PR comments with preview links.

### Step 6: Document architecture decisions

1. Create `docs/ARCHITECTURE.md` or update `README.md`.
2. Include:
   - Architecture overview
   - Hosting decision and rationale
   - CI/CD pipeline diagram
   - Migration plan (if applicable)
   - Preview environment strategy
   - Security and performance notes

## Dependencies

- `gh` CLI
- GitHub MCP server (`@modelcontextprotocol/server-github`)
- Framework-specific build tools
- `webfetch` for verifying live sites

## Example Interaction

```
User: Plan the architecture for migrating my Jekyll site to Next.js on GitHub.

Agent: I'm using the web-architect skill. I'll analyze the current site, recommend hosting, and design the migration and CI/CD.

[Detects Jekyll site with Markdown posts and a custom theme]
[Recommends Next.js static export hosted on GitHub Pages with Vercel fallback for dynamic features]
[Designs CI/CD: lint, build, test, deploy to Pages on main, preview on PRs]
[Plans migration phases: content export, MDX conversion, theme rebuild, redirects, RSS]
[Creates docs/ARCHITECTURE.md with decision records and diagrams]

Agent: Architecture plan complete. Recommended: Next.js static export on GitHub Pages, with PR previews via GitHub Actions.
```
