"use client";

import React, { useState, useEffect, useCallback, useMemo } from 'react';
import { UserContext } from './UserContext';
import { useUser, useAuth } from '@clerk/clerk-react';
import { useInvokeFunction } from '@/lib/supabase-functions';

// Set global token getter for entities.js
if (typeof window !== 'undefined') {
  window.__clerkGetToken = null;
}

export default function UserProvider({ children }) {
  const invokeFunction = useInvokeFunction();
    const { user: clerkUser, isLoaded: isClerkLoaded } = useUser();
    const { getToken } = useAuth();
    const [user, setUser] = useState(null);
    const [marketConfig, setMarketConfig] = useState(null);
    const [agentProfile, setAgentProfile] = useState(null);
    const [preferences, setPreferences] = useState(null);
    const [onboarding, setOnboarding] = useState(null);
    const [actions, setActions] = useState([]);
    const [agentConfig, setAgentConfig] = useState(null);
    const [userAgentSubscription, setUserAgentSubscription] = useState(null);
    const [goals, setGoals] = useState([]);
    const [businessPlan, setBusinessPlan] = useState(null);
    const [pulseHistory, setPulseHistory] = useState([]);
    const [pulseConfig, setPulseConfig] = useState(null);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);
    const [isSupportChatOpen, setSupportChatOpen] = useState(false);

    const fetchUserData = useCallback(async () => {
        if (!isClerkLoaded || !clerkUser) {
            setLoading(false);
            return;
        }

        console.log('[UserProvider] Starting fetchUserData');
        console.log('[UserProvider] Supabase URL:', process.env.NEXT_PUBLIC_SUPABASE_URL);
        console.log('[UserProvider] Supabase Anon Key (first 20 chars):', process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY?.substring(0, 20));
        setLoading(true);
        setError(null);

        // Set a safety timeout to prevent infinite loading
        const timeoutId = setTimeout(() => {
            console.error('[UserProvider] TIMEOUT: Function call exceeded 15 seconds');
            setError('Request timeout. Please check your connection and refresh the page.');
            setLoading(false);
        }, 15000);

        try {
            console.log('[UserProvider] Calling backend functions...');

            try {
                console.log('[UserProvider] Ensuring user defaults exist...');
                const initResult = await Promise.race([
                    invokeFunction('initializeUserData', {
                        body: {},
                    }),
                    new Promise((_, reject) => setTimeout(() => reject(new Error('initializeUserData timeout')), 10000))
                ]);
                console.log('[UserProvider] initializeUserData result:', initResult);
            } catch (seedError) {
                console.warn('[UserProvider] initializeUserData failed (continuing):', seedError);
            }

            // Call backend function to get all user data at once with timeout
            console.log('[UserProvider] Calling getUserContext...');
            let context, contextError;

            try {
                const result = await Promise.race([
                    invokeFunction('getUserContext'),
                    new Promise((_, reject) =>
                        setTimeout(() => reject(new Error('getUserContext timeout after 10 seconds')), 10000)
                    )
                ]);

                context = result.data;
                contextError = result.error;
                console.log('[UserProvider] getUserContext completed:', { hasData: !!context, hasError: !!contextError });
            } catch (timeoutError) {
                console.error('[UserProvider] getUserContext timed out:', timeoutError);
                throw new Error('Failed to load user data: Request timed out. Please check your connection.');
            }

            if (contextError) {
                console.error('[UserProvider] getUserContext error:', contextError);
                
                // Check if it's an authentication error
                if (contextError.message?.includes('401') || contextError.message?.includes('Token') || contextError.message?.includes('expired')) {
                    // Try to refresh the token and retry once
                    console.log('[UserProvider] Attempting to refresh token...');
                    try {
                        const newToken = await getToken({ skipCache: true });

                        if (newToken) {
                            console.log('[UserProvider] Retrying with refreshed token...');

                            try {
                                console.log('[UserProvider] Re-running initializeUserData with fresh token...');
                                await invokeFunction('initializeUserData', {
                                    body: {},
                                });
                            } catch (seedRetryError) {
                                console.warn('[UserProvider] initializeUserData retry failed (continuing):', seedRetryError);
                            }

                            // Retry with fresh token (useInvokeFunction will get the refreshed token from Clerk)
                            const { data: retryContext, error: retryError } = await invokeFunction('getUserContext');
                            
                            if (!retryError && retryContext) {
                                console.log('[UserProvider] Retry successful with fresh token');
                                // Set context and skip the error throw
                                setUser(retryContext.profile);
                                setOnboarding(retryContext.onboarding || {
                                    userId: clerkUser.id,
                                    onboardingCompleted: false,
                                    agentOnboardingCompleted: false,
                                    agentIntelligenceCompleted: false,
                                    completedSteps: []
                                });
                                setMarketConfig(retryContext.marketConfig);
                                setAgentProfile(retryContext.agentIntelligence);
                                setPreferences(retryContext.preferences || {
                                    userId: clerkUser.id,
                                    coachingStyle: 'balanced',
                                    activityMode: 'get_moving',
                                    dailyReminders: true,
                                    weeklyReports: true,
                                    marketUpdates: true,
                                    emailNotifications: true,
                                    timezone: 'America/New_York'
                                });
                                setActions(retryContext.dailyActions || []);
                                setAgentConfig(retryContext.agentConfig);
                                setUserAgentSubscription(retryContext.userAgentSubscription);
                                setGoals(retryContext.goals || []);
                                setBusinessPlan(retryContext.businessPlan);
                                setPulseHistory(retryContext.latestPulseScore ? [retryContext.latestPulseScore] : []);
                                setPulseConfig(retryContext.pulseConfig);
                                setLoading(false);
                                return; // Exit successfully
                            }
                        }
                    } catch (retryErr) {
                        console.error('[UserProvider] Token refresh/retry failed:', retryErr);
                    }
                }
                
                throw new Error('Failed to load user context: ' + (contextError.message || 'Unknown error'));
            }

            if (!context) {
                throw new Error('No context data returned from backend');
            }

            console.log('[UserProvider] Context loaded successfully from backend');
            console.log('[UserProvider] Profile data:', context.profile);

            // Set all state from backend response
            setUser(context.profile);
            setOnboarding(context.onboarding || {
                userId: clerkUser.id,
                onboardingCompleted: false,
                agentOnboardingCompleted: false,
                agentIntelligenceCompleted: false,
                completedSteps: []
            });
            setMarketConfig(context.marketConfig);
            setAgentProfile(context.agentIntelligence);
            setPreferences(context.preferences || {
                userId: clerkUser.id,
                coachingStyle: 'balanced',
                activityMode: 'get_moving',
                dailyReminders: true,
                weeklyReports: true,
                marketUpdates: true,
                emailNotifications: true,
                timezone: 'America/New_York'
            });
            setActions(context.dailyActions || []);
            setAgentConfig(context.agentConfig);
            setUserAgentSubscription(context.userAgentSubscription);
            setGoals(context.goals || []);
            setBusinessPlan(context.businessPlan);
            setPulseHistory(context.latestPulseScore ? [context.latestPulseScore] : []);
            setPulseConfig(context.pulseConfig);

            console.log('[UserProvider] All context data set successfully');

        } catch (err) {
            console.error("[UserProvider] Critical error in fetchUserData:", err);
            console.error("[UserProvider] Error details:", {
                message: err.message,
                stack: err.stack,
                name: err.name
            });
            setError("Unable to load your data. Please refresh the page or contact support if the issue persists.");
        } finally {
            clearTimeout(timeoutId);
            setLoading(false);
            console.log('[UserProvider] fetchUserData completed, loading set to false');
        }
    }, [clerkUser, isClerkLoaded, getToken]);

    useEffect(() => {
        // Set global token getter for entities.js
        if (typeof window !== 'undefined') {
            window.__clerkGetToken = getToken;
        }
        
        fetchUserData();
    }, [fetchUserData, getToken]);

    const contextValue = useMemo(() => ({
        user,
        marketConfig,
        agentProfile,
        preferences,
        onboarding,
        actions,
        agentConfig,
        userAgentSubscription,
        goals,
        businessPlan,
        pulseHistory,
        pulseConfig,
        loading,
        error,
        refreshUserData: fetchUserData,
        isSupportChatOpen,
        setSupportChatOpen
    }), [
        user, marketConfig, agentProfile, preferences, onboarding, actions,
        agentConfig, userAgentSubscription, goals, businessPlan, pulseHistory,
        pulseConfig, loading, error, fetchUserData, isSupportChatOpen, setSupportChatOpen
    ]);

    if (error && !loading) {
        return (
            <div className="min-h-screen bg-[#F8FAFC] flex items-center justify-center p-4">
                <div className="max-w-md w-full bg-white rounded-lg shadow-lg p-8 text-center">
                    <div className="w-16 h-16 bg-red-100 rounded-full flex items-center justify-center mx-auto mb-4">
                        <svg className="w-8 h-8 text-red-600" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
                        </svg>
                    </div>
                    <h2 className="text-xl font-semibold text-[#1E293B] mb-2">Connection Error</h2>
                    <p className="text-sm text-[#64748B] mb-6">{error}</p>
                    <div className="space-y-3">
                        <button
                            onClick={() => window.location.reload()}
                            className="w-full bg-[#6D28D9] hover:bg-[#5B21B6] text-white px-4 py-2 rounded-lg font-medium transition-colors"
                        >
                            Refresh Page
                        </button>
                        <button
                            onClick={() => window.open('mailto:support@pwru.app', '_blank')}
                            className="w-full border border-[#E2E8F0] hover:bg-[#F8FAFC] text-[#64748B] px-4 py-2 rounded-lg font-medium transition-colors"
                        >
                            Contact Support
                        </button>
                    </div>
                </div>
            </div>
        );
    }

    return (
        <UserContext.Provider value={contextValue}>
            {children}
        </UserContext.Provider>
    );
}
