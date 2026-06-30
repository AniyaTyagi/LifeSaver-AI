from fastapi import APIRouter, Depends, HTTPException, Header, status
from typing import List, Dict, Any, Optional
from datetime import datetime, timezone
import uuid
import logging

from firebase_admin import auth
from app.core.firebase import db
from app.models import schemas
from app.agents.agents import (
    TaskUnderstandingAgent,
    RiskPredictionAgent,
    PriorityOptimizationAgent,
    SchedulePlanningAgent,
    InterventionAgent,
    AccountabilityCoachAgent,
    RecoveryAgent
)
from app.services.google_services import GoogleServicesConnector

logger = logging.getLogger(__name__)
router = APIRouter()

# ==========================================
# Authentication Dependency
# ==========================================

async def get_current_user_id(authorization: Optional[str] = Header(None)) -> str:
    """Extracts user UID from Bearer Firebase ID Token. Fails gracefully to mock for testing."""
    if not authorization or not authorization.startswith("Bearer "):
        logger.info("No valid Bearer token provided. Falling back to test user 'mock_user_123'.")
        return "mock_user_123"
    
    token = authorization.split("Bearer ")[1]
    try:
        decoded_token = auth.verify_id_token(token)
        return decoded_token['uid']
    except Exception as e:
        logger.warning(f"Failed to authenticate Firebase Token: {e}. Falling back to 'mock_user_123'.")
        return "mock_user_123"

# ==========================================
# Tasks CRUD Endpoints
# ==========================================

@router.get("/tasks", response_model=List[schemas.TaskInDB])
async def get_tasks(user_id: str = Depends(get_current_user_id)):
    """Fetch all pending and completed tasks for the authenticated user."""
    try:
        tasks_ref = db.collection("tasks").where("userId", "==", user_id).stream()
        tasks = []
        for doc in tasks_ref:
            data = doc.to_dict()
            # Convert datetime strings/timestamps
            if "dueDate" in data and not isinstance(data["dueDate"], datetime):
                data["dueDate"] = datetime.fromisoformat(data["dueDate"].replace("Z", "+00:00"))
            if "createdAt" in data and not isinstance(data["createdAt"], datetime):
                data["createdAt"] = datetime.fromisoformat(data["createdAt"].replace("Z", "+00:00"))
            tasks.append(schemas.TaskInDB(id=doc.id, **data))
        return tasks
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Database read failed: {e}")

@router.post("/tasks", response_model=schemas.TaskInDB)
async def create_task(task_in: schemas.TaskCreate, user_id: str = Depends(get_current_user_id)):
    """Create a new task in Firestore."""
    try:
        task_id = str(uuid.uuid4())
        task_data = task_in.model_dump()
        task_data["userId"] = user_id
        task_data["createdAt"] = datetime.utcnow()
        
        # Save to database
        db.collection("tasks").document(task_id).set(task_data)
        
        return schemas.TaskInDB(id=task_id, **task_data)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Database write failed: {e}")

@router.put("/tasks/{task_id}", response_model=schemas.TaskInDB)
async def update_task(task_id: str, task_in: schemas.TaskUpdate, user_id: str = Depends(get_current_user_id)):
    """Update task details in Firestore."""
    try:
        task_ref = db.collection("tasks").document(task_id)
        doc = task_ref.get()
        if not doc.exists:
            raise HTTPException(status_code=404, detail="Task not found")
        
        existing_data = doc.to_dict()
        if existing_data.get("userId") != user_id:
            raise HTTPException(status_code=403, detail="Not authorized to edit this task")
            
        update_data = task_in.model_dump(exclude_unset=True)
        task_ref.update(update_data)
        
        # Build complete model response
        for k, v in update_data.items():
            existing_data[k] = v
            
        return schemas.TaskInDB(id=task_id, **existing_data)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Database update failed: {e}")

# ==========================================
# voice / Natural Text Task Extraction (Agent 1)
# ==========================================

class VoiceAnalyzeRequest(BaseModel := type('VoiceAnalyzeRequest', (object,), {})):
    text: str

