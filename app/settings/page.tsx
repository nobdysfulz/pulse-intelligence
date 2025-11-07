"use client";

import React, { useState, useContext, useEffect } from 'react';
import dynamic from 'next/dynamic';
import { useSearchParams } from 'next/navigation';
import { UserContext } from '@/components/context/UserContext';
import LoadingIndicator from '@/components/ui/LoadingIndicator';
import SettingsSidebar from '@/components/settings/SettingsSidebar';
import SetupProgressTab from '@/components/settings/SetupProgressTab';
import IntegrationsTab from '@/components/settings/IntegrationsTab';
import ReferralTab from '@/components/settings/ReferralTab';
import AgentIntelligenceTab from '@/components/settings/AgentIntelligenceTab';
import ProfileTab from '@/components/settings/ProfileTab';
import MarketTab from '@/components/settings/MarketTab';
import NotificationsTab from '@/components/settings/NotificationsTab';
import PreferencesTab from '@/components/settings/PreferencesTab';
import SecurityTab from '@/components/settings/SecurityTab';
import { Card, CardContent } from '@/components/ui/card';

// Admin Components - dynamically imported to avoid SSR issues
const UserManagementTab = dynamic(() => import('@/components/settings/UserManagementTab'), { ssr: false });
const ManualSubscriptionManager = dynamic(() => import('@/components/settings/ManualSubscriptionManager'), { ssr: false });
const ContentTopicsManager = dynamic(() => import('@/components/settings/ContentTopicsManager'), { ssr: false });
const ContentPackManager = dynamic(() => import('@/components/settings/ContentPackManager'), { ssr: false });
const FeaturedContentPackManager = dynamic(() => import('@/components/settings/FeaturedContentPackManager'), { ssr: false });
const AiPromptManager = dynamic(() => import('@/components/settings/AiPromptManager'), { ssr: false });
const CampaignTemplateManager = dynamic(() => import('@/components/settings/CampaignTemplateManager'), { ssr: false });
const ScenarioManager = dynamic(() => import('@/components/settings/ScenarioManager'), { ssr: false });
const ClientPersonaManager = dynamic(() => import('@/components/settings/ClientPersonaManager'), { ssr: false });
const ObjectionScriptManager = dynamic(() => import('@/components/settings/ObjectionScriptManager'), { ssr: false });
const TaskTemplateManager = dynamic(() => import('@/components/settings/TaskTemplateManager'), { ssr: false });
const AgentVoiceManager = dynamic(() => import('@/components/settings/AgentVoiceManager'), { ssr: false });
const DisclosureManager = dynamic(() => import('@/components/settings/DisclosureManager'), { ssr: false });
const EmailCampaignManager = dynamic(() => import('@/components/settings/EmailCampaignManager'), { ssr: false });
const SystemMonitoringDashboard = dynamic(() => import('@/components/settings/SystemMonitoringDashboard'), { ssr: false });
const SystemErrorsManager = dynamic(() => import('@/components/settings/SystemErrorsManager'), { ssr: false });
const FeatureFlagsManager = dynamic(() => import('@/components/settings/FeatureFlagsManager'), { ssr: false });
const IntegrationHealthMonitor = dynamic(() => import('@/components/settings/IntegrationHealthMonitor'), { ssr: false });
const AutopilotMonitoring = dynamic(() => import('@/components/settings/AutopilotMonitoring'), { ssr: false });
const DataImportManager = dynamic(() => import('@/components/settings/DataImportManager'), { ssr: false });

