# Environment Variables Setup - Vercel

Quick reference for setting up environment variables for Vercel deployment.

## Backend (Vercel) Variables

In your **backend project** on Vercel, set these environment variables:

**Settings** → **Environment Variables**

```
GEMINI_API_KEY=sk-...     # Get from https://aistudio.google.com/apikey
PYTHONUNBUFFERED=1        # For real-time logging
```

## Frontend (Vercel) Variables

In your **frontend project** on Vercel, set this environment variable:

**Settings** → **Environment Variables**

```
REACT_APP_API_URL=https://your-app-backend.vercel.app
```

**Important**: Replace `your-app-backend` with your actual backend Vercel URL.

---

## How to Get GEMINI_API_KEY

1. Go to https://aistudio.google.com/apikey
2. Sign in with your Google account
3. Click **Create API Key**
4. Copy the generated key (looks like `AIzaSy...`)
5. Paste it into the `GEMINI_API_KEY` field in your backend Vercel project

---

## How to Find Your Backend URL

After deploying the backend to Vercel:

1. Go to https://vercel.com
2. Click on your **backend project**
3. In the top left, you'll see your URL like:
   ```
   https://agentic-rag-backend.vercel.app
   ```
4. Copy this full URL
5. Paste it as `REACT_APP_API_URL` in your frontend project

---

## Deployment Flow

```
1. Set GEMINI_API_KEY in backend project
   ↓
2. Deploy backend to Vercel
   ↓
3. Copy backend URL (e.g., https://xxx.vercel.app)
   ↓
4. Set REACT_APP_API_URL in frontend project with backend URL
   ↓
5. Deploy frontend to Vercel
   ↓
6. Test: visit https://frontend-url.vercel.app
```

---

## Verification

### Test Backend Connection

```bash
curl https://your-backend-url.vercel.app/health
```

Expected output:
```json
{"status":"ok","lesson":"L43","pipeline":"Agentic RAG End-to-End"}
```

### Test Frontend Loads

Visit `https://your-frontend-url.vercel.app` in your browser. You should see:
- The Agentic RAG Pipeline dashboard
- Demo queries on the left sidebar
- Input field to ask questions

### Test API Integration

1. Open the frontend
2. Type a demo query: "What was our Q3 2025 revenue growth?"
3. Click **Query**
4. Open browser DevTools → **Network** tab
5. Verify the request goes to your backend URL
6. Response should contain the RAG result

---

## Environment Variable Limits

- **Max length**: 4,096 characters per value
- **Max count**: Unlimited
- **Available to**: Build time and runtime

---

## Common Issues

| Issue | Solution |
|-------|----------|
| "404 Not Found" from frontend | Check `REACT_APP_API_URL` is set correctly |
| "Invalid API Key" error | Verify `GEMINI_API_KEY` is set in backend project |
| "CORS error" in browser | Backend needs to allow frontend domain (check [backend/api/app.py:26](../backend/api/app.py)) |
| Variables not taking effect | After setting env vars, click **Redeploy** in Deployments tab |

---

## Production Recommendations

For production deployments:

1. **Rotate API Keys Regularly**
   - Delete old keys from Google API console
   - Update Vercel with new key

2. **Restrict CORS**
   - Only allow your frontend domain
   - Never use `allow_origins=["*"]` in production

3. **Use Custom Domains**
   - Map `rag.yourcompany.com` to frontend
   - Map `api.rag.yourcompany.com` to backend

4. **Monitor Logs**
   - Regularly check Vercel logs for errors
   - Set up alerts for failures

