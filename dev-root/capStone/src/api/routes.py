from fastapi import APIRouter, HTTPException
from src.api.schemas import JournalAnalysisRequest, JournalAnalysisResponse, ErrorResponse
from src.api.schemas import TodoFeedbackRequest, TodoFeedbackResponse
from src.service.orchestrator import Orchestrator

router = APIRouter()
orchestrator = Orchestrator()

@router.post("/analyze-journal", response_model=JournalAnalysisResponse)
async def analyze_journal(request: JournalAnalysisRequest):
    """일기 내용을 분석하여 감정 지표와 추천 콘텐츠를 반환합니다."""
    try:
        result = orchestrator.analyze_journal(
            journal_id=request.journal_id,
            content=request.content,
            persona_style=request.persona_style.value
        )
        return JournalAnalysisResponse(**result)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/todo-feedback", response_model=TodoFeedbackResponse)
async def todo_feedback(request: TodoFeedbackRequest):
    """Todo 달성률과 최근 감정 상태를 기반으로 격려 메시지를 반환합니다."""
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


