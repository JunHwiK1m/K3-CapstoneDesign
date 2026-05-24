from dataclasses import dataclass, field
from datetime import datetime
from typing import Optional

@dataclass
class User:
    """사용자 엔티티"""
    user_id: Optional[int] = None
    email: str = ""
    password_hash: Optional[str] = None
    provider: Optional[str] = None
    provider_id: Optional[str] = None
    name: str = ""
    role: str = "GENERAL"

@dataclass
class Journal:
    """사용자 일기 및 메모 엔티티"""
    journal_id: Optional[int] = None
    user_id: int = 0
    content: str = ""
    voice_url: Optional[str] = None
    img_url: Optional[str] = None
    analysis_status: str = "PENDING"
    created_at: datetime = field(default_factory=datetime.now)

@dataclass
class Todo:
    """할 일 엔티티"""
    todo_id: Optional[int] = None
    user_id: int = 0
    task_name: str = ""
    is_completed: bool = False
    due_date: Optional[datetime] = None
    completed_at: Optional[datetime] = None
    created_at: datetime = field(default_factory=datetime.now)

@dataclass
class Emotion:
    """감정 분석 결과 엔티티"""
    emotion_id: Optional[int] = None
    journal_id: int = 0
    joy_score: float = 0.0
    sadness_score: float = 0.0
    stress_level: float = 0.0
    emtion_summary: str = ""
    analyzed_at: datetime = field(default_factory=datetime.now)

@dataclass
class Recommendation:
    """추천 솔루션 엔티티"""
    rec_id: Optional[int] = None
    journal_id: int = 0
    category: str = ""
    content_text: str = ""
    external_link: Optional[str] = None
    fallback_url: Optional[str] = None
    is_clicked: bool = False

@dataclass
class UserSetting:
    """사용자 개인화 설정 엔티티"""
    setting_id: Optional[int] = None
    user_id: int = 0
    usage_purpose: Optional[str] = None
    diary_time: Optional[str] = None
    profile_image: Optional[str] = None
    persona_style: str = "FRIENDLY"
    birth_date: Optional[datetime] = None
    advice_tone: str = "INFORMAL"
    music_style: Optional[str] = None
    wake_up_time: Optional[str] = None
    nickname: Optional[str] = None
    updated_at: datetime = field(default_factory=datetime.now)

@dataclass
class Item:
    """아이템 엔티티"""
    item_id: Optional[int] = None
    item_type: str = ""
    item_name: str = ""
    price: int = 0
    resource_url: str = ""
    created_at: datetime = field(default_factory=datetime.now)

@dataclass
class UserItem:
    """사용자 보유 아이템 엔티티"""
    user_item_id: Optional[int] = None
    user_id: int = 0
    item_id: int = 0
    is_equipped: bool = False
    purchased_at: datetime = field(default_factory=datetime.now)
