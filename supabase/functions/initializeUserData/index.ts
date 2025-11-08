import 'https://deno.land/x/xhr@0.1.0/mod.ts';
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.45.4';
import { validateClerkTokenWithJose } from '../_shared/clerkAuth.ts';

type LogLevel = 'log' | 'warn' | 'error';

type JsonRecord = Record<string, unknown>;

type QueryArrayResponse<T> = Promise<{ data: T[] | null; error: { message: string } | null }>;

class HttpError extends Error {
  status: number;
  constructor(status: number, message: string) {
    super(message);
    this.status = status;
  }
}

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

const withCors = (status: number, body: JsonRecord) =>
  new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  });

const log = (level: LogLevel, message: string, meta?: JsonRecord) => {
  const namespace = '[initializeUserData]';
  if (meta) {
    console[level](`${namespace} ${message}`, meta);
  } else {
    console[level](`${namespace} ${message}`);
  }
};

const requireEnv = (key: string) => {
  const value = Deno.env.get(key);
  if (!value) {
    throw new HttpError(500, `Missing required environment variable: ${key}`);
  }
  return value;
};

const ensureAbsent = async (label: string, query: QueryArrayResponse<{ id: string }>) => {
  const { data, error } = await query;
  if (error) {
    log('error', `${label} existence check failed`, { message: error.message });
    throw new HttpError(500, `Unable to verify existing ${label}`);
  }
  return !data || data.length === 0;
};

const insertSingle = async (
  supabase: ReturnType<typeof createClient>,
  table: string,
  payload: JsonRecord,
) => {
  const { error } = await supabase.from(table).insert(payload);
  if (error) {
    log('error', `${table} insert failed`, { message: error.message });
    throw new HttpError(500, `Failed to seed ${table}`);
  }
};

const insertMany = async (
  supabase: ReturnType<typeof createClient>,
  table: string,
  payload: JsonRecord[],
) => {
  if (payload.length === 0) return;
  const { error } = await supabase.from(table).insert(payload);
  if (error) {
    log('error', `${table} bulk insert failed`, { message: error.message });
    throw new HttpError(500, `Failed to seed ${table}`);
  }
};

