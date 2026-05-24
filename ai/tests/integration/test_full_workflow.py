import pytest
from unittest.mock import patch, MagicMock
from src.models.db_entities import Journal
from src.service.orchestrator import Orchestrator

@pytest.fixture
def mock_ai_services():
    with patch("src.ai.emotion_analyzer.OpenAI") as mock_openai_emotion, \
         patch("src.service.recommendation_service.OpenAI") as mock_openai_rec, \
         patch("src.ai.stt_service.whisper") as mock_whisper:
        
        # Mock OpenAI Client for Emotion
        mock_client_emotion = MagicMock()
        mock_openai_emotion.return_value = mock_client_emotion
        
        emotion_response = MagicMock()
        emotion_response.choices = [
            MagicMock(message=MagicMock(content='{"joy_score": 0.7, "sadness_score": 0.2, "stress_level": 0.1, "emtion_summary": "행복한 하루"}'))
        ]
        mock_client_emotion.chat.completions.create.return_value = emotion_response
        
        # Mock OpenAI Client for Recommendation
        mock_client_rec = MagicMock()
        mock_openai_rec.return_value = mock_client_rec
        
        rec_response = MagicMock()
        rec_response.choices = [
            MagicMock(message=MagicMock(content='{"recommendations": [{"category": "MUSIC", "content_text": "곡"}], "feedback_message": "굿"}'))
        ]
        mock_client_rec.chat.completions.create.return_value = rec_response
        
        # Mock STT
        mock_model = MagicMock()
        mock_model.transcribe.return_value = {"text": "음성 변환 텍스트"}
        mock_whisper.load_model.return_value = mock_model
        
        yield {
            "emotion_client": mock_client_emotion,
            "rec_client": mock_client_rec,
            "stt": mock_model
        }

def test_full_workflow_success(mock_ai_services):
    """전체 분석 워크플로우 성공 케이스 통합 테스트"""
    journal = Journal(
        journal_id=1,
        user_id=10,
        content="진짜 좋은 날이다.",
        voice_url=None
    )
    
    # Mock Repository/DAO if necessary, but here we test the orchestrator logic
    orchestrator = Orchestrator()
    result = orchestrator.run_analysis(journal)
    
    assert result["status"] == "COMPLETED"
    assert result["emotion"]["joy_score"] == 0.7
    assert result["recommendation"]["feedback_message"] == "굿"

def test_full_workflow_with_voice(mock_ai_services):
    """음성 메모가 포함된 전체 워크플로우 테스트"""
    journal = Journal(
        journal_id=2,
        user_id=11,
        content="",
        voice_url="test.wav"
    )
    
    with patch("src.ai.stt_service.os.path.exists", return_value=True):
        orchestrator = Orchestrator()
        result = orchestrator.run_analysis(journal)
        
        assert result["status"] == "COMPLETED"
        mock_ai_services["stt"].transcribe.assert_called_once()
