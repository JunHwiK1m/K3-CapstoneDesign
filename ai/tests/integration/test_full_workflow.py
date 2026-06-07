import pytest
import time
from fastapi.testclient import TestClient
from src.main import app

client = TestClient(app)

def test_analyze_journal_integration():
    """/analyze-journal 엔드포인트 통합 테스트 및 5초 이내 응답 검증"""
    payload = {
        "journal_id": 1,
        "content": "통합 테스트 일기입니다.",
        "persona_style": "FRIENDLY"
    }
    
    start = time.time()
    response = client.post("/analyze-journal", json=payload)
    latency = time.time() - start
    
    assert response.status_code == 200
    data = response.json()
    assert data["journal_id"] == 1
    assert "joy_score" in data
    assert "recommendations" in data
    assert latency < 5.0, f"응답 지연 시간 초과: {latency:.2f}s"

def test_todo_feedback_integration():
    """/todo-feedback 엔드포인트 통합 테스트"""
    payload = {
        "total_count": 5,
        "completed_count": 3,
        "completion_rate": 0.6,
        "persona_style": "FRIENDLY",
        "recent_emotion": "JOY"
    }
    
    start = time.time()
    response = client.post("/todo-feedback", json=payload)
    latency = time.time() - start
    
    assert response.status_code == 200
    data = response.json()
    assert "feedback_message" in data
    assert latency < 5.0, f"응답 지연 시간 초과: {latency:.2f}s"

def test_schema_compliance_error():
    """요청 규격 위반 시 에러 처리(422) 검증"""
    payload = {
        "journal_id": 1
        # 필수 필드 content, persona_style 누락
    }
    response = client.post("/analyze-journal", json=payload)
    assert response.status_code == 422
