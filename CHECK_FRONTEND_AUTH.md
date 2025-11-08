# Check Frontend Authentication

## Issue: Logs Show "User as Anonymous"

This means the Authorization header is **NOT reaching the Edge Function**, or Clerk is not returning a token.

## Immediate Checks

### 1. Check Browser Console (F12)

Look for these specific log messages when you try to log in:

**Expected successful flow:**
```
[UserProvider] Supabase URL: https://jeukrohcgbnyquzrqvqr.supabase.co
[UserProvider] Token obtained, calling backend functions...
[UserProvider] Ensuring user defaults exist...
[UserProvider] Calling getUserContext...
```

**If you see this instead:**
```
[UserProvider] Failed to get authentication token
```
→ Clerk is not returning a token. This is the problem!

### 2. Test Clerk Directly in Console

While on https://pulse2.pwru.app (after logging in), run this in browser console:

```javascript
// Check if Clerk is loaded
console.log('Clerk loaded:', !!window.Clerk);

// Check if there's an active session
console.log('Active session:', !!window.Clerk?.session);

// Try to get a token
window.Clerk.session.getToken()
  .then(token => {
    if (token) {
      console.log('✅ Token obtained!');
      console.log('Token length:', token.length);
      console.log('Token preview:', token.substring(0, 50) + '...');
    } else {
      console.log('❌ Token is null/undefined');
    }
  })
  .catch(err => {
    console.log('❌ Error getting token:', err);
  });
```

### 3. Check Network Tab

1. Open DevTools → Network tab
2. Clear network log
3. Try to log in / refresh page
4. Filter by "getUserContext"
5. Click on the request
6. Go to "Headers" section
7. Look for **Request Headers**
8. Check if there's an `authorization` or `Authorization` header

**Expected:**
```
Authorization: Bearer eyJhbGci...
```

**If missing:**
→ The token is not being sent with the request

## Common Causes

### Cause 1: Clerk Session Not Ready

**Symptom:** `window.Clerk.session` is null or undefined

**Why:** The `useAuth()` hook in UserProvider might be running before Clerk is fully loaded

**Check the UserProvider code around line 20-30:**
```javascript
const { getToken } = useAuth();
const { user: clerkUser, isLoaded: isClerkLoaded } = useUser();
```

Make sure `isClerkLoaded` is true before calling `getToken()`

### Cause 2: Clerk Environment Variables Wrong

**Symptom:** Clerk loads but session is always null

**Check Vercel env vars:**
```
NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY=pk_live_Y2xlcmsucHdydS5hcHAk
CLERK_SECRET_KEY=sk_live_zv93Ovf393JP0OJoVS9ZKqgGWwz42GZStFCJ9XYiSm
```

If these don't match on Vercel, Clerk won't work properly.

### Cause 3: Clerk Middleware Blocking

**Check:** Do you have middleware.ts or middleware.js in your project?

If yes, make sure it includes:
```typescript
export default clerkMiddleware()
```

And NOT blocking the routes you're trying to access.

### Cause 4: CORS Stripping Headers

**Symptom:** Header is sent but not received by Edge Function

**Check Supabase function logs for:**
```
[getUserContext] Auth header present: false
```

If the log shows `present: false` but Network tab shows it was sent, it's a CORS issue.

**Fix:** Edge Function already has CORS headers, but check if OPTIONS preflight is working:
- In Network tab, look for an OPTIONS request to getUserContext
- It should return 204 status

## Quick Diagnostic Commands

Run these in browser console (F12) while on https://pulse2.pwru.app:

```javascript
// 1. Check Clerk status
console.log({
  clerkLoaded: !!window.Clerk,
  hasSession: !!window.Clerk?.session,
  userId: window.Clerk?.user?.id,
});

// 2. Try to get token
window.Clerk?.session?.getToken().then(t => console.log('Token:', t ? '✅ Got token' : '❌ No token'));

// 3. Check environment
console.log({
  supabaseUrl: process.env.NEXT_PUBLIC_SUPABASE_URL,
  hasClerkKey: !!process.env.NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY,
});

// 4. Test Edge Function call manually
const testCall = async () => {
  const token = await window.Clerk.session.getToken();
  console.log('Token for test:', token ? 'Present' : 'Missing');

  const response = await fetch('https://jeukrohcgbnyquzrqvqr.supabase.co/functions/v1/getUserContext', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${token}`,
      'apikey': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpldWtyb2hjZ2JueXF1enJxdnFyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjIzODQzMDYsImV4cCI6MjA3Nzk2MDMwNn0.UwUa_vepDbYjZCV5jW0qRBv2cP3mv2MLQ6b6uVIsslk',
    },
  });

  console.log('Status:', response.status);
  const data = await response.json();
  console.log('Response:', data);
};

// Run the test
testCall();
```

## What to Report Back

After running the checks above, tell me:

1. **Clerk Status:**
   - [ ] Clerk loaded: YES/NO
   - [ ] Has session: YES/NO
   - [ ] Token obtained: YES/NO

2. **Browser Console Logs:**
   - Copy all `[UserProvider]` log messages

3. **Network Tab:**
   - [ ] Authorization header present in request: YES/NO
   - If YES, copy the first 20 characters of the token

4. **Manual Test:**
   - What status code did the manual fetch return?
   - What was the response data?

## Expected vs Actual

**EXPECTED (Working):**
```
✅ Clerk loaded: true
✅ Has session: true
✅ Token obtained: true
✅ Authorization header in Network tab
✅ Edge Function receives auth header
✅ Status 200
```

**ACTUAL (Your case - if showing anonymous):**
```
? Clerk loaded: ?
? Has session: ?
❌ Token obtained: false/null
❌ Authorization header missing OR not received
❌ Edge Function sees anonymous user
❌ Status 401
```

The gap between Expected and Actual will tell us exactly what's broken.

---

**Run the diagnostic commands above and report back what you see!**
