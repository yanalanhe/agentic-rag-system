# Deployment Guide: Vercel Frontend + Railway Backend

This guide covers deploying the Agentic RAG System:
- **Frontend (React)** → Vercel
- **Backend (FastAPI)** → Railway

## Quick Recommendation

| Component | Platform | Why |
|-----------|----------|-----|
| **Frontend** | **Vercel** ✅ | Perfect for React, free tier |
| **Backend** | **Railway** ✅ | Handles heavy Python deps, no size limits |

---

## Deployment Overview

```
User Browser
    ↓
[Vercel Frontend]  https://your-frontend.vercel.app
    ↓ (API calls)
[Railway Backend]  https://your-project.up.railway.app
    ↓
Vector Database (File-based or Managed)
```

---

## Part 1: Deploy Backend on Railway

👉 **[Full Railway Deployment Guide](./RAILWAY_DEPLOYMENT.md)**

**Quick Steps**:

1. Go to https://railway.app → **New Project** → **Deploy from GitHub**
2. Select your repository
3. Add environment variables:
   - `GEMINI_API_KEY` = your API key
   - `PYTHONUNBUFFERED` = `1`
   - `GEMINI_MODEL` = `gemini-2.0-flash-lite`
   - `GOOGLE_CLOUD_UNIVERSE_DOMAIN` = `googleapis.com`
   - `GRPC_PYTHON_BUILD_WITH_CYTHON` = `false`
4. Deploy and copy your public URL
5. **⚠️ Important**: Seed knowledge base via `/docs` endpoint

See [RAILWAY_DEPLOYMENT.md](./RAILWAY_DEPLOYMENT.md) for detailed steps and troubleshooting.

---

## Part 2: Deploy Frontend on Vercel

### Step 1: Create Vercel Project for Frontend

1. Go to https://vercel.com/new
2. Click **Import Git Repository**
3. Select your repository
4. Configure:
   - **Project Name**: `agentic-rag-frontend`
   - **Framework**: Create React App
   - **Root Directory**: Click **Edit** → select `frontend/`
   - **Build Command**: `npm run build`
   - **Output Directory**: `build`

### Step 2: Add Environment Variables

1. Go to **Environment Variables** section
2. Add:
   ```
   REACT_APP_API_URL = https://your-railway-backend.up.railway.app
   ```
   ⚠️ **No trailing slash!** Use exact Railway public URL.

3. Click **Deploy**

### Step 3: Test

1. Visit your frontend URL
2. Try a query
3. Should see: Planner → Retriever → Validator → Synthesizer → Done

---

## Architecture Comparison

### Option A: Vercel (Frontend + Backend)
- ❌ Backend: 500MB size limit (breaks with ML deps)
- ❌ Knowledge base: Ephemeral (lost on redeploy)
- ❌ Build timeout issues
- **Not recommended** for this project

### Option B: Vercel + Railway (Recommended) ✅
- ✅ Frontend: Perfect on Vercel
- ✅ Backend: Full Python support on Railway
- ✅ No size limits
- ✅ Proper container support
- **Recommended**

### Option C: Railway (Both)
- ✅ Both components on Railway
- ✅ Simplified management
- ✅ But less specialized (less free tier benefits)
- Alternative option

---

## Important: Ephemeral Storage on Railway ⚠️

Railway's filesystem is **ephemeral**. Knowledge base data is lost when:
- Service redeploys
- Service restarts
- Code changes are pushed

### Solution

**For Development**: Seed knowledge base after each deployment via `/ingest` endpoint

**For Production**: Use persistent vector database (Pinecone, Weaviate, LanceDB)

👉 **[See Persistent Vector DB Guide](./PERSISTENT_VECTOR_DB.md)**

---

## Environment Variables

### Backend (Railway)

| Variable | Value | Purpose |
|----------|-------|---------|
| `GEMINI_API_KEY` | Your API key | Required: Google Generative AI |
| `PYTHONUNBUFFERED` | `1` | Required: Real-time logging |
| `GEMINI_MODEL` | `gemini-2.0-flash-lite` | Optional: Model choice |
| `GOOGLE_CLOUD_UNIVERSE_DOMAIN` | `googleapis.com` | Required: Fixes metadata timeout |
| `GRPC_PYTHON_BUILD_WITH_CYTHON` | `false` | Optional: gRPC fix |

### Frontend (Vercel)

| Variable | Value |
|----------|-------|
| `REACT_APP_API_URL` | Your Railway backend URL (no trailing slash) |

---

## Verification Checklist

After deployment:

- [ ] Backend health check works: `curl https://your-backend/health`
- [ ] Frontend loads in browser
- [ ] Knowledge base seeded via `/ingest`
- [ ] Query returns results (not "no information")
- [ ] No CORS errors in browser console
- [ ] Pipeline executes all 4 stages

---

## Troubleshooting

### Backend Issues
- See [RAILWAY_DEPLOYMENT.md](./RAILWAY_DEPLOYMENT.md) troubleshooting section

### Frontend Issues
- Verify `REACT_APP_API_URL` has no trailing slash
- Check browser console for CORS errors
- Ensure backend is running and accessible

### Knowledge Base Empty
- Visit `https://your-backend/docs`
- Use `/ingest` endpoint to seed documents
- See [RAILWAY_DEPLOYMENT.md](./RAILWAY_DEPLOYMENT.md) for details

### Data Loss After Redeploy
- This is expected with ephemeral storage
- Use persistent vector DB for production
- See [PERSISTENT_VECTOR_DB.md](./PERSISTENT_VECTOR_DB.md)

---

## For Production

### Recommended Setup

1. **Frontend**: Vercel with custom domain
2. **Backend**: Railway with persistent vector DB
3. **Vector DB**: Pinecone or Weaviate
4. **Monitoring**: Sentry or DataDog (optional)

### Security Checklist

- [ ] Restrict CORS to frontend domain only
- [ ] Use environment secrets for API keys (not in code)
- [ ] Enable HTTPS (automatic on both platforms)
- [ ] Monitor backend logs regularly
- [ ] Set up backup/restore process

---

## Next Steps

1. Deploy backend to Railway → [RAILWAY_DEPLOYMENT.md](./RAILWAY_DEPLOYMENT.md)
2. Deploy frontend to Vercel (steps above)
3. Seed knowledge base via `/ingest`
4. Test end-to-end
5. For production: Set up persistent vector DB → [PERSISTENT_VECTOR_DB.md](./PERSISTENT_VECTOR_DB.md)

---

## Support

For issues:
- Railway: https://railway.app/docs
- Vercel: https://vercel.com/docs
- FastAPI: https://fastapi.tiangolo.com
- React: https://react.dev

Happy deploying! 🚀

