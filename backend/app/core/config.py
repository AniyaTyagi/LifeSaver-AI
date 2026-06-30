import os
from pydantic_settings import BaseSettings
from typing import Optional

class Settings(BaseSettings):
    PROJECT_NAME: str = "LifeSaver AI API"
    VERSION: str = "1.0.0"
    
    # API Credentials
    GEMINI_API_KEY: str = "placeholder_key"
    
    # Firebase configuration
    # Can load credentials path or use automatic environment authentication
    FIREBASE_CREDENTIALS_PATH: Optional[str] = None
    FIREBASE_PROJECT_ID: str = "lifesaver-ai"
    
    # Encryption key for storing Google Tokens in Firestore
    ENCRYPTION_SECRET_KEY: str = "supersecretencryptionkeylifesaver123"

    class Config:
        env_file = ".env"
        env_file_encoding = 'utf-8'

settings = Settings()
