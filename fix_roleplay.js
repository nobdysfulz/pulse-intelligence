const fs = require('fs');
const content = fs.readFileSync('app/role-play/page.tsx', 'utf8');

// Fix the derivedPassFail function - remove the IIFE and make it a regular function
const fixedContent = content.replace(
  /const derivedPassFail = \(\) => {[^}]+}\)\);/, 
  match => match.replace('})();', '});')
);

fs.writeFileSync('app/role-play/page.tsx', fixedContent);
console.log('Fixed Role-Play function structure');
