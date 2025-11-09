#!/usr/bin/env node

/**
 * Migration Script: Update all files to use useInvokeFunction hook
 *
 * This script automatically migrates files from using supabase.functions.invoke()
 * directly to using the useInvokeFunction hook which uses direct fetch with
 * x-clerk-auth header instead of Authorization header.
 *
 * Usage:
 *   node scripts/migrate-to-useInvokeFunction.js [--dry-run] [--file=path/to/file.jsx]
 */

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

// Configuration
const DRY_RUN = process.argv.includes('--dry-run');
const SPECIFIC_FILE = process.argv.find(arg => arg.startsWith('--file='))?.split('=')[1];
const BACKUP_DIR = `migration_backup_${new Date().toISOString().replace(/[:.]/g, '-')}`;

// Statistics
const stats = {
  filesProcessed: 0,
  filesModified: 0,
  invocationsReplaced: 0,
  errors: [],
};

/**
 * Find all files that use supabase.functions.invoke
 */
function findFilesToMigrate() {
  if (SPECIFIC_FILE) {
    return [SPECIFIC_FILE];
  }

  console.log('🔍 Finding files that use supabase.functions.invoke...\n');

  try {
    const output = execSync('grep -rl "supabase\\.functions\\.invoke" src/', {
      encoding: 'utf-8',
      stdio: ['pipe', 'pipe', 'ignore'] // Suppress stderr
    });

    const files = output.split('\n')
      .filter(f => f.trim())
      .filter(f => !f.includes('backup'))
      .filter(f => !f.includes('.bak'))
      .filter(f => !f.endsWith('supabase-functions.ts')) // Skip the helper file itself
      .filter(f => f.match(/\.(jsx|tsx|js|ts)$/));

    console.log(`Found ${files.length} files to process\n`);
    return files;
  } catch (error) {
    // grep returns exit code 1 if no matches, which is fine
    if (error.status === 1) {
      console.log('No files found with supabase.functions.invoke\n');
      return [];
    }
    throw error;
  }
}

/**
 * Check if file is a React component (has JSX/TSX or uses React)
 */
function isReactComponent(content) {
  return (
    content.includes('import React') ||
    content.includes('from \'react\'') ||
    content.includes('from "react"') ||
    content.match(/function\s+\w+\s*\([^)]*\)\s*\{/) ||
    content.match(/const\s+\w+\s*=\s*\([^)]*\)\s*=>/) ||
    content.includes('export default function') ||
    content.includes('export function')
  );
}

/**
 * Check if file already imports useInvokeFunction
 */
function hasUseInvokeFunctionImport(content) {
  return content.includes('useInvokeFunction');
}

/**
 * Add import for useInvokeFunction if not present
 */
function addUseInvokeFunctionImport(content) {
  if (hasUseInvokeFunctionImport(content)) {
    return content;
  }

  // Find the last import statement
  const importRegex = /import\s+.*?from\s+['"][^'"]+['"];?\n/g;
  const imports = content.match(importRegex) || [];

  if (imports.length === 0) {
    // No imports found, add at the beginning
    return `import { useInvokeFunction } from '@/lib/supabase-functions';\n\n${content}`;
  }

  // Add after the last import
  const lastImport = imports[imports.length - 1];
  const lastImportIndex = content.lastIndexOf(lastImport);
  const insertPosition = lastImportIndex + lastImport.length;

  return content.slice(0, insertPosition) +
         `import { useInvokeFunction } from '@/lib/supabase-functions';\n` +
         content.slice(insertPosition);
}

/**
 * Remove supabase import if it's no longer needed
 */
