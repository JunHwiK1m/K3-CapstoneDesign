import pytest
from unittest.mock import patch, MagicMock
from src.service.recommendation_service import RecommendationService

def test_generate_recommendations():
    """맞춤형 추천 및 피드백 생성 테스트"""
    with patch("src.service.recommendation_service.OpenAI") as mock_openai:
        mock_client = MagicMock()
        mock_openai.return_value = mock_client
        
        mock_response = MagicMock()
        mock_response.choices = [
            MagicMock(message=MagicMock(content=(
                '{"recommendations": ['
                '{"category": "MUSIC", "content_text": "아이유*#*밤편지"}, '
                '{"category": "FOOD", "content_text": "따뜻한 코코아 한 잔"}], '
                '"feedback_message": "오늘 하루 수고 많았어요. 80%나 해내셨네요!"}'
            )))
        ]
        mock_client.chat.completions.create.return_value = mock_response
        
        service = RecommendationService()
        result = service.get_recommendations(
            emotion_data={"joy_score": 0.5, "sadness_score": 0.5, "stress_level": 0.5},
            diary_content="테스트 일기 내용입니다.",
            todo_stats={"total": 5, "completed": 4},
            user_settings={"advice_tone": "FRIENDLY"}
        )
        
        assert len(result["recommendations"]) == 2
        assert result["recommendations"][0]["content_text"] == "아이유*#*밤편지"
        assert "80%" in result["feedback_message"]

def test_recommendation_fallback():
    """추천 실패 시 폴백 테스트"""
    with patch("src.service.recommendation_service.OpenAI") as mock_openai:
        mock_client = MagicMock()
        mock_openai.return_value = mock_client
        mock_client.chat.completions.create.side_effect = Exception("OpenAI Error")
        
        service = RecommendationService()
        result = service.get_recommendations({}, "실패 테스트", {}, {})
        
        assert result["feedback_message"] == "오늘 하루도 고생 많으셨습니다. 내일은 더 좋은 일이 생길 거예요."
        assert len(result["recommendations"]) > 0
