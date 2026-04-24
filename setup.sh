#!/usr/bin/env bash
# =============================================================================
# Hands-On: Agentic RAG System
# =============================================================================
set -euo pipefail

# ─── Colors ───────────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'

log()    { echo -e "${GREEN}${NC} $1"; }
warn()   { echo -e "${YELLOW}[WARN]${NC} $1"; }
err()    { echo -e "${RED}[ERR]${NC} $1"; exit 1; }
header() { echo -e "\n${BOLD}${CYAN}══ $1 ══${NC}"; }

header "Agentic RAG End-to-End Setup"
log "Building: Planner → Retriever → Validator → Synthesizer pipeline"

# ─── Config ───────────────────────────────────────────────────────────────────
PROJECT_ROOT="${PWD}"
BACKEND_DIR="${PROJECT_ROOT}/backend"
FRONTEND_DIR="${PROJECT_ROOT}/frontend"
DATA_DIR="${PROJECT_ROOT}/data"
SCRIPTS_DIR="${PROJECT_ROOT}/scripts"
VENV_DIR="${PROJECT_ROOT}/.venv"
# Set GEMINI_API_KEY before running setup/start (get a key at https://aistudio.google.com/apikey)
GEMINI_API_KEY="${GEMINI_API_KEY:-}"
BACKEND_PORT=8043
FRONTEND_PORT=3043

# ─── Prerequisites ────────────────────────────────────────────────────────────
header "Checking Prerequisites"
PYTHON_CMD="/c/Users/User/AppData/Local/Programs/Python/Python310/python.exe"
[ -f "$PYTHON_CMD" ] || PYTHON_CMD="python3"
command -v node    >/dev/null 2>&1 || err "node required"
command -v npm     >/dev/null 2>&1 || err "npm required"
PY_VER=$("$PYTHON_CMD" --version | awk '{print $2}')
NODE_VER=$(node --version)
log "Python: ${PY_VER} | Node: ${NODE_VER}"

# ─── Directory Structure ──────────────────────────────────────────────────────
header "Creating Project Structure"
mkdir -p "${BACKEND_DIR}/agents"
mkdir -p "${BACKEND_DIR}/core"
mkdir -p "${BACKEND_DIR}/api"
mkdir -p "${BACKEND_DIR}/data/chroma_data"
mkdir -p "${DATA_DIR}/documents"
mkdir -p "${SCRIPTS_DIR}"
mkdir -p "${FRONTEND_DIR}/src/components"
mkdir -p "${FRONTEND_DIR}/public"
log "Directory structure created"

# ─── Python Virtual Environment ──────────────────────────────────────────────
header "Setting Up Python Environment"
create_venv() {
    if "$PYTHON_CMD" -m venv "${VENV_DIR}" 2>/dev/null; then
        log "Virtual environment created (with ensurepip)"
        return 0
    fi
}
if [ ! -f "${VENV_DIR}/Scripts/activate" ]; then
    [ -d "${VENV_DIR}" ] && rm -rf "${VENV_DIR}"
    create_venv
fi
source "${VENV_DIR}/Scripts/activate"
pip install --upgrade pip --quiet 2>/dev/null || true

# ─── Install Python Dependencies (after all files exist) ─────────────────────
header "Installing Python Dependencies"
pip install -r "${PROJECT_ROOT}/requirements.txt" --quiet
log "Python dependencies installed"

# ─── Install Frontend Dependencies ────────────────────────────────────────────
header "Installing Frontend Dependencies"
cd "${FRONTEND_DIR}" && npm install --quiet 2>/dev/null
log "Frontend dependencies installed"
cd "${PROJECT_ROOT}"

# ─── Final Summary ────────────────────────────────────────────────────────────
header "Setup Complete"
echo ""
echo -e "${BOLD}${GREEN}╔═══════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${GREEN}║   Agentic RAG End-to-End — Ready to Run!    ║${NC}"
echo -e "${BOLD}${GREEN}╚═══════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "  ${CYAN}Start:${NC}    bash ${SCRIPTS_DIR}/start.sh"
echo -e "  ${CYAN}Test:${NC}     bash ${SCRIPTS_DIR}/test.sh"
echo -e "  ${CYAN}Stop:${NC}     bash ${SCRIPTS_DIR}/stop.sh"
echo ""
echo -e "  ${CYAN}Backend:${NC}  http://localhost:${BACKEND_PORT}"
echo -e "  ${CYAN}Frontend:${NC} http://localhost:${FRONTEND_PORT}"
echo -e "  ${CYAN}API Docs:${NC} http://localhost:${BACKEND_PORT}/docs"
echo ""
echo -e "  ${YELLOW}Pipeline:${NC} Planner → Retriever → Validator → Synthesizer"
echo ""
echo -e "  ${BOLD}Project:${NC} ${PROJECT_ROOT}"
log "setup complete!"