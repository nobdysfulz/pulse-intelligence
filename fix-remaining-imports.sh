#!/bin/bash

echo "Fixing remaining import issues..."

# Create symlink for entities
ln -sf src/api/entities.js api-entities.js

# Fix the specific files
sed -i '' "s/from '.*api\/entities'/from '..\/..\/..\/api-entities'/" components/credits/useCredits.jsx
sed -i '' "s/from '.*api\/entities'/from '..\/..\/api-entities'/" src/components/actions/taskGeneration.jsx
sed -i '' "s/from '.*api\/entities'/from '..\/..\/api-entities'/" src/components/agents/AgentChatInterface.jsx
sed -i '' "s/from '.*api\/entities'/from '..\/..\/api-entities'/" src/components/agents/CallDetailSidebar.jsx
sed -i '' "s/from '.*api\/entities'/from '..\/..\/api-entities'/" src/components/agents/CurrentTransactionsPanel.jsx

echo "Fixes applied. Testing build..."
