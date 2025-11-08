/**
 * Helper utilities for calling Supabase Edge Functions with Clerk authentication
 *
 * This wrapper automatically adds the x-clerk-auth header to bypass Supabase's
 * built-in JWT validation, allowing our custom Clerk JWT validation to work.
 */

import { supabase } from '@/integrations/supabase/client';
import { useAuth } from '@clerk/nextjs';

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

  // Merge custom headers with auth header
  const headers = {
    'x-clerk-auth': token,
    ...options.headers,
  };

  console.log(`[invokeWithAuth] Calling ${functionName} with Clerk auth`);

  // Call the function with auth header
  const result = await supabase.functions.invoke(functionName, {
    ...options,
    headers,
  });

  if (result.error) {
    console.error(`[invokeWithAuth] ${functionName} error:`, result.error);
  }

  return result;
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

    // Merge custom headers with auth header
    const headers = {
      'x-clerk-auth': token,
      ...options.headers,
    };

    console.log(`[useInvokeFunction] Calling ${functionName} with Clerk auth`);

    // Call the function with auth header
    const result = await supabase.functions.invoke(functionName, {
      ...options,
      headers,
    });

    if (result.error) {
      console.error(`[useInvokeFunction] ${functionName} error:`, result.error);
    }

    return result;
  };
}
