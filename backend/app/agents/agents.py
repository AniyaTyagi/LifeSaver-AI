import json
import logging
from typing import List, Dict, Any, Optional
import google.generativeai as genai
from google.generativeai.types import GenerationConfig

from app.core.config import settings
from app.models.schemas import (
    TaskUnderstandingResponse,
    RiskPredictionResponse,
    PriorityOptimizationResponse,
    SchedulePlanningResponse,
    InterventionResponse,
    AccountabilityCoachResponse,
    RecoveryResponse
)

logger = logging.getLogger(__name__)

# Configure Google AI Studio / Gemini API
if settings.GEMINI_API_KEY and settings.GEMINI_API_KEY != "placeholder_key":
    genai.configure(api_key=settings.GEMINI_API_KEY)
else:
    logger.warning("GEMINI_API_KEY not configured. AI operations will use mock fallback mode.")

# Model configuration
MODEL_NAME = "gemini-2.5-pro"  # Google's flagship model for complex reasoning and agent pipelines

def _call_gemini_structured(prompt: str, system_instruction: str, response_schema: Any) -> Any:
    """Helper method to make a structured call to Gemini 2.5 Pro."""
    # Check for api key configuration fallback
    if not settings.GEMINI_API_KEY or settings.GEMINI_API_KEY == "placeholder_key":
        return _mock_fallback(response_schema)
        
    try:
        model = genai.GenerativeModel(
            model_name=MODEL_NAME,
            system_instruction=system_instruction
        )
        
        config = GenerationConfig(
            response_mime_type="application/json",
            response_schema=response_schema,
            temperature=0.2  # Low temperature for stable structure and parsing accuracy
        )
        
        response = model.generate_content(
            prompt,
            generation_config=config
        )
        
        # Parse the structured JSON response into Pydantic model
        result_json = json.loads(response.text)
        return response_schema.model_validate(result_json)
    except Exception as e:
        logger.error(f"Gemini API call failed: {e}. Executing structured recovery fallback.")
        return _mock_fallback(response_schema)

def _mock_fallback(schema_class: Any) -> Any:
    """Mock recovery data to ensure application reliability when API key is missing or rate-limited."""
    if schema_class == TaskUnderstandingResponse:
        return TaskUnderstandingResponse(tasks=[{
            "title": "Quick Review Task",
            "description": "Auto-extracted placeholder assignment",
            "estimated_effort_minutes": 60,
            "category": "personal",
            "relative_due_date_description": "tomorrow at 5pm",
            "dependencies": []
        }])
    elif schema_class == RiskPredictionResponse:
        return RiskPredictionResponse(
            miss_probability_score=0.45,
            risk_factors=["Overlapping work blocks detected in primary schedule"],
            risk_assessment="Medium"
        )
    elif schema_class == PriorityOptimizationResponse:
        return PriorityOptimizationResponse(prioritized_tasks=[
            {"task_id": "placeholder_id", "priority_score": 0.85, "priority_level": "High", "rationale": "Urgent deadline approaching"}
        ])
    elif schema_class == SchedulePlanningResponse:
        return SchedulePlanningResponse(schedule_blocks=[])
    elif schema_class == InterventionResponse:
        return InterventionResponse(
            should_intervene=True,
            notification_title="Let's Start Now",
            notification_body="You have 90 minutes remaining on your task. Let's do it!",
            suggested_action_code="start_now"
        )
    elif schema_class == AccountabilityCoachResponse:
        return AccountabilityCoachResponse(
            motivational_message="A journey of a thousand miles begins with a single step.",
            micro_tasks=["Open document", "Read first 2 lines"]
        )
    elif schema_class == RecoveryResponse:
        return RecoveryResponse(
            recovery_roadmap_steps=["Analyze backlog", "Re-schedule remaining blocks"],
            rescheduled_items=[]
        )
    return None

# ==========================================
# 7-Agent Orchestrator Functions
# ==========================================

class TaskUnderstandingAgent:
    """Agent 1: Extracts structured tasks, metadata, efforts, and dependencies from natural inputs."""
    SYSTEM_INSTRUCTION = (
        "You are the Task Understanding Agent. Your job is to parse text, voice transcripts, or emails "
        "and extract tasks. You must estimate the time effort in minutes, identify dependencies, "
        "and extract relative deadlines (e.g., 'next Monday' or 'in 2 days'). Current reference local time is "
        "provided in the prompt. Return a structured list of parsed tasks."
    )
    
    @staticmethod
    def parse_input(user_input: str, current_time: str) -> TaskUnderstandingResponse:
        prompt = f"Current Time Context: {current_time}\nUser Input: '{user_input}'"
        return _call_gemini_structured(prompt, TaskUnderstandingAgent.SYSTEM_INSTRUCTION, TaskUnderstandingResponse)


