/**
 * Helper utilities for calling Supabase Edge Functions with Clerk authentication
 *
 * This wrapper automatically adds the x-clerk-auth header to bypass Supabase's
 * built-in JWT validation, allowing our custom Clerk JWT validation to work.
 */

import { useAuth } from '@clerk/nextjs';

const SUPABASE_URL = process.env.NEXT_PUBLIC_SUPABASE_URL;

/**
 * Invoke a Supabase Edge Function with automatic Clerk token authentication
 *
 * @param functionName - Name of the Edge Function to call
 * @param options - Function invocation options (body, etc.)
 * @returns Promise with function response
 *
 * @example
 * const { data, error } = await invokeFunction('saveOnboardingProgress', {
 *   body: { progressData: {...} }
 * });
 */
export async function invokeWithAuth(
  functionName: string,
  options: {
    body?: any;
    headers?: Record<string, string>;
  } = {}
) {
  // Get the Clerk token from the current session
  // This will be called from React components that have access to useAuth()
  const token = await (window as any).__clerkToken;

  if (!token) {
    console.error('[invokeWithAuth] No Clerk token available');
    throw new Error('Authentication token not available. Please sign in.');
  }

  // Get Supabase anon key from environment
  const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY;

  if (!supabaseAnonKey) {
    console.error('[invokeWithAuth] Missing NEXT_PUBLIC_SUPABASE_ANON_KEY');
    throw new Error('Supabase configuration error');
  }

  // Merge custom headers with auth header and apikey
  // The apikey header is required by Supabase even with verify_jwt=false
  const headers = {
    'apikey': supabaseAnonKey,
    'Authorization': `Bearer ${supabaseAnonKey}`,
    'x-clerk-auth': token,
    'Content-Type': 'application/json',
    ...options.headers,
  };

  console.log(`[invokeWithAuth] Calling ${functionName} with Clerk auth`);

  try {
    // Use direct fetch instead of supabase.functions.invoke
    const response = await fetch(`${SUPABASE_URL}/functions/v1/${functionName}`, {
      method: 'POST',
      headers,
      body: options.body ? JSON.stringify(options.body) : undefined,
    });

    const data = await response.json();

    if (!response.ok) {
      console.error(`[invokeWithAuth] ${functionName} error:`, data);
      return { data: null, error: data };
    }

    return { data, error: null };
  } catch (error) {
    console.error(`[invokeWithAuth] ${functionName} fetch error:`, error);
    return { data: null, error };
  }
}

/**
 * React hook to get a function that invokes Edge Functions with auth
 * Use this in React components to automatically include Clerk token
 *
 * @example
 * const invokeFunction = useInvokeFunction();
 * const { data, error } = await invokeFunction('saveOnboardingProgress', {
 *   body: { progressData: {...} }
 * });
 */
export function useInvokeFunction() {
  const { getToken } = useAuth();

  return async (
    functionName: string,
    options: {
      body?: any;
      headers?: Record<string, string>;
    } = {}
  ) => {
    // Get fresh token from Clerk
    const token = await getToken();

    if (!token) {
      console.error('[useInvokeFunction] No Clerk token available');
      throw new Error('Authentication token not available. Please sign in.');
    }

    // Get Supabase anon key from environment
    const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY;

    if (!supabaseAnonKey) {
      console.error('[useInvokeFunction] Missing NEXT_PUBLIC_SUPABASE_ANON_KEY');
      throw new Error('Supabase configuration error');
    }

    // Merge custom headers with auth header and apikey
    // The apikey header is required by Supabase even with verify_jwt=false
    const headers = {
      'apikey': supabaseAnonKey,
      'Authorization': `Bearer ${supabaseAnonKey}`,
      'x-clerk-auth': token,
      'Content-Type': 'application/json',
      ...options.headers,
    };

    console.log(`[useInvokeFunction] Calling ${functionName} with Clerk auth`);

    try {
      // Use direct fetch instead of supabase.functions.invoke
      const response = await fetch(`${SUPABASE_URL}/functions/v1/${functionName}`, {
        method: 'POST',
        headers,
        body: options.body ? JSON.stringify(options.body) : undefined,
      });

      const data = await response.json();

      if (!response.ok) {
        console.error(`[useInvokeFunction] ${functionName} error:`, data);
        return { data: null, error: data };
      }

      return { data, error: null };
    } catch (error) {
      console.error(`[useInvokeFunction] ${functionName} fetch error:`, error);
      return { data: null, error };
    }
  };
}
