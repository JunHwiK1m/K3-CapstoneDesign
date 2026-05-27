import pytest
from src.models.db_entities import Journal, Emotion, Recommendation

def test_journal_entity():
    """Journal 엔티티 생성을 테스트합니다."""
    journal = Journal(content="오늘의 일기", voice_url="path/to/voice.mp3")
    assert journal.content == "오늘의 일기"
    assert journal.analysis_status == "PENDING"

def test_emotion_entity_range():
    """Emotion 지표 수치 범위를 테스트합니다."""
    emotion = Emotion(joy_score=0.8, sadness_score=0.1, stress_level=0.5)
    assert 0.0 <= emotion.joy_score <= 1.0
    assert 0.0 <= emotion.sadness_score <= 1.0
    assert 0.0 <= emotion.stress_level <= 1.0

def test_recommendation_song_format():
    """노래 추천 데이터의 구분자 포맷을 테스트합니다."""
    rec = Recommendation(category="MUSIC", content_text="가수*#*곡명")
    assert "*#*" in rec.content_text
