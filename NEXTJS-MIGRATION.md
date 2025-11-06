# PULSE AI - Vite to Next.js 14 Migration Guide

**Status:** 🔄 In Progress  
**Started:** November 6, 2025  
**Framework:** Vite + React → Next.js 14 App Router

---

## 🎯 Migration Overview

### What We're Doing
Migrating a sophisticated real estate coaching platform from Vite/React to Next.js 14 with:
- **Old Stack:** Vite + React + React Router + Clerk (React)
- **New Stack:** Next.js 14 App Router + Clerk (Next.js) + Supabase

### Why This Is Complex
The migration involves structural changes at every level:

1. **Module Resolution**
   - Vite: `@/` → `src/` (configured in `vite.config.js`)
   - Next.js: `@/` → configurable (in `tsconfig.json`)
   - Issue: Import paths need complete reconfiguration

2. **Routing System**
   - React Router: `useNavigate()`, `<Link>`, client-side routing
   - Next.js: `useRouter()`, `next/link`, file-based routing
   - Issue: Different APIs require code changes everywhere

3. **Directory Structure**
   - Vite: All code in `src/`, single entry point `main.jsx`
   - Next.js: Pages in `app/`, components can be anywhere
   - Issue: Relative imports like `../../components` break

4. **Rendering Model**
   - Vite: All components are client-side
   - Next.js: Server components by default, need "use client"
   - Issue: React hooks break in server components

---

## 📋 Migration Phases

### ✅ Phase 1: Build System (COMPLETE)
**Completed:** November 6, 2025

Changes Made:
- ✅ Updated `package.json` scripts to use Next.js
- ✅ Installed `@clerk/nextjs` (replacing `@clerk/clerk-react`)
- ✅ Created basic `app/layout.tsx` with ClerkProvider
- ✅ Created basic `app/page.tsx` home page
- ✅ Configured `next.config.mjs`

**Result:** Next.js development server can start

---

### 🔄 Phase 2: Import Path Migration (IN PROGRESS)
**Status:** Fixing import incompatibilities

#### Issues to Fix:
1. **Relative imports from app/ to src/**
   ```jsx
   // ❌ BROKEN in app/dashboard/page.tsx
   import { UserContext } from '../../components/context/UserContext';
   
   // ✅ CORRECT
   import { UserContext } from '@/components/context/UserContext';
   ```

2. **Router hook imports**
   ```jsx
   // ❌ BROKEN
   import { useNavigate } from 'react-router-dom';
   const navigate = useNavigate();
   navigate('/dashboard');
   
   // ✅ CORRECT
   import { useRouter } from 'next/navigation';
   const router = useRouter();
   router.push('/dashboard');
   ```

3. **Link component imports**
   ```jsx
   // ❌ BROKEN
   import { Link } from 'react-router-dom';
   <Link to="/dashboard">Dashboard</Link>
   
   // ✅ CORRECT
   import Link from 'next/link';
   <Link href="/dashboard">Dashboard</Link>
   ```

4. **Page routing helpers**
   ```jsx
   // ❌ OLD PATTERN
   navigate(createPageUrl('Dashboard'));
   
   // ✅ NEW PATTERN
   router.push('/dashboard');
   ```

#### Fix Strategy:
Created automated script: `fix-nextjs-migration.sh` that:
- Converts all `../../components` → `@/components`
- Converts all `../../api` → `@/api`
- Converts all router imports
- Fixes Link component usage
- Updates route names to lowercase

#### Files Requiring Fixes:
Based on scan, approximately 50+ files need updates in:
- `app/*/page.tsx` - All page components
- `src/components/**/*` - All components using navigation
- `src/hooks/**/*` - Hooks that use router
- `src/api/**/*` - API utilities

---

### ⏳ Phase 3: Client/Server Boundary (PENDING)
**Status:** Not started yet

#### What Needs to Happen:
Next.js 14 uses React Server Components by default. Components using:
- React hooks (`useState`, `useEffect`, `useContext`, etc.)
- Browser APIs (`window`, `localStorage`, etc.)
- Event handlers (`onClick`, `onChange`, etc.)

Must have `"use client"` directive at the top.

#### Files That Will Need "use client":
- All dashboard components
- All form components
- All interactive UI components
- All components using context
- All components with animations

#### Strategy:
1. Start from leaf components (buttons, inputs)
2. Add "use client" as needed
3. Keep server components where possible for performance

---

### ⏳ Phase 4: Context Providers (PENDING)
**Status:** Not started yet

#### Challenge:
The app relies heavily on `UserContext` which provides:
- User authentication state
- User preferences
- Goals and actions
- Agent profiles
- Business plans

#### Current Structure:
```jsx
// src/App.jsx (Vite entry)
<UserProvider>
  <RouterProvider router={router} />
