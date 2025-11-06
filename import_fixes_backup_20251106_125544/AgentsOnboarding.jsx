import React from 'react';
import AgentOnboardingFlow from '../components/agents/onboarding/AgentOnboardingFlow';
import { useRouter } from 'next/navigation';
import { createPageUrl } from '@/utils';

export default function AgentsOnboardingPage() {
  const navigate = useNavigate();

  const handleComplete = () => {
    navigate(createPageUrl('Agents'));
  };

  return <AgentOnboardingFlow onComplete={handleComplete} />;
}