# Vercel-Only Deployment Setup Summary

You've chosen to deploy **both frontend and backend on Vercel** as separate apps. Here's what's been set up:

## Files Created/Updated

✅ **Frontend Configuration**:
- `frontend/vercel.json` — Vercel config for React app
- `frontend/.vercelignore` — Excludes unnecessary files

✅ **Backend Configuration**:
- `vercel.json.backend` — Reference config for backend serverless deployment
- (Note: When deploying backend, you may not need this file—it's just for reference)

✅ **Documentation**:
- `DEPLOYMENT.md` — **⭐ Start here** - Complete Vercel deployment guide
- `ENV_SETUP.md` — Quick environment variables reference
- `VERCEL_SETUP_SUMMARY.md` — This file

## Why Two Separate Vercel Apps?

| Aspect | Frontend | Backend |
|--------|----------|---------|
| Framework | React (Node.js) | FastAPI (Python) |
| Vercel Support | Native ✅ | Serverless Functions |
| Deployment Type | Static + Edge | Serverless |
| Cold Start | ~100ms | ~1-5s first time |
| URL Example | `frontend.vercel.app` | `backend.vercel.app` |

**Having two separate apps is the professional approach** because:
1. Each can scale independently
2. Frontend deploys instantly; backend only when code changes
3. Easy to update frontend without touching backend
4. Cleaner separation of concerns

## Quick Start (3 Steps)

### Step 1: Deploy Backend
1. Go to https://vercel.com/new
2. Import this repository
3. Name it: `agentic-rag-backend`
4. **Root Directory**: Leave empty (root of repo, NOT `backend/`)
   - This finds `main.py` and `vercel.json` at the root
5. Set environment variables:
   - `GEMINI_API_KEY` = your API key
   - `PYTHONUNBUFFERED` = `1`
6. Deploy
7. **Save the backend URL** (e.g., `https://agentic-rag-backend.vercel.app`)

### Step 2: Deploy Frontend
1. Go to https://vercel.com/new
2. Import **same repository** again
3. Name it: `agentic-rag-frontend`
4. Root directory: `frontend/`
5. Build command: `npm run build`
6. Set environment variable:
   - `REACT_APP_API_URL` = `https://agentic-rag-backend.vercel.app` (from Step 1)
7. Deploy

### Step 3: Test
1. Visit your frontend URL
2. Try a query
3. See the pipeline execute!

## Architecture

```
┌─────────────────────────────────────────┐
│         Your Browser                    │
└─────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────┐
│  Vercel (Frontend)                      │
│  - React Static Site                    │
│  - Hosted Edge Locations                │
│  URL: frontend.vercel.app               │
└─────────────────────────────────────────┘
                    ↓
              (API calls)
                    ↓
┌─────────────────────────────────────────┐
│  Vercel (Backend)                       │
│  - Python Serverless Functions          │
│  - FastAPI + ChromaDB                   │
│  URL: backend.vercel.app                │
└─────────────────────────────────────────┘
                    ↓
         ChromaDB Vector Store
         (file-based storage)
```

## Key Differences from Railway

| Aspect | Vercel | Railway |
|--------|--------|---------|
| Setup | 2 separate projects | 1 project with Procfile |
| Costs | Generous free tier | Free + paid tiers |
| Python Support | Serverless functions | Full containers |
| Best For | Frontend-heavy apps | Full-stack monoliths |
| Deployment | Per project | Per push to main |

## Important Caveats

### Timeout Limits
Free Vercel has **10 second timeout** for serverless functions. Your RAG pipeline might exceed this because:
- First call: Model initialization (~3-5s) + embeddings (~5-10s)
- Subsequent calls: Faster (cached)

**Recommendation**: Upgrade to **Vercel Pro** ($20/month) for 60-second timeouts, which is more suitable for this use case.

### Ephemeral Storage
ChromaDB uses file-based storage, which is ephemeral on Vercel. On redeployment, data may be lost.

**For production**: 
- Use a persistent vector database (Pinecone, Weaviate, LanceDB)
- Or set up PostgreSQL with pgvector

For demos and testing, this is fine.

### CORS Configuration
Currently, the backend allows **all origins**. In production, restrict to your frontend domain:

In `backend/api/app.py` line 26, change:
```python
# Current (insecure)
allow_origins=["*"]

# To (secure)
allow_origins=["https://your-frontend-url.vercel.app"]
```

Then redeploy backend.

## Troubleshooting

### Can't see backend errors
Check backend logs in Vercel:
1. Backend project → **Deployments** → latest → **Logs**

### Frontend can't reach backend
1. Check `REACT_APP_API_URL` env var is set correctly
2. Frontend needs full URL: `https://backend-url.vercel.app` (not localhost!)

### Timeout errors
1. Use simpler queries first
2. Upgrade Vercel plan if you need longer timeouts

### API key not working
1. Check `GEMINI_API_KEY` is set in backend project settings
2. Key must be valid from https://aistudio.google.com/apikey
3. Redeploy backend after setting it

## Next Steps

1. 📖 Read [DEPLOYMENT.md](./DEPLOYMENT.md) for full step-by-step instructions
2. 🔑 Get your GEMINI_API_KEY from https://aistudio.google.com/apikey
3. 🚀 Deploy backend first
4. 🚀 Deploy frontend second (with backend URL)
5. ✅ Test your pipeline
6. 🔒 Restrict CORS for production

## Cost Breakdown

| Component | Free Tier | Pro Tier |
|-----------|-----------|----------|
| Frontend | Free ✅ | $20/mo optional |
| Backend | Free ✅ (10s timeout) | $20/mo (60s timeout) |
| API Calls | Google's pricing | Google's pricing |
| **Total** | **Free** | **$20-40/mo** |

For development/testing: **Free tier works fine**
For production: **Pro tier recommended**

