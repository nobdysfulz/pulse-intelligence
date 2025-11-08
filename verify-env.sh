#!/bin/bash

echo "========================================="
echo "Environment Variables Verification"
echo "========================================="
echo ""

echo "Local .env files:"
echo "-----------------"
if [ -f .env ]; then
    echo "✓ .env exists"
    grep "NEXT_PUBLIC_SUPABASE_URL" .env
else
    echo "✗ .env not found"
fi

if [ -f .env.local ]; then
    echo "✓ .env.local exists"
    grep "NEXT_PUBLIC_SUPABASE_URL" .env.local
else
    echo "✗ .env.local not found"
fi

echo ""
echo "Expected values:"
echo "-----------------"
echo "NEXT_PUBLIC_SUPABASE_URL=https://jeukrohcgbnyquzrqvqr.supabase.co"
echo ""

echo "Searching for hardcoded references to OLD Supabase URL..."
echo "---------------------------------------------------------"
OLD_REFS=$(grep -r "zxgoexjnudlauzgpgsua" . --include="*.ts" --include="*.tsx" --include="*.js" --include="*.jsx" 2>/dev/null | grep -v node_modules | grep -v ".next" | grep -v "BUILD")

if [ -z "$OLD_REFS" ]; then
    echo "✓ No hardcoded references to old Supabase URL found"
else
    echo "✗ Found hardcoded references:"
    echo "$OLD_REFS"
fi

echo ""
echo "Next steps:"
echo "-----------"
echo "1. Follow instructions in VERCEL_ENV_FIX.md"
echo "2. Update Vercel environment variables"
echo "3. Force a clean deployment"
echo ""