@router.post("/tasks/voice-analyze")
async def voice_analyze_task(req: Dict[str, str], user_id: str = Depends(get_current_user_id)):
    """Agent 1: Parse natural text input or transcript to extract structured tasks."""
    user_text = req.get("text", "")
    if not user_text:
        raise HTTPException(status_code=400, detail="Text input is required")
        
    current_time_str = datetime.utcnow().strftime("%Y-%m-%d %H:%M:%S UTC")
    
    # Process text using Agent 1
    parsed_tasks_response = TaskUnderstandingAgent.parse_input(user_text, current_time_str)
    
    created_tasks = []
    # Save the parsed tasks to the database
    for item in parsed_tasks_response.tasks:
        task_id = str(uuid.uuid4())
        
        # Estimate deadline from text descriptor
        # Fallback to 2 days ahead if relative description is parsed simplistically
        due_date = datetime.utcnow() + timedelta(days=2)
        
        task_data = {
            "userId": user_id,
            "title": item.title,
            "description": item.description or f"Auto-extracted. Relative deadline: {item.relative_due_date_description}",
            "dueDate": due_date,
            "estimatedEffortMinutes": item.estimated_effort_minutes,
            "dependencies": item.dependencies,
            "category": item.category,
            "status": "pending",
            "createdAt": datetime.utcnow()
        }
        db.collection("tasks").document(task_id).set(task_data)
        created_tasks.append(schemas.TaskInDB(id=task_id, **task_data))
        
    return {"message": "Tasks parsed and created successfully", "tasks": created_tasks}

# ==========================================
# Agent Core Pipelines Endpoints (Agents 2 - 7)
# ==========================================

@router.post("/agents/risk-predict/{task_id}", response_model=schemas.RiskPredictionResponse)
async def predict_task_risk(task_id: str, user_id: str = Depends(get_current_user_id)):
    """Agent 2: Calculate deadline failure risk metrics for a specific task."""
    # 1. Fetch Task
    task_doc = db.collection("tasks").document(task_id).get()
    if not task_doc.exists:
        raise HTTPException(status_code=404, detail="Task not found")
    task_data = task_doc.to_dict()
    
    # 2. Get Workload Details (count active user tasks)
    active_tasks = db.collection("tasks").where("userId", "==", user_id).where("status", "==", "pending").get()
    workload_summary = f"User has {len(active_tasks)} pending tasks."
    
    # 3. Predict Risk using Agent 2
    risk_report = RiskPredictionAgent.calculate_risk(task_data, workload_summary, calendar_conflicts=2)
    
    # 4. Save risk score log to database
    db.collection("riskScores").document().set({
        "userId": user_id,
        "taskId": task_id,
        "riskScore": risk_report.miss_probability_score,
        "factors": risk_report.risk_factors,
        "calculatedAt": datetime.utcnow()
    })
    
    return risk_report

@router.post("/agents/prioritize")
async def optimize_priorities(user_id: str = Depends(get_current_user_id)):
    """Agent 3: Sort tasks using Eisenhower priority algorithms."""
    # 1. Get pending user tasks
    tasks_ref = db.collection("tasks").where("userId", "==", user_id).where("status", "==", "pending").get()
    tasks = []
    for doc in tasks_ref:
        data = doc.to_dict()
        data["id"] = doc.id
        tasks.append(data)
        
    if not tasks:
        return {"message": "No pending tasks to prioritize", "prioritized_tasks": []}
        
    # 2. Order using Agent 3
    priority_response = PriorityOptimizationAgent.prioritize_tasks(tasks)
    return priority_response

@router.post("/agents/schedule")
async def schedule_focus_blocks(user_id: str = Depends(get_current_user_id)):
    """Agent 4: Synchronize calendar and automatically schedule task work blocks."""
    # 1. Fetch pending tasks
    tasks_ref = db.collection("tasks").where("userId", "==", user_id).where("status", "==", "pending").get()
    tasks = [dict(doc.to_dict(), id=doc.id) for doc in tasks_ref]
    
    # 2. Load calendar bookings placeholder/mock (or fetch via OAuth token if saved)
    calendar_events = [{"summary": "Team Review Sync", "startTime": "2026-06-25T10:00:00Z", "endTime": "2026-06-25T11:00:00Z"}]
    working_hours = {"start": "09:00", "end": "18:00"}
    
    # 3. Schedule via Agent 4
    schedule_response = SchedulePlanningAgent.create_schedule(
        tasks, calendar_events, working_hours, datetime.utcnow().strftime("%Y-%m-%d")
    )
    
    # 4. Write new schedule blocks to database
    schedule_doc_id = f"{user_id}_{datetime.utcnow().strftime('%Y-%m-%d')}"
    db.collection("schedules").document(schedule_doc_id).set({
        "userId": user_id,
        "date": datetime.utcnow().strftime("%Y-%m-%d"),
        "timeBlocks": [block.model_dump() for block in schedule_response.schedule_blocks],
        "createdAt": datetime.utcnow()
    })
    
    return schedule_response

