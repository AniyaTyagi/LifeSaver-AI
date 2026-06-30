import base64
import logging
from datetime import datetime, timedelta
from typing import List, Dict, Any, Optional

from cryptography.fernet import Fernet
from google.oauth2.credentials import Credentials
from googleapiclient.discovery import build

from app.core.config import settings

logger = logging.getLogger(__name__)

class TokenEncryption:
    """Helper service to encrypt/decrypt OAuth access and refresh tokens at rest."""
    
    @staticmethod
    def _get_fernet() -> Fernet:
        # Derive a key from the encryption secret
        key = settings.ENCRYPTION_SECRET_KEY
        # Ensure key is precisely 32 bytes and base64 encoded for Fernet
        padded_key = key.ljust(32)[:32].encode('utf-8')
        encoded_key = base64.urlsafe_b64encode(padded_key)
        return Fernet(encoded_key)
        
    @classmethod
    def encrypt(cls, token: str) -> str:
        if not token:
            return ""
        f = cls._get_fernet()
        return f.encrypt(token.encode('utf-8')).decode('utf-8')
        
    @classmethod
    def decrypt(cls, encrypted_token: str) -> str:
        if not encrypted_token:
            return ""
        f = cls._get_fernet()
        return f.decrypt(encrypted_token.encode('utf-8')).decode('utf-8')


class GoogleServicesConnector:
    """Service to connect and interact with Google Workspace APIs (Calendar, Gmail, Tasks)."""

    def __init__(self, access_token: str, refresh_token: Optional[str] = None, expiry: Optional[datetime] = None):
        # Create user credentials object from token details
        self.creds = Credentials(
            token=access_token,
            refresh_token=refresh_token,
            token_uri="https://oauth2.googleapis.com/token",
            client_id="your-client-id.apps.googleusercontent.com",  # Standard oauth placeholders
            client_secret="your-client-secret"
        )

    def _get_calendar_service(self):
        return build('calendar', 'v3', credentials=self.creds)

    def _get_gmail_service(self):
        return build('gmail', 'v1', credentials=self.creds)

    def _get_tasks_service(self):
        return build('tasks', 'v1', credentials=self.creds)

    # ==========================================
    # Google Calendar Operations
    # ==========================================
    
    def fetch_calendar_events(self, days_ahead: int = 7) -> List[Dict[str, Any]]:
        """Fetch primary calendar events for workload conflict checks."""
        try:
            service = self._get_calendar_service()
            now = datetime.utcnow().isoformat() + 'Z'
            time_max = (datetime.utcnow() + timedelta(days=days_ahead)).isoformat() + 'Z'
            
            events_result = service.events().list(
                calendarId='primary',
                timeMin=now,
                timeMax=time_max,
                singleEvents=True,
                orderBy='startTime'
            ).execute()
            
            events = events_result.get('items', [])
            parsed_events = []
            for event in events:
                parsed_events.append({
                    "id": event.get("id"),
                    "summary": event.get("summary", "No Title"),
                    "start": event.get("start", {}).get("dateTime") or event.get("start", {}).get("date"),
                    "end": event.get("end", {}).get("dateTime") or event.get("end", {}).get("date"),
                })
            return parsed_events
        except Exception as e:
            logger.error(f"Error fetching Google Calendar events: {e}")
            return []

    def create_calendar_block(self, summary: str, start_time: datetime, end_time: datetime, description: str = "") -> Optional[str]:
        """Creates a focus schedule block in the user's primary Google Calendar."""
        try:
            service = self._get_calendar_service()
            event_body = {
                'summary': f"[LifeSaver Focus] {summary}",
                'description': description or "Scheduled automatically by LifeSaver AI productivity coach.",
                'start': {
                    'dateTime': start_time.isoformat() + 'Z',
                    'timeZone': 'UTC',
                },
                'end': {
                    'dateTime': end_time.isoformat() + 'Z',
                    'timeZone': 'UTC',
                },
                'reminders': {
                    'useDefault': False,
                    'overrides': [
                        {'method': 'popup', 'minutes': 10},
                    ],
                },
            }
            event = service.events().insert(calendarId='primary', body=event_body).execute()
            return event.get('id')
        except Exception as e:
            logger.error(f"Error creating Google Calendar event: {e}")
            return None

    # ==========================================
    # Gmail Scan Operations
    # ==========================================

    def scan_recent_emails_for_deadlines(self, limit: int = 10) -> List[Dict[str, Any]]:
        """Scans recent emails to detect commitments/deadlines using keywords."""
        try:
            service = self._get_gmail_service()
            # Search filter: emails containing key commitment phrases
            query = "deadline OR assignment OR project OR meeting OR payment OR invoice"
            
            results = service.users().messages().list(userId='me', q=query, maxResults=limit).execute()
            messages = results.get('messages', [])
            
            email_contents = []
            for msg in messages:
                msg_detail = service.users().messages().get(userId='me', id=msg['id'], format='full').execute()
                payload = msg_detail.get('payload', {})
                headers = payload.get('headers', [])
                
                subject = "No Subject"
                sender = "Unknown Sender"
                for header in headers:
                    if header['name'] == 'Subject':
                        subject = header['value']
                    elif header['name'] == 'From':
                        sender = header['value']
                
                snippet = msg_detail.get('snippet', '')
                email_contents.append({
                    "id": msg['id'],
                    "subject": subject,
                    "sender": sender,
                    "snippet": snippet
                })
            return email_contents
        except Exception as e:
            logger.error(f"Error reading Gmail logs: {e}")
            return []

    # ==========================================
    # Google Tasks Sync Operations
    # ==========================================

    def sync_google_tasks(self) -> List[Dict[str, Any]]:
        """Fetches the user's active Google Tasks items."""
        try:
            service = self._get_tasks_service()
            tasklists = service.tasklists().list(maxResults=10).execute()
            lists = tasklists.get('items', [])
            
            all_tasks = []
            if lists:
                primary_list_id = lists[0]['id'] # Sync primary list
                tasks_result = service.tasks().list(tasklist=primary_list_id, showCompleted=False).execute()
                tasks = tasks_result.get('items', [])
                for t in tasks:
                    all_tasks.append({
                        "id": t.get("id"),
                        "title": t.get("title"),
                        "notes": t.get("notes"),
                        "due": t.get("due"),
                    })
            return all_tasks
        except Exception as e:
            logger.error(f"Error fetching Google Tasks: {e}")
            return []
