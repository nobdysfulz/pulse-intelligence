import React from 'react';
import AgentOnboardingFlow from '../../src/components/agents/onboarding/AgentOnboardingFlow';
import { useRouter } from 'next/navigation';
import { createPageUrl } from '@/utils';

export default function AgentsOnboardingPage() {
  const navigate = useRouter();

  const handleComplete = () => {
    navigate(createPageUrl('Agents'));
  };

  return <AgentOnboardingFlow onComplete={handleComplete} />;
}
