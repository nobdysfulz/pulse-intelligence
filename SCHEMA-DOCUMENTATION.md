# Pulse Intelligence - Database Schema Documentation

Generated: 2025-11-20T20:30:11.214Z

## Overview

This document provides a comprehensive overview of the Pulse Intelligence database schema.

**Database Type:** PostgreSQL (Supabase)
**Schema:** public
**Total Tables:** 52
**Total Migrations:** 22

## Database Statistics

- **Tables:** 56 CREATE TABLE statements
- **Functions:** 12 database functions
- **Indexes:** 14 indexes for performance
- **RLS Policies:** 161 Row Level Security policies

## Table Categories

### 👤 User Management
- `profiles` - User profiles (Clerk authentication with TEXT IDs)
- `user_onboarding` - Onboarding progress tracking
- `user_preferences` - User settings and preferences
- `user_credits` - Credit/token management system
- `user_roles` - Role-based access control (RBAC)
- `user_agent_subscriptions` - Agent subscription tracking
- `user_guidelines` - User-defined guidelines and rules

### 🤖 AI Agent System
- `agent_config` - AI agent configurations and settings
- `agent_intelligence_profiles` - Agent intelligence survey responses
- `agent_voices` - Voice settings for text-to-speech
- `ai_agent_conversations` - Conversation history and messages
- `ai_actions_log` - AI action execution logs
- `ai_tool_usage` - Tool usage analytics
- `ai_prompt_configs` - Prompt templates and configurations

### 📊 Intelligence Engines
- `pulse_scores` - Pulse intelligence scores
- `moro_engine_snapshots` - MORO engine calculations
- `gane_engine_snapshots` - GANE engine calculations
- `pulse_engine_snapshots` - Pulse engine snapshots
- `graph_context_cache` - Cached graph context data
- `market_intelligence` - Market data and insights

### 🎯 Goals & Actions
- `goals` - User goals and targets
- `daily_actions` - Daily action item tracking
- `transactions` - Real estate transaction records

### 📞 Communication
- `call_logs` - Phone call logs with recordings
- `email_campaigns` - Email campaign management
- `email_templates` - Reusable email templates

### 🎓 Training & Role Play
- `role_play_scenarios` - Role play training scenarios
- `role_play_session_logs` - Session activity logs
- `role_play_analysis_reports` - AI analysis of role play sessions
- `role_play_user_progress` - User progress tracking

### 🔗 Integrations
- `external_service_connections` - OAuth connections (Google, Microsoft, Zoom, LinkedIn, Meta)
- `crm_connections` - CRM integration data (Lofty, FollowUpBoss, SkySlope)

### 📝 Content Management
- `content_topics` - Content categorization
- `content_packs` - Content bundles
- `featured_content_packs` - Featured content listings
- `generated_content` - AI-generated content library
- `client_personas` - Client personas for training
- `objection_scripts` - Sales objection response scripts

### 🎨 Branding & Templates
- `brand_color_palettes` - Custom branding colors
- `campaign_templates` - Campaign template definitions
- `task_templates` - Reusable task templates

### ⚙️ System Configuration
- `business_plans` - Business plan tracking
- `market_config` - Market configuration settings
- `feature_flags` - Feature toggle system
- `legal_documents` - Legal document storage

### 💳 Billing & Credits
- `credit_transactions` - Credit transaction history
- `referrals` - Referral program tracking

## Complete Table List

1. `__InternalSupabase`
2. `admin_set_user_role`
3. `agent_config`
4. `agent_intelligence_profiles`
5. `agent_voices`
6. `ai_actions_log`
7. `ai_agent_conversations`
8. `ai_prompt_configs`
9. `ai_tool_usage`
10. `brand_color_palettes`
11. `business_plans`
12. `call_logs`
13. `campaign_templates`
14. `client_personas`
15. `content_packs`
16. `content_topics`
17. `credit_transactions`
18. `crm_connections`
19. `daily_actions`
20. `email_campaigns`
21. `email_templates`
22. `external_service_connections`
23. `feature_flags`
24. `featured_content_packs`
25. `gane_engine_snapshots`
26. `generated_content`
27. `goals`
28. `graph_context_cache`
29. `has_role`
30. `legal_documents`
31. `market_config`
32. `market_intelligence`
33. `moro_engine_snapshots`
34. `objection_scripts`
35. `profiles`
36. `public`
37. `pulse_engine_snapshots`
38. `pulse_scores`
39. `referrals`
40. `role_play_analysis_reports`
41. `role_play_scenarios`
42. `role_play_session_logs`
43. `role_play_user_progress`
44. `task_templates`
45. `transactions`
46. `user_agent_subscriptions`
47. `user_credits`
48. `user_guidelines`
49. `user_knowledge`
50. `user_onboarding`
51. `user_preferences`
52. `user_roles`

## Key Features

### Authentication
- **Clerk Integration**: Uses Clerk for authentication instead of Supabase Auth
- **User IDs**: TEXT format (e.g., `user_xxxxx`) instead of UUID
- **RLS Policies**: 161 Row Level Security policies for fine-grained access control
- **Service Role Bypass**: Edge Functions use service role key to bypass RLS

### Database Functions
The schema includes 12 custom PostgreSQL functions for:
- Data validation and triggers
- Computed columns and aggregations
- Business logic enforcement
- RLS helper functions

### Indexes
14 strategically placed indexes for optimal query performance on:
- Foreign key columns
- Frequently queried fields
- Compound indexes for complex queries

### Edge Functions
The application uses 101 Supabase Edge Functions for:
- AI agent chat interfaces
- Intelligence engine computations
- OAuth authentication flows
- Tool integrations (Google, Microsoft, Meta, LinkedIn, Zoom)
- CRM operations (Lofty, FollowUpBoss, SkySlope)
- Webhook handlers (Clerk, ElevenLabs)

## Schema Files

1. **database-schema-complete.sql** - Complete SQL schema with all migrations
2. **SCHEMA-DOCUMENTATION.md** - This documentation file
3. **src/integrations/supabase/types.ts** - TypeScript type definitions

## Migration History

The schema has evolved through 22 migrations:
- Initial schema setup (Oct 28, 2025)
- ElevenLabs call support (Nov 5, 2025)
- End-to-end features (Nov 6, 2025)
- RLS permission updates (Nov 7, 2025)
- Clerk authentication fixes (Nov 7-8, 2025)

## Notes

- This is a **structure-only export** - no actual data records are included
- All timestamps use UTC timezone
- JSON/JSONB columns are used extensively for flexible data structures
- Most tables include `created_at` and `updated_at` timestamp columns
- Foreign key relationships are enforced at the database level

## Usage

To view the complete SQL schema:
```bash
cat database-schema-complete.sql
```

To search for specific table definitions:
```bash
grep -A 20 "CREATE TABLE table_name" database-schema-complete.sql
```

## Support

For questions about the schema or database structure, refer to:
- The TypeScript types: `src/integrations/supabase/types.ts`
- Migration files: `supabase/migrations/`
- Supabase project: https://jeukrohcgbnyquzrqvqr.supabase.co
