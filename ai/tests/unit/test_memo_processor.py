import pytest
from datetime import datetime
from src.models.db_entities import Journal
from src.service.memo_processor import MemoProcessor

def test_preprocess_text_memo():
    """텍스트 메모 전처리 테스트"""
    journal = Journal(
        journal_id=1,
        user_id=100,
        content="오늘 기분이 참 좋다.",
        created_at=datetime.now()
    )
    processor = MemoProcessor()
    processed_data = processor.process(journal)
    
    assert processed_data["type"] == "text"
    assert processed_data["content"] == "오늘 기분이 참 좋다."
    assert processed_data["user_id"] == 100

def test_preprocess_voice_memo():
    """음성 메모 전처리 테스트 (URL 포함 시)"""
    journal = Journal(
        journal_id=2,
        user_id=101,
        content="",
        voice_url="https://example.com/voice.wav",
        created_at=datetime.now()
    )
    processor = MemoProcessor()
    processed_data = processor.process(journal)
    
    assert processed_data["type"] == "voice"
    assert processed_data["voice_url"] == "https://example.com/voice.wav"
    assert processed_data["user_id"] == 101

def test_preprocess_mixed_memo():
    """텍스트와 음성이 모두 있는 경우 테스트"""
    journal = Journal(
        journal_id=3,
        user_id=102,
        content="음성도 같이 보낸다.",
        voice_url="https://example.com/mixed.wav",
        created_at=datetime.now()
    )
    processor = MemoProcessor()
    processed_data = processor.process(journal)
    
    assert processed_data["type"] == "mixed"
    assert processed_data["content"] == "음성도 같이 보낸다."
    assert processed_data["voice_url"] == "https://example.com/mixed.wav"
