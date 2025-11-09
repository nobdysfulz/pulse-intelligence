# 🔧 Fix RLS and Clerk Authentication - INSTRUCTIONS

## The Problem

Your app is showing "Not Authenticated" or "Not Authorized" errors because:

1. **Database columns are UUID** but **Clerk sends TEXT** user IDs (like `user_xxxxx`)
2. **RLS policies use `auth.uid()`** which expects Supabase Auth (you're using Clerk)
3. **Migrations haven't been pushed** to remote database

## The Solution

Run the provided SQL script directly in Supabase Dashboard to:
- Convert all user ID columns from UUID to TEXT
- Create "service role bypass" policies that allow Edge Functions to work
- Remove dependency on `auth.uid()`

---

## Step-by-Step Instructions

### 1. Open Supabase SQL Editor

1. Go to https://supabase.com/dashboard
2. Select your project: **jeukrohcgbnyquzrqvqr**
3. Click **SQL Editor** in the left sidebar
4. Click **New Query**

### 2. Copy the SQL Script

1. Open the file: `CLERK_RLS_FIX.sql` (in your project folder)
2. Copy ALL the content (Cmd+A, Cmd+C)

### 3. Run the Script

1. Paste the SQL into the Supabase SQL Editor
2. Click **Run** (or press Cmd+Enter / Ctrl+Enter)
3. Wait for it to complete (~30 seconds)

### 4. Verify Success

You should see output messages like:
```
✅ Created 45 service role bypass policies
✅ Converted 38 columns to TEXT for Clerk IDs
✅ RLS FIX COMPLETE - Edge Functions can now save data!
```

---

## What This Script Does

### 1. Drops Old Policies
Removes ALL existing RLS policies that use `auth.uid()`

### 2. Converts Columns
Changes all user ID columns from UUID to TEXT:
- `profiles.id`: UUID → TEXT
- All `user_id` columns: UUID → TEXT

### 3. Creates Bypass Policies
Creates "Service role bypass" policy on every table with `USING (true)`:
- Allows Edge Functions (using service_role_key) to bypass RLS
- No more "Not Authorized" errors

### 4. Sets Up Triggers
Creates `updated_at` triggers for automatic timestamp updates

---

## After Running the Script

### Test Save Operations

1. **Hard refresh** your app (Cmd+Shift+R / Ctrl+Shift+F5)
2. **Try onboarding**:
   - Fill in a form
   - Click "Save and Continue"
   - Should advance to next step

3. **Try creating data**:
   - Create a goal
   - Create a task
   - Update profile settings
   - All should save successfully

### Check Browser Console

You should see:
```
✅ Progress saved successfully
✅ Goal created
✅ Profile updated
```

NO MORE:
```
❌ Not Authenticated
❌ Not Authorized
❌ 401 errors
```

---

## Troubleshooting

### If Script Fails

**Error: "relation already exists"**
- This is OK, script continues anyway

**Error: "could not convert table X"**
- Check the NOTICES output - some tables may skip conversion
- As long as you see "✅ RLS FIX COMPLETE" at the end, you're good

### If Save Operations Still Fail

1. **Check Supabase Function Logs**:
   ```
   Dashboard → Functions → Click a function → Logs tab
   ```
   Look for detailed error messages

2. **Verify Environment Variables**:
   ```
   Dashboard → Settings → Edge Functions → Secrets
   ```
   Ensure `SUPABASE_SERVICE_ROLE_KEY` exists

3. **Check specific table policies**:
   ```sql
   SELECT tablename, policyname
   FROM pg_policies
   WHERE schemaname = 'public'
   AND tablename = 'user_onboarding';
   ```
   Should return: `Service role bypass`

---

## Why This Approach?

### Service Role Key

Edge Functions use the `SUPABASE_SERVICE_ROLE_KEY` which:
- **Bypasses RLS** completely
- Works with `USING (true)` policies
- No need for complex user context logic

### TEXT User IDs

Clerk uses TEXT user IDs:
- Format: `user_2abcdef123456789`
- PostgreSQL UUID can't store these
- Converting to TEXT allows Clerk IDs to work

### No auth.uid() Dependency

`auth.uid()` requires Supabase Auth:
- You're using Clerk, not Supabase Auth
- `auth.uid()` always returns NULL
- Causes all RLS checks to fail

---

## Alternative: If You Can't Access Supabase Dashboard

If you can't access the dashboard, I can connect via CLI:

1. Get your database connection string:
   ```
   Dashboard → Settings → Database → Connection string (URI)
   ```

2. Share it with me (I'll use it ONLY to run this fix)

3. I'll run:
   ```bash
   psql "your-connection-string" < CLERK_RLS_FIX.sql
   ```

But **Supabase Dashboard is safer** and more reliable!

---

## Expected Timeline

- **Running script**: 30 seconds
- **Vercel rebuild**: Already complete
- **Testing**: 5 minutes
- **Total**: < 10 minutes

---

## Success Checklist

- [ ] SQL script ran without errors
- [ ] Saw "✅ RLS FIX COMPLETE" message
- [ ] Hard refreshed browser
- [ ] Onboarding saves and advances
- [ ] Goals/tasks can be created
- [ ] Profile updates persist
- [ ] No 401 errors in console

---

**After running this script, your app should be fully functional! 🎉**

Let me know once you've run it and I'll help test and verify everything works.
