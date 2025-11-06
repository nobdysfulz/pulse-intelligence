const fs = require('fs');

const filePath = 'src/components/referrals/ReferralTracker.jsx';
let content = fs.readFileSync(filePath, 'utf8');

// Fix the getItem calls - they need proper ternary syntax
content = content.replace(
  /const storedReferralData = if \(typeof window !== "undefined"\) \? localStorage\.getItem\('referralData'\);/,
  'const storedReferralData = typeof window !== "undefined" ? localStorage.getItem(\'referralData\') : null;'
);

content = content.replace(
  /const userJustSignedUp = if \(typeof window !== "undefined"\) \? localStorage\.getItem\('userJustSignedUp'\);/,
  'const userJustSignedUp = typeof window !== "undefined" ? localStorage.getItem(\'userJustSignedUp\') : null;'
);

// Fix the setItem and removeItem calls
content = content.replace(
  /if \(typeof window !== "undefined"\) localStorage\.setItem\('referralData', JSON\.stringify\(referralData\)\);/g,
  'if (typeof window !== "undefined") { localStorage.setItem(\'referralData\', JSON.stringify(referralData)); }'
);

content = content.replace(
  /if \(typeof window !== "undefined"\) localStorage\.setItem\('userJustSignedUp', 'true'\);/g,
  'if (typeof window !== "undefined") { localStorage.setItem(\'userJustSignedUp\', \'true\'); }'
);

content = content.replace(
  /if \(typeof window !== "undefined"\) localStorage\.removeItem\('referralData'\);/g,
  'if (typeof window !== "undefined") { localStorage.removeItem(\'referralData\'); }'
);

content = content.replace(
  /if \(typeof window !== "undefined"\) localStorage\.removeItem\('userJustSignedUp'\);/g,
  'if (typeof window !== "undefined") { localStorage.removeItem(\'userJustSignedUp\'); }'
);

fs.writeFileSync(filePath, content);
console.log('Fixed ReferralTracker syntax errors');
