# 🚀 Pulse AI - Next.js 14 Migration

> **Status:** 🔄 In Progress  
> **Current Phase:** Phase 2 - Import Path Migration  
> **Last Updated:** November 6, 2025

---

## 📖 Quick Start

```bash
# 1. Review the migration strategy
cat NEXTJS-MIGRATION.md

# 2. Make scripts executable
chmod +x fix-nextjs-migration.sh fix-imports-targeted.sh migration-commands.sh

# 3. Run the automated fix
./fix-imports-targeted.sh

# 4. Test the build
npm run build 2>&1 | tee build-output.log

# 5. Review and iterate
git diff
```

---

## 🎯 What's Happening

We're migrating from **Vite + React + React Router** to **Next.js 14 + App Router**.

### The Core Challenge

This isn't just a "change some imports" migration. The frameworks have fundamentally different architectures:

| Aspect | Vite/React | Next.js 14 |
|--------|-----------|------------|
| **Routing** | React Router (programmatic) | File-based routing |
| **Rendering** | Pure client-side | Server + Client components |
| **Navigation** | `useNavigate()` | `useRouter()` from next/navigation |
| **Module Resolution** | Vite config aliases | TypeScript paths |
| **Entry Point** | `src/main.jsx` | `app/layout.tsx` |

---

## 📁 Project Structure

```
pulse-intelligence/
├── app/                    # ✅ NEW: Next.js App Router pages
│   ├── layout.tsx         # Root layout with ClerkProvider
│   ├── page.tsx           # Home page
│   ├── dashboard/         # Dashboard page
│   ├── goals/            # Goals page
│   └── ...               # Other pages
│
├── src/                   # 📦 OLD: Original Vite source
│   ├── components/       # React components
│   ├── api/             # API utilities
│   ├── hooks/           # Custom hooks
│   ├── utils/           # Utility functions
│   ├── lib/             # Library code
│   └── integrations/    # External integrations
│
├── public/               # Static assets
├── supabase/            # Database functions
│
├── next.config.mjs      # ✅ Next.js configuration
├── tsconfig.json        # ✅ Updated for Next.js paths
├── package.json         # ✅ Updated scripts
│
└── migration files/     # 📚 Migration helpers
    ├── NEXTJS-MIGRATION.md         # Detailed guide
    ├── fix-nextjs-migration.sh     # Automated bulk fixer
    ├── fix-imports-targeted.sh     # Targeted file fixer
    └── migration-commands.sh       # Command reference
```

---

## 🛠️ Available Tools

### 1. **NEXTJS-MIGRATION.md** 
Comprehensive migration documentation with:
- Phase-by-phase breakdown
- Common pitfalls and solutions
- Success criteria
- Testing strategies

```bash
cat NEXTJS-MIGRATION.md
```

### 2. **fix-nextjs-migration.sh**
Bulk automated fixer that converts:
- ✅ Relative imports → @/ aliases
- ✅ React Router → Next.js navigation
- ✅ useNavigate → useRouter
- ✅ Link component usage
- ✅ Route name standardization

```bash
./fix-nextjs-migration.sh
```

### 3. **fix-imports-targeted.sh**
Precise fixer with validation that:
- ✅ Fixes specific problematic files
- ✅ Shows before/after stats
- ✅ Validates changes
- ✅ Creates timestamped backups

```bash
./fix-imports-targeted.sh
```

### 4. **migration-commands.sh**
Interactive command reference with:
- Diagnostic commands
- Testing commands
- Git commands
- Troubleshooting guides

```bash
./migration-commands.sh
```

---

## 🔍 Current Status

### ✅ Completed (Phase 1)
- [x] Next.js 14 installed and configured
- [x] Build scripts updated in package.json
- [x] Basic app structure created
- [x] Clerk Next.js integration setup
- [x] Path aliases configured
- [x] Migration tooling created

### 🔄 In Progress (Phase 2)
- [ ] Import path fixes (tool ready)
- [ ] Router hook migration (tool ready)
- [ ] Link component updates (tool ready)
- [ ] Build compilation test

### ⏳ Pending (Phases 3-5)
- [ ] Client/Server component boundaries
- [ ] Context provider migration
- [ ] Authentication middleware
- [ ] Full feature testing

---

## 🚦 Quick Health Check

Run these commands to see current status:

```bash
# How many files need fixing?
grep -r "from 'react-router-dom'" app/ src/ --include='*.tsx' | wc -l

# How many relative imports in app/?
grep -r "from '\.\." app/ --include='*.tsx' | wc -l

# Can it build?
npm run build
```

---

## 🎬 Step-by-Step Migration Process

### Step 1: Understand the Changes
```bash
# Read the full guide
cat NEXTJS-MIGRATION.md

# Review the command reference
./migration-commands.sh
```

### Step 2: Backup Your Work
```bash
# Create a migration branch
git checkout -b migration-nextjs14

# Commit current state
git add -A
git commit -m "Pre-migration checkpoint"
```