function removeSupabaseImportIfUnneeded(content) {
  // Check if supabase is used for anything other than functions.invoke
  const hasOtherSupabaseUsage =
    content.match(/supabase\.(from|auth|storage|channel|realtime)/);

  if (hasOtherSupabaseUsage) {
    return content; // Keep the import
  }

  // Remove the supabase import line
  return content.replace(
    /import\s+\{\s*supabase\s*\}\s+from\s+['"]@\/integrations\/supabase\/client['"];?\n/g,
    ''
  );
}

/**
 * Find the main component function in the file
 */
function findComponentFunction(content) {
  // Try to find the main component export
  const patterns = [
    /export\s+default\s+function\s+(\w+)\s*\([^)]*\)\s*\{/,
    /export\s+function\s+(\w+)\s*\([^)]*\)\s*\{/,
    /const\s+(\w+)\s*=\s*\([^)]*\)\s*=>\s*\{/,
    /function\s+(\w+)\s*\([^)]*\)\s*\{/
  ];

  for (const pattern of patterns) {
    const match = content.match(pattern);
    if (match) {
      return {
        name: match[1],
        match: match[0],
        index: match.index
      };
    }
  }

  return null;
}

/**
 * Add useInvokeFunction hook call to component
 */
function addUseInvokeFunctionHook(content) {
  // Check if already has the hook
  if (content.match(/const\s+\w+\s*=\s*useInvokeFunction\s*\(/)) {
    return content;
  }

  const componentFunc = findComponentFunction(content);
  if (!componentFunc) {
    console.log('  ⚠️  Could not find component function, skipping hook injection');
    return content;
  }

  // Find the position right after the opening brace of the component
  const funcBodyStart = componentFunc.index + componentFunc.match.length;

  // Find existing hooks to place our hook with them
  const beforeInsertion = content.slice(0, funcBodyStart);
  const afterInsertion = content.slice(funcBodyStart);

  // Check if there are already hooks in the component
  const hasHooks = afterInsertion.match(/^\s*(const|let|var)\s+\w+\s*=\s*use\w+/m);

  let hookCode;
  if (hasHooks) {
    // Add with minimal spacing if other hooks exist
    hookCode = '\n  const invokeFunction = useInvokeFunction();';
  } else {
    // Add with more spacing if this is the first hook
    hookCode = '\n  const invokeFunction = useInvokeFunction();\n';
  }

  return beforeInsertion + hookCode + afterInsertion;
}

/**
 * Replace supabase.functions.invoke calls with invokeFunction
 */
function replaceInvokeCalls(content) {
  let modified = content;
  let replacementCount = 0;

  // Pattern to match supabase.functions.invoke calls
  // This handles both simple and complex cases
  const invokePattern = /supabase\.functions\.invoke\s*\(\s*(['"`])([^'"`]+)\1\s*,?\s*(\{[^}]*\})?/g;

  modified = modified.replace(invokePattern, (match, quote, functionName, options) => {
    replacementCount++;

    if (options) {
      // Has options object
      return `invokeFunction(${quote}${functionName}${quote}, ${options}`;
    } else {
      // No options
      return `invokeFunction(${quote}${functionName}${quote}`;
    }
  });

  return { modified, replacementCount };
}

/**
 * Process a single file
 */
function processFile(filePath) {
  console.log(`\n📄 Processing: ${filePath}`);
  stats.filesProcessed++;

  try {
    const content = fs.readFileSync(filePath, 'utf-8');

    // Check if file has supabase.functions.invoke
    if (!content.includes('supabase.functions.invoke')) {
      console.log('  ℹ️  No supabase.functions.invoke found, skipping');
      return;
    }

    // Check if it's a React component
    if (!isReactComponent(content)) {
      console.log('  ⚠️  Not a React component, manual migration required');
      stats.errors.push({
        file: filePath,
        reason: 'Not a React component - needs manual migration'
      });
      return;
    }

    let modified = content;

    // Step 1: Add useInvokeFunction import
    console.log('  ✓ Adding useInvokeFunction import');
    modified = addUseInvokeFunctionImport(modified);

    // Step 2: Add useInvokeFunction hook call
    console.log('  ✓ Adding useInvokeFunction hook call');
    modified = addUseInvokeFunctionHook(modified);

    // Step 3: Replace all supabase.functions.invoke calls
    const { modified: finalContent, replacementCount } = replaceInvokeCalls(modified);
    modified = finalContent;

    console.log(`  ✓ Replaced ${replacementCount} supabase.functions.invoke call(s)`);
    stats.invocationsReplaced += replacementCount;

    // Step 4: Remove supabase import if no longer needed
    modified = removeSupabaseImportIfUnneeded(modified);

    if (modified !== content) {
      stats.filesModified++;

      if (DRY_RUN) {
        console.log('  🔍 [DRY RUN] Would modify this file');
        // Optionally show diff
        // console.log('\n--- CHANGES ---');
        // console.log(modified);
      } else {
        // Create backup
        const backupPath = path.join(BACKUP_DIR, filePath.replace(/\//g, '_'));
        fs.mkdirSync(BACKUP_DIR, { recursive: true });
        fs.writeFileSync(backupPath, content);

        // Write modified content
        fs.writeFileSync(filePath, modified);
        console.log('  ✅ File updated successfully');
      }
    } else {
      console.log('  ℹ️  No changes needed');
    }

  } catch (error) {
    console.error(`  ❌ Error processing file: ${error.message}`);
    stats.errors.push({
      file: filePath,
      reason: error.message
    });
  }
}

/**
 * Main migration function
 */
function migrate() {
  console.log('🚀 Starting migration to useInvokeFunction hook\n');
  console.log('═'.repeat(60));

  if (DRY_RUN) {
    console.log('🔍 DRY RUN MODE - No files will be modified\n');
  }

  const files = findFilesToMigrate();

  if (files.length === 0) {
    console.log('✨ No files to migrate!\n');
    return;
  }

  console.log(`Found ${files.length} file(s) to process\n`);
  console.log('═'.repeat(60));

  // Process each file
  files.forEach(processFile);

  // Print summary
  console.log('\n' + '═'.repeat(60));
  console.log('📊 Migration Summary\n');
  console.log(`Files processed:           ${stats.filesProcessed}`);
  console.log(`Files modified:            ${stats.filesModified}`);
  console.log(`Invocations replaced:      ${stats.invocationsReplaced}`);
  console.log(`Errors:                    ${stats.errors.length}`);

  if (stats.errors.length > 0) {
    console.log('\n⚠️  Files requiring manual migration:\n');
    stats.errors.forEach(({ file, reason }) => {
      console.log(`  • ${file}`);
      console.log(`    Reason: ${reason}\n`);
    });
  }

  if (!DRY_RUN && stats.filesModified > 0) {
    console.log(`\n📦 Backups saved to: ${BACKUP_DIR}/`);
  }

  console.log('\n' + '═'.repeat(60));

  if (DRY_RUN) {
    console.log('\n💡 Run without --dry-run to apply changes');
  } else if (stats.filesModified > 0) {
    console.log('\n✅ Migration complete! Next steps:');
    console.log('   1. Review the changes in git diff');
    console.log('   2. Test the application thoroughly');
    console.log('   3. Commit the changes if everything works');
  }
}

// Run migration
try {
  migrate();
} catch (error) {
  console.error('\n❌ Migration failed:', error.message);
  console.error(error.stack);
  process.exit(1);
}
