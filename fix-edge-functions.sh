#!/bin/bash

# Script to update Edge Functions to use x-clerk-auth header instead of Authorization

echo "Updating Edge Functions to use x-clerk-auth header..."

# Find all Edge Function index.ts files
find supabase/functions -name "index.ts" -type f | while read -r file; do
  echo "Processing: $file"

  # Skip if already updated (contains x-clerk-auth)
  if grep -q "x-clerk-auth" "$file"; then
    echo "  ✓ Already updated, skipping"
    continue
  fi

  # Skip if doesn't use Authorization header (might not need auth)
  if ! grep -q "Authorization" "$file"; then
    echo "  - No Authorization header found, skipping"
    continue
  fi

  # Create backup
  cp "$file" "$file.bak"

  # Update CORS headers to include x-clerk-auth
  sed -i '' "s/'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type'/'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type, x-clerk-auth'/g" "$file"

  sed -i '' "s/\"Access-Control-Allow-Headers\": \"authorization, x-client-info, apikey, content-type\"/\"Access-Control-Allow-Headers\": \"authorization, x-client-info, apikey, content-type, x-clerk-auth\"/g" "$file"

  # Replace Authorization header reading with x-clerk-auth
  sed -i '' "s/req.headers.get('Authorization')/req.headers.get('x-clerk-auth') || req.headers.get('Authorization')/g" "$file"

  sed -i '' "s/authHeader.substring(7)/authHeader.startsWith('Bearer ') ? authHeader.substring(7) : authHeader/g" "$file"

  echo "  ✓ Updated"
done

echo ""
echo "✅ Done! Edge Functions updated to support x-clerk-auth header"
echo "Note: Functions now accept BOTH x-clerk-auth and Authorization for backwards compatibility"
