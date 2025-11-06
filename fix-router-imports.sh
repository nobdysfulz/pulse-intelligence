#!/bin/bash

# Function to replace imports in a single file
replace_imports() {
    local file=$1
    
    # Replace useNavigate with useRouter
    sed -i '' "s/import { useNavigate } from 'react-router-dom'/import { useRouter } from 'next\/navigation'/g" "$file"
    
    # Replace useLocation with usePathname  
    sed -i '' "s/import { useLocation } from 'react-router-dom'/import { usePathname } from 'next\/navigation'/g" "$file"
    
    # Replace both useNavigate and useLocation
    sed -i '' "s/import { useNavigate, useLocation } from 'react-router-dom'/import { useRouter, usePathname } from 'next\/navigation'/g" "$file"
    
    # Replace Link imports
    sed -i '' "s/import { Link } from 'react-router-dom'/import Link from 'next\/link'/g" "$file"
    
    # Replace NavLink imports (convert to Link)
    sed -i '' "s/import { NavLink, useLocation } from 'react-router-dom'/import { usePathname } from 'next\/navigation'; import Link from 'next\/link'/g" "$file"
    
    # Replace Navigate imports
    sed -i '' "s/import { Navigate } from 'react-router-dom'/import { redirect } from 'next\/navigation'/g" "$file"
    
    echo "Updated: $file"
}

# Export the function so we can use it
export -f replace_imports

# Find all files and process them
find src/ components/ -name "*.jsx" -o -name "*.tsx" | head -10 | while read file; do
    if grep -q "from 'react-router-dom'" "$file"; then
        replace_imports "$file"
    fi
done

echo "First batch complete. Run 'npm run build' to test."
