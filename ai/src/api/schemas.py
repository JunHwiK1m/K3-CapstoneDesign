from pydantic import BaseModel, Field, ConfigDict
from pydantic.alias_generators import to_camel
from typing import Optional, List
from enum import Enum

class BaseSchema(BaseModel):
    """모든 스키마에 카멜 케이스 적용을 위한 베이스 클래스"""
    model_config = ConfigDict(
        alias_generator=to_camel,
        populate_by_name=True,
        from_attributes=True
    )

class PersonaStyle(str, Enum):
    BASIC = "BASIC"
    FRIENDLY = "FRIENDLY"
    STRICT = "STRICT"

class EmotionCategory(str, Enum):
    JOY = "JOY"
    SADNESS = "SADNESS"
    STRESS = "STRESS"
    NEUTRAL = "NEUTRAL"

class ContentCategory(str, Enum):
    MUSIC = "MUSIC"
    MOVIE = "MOVIE"
    FOOD = "FOOD"

class JournalAnalysisRequest(BaseSchema):
    journal_id: int
    content: str = Field(..., max_length=5000)
    voice_url: Optional[str] = None
    persona_style: PersonaStyle

class Recommendation(BaseSchema):
    category: ContentCategory
    content_text: str
    external_link: Optional[str] = None

class JournalAnalysisResponse(BaseSchema):
    journal_id: int
    joy_score: float
    sadness_score: float
    stress_level: float
    emotion_summary: str
    recommendations: List[Recommendation]

class TodoFeedbackRequest(BaseSchema):
    total_count: int = Field(..., ge=0)
    completed_count: int = Field(..., ge=0)
    completion_rate: float = Field(..., ge=0.0, le=1.0)
    persona_style: PersonaStyle
    recent_emotion: EmotionCategory

class TodoFeedbackResponse(BaseSchema):
    feedback_message: str

class DailyMessageResponse(BaseSchema):
    message: str

class ErrorResponse(BaseSchema):
    status: str = "ERROR"
    message: str
    data: Optional[dict] = None

