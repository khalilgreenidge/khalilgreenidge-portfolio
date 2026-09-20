# khalilgreenidge-portfolio

Plain static site (`dist/index.html`, no framework, no build step) served by
Cloudflare Workers static assets at **https://khalilgreenidge.com**.

- `dist/index.html` — the whole site. Edit, commit, push.
- `wrangler.jsonc` — Worker + custom domain config.
- `.github/workflows/deploy.yml` — deploys on every push to `main`.
- `scripts/setup-www-redirect.sh` — one-time: 301s `www` to the apex.

## Editing

Everything (copy, colors, sections) is plain HTML/CSS/JS in `dist/index.html`.
No templating, no build step: edit the file, commit, push. GitHub Actions
redeploys in well under a minute.

## Deploying by hand

```bash
npx wrangler deploy
```

## One-time setup

Already done once; recorded here so it can be rebuilt from scratch.

**1. Authenticate wrangler locally**

```bash
npx wrangler login
```

**2. First deploy** — creates the Worker and both custom domains, and adds the
proxied DNS records for `khalilgreenidge.com` and `www` automatically.

```bash
npx wrangler deploy
```

**3. www to apex redirect**

```bash
CLOUDFLARE_API_TOKEN=... ./scripts/setup-www-redirect.sh
```

**4. CI credentials** — create an API token at
[dash.cloudflare.com/profile/api-tokens](https://dash.cloudflare.com/profile/api-tokens)
using the **Edit Cloudflare Workers** template, scoped to this account and the
`khalilgreenidge.com` zone. To also run `setup-www-redirect.sh`, add
**Zone -> Single Redirect -> Edit** (not Config Rules). Then:

```bash
gh secret set CLOUDFLARE_API_TOKEN
gh secret set CLOUDFLARE_ACCOUNT_ID
```

Account ID is on the Workers & Pages overview page in the dashboard, or from
`npx wrangler whoami`.
