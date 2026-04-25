"""
FastAPI app entry point for Vercel deployment.
Imports and exports the app from the backend module.
"""
from backend.api.app import app

__all__ = ["app"]
