import pytest
from src.service.orchestrator import Orchestrator
from unittest.mock import patch, MagicMock

def test_generate_todo_feedback():
    """Todo 피드백 로직의 단위 테스트"""
    with patch("src.service.orchestrator.EmotionAnalyzer") as mock_analyzer:
        # Orchestrator 내부는 내부적으로 OpenAI를 호출할 수도 있지만,
        # 이 테스트는 Orchestrator의 generate_todo_feedback이 올바른 응답 형태를 반환하는지 테스트
        # 실제로는 GPT-4o에 프롬프트를 보내 메시지를 받아야 함.
        pass

    with patch("src.service.orchestrator.OpenAI") as mock_openai:
        mock_client = MagicMock()
        mock_openai.return_value = mock_client
        mock_response = MagicMock()
        mock_response.choices = [
            MagicMock(message=MagicMock(content='{"feedback_message": "잘 해내셨어요! 정말 대견합니다."}'))
        ]
        mock_client.chat.completions.create.return_value = mock_response

        orchestrator = Orchestrator()
        # orchestrator가 내부적으로 openai 클라이언트를 생성하게 할 수도 있지만,
        # 이미 RecommendationService, EmotionAnalyzer 등에서 생성하고 있음.
        # Todo 피드백은 별도의 메서드로 GPT에 호출하도록 구현.
        result = orchestrator.generate_todo_feedback(
            total_count=5,
            completed_count=3,
            completion_rate=0.6,
            persona_style="FRIENDLY",
            recent_emotion="SADNESS"
        )
        assert result["feedback_message"] == "잘 해내셨어요! 정말 대견합니다."

def test_generate_todo_feedback_fallback():
    """Todo 피드백 로직 예외 발생 시 폴백 테스트"""
    with patch("src.service.orchestrator.OpenAI") as mock_openai:
        mock_client = MagicMock()
        mock_openai.return_value = mock_client
        mock_client.chat.completions.create.side_effect = Exception("OpenAI Error")

        orchestrator = Orchestrator()
        result = orchestrator.generate_todo_feedback(
            total_count=5,
            completed_count=3,
            completion_rate=0.6,
            persona_style="FRIENDLY",
            recent_emotion="SADNESS"
        )
        assert "고생하셨습니다" in result["feedback_message"] or "괜찮아요" in result["feedback_message"]