@router.post("/agents/intervention/{task_id}", response_model=schemas.InterventionResponse)
async def check_intervention(task_id: str, user_id: str = Depends(get_current_user_id)):
    """Agent 5: Check risk and create interactive notification triggers if needed."""
    task_doc = db.collection("tasks").document(task_id).get()
    if not task_doc.exists:
        raise HTTPException(status_code=404, detail="Task not found")
    task_data = task_doc.to_dict()
    
    # Calculate hours remaining to deadline
    due_date = task_data.get("dueDate")
    if isinstance(due_date, str):
        due_date = datetime.fromisoformat(due_date.replace("Z", "+00:00"))
    
    # Ensure timezone aware subtraction
    if due_date.tzinfo is None:
        due_date = due_date.replace(tzinfo=timezone.utc)
    now_utc = datetime.now(timezone.utc)
    
    hours_remaining = (due_date - now_utc).total_seconds() / 3600.0
    
    # Evaluate using Agent 5
    intervention = InterventionAgent.evaluate_intervention(task_data, hours_remaining)
    
    # If intervention is active, save a notification item
    if intervention.should_intervene:
        db.collection("notifications").document().set({
            "userId": user_id,
            "title": intervention.notification_title,
            "body": intervention.notification_body,
            "isRead": False,
            "createdAt": datetime.utcnow(),
            "actionPayload": {
                "screen": "FocusMode",
                "params": {"taskId": task_id}
            }
        })
        
    return intervention

@router.post("/agents/coach-procrastinate/{task_id}", response_model=schemas.AccountabilityCoachResponse)
async def coach_procrastination(task_id: str, snooze_count: int = 1, user_id: str = Depends(get_current_user_id)):
    """Agent 6: Run accountability coach chat prompts when user postpones scheduling."""
    task_doc = db.collection("tasks").document(task_id).get()
    if not task_doc.exists:
        raise HTTPException(status_code=404, detail="Task not found")
    task_data = task_doc.to_dict()
    
    # Get coaching text and micro-steps from Agent 6
    coaching_result = AccountabilityCoachAgent.coach_procrastination(task_data, snooze_count)
    
    # Log recommendation to DB
    db.collection("aiRecommendations").document().set({
        "userId": user_id,
        "taskId": task_id,
        "recommendationType": "procrastination_coach",
        "message": coaching_result.motivational_message,
        "suggestedActions": [{"label": step, "actionCode": "do_micro_task"} for step in coaching_result.micro_tasks],
        "status": "pending",
        "createdAt": datetime.utcnow()
    })
    
    return coaching_result

@router.post("/agents/recovery/{task_id}", response_model=schemas.RecoveryResponse)
async def run_recovery_plan(task_id: str, user_id: str = Depends(get_current_user_id)):
    """Agent 7: Build a recovery outline when a deadline is missed."""
    task_doc = db.collection("tasks").document(task_id).get()
    if not task_doc.exists:
        raise HTTPException(status_code=404, detail="Task not found")
    task_data = task_doc.to_dict()
    
    # Fetch tasks depending on the missed task
    dependent_ref = db.collection("tasks").where("userId", "==", user_id).where("dependencies", "array_contains", task_data.get("title")).get()
    dependent_tasks = [dict(doc.to_dict(), id=doc.id) for doc in dependent_ref]
    
    # Run Agent 7
    recovery_plan = RecoveryAgent.build_recovery(task_data, dependent_tasks, datetime.utcnow().isoformat())
    
    # Save the recovery recommendations
    db.collection("aiRecommendations").document().set({
        "userId": user_id,
        "taskId": task_id,
        "recommendationType": "recovery_plan",
        "message": "Missed Deadline Recovery Plan",
        "suggestedActions": [{"label": step, "actionCode": "execute_recovery"} for step in recovery_plan.recovery_roadmap_steps],
        "status": "pending",
        "createdAt": datetime.utcnow()
    })
    
    return recovery_plan
