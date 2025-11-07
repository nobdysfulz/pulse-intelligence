"use client";

import React, { useState } from 'react';
import { useUser } from '@clerk/clerk-react';
import { usePathname } from 'next/navigation';
import PrimarySidebar from './PrimarySidebar';
import TopHeader from './TopHeader';
import { Menu } from 'lucide-react';

interface AppLayoutProps {
  children: React.ReactNode;
}

export default function AppLayout({ children }: AppLayoutProps) {
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);
  const { isSignedIn, isLoaded } = useUser();
  const pathname = usePathname();

  // Check if current route is a public route (sign-in/sign-up)
  const isPublicRoute = pathname === '/' || pathname?.startsWith('/sign-in') || pathname?.startsWith('/sign-up');

  // If not loaded yet or on a public route, don't show the layout chrome
  if (!isLoaded || !isSignedIn || isPublicRoute) {
    return <>{children}</>;
  }

  return (
    <div className="h-screen flex flex-col overflow-hidden bg-gray-50">
      {/* Top Purple Header */}
      <TopHeader />

      <div className="flex-1 flex overflow-hidden">
        {/* Mobile Menu Button */}
        <button
          onClick={() => setIsMobileMenuOpen(true)}
          className="md:hidden fixed bottom-4 left-4 z-50 p-3 bg-[#5b21b6] text-white rounded-full shadow-lg"
        >
          <Menu className="w-6 h-6" />
        </button>

        {/* Mobile Overlay */}
        {isMobileMenuOpen && (
          <div
            className="md:hidden fixed inset-0 bg-black bg-opacity-50 z-40"
            onClick={() => setIsMobileMenuOpen(false)}
          />
        )}

        {/* Primary Sidebar - Desktop (Fixed Width) */}
        <div className="bg-[#ffffff] hidden md:block flex-shrink-0">
          <PrimarySidebar onNavigate={() => {}} />
        </div>

        {/* Primary Sidebar - Mobile */}
        <div
          className={`
            md:hidden fixed inset-y-0 left-0 z-50 transform transition-transform duration-300
            ${isMobileMenuOpen ? 'translate-x-0' : '-translate-x-full'}
          `}
        >
          <PrimarySidebar isMobile onClose={() => setIsMobileMenuOpen(false)} onNavigate={() => setIsMobileMenuOpen(false)} />
        </div>

        {/* Main Content Area (grows to fill remaining space) */}
        <div className="flex-1 flex flex-col min-w-0 overflow-y-auto">
          {children}
        </div>
      </div>
    </div>
  );
}
