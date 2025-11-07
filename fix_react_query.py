import re
import glob
import os

# Pattern to find and fix React Query invalidateQueries calls
pattern = r'invalidateQueries\(\s*{\s*queryKey:\s*\[([^]]+)\]\s*\)\s*;'
replacement = r'invalidateQueries({ queryKey: [\1] });'

# Find all page.tsx files
pages = glob.glob('app/**/page.tsx', recursive=True)

for page in pages:
    with open(page, 'r') as f:
        content = f.read()
    
    # Fix the pattern
    new_content = re.sub(pattern, replacement, content)
    
    if new_content != content:
        print(f"Fixed React Query syntax in {page}")
        with open(page, 'w') as f:
            f.write(new_content)
    else:
        print(f"No fixes needed in {page}")

print("React Query syntax fixes completed!")
