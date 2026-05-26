import pytest
from unittest.mock import patch, MagicMock
from src.ai.emotion_analyzer import EmotionAnalyzer

def test_analyze_text_emotion():
    """텍스트 감정 분석 단위 테스트"""
    with patch("src.ai.emotion_analyzer.OpenAI") as mock_openai:
        # Mocking OpenAI response
        mock_client = MagicMock()
        mock_openai.return_value = mock_client
        
        mock_response = MagicMock()
        mock_response.choices = [
            MagicMock(message=MagicMock(content='{"joy_score": 0.8, "sadness_score": 0.1, "stress_level": 0.2, "emotion_summary": "매우 즐거운 상태입니다."}'))
        ]
        mock_client.chat.completions.create.return_value = mock_response
        
        analyzer = EmotionAnalyzer()
        result = analyzer.analyze("오늘 진짜 행복해!")
        
        assert result["joy_score"] == 0.8
        assert result["sadness_score"] == 0.1
        assert result["stress_level"] == 0.2
        assert result["emotion_summary"] == "매우 즐거운 상태입니다."

def test_analyze_failure_fallback():
    """분석 실패 시 폴백 데이터 반환 테스트"""
    with patch("src.ai.emotion_analyzer.OpenAI") as mock_openai:
        mock_client = MagicMock()
        mock_openai.return_value = mock_client
        mock_client.chat.completions.create.side_effect = Exception("OpenAI Error")
        
        analyzer = EmotionAnalyzer()
        result = analyzer.analyze("분석 실패 케이스")
        
        # 기본값 반환 확인 (0.0 또는 특정 기본 메시지)
        assert result["joy_score"] == 0.0
        assert "분석을 완료하지 못했습니다" in result["emotion_summary"]
