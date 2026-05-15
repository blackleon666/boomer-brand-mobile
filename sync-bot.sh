#!/bin/bash

echo "Syncing with boomer-brand-bot..."

git fetch bot

LOCAL=$(git rev-parse HEAD)
REMOTE=$(git rev-parse bot/master)

if [ "$LOCAL" != "$REMOTE" ]; then
    echo "New changes found in bot repo. Merging..."
    git merge bot/master -m "Merge from boomer-brand-bot"
    echo "Merge completed!"
else
    echo "Bot repo is up to date."
fi