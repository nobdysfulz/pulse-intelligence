#!/bin/bash

# Supabase Edge Function Secrets Configuration Script
# Run this after updating the values below

PROJECT_REF="jeukrohcgbnyquzrqvqr"

echo "🔐 Configuring Supabase Edge Function Secrets..."
echo "================================================"

# CRITICAL: Add your actual API keys below before running this script!

# ============================================================================
# AUTHENTICATION & BACKEND
# ============================================================================
echo "Setting authentication secrets..."

# Clerk (Already have from .env.local)
supabase secrets set CLERK_SECRET_KEY="sk_test_5b7emX6KppWvOE9YsUooeXVEuq6LwA8Xnj9LrPKJQY" \
  --project-ref $PROJECT_REF

# ============================================================================
# AI SERVICES
# ============================================================================
echo "Setting AI service secrets..."

# OpenAI - REQUIRED for AI features
# Get from: https://platform.openai.com/api-keys
supabase secrets set OPENAI_API_KEY="<YOUR_OPENAI_API_KEY>" \
  --project-ref $PROJECT_REF

# ElevenLabs - REQUIRED for voice/TTS features
# Get from: https://elevenlabs.io/app/settings/api-keys
supabase secrets set ELEVENLABS_API_KEY="<YOUR_ELEVENLABS_API_KEY>" \
  --project-ref $PROJECT_REF

supabase secrets set ELEVEN_LABS_API_KEY="<YOUR_ELEVENLABS_API_KEY>" \
  --project-ref $PROJECT_REF

supabase secrets set ELEVEN_LABS_DEFAULT_AGENT_ID="<YOUR_DEFAULT_AGENT_ID>" \
  --project-ref $PROJECT_REF

supabase secrets set ELEVEN_LABS_DEFAULT_VOICE_ID="<YOUR_DEFAULT_VOICE_ID>" \
  --project-ref $PROJECT_REF

supabase secrets set ELEVEN_LABS_BUYER_AGENT_ID="<YOUR_BUYER_AGENT_ID>" \
  --project-ref $PROJECT_REF

supabase secrets set ELEVEN_LABS_SELLER_AGENT_ID="<YOUR_SELLER_AGENT_ID>" \
  --project-ref $PROJECT_REF

# ============================================================================
# TWILIO - For phone/SMS features
# ============================================================================
echo "Setting Twilio secrets..."

# Get from: https://console.twilio.com/
supabase secrets set TWILIO_ACCOUNT_SID="<YOUR_TWILIO_ACCOUNT_SID>" \
  --project-ref $PROJECT_REF

supabase secrets set TWILIO_AUTH_TOKEN="<YOUR_TWILIO_AUTH_TOKEN>" \
  --project-ref $PROJECT_REF

# ============================================================================
# EMAIL - Resend for transactional emails
# ============================================================================
echo "Setting email secrets..."

# Get from: https://resend.com/api-keys
supabase secrets set RESEND_API_KEY="<YOUR_RESEND_API_KEY>" \
  --project-ref $PROJECT_REF

supabase secrets set RESEND_FROM_EMAIL="noreply@yourdomain.com" \
  --project-ref $PROJECT_REF

supabase secrets set ADMIN_ERROR_NOTIFICATION_EMAIL="admin@yourdomain.com" \
  --project-ref $PROJECT_REF

# ============================================================================
# OAUTH PROVIDERS - For social integrations
# ============================================================================
echo "Setting OAuth provider secrets..."

# Google Workspace
# Get from: https://console.cloud.google.com/apis/credentials
supabase secrets set GOOGLE_WORKSPACE_CLIENT_ID="<YOUR_GOOGLE_CLIENT_ID>" \
  --project-ref $PROJECT_REF

supabase secrets set GOOGLE_WORKSPACE_CLIENT_SECRET="<YOUR_GOOGLE_CLIENT_SECRET>" \
  --project-ref $PROJECT_REF

# Microsoft
# Get from: https://portal.azure.com/#view/Microsoft_AAD_RegisteredApps
supabase secrets set MICROSOFT_CLIENT_ID="<YOUR_MICROSOFT_CLIENT_ID>" \
  --project-ref $PROJECT_REF

supabase secrets set MICROSOFT_CLIENT_SECRET="<YOUR_MICROSOFT_CLIENT_SECRET>" \
  --project-ref $PROJECT_REF

# LinkedIn
# Get from: https://www.linkedin.com/developers/apps
supabase secrets set LINKEDIN_CLIENT_ID="<YOUR_LINKEDIN_CLIENT_ID>" \
  --project-ref $PROJECT_REF

supabase secrets set LINKEDIN_CLIENT_SECRET="<YOUR_LINKEDIN_CLIENT_SECRET>" \
  --project-ref $PROJECT_REF

# Meta (Facebook/Instagram)
# Get from: https://developers.facebook.com/apps
supabase secrets set META_APP_ID="<YOUR_META_APP_ID>" \
  --project-ref $PROJECT_REF

supabase secrets set META_APP_SECRET="<YOUR_META_APP_SECRET>" \
  --project-ref $PROJECT_REF

# Zoom
# Get from: https://marketplace.zoom.us/develop/apps
supabase secrets set ZOOM_CLIENT_ID="<YOUR_ZOOM_CLIENT_ID>" \
  --project-ref $PROJECT_REF

supabase secrets set ZOOM_CLIENT_SECRET="<YOUR_ZOOM_CLIENT_SECRET>" \
  --project-ref $PROJECT_REF

# ============================================================================
# WEBHOOK SECRETS - For secure webhook validation
# ============================================================================
echo "Setting webhook secrets..."

supabase secrets set GOHIGHLEVEL_WEBHOOK_SECRET="<YOUR_GHL_WEBHOOK_SECRET>" \
  --project-ref $PROJECT_REF

supabase secrets set SHOPIFY_WEBHOOK_SECRET="<YOUR_SHOPIFY_WEBHOOK_SECRET>" \
  --project-ref $PROJECT_REF

# ============================================================================
# EXTERNAL SERVICES
# ============================================================================
echo "Setting external service secrets..."

# Market data API
supabase secrets set RAPIDAPI_MARKET_METRICS_API_KEY="<YOUR_RAPIDAPI_KEY>" \
  --project-ref $PROJECT_REF

# Lovable API (if used)
supabase secrets set LOVABLE_API_KEY="<YOUR_LOVABLE_API_KEY>" \
  --project-ref $PROJECT_REF

# External backend (if you have a separate backend service)
supabase secrets set EXTERNAL_BACKEND_URL="<YOUR_EXTERNAL_BACKEND_URL>" \
  --project-ref $PROJECT_REF

supabase secrets set EXTERNAL_BACKEND_SERVICE_ROLE_KEY="<YOUR_EXTERNAL_BACKEND_KEY>" \
  --project-ref $PROJECT_REF

# ============================================================================
echo ""
echo "✅ Secrets configuration complete!"
echo ""
echo "To verify secrets were set, run:"
echo "  supabase secrets list --project-ref $PROJECT_REF"
echo ""
echo "⚠️  IMPORTANT: Make sure you replaced all <YOUR_*> placeholders with actual values!"
