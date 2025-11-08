import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
import { validateClerkTokenWithJose } from '../_shared/clerkAuth.ts';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

Deno.serve(async (req) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    console.log('[getUserContext] Handling CORS preflight');
    return new Response(null, {
      status: 204,
      headers: corsHeaders
    });
  }

  console.log('[getUserContext] === REQUEST START ===');
  console.log('[getUserContext] Method:', req.method);
  console.log('[getUserContext] URL:', req.url);

  try {
    // Step 1: Validate Authorization header
    const authHeader = req.headers.get('Authorization');
    console.log('[getUserContext] Auth header present:', !!authHeader);

    if (!authHeader?.startsWith('Bearer ')) {
      console.error('[getUserContext] Missing or invalid Authorization header');
      return new Response(
        JSON.stringify({
          error: 'Missing Authorization header',
          details: 'Please provide a valid Bearer token'
        }),
        {
          status: 401,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        }
      );
    }

    // Step 2: Extract and validate JWT token
    const token = authHeader.substring(7);
    console.log('[getUserContext] Token length:', token.length);
    console.log('[getUserContext] Token preview:', token.substring(0, 50) + '...');

    let userId: string;
    try {
      userId = await validateClerkTokenWithJose(token);
      console.log('[getUserContext] ✓ JWT validated successfully');
      console.log('[getUserContext] User ID:', userId);
    } catch (error) {
      console.error('[getUserContext] JWT validation failed:', error);
      return new Response(
        JSON.stringify({
          error: 'Invalid or expired JWT token',
          details: error instanceof Error ? error.message : 'Unknown error'
        }),
        {
          status: 401,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        }
      );
    }

    // Step 3: Connect to Supabase
    const supabaseUrl = Deno.env.get('SUPABASE_URL');
    const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');

    if (!supabaseUrl || !supabaseKey) {
      console.error('[getUserContext] Missing Supabase environment variables');
      return new Response(
        JSON.stringify({
          error: 'Server configuration error',
          details: 'Missing required environment variables'
        }),
        {
          status: 500,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        }
      );
    }

    console.log('[getUserContext] Connecting to Supabase:', supabaseUrl);
    const supabase = createClient(supabaseUrl, supabaseKey);

    // Step 4: Fetch all user data in parallel
    console.log('[getUserContext] Fetching user data for:', userId);

    const [
      profileResult,
      onboardingResult,
      marketConfigResult,
      preferencesResult,
      actionsResult,
      agentConfigResult,
      userAgentSubResult,
      goalsResult,
      businessPlanResult,
      pulseScoresResult,
      pulseConfigResult,
      agentIntelligenceResult,
    ] = await Promise.all([
      supabase.from('profiles').select('*').eq('id', userId).single(),
      supabase.from('user_onboarding').select('*').eq('user_id', userId).maybeSingle(),
      supabase.from('market_config').select('*').eq('user_id', userId).maybeSingle(),
      supabase.from('user_preferences').select('*').eq('user_id', userId).maybeSingle(),
      supabase.from('daily_actions').select('*').eq('user_id', userId).limit(50),
      supabase.from('agent_config').select('*').eq('userId', userId).maybeSingle(),
      supabase.from('user_agent_subscriptions').select('*').eq('userId', userId).maybeSingle(),
      supabase.from('goals').select('*').eq('user_id', userId),
      supabase.from('business_plans').select('*').eq('user_id', userId).maybeSingle(),
      supabase.from('pulse_scores').select('*').eq('user_id', userId).order('created_date', { ascending: false }).limit(1).maybeSingle(),
      supabase.from('pulse_config').select('*').eq('user_id', userId).maybeSingle(),
      supabase.from('agent_intelligence_profiles').select('*').eq('user_id', userId).maybeSingle(),
    ]);

    // Check for profile errors
    if (profileResult.error) {
      console.error('[getUserContext] Profile fetch error:', profileResult.error);
      return new Response(
        JSON.stringify({
          error: 'User profile not found',
          details: profileResult.error.message
        }),
        {
          status: 404,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        }
      );
    }

    console.log('[getUserContext] ✓ Profile loaded:', profileResult.data?.email);
    console.log('[getUserContext] ✓ Onboarding loaded:', !!onboardingResult.data);
    console.log('[getUserContext] ✓ Actions count:', actionsResult.data?.length || 0);

    // Step 5: Build response object
    const userContext = {
      profile: profileResult.data,
      onboarding: onboardingResult.data || null,
      marketConfig: marketConfigResult.data || null,
      preferences: preferencesResult.data || null,
      dailyActions: actionsResult.data || [],
      agentConfig: agentConfigResult.data || null,
      userAgentSubscription: userAgentSubResult.data || null,
      goals: goalsResult.data || [],
      businessPlan: businessPlanResult.data || null,
      latestPulseScore: pulseScoresResult.data || null,
      pulseConfig: pulseConfigResult.data || null,
      agentIntelligence: agentIntelligenceResult.data || null,
    };

    console.log('[getUserContext] ✓ User context built successfully');
    console.log('[getUserContext] === REQUEST END ===');

    return new Response(
      JSON.stringify(userContext),
      {
        status: 200,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      }
    );

  } catch (error) {
    console.error('[getUserContext] Unexpected error:', error);
    console.error('[getUserContext] Error stack:', error instanceof Error ? error.stack : 'No stack trace');

    return new Response(
      JSON.stringify({
        error: 'Internal server error',
        details: error instanceof Error ? error.message : 'Unknown error',
        timestamp: new Date().toISOString()
      }),
      {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      }
    );
  }
});