### Step 3: Run Automated Fixes
```bash
# Option A: Bulk fixer (faster, less precise)
./fix-nextjs-migration.sh

# Option B: Targeted fixer (slower, more precise)
./fix-imports-targeted.sh

# Recommended: Use targeted fixer first
```

### Step 4: Review Changes
```bash
# See what was changed
git diff

# See list of changed files
git diff --name-only

# Review specific file
git diff app/dashboard/page.tsx
```

### Step 5: Test Build
```bash
# Try to build
npm run build 2>&1 | tee build-output.log

# Count errors
grep -i error build-output.log | wc -l

# See specific errors
grep "Module not found" build-output.log
```

### Step 6: Fix Remaining Issues
```bash
# Common issues will be documented in build output
# See NEXTJS-MIGRATION.md section "Common Pitfalls"
```

### Step 7: Test Development Server
```bash
# Start dev server
npm run dev

# Test in browser
# Open http://localhost:3000
```

### Step 8: Commit Progress
```bash
# Commit successful fixes
git add -A
git commit -m "Phase 2 complete: Import paths migrated"
```

---

## 🐛 Common Errors & Solutions

### Error 1: Module not found: Can't resolve '@/utils'
```
Problem: Path alias not configured correctly
Solution: 
  1. Check tsconfig.json has correct paths
  2. Restart TypeScript server (in VSCode: Cmd+Shift+P → "Restart TS Server")
  3. Clear .next directory: rm -rf .next
```

### Error 2: useNavigate is not a function
```
Problem: Still importing from react-router-dom
Solution: Run ./fix-imports-targeted.sh to fix automatically
```

### Error 3: useState can only be used in Client Components
```
Problem: Component using React hooks is a Server Component
Solution: Add "use client" at top of file:

  "use client";
  
  import React, { useState } from 'react';
  // rest of component...
```

### Error 4: Hydration failed
```
Problem: Server and client rendering different content
Solution: Check for:
  - Date() usage (use server time)
  - localStorage (use useEffect)
  - window object (guard with typeof window !== 'undefined')
```

---

## 📊 Migration Metrics

Track your progress:

```bash
# Total files in app/
find app/ -name '*.tsx' | wc -l

# Files fixed
git diff --name-only | wc -l

# Build errors
npm run build 2>&1 | grep -i error | wc -l

# Files needing "use client"
grep -r "useState\|useEffect\|useContext" app/ --include='*.tsx' -l | wc -l
```

---

## 🎯 Success Criteria

### Phase 2 Complete When:
- [ ] `npm run build` completes with 0 import errors
- [ ] No "Module not found" errors
- [ ] No "react-router-dom" imports remain
- [ ] All `@/` aliases resolve correctly

### Full Migration Complete When:
- [ ] `npm run dev` starts without errors
- [ ] All pages render in browser
- [ ] Authentication works (sign in/sign up)
- [ ] Navigation works (all links)
- [ ] All features functional

---

## 💡 Pro Tips

1. **Work in Small Batches**
   - Fix 10-20 files at a time
   - Test after each batch
   - Commit working changes

2. **Use the Tools**
   - Don't manually edit everything
   - Let scripts handle repetitive changes
   - Focus on edge cases

3. **Test Incrementally**
   - Don't wait for "perfect" to test
   - Run `npm run build` often
   - Catch issues early

4. **Read the Errors**
   - Next.js errors are usually helpful
   - They tell you exactly what's wrong
   - Google the specific error message

5. **Keep Backups**
   - Scripts create .backup files
   - Don't delete until verified
   - Use git commits frequently

---

## 🆘 Getting Help

### Check These First:
1. **NEXTJS-MIGRATION.md** - Detailed guide
2. **migration-commands.sh** - Command reference
3. **build-output.log** - Your build errors
4. **Next.js Docs** - https://nextjs.org/docs

### Common Issues Documented:
- Import path problems
- Router hook issues
- Client/Server boundaries
- Hydration mismatches

### Still Stuck?
Share these with your team:
1. The specific error message
2. The file causing the error
3. What you've tried already
4. Output of `npm run build`

---

## 📚 Reference Documentation

- [Next.js 14 Documentation](https://nextjs.org/docs)
- [Next.js App Router](https://nextjs.org/docs/app)
- [Clerk Next.js](https://clerk.com/docs/quickstarts/nextjs)
- [Migrating from Vite](https://nextjs.org/docs/app/building-your-application/upgrading/from-vite)

---

## 🎉 Next Actions

**Ready to start?**

```bash
# 1. Make sure you're on the right branch
git checkout -b migration-nextjs14

# 2. Run the targeted fixer
chmod +x fix-imports-targeted.sh
./fix-imports-targeted.sh

# 3. Test the build
npm run build 2>&1 | tee build-output.log

# 4. Review results
cat build-output.log
```

**Questions?** Check NEXTJS-MIGRATION.md for detailed guidance.

---

**Last Updated:** November 6, 2025  
**Maintained By:** Development Team  
**Status:** 🔄 Active Migration
