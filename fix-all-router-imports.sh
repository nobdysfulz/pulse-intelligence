#!/bin/bash

echo "Processing all files with react-router-dom imports..."

# Find and process all files
find src/ components/ -name "*.jsx" -o -name "*.tsx" | while read file; do
    if grep -q "from 'react-router-dom'" "$file"; then
        echo "Processing: $file"
        
        # Replace useNavigate with useRouter
        sed -i '' "s/import { useNavigate } from 'react-router-dom'/import { useRouter } from 'next\/navigation'/g" "$file"
        
        # Replace useLocation with usePathname  
        sed -i '' "s/import { useLocation } from 'react-router-dom'/import { usePathname } from 'next\/navigation'/g" "$file"
        
        # Replace both useNavigate and useLocation
        sed -i '' "s/import { useNavigate, useLocation } from 'react-router-dom'/import { useRouter, usePathname } from 'next\/navigation'/g" "$file"
        sed -i '' "s/import { useLocation, useNavigate } from 'react-router-dom'/import { usePathname, useRouter } from 'next\/navigation'/g" "$file"
        
        # Replace Link imports
        sed -i '' "s/import { Link } from 'react-router-dom'/import Link from 'next\/link'/g" "$file"
        
        # Replace NavLink imports
        sed -i '' "s/import { NavLink } from 'react-router-dom'/import Link from 'next\/link'/g" "$file"
        sed -i '' "s/import { NavLink, useLocation } from 'react-router-dom'/import { usePathname } from 'next\/navigation'; import Link from 'next\/link'/g" "$file"
        
        # Replace Navigate imports
        sed -i '' "s/import { Navigate } from 'react-router-dom'/import { redirect } from 'next\/navigation'/g" "$file"
        
        # Replace complex imports (BrowserRouter, Routes, Route)
        sed -i '' "s/import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom'//g" "$file"
        sed -i '' "s/import { BrowserRouter, Routes, Route } from 'react-router-dom'//g" "$file"
        
        echo "✅ Updated: $file"
    fi
done

echo "All files processed!"
