# LifeSaver AI: Deployment, Security, & Scalability Plan

This guide details the infrastructure deployment workflows, security models, and scalability patterns for **LifeSaver AI**.

---

## 1. Deployment Guide

The deployment strategy leverage Google Cloud Platform and Firebase.

```
                  ┌──────────────────────┐
                  │   Firebase Hosting   │ ◄─── Frontend (Flutter Web)
                  └──────────┬───────────┘
                             │
                             ▼
 ┌───────────────┐  HTTPS  ┌──────────────────┐  OAuth2  ┌───────────────────────┐
 │ Mobile Device │ ◄──────►│ Google Cloud Run │ ◄──────► │ Google Workspace APIs │
 └───────────────┘         └────────┬─────────┘          └───────────────────────┘
                                    │
                                    ▼
                        ┌──────────────────────┐
                        │   Cloud Firestore    │
                        └──────────────────────┘
```

### 1.1. FastAPI Backend (Google Cloud Run)
FastAPI is containerized using Docker and deployed to **Google Cloud Run** to support serverless auto-scaling.

#### Dockerfile Configuration
The container is configured to build rapidly and execute asynchronously:
```dockerfile
FROM python:3.10-slim

ENV PYTHONUNBUFFERED=1 \
    PORT=8000

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

CMD exec uvicorn app.main:app --host 0.0.0.0 --port $PORT
```

#### Deploy Command
Deploy directly to Cloud Run:
```powershell
gcloud run deploy lifesaver-backend `
  --source . `
  --platform managed `
  --region us-central1 `
  --allow-unauthenticated `
  --set-env-vars="GEMINI_API_KEY=your_key,FIREBASE_PROJECT_ID=lifesaver-ai"
```

### 1.2. Flutter Frontend (Firebase Hosting)
Firebase Hosting serves the Flutter Web build, while Flutter Mobile binaries (APK/IPA) are uploaded to Google Play Console and Apple App Store.

#### Build Web Asset
```powershell
flutter build web --release
```

#### Deploy to Hosting
Initialize Firebase in the `frontend` directory and deploy:
```powershell
firebase deploy --only hosting
```

---

## 2. Security Architecture

LifeSaver AI maintains security controls across all application layers.

### 2.1. Authentication & JWT Validation
* **Identity Management:** Firebase Authentication handles registration and logins.
* **Token Verification:** Every request to the FastAPI backend includes a Bearer Token (Firebase ID Token).
* **Decryption Middleware:** FastAPI decodes the token using the `firebase_admin` SDK, verifying signatures, expiry, and extracting the user's `uid`.

### 2.2. Firebase Security Rules (Firestore)
Ensure users can only access their own documents:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Core user validation helper
    function isOwner(userId) {
      return request.auth != null && request.auth.uid == userId;
    }

    match /users/{userId} {
      allow read, write: if isOwner(userId);
    }
    
    match /tasks/{taskId} {
      allow read, write: if request.auth != null && resource.data.userId == request.auth.uid;
      allow create: if request.auth != null && request.resource.data.userId == request.auth.uid;
    }
    
    match /goals/{goalId} {
      allow read, write: if request.auth != null && resource.data.userId == request.auth.uid;
      allow create: if request.auth != null && request.resource.data.userId == request.auth.uid;
    }

    match /habits/{habitId} {
      allow read, write: if request.auth != null && resource.data.userId == request.auth.uid;
      allow create: if request.auth != null && request.resource.data.userId == request.auth.uid;
    }
    
    match /schedules/{scheduleId} {
      // Document ID contains userId, e.g., "uid_date"
      allow read, write: if request.auth != null && scheduleId.startsWith(request.auth.uid);
    }
  }
}
```

### 2.3. Google API Scopes & OAuth Handling
The application requests minimal permissions:
* `https://www.googleapis.com/auth/calendar.events` (Manage Google Calendar events)
* `https://www.googleapis.com/auth/gmail.readonly` (Scan emails for upcoming deadlines)
* `https://www.googleapis.com/auth/tasks` (Sync native task lists)

Tokens are encrypted using AES-256 before being written to the database.

---

## 3. Scalability Plan

### 3.1. Firestore Sharding & Indexes
Firestore performs query checks on single documents without scanning collections. We add composite indexes to ensure queries remain efficient:
* **Composite Index:** `tasks`: `userId` (Ascending) + `status` (Ascending) + `dueDate` (Descending).

### 3.2. FastAPI Async & Concurrency
* **Uvicorn Worker Model:** We run FastAPI with multiple worker nodes to handle network I/O.
* **Non-Blocking Calls:** All HTTP requests to Google AI Studio (Gemini) and the Google APIs use `httpx.AsyncClient` or async wrappers, preventing server thread pool starvation.

### 3.3. Cache Optimization
* **Schedule Cache:** We store calculated risk logs and schedule plans in Redis or internal cache systems with a 15-minute TTL, avoiding redundant LLM processing for unchanged workloads.
* **Workspace Token Caching:** Decoded OAuth tokens are cached locally in memory for 1 hour to reduce decryptions and database reads.
