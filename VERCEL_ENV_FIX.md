# CRITICAL: Fix Vercel Environment Variables

The build chunks are baking in the WRONG Supabase URL. This is a Vercel configuration issue.

## The Problem

Your build logs show:
```
[UserProvider] Supabase URL: https://zxgoexjnudlauzgpgsua.supabase.co  ❌ WRONG
```

Should be:
```
[UserProvider] Supabase URL: https://jeukrohcgbnyquzrqvqr.supabase.co  ✅ CORRECT
```

## Step-by-Step Fix

### 1. Go to Vercel Dashboard
https://vercel.com/dashboard

### 2. Select Your Project
Click on `pulse2.pwru.app` or whatever your project is named

### 3. Go to Settings → Environment Variables
https://vercel.com/[your-team]/[project-name]/settings/environment-variables

### 4. DELETE ALL Supabase Variables
Delete these if they exist (for ALL environments):
- `NEXT_PUBLIC_SUPABASE_URL`
- `NEXT_PUBLIC_SUPABASE_ANON_KEY`
- `SUPABASE_SERVICE_ROLE_KEY`
- `VITE_SUPABASE_URL` (old, should not exist)
- `VITE_SUPABASE_PUBLISHABLE_KEY` (old, should not exist)

**IMPORTANT**: Make sure to delete from ALL three environments:
- Production
- Preview
- Development

### 5. Add Fresh Variables

Click "Add New" and add these EXACTLY:

**Variable 1:**
```
Key: NEXT_PUBLIC_SUPABASE_URL
Value: https://jeukrohcgbnyquzrqvqr.supabase.co
Environments: Production, Preview, Development (check all three)
```

**Variable 2:**
```
Key: NEXT_PUBLIC_SUPABASE_ANON_KEY
Value: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpldWtyb2hjZ2JueXF1enJxdnFyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjIzODQzMDYsImV4cCI6MjA3Nzk2MDMwNn0.UwUa_vepDbYjZCV5jW0qRBv2cP3mv2MLQ6b6uVIsslk
Environments: Production, Preview, Development (check all three)
```

**Variable 3:**
```
Key: NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY
Value: pk_live_Y2xlcmsucHdydS5hcHAk
Environments: Production, Preview, Development (check all three)
```

### 6. Force a Clean Deployment

After saving the environment variables, you have TWO options:

**Option A: Redeploy from Vercel Dashboard**
1. Go to Deployments tab
2. Click the three dots (...) on the latest deployment
3. Click "Redeploy"
4. **IMPORTANT**: Uncheck "Use existing Build Cache"
5. Click "Redeploy"

**Option B: Trigger from Git (recommended)**
1. Run these commands locally:
```bash
git commit --allow-empty -m "Force rebuild with correct env vars"
git push
```

### 7. Verify the Fix

Once the deployment completes:

1. Go to https://pulse2.pwru.app
2. Open Browser Console (F12)
3. Look for this log:
```
[UserProvider] Supabase URL: https://jeukrohcgbnyquzrqvqr.supabase.co
```

4. If it still shows `zxgoexjnudlauzgpgsua`, the environment variables were NOT saved correctly. Repeat steps 4-6.

## Why This Happens

`NEXT_PUBLIC_*` environment variables are baked into the JavaScript bundle at BUILD TIME, not runtime. If Vercel has the wrong values (or old cached values), they get permanently embedded in the static chunks.

The only way to fix this is to:
1. Ensure Vercel has the correct environment variables
2. Force a fresh build (no cache)
3. Deploy the new build

## Common Mistakes

- ❌ Only updating Production environment (need all three)
- ❌ Not unchecking "Use existing Build Cache" when redeploying
- ❌ Having typos in the environment variable names
- ❌ Having old `VITE_*` variables that override the `NEXT_PUBLIC_*` ones

## Still Not Working?

If you've followed all steps and it's still showing the wrong URL:

1. Check if you have multiple Vercel projects pointing to the same repo
2. Make sure you're viewing the correct deployment (Production, not Preview)
3. Try deleting the project from Vercel and re-importing it fresh
