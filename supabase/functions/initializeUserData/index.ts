import 'https://deno.land/x/xhr@0.1.0/mod.ts';
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.45.4';
import { validateClerkTokenWithJose } from '../_shared/clerkAuth.ts';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

const formatDate = (date: Date) => date.toISOString().split('T')[0];

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response(null, { headers: corsHeaders });
  }

  try {
    const SUPABASE_URL = Deno.env.get('SUPABASE_URL');
    const SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');

    if (!SUPABASE_URL || !SERVICE_ROLE_KEY) {
      throw new Error('Missing required environment variables');
    }

    const authHeader = req.headers.get('Authorization');
    if (!authHeader?.startsWith('Bearer ')) {
      return new Response(
        JSON.stringify({ error: 'Missing or invalid Authorization header' }),
        { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    const token = authHeader.substring(7);

    let userId: string;
    try {
      userId = await validateClerkTokenWithJose(token);
    } catch (error) {
      console.error('[initializeUserData] JWT validation failed:', error);
      return new Response(
        JSON.stringify({ error: 'Invalid or expired JWT token' }),
        { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    const supabaseAdmin = createClient(SUPABASE_URL, SERVICE_ROLE_KEY);
    const seededTables: string[] = [];
    const now = new Date();

    const ensureSingleRecord = async (
      table: string,
      builder: () => Promise<Record<string, unknown> | null | undefined> | Record<string, unknown> | null | undefined,
    ) => {
      const { data, error } = await supabaseAdmin.from(table).select('id').eq('user_id', userId).limit(1);
      if (error) {
        throw new Error(`[${table}] select failed: ${error.message}`);
      }

      if (data && data.length > 0) {
        return false;
      }

      const payload = await builder();
      if (!payload) {
        return false;
      }

      const { error: insertError } = await supabaseAdmin
        .from(table)
        .insert({ user_id: userId, ...payload });

      if (insertError) {
        throw new Error(`[${table}] insert failed: ${insertError.message}`);
      }

      seededTables.push(table);
      return true;
    };

    const ensureMultipleRecords = async (
      table: string,
      builder: () => Promise<Record<string, unknown>[] | null | undefined> | Record<string, unknown>[] | null | undefined,
    ) => {
      const { data, error } = await supabaseAdmin.from(table).select('id').eq('user_id', userId).limit(1);
      if (error) {
        throw new Error(`[${table}] select failed: ${error.message}`);
      }

      if (data && data.length > 0) {
        return 0;
      }

      const payload = await builder();
      if (!payload || payload.length === 0) {
        return 0;
      }

      const normalized = payload.map((item) => ({
        user_id: userId,
        ...item,
      }));

      const { error: insertError } = await supabaseAdmin.from(table).insert(normalized);
      if (insertError) {
        throw new Error(`[${table}] insert failed: ${insertError.message}`);
      }

      seededTables.push(table);
      return normalized.length;
    };

    // Ensure a baseline business plan exists
    await ensureSingleRecord('business_plans', () => {
      const monthlyBreakdown = Array.from({ length: 12 }).reduce((acc, _, index) => {
        const month = (index + 1).toString().padStart(2, '0');
        acc[month] = {
          conversations: 80,
          appointments: 12,
          closings: 2,
        };
        return acc;
      }, {} as Record<string, unknown>);

      return {
        annual_gci_goal: 150000,
        transactions_needed: 24,
        average_commission: 7500,
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
        target_value: 150000,
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
    let insertedDailyActions = 0;

    insertedDailyActions = await ensureMultipleRecords('daily_actions', async () => {
      const { data: templates, error: templateError } = await supabaseAdmin
        .from('task_templates')
        .select('title, description, category, priority')
        .eq('is_active', true)
        .order('priority_weight', { ascending: false })
        .limit(templateLimit);

      if (templateError) {
        console.warn('[initializeUserData] Failed to load task templates:', templateError.message);
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

      const tasksToUse = (templates && templates.length > 0 ? templates : fallbackActions).slice(0, templateLimit);

      return tasksToUse.map((task, index) => {
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

    await ensureSingleRecord('user_agent_subscriptions', () => ({
      agent_type: 'executive_assistant',
      subscription_tier: 'starter',
      is_active: true,
    }));

    console.log('[initializeUserData] Seeded tables:', seededTables);

    return new Response(
      JSON.stringify({
        success: true,
        seededTables,
      }),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );
  } catch (error) {
    console.error('[initializeUserData] Error:', error);
    return new Response(
      JSON.stringify({ error: error instanceof Error ? error.message : 'Internal server error' }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );
  }
});
