# Railway Backend Deployment Guide

This guide covers deploying the **FastAPI backend** to Railway (recommended for Python applications with heavy dependencies).

## Why Railway?

| Feature | Vercel | Railway |
|---------|--------|---------|
| **Python Support** | Serverless functions only | Full containerized apps ✅ |
| **Dependency Size Limit** | 500 MB | Unlimited ✅ |
| **Build Time** | Limited | Generous ✅ |
| **Cost** | Pay-per-function | Free tier + usage ✅ |
| **ML Libraries** | Not suitable | Perfect ✅ |

---

## Deployment Steps

### Step 1: Deploy Backend to Railway

1. Go to https://railway.app
2. Sign up/sign in (GitHub login recommended)
3. Click **New Project**
4. Select **Deploy from GitHub repo**
5. Connect GitHub and select your repository
6. Railway auto-detects Python
7. Click **Deploy**

### Step 2: Add Environment Variables

After deployment starts:

1. Click the **Backend** service
2. Go to **Variables** tab
3. Add these variables:

   | Key | Value |
   |-----|-------|
   | `GEMINI_API_KEY` | Your API key from https://aistudio.google.com/apikey |
   | `PYTHONUNBUFFERED` | `1` |
   | `GEMINI_MODEL` | `gemini-2.0-flash-lite` |
   | `GOOGLE_CLOUD_UNIVERSE_DOMAIN` | `googleapis.com` |
   | `GRPC_PYTHON_BUILD_WITH_CYTHON` | `false` |

4. Click **Save** — Railway will redeploy

### Step 3: Get Your Public URL

Once deployed:

1. Click the **Backend** service
2. Look for **Public URL** (e.g., `https://agentic-rag-system-production.up.railway.app`)
3. **Copy this URL** for frontend setup

### Step 4: Test Backend

```bash
curl https://your-railway-url.up.railway.app/health
```

Expected:
```json
{"status":"ok","lesson":"L43","pipeline":"Agentic RAG End-to-End"}
```

---

## Important: Ephemeral Storage ⚠️

Railway's filesystem is **ephemeral**. This means:

- **ChromaDB data is lost** when the service restarts or redeploys
- Knowledge base will be empty after deployment
- Queries will fail with "not enough information"

### Solution: Seed the Knowledge Base

After deployment, you **must** seed the knowledge base. Choose one approach:

#### Recommended: Auto-Seed on Every Deploy

To avoid manual re-seeding after each git push, enable automatic seeding:

1. Go to Railway → Backend service → **Settings**
2. Scroll to find **Post-Deploy Command** field (or **Build Command**)
3. Add command:
   ```
   python -m backend.seed_knowledge_base
   ```
4. Save

Now every deployment automatically seeds the knowledge base with documents from `seed_knowledge_base.py`.

**Benefits**:
- ✅ Zero manual work
- ✅ Knowledge base repopulated after every git push
- ✅ Consistent data across deployments

#### Manual: Seed via API (If Auto-Seed Not Set)

#### Option 1: Via API Docs (Easiest)

1. Visit: `https://your-railway-url.up.railway.app/docs`
2. Find **`POST /ingest`** endpoint
3. Click **Try it out**
4. Add documents in request body:
   ```json
   {
     "documents": [
       "Our Q3 2025 revenue was $5.2 million, up 45% YoY",
       "AI deployment guidelines: Always containerize production models",
       "P1 incident response: Page oncall immediately, 5 min war room",
       "We have 12 GPU clusters for ML infrastructure",
       "2026 roadmap: Q1 - Auth redesign, Q2 - API v2, Q3 - Mobile"
     ],
     "sources": [
       "financial_report_q3_2025",
       "deployment_guidelines",
       "incident_response_protocol",
       "infrastructure_inventory",
       "product_roadmap_2026"
     ]
   }
   ```
5. Click **Execute**

#### Option 2: Via cURL

```bash
curl -X POST https://your-railway-url.up.railway.app/ingest \
  -H "Content-Type: application/json" \
  -d '{
    "documents": [
      "Document content here",
      "More documents..."
    ],
    "sources": ["doc1", "doc2"]
  }'
```

#### Option 3: Persistent Vector Database (Production)

See [PERSISTENT_VECTOR_DB.md](./PERSISTENT_VECTOR_DB.md) for using Pinecone, Weaviate, or LanceDB to make the knowledge base persistent.

---

## Environment Variables Reference

### Required

- `GEMINI_API_KEY` — Google Generative AI API key
- `PYTHONUNBUFFERED` — Set to `1` for real-time logging

### Optional

- `GEMINI_MODEL` — Model to use (default: `gemini-2.0-flash-lite`)
- `GOOGLE_CLOUD_UNIVERSE_DOMAIN` — Fixes GCP metadata service timeout
- `GRPC_PYTHON_BUILD_WITH_CYTHON` — Prevents gRPC compilation issues

---

## Git Push → Automatic Redeployment

**Important**: By default, Railway automatically redeploys when you push to GitHub.

### How It Works

```
You: git push to main
       ↓
Railway: Detects new commit
       ↓
Railway: Pulls code and rebuilds
       ↓
Railway: Redeploys backend (~2 minutes)
       ↓
Knowledge base is reset (ephemeral storage)
```

### What This Means

Every git push causes:
- ✅ Automatic redeployment (good for CI/CD)
- ❌ Knowledge base to be lost (bad for data)

### Solutions

**Option 1: Auto-Seed on Deploy** (Recommended)
- Add post-deploy command (see "Auto-Seed" section above)
- Knowledge base automatically repopulated
- Zero manual work

**Option 2: Manual Re-seed After Push**
- After each git push, visit `/docs` → `/ingest`
- Add documents manually
- Takes ~2 minutes

**Option 3: Disable Auto-Deploy**
- Railway → Backend → Settings → **Auto Deploy** → OFF
- Manually trigger deploys only when ready
- More control, but requires manual action

**Option 4: Use Persistent Vector DB**
- Set up Pinecone or Weaviate (see PERSISTENT_VECTOR_DB.md)
- Data never lost
- Best for production

---

## Troubleshooting

### "Build timeout exceeded"

Your dependencies are too large. Make sure `requirements.txt` uses CPU-only PyTorch:
```
--extra-index-url https://download.pytorch.org/whl/cpu
torch==2.5.1+cpu
```

### "Metadata service timeout"

Add these environment variables:
```
GOOGLE_CLOUD_UNIVERSE_DOMAIN=googleapis.com
GRPC_PYTHON_BUILD_WITH_CYTHON=false
```

### "Not enough information to answer"

Your knowledge base is empty. Run the `/ingest` endpoint to seed documents (see above).

### "CORS error in frontend"

Ensure `REACT_APP_API_URL` on Vercel frontend matches your Railway public URL exactly (no trailing slash).

---

## Monitoring

### View Logs

1. Go to your Backend service
2. Click **Logs** tab
3. See real-time logs

### View Metrics

1. Go to Backend service → **Metrics**
2. Monitor CPU, memory, network usage

---

## For Production: Use Persistent Vector Database

The current setup loses knowledge base data on redeploy. For production, use a managed vector database.

See [PERSISTENT_VECTOR_DB.md](./PERSISTENT_VECTOR_DB.md) for options and setup instructions.

