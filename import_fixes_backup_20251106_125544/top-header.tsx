'use client'

import Link from 'next/link'

export function TopHeader() {
  return (
    <header className="bg-gray-900 text-white px-6 py-3">
      <div className="flex justify-between items-center">
        <div className="flex items-center space-x-6">
          <Link 
            href="https://pwru.app/login" 
            className="flex items-center space-x-2 hover:text-blue-300 transition-colors"
            target="_blank"
            rel="noopener noreferrer"
          >
            <span className="text-lg">🎓</span>
            <span className="font-semibold">TRAINING CENTER</span>
          </Link>
        </div>
        
        <div className="flex items-center space-x-4">
          <button className="p-2 hover:bg-gray-800 rounded-lg transition-colors">
            <span className="text-lg">🔔</span>
          </button>
          
          <Link 
            href="/settings" 
            className="p-2 hover:bg-gray-800 rounded-lg transition-colors"
          >
            <span className="text-lg">⚙️</span>
          </Link>
          
          <button className="p-2 hover:bg-gray-800 rounded-lg transition-colors">
            <span className="text-lg">🆘</span>
          </button>
        </div>
      </div>
    </header>
  )
}
