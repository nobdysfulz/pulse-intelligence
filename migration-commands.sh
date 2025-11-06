#!/bin/bash

# PULSE AI - Next.js Migration Quick Reference
# Use this as your command cheat sheet during migration

echo "╔════════════════════════════════════════════════════════════╗"
echo "║     PULSE AI - Next.js 14 Migration Command Reference     ║"
echo "╔════════════════════════════════════════════════════════════╗"
echo ""

# Text formatting
BOLD='\033[1m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

print_section() {
    echo ""
    echo -e "${BOLD}${BLUE}━━━ $1 ━━━${NC}"
    echo ""
}

print_command() {
    echo -e "${GREEN}$${NC} ${YELLOW}$1${NC}"
    echo "   → $2"
    echo ""
}

# ==================== DIAGNOSTIC COMMANDS ====================
print_section "1. DIAGNOSTIC COMMANDS (Check Current Status)"

print_command "npm run build 2>&1 | tee build.log" \
    "Build and save all errors to build.log file"

print_command "npm run dev" \
    "Start dev server (useful to see runtime errors)"

print_command "grep -r \"from 'react-router-dom'\" app/ src/ --include='*.tsx' --include='*.jsx'" \
    "Find all React Router imports that need fixing"

print_command "grep -r \"from '\\.\\.\" app/ --include='*.tsx' --include='*.jsx'" \
    "Find all relative imports in app/ directory"

print_command "grep -r \"createPageUrl\" app/ src/ --include='*.tsx' --include='*.jsx'" \
    "Find all old routing helper usage"

print_command "grep -r \"useNavigate\" app/ src/ --include='*.tsx' --include='*.jsx'" \
    "Find all useNavigate hook usage"

# ==================== FIX COMMANDS ====================
print_section "2. FIX COMMANDS (Apply Automated Fixes)"

print_command "chmod +x fix-nextjs-migration.sh" \
    "Make the fix script executable (one-time)"

print_command "./fix-nextjs-migration.sh" \
    "Run the automated import/router fix script"

print_command "find . -name '*.backup_*' -delete" \
    "Remove backup files after verifying fixes work"

# ==================== BUILD & TEST ====================
print_section "3. BUILD & TEST COMMANDS"

print_command "npm run build" \
    "Production build (reveals all TypeScript/import errors)"

print_command "npm run build -- --debug" \
    "Build with extra debugging information"

print_command "npm run dev" \
    "Start development server on http://localhost:3000"

print_command "npm run dev -- --turbo" \
    "Start dev server with Turbopack (faster)"

print_command "npm run lint" \
    "Run ESLint to find code issues"

# ==================== GIT COMMANDS ====================
print_section "4. GIT COMMANDS (Version Control)"

print_command "git status" \
    "See what files have been modified"

print_command "git diff" \
    "Review all changes made by the fix script"

print_command "git diff --name-only" \
    "List only the names of changed files"

print_command "git checkout -b migration-nextjs14" \
    "Create a new branch for migration work"

print_command "git add -A && git commit -m 'WIP: Next.js migration progress'" \
    "Save current migration progress"

print_command "git restore ." \
    "Discard all changes (if you need to start over)"

# ==================== SEARCH & REPLACE ====================
print_section "5. MANUAL SEARCH & REPLACE PATTERNS"

echo -e "${YELLOW}Use these in your code editor's Find & Replace:${NC}"
echo ""
echo "Pattern 1: Fix router imports"
echo "  Find:    import { useNavigate } from 'react-router-dom'"
echo "  Replace: import { useRouter } from 'next/navigation'"
echo ""
echo "Pattern 2: Fix router usage"
echo "  Find:    const navigate = useNavigate()"
echo "  Replace: const router = useRouter()"
echo ""
echo "Pattern 3: Fix navigation calls"
echo "  Find:    navigate("
echo "  Replace: router.push("
echo ""
echo "Pattern 4: Fix Link imports"
echo "  Find:    import { Link } from 'react-router-dom'"
echo "  Replace: import Link from 'next/link'"
echo ""
echo "Pattern 5: Fix Link usage"
echo "  Find:    <Link to="
echo "  Replace: <Link href="
echo ""

# ==================== VERIFICATION ====================
print_section "6. VERIFICATION COMMANDS"

print_command "npm run build 2>&1 | grep -i error | wc -l" \
    "Count number of build errors"

print_command "npm run build 2>&1 | grep 'Module not found'" \
    "Find all missing module errors"

