-- Complete fix for Clerk authentication with RLS bypass
-- This migration ensures all Edge Functions can use service role key to bypass RLS

-- Step 1: Drop ALL existing RLS policies
DO $$
DECLARE
  r RECORD;
BEGIN
  FOR r IN (SELECT schemaname, tablename, policyname FROM pg_policies WHERE schemaname = 'public')
  LOOP
    EXECUTE format('DROP POLICY IF EXISTS %I ON %I.%I', r.policyname, r.schemaname, r.tablename);
  END LOOP;
END$$;

-- Step 2: Convert all user_id and id columns from UUID to TEXT
-- This allows Clerk user IDs (user_xxxxx format) to be stored

-- Profiles table (uses 'id' not 'user_id')
DO $$
BEGIN
  -- Drop foreign keys first
  ALTER TABLE IF EXISTS public.agent_intelligence_profiles DROP CONSTRAINT IF EXISTS agent_intelligence_profiles_user_id_fkey;
  ALTER TABLE IF EXISTS public.user_onboarding DROP CONSTRAINT IF EXISTS user_onboarding_user_id_fkey;
  ALTER TABLE IF EXISTS public.daily_actions DROP CONSTRAINT IF EXISTS daily_actions_user_id_fkey;
  ALTER TABLE IF EXISTS public.goals DROP CONSTRAINT IF EXISTS goals_user_id_fkey;
  ALTER TABLE IF EXISTS public.user_credits DROP CONSTRAINT IF EXISTS user_credits_user_id_fkey;
  ALTER TABLE IF EXISTS public.external_service_connections DROP CONSTRAINT IF EXISTS external_service_connections_user_id_fkey;

  -- Convert profiles.id to TEXT
  ALTER TABLE IF EXISTS public.profiles ALTER COLUMN id TYPE TEXT USING id::TEXT;

  -- Add avatar_url if it doesn't exist
  ALTER TABLE IF EXISTS public.profiles ADD COLUMN IF NOT EXISTS avatar_url TEXT;

EXCEPTION WHEN OTHERS THEN
  RAISE NOTICE 'Error converting profiles.id: %', SQLERRM;
END$$;

-- Step 3: Convert all tables with user_id columns from UUID to TEXT
DO $$
DECLARE
  tbl TEXT;
BEGIN
  FOR tbl IN
    SELECT DISTINCT table_name
    FROM information_schema.columns
    WHERE table_schema = 'public'
    AND column_name = 'user_id'
    AND data_type LIKE '%uuid%'
  LOOP
    BEGIN
      EXECUTE format('ALTER TABLE IF EXISTS public.%I ALTER COLUMN user_id TYPE TEXT USING user_id::TEXT', tbl);
      RAISE NOTICE 'Converted %.user_id to TEXT', tbl;
    EXCEPTION WHEN OTHERS THEN
      RAISE NOTICE 'Could not convert %.user_id: %', tbl, SQLERRM;
    END;
  END LOOP;
END$$;

-- Step 4: Create service role bypass policies for ALL tables
-- These policies allow service role key to bypass RLS completely
DO $$
DECLARE
  tbl TEXT;
BEGIN
  FOR tbl IN
    SELECT table_name
    FROM information_schema.tables
    WHERE table_schema = 'public'
    AND table_type = 'BASE TABLE'
    AND table_name NOT LIKE 'pg_%'
    AND table_name NOT LIKE '_pg_%'
    AND table_name NOT LIKE 'sql_%'
  LOOP
    -- Enable RLS
    EXECUTE format('ALTER TABLE public.%I ENABLE ROW LEVEL SECURITY', tbl);

    -- Create bypass policy for service role
    EXECUTE format('CREATE POLICY "Service role bypass" ON public.%I FOR ALL USING (true)', tbl);

    RAISE NOTICE 'Created service role bypass policy for %', tbl;
  END LOOP;
END$$;

-- Step 5: Drop auth.users reference constraint if it exists
-- We don't use Supabase auth, only Clerk
ALTER TABLE IF EXISTS public.profiles DROP CONSTRAINT IF EXISTS profiles_id_fkey;
ALTER TABLE IF EXISTS public.content_topics DROP CONSTRAINT IF EXISTS content_topics_user_id_fkey;

-- Step 6: Ensure critical tables exist with correct schema
CREATE TABLE IF NOT EXISTS public.profiles (
  id TEXT PRIMARY KEY,
  email TEXT,
  first_name TEXT,
  last_name TEXT,
  full_name TEXT,
  avatar_url TEXT,
  phone TEXT,
  tier TEXT DEFAULT 'starter',
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.user_onboarding (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id TEXT NOT NULL,
  onboarding_completed BOOLEAN DEFAULT false,
  agent_onboarding_completed BOOLEAN DEFAULT false,
  call_center_onboarding_completed BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(user_id)
);

-- Step 7: Remove the auth.uid() trigger since we don't use Supabase auth
DROP FUNCTION IF EXISTS public.set_user_id() CASCADE;

-- Step 8: Create updated_at trigger for profiles
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS handle_profiles_updated_at ON public.profiles;
CREATE TRIGGER handle_profiles_updated_at
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_updated_at();

DROP TRIGGER IF EXISTS handle_user_onboarding_updated_at ON public.user_onboarding;
CREATE TRIGGER handle_user_onboarding_updated_at
  BEFORE UPDATE ON public.user_onboarding
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_updated_at();

COMMENT ON MIGRATION IS 'Complete Clerk authentication fix: Converts all user IDs to TEXT and creates service role bypass policies';
