#!/bin/bash

echo "Fixing import paths system-wide..."

# Find all JSX/TSX files and fix common import patterns
find . \( -name "*.jsx" -o -name "*.tsx" -o -name "*.ts" \) -type f | grep -v node_modules | while read file; do
    echo "Checking: $file"
    
    # Fix react-router-dom imports (should already be mostly done, but catch any stragglers)
    sed -i '' "s/from ['\"]react-router-dom['\"]//g" "$file"
    
    # Fix relative path imports that are wrong
    # Fix ../components/ to ../../components/ for app directory files
    if [[ "$file" == ./app/* ]]; then
        sed -i '' "s/from '\.\.\/components\//from '\.\.\/\.\.\/components\//g" "$file"
        sed -i '' "s/from \"\.\.\/components\//from \"\.\.\/\.\.\/components\//g" "$file"
    fi
    
    # Fix @/ imports that point to wrong locations
    sed -i '' "s/from '@\/components\//from '\.\.\/\.\.\/components\//g" "$file"
    sed -i '' "s/from \"@\/components\//from \"\.\.\/\.\.\/components\//g" "$file"
    
    # Fix @/lib imports to use correct relative paths
    sed -i '' "s/from '@\/lib\//from '\.\.\/\.\.\/lib\//g" "$file"
    sed -i '' "s/from \"@\/lib\//from \"\.\.\/\.\.\/lib\//g" "$file"
    
    # Fix @/api imports
    sed -i '' "s/from '@\/api\//from '\.\.\/\.\.\/api\//g" "$file"
    sed -i '' "s/from \"@\/api\//from \"\.\.\/\.\.\/api\//g" "$file"
    
    # Fix @/integrations imports  
    sed -i '' "s/from '@\/integrations\//from '\.\.\/\.\.\/integrations\//g" "$file"
    sed -i '' "s/from \"@\/integrations\//from \"\.\.\/\.\.\/integrations\//g" "$file"
    
    # Fix @/utils imports
    sed -i '' "s/from '@\/utils\//from '\.\.\/\.\.\/utils\//g" "$file"
    sed -i '' "s/from \"@\/utils\//from \"\.\.\/\.\.\/utils\//g" "$file"
    
    # Fix @/hooks imports
    sed -i '' "s/from '@\/hooks\//from '\.\.\/\.\.\/hooks\//g" "$file"
    sed -i '' "s/from \"@\/hooks\//from \"\.\.\/\.\.\/hooks\//g" "$file"
done

echo "Import path fixes complete!"
