---
name: site-optimizer
description: Optimize websites hosted on GitHub for SEO, performance, accessibility, and mobile responsiveness. Analyzes meta tags, Core Web Vitals readiness, ARIA, contrast, keyboard navigation, and page speed.
license: MIT
metadata:
  author: Francesco Castaldi
  tags: [seo, performance, accessibility, core-web-vitals, mobile, optimization, website]
---

# site-optimizer

## What I do

I optimize websites hosted on GitHub for search engines, performance, accessibility, and mobile experience. I analyze meta tags, Core Web Vitals readiness, accessibility, mobile responsiveness, and page speed opportunities.

## When to use

- Before launching a public site
- During SEO or performance audits
- When improving accessibility compliance
- After major content or design changes

## Workflow

### Step 1: Analyze SEO meta tags

1. Fetch the site with `webfetch` or Playwright MCP.
2. Check:
   - `<title>` length and uniqueness
   - `<meta name="description">`
   - Open Graph tags (`og:title`, `og:description`, `og:image`, `og:url`)
   - Twitter Card tags
   - Canonical URL
   - Schema.org structured data

### Step 2: Check Core Web Vitals readiness

1. Use Playwright MCP to collect:
   - Largest Contentful Paint (LCP)
   - First Input Delay (FID) / Interaction to Next Paint (INP)
   - Cumulative Layout Shift (CLS)
2. Check for render-blocking resources.
3. Verify image and script optimization.

### Step 3: Audit accessibility

1. Check ARIA roles and attributes.
2. Verify color contrast ratios.
3. Test keyboard navigation and focus order.
4. Ensure images have alt text and forms have labels.
5. Check for skip links and semantic HTML.

### Step 4: Check mobile responsiveness

1. Use Playwright MCP to emulate common devices.
2. Check viewport meta tag.
3. Verify layout does not break at mobile widths.
4. Check tap target sizes and font sizes.

### Step 5: Analyze page speed opportunities

1. Identify large images, unoptimized fonts, and unused CSS/JS.
2. Check for caching headers and compression.
3. Suggest lazy loading, code splitting, and asset optimization.

### Step 6: Generate optimization report

1. Create `SITE_OPTIMIZATION_REPORT.md`.
2. Include:
   - SEO score and issues
   - Core Web Vitals metrics
   - Accessibility findings
   - Mobile responsiveness status
   - Speed opportunities
   - Priority queue of fixes

## Dependencies

- Playwright MCP (`@playwright/mcp`)
- `webfetch` for static metadata
- `lighthouse` CLI or Playwright performance metrics (optional)

## Example Interaction

```
User: Optimize my GitHub Pages site for SEO and accessibility.

Agent: I'm using the site-optimizer skill. I'll audit SEO, performance, accessibility, and mobile readiness.

[Checks title, description, OG tags, canonical — missing og:image]
[Measures LCP 2.1s, CLS 0.05 — LCP needs improvement]
[Accessibility: low contrast on footer links, missing alt text on 3 images]
[Mobile: viewport OK, tap targets too small on navigation]
[Generates SITE_OPTIMIZATION_REPORT.md with priority queue]

Agent: Top priorities: add og:image, fix footer contrast, add alt text, and lazy-load hero image.
```
