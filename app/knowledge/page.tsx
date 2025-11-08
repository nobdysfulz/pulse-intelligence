"use client";

import React from 'react';

export default function KnowledgeBasePage() {
  return (
    <div className="flex flex-col h-full w-full bg-white">
      <iframe
        src="https://help.powerunitcoaching.com/"
        title="Knowledge Base"
        className="w-full h-full border-0"
        sandbox="allow-scripts allow-popups allow-forms"
      />
    </div>
  );
}
