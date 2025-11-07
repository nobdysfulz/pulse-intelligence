'use client';

import React, { useState, useEffect, useContext } from 'react';
import { UserContext } from '@/components/context/UserContext';
import { useRouter, useSearchParams } from 'next/navigation';
import { createPageUrl } from '@/utils';
import TierAwareOnboarding from '@/components/onboarding/TierAwareOnboarding';
import LoadingIndicator from '@/components/ui/LoadingIndicator';

export default function OnboardingPage() {
  const { user, onboarding, userAgentSubscription, loading } = useContext(UserContext);
  const [activePhase, setActivePhase] = useState<string | null>(null);
  const router = useRouter();
  const searchParams = useSearchParams();

  useEffect(() => {
    if (loading || !user) return;

    // Check URL params for explicit phase
    const phaseParam = searchParams.get('phase');

    if (phaseParam) {
      setActivePhase(phaseParam);
      return;
    }

    // Auto-detect which phase is needed
    const isSubscriber = user.subscriptionTier === 'Subscriber' || user.subscriptionTier === 'Admin';
    const hasCallCenter = userAgentSubscription && userAgentSubscription.status === 'active';

    if (!onboarding?.onboardingCompleted) {
      setActivePhase('core');
    } else if (isSubscriber && !onboarding?.agentOnboardingCompleted) {
      setActivePhase('agents');
    } else if (hasCallCenter && !onboarding?.callCenterOnboardingCompleted) {
      setActivePhase('callcenter');
    } else {
      // All onboarding complete, redirect to dashboard
      router.push(createPageUrl('Dashboard'));
    }
  }, [user, onboarding, userAgentSubscription, loading, router, searchParams]);

  if (loading || !activePhase) {
    return (
      <div className="flex items-center justify-center min-h-screen bg-[#F8FAFC]">
        <LoadingIndicator text="Loading onboarding..." size="lg" />
      </div>
    );
  }

  return <TierAwareOnboarding initialPhase={activePhase} />;
}