</UserProvider>
```

#### Target Structure:
```jsx
// app/layout.tsx (Next.js)
<ClerkProvider>
  <UserProvider> {/* Needs "use client" */}
    {children}
  </UserProvider>
</ClerkProvider>
```

#### Issues:
- Context providers must be client components
- May need to split into smaller providers
- Need to handle SSR hydration

---

### ⏳ Phase 5: Authentication Integration (PENDING)
**Status:** Not started yet

#### Changes Needed:
1. **Migrate from @clerk/clerk-react to @clerk/nextjs**
   - Different API for server-side auth
   - Different middleware setup
   - Different protected routes pattern

2. **Update Protected Routes**
   ```jsx
   // ❌ OLD (React Router)
   <Route element={<ProtectedRoute />}>
     <Route path="/dashboard" element={<Dashboard />} />
   </Route>
   
   // ✅ NEW (Next.js)
   // Use middleware.ts for protection
   // Or use currentUser() in Server Components
   ```

3. **Clerk Middleware Configuration**
   - Create/update `middleware.ts`
   - Configure public/private routes
   - Handle redirects properly

---

### ⏳ Phase 6: API Routes Migration (PENDING)
**Status:** Not started yet

#### Current:
- Supabase functions called directly from components
- Edge functions for AI processing
- OAuth callbacks handled in components

#### Target:
- Move sensitive operations to Next.js API routes
- Use Server Actions for mutations
- Keep edge functions for compute-heavy tasks

---

## 🔧 Current Build Status

### Last Known Error:
```
Module not found: Can't resolve '@/utils'
```

This occurs because:
1. Import paths still use old Vite patterns
2. Path aliases not fully configured
3. Some imports missing file extensions

### Quick Diagnosis Commands:
```bash
# Check for React Router imports
grep -r "from 'react-router-dom'" app/ src/

# Check for relative imports in app directory
grep -r "from '\.\." app/

# Check for old createPageUrl usage
grep -r "createPageUrl" app/ src/

# Try to build
npm run build
```

---

## 🛠️ Fix Application Process

### Step 1: Run Automated Fix Script
```bash
chmod +x fix-nextjs-migration.sh
./fix-nextjs-migration.sh
```

This script will:
- ✅ Convert relative imports to @/ aliases
- ✅ Fix router hook imports
- ✅ Fix Link component usage
- ✅ Update route names
- ✅ Create backups of all changed files

### Step 2: Verify the Fixes
```bash
# Review changes
git diff

# Check for remaining issues
npm run build 2>&1 | tee build-errors.log
```

### Step 3: Manual Fixes (If Needed)
Common issues that may require manual fixing:
1. **Dynamic imports** - May need `next/dynamic`
2. **CSS imports** - May need adjustments
3. **Environment variables** - Change `VITE_` → `NEXT_PUBLIC_`
4. **Image imports** - May need `next/image`

### Step 4: Add "use client" Directives
After imports are fixed, add "use client" to components that need it:
```bash
# Find components using hooks
grep -r "useState\|useEffect\|useContext" app/ --include="*.tsx" -l

