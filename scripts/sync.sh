#!/bin/bash

# Sync Script
# Usage: ./scripts/sync.sh "Commit message"

if [ -z "$1" ]; then
    echo "Error: Please provide a commit message."
    echo "Usage: ./scripts/sync.sh \"Your commit message\""
    exit 1
fi

echo "Starting sync process..."

# Add all changes
git add .

# Commit changes
git commit -m "$1"

# Push to remote (assuming 'origin' and 'main' branch)
# You might need to set up the remote first if not done.
current_branch=$(git branch --show-current)
if [ -z "$current_branch" ]; then
    current_branch="main"
fi

echo "Pushing to branch $current_branch..."
git push origin "$current_branch"

echo "Sync complete!"