print_command "grep -r '\"use client\"' app/ --include='*.tsx' | wc -l" \
    "Count how many client components you have"

print_command "find app/ -name '*.tsx' | wc -l" \
    "Count total page/component files in app/"

# ==================== CLEANUP ====================
print_section "7. CLEANUP COMMANDS"

print_command "rm -rf .next" \
    "Clear Next.js build cache (if build acting weird)"

print_command "rm -rf node_modules && npm install" \
    "Reinstall all dependencies (nuclear option)"

print_command "find . -name '*.backup_*' -type f -ls" \
    "List all backup files created by fix script"

# ==================== TROUBLESHOOTING ====================
print_section "8. TROUBLESHOOTING SPECIFIC ERRORS"

echo -e "${RED}Error: Module not found: Can't resolve '@/utils'${NC}"
echo "  Fix: Check tsconfig.json paths configuration"
echo "  Run: cat tsconfig.json | grep -A 5 paths"
echo ""

echo -e "${RED}Error: useState can only be used in Client Components${NC}"
echo "  Fix: Add 'use client' at top of file"
echo "  Run: grep -l 'useState' app/**/*.tsx | xargs sed -i '' '1s/^/\"use client\";\\n\\n/'"
echo ""

echo -e "${RED}Error: useNavigate is not a function${NC}"
echo "  Fix: Change to useRouter from 'next/navigation'"
echo "  Run: ./fix-nextjs-migration.sh (should fix this)"
echo ""

echo -e "${RED}Error: Hydration failed${NC}"
echo "  Fix: Ensure server and client render same initial content"
echo "  Check: Components using Date(), localStorage, or window"
echo ""

# ==================== USEFUL FILTERS ====================
print_section "9. USEFUL FILE FILTERS"

print_command "find app/ -name '*.tsx' -exec grep -l 'useRouter' {} \\;" \
    "Find all files using useRouter"

print_command "find src/ -name '*.tsx' -exec grep -l 'useNavigate' {} \\;" \
    "Find all files still using old useNavigate"

print_command "find app/ src/ -name '*.tsx' -exec grep -L '\"use client\"' {} \\; | xargs grep -l 'useState\\|useEffect'" \
    "Find server components using hooks (need 'use client')"

# ==================== NEXT STEPS ====================
print_section "10. RECOMMENDED WORKFLOW"

echo "Step 1: Run diagnostics"
echo "  $ npm run build 2>&1 | tee build-before.log"
echo ""
echo "Step 2: Apply automated fixes"
echo "  $ ./fix-nextjs-migration.sh"
echo ""
echo "Step 3: Check results"
echo "  $ npm run build 2>&1 | tee build-after.log"
echo ""
echo "Step 4: Compare errors"
echo "  $ diff build-before.log build-after.log"
echo ""
echo "Step 5: Add 'use client' where needed"
echo "  $ (manually add to files using React hooks)"
echo ""
echo "Step 6: Test build again"
echo "  $ npm run build"
echo ""
echo "Step 7: Test dev server"
echo "  $ npm run dev"
echo ""

# ==================== QUICK STATS ====================
print_section "11. PROJECT STATISTICS"

if [ -d "app" ]; then
    APP_FILES=$(find app/ -name '*.tsx' -o -name '*.ts' | wc -l | tr -d ' ')
    echo "App directory files: $APP_FILES"
fi

if [ -d "src" ]; then
    SRC_FILES=$(find src/ -name '*.tsx' -o -name '*.ts' -o -name '*.jsx' -o -name '*.js' | wc -l | tr -d ' ')
    echo "Src directory files: $SRC_FILES"
fi

if [ -d "src/components" ]; then
    COMP_FILES=$(find src/components/ -name '*.tsx' -o -name '*.jsx' | wc -l | tr -d ' ')
    echo "Component files: $COMP_FILES"
fi

echo ""
echo "To see real-time stats during migration:"
echo "  watch -n 2 'npm run build 2>&1 | grep -c error'"
echo ""

# ==================== FOOTER ====================
echo ""
echo -e "${BOLD}${GREEN}════════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}For detailed migration guide: cat NEXTJS-MIGRATION.md${NC}"
echo -e "${BOLD}For quick start: ./fix-nextjs-migration.sh && npm run build${NC}"
echo -e "${BOLD}${GREEN}════════════════════════════════════════════════════════════${NC}"
echo ""
