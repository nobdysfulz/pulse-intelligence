#!/bin/bash

# PULSE AI - Next.js Migration Fix Script
# Fixes all import paths and router references for Next.js 14 App Router

echo "🚀 Starting Next.js Migration Fixes..."
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Counter variables
total_files=0
fixed_files=0
error_files=0

# Function to fix a single file
fix_file() {
    local file="$1"
    local temp_file="${file}.tmp"
    local changes_made=false
    
    # Skip if file doesn't exist or is not readable
    if [ ! -f "$file" ] || [ ! -r "$file" ]; then
        return
    fi
    
    # Create backup
    cp "$file" "${file}.backup_$(date +%Y%m%d_%H%M%S)" 2>/dev/null || true
    
    # Apply all transformations
    cat "$file" | \
    # Fix relative imports pointing to src/ (../../ → @/)
    sed -E "s|from ['\"](\.\./)+components/|from '@/components/|g" | \
    sed -E "s|from ['\"](\.\./)+api/|from '@/api/|g" | \
    sed -E "s|from ['\"](\.\./)+integrations/|from '@/integrations/|g" | \
    sed -E "s|from ['\"](\.\./)+hooks/|from '@/hooks/|g" | \
    sed -E "s|from ['\"](\.\./)+utils/|from '@/utils/|g" | \
    sed -E "s|from ['\"](\.\./)+lib/|from '@/lib/|g" | \
    sed -E "s|from ['\"](\.\./)+config/|from '@/config/|g" | \
    
    # Fix incorrect @/ imports (only if they're truly incorrect)
    sed -E "s|from '@/utils'|from '@/utils'|g" | \
    
    # Fix React Router imports to Next.js
    sed "s|from 'react-router-dom'|from 'next/navigation'|g" | \
    sed "s|from \"react-router-dom\"|from 'next/navigation'|g" | \
    
    # Fix router hook usage
    sed -E "s|const navigate = useNavigate\(\)|const router = useRouter()|g" | \
    sed -E "s|const router = useRouter\(\);|const router = useRouter();|g" | \
    sed -E "s|navigate\(|router.push(|g" | \
    
    # Fix Link component imports
    sed "s|import { Link }|import Link|g" | \
    sed "s|import { Link,|import Link, {|g" | \
    
    # Fix createPageUrl usage (convert to direct paths)
    sed -E "s|createPageUrl\('([^']+)'\)|'/$1'|g" | \
    sed -E "s|createPageUrl\(\"([^\"]+)\"\)|'/$1'|g" | \
    
    # Convert page names to lowercase routes
    sed "s|'/Dashboard'|'/dashboard'|g" | \
    sed "s|'/Goals'|'/goals'|g" | \
    sed "s|'/ToDo'|'/to-do'|g" | \
    sed "s|'/Agents'|'/agents'|g" | \
    sed "s|'/PersonalAdvisor'|'/personaladvisor'|g" | \
    sed "s|'/Market'|'/market'|g" | \
    sed "s|'/RolePlay'|'/role-play'|g" | \
    sed "s|'/ContentStudio'|'/content-studio'|g" | \
    sed "s|'/Settings'|'/settings'|g" | \
    sed "s|'/Intelligence'|'/intelligence'|g" | \
    sed "s|'/Plans'|'/plans'|g" | \
    sed "s|'/Onboarding'|'/onboarding'|g" \
    > "$temp_file"
    
    # Check if file was modified
    if ! cmp -s "$file" "$temp_file"; then
        mv "$temp_file" "$file"
        changes_made=true
        ((fixed_files++))
        echo -e "${GREEN}✓${NC} Fixed: $file"
    else
        rm "$temp_file"
    fi
    
    ((total_files++))
}

# Find and fix all TypeScript/JavaScript files in app directory
echo "📁 Scanning app/ directory..."
while IFS= read -r -d '' file; do
    fix_file "$file"
done < <(find ./app -type f \( -name "*.tsx" -o -name "*.ts" -o -name "*.jsx" -o -name "*.js" \) -print0 2>/dev/null)

# Find and fix all files in src directory that might be used by app
echo ""
echo "📁 Scanning src/ directory..."
while IFS= read -r -d '' file; do
    fix_file "$file"
done < <(find ./src -type f \( -name "*.tsx" -o -name "*.ts" -o -name "*.jsx" -o -name "*.js" \) -print0 2>/dev/null)

# Summary
echo ""
echo "================================"
echo "📊 Migration Fix Summary"
echo "================================"
echo -e "Total files scanned: ${YELLOW}$total_files${NC}"
echo -e "Files modified: ${GREEN}$fixed_files${NC}"
echo -e "Files with errors: ${RED}$error_files${NC}"
echo ""

if [ $fixed_files -gt 0 ]; then
    echo -e "${GREEN}✅ Import fixes applied successfully!${NC}"
    echo ""
    echo "Next steps:"
    echo "1. Review the changes: git diff"
    echo "2. Test the build: npm run build"
    echo "3. If issues persist, check specific files for manual fixes"
else
    echo -e "${YELLOW}⚠️  No changes were needed${NC}"
fi

echo ""
echo "Backup files created with pattern: *.backup_YYYYMMDD_HHMMSS"
echo "You can remove them after verifying the fixes work."
