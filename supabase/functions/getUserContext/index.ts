import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
import { validateClerkTokenWithJose } from '../_shared/clerkAuth.ts';

type LogLevel = 'log' | 'warn' | 'error';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

const withCors = (status: number, body: Record<string, unknown>) =>
  new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  });

const log = (level: LogLevel, message: string, meta?: Record<string, unknown>) => {
  const namespace = '[getUserContext]';
  if (meta) {
    console[level](`${namespace} ${message}`, meta);
  } else {
    console[level](`${namespace} ${message}`);
  }
};

class HttpError extends Error {
  status: number;
  constructor(status: number, message: string) {
    super(message);
    this.status = status;
  }
}

type QueryResult<T> = Promise<{ data: T | null; error: { message: string } | null }>;

type QueryRunner<T> = () => QueryResult<T>;

const ensureEnv = (key: string) => {
  const value = Deno.env.get(key);
  if (!value) {
    throw new HttpError(500, `Missing required environment variable: ${key}`);
  }
  return value;
};

const fetchRequired = async <T>(label: string, run: QueryRunner<T>): Promise<T> => {
  const { data, error } = await run();
  if (error) {
    log('error', `${label} query failed`, { message: error.message });
    throw new HttpError(500, `Failed to load ${label}`);
  }
  if (data === null) {
    log('warn', `${label} missing`);
    throw new HttpError(404, `${label} not found`);
  }
  return data;
};

const fetchOptional = async <T>(label: string, run: QueryRunner<T>): Promise<T | null> => {
  const { data, error } = await run();
  if (error) {
    log('warn', `${label} query failed`, { message: error.message });
    return null;
  }
  return data;
};

const fetchCollection = async <T>(label: string, run: QueryRunner<T[]>): Promise<T[]> => {
  const { data, error } = await run();
  if (error) {
    log('warn', `${label} query failed`, { message: error.message });
    return [];
  }
  return data ?? [];
};

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response(null, { headers: corsHeaders });
  }

  try {
    const authHeader = req.headers.get('Authorization');
    if (!authHeader?.startsWith('Bearer ')) {
      throw new HttpError(401, 'Missing or invalid Authorization header');
    }

    const token = authHeader.substring(7);
    let userId: string;
    try {
      userId = await validateClerkTokenWithJose(token);
    } catch (error) {
      log('warn', 'Token validation failed', { error: error instanceof Error ? error.message : String(error) });
      throw new HttpError(401, 'Invalid or expired token');
    }

    const supabaseUrl = ensureEnv('SUPABASE_URL');
    const supabaseKey = ensureEnv('SUPABASE_SERVICE_ROLE_KEY');
    const supabase = createClient(supabaseUrl, supabaseKey);

    log('log', 'Fetching user context', { userId });

    const [
      profile,
      onboarding,
      marketConfig,
      preferences,
      actions,
      agentConfig,
      agentSubscription,
      goals,
      businessPlan,
      pulseHistory,
      pulseConfig,
      agentProfile,
    ] = await Promise.all([
      fetchRequired('profile', () => supabase.from('profiles').select('*').eq('id', userId).maybeSingle()),
      fetchOptional('onboarding', () => supabase.from('user_onboarding').select('*').eq('user_id', userId).maybeSingle()),
      fetchOptional('market_config', () => supabase.from('market_config').select('*').eq('user_id', userId).maybeSingle()),
      fetchOptional('user_preferences', () => supabase.from('user_preferences').select('*').eq('user_id', userId).maybeSingle()),
      fetchCollection('daily_actions', () =>
        supabase
          .from('daily_actions')
          .select('*')
          .eq('user_id', userId)
          .order('due_date', { ascending: false })
          .limit(50)
      ),
      fetchOptional('agent_config', () => supabase.from('agent_config').select('*').eq('user_id', userId).maybeSingle()),
      fetchOptional('user_agent_subscription', () =>
        supabase.from('user_agent_subscription').select('*').eq('user_id', userId).maybeSingle()
      ),
      fetchCollection('goals', () => supabase.from('goals').select('*').eq('user_id', userId)),
      fetchOptional('business_plans', () => supabase.from('business_plans').select('*').eq('user_id', userId).maybeSingle()),
      fetchCollection('pulse_scores', () =>
        supabase
          .from('pulse_scores')
          .select('*')
          .eq('user_id', userId)
          .order('date', { ascending: false })
          .limit(30)
      ),
      fetchOptional('pulse_config', () => supabase.from('pulse_config').select('*').eq('user_id', userId).maybeSingle()),
      fetchOptional('agent_intelligence_profiles', () =>
        supabase.from('agent_intelligence_profiles').select('*').eq('user_id', userId).maybeSingle()
      ),
    ]);

    log('log', 'User context fetched successfully', { userId });

    return withCors(200, {
      user: profile,
      onboarding,
      marketConfig,
      preferences,
      actions,
      agentConfig,
      userAgentSubscription: agentSubscription,
      goals,
      businessPlan,
      pulseHistory,
      pulseConfig,
      agentProfile,
    });
  } catch (error) {
    if (error instanceof HttpError) {
      return withCors(error.status, { error: error.message });
    }

    log('error', 'Unexpected failure', { error: error instanceof Error ? error.message : String(error) });
    return withCors(500, { error: 'Internal server error' });
  }
});
