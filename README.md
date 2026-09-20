# khalilgreenidge-portfolio

A plain, portable static site (`dist/index.html`, no framework, no build step) ready to deploy on Cloudflare Workers with static assets, which is Cloudflare's current recommended path for new static sites (Pages still works but isn't where new features land).

## 1. Push to GitHub

From this folder:

```bash
git init
git add .
git commit -m "Initial portfolio site"
gh repo create khalilgreenidge-portfolio --public --source=. --remote=origin --push
```

(No `gh` CLI? Create an empty repo named `khalilgreenidge-portfolio` on github.com first, then:)

```bash
git remote add origin https://github.com/khalilgreenidge/khalilgreenidge-portfolio.git
git branch -M main
git push -u origin main
```

## 2. Deploy once, right now (optional sanity check)

```bash
npx wrangler deploy
```

This publishes it to `khalilgreenidge-portfolio.<your-subdomain>.workers.dev` immediately, no GitHub needed for this step.

## 3. Connect GitHub for auto-deploy on every push

1. Go to the Cloudflare dashboard → **Workers & Pages** → **Create application** → **Import a repository**.
2. Pick `khalilgreenidge-portfolio` from your GitHub account.
3. Leave the build settings as detected (no build command needed, it's already static) and select **Save and Deploy**.

Every future `git push` to `main` now redeploys automatically.

## 4. Point khalilgreenidge.com at it

In the Worker's settings → **Domains & Routes** → **Add** → **Custom Domain** → enter `khalilgreenidge.com` (and `www.khalilgreenidge.com` if you want both). Since the domain is already on your Cloudflare account, the DNS record is added for you automatically.

## Editing later

Everything, copy, colors, sections, is plain HTML/CSS/JS in `dist/index.html`. No templating, no build step: edit the file, commit, push, done.
