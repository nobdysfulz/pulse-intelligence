#!/usr/bin/env node

/**
 * JWT Validation Test Script
 *
 * This script helps diagnose JWT authentication issues by:
 * 1. Extracting domain from Clerk publishable key
 * 2. Fetching JWKS endpoint
 * 3. Attempting to verify a sample JWT token
 *
 * Usage:
 *   node test-jwt-validation.js [jwt-token]
 *
 * To get a JWT token:
 * 1. Open https://pulse2.pwru.app
 * 2. Open browser console (F12)
 * 3. Run: await window.Clerk.session.getToken()
 * 4. Copy the token and pass it to this script
 */

const https = require('https');

const CLERK_PUBLISHABLE_KEY = 'pk_live_Y2xlcmsucHdydS5hcHAk';

function extractDomainFromKey(publishableKey) {
  console.log('\n=== Step 1: Extract Domain from Clerk Key ===');
  console.log('Publishable Key:', publishableKey);

  const parts = publishableKey.split('_');
  console.log('Key parts:', parts);

  if (parts.length < 3) {
    throw new Error('Invalid CLERK_PUBLISHABLE_KEY format');
  }

  const base64Domain = parts.slice(2).join('_');
  console.log('Base64 domain:', base64Domain);

  const decoded = Buffer.from(base64Domain, 'base64').toString('utf-8');
  console.log('Decoded domain:', decoded);

  const sanitized = decoded.replace(/\$+$/, '');
  console.log('Sanitized domain:', sanitized);

  return sanitized;
}

function fetchJWKS(domain) {
  return new Promise((resolve, reject) => {
    console.log('\n=== Step 2: Fetch JWKS from Clerk ===');
    const jwksUrl = `https://${domain}/.well-known/jwks.json`;
    console.log('JWKS URL:', jwksUrl);

    https.get(jwksUrl, (res) => {
      let data = '';

      res.on('data', (chunk) => {
        data += chunk;
      });

      res.on('end', () => {
        if (res.statusCode === 200) {
          const jwks = JSON.parse(data);
          console.log('✅ JWKS fetched successfully');
          console.log('Number of keys:', jwks.keys.length);
          console.log('Key IDs:', jwks.keys.map(k => k.kid));
          resolve(jwks);
        } else {
          reject(new Error(`JWKS fetch failed with status ${res.statusCode}`));
        }
      });
    }).on('error', reject);
  });
}

function decodeJWT(token) {
  console.log('\n=== Step 3: Decode JWT (without verification) ===');
  console.log('Token length:', token.length);
  console.log('Token preview:', token.substring(0, 50) + '...');

  const parts = token.split('.');
  if (parts.length !== 3) {
    throw new Error('Invalid JWT format - should have 3 parts separated by dots');
  }

  try {
    const header = JSON.parse(Buffer.from(parts[0], 'base64url').toString());
    const payload = JSON.parse(Buffer.from(parts[1], 'base64url').toString());

    console.log('\n--- JWT Header ---');
    console.log(JSON.stringify(header, null, 2));

    console.log('\n--- JWT Payload ---');
    console.log(JSON.stringify(payload, null, 2));

    // Check expiration
    if (payload.exp) {
      const expiresAt = new Date(payload.exp * 1000);
      const now = new Date();
      const isExpired = now > expiresAt;

      console.log('\n--- Token Expiration ---');
      console.log('Expires at:', expiresAt.toISOString());
      console.log('Current time:', now.toISOString());
      console.log('Is expired:', isExpired ? '❌ YES' : '✅ NO');

      if (isExpired) {
        const expiredAgo = Math.floor((now - expiresAt) / 1000);
        console.log(`⚠️  Token expired ${expiredAgo} seconds ago`);
      }
    }

    // Check issued at
    if (payload.iat) {
      const issuedAt = new Date(payload.iat * 1000);
      console.log('Issued at:', issuedAt.toISOString());
    }

    // Check user ID
    if (payload.sub) {
      console.log('User ID (sub):', payload.sub);
    }

    return { header, payload };
  } catch (error) {
    throw new Error(`Failed to decode JWT: ${error.message}`);
  }
}

async function main() {
  try {
    const token = process.argv[2];

    if (!token) {
      console.log('❌ No JWT token provided');
      console.log('\nUsage: node test-jwt-validation.js <jwt-token>');
      console.log('\nTo get a JWT token:');
      console.log('1. Open https://pulse2.pwru.app in your browser');
      console.log('2. Open browser console (F12)');
      console.log('3. Run: await window.Clerk.session.getToken()');
      console.log('4. Copy the token and pass it to this script');
      process.exit(1);
    }

    console.log('='.repeat(60));
    console.log('JWT VALIDATION DIAGNOSTIC TEST');
    console.log('='.repeat(60));

    // Step 1: Extract domain
    const domain = extractDomainFromKey(CLERK_PUBLISHABLE_KEY);

    // Step 2: Fetch JWKS
    const jwks = await fetchJWKS(domain);

    // Step 3: Decode JWT
    const { header, payload } = decodeJWT(token);

    // Step 4: Check if key ID matches
    console.log('\n=== Step 4: Verify Key ID Match ===');
    const tokenKid = header.kid;
    const jwksKids = jwks.keys.map(k => k.kid);
    const keyMatch = jwksKids.includes(tokenKid);

    console.log('Token Key ID:', tokenKid);
    console.log('Available Key IDs:', jwksKids.join(', '));
    console.log('Key ID match:', keyMatch ? '✅ YES' : '❌ NO');

    if (!keyMatch) {
      console.log('\n⚠️  ERROR: Token was signed with a key not in the JWKS!');
      console.log('This means the token was generated with a different Clerk application.');
      console.log('\nPossible causes:');
      console.log('1. Frontend is using a different NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY than backend');
      console.log('2. Token is from a different Clerk environment (test vs live)');
      console.log('3. Clerk keys have been rotated but backend not updated');
    }

    console.log('\n' + '='.repeat(60));
    console.log('SUMMARY');
    console.log('='.repeat(60));
    console.log('Domain extraction:', '✅');
    console.log('JWKS fetch:', '✅');
    console.log('JWT decode:', '✅');
    console.log('Key ID match:', keyMatch ? '✅' : '❌');
    console.log('Token expired:', payload.exp && (Date.now() / 1000) > payload.exp ? '❌' : '✅');

    console.log('\n💡 Next Steps:');
    if (!keyMatch) {
      console.log('   - Check Vercel NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY matches:', CLERK_PUBLISHABLE_KEY);
      console.log('   - Verify you\'re using the same Clerk environment (live vs test)');
    } else if (payload.exp && (Date.now() / 1000) > payload.exp) {
      console.log('   - Token is expired - sign out and sign back in to get a fresh token');
    } else {
      console.log('   - JWT structure looks valid!');
      console.log('   - Issue may be in signature verification or claims validation');
      console.log('   - Check Supabase function logs for detailed error');
    }

  } catch (error) {
    console.error('\n❌ ERROR:', error.message);
    console.error('\nStack trace:', error.stack);
    process.exit(1);
  }
}

main();
