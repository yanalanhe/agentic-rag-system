"""
FastAPI app entry point for Vercel deployment.
Imports and exports the app from the backend module.
"""
import os
import google.generativeai as genai

# Ensure API key is configured at runtime (Vercel sets env vars at runtime, not build time)
_api_key = os.environ.get("GEMINI_API_KEY")
if _api_key:
    genai.configure(api_key=_api_key)

from backend.api.app import app

__all__ = ["app"]
