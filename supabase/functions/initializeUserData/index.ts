import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
import { validateClerkTokenWithJose } from '../_shared/clerkAuth.ts';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

const formatDate = (date: Date) => date.toISOString().split('T')[0];

Deno.serve(async (req) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    console.log('[initializeUserData] Handling CORS preflight');
    return new Response(null, {
      status: 204,
      headers: corsHeaders
    });
  }

  console.log('[initializeUserData] === REQUEST START ===');
  console.log('[initializeUserData] Method:', req.method);
  console.log('[initializeUserData] URL:', req.url);

  try {
    // Step 1: Get environment variables
    const supabaseUrl = Deno.env.get('SUPABASE_URL');
    const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');

    if (!supabaseUrl || !serviceRoleKey) {
      console.error('[initializeUserData] Missing Supabase environment variables');
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

    // Step 2: Validate Authorization header
    const authHeader = req.headers.get('Authorization');
    console.log('[initializeUserData] Auth header present:', !!authHeader);

    if (!authHeader?.startsWith('Bearer ')) {
      console.error('[initializeUserData] Missing or invalid Authorization header');
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

    // Step 3: Validate JWT token
    const token = authHeader.substring(7);
    console.log('[initializeUserData] Token length:', token.length);

    let userId: string;
    try {
      userId = await validateClerkTokenWithJose(token);
      console.log('[initializeUserData] ✓ JWT validated successfully');
      console.log('[initializeUserData] User ID:', userId);
    } catch (error) {
      console.error('[initializeUserData] JWT validation failed:', error);
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

    // Step 4: Connect to Supabase
    console.log('[initializeUserData] Connecting to Supabase:', supabaseUrl);
    const supabase = createClient(supabaseUrl, serviceRoleKey);

    const seededTables: string[] = [];
    const now = new Date();

    // Step 5: Initialize user_onboarding
    console.log('[initializeUserData] Checking user_onboarding...');
    const { data: existingOnboarding } = await supabase
      .from('user_onboarding')
      .select('*')
      .eq('user_id', userId)
      .maybeSingle();

    if (!existingOnboarding) {
      console.log('[initializeUserData] Creating user_onboarding record');
      const { error } = await supabase.from('user_onboarding').insert({
        user_id: userId,
        current_step: 0,
        completed_steps: [],
        is_complete: false,
        created_date: now.toISOString(),
        updated_date: now.toISOString(),
      });

      if (error) {
        console.error('[initializeUserData] Error creating onboarding:', error);
      } else {
        seededTables.push('user_onboarding');
        console.log('[initializeUserData] ✓ user_onboarding created');
      }
    } else {
      console.log('[initializeUserData] ✓ user_onboarding exists');
    }

    // Step 6: Initialize market_config
    console.log('[initializeUserData] Checking market_config...');
    const { data: existingMarketConfig } = await supabase
      .from('market_config')
      .select('*')
      .eq('user_id', userId)
      .maybeSingle();

    if (!existingMarketConfig) {
      console.log('[initializeUserData] Creating market_config record');
      const { error } = await supabase.from('market_config').insert({
        user_id: userId,
        city: null,
        state: null,
        zip_code: null,
        county: null,
        msa: null,
        region: null,
        created_date: now.toISOString(),
        updated_date: now.toISOString(),
      });

      if (error) {
        console.error('[initializeUserData] Error creating market_config:', error);
      } else {
        seededTables.push('market_config');
        console.log('[initializeUserData] ✓ market_config created');
      }
    } else {
      console.log('[initializeUserData] ✓ market_config exists');
    }

    // Step 7: Initialize user_preferences
    console.log('[initializeUserData] Checking user_preferences...');
    const { data: existingPreferences } = await supabase
      .from('user_preferences')
      .select('*')
      .eq('user_id', userId)
      .maybeSingle();

    if (!existingPreferences) {
      console.log('[initializeUserData] Creating user_preferences record');
      const { error } = await supabase.from('user_preferences').insert({
        user_id: userId,
        email_notifications: true,
        sms_notifications: false,
        push_notifications: true,
        weekly_digest: true,
        market_updates: true,
        created_date: now.toISOString(),
        updated_date: now.toISOString(),
      });

      if (error) {
        console.error('[initializeUserData] Error creating preferences:', error);
      } else {
        seededTables.push('user_preferences');
        console.log('[initializeUserData] ✓ user_preferences created');
      }
    } else {
      console.log('[initializeUserData] ✓ user_preferences exists');
    }

    // Step 8: Initialize pulse_config
    console.log('[initializeUserData] Checking pulse_config...');
    const { data: existingPulseConfig } = await supabase
      .from('pulse_config')
      .select('*')
      .eq('user_id', userId)
      .maybeSingle();

    if (!existingPulseConfig) {
      console.log('[initializeUserData] Creating pulse_config record');
      const { error } = await supabase.from('pulse_config').insert({
        user_id: userId,
        weight_prospecting: 0.25,
        weight_listing: 0.25,
        weight_transaction: 0.25,
        weight_relationship: 0.25,
        created_date: now.toISOString(),
        updated_date: now.toISOString(),
      });

      if (error) {
        console.error('[initializeUserData] Error creating pulse_config:', error);
      } else {
        seededTables.push('pulse_config');
        console.log('[initializeUserData] ✓ pulse_config created');
      }
    } else {
      console.log('[initializeUserData] ✓ pulse_config exists');
    }

    // Step 9: Initialize business_plans
    console.log('[initializeUserData] Checking business_plans...');
    const { data: existingBusinessPlan } = await supabase
      .from('business_plans')
      .select('*')
      .eq('user_id', userId)
      .maybeSingle();

    if (!existingBusinessPlan) {
      console.log('[initializeUserData] Creating business_plan record');
      const currentYear = now.getFullYear();
      const { error } = await supabase.from('business_plans').insert({
        user_id: userId,
        plan_year: currentYear,
        annual_gci_goal: 100000,
        annual_transaction_goal: 12,
        listing_goal: 6,
        buyer_goal: 6,
        created_date: now.toISOString(),
        updated_date: now.toISOString(),
      });

      if (error) {
        console.error('[initializeUserData] Error creating business_plan:', error);
      } else {
        seededTables.push('business_plans');
        console.log('[initializeUserData] ✓ business_plan created');
      }
    } else {
      console.log('[initializeUserData] ✓ business_plan exists');
    }

    console.log('[initializeUserData] ✓ Initialization complete');
    console.log('[initializeUserData] Seeded tables:', seededTables);
    console.log('[initializeUserData] === REQUEST END ===');

    return new Response(
      JSON.stringify({
        success: true,
        seededTables,
        message: `Initialized ${seededTables.length} default records`
      }),
      {
        status: 200,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      }
    );

  } catch (error) {
    console.error('[initializeUserData] Unexpected error:', error);
    console.error('[initializeUserData] Error stack:', error instanceof Error ? error.stack : 'No stack trace');

    return new Response(
      JSON.stringify({
        success: false,
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
