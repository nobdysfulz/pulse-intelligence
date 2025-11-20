-- =====================================================================
-- PULSE INTELLIGENCE - DATABASE SCHEMA EXPORT
-- =====================================================================
-- Generated: 2025-11-20 20:28:52 UTC
-- Database: PostgreSQL (Supabase)
-- Schema: public
-- Total Migrations: 22
--
-- This file contains the complete database schema structure including:
-- - All table definitions
-- - Primary keys, foreign keys, and constraints
-- - Indexes
-- - Row Level Security (RLS) policies
-- - Functions and triggers
-- - Extensions
--
-- Note: This is a READ-ONLY export for documentation purposes.
-- No actual data records are included.
-- =====================================================================



-- =====================================================================
-- MIGRATION: 20251028204657_265932fc-bb5a-4b6f-96d7-499ec46eefe9.sql
-- =====================================================================

-- Create profiles table for user information
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT,
  full_name TEXT,
  phone TEXT,
  brokerage_name TEXT,
  license_number TEXT,
  years_experience INTEGER,
  specialization TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Enable RLS on profiles
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Profiles policies
CREATE POLICY "Users can view their own profile"
  ON public.profiles FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile"
  ON public.profiles FOR UPDATE
  USING (auth.uid() = id);

CREATE POLICY "Users can insert their own profile"
  ON public.profiles FOR INSERT
  WITH CHECK (auth.uid() = id);

-- Create function to handle new user signups
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, full_name)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', '')
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- Trigger to create profile on signup
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

-- Create user_roles table for role-based access
CREATE TYPE public.app_role AS ENUM ('admin', 'user');

CREATE TABLE IF NOT EXISTS public.user_roles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  role app_role NOT NULL DEFAULT 'user',
  created_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(user_id, role)
);

ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;

-- Function to check user role (security definer to avoid RLS recursion)
CREATE OR REPLACE FUNCTION public.has_role(_user_id UUID, _role app_role)
RETURNS BOOLEAN
LANGUAGE SQL
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.user_roles
    WHERE user_id = _user_id AND role = _role
  )
$$;

-- User roles policies
CREATE POLICY "Users can view their own roles"
  ON public.user_roles FOR SELECT
  USING (auth.uid() = user_id);

