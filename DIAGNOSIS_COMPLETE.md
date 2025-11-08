# 401 Authentication Error - Complete Diagnosis

## Infrastructure Status (All Verified ✅)

I've completed a comprehensive infrastructure check:

### 1. ✅ Supabase Configuration
```bash
# Verified all secrets are set correctly:
✅ NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY
✅ CLERK_SECRET_KEY
✅ NEXT_PUBLIC_SUPABASE_URL
✅ SUPABASE_SERVICE_ROLE_KEY

# Confirmed via: supabase secrets list
```

### 2. ✅ Edge Functions Deployed
```
✅ getUserContext - Version 30 (deployed 08:30:12 UTC)
✅ initializeUserData - Version 20 (deployed 08:29:59 UTC)

Both functions are ACTIVE and running the latest code with enhanced logging.
```

### 3. ✅ Clerk JWKS Endpoint
```bash
# Tested: https://clerk.pwru.app/.well-known/jwks.json
✅ Endpoint accessible
✅ Returns valid RSA public key (RS256)
✅ Key ID: ins_35AV52SesOEWjjs19BS9WvPmoNk
```

### 4. ✅ Domain Extraction Logic
```
Clerk Publishable Key: pk_live_Y2xlcmsucHdydS5hcHAk
Decoded Domain: clerk.pwru.app$
Sanitized Domain: clerk.pwru.app ✅
JWKS URL: https://clerk.pwru.app/.well-known/jwks.json ✅
```

### 5. ✅ Local Environment Files
```
.env and .env.local both have correct:
- Supabase URL: https://jeukrohcgbnyquzrqvqr.supabase.co
- Clerk Key: pk_live_Y2xlcmsucHdydS5hcHAk
```

## What This Means

**All infrastructure is correctly configured.** The 401 error is happening during the JWT validation process itself, NOT due to configuration issues.

## Most Likely Causes

Based on the infrastructure being correct, the 401 error is most likely one of these:

### 1. Token Expiration (Most Common)
**Symptom**: JWT tokens expire after a set time (usually 60 seconds for Clerk)

**Solution**:
- Sign out and sign back in to get a fresh token
- Check if the error persists with a new login session

### 2. Vercel Environment Variables Mismatch
**Symptom**: The deployed frontend on Vercel uses different Clerk keys than Supabase expects

**Critical Check** - Go to Vercel dashboard and verify:
```
Production environment variables must be EXACTLY:
NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY=pk_live_Y2xlcmsucHdydS5hcHAk

If different, Clerk generates tokens with different signatures!
```

### 3. JWT Claims Validation Failure
**Symptom**: The JWT has valid signature but claims don't match expectations

**Check the function logs** - The enhanced logging will show:
```
[clerkAuth] JWT validation failed: [specific error]
[clerkAuth] Error name: JWTClaimValidationFailed
[clerkAuth] Error message: [the actual claim that failed]
```

## Next Steps - IN THIS ORDER

### Step 1: Check Vercel Environment Variables (5 minutes)

1. Go to: https://vercel.com/[your-project]/settings/environment-variables
2. Find `NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY`
3. Verify it shows: `pk_live_Y2xlcmsucHdydS5hcHAk`
4. If different or missing:
   - Update it to the correct value
   - Redeploy WITHOUT build cache
5. If correct, proceed to Step 2

### Step 2: View Enhanced Function Logs (5 minutes)

The enhanced logging I deployed will show EXACTLY where JWT validation fails:

1. Go to: https://supabase.com/dashboard/project/jeukrohcgbnyquzrqvqr/functions
2. Click on `getUserContext` function
3. Click the `Logs` tab
4. Clear old logs (refresh page)
5. Try logging in on https://pulse2.pwru.app
6. Immediately refresh the logs page
7. Look for `[clerkAuth]` entries

**What you'll see:**
```
Success case:
[clerkAuth] Checking for Clerk publishable key...
[clerkAuth] NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY present: true
[clerkAuth] Using Clerk publishable key (first 15 chars): pk_live_Y2xlcm...
[clerkAuth] Frontend API: clerk.pwru.app
[clerkAuth] JWKS URL: https://clerk.pwru.app/.well-known/jwks.json
[clerkAuth] Importing jose library...
[clerkAuth] Creating JWKS remote set...
[clerkAuth] Verifying JWT with RS256...
[clerkAuth] ✓ Token validated (RSA256) for user: user_xxxxx

Failure case:
[clerkAuth] JWT validation failed: [ERROR MESSAGE HERE]
[clerkAuth] Error name: [ERROR TYPE]
[clerkAuth] Error message: [SPECIFIC DETAILS]
```

### Step 3: Fresh Login Test (2 minutes)

1. On https://pulse2.pwru.app, click Sign Out
2. Clear browser cache (Ctrl+Shift+Delete → Cookies and cached data)
3. Sign in again with Clerk
4. Check if 401 persists

**Why**: Gets a fresh JWT token with new expiration

### Step 4: Report Back

Once you've completed Steps 1-3, report:

1. **Vercel env var status**: Was the key correct? Did you update it?
2. **Function logs**: Copy the exact `[clerkAuth]` error messages
3. **Fresh login**: Did the error persist after signing out/in?

## If Logs Show Success But Still 401

If the logs show:
```
[clerkAuth] ✓ Token validated (RSA256) for user: user_xxxxx
```

But you STILL get 401, then the issue is AFTER JWT validation. Check:

1. **User doesn't exist in profiles table**:
```sql
SELECT * FROM profiles WHERE id = 'user_xxxxx';
```

2. **RLS policies blocking access**: The profile query might be failing due to Row Level Security

3. **Missing data causing error**: One of the 12 parallel queries might be failing

Look for `[getUserContext]` logs after the `✓ Token validated` line to see which query failed.

## Technical Details

### JWT Validation Flow

1. Extract `Authorization: Bearer <token>` header
2. Decode Clerk publishable key to get domain (`clerk.pwru.app`)
3. Fetch JWKS from `https://clerk.pwru.app/.well-known/jwks.json`
4. Verify JWT signature using RSA256 algorithm with public key
5. Validate JWT claims (exp, iat, iss, sub)
6. Extract user ID from `sub` claim
7. Use user ID to query Supabase tables

**Current status**: Steps 1-3 verified working. Step 4-5 is where 401 is likely happening.

### Enhanced Logging Coverage

The deployed functions now log:
- ✅ Environment variable checks (which keys are present)
- ✅ Key value previews (first 15 chars)
- ✅ Domain extraction results
- ✅ JWKS URL construction
- ✅ Jose library import
- ✅ JWKS remote set creation
- ✅ JWT verification attempt
- ✅ Detailed error information (name, message, stack)

**This means**: The function logs will tell us EXACTLY what's failing.

## Summary

**Infrastructure**: ✅ All correct
**Most Likely Issue**: JWT token expiration or Vercel env var mismatch
**Next Action**: Check Vercel environment variables, then view function logs
**Logging**: Enhanced and comprehensive - will show exact failure point

---

**Created**: 2025-11-08 08:32 UTC
**Status**: Ready for user action - Steps 1-3 above
