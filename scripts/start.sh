#!/usr/bin/env bash
set -e
# Avoid duplicate services
pkill -f "uvicorn backend.api.app" 2>/dev/null || true
[ -f /tmpbackend.pid ]  && kill $(cat /tmpbackend.pid) 2>/dev/null || true
[ -f /tmpfrontend.pid ] && kill $(cat /tmpfrontend.pid) 2>/dev/null || true
rm -f /tmpbackend.pid /tmpfrontend.pid
sleep 1
ROOT="${PWD}"
[ -f "${ROOT}/.env" ] && set -a && source "${ROOT}/.env" && set +a
source "${ROOT}/.venv/Scripts/activate"
export PYTHONIOENCODING=utf-8
if [ -z "${GEMINI_API_KEY}" ]; then
  echo "ERROR: GEMINI_API_KEY is not set. Export a valid key first, e.g.: export GEMINI_API_KEY=your_key"
  echo "       Get a key at: https://aistudio.google.com/apikey"
  exit 1
fi
export PYTHONPATH="${ROOT}"
export XDG_CACHE_HOME="${ROOT}/.cache"
mkdir -p "${ROOT}/.cache"

echo "Seeding knowledge base..."
python "${ROOT}/backend/seed_knowledge_base.py"

echo "Starting backend on port 8043..."
cd "${ROOT}"
uvicorn backend.api.app:app --host 0.0.0.0 --port 8043 --reload &
echo $! > ${ROOT}/backend/backend.pid

echo "Starting /frontend on port 3043..."
cd "${ROOT}/frontend" && PORT=3043 npm start &
echo $! > ${ROOT}/frontend/frontend.pid

echo ""
echo "✓ Backend:  http://localhost:8043"
echo "✓ Frontend: http://localhost:3043"
echo "✓ API Docs: http://localhost:8043/docs"
echo "✓ Health:   http://localhost:8043/health"
