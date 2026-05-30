from fastapi import APIRouter, HTTPException
from src.api.schemas import JournalAnalysisRequest, JournalAnalysisResponse, ErrorResponse
from src.api.schemas import TodoFeedbackRequest, TodoFeedbackResponse, DailyMessageResponse
from src.service.orchestrator import Orchestrator
import random

router = APIRouter(prefix="/api/ai")
orchestrator = Orchestrator()

@router.get("/daily-message", response_model=DailyMessageResponse)
async def get_daily_message():
    """사용자에게 응원이 되는 기본 메시지를 반환합니다."""
    messages = [
        "오늘 하루도 정말 수고 많으셨어요. 당신은 충분히 잘하고 있습니다.",
        "힘든 일이 있었다면 잠시 쉬어가도 괜찮아요. 내일은 더 밝은 날이 기다릴 거예요.",
        "당신의 노력을 제가 항상 응원하고 있다는 걸 잊지 마세요.",
        "작은 성취도 소중히 여기는 당신이 정말 멋집니다.",
        "오늘 하루, 당신에게 기분 좋은 일들만 가득하기를 바랍니다.",
        "당신은 생각보다 훨씬 더 강하고 멋진 사람이에요.",
        "포기하지 않고 나아가는 당신의 모습이 정말 아름답습니다.",
        "잠시 숨을 고르고 주변을 둘러보세요. 당신을 응원하는 마음들이 보일 거예요."
    ]
    return DailyMessageResponse(message=random.choice(messages))

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