# Add "use client" to the top of each file
```

---

## 📊 Progress Tracking

### Completed Tasks ✅
- [x] Next.js 14 installed and configured
- [x] Basic app structure created
- [x] Clerk Next.js integration setup
- [x] Path aliases configured in tsconfig.json
- [x] next.config.mjs created
- [x] Automated fix script created
- [x] Migration guide documented

### In Progress 🔄
- [ ] Import path fixes (automated script ready to run)
- [ ] Router hook migration
- [ ] Link component migration

### Not Started ⏳
- [ ] Client/Server component boundaries
- [ ] Context provider migration
- [ ] Authentication flow updates
- [ ] Middleware configuration
- [ ] API routes migration
- [ ] Environment variables update
- [ ] Testing and verification

---

## 🎯 Success Criteria

### Build Success
- ✅ `npm run build` completes without errors
- ✅ No TypeScript errors
- ✅ No import resolution errors

### Runtime Success
- ✅ App starts: `npm run dev`
- ✅ Pages render without hydration errors
- ✅ Authentication works (sign in/sign up)
- ✅ Protected routes work
- ✅ Navigation works (all links)

### Feature Parity
- ✅ All pages accessible
- ✅ All forms functional
- ✅ All integrations working
- ✅ All AI agents operational
- ✅ All data operations working

---

## 📚 Key Resources

### Next.js Documentation
- [App Router](https://nextjs.org/docs/app)
- [Routing](https://nextjs.org/docs/app/building-your-application/routing)
- [Server/Client Components](https://nextjs.org/docs/app/building-your-application/rendering/server-components)

### Clerk Documentation
- [Next.js Integration](https://clerk.com/docs/quickstarts/nextjs)
- [Middleware](https://clerk.com/docs/references/nextjs/clerk-middleware)

### Migration Guides
- [Vite to Next.js](https://nextjs.org/docs/app/building-your-application/upgrading/from-vite)
- [React Router to Next.js](https://nextjs.org/docs/app/building-your-application/upgrading/from-react-router)

---

## 🚨 Common Pitfalls

### 1. Forgetting "use client"
**Error:** `Error: useState can only be used in Client Components`  
**Fix:** Add `"use client"` at the top of the file

### 2. Wrong Router Hook
**Error:** `Module not found: Can't resolve 'react-router-dom'`  
**Fix:** Change to `import { useRouter } from 'next/navigation'`

### 3. Incorrect Path Aliases
**Error:** `Module not found: Can't resolve '@/utils'`  
**Fix:** Ensure tsconfig.json paths are correct and restart TS server

### 4. Server Component Trying to Use Context
**Error:** `createContext only works in Client Components`  
**Fix:** Make the provider a client component

### 5. Hydration Mismatches
**Error:** `Hydration failed because the initial UI does not match`  
**Fix:** Ensure server and client render the same initial content

---

## 🎉 Next Steps

1. **Run the automated fix script** to handle bulk import/router changes
2. **Test the build** to see what errors remain
3. **Add "use client"** directives systematically
4. **Update context providers** to work with App Router
5. **Configure Clerk middleware** for authentication
6. **Verify all features** work in the new structure

---

## 💡 Migration Tips

### Work in Layers
1. Get imports working first (structure)
2. Then fix component boundaries (rendering)
3. Then fix authentication (security)
4. Then optimize (performance)

### Test Incrementally
Don't wait until everything is "done" to test. Test after each major change:
- After fixing imports → test build
- After adding "use client" → test dev server
- After updating auth → test sign in flow

### Keep Backups
The automated script creates backups, but also:
```bash
git checkout -b migration-nextjs14
git add -A
git commit -m "WIP: Next.js migration progress"
```

### Ask for Help
If stuck on a specific error for more than 30 minutes:
1. Share the full error message
2. Share the problematic file
3. Share what you've already tried

---

**Last Updated:** November 6, 2025  
**Current Phase:** Phase 2 - Import Path Migration  
**Next Action:** Run `./fix-nextjs-migration.sh`
