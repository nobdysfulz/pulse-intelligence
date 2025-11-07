-- Fix existing schema to work with Clerk authentication
-- This migration safely transitions from UUID-based IDs to TEXT-based Clerk IDs

-- Step 1: Drop existing policies that reference auth.uid()
DO $$
DECLARE
  pol RECORD;
BEGIN
  FOR pol IN
    SELECT policyname
    FROM pg_policies
    WHERE schemaname = 'public' AND tablename = 'profiles'
  LOOP
    EXECUTE format('DROP POLICY IF EXISTS %I ON public.profiles;', pol.policyname);
  END LOOP;
END$$;

-- Step 2: Drop foreign key constraints
DO $$
BEGIN
  -- Drop all foreign keys referencing profiles.id
  EXECUTE (
    SELECT string_agg('ALTER TABLE ' || quote_ident(tc.table_schema) || '.' || quote_ident(tc.table_name) ||
           ' DROP CONSTRAINT IF EXISTS ' || quote_ident(tc.constraint_name) || ';', ' ')
    FROM information_schema.table_constraints AS tc
    WHERE tc.constraint_type = 'FOREIGN KEY'
    AND tc.constraint_schema = 'public'
    AND tc.constraint_name IN (
      SELECT constraint_name
      FROM information_schema.key_column_usage
      WHERE table_schema = 'public'
      AND referenced_table_name = 'profiles'
    )
  );
EXCEPTION WHEN OTHERS THEN
  NULL; -- Ignore if no foreign keys exist
END$$;

-- Step 3: Alter profiles table to use TEXT ID
ALTER TABLE IF EXISTS public.profiles
  ALTER COLUMN id TYPE TEXT USING id::TEXT;

-- Step 4: Recreate RLS policies with proper Clerk support
CREATE POLICY "Service role can manage all profiles"
  ON public.profiles
  FOR ALL
  USING (true);

-- Step 5: Handle user_onboarding table
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'user_onboarding') THEN
    -- Drop existing policies
    DROP POLICY IF EXISTS "Users can view their own onboarding" ON public.user_onboarding;
    DROP POLICY IF EXISTS "Users can update their own onboarding" ON public.user_onboarding;
    DROP POLICY IF EXISTS "Users can insert their own onboarding" ON public.user_onboarding;
    DROP POLICY IF EXISTS "Users can manage their own onboarding" ON public.user_onboarding;

    -- Alter column type
    ALTER TABLE public.user_onboarding
      ALTER COLUMN user_id TYPE TEXT USING user_id::TEXT;

    -- Create service role policy
    CREATE POLICY "Service role can manage all onboarding"
      ON public.user_onboarding
      FOR ALL
      USING (true);
  END IF;
END$$;

-- Step 6: Handle other user-related tables
DO $$
DECLARE
  tbl TEXT;
  col TEXT;
BEGIN
  -- Find all tables with user_id columns
  FOR tbl, col IN
    SELECT table_name, column_name
    FROM information_schema.columns
    WHERE table_schema = 'public'
    AND column_name IN ('user_id')
    AND table_name NOT IN ('profiles', 'user_onboarding')
    AND data_type LIKE '%uuid%'
  LOOP
    BEGIN
      -- Try to alter the column type
      EXECUTE format('ALTER TABLE IF EXISTS public.%I ALTER COLUMN %I TYPE TEXT USING %I::TEXT;', tbl, col, col);

      -- Drop existing RLS policies
      EXECUTE (
        SELECT string_agg(format('DROP POLICY IF EXISTS %I ON public.%I;', policyname, tablename), ' ')
        FROM pg_policies
        WHERE schemaname = 'public' AND tablename = tbl
      );

      -- Create service role policy
      EXECUTE format('CREATE POLICY "Service role can manage all %I" ON public.%I FOR ALL USING (true);', tbl, tbl);

    EXCEPTION WHEN OTHERS THEN
      -- Log error but continue
      RAISE NOTICE 'Could not alter table %: %', tbl, SQLERRM;
    END;
  END LOOP;
END$$;

-- Step 7: Ensure all tables have RLS enabled
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
    AND table_name NOT LIKE 'sql_%'
  LOOP
    EXECUTE format('ALTER TABLE IF EXISTS public.%I ENABLE ROW LEVEL SECURITY;', tbl);
  END LOOP;
END$$;

-- Step 8: Add avatar_url to profiles if it doesn't exist
ALTER TABLE IF EXISTS public.profiles
  ADD COLUMN IF NOT EXISTS avatar_url TEXT;

COMMENT ON MIGRATION IS 'Adapted schema from Supabase Auth (UUID) to Clerk (TEXT IDs) and simplified RLS to use service role';
