import logging
import uuid
from typing import Any
import firebase_admin
from firebase_admin import credentials, firestore
from app.core.config import settings


logger = logging.getLogger(__name__)

# ==========================================
# In-Memory Mock Firestore Database
# ==========================================

_MOCK_DB_STORE = {
    "tasks": {
        "task_1": {
            "title": "Compiler Project Design",
            "description": "Auto-extracted. Relative deadline: Friday",
            "dueDate": "2026-06-26T23:59:00",
            "estimatedEffortMinutes": 120,
            "dependencies": ["Gather requirements", "AST grammar review"],
            "category": "academic",
            "status": "pending",
            "userId": "mock_user_123",
            "createdAt": "2026-06-24T12:00:00"
        },
        "task_2": {
            "title": "File Q3 Tax Returns",
            "description": "Prepare invoices and gather revenue numbers",
            "dueDate": "2026-06-27T18:00:00",
            "estimatedEffortMinutes": 240,
            "dependencies": [],
            "category": "work",
            "status": "pending",
            "userId": "mock_user_123",
            "createdAt": "2026-06-24T12:00:00"
        }
    },
    "riskScores": {},
    "aiRecommendations": {},
    "schedules": {},
    "notifications": {},
    "goals": {},
    "habits": {}
}

class MockDocumentReference:
    def __init__(self, collection_name, doc_id):
        self.collection_name = collection_name
        self.id = doc_id

    @property
    def exists(self) -> bool:
        return self.id in _MOCK_DB_STORE.get(self.collection_name, {})

    def get(self):
        return self

    def to_dict(self) -> dict:
        return _MOCK_DB_STORE.get(self.collection_name, {}).get(self.id, {})

    def set(self, data: dict):
        if self.collection_name not in _MOCK_DB_STORE:
            _MOCK_DB_STORE[self.collection_name] = {}
        # Normalize datetime elements
        serializable_data = {}
        for k, v in data.items():
            if hasattr(v, "isoformat"):
                serializable_data[k] = v.isoformat()
            else:
                serializable_data[k] = v
        _MOCK_DB_STORE[self.collection_name][self.id] = serializable_data

    def update(self, data: dict):
        if self.collection_name not in _MOCK_DB_STORE:
            _MOCK_DB_STORE[self.collection_name] = {}
        if self.id not in _MOCK_DB_STORE[self.collection_name]:
            _MOCK_DB_STORE[self.collection_name][self.id] = {}
        
        for k, v in data.items():
            if hasattr(v, "isoformat"):
                _MOCK_DB_STORE[self.collection_name][self.id][k] = v.isoformat()
            else:
                _MOCK_DB_STORE[self.collection_name][self.id][k] = v

class MockQuery:
    def __init__(self, collection_name, filter_conditions=None):
        self.collection_name = collection_name
        self.filter_conditions = filter_conditions or []

    def where(self, field: str, op: str, value: Any):
        new_filters = list(self.filter_conditions)
        new_filters.append((field, op, value))
        return MockQuery(self.collection_name, new_filters)

    def _get_filtered_docs(self) -> list:
        docs_dict = _MOCK_DB_STORE.get(self.collection_name, {})
        filtered = []
        for doc_id, data in docs_dict.items():
            match = True
            for field, op, value in self.filter_conditions:
                doc_val = data.get(field)
                if op == "==":
                    if doc_val != value:
                        match = False
                elif op == "array_contains":
                    if not isinstance(doc_val, list) or value not in doc_val:
                        match = False
            if match:
                filtered.append(MockDocumentReference(self.collection_name, doc_id))
        return filtered

    def stream(self) -> list:
        return self._get_filtered_docs()

    def get(self) -> list:
        return self._get_filtered_docs()

class MockCollection:
    def __init__(self, name: str):
        self.name = name

    def document(self, doc_id: str = None) -> MockDocumentReference:
        if not doc_id:
            doc_id = str(uuid.uuid4())
        return MockDocumentReference(self.name, doc_id)

    def where(self, field: str, op: str, value: Any) -> MockQuery:
        return MockQuery(self.name).where(field, op, value)

    def stream(self) -> list:
        docs_dict = _MOCK_DB_STORE.get(self.name, {})
        return [MockDocumentReference(self.name, doc_id) for doc_id in docs_dict.keys()]

    def get(self) -> list:
        return self.stream()

class MockFirestoreClient:
    def collection(self, name: str) -> MockCollection:
        return MockCollection(name)

# ==========================================
# Client Orchestrator
# ==========================================

db = None

def initialize_firebase():
    """Initializes Firebase Admin SDK or sets up Mock Client."""
    global db
    try:
        # Check if already initialized to prevent errors during multiple calls or tests
        firebase_admin.get_app()
        db = firestore.client()
        logger.info("Firebase Admin SDK successfully connected.")
    except Exception:
        if settings.FIREBASE_CREDENTIALS_PATH:
            try:
                cred = credentials.Certificate(settings.FIREBASE_CREDENTIALS_PATH)
                firebase_admin.initialize_app(cred, {
                    'projectId': settings.FIREBASE_PROJECT_ID,
                })
                db = firestore.client()
                logger.info("Firebase Firestore client initialized using credentials file.")
                return
            except Exception as e:
                logger.warning(f"Failed to load credentials certificate: {e}. Trying default ADC.")

        try:
            firebase_admin.initialize_app()
            db = firestore.client()
            logger.info("Firebase Firestore client initialized using Application Default Credentials.")
        except Exception as e:
            logger.warning(f"Could not initialize Google Cloud Credentials: {e}. Spinning up local database engine.")
            db = MockFirestoreClient()

initialize_firebase()

