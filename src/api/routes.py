from fastapi import APIRouter, HTTPException
from src.api.schemas import JournalAnalysisRequest, JournalAnalysisResponse, ErrorResponse
from src.api.schemas import TodoFeedbackRequest, TodoFeedbackResponse
from src.service.orchestrator import Orchestrator

router = APIRouter(prefix="/api/ai")
orchestrator = Orchestrator()

@router.post("/journals", response_model=JournalAnalysisResponse)
async def analyze_journal(request: JournalAnalysisRequest):
    """일기 리소스에 대한 AI 감정 분석 및 추천을 수행합니다."""
    try:
        result = orchestrator.analyze_journal(
            journal_id=request.journal_id,
            content=request.content,
            persona_style=request.persona_style.value
        )
        return JournalAnalysisResponse(**result)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/todos/feedback", response_model=TodoFeedbackResponse)
async def todo_feedback(request: TodoFeedbackRequest):
    """Todo 리소스에 대한 성취도 피드백을 생성합니다."""
    try:
        result = orchestrator.generate_todo_feedback(
            total_count=request.total_count,
            completed_count=request.completed_count,
            completion_rate=request.completion_rate,
            persona_style=request.persona_style.value,
            recent_emotion=request.recent_emotion.value
        )
        return TodoFeedbackResponse(**result)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


