#!/bin/bash

echo "Fixing nested import paths system-wide..."

# Find all JSX/TSX files and fix nested import patterns
find . \( -name "*.jsx" -o -name "*.tsx" -o -name "*.js" \) -type f | grep -v node_modules | while read file; do
    echo "Checking: $file"
    
    # For files in src/components directory, fix imports going up multiple levels
    if [[ "$file" == ./src/components/* ]]; then
        # Fix imports that need to go from src/components to root level components
        sed -i '' "s/from '\.\.\/\.\.\/components\//from '\.\.\/\.\.\/\.\.\/components\//g" "$file"
        sed -i '' "s/from \"\.\.\/\.\.\/components\//from \"\.\.\/\.\.\/\.\.\/components\//g" "$file"
        
        # Fix imports that need to go from src/components to root level api
        sed -i '' "s/from '\.\.\/\.\.\/api\//from '\.\.\/\.\.\/\.\.\/api\//g" "$file"
        sed -i '' "s/from \"\.\.\/\.\.\/api\//from \"\.\.\/\.\.\/\.\.\/api\//g" "$file"
        
        # Fix imports from src/components to src/api
        sed -i '' "s/from '\.\.\/api\//from '\.\.\/\.\.\/src\/api\//g" "$file"
        sed -i '' "s/from \"\.\.\/api\//from \"\.\.\/\.\.\/src\/api\//g" "$file"
    fi
    
    # For files in components directory (not src), fix imports
    if [[ "$file" == ./components/* ]]; then
        # Fix imports from components to src/api
        sed -i '' "s/from '\.\.\/\.\.\/api\//from '\.\.\/\.\.\/src\/api\//g" "$file"
        sed -i '' "s/from \"\.\.\/\.\.\/api\//from \"\.\.\/\.\.\/src\/api\//g" "$file"
        
        # Fix imports from components to api
        sed -i '' "s/from '\.\.\/api\//from '\.\.\/\.\.\/src\/api\//g" "$file"
        sed -i '' "s/from \"\.\.\/api\//from \"\.\.\/\.\.\/src\/api\//g" "$file"
    fi
    
    # Fix common problematic patterns regardless of location
    sed -i '' "s/from '\.\.\/components\/ui\/button'/from '\.\.\/\.\.\/\.\.\/components\/ui\/button'/g" "$file"
    sed -i '' "s/from \"\.\.\/components\/ui\/button\"/from \"\.\.\/\.\.\/\.\.\/components\/ui\/button\"/g" "$file"
    
    sed -i '' "s/from '\.\.\/components\/ui\/input'/from '\.\.\/\.\.\/\.\.\/components\/ui\/input'/g" "$file"
    sed -i '' "s/from \"\.\.\/components\/ui\/input\"/from \"\.\.\/\.\.\/\.\.\/components\/ui\/input\"/g" "$file"
    
    sed -i '' "s/from '\.\.\/api\/entities'/from '\.\.\/\.\.\/src\/api\/entities'/g" "$file"
    sed -i '' "s/from \"\.\.\/api\/entities\"/from \"\.\.\/\.\.\/src\/api\/entities\"/g" "$file"
done

echo "Nested import fixes complete!"