class RiskPredictionAgent:
    """Agent 2: Evaluates failure probabilities based on workload and user profile."""
    SYSTEM_INSTRUCTION = (
        "You are the Risk Prediction Agent. You calculate a 'Miss Probability Score' (0.0 to 1.0) "
        "indicating how likely a user is to miss a task deadline. "
        "Evaluate this based on: remaining time to deadline, estimated task effort, the user's workload, "
        "overlapping calendar events, and their historical completion trends. List the main risk factors."
    )
    
    @staticmethod
    def calculate_risk(task: Dict[str, Any], workload_summary: str, calendar_conflicts: int) -> RiskPredictionResponse:
        prompt = (
            f"Task details: {json.dumps(task, default=str)}\n"
            f"Active Workload Summary: {workload_summary}\n"
            f"Calendar Meeting Conflicts: {calendar_conflicts}"
        )
        return _call_gemini_structured(prompt, RiskPredictionAgent.SYSTEM_INSTRUCTION, RiskPredictionResponse)


class PriorityOptimizationAgent:
    """Agent 3: Sorts and prioritizes active tasks using urgency, importance, and risk metrics."""
    SYSTEM_INSTRUCTION = (
        "You are the Priority Optimization Agent. Your goal is to rank a list of tasks in order "
        "of recommended execution. Use their deadlines, effort, and risk scores. "
        "Urgent/high-risk tasks should be prioritized. Provide a priority score and brief rationale for each."
    )
    
    @staticmethod
    def prioritize_tasks(tasks: List[Dict[str, Any]]) -> PriorityOptimizationResponse:
        prompt = f"Analyze and prioritize this task list: {json.dumps(tasks, default=str)}"
        return _call_gemini_structured(prompt, PriorityOptimizationAgent.SYSTEM_INSTRUCTION, PriorityOptimizationResponse)


class SchedulePlanningAgent:
    """Agent 4: Maps high-priority tasks into open calendar windows within working hours."""
    SYSTEM_INSTRUCTION = (
        "You are the Schedule Planning Agent. Your job is to schedule focus blocks for pending tasks. "
        "You are provided with user tasks, current calendar events, and working hour boundaries. "
        "Return time blocks representing when the user should work on these tasks, avoiding conflicts."
    )
    
    @staticmethod
    def create_schedule(tasks: List[Dict[str, Any]], calendar_events: List[Dict[str, Any]], working_hours: Dict[str, str], current_date: str) -> SchedulePlanningResponse:
        prompt = (
            f"Current Date: {current_date}\n"
            f"Working Hours: {json.dumps(working_hours)}\n"
            f"Tasks to Schedule: {json.dumps(tasks, default=str)}\n"
            f"Calendar Bookings (Conflicts): {json.dumps(calendar_events, default=str)}"
        )
        return _call_gemini_structured(prompt, SchedulePlanningAgent.SYSTEM_INSTRUCTION, SchedulePlanningResponse)


class InterventionAgent:
    """Agent 5: Decides if an approaching task is critical enough to trigger an active notification."""
    SYSTEM_INSTRUCTION = (
        "You are the Intervention Agent. Determine if a task with high miss risk requires immediate intervention. "
        "If yes, draft a compelling, proactive title and body copy with an action code. "
        "Do not make it passive. Write micro-copy that prompts immediate, friction-free action."
    )
    
    @staticmethod
    def evaluate_intervention(task: Dict[str, Any], hours_remaining: float) -> InterventionResponse:
        prompt = f"Task: {json.dumps(task, default=str)}\nHours remaining to deadline: {hours_remaining}"
        return _call_gemini_structured(prompt, InterventionAgent.SYSTEM_INSTRUCTION, InterventionResponse)


class AccountabilityCoachAgent:
    """Agent 6: Intervenes during procrastination by breaking tasks into micro-steps."""
    SYSTEM_INSTRUCTION = (
        "You are the Accountability Coach Agent. The user is procrastinating (e.g., snoozing blocks). "
        "Write a direct, yet empathetic coaching message. Break down their complex task into 2 to 4 "
        "micro-tasks that take less than 10 minutes to complete. Reduce friction to start."
    )
    
    @staticmethod
    def coach_procrastination(task: Dict[str, Any], snooze_count: int) -> AccountabilityCoachResponse:
        prompt = f"Task: {json.dumps(task, default=str)}\nTimes this task was snoozed: {snooze_count}"
        return _call_gemini_structured(prompt, AccountabilityCoachAgent.SYSTEM_INSTRUCTION, AccountabilityCoachResponse)


class RecoveryAgent:
    """Agent 7: Builds roadmaps and shifts timelines dynamically when a deadline is missed."""
    SYSTEM_INSTRUCTION = (
        "You are the Recovery Agent. The user has missed a deadline. You must assess the fallout. "
        "Review the missed task and downstream dependent tasks. Re-calculate deadlines to accommodate "
        "the miss and create a recovery roadmap to get the user back on track."
    )
    
    @staticmethod
    def build_recovery(missed_task: Dict[str, Any], dependent_tasks: List[Dict[str, Any]], current_time: str) -> RecoveryResponse:
        prompt = (
            f"Current Time: {current_time}\n"
            f"Missed Task: {json.dumps(missed_task, default=str)}\n"
            f"Dependent Tasks: {json.dumps(dependent_tasks, default=str)}"
        )
        return _call_gemini_structured(prompt, RecoveryAgent.SYSTEM_INSTRUCTION, RecoveryResponse)
