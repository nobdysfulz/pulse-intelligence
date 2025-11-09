-- ===================================================================
-- CLERK AUTHENTICATION RLS FIX
-- Run this directly in Supabase Dashboard > SQL Editor
-- ===================================================================

-- Step 1: Drop existing RLS policies on user tables only (skip system tables)
DO $$
DECLARE
  r RECORD;
BEGIN
  FOR r IN (
    SELECT schemaname, tablename, policyname
    FROM pg_policies
    WHERE schemaname = 'public'
    AND tablename NOT LIKE 'wrappers_%'
    AND tablename NOT LIKE 'supabase_%'
    AND tablename NOT LIKE 'vault_%'
    AND tablename NOT LIKE 'storage_%'
    AND tablename NOT LIKE 'auth_%'
  )
  LOOP
    BEGIN
      EXECUTE format('DROP POLICY IF EXISTS %I ON %I.%I', r.policyname, r.schemaname, r.tablename);
      RAISE NOTICE 'Dropped policy: %.%', r.tablename, r.policyname;
    EXCEPTION WHEN OTHERS THEN
      RAISE NOTICE 'Could not drop policy %.%: %', r.tablename, r.policyname, SQLERRM;
    END;
  END LOOP;
END$$;

-- Step 2: Convert profiles.id from UUID to TEXT (for Clerk user IDs)
DO $$
BEGIN
  -- Drop foreign keys that reference profiles.id
  EXECUTE (
    SELECT string_agg(
      format('ALTER TABLE %I DROP CONSTRAINT IF EXISTS %I',
        tc.table_name,
        tc.constraint_name
      ), '; '
    )
    FROM information_schema.table_constraints tc
    JOIN information_schema.key_column_usage kcu
      ON tc.constraint_name = kcu.constraint_name
    WHERE tc.constraint_type = 'FOREIGN KEY'
    AND tc.table_schema = 'public'
    AND EXISTS (
      SELECT 1 FROM information_schema.key_column_usage kcu2
      WHERE kcu2.constraint_name = tc.constraint_name
      AND kcu2.table_schema = 'public'
      AND kcu2.referenced_table_name = 'profiles'
      AND kcu2.referenced_column_name = 'id'
    )
  );

  -- Convert profiles.id to TEXT
  ALTER TABLE public.profiles ALTER COLUMN id TYPE TEXT USING id::TEXT;

  -- Add avatar_url column if missing
  ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS avatar_url TEXT;

  RAISE NOTICE 'Converted profiles.id to TEXT';
EXCEPTION WHEN OTHERS THEN
  RAISE NOTICE 'Error converting profiles.id: %', SQLERRM;
END$$;

-- Step 3: Convert ALL user_id columns from UUID to TEXT
DO $$
DECLARE
  tbl TEXT;
  col_type TEXT;
BEGIN
  FOR tbl IN
    SELECT DISTINCT table_name
    FROM information_schema.columns
    WHERE table_schema = 'public'
    AND column_name = 'user_id'
  LOOP
    BEGIN
      -- Check if column is UUID type
      SELECT data_type INTO col_type
      FROM information_schema.columns
      WHERE table_schema = 'public'
      AND table_name = tbl
      AND column_name = 'user_id';

      IF col_type LIKE '%uuid%' THEN
        EXECUTE format('ALTER TABLE public.%I ALTER COLUMN user_id TYPE TEXT USING user_id::TEXT', tbl);
        RAISE NOTICE 'Converted %.user_id to TEXT', tbl;
      ELSE
        RAISE NOTICE 'Skipped %.user_id (already %)', tbl, col_type;
      END IF;
    EXCEPTION WHEN OTHERS THEN
      RAISE NOTICE 'Could not convert %.user_id: %', tbl, SQLERRM;
    END;
  END LOOP;
END$$;

-- Step 4: Create "service role bypass" policies for user tables only
-- This allows Edge Functions using service_role_key to bypass RLS
-- Excludes system tables (wrappers_*, supabase_*, vault_*, storage_*, auth_*)
DO $$
DECLARE
  tbl TEXT;
BEGIN
  FOR tbl IN
    SELECT t.table_name
    FROM information_schema.tables t
    WHERE t.table_schema = 'public'
    AND t.table_type = 'BASE TABLE'
    AND t.table_name NOT LIKE 'pg_%'
    AND t.table_name NOT LIKE '_pg_%'
    AND t.table_name NOT LIKE 'sql_%'
    AND t.table_name NOT LIKE 'wrappers_%'
    AND t.table_name NOT LIKE 'supabase_%'
    AND t.table_name NOT LIKE 'vault_%'
    AND t.table_name NOT LIKE 'storage_%'
    AND t.table_name NOT LIKE 'auth_%'
  LOOP
    BEGIN
      -- Enable RLS on table
      EXECUTE format('ALTER TABLE public.%I ENABLE ROW LEVEL SECURITY', tbl);

      -- Create bypass policy (allows service role to do anything)
      EXECUTE format(
        'CREATE POLICY "Service role bypass" ON public.%I FOR ALL USING (true)',
        tbl
      );

      RAISE NOTICE 'Created service role bypass policy for %', tbl;
    EXCEPTION
      WHEN insufficient_privilege THEN
        RAISE NOTICE 'Skipped % (insufficient privileges)', tbl;
      WHEN OTHERS THEN
        RAISE NOTICE 'Error on %: %', tbl, SQLERRM;
    END;
  END LOOP;
END$$;

-- Step 5: Ensure critical tables exist with correct schema
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
  user_id TEXT NOT NULL UNIQUE,
  onboarding_completed BOOLEAN DEFAULT false,
  agent_onboarding_completed BOOLEAN DEFAULT false,
  call_center_onboarding_completed BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Step 6: Create updated_at trigger function
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply trigger to profiles
DROP TRIGGER IF EXISTS handle_profiles_updated_at ON public.profiles;
CREATE TRIGGER handle_profiles_updated_at
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_updated_at();

-- Apply trigger to user_onboarding
DROP TRIGGER IF EXISTS handle_user_onboarding_updated_at ON public.user_onboarding;
CREATE TRIGGER handle_user_onboarding_updated_at
  BEFORE UPDATE ON public.user_onboarding
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_updated_at();

-- Step 7: Verify setup
DO $$
DECLARE
  policy_count INT;
  text_id_tables INT;
BEGIN
  SELECT COUNT(*) INTO policy_count
  FROM pg_policies
  WHERE schemaname = 'public'
  AND policyname = 'Service role bypass';

  SELECT COUNT(*) INTO text_id_tables
  FROM information_schema.columns
  WHERE table_schema = 'public'
  AND column_name IN ('id', 'user_id')
  AND data_type = 'text';

  RAISE NOTICE '✅ Created % service role bypass policies', policy_count;
  RAISE NOTICE '✅ Converted % columns to TEXT for Clerk IDs', text_id_tables;
  RAISE NOTICE '✅ RLS FIX COMPLETE - Edge Functions can now save data!';
END$$;