export default function SettingsPage() {
  const { user, loading } = useContext(UserContext);
  const searchParams = useSearchParams();
  const tabFromUrl = searchParams?.get('tab');
  const [activeTab, setActiveTab] = useState(tabFromUrl || 'account');

  useEffect(() => {
    const tabParam = searchParams?.get('tab');
    if (tabParam && tabParam !== activeTab) {
      setActiveTab(tabParam);
    }
  }, [searchParams, activeTab]);

  const renderContent = () => {
    // Regular Settings Tabs
    switch (activeTab) {
      case 'setup-progress':
        return <SetupProgressTab />;
      case 'account':
        return <ProfileTab />;
      case 'market':
        return <MarketTab />;
      case 'agent-intelligence':
        return <AgentIntelligenceTab />;
      case 'integrations':
        return <IntegrationsTab user={user} onUpdate={() => {}} />;
      case 'notifications':
        return <NotificationsTab />;
      case 'preferences':
        return <PreferencesTab />;
      case 'referrals':
        return <ReferralTab user={user} />;
      case 'security':
        return <SecurityTab />;
      
      // Admin Tabs
      case 'data-import':
        return user?.role === 'admin' ? <DataImportManager /> : <AccessDenied />;
      case 'admin-users':
        return user?.role === 'admin' ? <UserManagementTab /> : <AccessDenied />;
      case 'admin-subscriptions':
        return user?.role === 'admin' ? <ManualSubscriptionManager /> : <AccessDenied />;
      case 'admin-content':
        return user?.role === 'admin' ? <ContentTopicsManager /> : <AccessDenied />;
      case 'admin-packs':
        return user?.role === 'admin' ? <ContentPackManager /> : <AccessDenied />;
      case 'admin-featured':
        return user?.role === 'admin' ? <FeaturedContentPackManager /> : <AccessDenied />;
      case 'admin-prompts':
        return user?.role === 'admin' ? <AiPromptManager /> : <AccessDenied />;
      case 'admin-campaigns':
        return user?.role === 'admin' ? <CampaignTemplateManager /> : <AccessDenied />;
      case 'admin-scenarios':
        return user?.role === 'admin' ? <ScenarioManager /> : <AccessDenied />;
      case 'admin-personas':
        return user?.role === 'admin' ? <ClientPersonaManager /> : <AccessDenied />;
      case 'admin-scripts':
        return user?.role === 'admin' ? <ObjectionScriptManager /> : <AccessDenied />;
      case 'admin-tasks':
        return user?.role === 'admin' ? <TaskTemplateManager /> : <AccessDenied />; // Updated component
      case 'admin-voices':
        return user?.role === 'admin' ? <AgentVoiceManager /> : <AccessDenied />;
      case 'admin-disclosures':
        return user?.role === 'admin' ? <DisclosureManager /> : <AccessDenied />;
      
      // NEW Admin Tabs
      case 'admin-emails':
        return user?.role === 'admin' ? <EmailCampaignManager /> : <AccessDenied />;
      case 'admin-monitoring':
        return user?.role === 'admin' ? <SystemMonitoringDashboard /> : <AccessDenied />;
      case 'admin-errors':
        return user?.role === 'admin' ? <SystemErrorsManager /> : <AccessDenied />;
      case 'admin-flags':
        return user?.role === 'admin' ? <FeatureFlagsManager /> : <AccessDenied />;
      case 'admin-integrations':
        return user?.role === 'admin' ? <IntegrationHealthMonitor /> : <AccessDenied />;
      case 'admin-autopilot': // New case for Autopilot Monitoring
        return user?.role === 'admin' ? <AutopilotMonitoring /> : <AccessDenied />;
      
      default:
        return <ProfileTab />;
    }
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center h-screen bg-[#F8FAFC]">
        <LoadingIndicator text="Loading Settings..." size="lg" />
      </div>
    );
  }

  return (
    <div className="flex h-screen overflow-hidden">
      <SettingsSidebar activeTab={activeTab} onTabChange={setActiveTab} />
      <main className="flex-1 overflow-y-auto bg-[#F8FAFC] p-8">
        <div className="max-w-4xl mx-auto">
          {renderContent()}
        </div>
      </main>
    </div>
  );
}

function AccessDenied() {
  return (
    <Card className="bg-white border border-[#E2E8F0]">
      <CardContent className="p-12 text-center">
        <h3 className="text-lg font-semibold text-[#1E293B] mb-2">Access Denied</h3>
        <p className="text-sm text-[#475569]">You don't have permission to access this section</p>
      </CardContent>
    </Card>
  );
}
