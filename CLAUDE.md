# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Standalone marketing landing page for **Edital Inteligente** (a Garagem product) — a platform
for funding capture via *editais de fomento* (grant calls). PT-BR copy throughout. There is no
backend, no framework, and no build step: the entire site is one self-contained `index.html`.

## Architecture

- **`index.html`** (~1400 lines) holds everything: markup, the full design system as inline CSS
  inside a single `<style>` block, plus two tiny inline `<script>`s (an anti-FOUC theme initializer
  in the `<head>` and a footer one that sets the year and wires the theme toggle). No external JS,
  no bundler, no `package.json`, no `node_modules`. The only network dependency is Google Fonts
  (Orbitron + Funnel Display).
- **Design system** lives in CSS custom properties. The light theme is in `:root`, the dark theme
  in `[data-theme="dark"]` (set on `<html>`). The brand is monochrome — teal `--primary` (#4CBFAA)
  + navy `#0E1C3B`, off-white `#F8F1FE` / near-black backgrounds, **no gradient** (`--gradient` is a
  flat teal kept only so the existing `background-clip:text` call sites render solid teal). Change
  brand colors in the tokens, not at call sites. Typography helpers: `.display` (Orbitron, uppercase
  headings) and `.gradient-text` (solid teal accent). Theme toggle persists to `localStorage` and
  defaults from `prefers-color-scheme`.
- **Page sections** are ordered top-to-bottom in the body, each delimited by a `<!-- ===== NAME ===== -->`
  comment and anchored by `id` (`como-funciona`, `veredito`, `barema`, `pipeline`, `documentacao`,
  `relatorios`, `para-quem`). The sticky header nav links to these anchors. Edit a section by finding
  its comment banner.
- **`brand/`** — vector brand kit extracted from the PDF: `symbol`, `horizontal` (symbol + wordmark)
  and `vertical` (stacked) lockups, each as a `currentColor` master plus fixed tints
  `-teal/-navy/-white/-black`. The page itself inlines only the symbol (`symbol.svg`, via an SVG
  `<symbol id="brand-mark">` sprite so the header/footer marks tint with the theme) and recomposes the
  "EDITAL / inteligente" wordmark as live text (Orbitron + Funnel Display); the standalone `horizontal`/
  `vertical` SVGs carry the wordmark as outlines for og:image, print, or font-less contexts.
  `symbol-teal.svg` is the favicon. Served static and cached 7d by nginx. Source of truth:
  `src/logos/id - Edital Inteligente.pdf` (CorelDRAW export).

## Serving & deployment

The site is served by **nginx in Docker**, deployed on **Railway** (`railway.toml`, builder =
`DOCKERFILE`). Flow:

- `Dockerfile` — `nginx:alpine`, copies `index.html` + `brand/` to the web root, installs `gettext`
  for `envsubst`, exposes `8080`.
- `docker-entrypoint.sh` — at container start, runs `envsubst` to substitute `${PORT}` (default 8080,
  set by Railway) into `nginx/default.conf.template`, producing the live `default.conf`. This is the
  only reason the port is dynamic — nginx itself has no env-var support.
- `nginx/default.conf.template` — server block: SPA-style `try_files ... /index.html` fallback,
  security headers, gzip, long-cache rules for `/brand/` and image extensions, and a `/healthz`
  endpoint returning `ok`.
- `nginx/nginx.conf` — base http/events config.
- Railway healthcheck path is **`/`** (see `railway.toml`), not `/healthz`, even though the nginx
  `/healthz` route exists.

## Common commands

```bash
# Quick local preview — open the file directly (Google Fonts load over network)
start index.html              # Windows

# Test exactly as production (nginx + envsubst), serving on http://localhost:8080
docker build -t edital-landing .
docker run --rm -p 8080:8080 edital-landing
```

There are no tests, linters, or build scripts in this repo.

## Conventions

- All user-facing copy is **PT-BR**. Keep tone formal/institutional to match existing sections
  (this is a B2B/B2G product page).
- Per global frontend rule: **no comments in view/CSS code** — the `<!-- ===== NAME ===== -->`
  section banners are the one intentional exception (navigation aid); don't add per-rule or
  per-element comments. Refactor/rename for clarity instead.
- `.dockerignore` strips `*.md`, env files, and editor dirs from the image — markdown like this
  file never ships to production.
