import React from 'react';

interface AITypingIndicatorProps {
  agentName?: string;
  avatarUrl?: string;
  className?: string;
}

export default function AITypingIndicator({ 
  agentName = "PULSE AI", 
  avatarUrl, 
  className = "" 
}: AITypingIndicatorProps) {
  return (
    <div className={`flex items-center space-x-3 p-4 ${className}`}>
      <div className="flex-shrink-0">
        {avatarUrl ? (
          <img
            src={avatarUrl}
            alt={`${agentName} avatar`}
            className="h-8 w-8 rounded-full"
          />
        ) : (
          <div className="h-8 w-8 rounded-full bg-gradient-to-r from-purple-500 to-blue-500 flex items-center justify-center">
            <span className="text-white text-xs font-bold">AI</span>
          </div>
        )}
      </div>
      <div className="flex-1 min-w-0">
        <p className="text-sm font-medium text-gray-900">{agentName} is typing</p>
        <div className="flex space-x-1 mt-1">
          <div className="h-2 w-2 bg-gray-400 rounded-full animate-bounce" style={{ animationDelay: '0ms' }} />
          <div className="h-2 w-2 bg-gray-400 rounded-full animate-bounce" style={{ animationDelay: '150ms' }} />
          <div className="h-2 w-2 bg-gray-400 rounded-full animate-bounce" style={{ animationDelay: '300ms' }} />
        </div>
      </div>
    </div>
  );
}
