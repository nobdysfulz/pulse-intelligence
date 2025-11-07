"use client";

import { createContext, useContext } from 'react';

const defaultState = {
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
};

export const UserContext = createContext(defaultState);

export const useUser = () => {
  const context = useContext(UserContext);

  if (context === undefined) {
    throw new Error('useUser must be used within a UserProvider');
  }

  return context;
};

export { default as UserProvider } from './UserProvider';
