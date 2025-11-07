const fs = require('fs');
const content = fs.readFileSync('app/personaladvisor/page.tsx', 'utf8');

let braceCount = 0;
let parenCount = 0;
let bracketCount = 0;

content.split('\n').forEach((line, index) => {
  const lineNum = index + 1;
  
  // Count braces
  const openBraces = (line.match(/{/g) || []).length;
  const closeBraces = (line.match(/}/g) || []).length;
  braceCount += openBraces - closeBraces;
  
  // Count parentheses
  const openParens = (line.match(/\(/g) || []).length;
  const closeParens = (line.match(/\)/g) || []).length;
  parenCount += openParens - closeParens;
  
  // Count brackets
  const openBrackets = (line.match(/\[/g) || []).length;
  const closeBrackets = (line.match(/\]/g) || []).length;
  bracketCount += openBrackets - closeBrackets;
  
  if (braceCount < 0 || parenCount < 0 || bracketCount < 0) {
    console.log(`Line ${lineNum}: Unbalanced - braces:${braceCount}, parens:${parenCount}, brackets:${bracketCount}`);
  }
});

console.log(`Final counts - Braces: ${braceCount}, Parens: ${parenCount}, Brackets: ${bracketCount}`);

// Also check for specific problematic patterns
console.log("\n=== Checking for common syntax issues ===");
const lines = content.split('\n');
lines.forEach((line, index) => {
  const lineNum = index + 1;
  
  // Check for if statements with extra braces
  if (line.match(/if\s*\([^)]*\)\s*{/)) {
    console.log(`Line ${lineNum}: Found if statement with brace - "${line.trim()}"`);
  }
  
  // Check for function calls with extra braces
  if (line.match(/\)\s*{/)) {
    console.log(`Line ${lineNum}: Found function call with brace - "${line.trim()}"`);
  }
});
