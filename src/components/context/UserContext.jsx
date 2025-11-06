"use client";

import { createContext, useContext, useState, useEffect } from 'react';

export const UserContext = createContext({
    user: null,
    marketConfig: null,
    agentProfile: null,
    preferences: null,
    onboarding: null,
    actions: [],
    agentConfig: null,
    userAgentSubscription: null,
    goals: [],
    businessPlan: null,
    pulseHistory: [],
    pulseConfig: null,
    loading: true,
    error: null,
    refreshUserData: () => {},
    isSupportChatOpen: false,
    setSupportChatOpen: () => {},
});

export const UserProvider = ({ children }) => {
  const [userState, setUserState] = useState({
    user: null,
    marketConfig: null,
    agentProfile: null,
    preferences: null,
    onboarding: null,
    actions: [],
    agentConfig: null,
    userAgentSubscription: null,
    goals: [],
    businessPlan: null,
    pulseHistory: [],
    pulseConfig: null,
    loading: true,
    error: null,
    isSupportChatOpen: false,
  });

  const refreshUserData = () => {
    console.log('Refresh user data called');
    // This would typically refetch user data
  };

  const setSupportChatOpen = (isOpen) => {
    setUserState(prev => ({ ...prev, isSupportChatOpen: isOpen }));
  };

  const value = {
    ...userState,
    refreshUserData,
    setSupportChatOpen,
  };

  return (
    <UserContext.Provider value={value}>
      {children}
    </UserContext.Provider>
  );
};

export const useUser = () => {
  const context = useContext(UserContext);
  if (context === undefined) {
    throw new Error('useUser must be used within a UserProvider');
  }
  return context;
};
