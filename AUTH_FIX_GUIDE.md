# 401 Authentication Error - Fix Guide

## ✅ Progress So Far

1. ✅ Fixed the Supabase URL (now using correct `jeukrohcgbnyquzrqvqr`)
2. ✅ Functions are deployed and accessible
3. ❌ 401 error - Clerk JWT validation is failing

## The Current Issue

The Edge Functions are rejecting the Clerk JWT token during validation. This is an authentication/authorization issue, not a connection issue.

## How to View Function Logs

To see the actual error from the Edge Functions:

### Option 1: Supabase Dashboard (Easiest)

1. Go to: https://supabase.com/dashboard/project/jeukrohcgbnyquzrqvqr/functions
2. Click on "getUserContext" function
3. Click the "Logs" tab
4. Try logging in again on your site
5. Refresh the logs page
6. Look for error messages with `[clerkAuth]` prefix

### Option 2: Real-time Logs via CLI

```bash
# You can't use `supabase functions logs` with current CLI version
# Use the dashboard instead
```

## What to Look For in the Logs

The enhanced logging I just added will show:

```
[clerkAuth] Checking for Clerk publishable key...
[clerkAuth] NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY present: true/false
[clerkAuth] Using Clerk publishable key (first 15 chars): pk_live_Y2xlcm...
[clerkAuth] Key parts: 3
[clerkAuth] Frontend API: clerk.pwru.app
[clerkAuth] JWKS URL: https://clerk.pwru.app/.well-known/jwks.json
[clerkAuth] Importing jose library...
[clerkAuth] Creating JWKS remote set...
[clerkAuth] Verifying JWT with RS256...
[clerkAuth] ✓ Token validated (RSA256) for user: user_xxxxx
```

If there's an error, you'll see:
```
[clerkAuth] JWT validation failed: [error message]
[clerkAuth] Error name: JWTClaimValidationFailed
[clerkAuth] Error message: [specific error]
```

## Common Causes & Fixes

### 1. Wrong Clerk Publishable Key

**Symptom:** Logs show `NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY present: false`

**Fix:**
```bash
supabase secrets set NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY=pk_live_Y2xlcmsucHdydS5hcHAk
supabase functions deploy getUserContext initializeUserData
```

### 2. JWKS URL Unreachable

**Symptom:** Error about "Failed to fetch JWKS" or network error

**Fix:** The frontend API domain might be wrong. Check the logs for:
```
[clerkAuth] Frontend API: clerk.pwru.app
```

Verify this domain is correct by visiting: https://clerk.pwru.app/.well-known/jwks.json
(Should return JSON with Clerk's public keys)

### 3. Token Expired

**Symptom:** Error message contains "expired" or "exp claim"

**Fix:** User needs to sign out and sign back in to get a fresh token.

### 4. Invalid Token Format

**Symptom:** Error about "invalid token" or "malformed JWT"

**Fix:** This usually means Clerk configuration on the frontend doesn't match the backend.

Verify your Clerk publishable key in Vercel matches what's in Supabase:
- Vercel: `NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY=pk_live_Y2xlcmsucHdydS5hcHAk`
- Supabase: Same value

### 5. CORS/Network Issue with JWKS

**Symptom:** Logs stop at "Creating JWKS remote set..." without proceeding

**Fix:** The Supabase Edge Function can't reach Clerk's JWKS endpoint. This is rare but could be a Supabase/Clerk connectivity issue.

Try:
```bash
# Test if JWKS is accessible
curl https://clerk.pwru.app/.well-known/jwks.json
```

## Quick Fix Steps

1. **Try logging in** on https://pulse2.pwru.app
2. **Go to Supabase Dashboard logs** immediately after
3. **Copy the error message** from the logs
4. **Share the specific error** so we can diagnose

## If Logs Show Success But Still 401

If the logs show:
```
[clerkAuth] ✓ Token validated (RSA256) for user: user_xxxxx
```

But you still get 401, the issue is AFTER JWT validation. Possible causes:
- User doesn't exist in `profiles` table
- RLS (Row Level Security) policies blocking access
- Missing permissions

Check if user exists:
```sql
SELECT * FROM profiles WHERE id = 'user_xxxxx';
```

## Next Steps

1. **View the Supabase logs** following instructions above
2. **Try logging in** to trigger the error
3. **Copy the specific error message**
4. **Let me know what you see** in the logs

The enhanced logging will show us exactly where the JWT validation is failing, which will tell us the exact fix needed.

---

**Remember:** We've already confirmed:
- ✅ Correct Supabase URL is being used
- ✅ Functions are deployed and running
- ✅ Clerk token is being sent from frontend

The remaining issue is just the JWT validation logic, which the logs will reveal.
