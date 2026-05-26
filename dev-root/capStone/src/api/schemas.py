from pydantic import BaseModel, Field
from typing import Optional, List
from enum import Enum

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

class JournalAnalysisRequest(BaseModel):
    journal_id: int
    content: str = Field(..., max_length=5000)
    voice_url: Optional[str] = None
    persona_style: PersonaStyle

class Recommendation(BaseModel):
    category: ContentCategory
    content_text: str
    external_link: Optional[str] = None

class JournalAnalysisResponse(BaseModel):
    journal_id: int
    joy_score: float
    sadness_score: float
    stress_level: float
    emotion_summary: str
    recommendations: List[Recommendation]

class TodoFeedbackRequest(BaseModel):
    total_count: int = Field(..., ge=0)
    completed_count: int = Field(..., ge=0)
    completion_rate: float = Field(..., ge=0.0, le=1.0)
    persona_style: PersonaStyle
    recent_emotion: EmotionCategory

class TodoFeedbackResponse(BaseModel):
    feedback_message: str

class ErrorResponse(BaseModel):
    status: str = "ERROR"
    message: str
    data: Optional[dict] = None
