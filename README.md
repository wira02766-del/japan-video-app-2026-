# JAPAN VIDEO APP — Cloudflare deployment package

ဒီ ZIP သည် မူလ static mockup ကို Cloudflare Pages frontend + Cloudflare Worker API + D1 + private R2 media storage အဖြစ် တိုးချဲ့ထားသော source package ဖြစ်သည်။ **Cloudflare/Google credentials မထည့်မချင်း online feature များ မအလုပ်လုပ်သေးပါ။** Deploy ပြီးမှ အောက်ပါ checklist ကို လုပ်ပါ။

## Included
- Responsive PWA frontend, Public/Premium/Shorts/Photos/Posts sections
- Google Identity Services sign-in; Worker verifies Google ID token against configured client ID (set it in both wrangler.toml and config.js)
- D1 schema and migrations
- Worker API with server-side admin and premium checks
- R2 upload and authenticated media streaming (max upload 100 MB)
- Admin upload, posts, premium approvals/revocations, ad create/toggle
- Telegram webhook event receiver (metadata/event logging only; it does NOT import/play Telegram channel videos automatically)

## 1. Create Cloudflare resources
In Cloudflare Dashboard:
1. Create D1 database named `japan-video-db`.
2. Copy its Database ID and replace `REPLACE_WITH_YOUR_D1_DATABASE_ID` in `wrangler.toml`.
3. Create R2 bucket named `japan-video-media`.
4. Install Node.js + Wrangler on a computer, or use Cloudflare's supported development workflow. Android-only deployment may be difficult; do not assume the Cloudflare dashboard editor can run Wrangler migrations.

## 2. Configure Google OAuth
1. Google Cloud Console → APIs & Services → Credentials.
2. Create OAuth Client ID → Web application.
3. Add the deployed Pages domain to Authorized JavaScript origins, e.g. `https://YOUR-PAGES.pages.dev`.
4. Put the Web Client ID in `wrangler.toml` as `GOOGLE_CLIENT_ID`.
5. Configure OAuth consent screen and publish/test users as appropriate.
Never paste a client secret into frontend code. This app uses Google Identity Services ID token and server-side verification.

## 3. Configure admin
Set `ADMIN_EMAILS` to the exact Google email(s) that may administer the app. For one admin, replace the placeholder with your own email. This is an allowlist; there is no public admin registration.

## 4. Install dependencies / apply D1 migration / deploy Worker
From this project directory:
```bash
npm install -g wrangler
npx wrangler login
npx wrangler d1 migrations apply japan-video-db --remote
npx wrangler deploy
```
If you use a different Cloudflare account, make sure Wrangler is logged into the account that owns the D1 and R2 resources.

## 5. Connect Worker to existing Pages site
In Cloudflare Dashboard → Workers & Pages → your existing Pages project → Settings → Functions → Service bindings:
- Variable name: `API_WORKER`
- Service: `japan-video-api`
Then update Pages routing or use a Pages Function proxy. **This package currently calls `/api/*` on the same origin; you must add a Pages Function at `functions/api/[[path]].js` to proxy to the service binding**, or configure a same-origin route/proxy. Example:
```js
export async function onRequest({ request, env }) {
  const url = new URL(request.url);
  return env.API_WORKER.fetch(new Request("https://worker.internal" + url.pathname + url.search, request));
}
```
If Cloudflare Pages service binding is not available in your account, use a Worker route on a dedicated API subdomain and change `API` in `app.js` plus configure CORS safely. Do not use wildcard CORS with authorization tokens.

## 6. Worker secrets
```bash
npx wrangler secret put TELEGRAM_WEBHOOK_SECRET
```
This secret is optional unless you configure the Telegram webhook endpoint. Never put Telegram Bot Token in browser code. The current Telegram webhook only logs channel post metadata; it does not automatically mirror Telegram video files to R2.

## 7. Test checklist
- `GET /api/health` returns `{"ok":true,...}`.
- Google login works on the deployed domain.
- First login creates a user with premium status `pending`.
- Add the admin's exact Google email to `ADMIN_EMAILS`, then sign in again.
- Admin can upload image/video to R2; test public playback.
- Upload type `Premium video`; a non-approved account must receive 403 on premium list and media stream.
- Admin can approve/revoke users and toggle ads.
- Test on mobile Chrome and install PWA.

## Important limitations / safety
- No screenshot/screen-recording protection can be guaranteed by a PWA/browser.
- Premium authorization is enforced by Worker on media stream, but once a member can view content they can still capture it using external methods.
- Standard Telegram Bot API is not a general-purpose unlimited streaming CDN. Telegram webhook receiver here records event metadata only. To show Telegram channel media, build a separate authorized ingestion pipeline to copy permitted media into R2, respecting Telegram/API limits and rights.
- Only upload/distribute lawful content you own or are authorized to distribute, featuring consenting adults aged 18+.
- Free Cloudflare quotas and file limits can change; check account billing/limits before large media uploads.
- No payments/subscriptions, comments/likes, automated Telegram video sync, password recovery, or analytics dashboard are implemented in this package. Premium status is manually controlled by admin.
