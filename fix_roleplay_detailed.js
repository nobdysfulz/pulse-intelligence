const fs = require('fs');
let content = fs.readFileSync('app/role-play/page.tsx', 'utf8');

// Find and fix the derivedPassFail section
const lines = content.split('\n');
let inFunction = false;
let functionStart = -1;

for (let i = 0; i < lines.length; i++) {
  if (lines[i].includes('const derivedPassFail = () => {')) {
    inFunction = true;
    functionStart = i;
  }
  
  if (inFunction && lines[i].includes('});')) {
    // Replace the IIFE pattern with a regular function call
    lines[i] = '  };';
    lines.splice(i + 1, 0, '  ');
    lines.splice(i + 1, 0, '  const derivedPassFailValue = derivedPassFail();');
    break;
  }
}

content = lines.join('\n');
fs.writeFileSync('app/role-play/page.tsx', content);
console.log('Fixed IIFE structure in Role-Play page');
