#!/bin/bash

echo "========================================="
echo "Build Verification Script"
echo "========================================="
echo ""

# Check if .next directory exists
if [ ! -d ".next" ]; then
    echo "❌ No build found. Run 'npm run build' first."
    exit 1
fi

echo "Checking for OLD Supabase URL in build output..."
echo "-------------------------------------------------"

OLD_URL="zxgoexjnudlauzgpgsua"
CORRECT_URL="jeukrohcgbnyquzrqvqr"

# Search in build output
OLD_REFS=$(find .next/static -type f -name "*.js" -exec grep -l "$OLD_URL" {} \; 2>/dev/null)

if [ -n "$OLD_REFS" ]; then
    echo "❌ FOUND OLD SUPABASE URL IN BUILD!"
    echo ""
    echo "Files containing old URL:"
    echo "$OLD_REFS"
    echo ""
    echo "Your environment variables are NOT being picked up correctly."
    echo "Try:"
    echo "  1. Delete .next folder: rm -rf .next"
    echo "  2. Verify .env files with: cat .env .env.local"
    echo "  3. Rebuild: npm run build"
    exit 1
else
    echo "✅ No references to old Supabase URL found"
fi

echo ""
echo "Checking for CORRECT Supabase URL..."
echo "-------------------------------------"

CORRECT_REFS=$(find .next/static -type f -name "*.js" -exec grep -l "$CORRECT_URL" {} \; 2>/dev/null | wc -l)

if [ "$CORRECT_REFS" -gt 0 ]; then
    echo "✅ Found correct Supabase URL in $CORRECT_REFS file(s)"
    echo ""
    echo "Build is GOOD! Safe to deploy."
else
    echo "⚠️  Could not find correct Supabase URL"
    echo "This might be okay if env vars are loaded at runtime."
fi

echo ""
echo "Verifying environment files..."
echo "------------------------------"

if grep -q "$CORRECT_URL" .env 2>/dev/null; then
    echo "✅ .env has correct URL"
else
    echo "❌ .env missing or incorrect"
fi

if grep -q "$CORRECT_URL" .env.local 2>/dev/null; then
    echo "✅ .env.local has correct URL"
else
    echo "⚠️  .env.local missing or incorrect"
fi

echo ""
echo "========================================="
echo "Verification Complete"
echo "========================================="
