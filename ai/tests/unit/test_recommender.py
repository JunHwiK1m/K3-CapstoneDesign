import pytest
import re
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
                '{"category": "MUSIC", "content_text": "신나는 팝 플레이리스트", "external_link": "37i9dQZF1DXcBWIGoYBM3M"}, '
                '{"category": "MOVIE", "content_text": "넷플릭스 영화: 어바웃 타임", "external_link": "70273658"}, '
                '{"category": "FOOD", "content_text": "따뜻한 코코아 한 잔", "external_link": null}], '
                '"feedback_message": "오늘 하루 수고 많았어요. 80%나 해내셨네요!"}'
            )))
        ]
        mock_client.chat.completions.create.return_value = mock_response
        
        service = RecommendationService()
        result = service.get_recommendations(
            emotion_data={"joy_score": 0.5, "sadness_score": 0.5, "stress_level": 0.5},
            diary_content="테스트 일기 내용입니다.",
            todo_stats={"total": 5, "completed": 4},
            user_settings={"advice_tone": "FRIENDLY"},
            categories=["MUSIC", "MOVIE", "FOOD"]
        )
        
        assert len(result["recommendations"]) == 3
        
        # ID 형식 정규식 검증
        spotify_regex = re.compile(r"^[a-zA-Z0-9]{22}$")
        movie_regex = re.compile(r"^\d+$")
        
        for rec in result["recommendations"]:
            cat = rec.get("category")
            link = rec.get("external_link")
            if cat == "MUSIC":
                assert spotify_regex.match(link) is not None, f"Invalid Spotify ID: {link}"
            elif cat == "MOVIE":
                assert movie_regex.match(link) is not None, f"Invalid Movie ID: {link}"
            elif cat == "FOOD":
                assert link is None, f"FOOD external_link should be null, got: {link}"
                
        assert "80%" in result["feedback_message"]

def test_recommendation_fallback():
    """추천 실패 시 폴백 테스트"""
    with patch("src.service.recommendation_service.OpenAI") as mock_openai:
        mock_client = MagicMock()
        mock_openai.return_value = mock_client
        mock_client.chat.completions.create.side_effect = Exception("OpenAI Error")
        
        service = RecommendationService()
        result = service.get_recommendations({}, "실패 테스트", {}, {}, categories=["MUSIC", "MOVIE", "FOOD"])
        
        assert "고생 많으셨습니다" in result["feedback_message"]
        assert len(result["recommendations"]) == 3
        
        for rec in result["recommendations"]:
            if rec["category"] == "FOOD":
                assert rec.get("external_link") is None

