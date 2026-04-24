#!/usr/bin/env bash
[ -f /tmpbackend.pid ]  && kill $(cat /tmpbackend.pid)  2>/dev/null && rm /tmpbackend.pid  && echo "Backend stopped"
[ -f /tmpfrontend.pid ] && kill $(cat /tmpfrontend.pid) 2>/dev/null && rm /tmpfrontend.pid && echo "Frontend stopped"
pkill -f "uvicorn backend.api.app" 2>/dev/null || true
echo "✓ All processes stopped"
