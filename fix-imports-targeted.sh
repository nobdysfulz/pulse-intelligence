#!/bin/bash

# PULSE AI - Targeted Import Fixer
# This script fixes the most common import issues in specific files

set -e  # Exit on error

echo "🎯 PULSE AI - Targeted Import Fixer"
echo "=================================="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Counter
FIXED=0
ERRORS=0

fix_file() {
    local file="$1"
    local backup="${file}.bak"
    
    if [ ! -f "$file" ]; then
        echo -e "${RED}✗${NC} File not found: $file"
        ((ERRORS++))
        return 1
    fi
    
    echo -e "${BLUE}→${NC} Processing: $file"
    
    # Create backup
    cp "$file" "$backup"
    
    # Apply fixes using Perl for better regex support
    perl -i -pe '
        # Fix: ../../components → @/components
        s|from ["\x27](\.\./)+components/|from "@/components/|g;
        s|from ["\x27](\.\./)+api/|from "@/api/|g;
        s|from ["\x27](\.\./)+integrations/|from "@/integrations/|g;
        s|from ["\x27](\.\./)+utils/|from "@/utils/|g;
        s|from ["\x27](\.\./)+lib/|from "@/lib/|g;
        s|from ["\x27](\.\./)+hooks/|from "@/hooks/|g;
        s|from ["\x27](\.\./)+config/|from "@/config/|g;
        
        # Fix: React Router imports
        s|from ["\x27]react-router-dom["\x27]|from "next/navigation"|g;
        
        # Fix: useNavigate → useRouter
        s|const\s+navigate\s*=\s*useNavigate\(\)|const router = useRouter()|g;
        
        # Fix: navigate( → router.push(
        s|\bnavigate\(|router.push(|g;
        
        # Fix: Link import
        s|import\s*{\s*Link\s*}|import Link|g;
        s|import\s*{\s*Link,|import Link, {|g;
        
        # Fix: createPageUrl usage
        s|createPageUrl\(["\x27]([^"\x27]+)["\x27]\)|"/" . lc($1)|ge;
        
        # Fix common route names
        s|["\x27]/Dashboard["\x27]|"/dashboard"|g;
        s|["\x27]/Goals["\x27]|"/goals"|g;
        s|["\x27]/ToDo["\x27]|"/to-do"|g;
        s|["\x27]/Agents["\x27]|"/agents"|g;
        s|["\x27]/PersonalAdvisor["\x27]|"/personaladvisor"|g;
        s|["\x27]/Market["\x27]|"/market"|g;
        s|["\x27]/RolePlay["\x27]|"/role-play"|g;
        s|["\x27]/ContentStudio["\x27]|"/content-studio"|g;
        s|["\x27]/Settings["\x27]|"/settings"|g;
        s|["\x27]/Intelligence["\x27]|"/intelligence"|g;
        s|["\x27]/Plans["\x27]|"/plans"|g;
        s|["\x27]/Onboarding["\x27]|"/onboarding"|g;
    ' "$file"
    
    # Check if file was actually changed
    if ! cmp -s "$file" "$backup"; then
        echo -e "${GREEN}✓${NC} Fixed imports in: $file"
        ((FIXED++))
        # Keep backup with timestamp
        mv "$backup" "${file}.backup_$(date +%Y%m%d_%H%M%S)"
    else
        echo -e "${YELLOW}○${NC} No changes needed: $file"
        rm "$backup"
    fi
}

# ========================================
# PHASE 1: Fix app/ directory files
# ========================================
echo ""
echo "Phase 1: Fixing app/ directory"
echo "-------------------------------"

if [ -d "app" ]; then
    while IFS= read -r -d '' file; do
        fix_file "$file"
    done < <(find app/ -type f \( -name "*.tsx" -o -name "*.ts" \) -print0 2>/dev/null)
else
    echo -e "${YELLOW}⚠${NC} app/ directory not found"
fi

# ========================================
# PHASE 2: Fix critical src/ files
# ========================================
echo ""
echo "Phase 2: Fixing critical src/ files"
echo "------------------------------------"

CRITICAL_FILES=(
    "src/components/context/UserContext.tsx"
    "src/components/context/UserContext.jsx"
    "src/hooks/useNavigation.ts"
    "src/hooks/useNavigation.tsx"
    "src/utils/navigation.ts"
    "src/utils/navigation.tsx"
    "src/api/entities.ts"
    "src/api/entities.js"
)

for file in "${CRITICAL_FILES[@]}"; do
    if [ -f "$file" ]; then
        fix_file "$file"
    fi
done

# ========================================
# PHASE 3: Fix components using navigation
# ========================================
echo ""
echo "Phase 3: Fixing navigation in components"
echo "-----------------------------------------"

if [ -d "src/components" ]; then
    # Find files that use navigation
    while IFS= read -r file; do
        fix_file "$file"
    done < <(grep -rl "useNavigate\|createPageUrl\|from 'react-router-dom'" src/components/ --include="*.tsx" --include="*.jsx" --include="*.ts" --include="*.js" 2>/dev/null || true)
fi

# ========================================
# SUMMARY
# ========================================
echo ""
echo "=================================="
echo "📊 Fix Summary"
echo "=================================="
echo -e "Files fixed: ${GREEN}$FIXED${NC}"
echo -e "Errors: ${RED}$ERRORS${NC}"
echo ""

if [ $FIXED -gt 0 ]; then
    echo -e "${GREEN}✅ Fixes applied successfully!${NC}"
    echo ""
    echo "Next steps:"
    echo "1. Review changes: git diff"
    echo "2. Test build: npm run build"
    echo "3. Check for remaining errors"
    echo ""
    echo "Backups saved with pattern: *.backup_YYYYMMDD_HHMMSS"
else
    echo -e "${YELLOW}ℹ️  No changes were needed${NC}"
fi

# ========================================
# VALIDATION
# ========================================
echo ""
echo "Running validation checks..."
echo "----------------------------"

# Check for remaining issues
echo ""
echo -e "${BLUE}Checking for remaining React Router imports...${NC}"
ROUTER_COUNT=$(grep -r "from 'react-router-dom'" app/ src/ --include="*.tsx" --include="*.jsx" 2>/dev/null | wc -l | tr -d ' ')
if [ "$ROUTER_COUNT" -gt 0 ]; then
    echo -e "${YELLOW}⚠${NC} Found $ROUTER_COUNT files still using react-router-dom"
    echo "   Run: grep -r \"from 'react-router-dom'\" app/ src/ --include='*.tsx'"
else
    echo -e "${GREEN}✓${NC} No react-router-dom imports found"
fi

echo ""
echo -e "${BLUE}Checking for relative imports in app/...${NC}"
RELATIVE_COUNT=$(grep -r "from '\.\." app/ --include="*.tsx" --include="*.jsx" 2>/dev/null | wc -l | tr -d ' ')
if [ "$RELATIVE_COUNT" -gt 0 ]; then
    echo -e "${YELLOW}⚠${NC} Found $RELATIVE_COUNT relative imports in app/"
    echo "   Run: grep -r \"from '\\.\\.\" app/ --include='*.tsx'"
else
    echo -e "${GREEN}✓${NC} No relative imports in app/ directory"
fi

echo ""
echo -e "${BLUE}Checking for useNavigate usage...${NC}"
NAVIGATE_COUNT=$(grep -r "useNavigate" app/ src/ --include="*.tsx" --include="*.jsx" 2>/dev/null | wc -l | tr -d ' ')
if [ "$NAVIGATE_COUNT" -gt 0 ]; then
    echo -e "${YELLOW}⚠${NC} Found $NAVIGATE_COUNT instances of useNavigate"
    echo "   Run: grep -r \"useNavigate\" app/ src/ --include='*.tsx'"
else
    echo -e "${GREEN}✓${NC} No useNavigate usage found"
fi

echo ""
echo "=================================="
echo -e "${BOLD}Ready to test? Run: npm run build${NC}"
echo "=================================="