-- Create guidelines table for AI agent preferences
CREATE TABLE IF NOT EXISTS public.user_guidelines (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  agent_type TEXT NOT NULL,
  guideline_category TEXT NOT NULL,
  guideline_text TEXT NOT NULL,
  guideline_type TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE public.user_guidelines ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage their own guidelines"
  ON public.user_guidelines FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Create onboarding table
CREATE TABLE IF NOT EXISTS public.user_onboarding (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL UNIQUE,
  completed_steps TEXT[] DEFAULT '{}',
  agent_onboarding_completed BOOLEAN DEFAULT false,
  onboarding_completion_date TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE public.user_onboarding ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage their own onboarding"
  ON public.user_onboarding FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Create updated_at trigger function
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Add updated_at triggers
CREATE TRIGGER update_profiles_updated_at
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_user_guidelines_updated_at
  BEFORE UPDATE ON public.user_guidelines
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_user_onboarding_updated_at
  BEFORE UPDATE ON public.user_onboarding
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

-- =====================================================================
-- MIGRATION: 20251031191704_f5f4ac12-3b64-4efa-8509-c38d098cc082.sql
-- =====================================================================

-- ============================================
-- PHASE 1: ADD MISSING FOUNDATION TABLES
-- Only tables that don't exist yet
-- ============================================

-- ============================================
-- MARKET CONFIGURATION
-- ============================================

CREATE TABLE IF NOT EXISTS public.market_config (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  market_name TEXT NOT NULL,
  state TEXT,
  city TEXT,
  average_price DECIMAL(12,2),
  median_dom INTEGER,
  inventory_level TEXT,
  market_trend TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(user_id)
);

ALTER TABLE public.market_config ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users manage own market config" ON public.market_config;
CREATE POLICY "Users manage own market config"
  ON public.market_config FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- ============================================
-- USER PREFERENCES
-- ============================================

CREATE TABLE IF NOT EXISTS public.user_preferences (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  brand_primary_color TEXT DEFAULT '#7C3AED',
  brand_secondary_color TEXT DEFAULT '#F1F5F9',
  brand_accent_color TEXT DEFAULT '#3B82F6',
  communication_style TEXT DEFAULT 'professional',
  content_themes TEXT[] DEFAULT '{}',
  email_categories TEXT[] DEFAULT '{}',
  auto_response_enabled BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(user_id)
);

ALTER TABLE public.user_preferences ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users manage own preferences" ON public.user_preferences;
CREATE POLICY "Users manage own preferences"
  ON public.user_preferences FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- ============================================
-- GOALS & BUSINESS PLANS
-- ============================================

CREATE TABLE IF NOT EXISTS public.goals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  goal_type TEXT NOT NULL,
  target_value DECIMAL(12,2),
  current_value DECIMAL(12,2) DEFAULT 0,
  unit TEXT,
  timeframe TEXT,
  deadline DATE,
  confidence_score INTEGER DEFAULT 50,
  status TEXT DEFAULT 'active',
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE public.goals ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users manage own goals" ON public.goals;
CREATE POLICY "Users manage own goals"
  ON public.goals FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE TABLE IF NOT EXISTS public.business_plans (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  annual_gci_goal DECIMAL(12,2),
  transactions_needed INTEGER,
  average_commission DECIMAL(12,2),
  lead_sources JSONB DEFAULT '{}',
  conversion_rates JSONB DEFAULT '{}',
  monthly_breakdown JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(user_id)
);

ALTER TABLE public.business_plans ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users manage own business plan" ON public.business_plans;
CREATE POLICY "Users manage own business plan"
  ON public.business_plans FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- ============================================
-- DAILY ACTIONS & TASKS
-- ============================================

CREATE TABLE IF NOT EXISTS public.daily_actions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  category TEXT NOT NULL,
  priority TEXT DEFAULT 'medium',
  status TEXT DEFAULT 'pending',
  due_date DATE NOT NULL,
  scheduled_time TIME,
  duration_minutes INTEGER,
  completed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE public.daily_actions ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users manage own actions" ON public.daily_actions;
CREATE POLICY "Users manage own actions"
  ON public.daily_actions FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- ============================================
-- PULSE SCORING
-- ============================================

CREATE TABLE IF NOT EXISTS public.pulse_scores (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  date DATE NOT NULL,
  overall_score INTEGER NOT NULL,
  production_score INTEGER,
  pipeline_score INTEGER,
  activities_score INTEGER,
  systems_score INTEGER,
  mindset_score INTEGER,
  metrics JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(user_id, date)
);

ALTER TABLE public.pulse_scores ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users manage own pulse scores" ON public.pulse_scores;
CREATE POLICY "Users manage own pulse scores"
  ON public.pulse_scores FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- ============================================
-- AI AGENT CONFIGURATION
-- ============================================

CREATE TABLE IF NOT EXISTS public.agent_config (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  agent_type TEXT NOT NULL,
  voice_id TEXT,
  voice_name TEXT,
  personality_traits TEXT[] DEFAULT '{}',
  response_style TEXT DEFAULT 'professional',
  enabled BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(user_id, agent_type)
);

ALTER TABLE public.agent_config ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users manage own agent config" ON public.agent_config;
CREATE POLICY "Users manage own agent config"
  ON public.agent_config FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- ============================================
-- ADD TRIGGERS FOR NEW TABLES
-- ============================================

DROP TRIGGER IF EXISTS update_market_config_updated_at ON public.market_config;
CREATE TRIGGER update_market_config_updated_at BEFORE UPDATE ON public.market_config
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_user_preferences_updated_at ON public.user_preferences;
CREATE TRIGGER update_user_preferences_updated_at BEFORE UPDATE ON public.user_preferences
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_goals_updated_at ON public.goals;
CREATE TRIGGER update_goals_updated_at BEFORE UPDATE ON public.goals
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_business_plans_updated_at ON public.business_plans;
CREATE TRIGGER update_business_plans_updated_at BEFORE UPDATE ON public.business_plans
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_daily_actions_updated_at ON public.daily_actions;
CREATE TRIGGER update_daily_actions_updated_at BEFORE UPDATE ON public.daily_actions
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_agent_config_updated_at ON public.agent_config;
CREATE TRIGGER update_agent_config_updated_at BEFORE UPDATE ON public.agent_config
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- UPDATE HANDLE NEW USER TO CREATE NEW RECORDS
-- ============================================

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  -- Create profile
  INSERT INTO public.profiles (id, email, full_name)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', '')
  );
  
  -- Create default user role
  INSERT INTO public.user_roles (user_id, role)
  VALUES (NEW.id, 'user')
  ON CONFLICT (user_id, role) DO NOTHING;
  
  -- Create onboarding record
  INSERT INTO public.user_onboarding (user_id)
  VALUES (NEW.id)
  ON CONFLICT (user_id) DO NOTHING;
  
  -- Create default preferences
  INSERT INTO public.user_preferences (user_id)
  VALUES (NEW.id)
  ON CONFLICT (user_id) DO NOTHING;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- =====================================================================
-- MIGRATION: 20251101162720_3adf9fdf-6a8e-48a2-b509-71e35d8f983f.sql
-- =====================================================================

-- Security Fix: Prevent privilege escalation on user_roles table
-- Add explicit DENY policies for INSERT, UPDATE, DELETE operations
-- Only allow role modifications through SECURITY DEFINER functions

-- Drop existing policies if any (besides SELECT)
DO $$ 
BEGIN
  DROP POLICY IF EXISTS "Prevent user role modifications" ON public.user_roles;
  DROP POLICY IF EXISTS "Prevent unauthorized role inserts" ON public.user_roles;
  DROP POLICY IF EXISTS "Prevent unauthorized role updates" ON public.user_roles;
  DROP POLICY IF EXISTS "Prevent unauthorized role deletes" ON public.user_roles;
END $$;

-- Create explicit DENY policies for all modification operations
CREATE POLICY "Prevent unauthorized role inserts"
ON public.user_roles
FOR INSERT
TO authenticated
WITH CHECK (false);

CREATE POLICY "Prevent unauthorized role updates"
ON public.user_roles
FOR UPDATE
TO authenticated
USING (false)
WITH CHECK (false);

CREATE POLICY "Prevent unauthorized role deletes"
ON public.user_roles
FOR DELETE
TO authenticated
USING (false);

-- Create a SECURITY DEFINER function for admins to manage roles (to be called by service role only)
CREATE OR REPLACE FUNCTION public.admin_set_user_role(
  _target_user_id uuid,
  _role app_role
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  -- This function can only be called by the service role (from backend/edge functions)
  -- Not directly accessible from client code
  
  -- Insert or update the user role
  INSERT INTO public.user_roles (user_id, role)
  VALUES (_target_user_id, _role)
  ON CONFLICT (user_id, role) DO NOTHING;
  
END;
$$;

-- Revoke execute from public, only service role can call this
REVOKE EXECUTE ON FUNCTION public.admin_set_user_role FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION public.admin_set_user_role FROM authenticated;

COMMENT ON FUNCTION public.admin_set_user_role IS 'Admin function to manage user roles. Can only be called by service role from backend.';
COMMENT ON POLICY "Prevent unauthorized role inserts" ON public.user_roles IS 'Prevents client-side privilege escalation by blocking direct inserts';
COMMENT ON POLICY "Prevent unauthorized role updates" ON public.user_roles IS 'Prevents client-side privilege escalation by blocking direct updates';
COMMENT ON POLICY "Prevent unauthorized role deletes" ON public.user_roles IS 'Prevents client-side privilege escalation by blocking direct deletes';

-- =====================================================================
-- MIGRATION: 20251103200726_9dd532ed-efa7-47e5-a003-d9f7403a4c93.sql
-- =====================================================================

-- PULSE GRAPH INTELLIGENCE CORE (PGIC) Database Schema

-- Table for Pulse Engine snapshots (measures execution & consistency)
CREATE TABLE IF NOT EXISTS public.pulse_engine_snapshots (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  score NUMERIC(5,2) NOT NULL CHECK (score >= 0 AND score <= 100),
  metrics JSONB NOT NULL DEFAULT '{}'::jsonb,
  computed_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

CREATE INDEX idx_pulse_snapshots_user_computed ON public.pulse_engine_snapshots(user_id, computed_at DESC);

-- Table for GANE Engine snapshots (measures intelligence & predictability)
CREATE TABLE IF NOT EXISTS public.gane_engine_snapshots (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  score NUMERIC(5,2) NOT NULL CHECK (score >= 0 AND score <= 100),
  metrics JSONB NOT NULL DEFAULT '{}'::jsonb,
  computed_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

CREATE INDEX idx_gane_snapshots_user_computed ON public.gane_engine_snapshots(user_id, computed_at DESC);

-- Table for MORO Engine snapshots (measures market opportunity & resilience)
CREATE TABLE IF NOT EXISTS public.moro_engine_snapshots (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  score NUMERIC(5,2) NOT NULL CHECK (score >= 0 AND score <= 100),
  metrics JSONB NOT NULL DEFAULT '{}'::jsonb,
  computed_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

CREATE INDEX idx_moro_snapshots_user_computed ON public.moro_engine_snapshots(user_id, computed_at DESC);

-- Table for caching built graph context (15min TTL)
CREATE TABLE IF NOT EXISTS public.graph_context_cache (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE,
  context JSONB NOT NULL,
  expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

CREATE INDEX idx_graph_context_user_expires ON public.graph_context_cache(user_id, expires_at);

-- Table for logging AI action executions
CREATE TABLE IF NOT EXISTS public.ai_actions_log (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  action_type TEXT NOT NULL,
  action_data JSONB NOT NULL DEFAULT '{}'::jsonb,
  status TEXT NOT NULL CHECK (status IN ('pending', 'success', 'failed')),
  resource_url TEXT,
  error_message TEXT,
  executed_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

CREATE INDEX idx_ai_actions_user_executed ON public.ai_actions_log(user_id, executed_at DESC);
CREATE INDEX idx_ai_actions_status ON public.ai_actions_log(status, executed_at DESC);

-- Enable RLS on all tables
ALTER TABLE public.pulse_engine_snapshots ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.gane_engine_snapshots ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.moro_engine_snapshots ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.graph_context_cache ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ai_actions_log ENABLE ROW LEVEL SECURITY;

-- RLS Policies for pulse_engine_snapshots
CREATE POLICY "Users can view their own pulse snapshots"
  ON public.pulse_engine_snapshots FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Service role can insert pulse snapshots"
  ON public.pulse_engine_snapshots FOR INSERT
  WITH CHECK (true);

-- RLS Policies for gane_engine_snapshots
CREATE POLICY "Users can view their own gane snapshots"
  ON public.gane_engine_snapshots FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Service role can insert gane snapshots"
  ON public.gane_engine_snapshots FOR INSERT
  WITH CHECK (true);

-- RLS Policies for moro_engine_snapshots
CREATE POLICY "Users can view their own moro snapshots"
  ON public.moro_engine_snapshots FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Service role can insert moro snapshots"
  ON public.moro_engine_snapshots FOR INSERT
  WITH CHECK (true);

-- RLS Policies for graph_context_cache
CREATE POLICY "Users can view their own graph context"
  ON public.graph_context_cache FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Service role can manage graph context"
  ON public.graph_context_cache FOR ALL
  USING (true)
  WITH CHECK (true);

-- RLS Policies for ai_actions_log
CREATE POLICY "Users can view their own action logs"
  ON public.ai_actions_log FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Service role can insert action logs"
  ON public.ai_actions_log FOR INSERT
  WITH CHECK (true);

-- Trigger for updating graph_context_cache.updated_at
CREATE TRIGGER update_graph_context_updated_at
  BEFORE UPDATE ON public.graph_context_cache
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

-- =====================================================================
-- MIGRATION: 20251103204153_21d075a9-da67-4589-b905-a93b1e8af35e.sql
-- =====================================================================

-- Enable realtime for intelligence snapshot tables
ALTER PUBLICATION supabase_realtime ADD TABLE public.pulse_engine_snapshots;
ALTER PUBLICATION supabase_realtime ADD TABLE public.gane_engine_snapshots;
ALTER PUBLICATION supabase_realtime ADD TABLE public.moro_engine_snapshots;
ALTER PUBLICATION supabase_realtime ADD TABLE public.graph_context_cache;

-- =====================================================================
-- MIGRATION: 20251103220558_9e571067-0102-481c-b316-8c7595b973b4.sql
-- =====================================================================

-- Create task_templates table
CREATE TABLE IF NOT EXISTS task_templates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT,
  category TEXT NOT NULL,
  action_type TEXT NOT NULL,
  priority TEXT DEFAULT 'medium',
  trigger_type TEXT NOT NULL,
  trigger_value INTEGER,
  impact_area TEXT,
  display_category TEXT,
  priority_weight INTEGER DEFAULT 3,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create role_play_scenarios table
CREATE TABLE IF NOT EXISTS role_play_scenarios (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  description TEXT,
  category TEXT NOT NULL,
  difficulty_level TEXT NOT NULL,
  initial_context TEXT NOT NULL,
  client_persona TEXT NOT NULL,
  eleven_labs_agent_id TEXT,
  eleven_labs_phone_number_id TEXT,
  eleven_labs_voice_id TEXT,
  first_message_override TEXT,
  avatar_image_url TEXT,
  passing_threshold INTEGER DEFAULT 70,
  learning_objectives TEXT[] DEFAULT '{}',
  average_duration_minutes INTEGER DEFAULT 10,
  success_criteria TEXT[] DEFAULT '{}',
  is_active BOOLEAN DEFAULT true,
  is_popular BOOLEAN DEFAULT false,
  is_premium BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create client_personas table
CREATE TABLE IF NOT EXISTS client_personas (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  persona_key TEXT UNIQUE NOT NULL,
  persona_name TEXT NOT NULL,
  description TEXT,
  personality_traits TEXT[] DEFAULT '{}',
  communication_style TEXT,
  objection_patterns TEXT[] DEFAULT '{}',
  decision_making_style TEXT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create objection_scripts table
CREATE TABLE IF NOT EXISTS objection_scripts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  category TEXT NOT NULL,
  difficulty TEXT NOT NULL,
  situation TEXT NOT NULL,
  response TEXT NOT NULL,
  tips TEXT[] DEFAULT '{}',
  is_free BOOLEAN DEFAULT true,
  is_popular BOOLEAN DEFAULT false,
  is_active BOOLEAN DEFAULT true,
  sort_order INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create campaign_templates table
CREATE TABLE IF NOT EXISTS campaign_templates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  file_name TEXT NOT NULL,
  file_uri TEXT NOT NULL,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS on all tables
ALTER TABLE task_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE role_play_scenarios ENABLE ROW LEVEL SECURITY;
ALTER TABLE client_personas ENABLE ROW LEVEL SECURITY;
ALTER TABLE objection_scripts ENABLE ROW LEVEL SECURITY;
ALTER TABLE campaign_templates ENABLE ROW LEVEL SECURITY;

-- RLS Policies for task_templates
CREATE POLICY "Admins manage task templates"
  ON task_templates FOR ALL
  TO authenticated
  USING (public.has_role(auth.uid(), 'admin'))
  WITH CHECK (public.has_role(auth.uid(), 'admin'));

CREATE POLICY "Users view active task templates"
  ON task_templates FOR SELECT
  TO authenticated
  USING (is_active = true);

-- RLS Policies for role_play_scenarios
CREATE POLICY "Admins manage scenarios"
  ON role_play_scenarios FOR ALL
  TO authenticated
  USING (public.has_role(auth.uid(), 'admin'))
  WITH CHECK (public.has_role(auth.uid(), 'admin'));

CREATE POLICY "Users view active scenarios"
  ON role_play_scenarios FOR SELECT
  TO authenticated
  USING (is_active = true);

-- RLS Policies for client_personas
CREATE POLICY "Admins manage client personas"
  ON client_personas FOR ALL
  TO authenticated
  USING (public.has_role(auth.uid(), 'admin'))
  WITH CHECK (public.has_role(auth.uid(), 'admin'));

CREATE POLICY "Users view active personas"
  ON client_personas FOR SELECT
  TO authenticated
  USING (is_active = true);

-- RLS Policies for objection_scripts
CREATE POLICY "Admins manage objection scripts"
  ON objection_scripts FOR ALL
  TO authenticated
  USING (public.has_role(auth.uid(), 'admin'))
  WITH CHECK (public.has_role(auth.uid(), 'admin'));

CREATE POLICY "Users view active scripts"
  ON objection_scripts FOR SELECT
  TO authenticated
  USING (is_active = true);

-- RLS Policies for campaign_templates
CREATE POLICY "Admins manage campaign templates"
  ON campaign_templates FOR ALL
  TO authenticated
  USING (public.has_role(auth.uid(), 'admin'))
  WITH CHECK (public.has_role(auth.uid(), 'admin'));

CREATE POLICY "Users view active templates"
  ON campaign_templates FOR SELECT
  TO authenticated
  USING (is_active = true);

-- Create triggers for updated_at
CREATE TRIGGER update_task_templates_updated_at
  BEFORE UPDATE ON task_templates
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_role_play_scenarios_updated_at
  BEFORE UPDATE ON role_play_scenarios
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_client_personas_updated_at
  BEFORE UPDATE ON client_personas
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_objection_scripts_updated_at
  BEFORE UPDATE ON objection_scripts
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_campaign_templates_updated_at
  BEFORE UPDATE ON campaign_templates
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =====================================================================
-- MIGRATION: 20251103222022_a0f35b77-422a-47a6-ac76-2aba089de700.sql
-- =====================================================================

-- Market Intelligence Table
CREATE TABLE public.market_intelligence (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  market_name TEXT NOT NULL,
  data_snapshot JSONB DEFAULT '{}'::jsonb,
  insights JSONB DEFAULT '{}'::jsonb,
  refreshed_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

ALTER TABLE public.market_intelligence ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users manage own market intelligence"
  ON public.market_intelligence
  FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Agent Voices Table
CREATE TABLE public.agent_voices (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  agent_type TEXT NOT NULL,
  voice_id TEXT,
  voice_name TEXT,
  voice_settings JSONB DEFAULT '{}'::jsonb,
  is_default BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

ALTER TABLE public.agent_voices ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users manage own agent voices"
  ON public.agent_voices
  FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- User Knowledge Table
CREATE TABLE public.user_knowledge (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  agent_type TEXT NOT NULL,
  knowledge_type TEXT NOT NULL,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  metadata JSONB DEFAULT '{}'::jsonb,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

ALTER TABLE public.user_knowledge ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users manage own knowledge"
  ON public.user_knowledge
  FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- CRM Connections Table
CREATE TABLE public.crm_connections (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  provider TEXT NOT NULL,
  connection_status TEXT DEFAULT 'disconnected',
  credentials JSONB DEFAULT '{}'::jsonb,
  sync_settings JSONB DEFAULT '{}'::jsonb,
  last_sync_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

ALTER TABLE public.crm_connections ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users manage own CRM connections"
  ON public.crm_connections
  FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Content Packs Table
CREATE TABLE public.content_packs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  pack_name TEXT NOT NULL,
  pack_key TEXT NOT NULL UNIQUE,
  description TEXT,
  category TEXT NOT NULL,
  is_active BOOLEAN DEFAULT true,
  is_premium BOOLEAN DEFAULT false,
  content_items JSONB DEFAULT '[]'::jsonb,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

ALTER TABLE public.content_packs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admins manage content packs"
  ON public.content_packs
  FOR ALL
  USING (has_role(auth.uid(), 'admin'::app_role))
  WITH CHECK (has_role(auth.uid(), 'admin'::app_role));

CREATE POLICY "Users view active content packs"
  ON public.content_packs
  FOR SELECT
  USING (is_active = true);

-- Content Topics Table
CREATE TABLE public.content_topics (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  topic_name TEXT NOT NULL,
  topic_key TEXT NOT NULL UNIQUE,
  description TEXT,
  category TEXT NOT NULL,
  prompts JSONB DEFAULT '{}'::jsonb,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

ALTER TABLE public.content_topics ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admins manage content topics"
  ON public.content_topics
  FOR ALL
  USING (has_role(auth.uid(), 'admin'::app_role))
  WITH CHECK (has_role(auth.uid(), 'admin'::app_role));

CREATE POLICY "Users view active topics"
  ON public.content_topics
  FOR SELECT
  USING (is_active = true);

-- Featured Content Packs Table
CREATE TABLE public.featured_content_packs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT,
  icon TEXT,
  category TEXT NOT NULL,
  content_items JSONB DEFAULT '[]'::jsonb,
  sort_order INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

ALTER TABLE public.featured_content_packs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admins manage featured content packs"
  ON public.featured_content_packs
  FOR ALL
  USING (has_role(auth.uid(), 'admin'::app_role))
  WITH CHECK (has_role(auth.uid(), 'admin'::app_role));

CREATE POLICY "Users view active featured packs"
  ON public.featured_content_packs
  FOR SELECT
  USING (is_active = true);

-- Generated Content Table
CREATE TABLE public.generated_content (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  content_type TEXT NOT NULL,
  title TEXT,
  content TEXT NOT NULL,
  metadata JSONB DEFAULT '{}'::jsonb,
  prompt_used TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

ALTER TABLE public.generated_content ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users manage own generated content"
  ON public.generated_content
  FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- AI Prompt Configs Table
CREATE TABLE public.ai_prompt_configs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  prompt_key TEXT NOT NULL UNIQUE,
  prompt_name TEXT NOT NULL,
  prompt_template TEXT NOT NULL,
  category TEXT NOT NULL,
  variables JSONB DEFAULT '[]'::jsonb,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

ALTER TABLE public.ai_prompt_configs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admins manage AI prompt configs"
  ON public.ai_prompt_configs
  FOR ALL
  USING (has_role(auth.uid(), 'admin'::app_role))
  WITH CHECK (has_role(auth.uid(), 'admin'::app_role));

CREATE POLICY "Users view active prompts"
  ON public.ai_prompt_configs
  FOR SELECT
  USING (is_active = true);

-- Transactions Table
CREATE TABLE public.transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  transaction_type TEXT NOT NULL,
  property_address TEXT,
  client_name TEXT,
  status TEXT DEFAULT 'pending',
  expected_close_date DATE,
  commission_amount NUMERIC,
  notes TEXT,
  metadata JSONB DEFAULT '{}'::jsonb,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

ALTER TABLE public.transactions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users manage own transactions"
  ON public.transactions
  FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- User Credits Table
CREATE TABLE public.user_credits (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE UNIQUE,
  credits_available INTEGER DEFAULT 0,
  credits_used INTEGER DEFAULT 0,
  last_reset_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

ALTER TABLE public.user_credits ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users view own credits"
  ON public.user_credits
  FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Service role manages credits"
  ON public.user_credits
  FOR ALL
  USING (true)
  WITH CHECK (true);

-- Credit Transactions Table
CREATE TABLE public.credit_transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  transaction_type TEXT NOT NULL,
  amount INTEGER NOT NULL,
  balance_after INTEGER NOT NULL,
  description TEXT,
  metadata JSONB DEFAULT '{}'::jsonb,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

ALTER TABLE public.credit_transactions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users view own credit transactions"
  ON public.credit_transactions
  FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Service role manages credit transactions"
  ON public.credit_transactions
  FOR INSERT
  WITH CHECK (true);

-- Call Logs Table
CREATE TABLE public.call_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  call_type TEXT NOT NULL,
  contact_name TEXT,
  phone_number TEXT,
  duration_seconds INTEGER,
  status TEXT,
  notes TEXT,
  recording_url TEXT,
  metadata JSONB DEFAULT '{}'::jsonb,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

ALTER TABLE public.call_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users manage own call logs"
  ON public.call_logs
  FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Role Play Session Logs Table
CREATE TABLE public.role_play_session_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  scenario_id UUID REFERENCES public.role_play_scenarios(id) ON DELETE SET NULL,
  session_duration_seconds INTEGER,
  transcript JSONB DEFAULT '[]'::jsonb,
  status TEXT DEFAULT 'completed',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

ALTER TABLE public.role_play_session_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users manage own session logs"
  ON public.role_play_session_logs
  FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Role Play User Progress Table
CREATE TABLE public.role_play_user_progress (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  scenario_id UUID REFERENCES public.role_play_scenarios(id) ON DELETE CASCADE,
  attempts INTEGER DEFAULT 0,
  best_score INTEGER,
  last_attempt_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  UNIQUE(user_id, scenario_id)
);

ALTER TABLE public.role_play_user_progress ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users manage own progress"
  ON public.role_play_user_progress
  FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Role Play Analysis Reports Table
CREATE TABLE public.role_play_analysis_reports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  session_id UUID REFERENCES public.role_play_session_logs(id) ON DELETE CASCADE,
  overall_score INTEGER,
  strengths JSONB DEFAULT '[]'::jsonb,
  areas_for_improvement JSONB DEFAULT '[]'::jsonb,
  detailed_feedback TEXT,
  metrics JSONB DEFAULT '{}'::jsonb,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

ALTER TABLE public.role_play_analysis_reports ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users view own analysis reports"
  ON public.role_play_analysis_reports
  FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Service role creates reports"
  ON public.role_play_analysis_reports
  FOR INSERT
  WITH CHECK (true);

-- Referrals Table
CREATE TABLE public.referrals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  referrer_user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  referred_email TEXT NOT NULL,
  referred_user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  status TEXT DEFAULT 'pending',
  reward_granted BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

ALTER TABLE public.referrals ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users manage own referrals"
  ON public.referrals
  FOR ALL
  USING (auth.uid() = referrer_user_id)
  WITH CHECK (auth.uid() = referrer_user_id);

-- Brand Color Palettes Table
CREATE TABLE public.brand_color_palettes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  palette_name TEXT NOT NULL,
  primary_color TEXT NOT NULL,
  secondary_color TEXT,
  accent_color TEXT,
  is_active BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

ALTER TABLE public.brand_color_palettes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users manage own brand palettes"
  ON public.brand_color_palettes
  FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- User Agent Subscriptions Table
CREATE TABLE public.user_agent_subscriptions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  agent_type TEXT NOT NULL,
  subscription_tier TEXT DEFAULT 'free',
  is_active BOOLEAN DEFAULT true,
  expires_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  UNIQUE(user_id, agent_type)
);

ALTER TABLE public.user_agent_subscriptions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users manage own subscriptions"
  ON public.user_agent_subscriptions
  FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Legal Documents Table
CREATE TABLE public.legal_documents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  document_type TEXT NOT NULL,
  document_key TEXT NOT NULL UNIQUE,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  version TEXT DEFAULT '1.0',
  effective_date DATE,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

ALTER TABLE public.legal_documents ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admins manage legal documents"
  ON public.legal_documents
  FOR ALL
  USING (has_role(auth.uid(), 'admin'::app_role))
  WITH CHECK (has_role(auth.uid(), 'admin'::app_role));

CREATE POLICY "All users view active legal documents"
  ON public.legal_documents
  FOR SELECT
  USING (is_active = true);

-- Email Templates Table
CREATE TABLE public.email_templates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  template_key TEXT NOT NULL UNIQUE,
  template_name TEXT NOT NULL,
  subject TEXT NOT NULL,
  body_html TEXT NOT NULL,
  body_text TEXT,
  category TEXT NOT NULL,
  variables JSONB DEFAULT '[]'::jsonb,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

ALTER TABLE public.email_templates ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admins manage email templates"
  ON public.email_templates
  FOR ALL
  USING (has_role(auth.uid(), 'admin'::app_role))
  WITH CHECK (has_role(auth.uid(), 'admin'::app_role));

CREATE POLICY "Users view active templates"
  ON public.email_templates
  FOR SELECT
  USING (is_active = true);

-- Email Campaigns Table
CREATE TABLE public.email_campaigns (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  campaign_name TEXT NOT NULL,
  template_id UUID REFERENCES public.email_templates(id) ON DELETE SET NULL,
  status TEXT DEFAULT 'draft',
  recipients JSONB DEFAULT '[]'::jsonb,
  scheduled_at TIMESTAMP WITH TIME ZONE,
  sent_at TIMESTAMP WITH TIME ZONE,
  metrics JSONB DEFAULT '{}'::jsonb,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

ALTER TABLE public.email_campaigns ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users manage own campaigns"
  ON public.email_campaigns
  FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Feature Flags Table
CREATE TABLE public.feature_flags (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  flag_key TEXT NOT NULL UNIQUE,
  flag_name TEXT NOT NULL,
  description TEXT,
  is_enabled BOOLEAN DEFAULT false,
  target_users JSONB DEFAULT '[]'::jsonb,
  config JSONB DEFAULT '{}'::jsonb,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

ALTER TABLE public.feature_flags ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admins manage feature flags"
  ON public.feature_flags
  FOR ALL
  USING (has_role(auth.uid(), 'admin'::app_role))
  WITH CHECK (has_role(auth.uid(), 'admin'::app_role));

CREATE POLICY "All users view feature flags"
  ON public.feature_flags
  FOR SELECT
  USING (true);

-- Create triggers for updated_at columns
CREATE TRIGGER update_market_intelligence_updated_at BEFORE UPDATE ON public.market_intelligence
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_agent_voices_updated_at BEFORE UPDATE ON public.agent_voices
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_user_knowledge_updated_at BEFORE UPDATE ON public.user_knowledge
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_crm_connections_updated_at BEFORE UPDATE ON public.crm_connections
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_content_packs_updated_at BEFORE UPDATE ON public.content_packs
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_content_topics_updated_at BEFORE UPDATE ON public.content_topics
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_featured_content_packs_updated_at BEFORE UPDATE ON public.featured_content_packs
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_generated_content_updated_at BEFORE UPDATE ON public.generated_content
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_ai_prompt_configs_updated_at BEFORE UPDATE ON public.ai_prompt_configs
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_transactions_updated_at BEFORE UPDATE ON public.transactions
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_user_credits_updated_at BEFORE UPDATE ON public.user_credits
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_role_play_user_progress_updated_at BEFORE UPDATE ON public.role_play_user_progress
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_referrals_updated_at BEFORE UPDATE ON public.referrals
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_brand_color_palettes_updated_at BEFORE UPDATE ON public.brand_color_palettes
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_user_agent_subscriptions_updated_at BEFORE UPDATE ON public.user_agent_subscriptions
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_legal_documents_updated_at BEFORE UPDATE ON public.legal_documents
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_email_templates_updated_at BEFORE UPDATE ON public.email_templates
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_email_campaigns_updated_at BEFORE UPDATE ON public.email_campaigns
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_feature_flags_updated_at BEFORE UPDATE ON public.feature_flags
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- =====================================================================
-- MIGRATION: 20251103231817_4e3af132-ab63-4c78-a05c-59d54028f231.sql
-- =====================================================================

-- Create ai_agent_conversations table
CREATE TABLE public.ai_agent_conversations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  agent_type TEXT NOT NULL,
  messages JSONB DEFAULT '[]'::jsonb,
  context JSONB DEFAULT '{}'::jsonb,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

ALTER TABLE public.ai_agent_conversations ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users manage own conversations"
ON public.ai_agent_conversations
FOR ALL
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Create external_service_connections table
CREATE TABLE public.external_service_connections (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  service_name TEXT NOT NULL,
  connection_status TEXT DEFAULT 'disconnected',
  credentials JSONB DEFAULT '{}'::jsonb,
  settings JSONB DEFAULT '{}'::jsonb,
  last_sync_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  UNIQUE(user_id, service_name)
);

ALTER TABLE public.external_service_connections ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users manage own service connections"
ON public.external_service_connections
FOR ALL
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Create storage buckets
INSERT INTO storage.buckets (id, name, public) 
VALUES 
  ('agent-voices', 'agent-voices', false),
  ('avatars', 'avatars', true),
  ('content-packs', 'content-packs', true),
  ('generated-content', 'generated-content', false),
  ('brand-assets', 'brand-assets', false),
  ('audio-recordings', 'audio-recordings', false),
  ('documents', 'documents', false)
ON CONFLICT (id) DO NOTHING;

-- Storage policies for agent-voices
CREATE POLICY "Users can upload their own agent voices"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'agent-voices' 
  AND auth.uid()::text = (storage.foldername(name))[1]
);

CREATE POLICY "Users can view their own agent voices"
ON storage.objects FOR SELECT
USING (
  bucket_id = 'agent-voices' 
  AND auth.uid()::text = (storage.foldername(name))[1]
);

-- Storage policies for avatars (public)
CREATE POLICY "Anyone can view avatars"
ON storage.objects FOR SELECT
USING (bucket_id = 'avatars');

CREATE POLICY "Users can upload their own avatar"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'avatars' 
  AND auth.uid()::text = (storage.foldername(name))[1]
);

-- Storage policies for content-packs (public read)
CREATE POLICY "Anyone can view content packs"
ON storage.objects FOR SELECT
USING (bucket_id = 'content-packs');

CREATE POLICY "Admins can upload content packs"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'content-packs' 
  AND has_role(auth.uid(), 'admin'::app_role)
);

-- Storage policies for generated-content
CREATE POLICY "Users can manage their own generated content"
ON storage.objects FOR ALL
USING (
  bucket_id = 'generated-content' 
  AND auth.uid()::text = (storage.foldername(name))[1]
)
WITH CHECK (
  bucket_id = 'generated-content' 
  AND auth.uid()::text = (storage.foldername(name))[1]
);

-- Storage policies for brand-assets
CREATE POLICY "Users can manage their own brand assets"
ON storage.objects FOR ALL
USING (
  bucket_id = 'brand-assets' 
  AND auth.uid()::text = (storage.foldername(name))[1]
)
WITH CHECK (
  bucket_id = 'brand-assets' 
  AND auth.uid()::text = (storage.foldername(name))[1]
);

-- Storage policies for audio-recordings
CREATE POLICY "Users can manage their own audio recordings"
ON storage.objects FOR ALL
USING (
  bucket_id = 'audio-recordings' 
  AND auth.uid()::text = (storage.foldername(name))[1]
)
WITH CHECK (
  bucket_id = 'audio-recordings' 
  AND auth.uid()::text = (storage.foldername(name))[1]
);

-- Storage policies for documents
CREATE POLICY "Users can manage their own documents"
ON storage.objects FOR ALL
USING (
  bucket_id = 'documents' 
  AND auth.uid()::text = (storage.foldername(name))[1]
)
WITH CHECK (
  bucket_id = 'documents' 
  AND auth.uid()::text = (storage.foldername(name))[1]
);

-- Add trigger for updated_at on new tables
CREATE TRIGGER update_ai_agent_conversations_updated_at
BEFORE UPDATE ON public.ai_agent_conversations
FOR EACH ROW
EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_external_service_connections_updated_at
BEFORE UPDATE ON public.external_service_connections
FOR EACH ROW
EXECUTE FUNCTION public.update_updated_at_column();

-- =====================================================================
-- MIGRATION: 20251104010819_045e4784-a806-4b83-b188-ccbe283a7fc0.sql
-- =====================================================================

-- Add palette_id column to brand_color_palettes
ALTER TABLE brand_color_palettes 
ADD COLUMN IF NOT EXISTS palette_id TEXT;

-- Add comment explaining accent_color limitation
COMMENT ON COLUMN brand_color_palettes.accent_color IS 
'Primary accent color from CSV accentColorHex1. Note: CSV exports include accentColorHex2 but only one accent_color is stored.';

-- No other schema changes needed as tables already have correct structure
-- agent_voices will store previewAudioUrl and isActive in voice_settings jsonb
-- call_logs will store full data in metadata jsonb
-- Other tables match CSV structure or can be handled via column mapping

-- =====================================================================
-- MIGRATION: 20251104050253_7d58f505-2555-4f5a-9259-a7fb45c93199.sql
-- =====================================================================

-- Add missing preference columns to user_preferences table
ALTER TABLE public.user_preferences
ADD COLUMN IF NOT EXISTS coaching_style text DEFAULT 'balanced',
ADD COLUMN IF NOT EXISTS activity_mode text DEFAULT 'get_moving',
ADD COLUMN IF NOT EXISTS timezone text DEFAULT 'America/New_York',
ADD COLUMN IF NOT EXISTS daily_reminders boolean DEFAULT true,
ADD COLUMN IF NOT EXISTS weekly_reports boolean DEFAULT true,
ADD COLUMN IF NOT EXISTS market_updates boolean DEFAULT true,
ADD COLUMN IF NOT EXISTS email_notifications boolean DEFAULT true;

-- =====================================================================
-- MIGRATION: 20251104051232_5bd74db4-f0e5-4759-91a5-5c030ad5c672.sql
-- =====================================================================

-- Phase 1: Create agent_intelligence_profiles table
CREATE TABLE public.agent_intelligence_profiles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  experience_level text,
  work_commitment text,
  business_structure text,
  database_size text,
  sphere_warmth text,
  previous_year_transactions integer,
  previous_year_volume bigint,
  average_price_point text,
  business_consistency text,
  biggest_challenges text[],
  growth_timeline text,
  learning_preference text,
  survey_completed_at timestamptz,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  UNIQUE(user_id)
);

-- Enable RLS
ALTER TABLE public.agent_intelligence_profiles ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Users manage own intelligence profile"
  ON public.agent_intelligence_profiles
  FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Phase 2: Add missing columns to user_onboarding
ALTER TABLE public.user_onboarding
ADD COLUMN IF NOT EXISTS agent_intelligence_completed boolean DEFAULT false,
ADD COLUMN IF NOT EXISTS agent_intelligence_completion_date timestamptz;

-- =====================================================================
-- MIGRATION: 20251104060440_51bce73c-05ee-4dcb-abdd-585a62939505.sql
-- =====================================================================

-- Create ai_tool_usage table to track tool execution
CREATE TABLE IF NOT EXISTS public.ai_tool_usage (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  agent_type TEXT,
  tool_name TEXT NOT NULL,
  tool_args JSONB DEFAULT '{}'::jsonb,
  tool_result JSONB,
  execution_time_ms INTEGER,
  success BOOLEAN NOT NULL DEFAULT false,
  error_message TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Create index for faster queries
CREATE INDEX IF NOT EXISTS idx_ai_tool_usage_user_id ON public.ai_tool_usage(user_id);
CREATE INDEX IF NOT EXISTS idx_ai_tool_usage_created_at ON public.ai_tool_usage(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_ai_tool_usage_tool_name ON public.ai_tool_usage(tool_name);

-- Enable RLS
ALTER TABLE public.ai_tool_usage ENABLE ROW LEVEL SECURITY;

-- Users can view their own tool usage
CREATE POLICY "Users can view their own tool usage"
  ON public.ai_tool_usage
  FOR SELECT
  USING (auth.uid() = user_id);

-- Service role can insert tool usage logs
CREATE POLICY "Service role can insert tool usage logs"
  ON public.ai_tool_usage
  FOR INSERT
  WITH CHECK (true);

-- =====================================================================
-- MIGRATION: 20251104144653_437ebb4b-c1e5-48b7-9abd-e029a2546160.sql
-- =====================================================================

-- Add avatar_url column to profiles table
ALTER TABLE public.profiles 
ADD COLUMN IF NOT EXISTS avatar_url TEXT;

COMMENT ON COLUMN public.profiles.avatar_url IS 'URL to user profile avatar image stored in Supabase Storage';

-- Add license_state column to profiles table
ALTER TABLE public.profiles 
ADD COLUMN IF NOT EXISTS license_state TEXT;

COMMENT ON COLUMN public.profiles.license_state IS 'US state where the agent is licensed';

-- Migrate existing data from specialization to license_state if it looks like a state
UPDATE public.profiles 
SET license_state = specialization 
WHERE specialization IS NOT NULL 
  AND length(specialization) <= 2;

-- Update RLS policy to allow users to update their own profile including avatar_url and license_state
DROP POLICY IF EXISTS "Users can update their own profile" ON public.profiles;

CREATE POLICY "Users can update their own profile" 
ON public.profiles 
FOR UPDATE 
USING (auth.uid() = id) 
WITH CHECK (auth.uid() = id);

-- =====================================================================
-- MIGRATION: 20251104165628_8708a391-32b0-4de8-81f6-70a832b54c75.sql
-- =====================================================================

-- Expand content_topics table to support full weekly content pack system
ALTER TABLE content_topics 
ADD COLUMN IF NOT EXISTS week_number INTEGER,
ADD COLUMN IF NOT EXISTS social_feed_graphic_url TEXT,
ADD COLUMN IF NOT EXISTS social_feed_caption TEXT,
ADD COLUMN IF NOT EXISTS social_hashtags TEXT,
ADD COLUMN IF NOT EXISTS outreach_email_subject TEXT,
ADD COLUMN IF NOT EXISTS outreach_email TEXT,
ADD COLUMN IF NOT EXISTS outreach_call_script TEXT,
ADD COLUMN IF NOT EXISTS outreach_dm_template TEXT;

-- Add topic_id to content_packs to link packs with topics
ALTER TABLE content_packs 
ADD COLUMN IF NOT EXISTS topic_id UUID REFERENCES content_topics(id) ON DELETE SET NULL;

-- Create content-topics storage bucket for social media graphics
INSERT INTO storage.buckets (id, name, public)
VALUES ('content-topics', 'content-topics', true)
ON CONFLICT (id) DO NOTHING;

-- RLS policies for content-topics bucket
CREATE POLICY "Admins can upload content topic images"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'content-topics' AND
  has_role(auth.uid(), 'admin'::app_role)
);

CREATE POLICY "Admins can update content topic images"
ON storage.objects FOR UPDATE
TO authenticated
USING (
  bucket_id = 'content-topics' AND
  has_role(auth.uid(), 'admin'::app_role)
)
WITH CHECK (
  bucket_id = 'content-topics' AND
  has_role(auth.uid(), 'admin'::app_role)
);

CREATE POLICY "Admins can delete content topic images"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'content-topics' AND
  has_role(auth.uid(), 'admin'::app_role)
);

CREATE POLICY "Public can view content topic images"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'content-topics');

-- =====================================================================
-- MIGRATION: 20251104170008_436f2d70-10b4-4546-aa8f-b00bf8e76926.sql
-- =====================================================================

-- Fix RLS policies for platform-wide data imported from external database
-- These records are created by the system user during sync and should be viewable by all users

-- Drop existing restrictive policies and create new ones for task_templates
DROP POLICY IF EXISTS "Users view active task templates" ON task_templates;
DROP POLICY IF EXISTS "Admins manage task templates" ON task_templates;

CREATE POLICY "All authenticated users can view task templates"
ON task_templates FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "Admins can manage task templates"
ON task_templates FOR ALL
TO authenticated
USING (has_role(auth.uid(), 'admin'::app_role))
WITH CHECK (has_role(auth.uid(), 'admin'::app_role));

-- Fix client_personas policies
DROP POLICY IF EXISTS "Users view active personas" ON client_personas;
DROP POLICY IF EXISTS "Admins manage client personas" ON client_personas;

CREATE POLICY "All authenticated users can view client personas"
ON client_personas FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "Admins can manage client personas"
ON client_personas FOR ALL
TO authenticated
USING (has_role(auth.uid(), 'admin'::app_role))
WITH CHECK (has_role(auth.uid(), 'admin'::app_role));

-- Fix featured_content_packs policies  
DROP POLICY IF EXISTS "Users view active featured packs" ON featured_content_packs;
DROP POLICY IF EXISTS "Admins manage featured content packs" ON featured_content_packs;

CREATE POLICY "All authenticated users can view featured content packs"
ON featured_content_packs FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "Admins can manage featured content packs"
ON featured_content_packs FOR ALL
TO authenticated
USING (has_role(auth.uid(), 'admin'::app_role))
WITH CHECK (has_role(auth.uid(), 'admin'::app_role));

-- Fix agent_voices to be viewable by all (these are platform voice options, not user-specific)
DROP POLICY IF EXISTS "Users manage own agent voices" ON agent_voices;

CREATE POLICY "All authenticated users can view agent voices"
ON agent_voices FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "Admins can manage agent voices"
ON agent_voices FOR ALL
TO authenticated
USING (has_role(auth.uid(), 'admin'::app_role))
WITH CHECK (has_role(auth.uid(), 'admin'::app_role));

-- Keep call_logs user-specific but allow admins to see all
CREATE POLICY "Admins can view all call logs"
ON call_logs FOR SELECT
TO authenticated
USING (has_role(auth.uid(), 'admin'::app_role));

-- =====================================================================
-- MIGRATION: 20251105000000_add_elevenlabs_call_support.sql
-- =====================================================================

-- Add extended metadata columns for ElevenLabs integrations
ALTER TABLE public.call_logs
  ADD COLUMN IF NOT EXISTS conversation_id TEXT,
  ADD COLUMN IF NOT EXISTS call_sid TEXT,
  ADD COLUMN IF NOT EXISTS ended_at TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS transcript JSONB DEFAULT '[]'::jsonb,
  ADD COLUMN IF NOT EXISTS analysis JSONB DEFAULT '{}'::jsonb,
  ADD COLUMN IF NOT EXISTS form_data JSONB DEFAULT '{}'::jsonb;

ALTER TABLE public.call_logs
  ALTER COLUMN status SET DEFAULT 'pending_initiation',
  ALTER COLUMN metadata SET DEFAULT '{}'::jsonb;

CREATE INDEX IF NOT EXISTS call_logs_conversation_id_idx
  ON public.call_logs (conversation_id);

ALTER TABLE public.role_play_session_logs
  ADD COLUMN IF NOT EXISTS conversation_id TEXT,
  ADD COLUMN IF NOT EXISTS call_sid TEXT,
  ADD COLUMN IF NOT EXISTS metadata JSONB DEFAULT '{}'::jsonb,
  ADD COLUMN IF NOT EXISTS recording_url TEXT,
  ADD COLUMN IF NOT EXISTS ended_at TIMESTAMPTZ;

ALTER TABLE public.role_play_session_logs
  ALTER COLUMN status SET DEFAULT 'pending_initiation';

CREATE INDEX IF NOT EXISTS role_play_session_logs_conversation_id_idx
  ON public.role_play_session_logs (conversation_id);

ALTER TABLE public.role_play_analysis_reports
  ADD COLUMN IF NOT EXISTS overall_result TEXT;

ALTER TABLE public.user_agent_subscriptions
  ADD COLUMN IF NOT EXISTS minutes_allocated INTEGER,
  ADD COLUMN IF NOT EXISTS current_minutes_used INTEGER DEFAULT 0,
  ADD COLUMN IF NOT EXISTS overage_rate NUMERIC(6,2) DEFAULT 0;

-- Ensure defaults for existing numeric columns
ALTER TABLE public.user_agent_subscriptions
  ALTER COLUMN current_minutes_used SET DEFAULT 0,
  ALTER COLUMN overage_rate SET DEFAULT 0;

-- Ensure credit tracking uses non-null defaults
ALTER TABLE public.user_credits
  ALTER COLUMN credits_available SET DEFAULT 0,
  ALTER COLUMN credits_used SET DEFAULT 0;

-- Maintain metadata defaults for analysis tables
ALTER TABLE public.role_play_session_logs
  ALTER COLUMN transcript SET DEFAULT '[]'::jsonb;

-- Index to speed up lookups by session status
CREATE INDEX IF NOT EXISTS role_play_session_logs_status_idx
  ON public.role_play_session_logs (status);


-- =====================================================================
-- MIGRATION: 20251105145610_ed53218f-7a11-4e6d-a4ca-f68fa770ac9e.sql
-- =====================================================================

-- Fix profiles table to accept Clerk user IDs (which are text, not UUID)
-- Drop existing table if it exists and recreate with correct types
DROP TABLE IF EXISTS public.profiles CASCADE;

CREATE TABLE public.profiles (
  id TEXT PRIMARY KEY,
  email TEXT,
  full_name TEXT,
  avatar_url TEXT,
  phone TEXT,
  license_number TEXT,
  license_state TEXT,
  brokerage TEXT,
  role TEXT DEFAULT 'user',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Users can view their own profile"
  ON public.profiles
  FOR SELECT
  USING (auth.uid()::text = id);

CREATE POLICY "Users can update their own profile"
  ON public.profiles
  FOR UPDATE
  USING (auth.uid()::text = id);

CREATE POLICY "Users can insert their own profile"
  ON public.profiles
  FOR INSERT
  WITH CHECK (auth.uid()::text = id);

-- Create user_onboarding table with proper ID type
DROP TABLE IF EXISTS public.user_onboarding CASCADE;

CREATE TABLE public.user_onboarding (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id TEXT NOT NULL UNIQUE,
  onboarding_completed BOOLEAN DEFAULT FALSE,
  agent_onboarding_completed BOOLEAN DEFAULT FALSE,
  call_center_onboarding_completed BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.user_onboarding ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Users can view their own onboarding"
  ON public.user_onboarding
  FOR SELECT
  USING (auth.uid()::text = user_id);

CREATE POLICY "Users can update their own onboarding"
  ON public.user_onboarding
  FOR UPDATE
  USING (auth.uid()::text = user_id);

CREATE POLICY "Users can insert their own onboarding"
  ON public.user_onboarding
  FOR INSERT
  WITH CHECK (auth.uid()::text = user_id);

-- =====================================================================
-- MIGRATION: 20251105231025_477a69af-4b3b-4d32-85d6-0598fd730210.sql
-- =====================================================================

-- Update avatars bucket policies to fix upload errors

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Users can upload their own avatar" ON storage.objects;
DROP POLICY IF EXISTS "Anyone can view avatars" ON storage.objects;
DROP POLICY IF EXISTS "Users can update their own avatar" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete their own avatar" ON storage.objects;

-- Allow authenticated users to upload to their own user ID path in avatars bucket
CREATE POLICY "Users can upload their own avatar"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'avatars' 
  AND auth.uid()::text = (storage.foldername(name))[1]
);

-- Allow public read access to all avatars
CREATE POLICY "Anyone can view avatars"
ON storage.objects
FOR SELECT
TO public
USING (bucket_id = 'avatars');

-- Allow users to update their own avatars
CREATE POLICY "Users can update their own avatar"
ON storage.objects
FOR UPDATE
TO authenticated
USING (
  bucket_id = 'avatars' 
  AND auth.uid()::text = (storage.foldername(name))[1]
)
WITH CHECK (
  bucket_id = 'avatars' 
  AND auth.uid()::text = (storage.foldername(name))[1]
);

-- Allow users to delete their own avatars
CREATE POLICY "Users can delete their own avatar"
ON storage.objects
FOR DELETE
TO authenticated
USING (
  bucket_id = 'avatars' 
  AND auth.uid()::text = (storage.foldername(name))[1]
);

-- =====================================================================
-- MIGRATION: 20251106090000_end_to_end_features.sql
-- =====================================================================


-- Ensure helper exists to keep updated_at columns current
CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Ensure subscription metadata lives on profiles
ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS subscription_tier TEXT DEFAULT 'Free',
  ADD COLUMN IF NOT EXISTS subscription_status TEXT DEFAULT 'active';

-- Track GoHighLevel onboarding automation
ALTER TABLE public.user_onboarding
  ADD COLUMN IF NOT EXISTS highlevel_webhook_sent BOOLEAN DEFAULT false;

-- Expand subscription tracking for external commerce platforms
ALTER TABLE public.user_agent_subscriptions
  ADD COLUMN IF NOT EXISTS plan_type TEXT,
  ADD COLUMN IF NOT EXISTS billing_cycle_start TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS billing_cycle_end TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS gohighlevel_order_id TEXT,
  ADD COLUMN IF NOT EXISTS shopify_order_id TEXT,
  ADD COLUMN IF NOT EXISTS source_platform TEXT DEFAULT 'app',
  ADD COLUMN IF NOT EXISTS status TEXT DEFAULT 'active';

ALTER TABLE public.user_agent_subscriptions
  ALTER COLUMN source_platform SET DEFAULT 'app',
  ALTER COLUMN status SET DEFAULT 'active';

-- System-wide error log used by admin dashboards and notifications
CREATE TABLE IF NOT EXISTS public.system_errors (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  severity TEXT NOT NULL CHECK (severity IN ('critical', 'warning', 'info')),
  function_name TEXT NOT NULL,
  message TEXT NOT NULL,
  stack_trace TEXT,
  user_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
  metadata JSONB DEFAULT '{}'::jsonb,
  occurrence_count INTEGER DEFAULT 1,
  created_at TIMESTAMPTZ DEFAULT now(),
  last_occurrence_at TIMESTAMPTZ DEFAULT now(),
  resolved BOOLEAN DEFAULT false,
  resolved_at TIMESTAMPTZ,
  resolved_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL
);

ALTER TABLE public.system_errors ENABLE ROW LEVEL SECURITY;

CREATE POLICY IF NOT EXISTS "Admins manage system errors"
  ON public.system_errors
  FOR ALL
  USING (has_role(auth.uid(), 'admin'::app_role))
  WITH CHECK (has_role(auth.uid(), 'admin'::app_role));

CREATE INDEX IF NOT EXISTS system_errors_function_idx
  ON public.system_errors (function_name, severity);

-- Persist integration check results and last webhook timestamps
CREATE TABLE IF NOT EXISTS public.integration_status (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  service TEXT NOT NULL UNIQUE,
  status TEXT NOT NULL,
  response_time_ms INTEGER,
  last_checked TIMESTAMPTZ DEFAULT now(),
  error_message TEXT,
  metadata JSONB DEFAULT '{}'::jsonb
);

ALTER TABLE public.integration_status ENABLE ROW LEVEL SECURITY;

CREATE POLICY IF NOT EXISTS "Admins view integration status"
  ON public.integration_status
  FOR SELECT
  USING (has_role(auth.uid(), 'admin'::app_role));

CREATE POLICY IF NOT EXISTS "Admins manage integration status"
  ON public.integration_status
  FOR ALL
  USING (has_role(auth.uid(), 'admin'::app_role))
  WITH CHECK (has_role(auth.uid(), 'admin'::app_role));

-- Centralised email delivery logging for automated campaigns
CREATE TABLE IF NOT EXISTS public.email_delivery_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  email_type TEXT NOT NULL,
  template_key TEXT,
  sent_at TIMESTAMPTZ DEFAULT now(),
  metadata JSONB DEFAULT '{}'::jsonb
);

ALTER TABLE public.email_delivery_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY IF NOT EXISTS "Users view own email logs"
  ON public.email_delivery_logs
  FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY IF NOT EXISTS "Admins manage email logs"
  ON public.email_delivery_logs
  FOR ALL
  USING (has_role(auth.uid(), 'admin'::app_role))
  WITH CHECK (has_role(auth.uid(), 'admin'::app_role));

-- Store cached market data snapshots from RapidAPI
CREATE TABLE IF NOT EXISTS public.market_data (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  geography_type TEXT,
  geography_id TEXT,
  geography_name TEXT,
  raw_data JSONB NOT NULL DEFAULT '{}'::jsonb,
  data_date TIMESTAMPTZ DEFAULT now(),
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(user_id, geography_id)
);

ALTER TABLE public.market_data ENABLE ROW LEVEL SECURITY;

CREATE POLICY IF NOT EXISTS "Users manage own market data"
  ON public.market_data
  FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE TRIGGER update_market_data_updated_at
  BEFORE UPDATE ON public.market_data
  FOR EACH ROW
  EXECUTE FUNCTION public.set_updated_at();


-- =====================================================================
-- MIGRATION: 20251107100000_rls_permission_updates.sql
-- =====================================================================

-- Ensure user-owned records default to the requesting user
CREATE OR REPLACE FUNCTION public.set_user_id()
RETURNS trigger AS $$
BEGIN
  IF NEW.user_id IS NULL THEN
    NEW.user_id := auth.uid();
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- Attach the helper trigger to every table that exposes a user_id column
DO $$
DECLARE
  tbl TEXT;
BEGIN
  FOR tbl IN
    SELECT table_name
    FROM information_schema.columns
    WHERE table_schema = 'public' AND column_name = 'user_id'
  LOOP
    EXECUTE format('DROP TRIGGER IF EXISTS set_user_id_trigger ON public.%I;', tbl);
    EXECUTE format(
      'CREATE TRIGGER set_user_id_trigger BEFORE INSERT ON public.%I
       FOR EACH ROW EXECUTE FUNCTION public.set_user_id();',
      tbl
    );
  END LOOP;
END$$;

-- Drop any existing policies so we can replace them with the new baseline
DO $$
DECLARE
  tbl TEXT;
  pol RECORD;
BEGIN
  FOR tbl IN SELECT unnest(ARRAY[
    'agent_config',
    'agent_intelligence_profiles',
    'agent_voices',
    'ai_actions_log',
    'ai_agent_conversations',
    'ai_prompt_configs',
    'ai_tool_usage',
    'brand_color_palettes',
    'business_plans',
    'call_logs',
    'client_personas',
    'content_packs',
    'content_topics',
    'credit_transactions',
    'crm_connections',
    'daily_actions',
    'email_campaigns',
    'email_templates',
    'external_service_connections',
    'feature_flags',
    'featured_content_packs',
    'goals',
    'market_config',
    'market_intelligence',
    'generated_content',
    'objection_scripts',
    'role_play_scenarios',
    'role_play_session_logs',
    'role_play_user_progress',
    'profiles',
    'user_preferences',
    'user_agent_subscriptions',
    'user_credits',
    'user_guidelines',
    'user_onboarding',
    'transactions',
    'task_templates',
    'legal_documents',
    'campaign_templates'
  ])
  LOOP
    IF EXISTS (
      SELECT 1
      FROM information_schema.tables
      WHERE table_schema = 'public' AND table_name = tbl
    ) THEN
      FOR pol IN
        SELECT policyname
        FROM pg_policies
        WHERE schemaname = 'public' AND tablename = tbl
      LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON public.%I;', pol.policyname, tbl);
      END LOOP;
      EXECUTE format('ALTER TABLE IF EXISTS public.%I ENABLE ROW LEVEL SECURITY;', tbl);
    END IF;
  END LOOP;
END$$;

-- Ensure content topics can store ownership metadata for drafts
ALTER TABLE IF EXISTS public.content_topics
  ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  ADD COLUMN IF NOT EXISTS is_public BOOLEAN DEFAULT false;

-- Tables that simply follow the admin + owner pattern
DO $$
DECLARE
  tbl TEXT;
BEGIN
  FOR tbl IN SELECT unnest(ARRAY[
    'ai_prompt_configs',
    'ai_tool_usage',
    'brand_color_palettes',
    'business_plans',
    'call_logs',
    'credit_transactions',
    'crm_connections',
    'daily_actions',
    'email_campaigns',
    'email_templates',
    'external_service_connections',
    'goals',
    'market_config',
    'generated_content',
    'role_play_session_logs',
    'user_preferences',
    'user_agent_subscriptions',
    'user_credits',
    'user_guidelines',
    'user_onboarding',
    'transactions',
    'campaign_templates'
  ])
  LOOP
    IF EXISTS (
      SELECT 1
      FROM information_schema.columns
      WHERE table_schema = 'public' AND table_name = tbl AND column_name = 'user_id'
    ) THEN
      EXECUTE format('CREATE POLICY "Admins manage %I" ON public.%I FOR ALL
        USING (has_role(auth.uid(), ''admin''::app_role))
        WITH CHECK (has_role(auth.uid(), ''admin''::app_role));', tbl, tbl);

      EXECUTE format('CREATE POLICY "Users manage own %I" ON public.%I FOR ALL
        TO authenticated
        USING (auth.uid() = user_id)
        WITH CHECK (auth.uid() = user_id);', tbl, tbl);
    ELSE
      EXECUTE format('CREATE POLICY "Admins manage %I" ON public.%I FOR ALL
        USING (has_role(auth.uid(), ''admin''::app_role))
        WITH CHECK (has_role(auth.uid(), ''admin''::app_role));', tbl, tbl);
    END IF;
  END LOOP;
END$$;

CREATE POLICY "Users view active ai_prompt_configs"
ON public.ai_prompt_configs FOR SELECT
TO authenticated
USING (is_active = true);

-- Agent configuration
CREATE POLICY "Admins manage agent_config"
ON public.agent_config FOR ALL
USING (has_role(auth.uid(), 'admin'::app_role))
WITH CHECK (has_role(auth.uid(), 'admin'::app_role));

CREATE POLICY "Users manage own agent_config"
ON public.agent_config FOR ALL
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Agent intelligence profiles
CREATE POLICY "Admins manage agent_intelligence_profiles"
ON public.agent_intelligence_profiles FOR ALL
USING (has_role(auth.uid(), 'admin'::app_role))
WITH CHECK (has_role(auth.uid(), 'admin'::app_role));

CREATE POLICY "Users manage own intelligence profile"
ON public.agent_intelligence_profiles FOR ALL
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- AI agent conversations
CREATE POLICY "Admins manage ai_agent_conversations"
ON public.ai_agent_conversations FOR ALL
USING (has_role(auth.uid(), 'admin'::app_role))
WITH CHECK (has_role(auth.uid(), 'admin'::app_role));

CREATE POLICY "Users manage own ai_agent_conversations"
ON public.ai_agent_conversations FOR ALL
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Agent voices are admin managed only
CREATE POLICY "Admins manage agent_voices"
ON public.agent_voices FOR ALL
USING (has_role(auth.uid(), 'admin'::app_role))
WITH CHECK (has_role(auth.uid(), 'admin'::app_role));

-- AI actions log retains granular policies
CREATE POLICY "Admins manage ai_actions_log"
ON public.ai_actions_log FOR ALL
USING (has_role(auth.uid(), 'admin'::app_role))
WITH CHECK (has_role(auth.uid(), 'admin'::app_role));

CREATE POLICY "Users view own ai_actions_log"
ON public.ai_actions_log FOR SELECT
TO authenticated
USING (auth.uid() = user_id);

CREATE POLICY "Users insert ai_actions_log"
ON public.ai_actions_log FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

-- Content oriented access
CREATE POLICY "Admins manage content_packs"
ON public.content_packs FOR ALL
USING (has_role(auth.uid(), 'admin'::app_role))
WITH CHECK (has_role(auth.uid(), 'admin'::app_role));

CREATE POLICY "Public view active content packs"
ON public.content_packs FOR SELECT
TO public
USING (is_active = true);

CREATE POLICY "Admins manage content"
ON public.content_topics FOR ALL
USING (has_role(auth.uid(), 'admin'::app_role))
WITH CHECK (has_role(auth.uid(), 'admin'::app_role));

CREATE POLICY "Users insert drafts"
ON public.content_topics FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Public view active topics"
ON public.content_topics FOR SELECT
TO public
USING (is_active = true);

CREATE POLICY "Users view active email_templates"
ON public.email_templates FOR SELECT
TO authenticated
USING (is_active = true);

CREATE POLICY "Admins manage featured_content_packs"
ON public.featured_content_packs FOR ALL
USING (has_role(auth.uid(), 'admin'::app_role))
WITH CHECK (has_role(auth.uid(), 'admin'::app_role));

CREATE POLICY "Public view active featured content packs"
ON public.featured_content_packs FOR SELECT
TO public
USING (is_active = true);

-- Client personas and objection scripts remain curated but publicly viewable when active
CREATE POLICY "Admins manage client_personas"
ON public.client_personas FOR ALL
USING (has_role(auth.uid(), 'admin'::app_role))
WITH CHECK (has_role(auth.uid(), 'admin'::app_role));

CREATE POLICY "Public view active client_personas"
ON public.client_personas FOR SELECT
TO public
USING (is_active = true);

CREATE POLICY "Admins manage objection_scripts"
ON public.objection_scripts FOR ALL
USING (has_role(auth.uid(), 'admin'::app_role))
WITH CHECK (has_role(auth.uid(), 'admin'::app_role));

CREATE POLICY "Public view active objection_scripts"
ON public.objection_scripts FOR SELECT
TO public
USING (is_active = true);

CREATE POLICY "Admins manage all training content"
ON public.role_play_scenarios FOR ALL
USING (has_role(auth.uid(), 'admin'::app_role))
WITH CHECK (has_role(auth.uid(), 'admin'::app_role));

CREATE POLICY "Public can view active role_play_scenarios"
ON public.role_play_scenarios FOR SELECT
TO public
USING (is_active = true);

CREATE POLICY "Admins manage role_play_user_progress"
ON public.role_play_user_progress FOR ALL
USING (has_role(auth.uid(), 'admin'::app_role))
WITH CHECK (has_role(auth.uid(), 'admin'::app_role));

CREATE POLICY "Users track their own progress"
ON public.role_play_user_progress FOR ALL
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Profiles rely on ID column for ownership checks
CREATE POLICY "Admins manage profiles"
ON public.profiles FOR ALL
USING (has_role(auth.uid(), 'admin'::app_role))
WITH CHECK (has_role(auth.uid(), 'admin'::app_role));

CREATE POLICY "Users manage own profile"
ON public.profiles FOR ALL
TO authenticated
USING (auth.uid() = id)
WITH CHECK (auth.uid() = id);

-- Admin-only operational tables
CREATE POLICY "Admins manage feature_flags"
ON public.feature_flags FOR ALL
USING (has_role(auth.uid(), 'admin'::app_role))
WITH CHECK (has_role(auth.uid(), 'admin'::app_role));

CREATE POLICY "Users view feature_flags"
ON public.feature_flags FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "Admins manage market_intelligence"
ON public.market_intelligence FOR ALL
USING (has_role(auth.uid(), 'admin'::app_role))
WITH CHECK (has_role(auth.uid(), 'admin'::app_role));

CREATE POLICY "Admins manage user_roles"
ON public.user_roles FOR ALL
USING (has_role(auth.uid(), 'admin'::app_role))
WITH CHECK (has_role(auth.uid(), 'admin'::app_role));

CREATE POLICY "Users view own user_roles"
ON public.user_roles FOR SELECT
TO authenticated
USING (auth.uid() = user_id);

CREATE POLICY "Admins manage referrals"
ON public.referrals FOR ALL
USING (has_role(auth.uid(), 'admin'::app_role))
WITH CHECK (has_role(auth.uid(), 'admin'::app_role));

CREATE POLICY "Users manage own referrals"
ON public.referrals FOR ALL
TO authenticated
USING (auth.uid() = referrer_user_id)
WITH CHECK (auth.uid() = referrer_user_id);

CREATE POLICY "Admins manage legal_documents"
ON public.legal_documents FOR ALL
USING (has_role(auth.uid(), 'admin'::app_role))
WITH CHECK (has_role(auth.uid(), 'admin'::app_role));

CREATE POLICY "Public view active legal_documents"
ON public.legal_documents FOR SELECT
TO public
USING (is_active = true);

-- Task templates remain globally readable
CREATE POLICY "Admins manage task_templates"
ON public.task_templates FOR ALL
USING (has_role(auth.uid(), 'admin'::app_role))
WITH CHECK (has_role(auth.uid(), 'admin'::app_role));

CREATE POLICY "Public view active task_templates"
ON public.task_templates FOR SELECT
TO public
USING (is_active = true);


-- =====================================================================
-- MIGRATION: 20251107160000_fix_clerk_schema.sql
-- =====================================================================

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


-- =====================================================================
-- MIGRATION: 20251108170000_clerk_auth_complete_fix.sql
-- =====================================================================

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


-- =====================================================================
-- END OF SCHEMA EXPORT
-- =====================================================================
