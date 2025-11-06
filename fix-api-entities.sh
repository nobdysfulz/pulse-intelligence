#!/bin/bash

# Fix api-entities import issues
# This script fixes the specific "api-entities" import problem

echo "🔧 Fixing api-entities Import Issues"
echo "====================================="
echo ""

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

FIXED=0

# Step 1: Fix the entities.js file itself (has wrong quote in import)
echo "Step 1: Fixing src/api/entities.js..."
if [ -f "src/api/entities.js" ]; then
    sed -i '' "s|from \"@/integrations/supabase/client';|from '@/integrations/supabase/client';|g" src/api/entities.js
    echo -e "${GREEN}✓${NC} Fixed quote mismatch in src/api/entities.js"
fi

# Step 2: Find and fix all files importing api-entities incorrectly
echo ""
echo "Step 2: Finding files with incorrect api-entities imports..."
echo ""

# Pattern 1: '../../../api-entities' or '../../api-entities' (missing path and extension)
find . -type f \( -name "*.jsx" -o -name "*.tsx" -o -name "*.js" -o -name "*.ts" \) \
  -not -path "./node_modules/*" \
  -not -path "./.next/*" \
  -not -path "./dist/*" \
  -exec grep -l "from.*api-entities" {} \; | while read file; do
    
    echo -e "${YELLOW}Processing:${NC} $file"
    
    # Create backup
    cp "$file" "${file}.bak"
    
    # Fix: ../../../api-entities → @/api/entities
    sed -i '' "s|from ['\"]../../../api-entities['\"]|from '@/api/entities'|g" "$file"
    sed -i '' "s|from ['\"]../../api-entities['\"]|from '@/api/entities'|g" "$file"
    sed -i '' "s|from ['\"]../api-entities['\"]|from '@/api/entities'|g" "$file"
    sed -i '' "s|from ['\"]./api-entities['\"]|from '@/api/entities'|g" "$file"
    
    # Also fix if they're importing from wrong named imports
    sed -i '' "s|import {\\([^}]*\\)} from '@/api-entities'|import {\\1} from '@/api/entities'|g" "$file"
    
    # Check if file actually changed
    if ! cmp -s "$file" "${file}.bak"; then
        echo -e "${GREEN}  ✓ Fixed imports${NC}"
        ((FIXED++))
        rm "${file}.bak"
    else
        echo -e "  No changes needed"
        rm "${file}.bak"
    fi
done

# Step 3: Remove the duplicate api-entities.js from root if it exists
echo ""
echo "Step 3: Cleaning up duplicate files..."
if [ -f "api-entities.js" ]; then
    echo -e "${YELLOW}⚠${NC} Found api-entities.js in root directory (should be in src/api/)"
    echo "  Moving to backup..."
    mv api-entities.js api-entities.js.old
    echo -e "${GREEN}✓${NC} Moved to api-entities.js.old"
fi

# Step 4: Summary
echo ""
echo "====================================="
echo "📊 Summary"
echo "====================================="
echo -e "Files fixed: ${GREEN}$FIXED${NC}"
echo ""

if [ $FIXED -gt 0 ]; then
    echo -e "${GREEN}✅ Import fixes applied!${NC}"
    echo ""
    echo "All imports now use: import { ... } from '@/api/entities'"
else
    echo -e "${YELLOW}ℹ️  No files needed fixing${NC}"
fi

echo ""
echo "Next: Run npm run build to test"
