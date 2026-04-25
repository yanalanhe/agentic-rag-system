# Deployment Guide: Vercel (Frontend + Backend)

This guide covers deploying the Agentic RAG System entirely on **Vercel** as two separate apps:
- **Frontend (React)** → `https://your-app-frontend.vercel.app`
- **Backend (FastAPI)** → `https://your-app-backend.vercel.app`

## Architecture

```
User Browser
    ↓
[Vercel Frontend]
    ↓ (API calls)
[Vercel Backend - Serverless Python]
    ↓
ChromaDB Vector Store
```

---

## Prerequisites

- Vercel account (https://vercel.com) — free tier works
- GitHub account with this repository
- Google Generative AI API key (https://aistudio.google.com/apikey)

---

## Part 1: Deploy Backend First

### Step 1: Create a Vercel Project for Backend

1. Go to [vercel.com/new](https://vercel.com/new)
2. Click **Import Git Repository**
3. Select this repository
4. Configure the project:
   - **Project Name**: `agentic-rag-backend` (or your choice)
   - **Framework**: Select **Other**
   - **Root Directory**: Leave empty (`.` or root of repo — NOT `backend/`)
     - ℹ️ This must be the root because `main.py`, `vercel.json`, and `requirements.txt` are all at the repo root
   - Click **Deploy**

### Step 2: Add Environment Variables

1. After the project is created, go to **Settings** → **Environment Variables**
2. Add these variables:

   | Key | Value | Required |
   |-----|-------|----------|
   | `GEMINI_API_KEY` | Your API key from https://aistudio.google.com/apikey | ✅ Yes |
   | `PYTHONUNBUFFERED` | `1` | ✅ Yes |
   | `GEMINI_MODEL` | `gemini-2.0-flash-lite` (or other model) | ❌ Optional |

   **About `GEMINI_MODEL`**:
   - Default: `gemini-2.0-flash-lite` (free tier friendly)
   - Alternative: `gemini-2.0-flash` (faster, higher quota)
   - See [Google AI Studio](https://aistudio.google.com) for available models

3. Click **Save**

### Step 3: Redeploy with Env Variables

1. Go to **Deployments** tab
2. Click the 3-dot menu on the latest deployment → **Redeploy**
3. Check the build logs to ensure it succeeds

### Step 4: Get Your Backend URL

Once deployed successfully, you'll see the URL in the top left:
```
https://your-app-backend.vercel.app
```

**Save this URL** — you need it for the frontend setup.

### Step 5: Test Backend is Working

```bash
curl https://your-app-backend.vercel.app/health
```

Expected response:
```json
{"status":"ok","lesson":"L43","pipeline":"Agentic RAG End-to-End"}
```

---

## Part 2: Deploy Frontend

### Step 1: Create a Vercel Project for Frontend

1. Go to [vercel.com/new](https://vercel.com/new)
2. Click **Import Git Repository** again
3. Select the **same repository**
4. Configure the project:
   - **Project Name**: `agentic-rag-frontend` (or your choice)
   - **Framework**: Select **Create React App**
   - **Root Directory**: Click **Edit** → select `frontend/`
   - **Build Command**: `npm run build`
   - **Output Directory**: `build`
   - Click **Deploy**

### Step 2: Add Environment Variables

After deployment, go to **Settings** → **Environment Variables**

Add this variable:
   | Key | Value |
   |-----|-------|
   | `REACT_APP_API_URL` | `https://your-app-backend.vercel.app` |

Replace `your-app-backend` with your actual backend URL from Part 1, Step 4.

### Step 3: Redeploy with Env Variables

1. Go to **Deployments** tab
2. Click the 3-dot menu on the latest deployment → **Redeploy**
3. Wait for deployment to complete

### Step 4: Test Frontend

Visit your frontend URL:
```
https://your-app-frontend.vercel.app
```

Try a demo query:
- "What was our Q3 2025 revenue growth?"
- "Describe the AI deployment guidelines"

You should see the pipeline execute: **Planner → Retriever → Validator → Synthesizer**

---

## Verification Checklist

- [ ] Backend health check returns `{"status":"ok",...}`
- [ ] Frontend loads in browser
- [ ] Can enter a query
- [ ] Pipeline executes successfully
- [ ] Results appear with citations
- [ ] No CORS errors in browser console

---

## Important Notes

### CORS Configuration

The backend allows all origins. **For production, restrict this** in [backend/api/app.py:26](backend/api/app.py#L26):

```python
allow_origins=[
    "https://your-app-frontend.vercel.app",
    "https://your-custom-domain.com",  # if using custom domain
]
```

Then redeploy the backend.

### ChromaDB Data

ChromaDB uses **file-based storage** (`backend/data/chroma_data/`).

⚠️ **Vercel serverless storage is ephemeral** — data may be lost on cold starts or redeployments.

**For production**, consider:

1. **Option A**: Use persistent vector databases:
   - [Pinecone](https://www.pinecone.io/) — managed vector DB
   - [Weaviate Cloud](https://weaviate.io/cloud) — open-source vector DB
   - [LanceDB](https://lancedb.com/) — serverless vector DB

2. **Option B**: Use Vercel's permanent storage options:
   - Set up PostgreSQL with pgvector (via Vercel's database integrations)
   - Use AWS S3/DynamoDB for backups

For now, the demo works fine with ephemeral storage.

### Timeout Limits

Vercel serverless functions have **timeout limits**:
- Free tier: **10 seconds**
- Pro tier: **60 seconds**
- Enterprise: **900 seconds**

Your RAG pipeline might exceed 10 seconds on first run (model loading, embeddings). If you hit timeouts:
- Upgrade to Pro tier (60s, recommended for this use case)
- Optimize query processing
- Cache embeddings

### Environment Variables Reference

**Backend** (`GEMINI_API_KEY`, `PYTHONUNBUFFERED`):
- Set in backend project settings on Vercel

**Frontend** (`REACT_APP_API_URL`):
- Set in frontend project settings on Vercel
- Must point to the **backend URL** from Part 1

---

## Local Development

Before deploying, test locally:

```bash
# Terminal 1: Backend
cd backend
export GEMINI_API_KEY=your_key_here
uvicorn api.app:app --host 0.0.0.0 --port 8043

# Terminal 2: Frontend
cd frontend
npm install
npm start  # Runs on http://localhost:3043
```

Visit `http://localhost:3043` and test queries.

---

## Troubleshooting

### "Cannot reach backend" or CORS errors

**Check**:
1. Backend URL is correct in frontend env vars
2. Backend project deployed successfully
3. Backend `/health` endpoint is accessible
4. Browser console shows which URL is being called

### "504 Gateway Timeout"

Your query is taking too long. Solutions:
1. Use a shorter, simpler query
2. Upgrade Vercel plan (more time)
3. Optimize query processing in backend

### "401 Unauthorized" or "Invalid API Key"

**Check**:
1. `GEMINI_API_KEY` is set in backend project settings
2. API key is valid (test at https://aistudio.google.com/apikey)
3. Redeploy backend after adding env var

### "Empty response from server"

Backend is running but returning invalid data:
1. Check backend logs in Vercel
2. Verify `GEMINI_API_KEY` is set
3. Check ChromaDB initialization logs

---

## Monitoring

### View Backend Logs

1. Go to backend project on Vercel
2. Click **Deployments** → latest deployment
3. Click **Logs** → **Function Logs**

### View Frontend Logs

1. Go to frontend project on Vercel
2. Click **Deployments** → latest deployment
3. Click **Logs** → **Build Logs** or **Runtime Logs**

---

## Custom Domains (Optional)

To use your own domain (e.g., `rag.yourcompany.com`):

1. **For Frontend**:
   - Frontend project → **Settings** → **Domains**
   - Add `rag.yourcompany.com`
   - Update DNS records as instructed

2. **For Backend**:
   - Backend project → **Settings** → **Domains**
   - Add `api.rag.yourcompany.com`
   - Update DNS records as instructed

3. **Update Frontend Env Vars**:
   - Change `REACT_APP_API_URL` to `https://api.rag.yourcompany.com`
   - Redeploy frontend

---

## Rollback / Revert

To revert to a previous version:

1. Go to **Deployments** tab
2. Find the deployment you want to restore
3. Click 3-dot menu → **Redeploy**

---

## Cost Estimate

- **Vercel Free Tier**: $0/month, includes serverless functions
- **Vercel Pro**: $20/month, better timeouts (60s) and performance
- **API Keys**: Free (you pay per API call to Google Generative AI)

---

## Next Steps

1. ✅ Deploy backend to Vercel
2. ✅ Deploy frontend to Vercel  
3. ✅ Test the full pipeline
4. 🔐 Restrict CORS to your domain
5. 💾 Consider persistent vector DB for production
6. 📊 Add monitoring (Sentry, LogRocket, etc.)

