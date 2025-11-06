#!/bin/bash

# Path Alias Verification Script
# Tests if @/ imports are correctly configured

echo "🔍 Path Alias Verification"
echo "=========================="
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Check if tsconfig.json exists and has paths
echo -e "${BLUE}Checking tsconfig.json...${NC}"
if [ -f "tsconfig.json" ]; then
    if grep -q '"@/\*"' tsconfig.json; then
        echo -e "${GREEN}✓${NC} tsconfig.json has @/ path aliases configured"
        echo "  Configured paths:"
        grep -A 10 '"paths"' tsconfig.json | grep '@/' | sed 's/^/    /'
    else
        echo -e "${RED}✗${NC} tsconfig.json missing @/ path configuration"
    fi
else
    echo -e "${RED}✗${NC} tsconfig.json not found"
fi

echo ""

# Check if next.config.mjs exists and has webpack aliases
echo -e "${BLUE}Checking next.config.mjs...${NC}"
if [ -f "next.config.mjs" ]; then
    if grep -q '@.*path.resolve' next.config.mjs; then
        echo -e "${GREEN}✓${NC} next.config.mjs has webpack aliases configured"
        echo "  Configured aliases:"
        grep '@.*path.resolve' next.config.mjs | sed 's/^/    /'
    else
        echo -e "${YELLOW}⚠${NC} next.config.mjs might need webpack alias configuration"
    fi
else
    echo -e "${RED}✗${NC} next.config.mjs not found"
fi

echo ""

# Check module resolution in tsconfig
echo -e "${BLUE}Checking module resolution...${NC}"
MODULE_RES=$(grep '"moduleResolution"' tsconfig.json | cut -d'"' -f4)
if [ "$MODULE_RES" = "node" ]; then
    echo -e "${GREEN}✓${NC} Using 'node' module resolution (correct for Next.js)"
elif [ "$MODULE_RES" = "bundler" ]; then
    echo -e "${RED}✗${NC} Using 'bundler' module resolution (this is for Vite, not Next.js)"
    echo "  Should be 'node' for Next.js"
else
    echo -e "${YELLOW}⚠${NC} Module resolution: $MODULE_RES"
fi

echo ""

# Test actual import patterns in files
echo -e "${BLUE}Checking current import usage...${NC}"

# Count @/ imports
AT_IMPORTS=$(grep -r "from '@/" app/ src/ --include='*.tsx' --include='*.jsx' --include='*.ts' --include='*.js' 2>/dev/null | wc -l | tr -d ' ')
echo "  @/ imports found: $AT_IMPORTS"

# Count relative imports that should be @/
RELATIVE_IMPORTS=$(grep -r "from '\.\./\.\." app/ --include='*.tsx' --include='*.jsx' 2>/dev/null | wc -l | tr -d ' ')
if [ "$RELATIVE_IMPORTS" -gt 0 ]; then
    echo -e "  ${YELLOW}⚠${NC} Relative imports in app/: $RELATIVE_IMPORTS (should use @/)"
else
    echo -e "  ${GREEN}✓${NC} No problematic relative imports in app/"
fi

echo ""

# Check for common import patterns
echo -e "${BLUE}Analyzing import patterns...${NC}"

# Check for @/utils usage
UTILS_IMPORTS=$(grep -r "from '@/utils" app/ src/ --include='*.tsx' --include='*.jsx' 2>/dev/null | wc -l | tr -d ' ')
echo "  @/utils imports: $UTILS_IMPORTS"

# Check for @/components usage
COMP_IMPORTS=$(grep -r "from '@/components" app/ src/ --include='*.tsx' --include='*.jsx' 2>/dev/null | wc -l | tr -d ' ')
echo "  @/components imports: $COMP_IMPORTS"

# Check for @/api usage
API_IMPORTS=$(grep -r "from '@/api" app/ src/ --include='*.tsx' --include='*.jsx' 2>/dev/null | wc -l | tr -d ' ')
echo "  @/api imports: $API_IMPORTS"

echo ""

# Recommend actions
echo -e "${BLUE}Recommendations:${NC}"
echo ""

if [ "$MODULE_RES" = "bundler" ]; then
    echo -e "${YELLOW}→${NC} Update moduleResolution to 'node' in tsconfig.json"
fi

if [ "$RELATIVE_IMPORTS" -gt 0 ]; then
    echo -e "${YELLOW}→${NC} Run ./fix-imports-targeted.sh to convert relative imports to @/"
fi

if [ ! -f "next.config.mjs" ]; then
    echo -e "${YELLOW}→${NC} Create next.config.mjs with webpack aliases"
fi

# Try a test build to see if imports resolve
echo ""
echo -e "${BLUE}Testing with TypeScript compiler...${NC}"
echo "(This will show if path aliases are working)"
echo ""

if command -v tsc &> /dev/null; then
    # Run tsc but only show module resolution errors
    npx tsc --noEmit --listFiles 2>&1 | grep -i "error TS2307\|Cannot find module" | head -5
    
    if [ $? -eq 0 ]; then
        echo -e "${YELLOW}⚠${NC} Found module resolution errors (see above)"
        echo "  This means path aliases might not be working correctly"
    else
        echo -e "${GREEN}✓${NC} No obvious module resolution errors found"
    fi
else
    echo -e "${YELLOW}⚠${NC} TypeScript not found, skipping tsc check"
fi

echo ""
echo "=========================="
echo -e "${BOLD}Next steps:${NC}"
echo "1. If module resolution is 'bundler', restart your TypeScript server"
echo "2. Run: ./fix-imports-targeted.sh"
echo "3. Test build: npm run build"
echo ""
