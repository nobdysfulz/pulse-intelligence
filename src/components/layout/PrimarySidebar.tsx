import React, { useContext } from 'react';
import { usePathname } from 'next/navigation';
import Link from 'next/link';
import { createPageUrl } from '@/utils';
import { Home, CheckSquare, Target, Users, LogOut, TrendingUp, Camera, Award, MessageSquare, Brain } from 'lucide-react';
import { UserContext } from '../context/UserContext';
import { useClerk } from '@clerk/clerk-react';

interface PrimarySidebarProps {
  onNavigate?: () => void;
  isMobile?: boolean;
  onClose?: () => void;
}

export default function PrimarySidebar({ onNavigate, isMobile, onClose }: PrimarySidebarProps) {
  const { user } = useContext(UserContext);
  const { signOut } = useClerk();
  const currentPath = usePathname();

  const isAdmin = user?.role === 'admin';
  const isSubscriberOrAdmin = user?.subscriptionTier === 'Subscriber' || user?.subscriptionTier === 'Admin';

  const handleLogout = async () => {
    await signOut();
    onNavigate?.(); 
  };

  // Calculate active states based on currentPath
  const isDashboardActive = currentPath === '/dashboard' || currentPath === '/';
  const isToDoActive = currentPath === '/to-do';
  const isGoalsActive = currentPath === '/goals';
  const isIntelligenceActive = currentPath === '/intelligence';
  const isContentActive = currentPath === '/content-studio';
  const isSkillsActive = currentPath === '/role-play';
  const isAdvisorActive = currentPath === '/personaladvisor';
  const isMarketActive = currentPath === '/market';
  const isAgentsActive = currentPath === '/agents';

  // Determine where My AI Agents should link to
  const aiAgentsLink = isSubscriberOrAdmin ? '/agents' : '/plans';

  return (
    <aside className="bg-white w-40 flex flex-col h-full border-r border-[#E2E8F0] shadow-sm pt-4">
      <nav className="flex-1 py-4">
        {/* Dashboard */}
        <Link
          href="/dashboard"
          className={
            `text-[#01070f] pt-2 pr-1 pb-2 pl-4 text-sm font-normal flex items-center transition-colors hover:bg-[#F8FAFC]
            ${isDashboardActive ? 'font-semibold bg-[#F8FAFC]' : ''}`
          }
          onClick={() => onNavigate?.()}
        >
          <Home className="w-5 h-5 mr-3" />
          <span className="text-left">Dashboard</span>
        </Link>

        {/* To-Do */}
        <Link
          href="/to-do"
          className={
            `text-[#01070f] pt-2 pr-1 pb-2 pl-4 text-sm font-normal flex items-center transition-colors hover:bg-[#F8FAFC] 
            ${isToDoActive ? 'font-semibold bg-[#F8FAFC]' : ''}`
          }
          onClick={() => onNavigate?.()}
        >
          <CheckSquare className="w-5 h-5 mr-3" />
          <span className="text-left">To-Do</span>
        </Link>

        {/* Goals */}
        <Link
          href="/goals"
          className={
            `text-[#01070f] pt-2 pr-1 pb-2 pl-4 text-sm font-normal flex items-center transition-colors hover:bg-[#F8FAFC] 
            ${isGoalsActive ? 'font-semibold bg-[#F8FAFC]' : ''}`
          }
          onClick={() => onNavigate?.()}
        >
          <Target className="w-5 h-5 mr-3" />
          <span className="text-left">Goals</span>
        </Link>

        {/* Intelligence */}
        <Link
          href="/intelligence"
          className={
            `text-[#01070f] pt-2 pr-1 pb-2 pl-4 text-sm font-normal flex items-center transition-colors hover:bg-[#F8FAFC] 
            ${isIntelligenceActive ? 'font-semibold bg-[#F8FAFC]' : ''}`
          }
          onClick={() => onNavigate?.()}
        >
          <Brain className="w-5 h-5 mr-3" />
          <span className="text-left">Intelligence</span>
        </Link>

        {/* Content */}
        <Link
          href="/content-studio"
          className={
            `text-[#01070f] pt-2 pr-1 pb-2 pl-4 text-sm font-normal flex items-center transition-colors hover:bg-[#F8FAFC] 
            ${isContentActive ? 'font-semibold bg-[#F8FAFC]' : ''}`
          }
          onClick={() => onNavigate?.()}
        >
          <Camera className="w-5 h-5 mr-3" />
          <span className="text-left">Content</span>
        </Link>

        {/* Skills */}
        <Link
          href="/role-play"
          className={
            `text-[#01070f] pt-2 pr-1 pb-2 pl-4 text-sm font-normal flex items-center transition-colors hover:bg-[#F8FAFC] 
            ${isSkillsActive ? 'font-semibold bg-[#F8FAFC]' : ''}`
          }
          onClick={() => onNavigate?.()}
        >
          <Award className="w-5 h-5 mr-3" />
          <span className="text-left">Skills</span>
        </Link>

        {/* My Advisor */}
        <Link
          href="/personaladvisor"
          className={
            `text-[#01070f] pt-2 pr-1 pb-2 pl-4 text-sm font-normal flex items-center transition-colors hover:bg-[#F8FAFC] 
            ${isAdvisorActive ? 'font-semibold bg-[#F8FAFC]' : ''}`
          }
          onClick={() => onNavigate?.()}
        >
          <MessageSquare className="w-5 h-5 mr-3" />
          <span className="text-left">My Advisor</span>
        </Link>

        {/* My Market */}
        <Link
          href="/market"
          className={
            `text-[#01070f] pt-2 pr-1 pb-2 pl-4 text-sm font-normal flex items-center transition-colors hover:bg-[#F8FAFC] 
            ${isMarketActive ? 'font-semibold bg-[#F8FAFC]' : ''}`
          }
          onClick={() => onNavigate?.()}
        >
          <TrendingUp className="w-5 h-5 mr-3" />
          <span className="text-left">My Market</span>
        </Link>

        {/* My AI Agents - Conditionally links to Plans or Agents based on subscription */}
        <Link
          href={aiAgentsLink}
          className={
            `text-[#01070f] pt-2 pr-1 pb-2 pl-4 text-sm font-normal flex items-center transition-colors hover:bg-[#F8FAFC] 
            ${isAgentsActive ? 'font-semibold bg-[#F8FAFC]' : ''}`
          }
          onClick={() => onNavigate?.()}
        >
          <Users className="w-5 h-5 mr-3" />
          <span className="text-left">My AI Agents</span>
        </Link>
      </nav>

      <div className="mt-auto">
        {/* The Upgrade link is visible only if the user is NOT an admin */}
        {!isAdmin && ( 
          <Link
            href="/plans"
            className="text-[#01070f] pt-2 pr-1 pb-2 pl-4 text-sm font-medium flex items-center transition-colors hover:bg-[#F8FAFC]"
            onClick={() => onNavigate?.()}
          >
            <img 
              src="/images/logos/pulse-logo.png" 
              alt="Upgrade" 
              className="w-5 h-5 mr-3"
            />
            <span className="text-left">Upgrade</span>
          </Link>
        )}
        
        <div className="p-2 border-t border-[#E2E8F0]">
          <button
            onClick={handleLogout}
            className="w-full flex items-center px-4 py-3 text-sm font-medium transition-colors text-[#475569] hover:bg-[#F8FAFC] rounded-md"
          >
            <LogOut className="w-5 h-5 mr-3" />
            <span>Logout</span>
          </button>
        </div>
      </div>
    </aside>
  );
}
