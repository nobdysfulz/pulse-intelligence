'use client'

import Link from 'next/link'
import { usePathname } from 'next/navigation'
import { UserButton, useUser } from '@clerk/nextjs'

const navigation = [
  { name: 'Dashboard', href: '/dashboard', icon: '🏠' },
  { name: 'To-Do', href: '/to-do', icon: '☑️' },
  { name: 'Goals', href: '/goals', icon: '🎯' },
  { name: 'Intelligence', href: '/intelligence', icon: '🧠' },
  { name: 'Content', href: '/content-studio', icon: '📷' },
  { name: 'Skills', href: '/role-play', icon: '🏆' },
  { name: 'My Advisor', href: '/personaladvisor', icon: '💬' },
  { name: 'My Market', href: '/market', icon: '📈' },
  { name: 'My AI Agents', href: '/agents', icon: '👥', badge: 'Upgrade' },
]

export function PrimarySidebar() {
  const pathname = usePathname()
  const { user } = useUser()

  return (
    <div className="flex h-full flex-col bg-gray-900 text-white w-64">
      {/* Logo */}
      <div className="flex items-center justify-center h-16 shrink-0 px-4 border-b border-gray-800">
        <h1 className="text-xl font-bold">Pulse Intelligence</h1>
      </div>

      {/* Navigation */}
      <nav className="flex-1 space-y-2 px-4 py-4">
        {navigation.map((item) => {
          const isActive = pathname === item.href
          return (
            <Link
              key={item.name}
              href={item.href}
              className={`flex items-center px-3 py-2 text-sm font-medium rounded-lg transition-colors ${
                isActive
                  ? 'bg-blue-600 text-white'
                  : 'text-gray-300 hover:bg-gray-800 hover:text-white'
              }`}
            >
              <span className="mr-3 text-lg">{item.icon}</span>
              <span className="flex-1">{item.name}</span>
              {item.badge && (
                <span className="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-yellow-500 text-yellow-900">
                  {item.badge}
                </span>
              )}
            </Link>
          )
        })}
      </nav>

      {/* Footer */}
      <div className="shrink-0 border-t border-gray-800 p-4">
        <div className="flex items-center justify-between">
          <UserButton afterSignOutUrl="/" />
          <div className="flex-1 ml-3">
            <p className="text-sm font-medium text-white">
              {user?.firstName} {user?.lastName}
            </p>
            <p className="text-xs text-gray-400">{user?.emailAddresses[0]?.emailAddress}</p>
          </div>
        </div>
      </div>
    </div>
  )
}
