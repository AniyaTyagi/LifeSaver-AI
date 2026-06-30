from pydantic import BaseModel, Field
from typing import List, Optional, Dict, Any
from datetime import datetime

# ==========================================
# Core Database Entities
# ==========================================

class TaskBase(BaseModel):
    title: str
    description: Optional[str] = None
    dueDate: datetime
    estimatedEffortMinutes: int = 30
    dependencies: List[str] = []
    category: str = "personal" # work | academic | personal | billing
    status: str = "pending" # pending | in_progress | completed | missed

class TaskCreate(TaskBase):
    pass

class TaskUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    dueDate: Optional[datetime] = None
    estimatedEffortMinutes: Optional[int] = None
    dependencies: Optional[List[str]] = None
    category: Optional[str] = None
    status: Optional[str] = None

class TaskInDB(TaskBase):
    id: str
    userId: str
    createdAt: datetime

# --- Goals ---
class GoalBase(BaseModel):
    title: str
    category: str # academic | career | personal
    targetDate: datetime
    currentProgress: float = 0.0
    relatedTaskIds: List[str] = []

class GoalCreate(GoalBase):
    pass

class GoalInDB(GoalBase):
    id: str
    userId: str
    createdAt: datetime

# --- Habits ---
class HabitBase(BaseModel):
    title: str
    frequency: str = "daily" # daily | weekly
    streakCount: int = 0
    lastCompleted: Optional[datetime] = None
    completionHistory: Dict[str, bool] = {} # "YYYY-MM-DD": true

class HabitCreate(HabitBase):
    pass

class HabitInDB(HabitBase):
    id: str
    userId: str
    createdAt: datetime

# --- Schedules ---
class TimeBlock(BaseModel):
    start: datetime
    end: datetime
    type: str # focus_session | meeting | break | routine
    relatedTaskId: Optional[str] = None
    label: str

class DailySchedule(BaseModel):
    userId: str
    date: str # YYYY-MM-DD
    timeBlocks: List[TimeBlock]
    createdAt: datetime

# --- Focus Sessions ---
class FocusSessionStart(BaseModel):
    taskId: str
    plannedDurationMinutes: int = 25

class FocusSessionEnd(BaseModel):
    completedMilestones: List[str] = []
    focusScore: int = 80

class FocusSessionInDB(BaseModel):
    id: str
    userId: str
    taskId: str
    startTime: datetime
    endTime: Optional[datetime] = None
    plannedDurationMinutes: int
    actualDurationMinutes: Optional[int] = None
    completedMilestones: List[str] = []
    focusScore: Optional[int] = None

# ==========================================
# AI Structured Output Schemas (Gemini 2.5 Pro)
# ==========================================

# Agent 1: Task Understanding Schema
class ParsedTaskItem(BaseModel):
    title: str = Field(description="Summarized, actionable title of the task")
    description: Optional[str] = Field(None, description="Detailed description extracted from the prompt or context")
    estimated_effort_minutes: int = Field(30, description="Estimated time required to complete the task in minutes")
    category: str = Field("personal", description="Categorization: work, academic, personal, or billing")
    relative_due_date_description: str = Field(description="Literal description of the due date, e.g., 'next Friday at 5pm'")
    dependencies: List[str] = Field(default=[], description="List of titles of other tasks this task depends on")

class TaskUnderstandingResponse(BaseModel):
    tasks: List[ParsedTaskItem] = Field(description="List of tasks extracted from the input text")

# Agent 2: Risk Prediction Schema
class RiskPredictionResponse(BaseModel):
    miss_probability_score: float = Field(description="Probability between 0.0 and 1.0 of missing this deadline")
    risk_factors: List[str] = Field(description="Explanations of why this risk score was computed (e.g., workload overlaps)")
    risk_assessment: str = Field(description="Overall strategic assessment of the task risk level (High, Medium, Low)")

# Agent 3: Priority Optimization Schema
class PrioritizedTaskItem(BaseModel):
    task_id: str = Field(description="The unique task identifier")
    priority_score: float = Field(description="Calculated priority score (higher is more critical)")
    priority_level: str = Field(description="Level: Urgent, High, Medium, Low")
    rationale: str = Field(description="Brief reason for this specific prioritization ranking")

class PriorityOptimizationResponse(BaseModel):
    prioritized_tasks: List[PrioritizedTaskItem] = Field(description="Sorted list of tasks in order of recommended execution priority")

# Agent 4: Schedule Planning Schema
class ScheduledBlockItem(BaseModel):
    task_id: str = Field(description="The ID of the task to schedule")
    label: str = Field(description="Description of the schedule block")
    start_time: str = Field(description="ISO format string for block start time")
    end_time: str = Field(description="ISO format string for block end time")
    block_type: str = Field("focus_session", description="Block type: focus_session, routine, break")

class SchedulePlanningResponse(BaseModel):
    schedule_blocks: List[ScheduledBlockItem] = Field(description="List of calculated calendar blocks to add to the calendar")

# Agent 5: Intervention Schema
class InterventionResponse(BaseModel):
    should_intervene: bool = Field(description="True if the user requires proactive intervention for this task")
    notification_title: str = Field(description="The push notification header")
    notification_body: str = Field(description="The micro-copy body of the notification encouraging immediate action")
    suggested_action_code: str = Field(description="Action options: start_now, snooze, delegate, break_into_subtasks")

# Agent 6: Accountability Coach Schema
class AccountabilityCoachResponse(BaseModel):
    motivational_message: str = Field(description="Empathetic or direct coaching statement to counteract procrastination")
    micro_tasks: List[str] = Field(description="A sequential plan of 2 to 4 ultra-small tasks to ease into the main task")

# Agent 7: Recovery Schema
class RecoveryRescheduledItem(BaseModel):
    task_id: str = Field(description="Task ID needing shift")
    suggested_new_due_date: str = Field(description="New ISO format due date suggestion")
    reason: str = Field(description="Reason for shifting this item")

class RecoveryResponse(BaseModel):
    recovery_roadmap_steps: List[str] = Field(description="Detailed steps recommended to recover from the missed deadline")
    rescheduled_items: List[RecoveryRescheduledItem] = Field(description="Tasks that need to be dynamically shifted in response to the miss")
