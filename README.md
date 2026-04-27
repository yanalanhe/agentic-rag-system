# Agentic RAG System

An end-to-end, executable Agentic RAG platform implementing a **multi-agents pipeline**:

**Planner → Retriever → Validator → Synthesizer**

The system is built for reliable enterprise retrieval workflows, with self-correction, full traceability, and a live orchestration dashboard.

---

## Key Components

- **Four-Agent Pipeline**
  - A coordinated multi-agent flow where each stage has a clear responsibility:
    - **Planner**: decomposes user intent into retrieval/analysis steps
    - **Retriever**: fetches candidate knowledge chunks from vector search
    - **Validator**: scores chunk quality and relevance against acceptance criteria
    - **Synthesizer**: composes final grounded response from validated evidence

- **Self-Correction Loop**
  - The **Validator** enforces quality thresholds for retrieved chunks.
  - If chunk quality falls below threshold, the Validator triggers **re-retrieval** (feedback loop) before synthesis.
  - This improves answer reliability and reduces low-signal outputs.

- **Full Traceability + Audit Trail**
  - Every agent action emits a structured event with a shared **`trace_id`**.
  - Events are logged across the full pipeline to support:
    - reproducibility
    - observability
    - compliance/audit review
    - root-cause analysis for failed or low-quality runs

- **FastAPI Orchestration + React Dashboard**
  - A **FastAPI orchestration layer** executes and manages the agent workflow.
  - A **React frontend dashboard** visualizes pipeline state in near real time, including stage transitions and execution progress.

- **ChromaDB Vector Store**
  - The system uses **ChromaDB** as its vector backend.
  - The knowledge base is **pre-seeded with enterprise documents** to support immediate retrieval and testing.

---

## High-Level Architecture

1. User query enters FastAPI orchestration endpoint.
2. Planner generates an execution plan.
3. Retriever pulls relevant chunks from ChromaDB.
4. Validator scores chunk quality/relevance.
5. If score is below threshold, Validator triggers re-retrieval.
6. Once validated, Synthesizer generates final response.
7. All steps emit structured trace events tied by `trace_id`.
8. React dashboard reflects live state of the running pipeline.

---

## Why This Design

- **Reliability**: self-correction prevents weak evidence from reaching synthesis.
- **Transparency**: trace-level logs make every decision inspectable.
- **Operational readiness**: API + dashboard supports both programmatic and visual monitoring.
- **Domain alignment**: pre-seeded enterprise corpus enables meaningful retrieval from day one.

---

## Usage

Run commands from the project root in this order.

### Initial setup (one-time or after dependency changes)

```bash
bash scripts/setup.sh
```

### Start the system

```bash
bash scripts/start.sh
```

### Stop the system

```bash
bash scripts/stop.sh
```