#!/bin/bash

# Fix Bearer prefix validation in Edge Functions
# The issue: Functions reject requests that don't start with "Bearer "
# But x-clerk-auth sends raw JWT without "Bearer " prefix

echo "Fixing Bearer prefix validation in Edge Functions..."

count=0

find supabase/functions -name "index.ts" -type f | while read -r file; do
  # Skip if file doesn't contain the problematic check
  if ! grep -q "startsWith('Bearer ')" "$file"; then
    continue
  fi

  echo "Processing: $file"

  # Create backup
  cp "$file" "$file.bearer-fix-backup"

  # Fix the validation check
  # OLD: if (!authHeader?.startsWith('Bearer ')) {
  # NEW: if (!authHeader) {

  sed -i '' "s/if (!authHeader\?\.startsWith('Bearer '))/if (!authHeader)/g" "$file"

  echo "  ✓ Fixed Bearer validation check"
  count=$((count + 1))
done

echo ""
echo "✅ Fixed $count Edge Functions"
echo "Ready to deploy!"
