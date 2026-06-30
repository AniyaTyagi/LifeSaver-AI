import logging
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.api.endpoints import router as api_router
from app.core.config import settings

# Setup standard logger
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(name)s: %(message)s",
)
logger = logging.getLogger(__name__)

app = FastAPI(
    title=settings.PROJECT_NAME,
    version=settings.VERSION,
    description="The complete AI-powered backend service for LifeSaver AI."
)

# Set CORS permissions
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Restrict this to domain configurations in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Register API Router
app.include_router(api_router, prefix="/api")

@app.get("/")
async def root():
    """Health check endpoint confirming API online state."""
    return {
        "status": "healthy",
        "app": settings.PROJECT_NAME,
        "version": settings.VERSION,
        "engine": "Google Gemini 2.5 Pro via AI Studio",
        "database": "Cloud Firestore"
    }
