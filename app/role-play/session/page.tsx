"use client";

import React, { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import RolePlaySession from '@/components/roleplay/RolePlaySession';

export default function RolePlaySessionPage() {
  const router = useRouter();
  const [scenario, setScenario] = useState<any>(null);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    // Try to get scenario from sessionStorage
    const storedScenario = sessionStorage.getItem('roleplay-scenario');

    if (storedScenario) {
      try {
        const parsedScenario = JSON.parse(storedScenario);
        setScenario(parsedScenario);
        setIsLoading(false);
      } catch (error) {
        console.error('Failed to parse scenario from sessionStorage:', error);
        router.push('/role-play');
      }
    } else {
      // If no scenario in storage, redirect back to role play page
      router.push('/role-play');
    }
  }, [router]);

  if (isLoading || !scenario) {
    return (
      <div className="flex items-center justify-center h-screen bg-slate-50">
        <div className="w-8 h-8 border-4 border-purple-600 border-t-transparent rounded-full animate-spin"></div>
      </div>
    );
  }

  return <RolePlaySession />;
}