const formatDate = (date: Date) => date.toISOString().split('T')[0];

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response(null, { headers: corsHeaders });
  }

  try {
    const supabaseUrl = requireEnv('SUPABASE_URL');
    const serviceRoleKey = requireEnv('SUPABASE_SERVICE_ROLE_KEY');

    const authHeader = req.headers.get('Authorization');
    if (!authHeader?.startsWith('Bearer ')) {
      throw new HttpError(401, 'Missing or invalid Authorization header');
    }

    const token = authHeader.substring(7);
    let userId: string;
    try {
      userId = await validateClerkTokenWithJose(token);
    } catch (error) {
      log('warn', 'JWT validation failed', { error: error instanceof Error ? error.message : String(error) });
      throw new HttpError(401, 'Invalid or expired token');
    }

    const supabaseAdmin = createClient(supabaseUrl, serviceRoleKey);
    const seededTables: string[] = [];
    const now = new Date();

    log('log', 'Seeding user data if necessary', { userId });

    const ensureSingleRecord = async (table: string, builder: () => JsonRecord | null | Promise<JsonRecord | null>) => {
      const isMissing = await ensureAbsent(`${table} record`, supabaseAdmin.from(table).select('id').eq('user_id', userId).limit(1));
      if (!isMissing) {
        log('log', `${table} already seeded`, { userId });
        return;
      }

      const payload = await builder();
      if (!payload) {
        log('warn', `${table} builder returned nothing`, { userId });
        return;
      }

      await insertSingle(supabaseAdmin, table, { user_id: userId, ...payload });
      seededTables.push(table);
    };

    const ensureMultipleRecords = async (
      table: string,
      builder: () => JsonRecord[] | Promise<JsonRecord[]>,
    ) => {
      const isMissing = await ensureAbsent(`${table} records`, supabaseAdmin.from(table).select('id').eq('user_id', userId).limit(1));
      if (!isMissing) {
        log('log', `${table} already seeded`, { userId });
        return 0;
      }

      const payload = await builder();
      if (!payload || payload.length === 0) {
        log('warn', `${table} builder returned no records`, { userId });
        return 0;
      }

      await insertMany(
        supabaseAdmin,
        table,
        payload.map((record) => ({ user_id: userId, ...record })),
      );
      seededTables.push(table);
      return payload.length;
    };

    await ensureSingleRecord('business_plans', () => {
      const monthlyBreakdown: Record<string, JsonRecord> = {};
      for (let i = 1; i <= 12; i += 1) {
        monthlyBreakdown[i.toString().padStart(2, '0')] = {
          conversations: 80,
          appointments: 12,
          closings: 2,
        };
      }

      return {
        annual_gci_goal: 150_000,
        transactions_needed: 24,
        average_commission: 7_500,
        lead_sources: {
          sphere: 0.4,
          past_clients: 0.3,
          online_leads: 0.2,
          open_houses: 0.1,
        },
        conversion_rates: {
          conversations_to_appointments: 0.2,
          appointments_to_clients: 0.4,
          clients_to_closings: 0.7,
        },
        monthly_breakdown: monthlyBreakdown,
      };
    });

    const currentYear = now.getFullYear();
    const quarterEndMonth = Math.floor(now.getMonth() / 3) * 3 + 3;
    const quarterDeadline = formatDate(new Date(currentYear, quarterEndMonth, 0));
    const yearEnd = formatDate(new Date(currentYear, 11, 31));

    await ensureMultipleRecords('goals', () => [
      {
        title: 'Annual GCI Goal',
        goal_type: 'production',
        target_value: 150_000,
        current_value: 0,
        unit: 'USD',
        timeframe: 'annual',
        deadline: yearEnd,
        confidence_score: 70,
        status: 'active',
      },
      {
        title: 'Conversations Per Week',
        goal_type: 'activity',
        target_value: 25,
        current_value: 0,
        unit: 'conversations',
        timeframe: 'weekly',
        deadline: yearEnd,
        confidence_score: 60,
        status: 'active',
      },
      {
        title: 'New Listings This Quarter',
        goal_type: 'pipeline',
        target_value: 6,
        current_value: 0,
        unit: 'listings',
        timeframe: 'quarterly',
        deadline: quarterDeadline,
        confidence_score: 55,
        status: 'active',
      },
    ]);

    const templateLimit = 5;
    const insertedDailyActions = await ensureMultipleRecords('daily_actions', async () => {
      const { data: templates, error: templateError } = await supabaseAdmin
        .from('task_templates')
        .select('title, description, category, priority')
        .eq('is_active', true)
        .order('priority_weight', { ascending: false })
        .limit(templateLimit);

      if (templateError) {
        log('warn', 'Failed to load task templates', { message: templateError.message });
      }

      const fallbackActions = [
        {
          title: 'Review your 12-month business plan',
          description: 'Confirm income targets and the activities needed for this week.',
          category: 'planning',
          priority: 'medium',
        },
        {
          title: 'Call 5 people from your sphere',
          description: 'Reach out to warm contacts and check in on current needs.',
          category: 'pipeline',
          priority: 'high',
        },
        {
          title: 'Post a market update on social media',
          description: 'Share a quick market snapshot for your primary territory.',
          category: 'marketing',
          priority: 'medium',
        },
        {
          title: 'Organize today’s follow-ups in your CRM',
          description: 'Clean up tasks and schedule the next steps for active leads.',
          category: 'systems',
          priority: 'medium',
        },
        {
          title: 'Send a handwritten thank-you note',
          description: 'Surprise a recent client or referral partner with a personal note.',
          category: 'database',
          priority: 'low',
        },
      ];

      const source = templates && templates.length > 0 ? templates : fallbackActions;

      return source.slice(0, templateLimit).map((task, index) => {
        const dueDate = new Date(now);
        dueDate.setDate(now.getDate() + index);
        return {
          title: task.title ?? fallbackActions[index]?.title ?? 'Daily Focus Task',
          description: task.description ?? fallbackActions[index]?.description ?? '',
          category: task.category ?? fallbackActions[index]?.category ?? 'planning',
          priority: task.priority ?? fallbackActions[index]?.priority ?? 'medium',
          status: 'pending',
          due_date: formatDate(dueDate),
          duration_minutes: 30,
        };
      });
    });

    await ensureSingleRecord('pulse_scores', () => ({
      date: formatDate(now),
      overall_score: 55,
      production_score: 50,
      pipeline_score: 52,
      activities_score: 58,
      systems_score: 54,
      mindset_score: 60,
      metrics: {
        tasks_due_today: insertedDailyActions > 0 ? insertedDailyActions : 3,
        tasks_completed_today: 0,
        weekly_conversations: 0,
        new_leads: 0,
      },
    }));

    await ensureSingleRecord('agent_config', () => ({
      agent_type: 'executive_assistant',
      response_style: 'professional',
      personality_traits: ['organized', 'proactive', 'detail_oriented'],
      enabled: true,
    }));

    await ensureSingleRecord('user_agent_subscription', () => ({
      agent_type: 'executive_assistant',
      subscription_tier: 'starter',
      is_active: true,
    }));

    log('log', 'Seeding complete', { userId, seededTables });

    return withCors(200, { success: true, seededTables });
  } catch (error) {
    if (error instanceof HttpError) {
      return withCors(error.status, { error: error.message });
    }

    log('error', 'Unexpected failure', { error: error instanceof Error ? error.message : String(error) });
    return withCors(500, { error: 'Internal server error' });
  }
});
