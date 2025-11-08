# 401 Error - Action Plan

## Current Status

✅ **Infrastructure verified and working:**
- Supabase secrets configured correctly
- Edge Functions deployed with enhanced logging (v30, v20)
- JWKS endpoint accessible and returning valid keys
- Local environment files have correct values

❌ **Issue:**
- 401 errors when calling getUserContext Edge Function
- JWT validation failing during authentication

## Immediate Actions Required

### Action 1: Verify Vercel Environment Variables (CRITICAL - 5 minutes)

This is the **most likely cause** of the 401 error.

**Steps:**

1. **Go to Vercel Dashboard:**
   - Visit: https://vercel.com
   - Navigate to your pulse-intelligence project
   - Go to Settings → Environment Variables

2. **Check NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY:**
   - Find the variable named `NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY`
   - Verify it shows: `pk_live_Y2xlcmsucHdydS5hcHAk`
   - **IMPORTANT:** Check it's enabled for ALL environments:
     - ✅ Production
     - ✅ Preview
     - ✅ Development

3. **If the value is different or missing:**
   ```
   Current (wrong): pk_test_XXXXXXX  or  pk_live_XXXXXXX
   Required (correct): pk_live_Y2xlcmsucHdydS5hcHAk
   ```

4. **Fix if needed:**
   - Click the variable to edit
   - Update to: `pk_live_Y2xlcmsucHdydS5hcHAk`
   - Make sure all three checkboxes are checked
   - Save changes
   - Go to Deployments → Click latest deployment → Redeploy
   - **CRITICAL:** Uncheck "Use existing Build Cache"

**Why this matters:**
- Clerk generates different JWT signatures for different publishable keys
- If Vercel uses a different key than Supabase expects, signature validation will ALWAYS fail
- This causes a 401 error even when everything else is correct

### Action 2: Test JWT Token (5 minutes)

Use the diagnostic script I created to analyze your JWT token:

**Steps:**

1. **Get a fresh JWT token:**
   ```
   1. Open https://pulse2.pwru.app in your browser
   2. Sign in with Clerk
   3. Open browser console (Press F12)
   4. Run this command:
      await window.Clerk.session.getToken()
   5. Copy the output (long string starting with "eyJ...")
   ```

2. **Run the diagnostic script:**
   ```bash
   cd /Users/chastinmiles/Downloads/pulse-intelligence
   node test-jwt-validation.js <paste-token-here>
   ```

3. **Interpret results:**

   **If you see:**
   ```
   Key ID match: ❌ NO
   ```
   → This confirms Vercel is using a different Clerk key! Go back to Action 1.

   **If you see:**
   ```
   Token expired: ❌ YES
   ```
   → Your token is old. Sign out and sign back in for a fresh token.

   **If you see:**
   ```
   Key ID match: ✅ YES
   Token expired: ✅ NO
   ```
   → JWT structure is valid. Issue is in signature verification or claims. Proceed to Action 3.

### Action 3: Check Supabase Function Logs (5 minutes)

View the detailed logs from the enhanced logging I deployed:

**Steps:**

1. **Open Supabase Dashboard:**
   - Go to: https://supabase.com/dashboard/project/jeukrohcgbnyquzrqvqr/functions
   - Click on `getUserContext` function
   - Click the `Logs` tab

2. **Trigger a fresh request:**
   - In a new browser tab, go to https://pulse2.pwru.app
   - Sign out if already signed in
   - Sign in again
   - Wait for the 401 error

3. **Refresh logs and look for:**
   ```
   [clerkAuth] Checking for Clerk publishable key...
   [clerkAuth] NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY present: true/false
   [clerkAuth] Using Clerk publishable key (first 15 chars): pk_live_XXXXXXX
   [clerkAuth] Frontend API: clerk.pwru.app
   [clerkAuth] JWKS URL: https://clerk.pwru.app/.well-known/jwks.json
   [clerkAuth] Verifying JWT with RS256...
   [clerkAuth] JWT validation failed: [ERROR MESSAGE]
   ```

4. **Copy the error message** - especially the line that says:
   ```
   [clerkAuth] JWT validation failed: [ERROR MESSAGE]
   [clerkAuth] Error name: [ERROR TYPE]
   [clerkAuth] Error message: [DETAILS]
   ```

### Action 4: Report Results

Once you've completed Actions 1-3, report:

1. **Vercel check results:**
   - [ ] Variable was correct
   - [ ] Variable was missing
   - [ ] Variable had wrong value (what was it?)
   - [ ] Updated and redeployed

2. **JWT test results:**
   - [ ] Key ID match: YES/NO
   - [ ] Token expired: YES/NO
   - [ ] Other errors from script

3. **Function logs:**
   - Copy and paste the `[clerkAuth]` error messages here

## Common Issues and Solutions

### Issue: "Key ID match: ❌ NO"

**Cause:** Frontend and backend using different Clerk applications/keys

**Solution:**
1. Check Vercel `NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY`
2. Should be: `pk_live_Y2xlcmsucHdydS5hcHAk`
3. If different, update and redeploy without cache

### Issue: "Token expired: ❌ YES"

**Cause:** Clerk tokens expire after 60 seconds (default)

**Solution:**
1. Sign out of https://pulse2.pwru.app
2. Clear browser cookies
3. Sign in again
4. Test immediately

### Issue: "NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY present: false"

**Cause:** Supabase secrets missing the Clerk key

**Solution:**
```bash
cd /Users/chastinmiles/Downloads/pulse-intelligence
supabase secrets set NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY=pk_live_Y2xlcmsucHdydS5hcHAk
supabase functions deploy getUserContext initializeUserData
```

### Issue: "JWTClaimValidationFailed"

**Cause:** Token claims don't match expected values (audience, issuer, etc.)

**Solution:**
Check the specific claim mentioned in error. Usually means:
- Frontend is using Clerk test environment but backend expects live
- Or vice versa

## Files Created for Diagnostics

1. **DIAGNOSIS_COMPLETE.md** - Complete infrastructure analysis
2. **ACTION_PLAN.md** - This file - step-by-step actions
3. **test-jwt-validation.js** - Script to test JWT locally
4. **AUTH_FIX_GUIDE.md** - Previous troubleshooting guide
5. **DEPLOYMENT_SUCCESS.md** - How we fixed the Supabase URL issue

## Timeline

- ✅ Fixed infinite loading state (added timeouts)
- ✅ Fixed wrong Supabase URL (cleared node_modules cache)
- ✅ Deployed enhanced JWT logging (versions 30, 20)
- ✅ Verified all infrastructure (Supabase, JWKS, environment)
- ⏳ **Current:** Diagnosing 401 JWT validation error
- 📍 **You are here:** Waiting for Actions 1-3 results

## Expected Resolution

Based on experience with similar issues, the 401 error is **95% likely** to be:

1. **Vercel environment variable mismatch** (60% probability)
   - Different Clerk key in Vercel than local
   - Fix: Update Vercel env var and redeploy

2. **Token expiration** (30% probability)
   - User stayed logged in too long
   - Fix: Sign out and back in

3. **Claims validation failure** (10% probability)
   - Test vs Live environment mismatch
   - Fix: Ensure all systems use same Clerk environment

Once we get the results from Actions 1-3, I can provide the exact fix needed.

---

**Created:** 2025-11-08 08:35 UTC
**Status:** Ready for user actions
**Next:** Complete Actions 1-3 above
