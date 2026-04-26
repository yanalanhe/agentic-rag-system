# Persistent Vector Database Guide

The current setup uses **ephemeral ChromaDB**, which loses data on redeploy. This guide covers migrating to persistent vector databases for production.

## Why Persistent Vector DB?

| Aspect | File-based ChromaDB | Managed Vector DB |
|--------|-------------------|-------------------|
| **Persistence** | Lost on redeploy ❌ | Permanently stored ✅ |
| **Scalability** | Limited ❌ | Enterprise scale ✅ |
| **Availability** | Depends on server ❌ | Always available ✅ |
| **Backup** | Manual ❌ | Automatic ✅ |
| **Cost** | Free | Free tier available ✅ |

---

## Options Comparison

| Provider | Free Tier | Setup Time | Best For | Pricing |
|----------|-----------|-----------|----------|---------|
| **Pinecone** | ✅ Yes | 5 min | Production RAG | Generous free tier |
| **Weaviate** | ✅ Yes (Cloud) | 10 min | Flexibility | Free tier + paid |
| **LanceDB** | ✅ Yes | 15 min | Serverless | Pay-per-use |
| **Qdrant** | ✅ Yes | 10 min | Self-hosted | Cloud + self-host |

**Recommendation**: **Pinecone** (easiest, best free tier)

---

## Option 1: Pinecone (Recommended) ✅

### Benefits
- Free tier: 1 pod, 100k vectors
- Easiest integration
- No infrastructure management
- Built-in security

### Setup

#### Step 1: Create Pinecone Account

1. Go to https://www.pinecone.io
2. Click **Sign Up**
3. Create account with email or Google
4. Verify email

#### Step 2: Create Index

1. In Pinecone dashboard, click **Create Index**
2. Configure:
   - **Name**: `agentic-rag`
   - **Dimension**: `384` (sentence-transformers output)
   - **Metric**: `cosine`
   - **Pod type**: `starter` (free)
3. Click **Create**

#### Step 3: Get API Key

1. Go to **API Keys** in sidebar
2. Copy your **API Key**
3. Copy **Environment** (e.g., `us-east-1-aws`)

#### Step 4: Update Backend Code

Update `backend/core/orchestrator.py` to use Pinecone instead of ChromaDB:

```python
import pinecone

# Initialize Pinecone
pinecone.init(api_key=os.environ["PINECONE_API_KEY"], 
              environment=os.environ["PINECONE_ENV"])

# Create/get index
index = pinecone.Index("agentic-rag")

# Use index for vector operations
```

**Detailed migration coming in next section.**

#### Step 5: Add Environment Variables to Railway

1. Go to Railway Backend service → **Variables**
2. Add:
   ```
   PINECONE_API_KEY=your-api-key-here
   PINECONE_ENV=us-east-1-aws
   PINECONE_INDEX=agentic-rag
   ```
3. Save and redeploy

#### Step 6: Re-seed Knowledge Base

After deployment, seed documents via `/ingest` endpoint (same as before).

---

## Option 2: Weaviate Cloud

### Benefits
- Open source + managed cloud
- Great documentation
- GraphQL API
- Good for complex queries

### Setup

#### Step 1: Create Weaviate Cloud Account

1. Go to https://weaviate.io/cloud
2. Click **Sign Up**
3. Create account

#### Step 2: Create Cluster

1. In console, click **Create Cluster**
2. Name: `agentic-rag`
3. Wait for cluster creation (~2 min)

#### Step 3: Get Connection Details

1. Copy your **Cluster URL** (e.g., `https://xxx.weaviate.network`)
2. Go to **API Keys** and copy the key

#### Step 4: Update Backend Code

Update `backend/core/orchestrator.py`:

```python
import weaviate

client = weaviate.Client(
    url=os.environ["WEAVIATE_URL"],
    auth_client_secret=weaviate.AuthApiKey(
        api_key=os.environ["WEAVIATE_KEY"]
    )
)
```

#### Step 5: Add Environment Variables to Railway

```
WEAVIATE_URL=https://your-cluster.weaviate.network
WEAVIATE_KEY=your-api-key
```

---

## Option 3: LanceDB (Serverless)

### Benefits
- Serverless vector DB
- No infrastructure to manage
- Great for low-cost deployments
- Good for prototypes

### Setup

#### Step 1: Get LanceDB API Key

1. Go to https://lancedb.com
2. Create account
3. Get API key

#### Step 2: Update Backend Code

```python
import lancedb

db = lancedb.connect(
    api_key=os.environ["LANCEDB_API_KEY"],
    region="us-east-1"
)

table = db.create_table("documents")
```

#### Step 3: Add Environment Variables

```
LANCEDB_API_KEY=your-key
LANCEDB_REGION=us-east-1
```

---

## Migration Steps (Using Pinecone as Example)

### Step 1: Backup Current Data

Before migrating, export your current ChromaDB data:

```bash
# Local: run this to export embeddings
python -c "
from backend.core.orchestrator import AgenticRAGOrchestrator
orch = AgenticRAGOrchestrator()
data = orch.retriever._collection.get()
import json
with open('backup.json', 'w') as f:
    json.dump(data, f)
"
```

### Step 2: Create New Vector DB

Follow setup steps above for your chosen provider.

### Step 3: Update Backend

Modify `backend/core/orchestrator.py` to use new vector DB instead of ChromaDB:

**Current (file-based)**:
```python
from chromadb.config import Settings
import chromadb

# Initialize ChromaDB
chroma_client = chromadb.Client(Settings(...))
collection = chroma_client.get_or_create_collection(...)
```

**New (Pinecone example)**:
```python
import pinecone

# Initialize Pinecone
pinecone.init(
    api_key=os.environ["PINECONE_API_KEY"],
    environment=os.environ["PINECONE_ENV"]
)
index = pinecone.Index(os.environ["PINECONE_INDEX"])

# Upsert vectors
index.upsert(vectors=[(id, embedding) for id, embedding in ...])
```

### Step 4: Re-seed Knowledge Base

1. Deploy updated backend to Railway
2. Visit `/docs` endpoint
3. Use `/ingest` to seed documents
4. Data now persists in managed vector DB

### Step 5: Test

1. Try queries in frontend
2. Restart the backend service
3. Verify knowledge base still there ✅

---

## Cost Estimates

| Provider | Free Tier | Paid Tier |
|----------|-----------|-----------|
| **Pinecone** | 100k vectors | $0.25/million vectors |
| **Weaviate** | 1 cluster, limited | $25-100/mo |
| **LanceDB** | Pay-as-you-go | $0.10 per GB/month |

For small deployments (< 100k vectors), **all free tiers cover you**.

---

## FAQ

### Q: Will migration cause downtime?

**A**: Yes, brief downtime during the switch. Best to do during off-hours.

### Q: Can I test locally first?

**A**: Yes! Set up Pinecone locally and test with `python -m backend.seed_knowledge_base` before deploying.

### Q: How do I switch providers later?

**A**: Export data from old DB, import to new DB. Most have export/import tools.

### Q: What if I want to keep ChromaDB but add persistence?

**A**: Use Docker volumes on Railway or AWS S3 backup syncing. More complex, not recommended.

---

## Next Steps

1. Choose a vector DB (Pinecone recommended)
2. Create account and get API key
3. Update `backend/core/orchestrator.py` to use it
4. Add environment variables to Railway
5. Redeploy and seed knowledge base
6. Test end-to-end

Need help with a specific provider? Let me know! 🚀

