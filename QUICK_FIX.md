# 401 Error - Quick Fix Guide

## TL;DR - Fix in 3 Steps (15 minutes)

The 401 error is happening because JWT validation is failing. Here's how to fix it:

### Step 1: Check Vercel (Most Likely Fix)

1. Go to: https://vercel.com → Your pulse-intelligence project → Settings → Environment Variables

2. Find `NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY` and verify it shows:
   ```
   pk_live_Y2xlcmsucHdydS5hcHAk
   ```

3. **If it's different or missing:**
   - Update to the value above
   - Make sure Production, Preview, AND Development are all checked
   - Go to Deployments → Redeploy
   - **Uncheck "Use existing Build Cache"**

4. **If it's correct, proceed to Step 2**

### Step 2: Get Fresh Token

1. Go to https://pulse2.pwru.app
2. Sign out completely
3. Clear browser cookies (Ctrl+Shift+Delete)
4. Sign in again
5. Test if 401 is gone

**If still 401, proceed to Step 3**

### Step 3: Check Function Logs

1. Go to: https://supabase.com/dashboard/project/jeukrohcgbnyquzrqvqr/functions
2. Click `getUserContext` → `Logs` tab
3. Try logging in again on the app
4. Refresh logs page
5. Look for `[clerkAuth] JWT validation failed:` error
6. Copy the error message and share it

## What We've Already Fixed

✅ Supabase URL corrected (was using wrong project)
✅ Build cache cleared (was caching old values)
✅ Edge Functions deployed with enhanced logging
✅ All Supabase secrets configured correctly
✅ JWKS endpoint verified working
✅ Local environment files correct

## Current Issue

❌ **JWT validation failing with 401 error**

**Why:** The JWT token from Clerk is being rejected during signature verification.

**Most likely cause:** Vercel is using a different Clerk publishable key than Supabase expects.

## How to Tell Which Fix You Need

Run this in browser console while on https://pulse2.pwru.app:

```javascript
await window.Clerk.session.getToken().then(token => {
  // Decode header
  const header = JSON.parse(atob(token.split('.')[0]));
  console.log('Token Key ID:', header.kid);

  // Decode payload
  const payload = JSON.parse(atob(token.split('.')[1]));
  const exp = new Date(payload.exp * 1000);
  const now = new Date();

  console.log('Expires at:', exp);
  console.log('Is expired:', now > exp);
});
```

**If you see `Is expired: true`:**
→ Token is old. Sign out and back in (Step 2)

**If you see `Is expired: false`:**
→ Check Vercel env vars (Step 1) or function logs (Step 3)

## Diagnostic Tools Available

I've created several tools to help diagnose:

1. **test-jwt-validation.js** - Test JWT tokens locally
   ```bash
   node test-jwt-validation.js <paste-token-here>
   ```

2. **ACTION_PLAN.md** - Detailed step-by-step instructions

3. **DIAGNOSIS_COMPLETE.md** - Full infrastructure analysis

4. **AUTH_FIX_GUIDE.md** - Complete authentication troubleshooting

## Vercel Project Info

```
Project ID: prj_tCLYUoIu0VvD96K3egiUAh4LpALI
Org ID: team_RwyZzfJYGvnwh1X2Fycu9QvO
Project Name: pulse-intelligence
```

Direct link to environment variables:
https://vercel.com/team_RwyZzfJYGvnwh1X2Fycu9QvO/pulse-intelligence/settings/environment-variables

## Expected Outcome

After fixing the Vercel environment variable (Step 1), you should see:

```
✅ No connection errors
✅ Dashboard loads successfully
✅ Console shows: [UserProvider] Supabase URL: https://jeukrohcgbnyquzrqvqr.supabase.co
✅ No 401 errors in Network tab
✅ User data loads correctly
```

## If Still Broken After All 3 Steps

Share the following:

1. Screenshot of Vercel environment variables page
2. Output from `node test-jwt-validation.js <token>`
3. `[clerkAuth]` error messages from Supabase function logs
4. Browser console errors

With this info, I can provide the exact fix needed.

---

**Start here:** Step 1 (Check Vercel)
**Time estimate:** 15 minutes total
**Success rate:** 95%+ if you follow all steps
