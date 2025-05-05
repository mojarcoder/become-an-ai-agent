#!/bin/bash

APP_NAME="Become An Ai Agent.app"
APP_PATH="/Applications/$APP_NAME"

echo "🔄 Attempting to uninstall $APP_NAME..."

# Delete the app
if [ -d "$APP_PATH" ]; then
  rm -rf "$APP_PATH"
  echo "✅ $APP_NAME has been removed from /Applications."
else
  echo "⚠️ $APP_NAME not found in /Applications."
fi

# Optional: Remove related support files (if you created any)
echo "🧹 Cleaning up support files..."

rm -rf ~/Library/Application\ Support/Become An Ai Agent
rm -rf ~/Library/Caches/com.mojarcoder.become_an_ai_agent
rm -f  ~/Library/Preferences/com.mojarcoder.become_an_ai_agent.plist

echo "✅ Uninstallation complete."
