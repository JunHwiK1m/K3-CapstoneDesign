from src.ai.emotion_analyzer import EmotionAnalyzer
from src.service.recommendation_service import RecommendationService
from src.config.ai_config import ai_config
from openai import OpenAI
from tenacity import retry, stop_after_attempt, wait_exponential
import json
import random

class Orchestrator:
    """전체 AI 분석 프로세스를 제어하고 통합하는 비즈니스 로직(서비스 레이어) 오케스트레이터"""
    
    def __init__(self):
        self.emotion_analyzer = EmotionAnalyzer()
        self.recommendation_service = RecommendationService()
        self.client = OpenAI(api_key=ai_config.api_key)
        
    def analyze_journal(self, journal_id: int, content: str, persona_style: str, music_style: str = None, image_urls: list = None) -> dict:
        """일기 분석 파이프라인 (STT 로직 제거됨, 멀티모달 이미지 분석 추가됨)"""
        try:
            # 1. 감정 분석
            emotion_result = self.emotion_analyzer.analyze(content, persona_style, image_urls)
            
            # 2. 추천 및 피드백 생성
            # 백엔드 연동을 위해 임시로 Todo 및 UserSettings 구성
            todo_stats = {"total": 0, "completed": 0} 
            user_settings = {
                "advice_tone": persona_style,
                "music_style": music_style
            }
            
            recommendation_result = self.recommendation_service.get_recommendations(
                emotion_data=emotion_result, 
                diary_content=content, 
                todo_stats=todo_stats, 
                user_settings=user_settings, 
                categories=["MUSIC", "MOVIE", "FOOD"]
            )
            
            return {
                "journal_id": journal_id,
                "joy_score": emotion_result.get("joy_score", 0.0),
                "sadness_score": emotion_result.get("sadness_score", 0.0),
                "stress_level": emotion_result.get("stress_level", 0.0),
                "emotion_summary": emotion_result.get("emotion_summary", ""),
                "recommendations": recommendation_result.get("recommendations", [])
            }
            
        except Exception as e:
            # Fallback 처리는 개별 서비스에서 이미 수행하지만 최상위 안전망 구축
            fallback_emotion = self.emotion_analyzer._get_fallback_data(str(e))
            fallback_rec = self.recommendation_service._get_fallback_recommendations(["MUSIC", "MOVIE", "FOOD"], "37i9dQZF1DXcBWIGoYBM3M")
            return {
                "journal_id": journal_id,
                "joy_score": fallback_emotion.get("joy_score", 0.0),
                "sadness_score": fallback_emotion.get("sadness_score", 0.0),
                "stress_level": fallback_emotion.get("stress_level", 0.0),
                "emotion_summary": fallback_emotion.get("emotion_summary", ""),
                "recommendations": fallback_rec.get("recommendations", [])
            }

    @retry(stop=stop_after_attempt(3), wait=wait_exponential(multiplier=1, min=2, max=10))
    def _call_todo_openai(self, prompt: str) -> str:
        response = self.client.chat.completions.create(
            model=ai_config.llm_model,
            messages=[{"role": "user", "content": prompt}],
            response_format={"type": "json_object"}
        )
        return response.choices[0].message.content

    def generate_todo_feedback(self, total_count: int, completed_count: int, completion_rate: float, persona_style: str, recent_emotion: str) -> dict:
        """Todo 성취도 기반 피드백 생성 로직"""
        prompt = (
            f"당신은 사용자의 Todo 성취도를 바탕으로 격려 메시지를 작성하는 AI입니다.\n"
            f"상태 요약:\n"
            f"- 해야 할 일 총 {total_count}개 중 {completed_count}개 완료 (달성률: {completion_rate * 100:.1f}%)\n"
            f"- 사용자의 최근 감정 상태: {recent_emotion}\n"
            f"- 답변 톤앤매너: {persona_style}\n\n"
            "요구사항:\n"
            "1. 사용자의 감정 상태를 우선적으로 공감해주고, 그에 맞춰 달성률을 칭찬하거나 위로해주세요.\n"
            "2. 메시지는 최대 2~3문장으로 간결하게 작성하세요.\n"
            "3. 아래 JSON 형식으로 응답하세요.\n"
            "{\n"
            "  \"feedback_message\": \"생성된 메시지\"\n"
            "}"
        )
        
        try:
            content = self._call_todo_openai(prompt)
            return json.loads(content)
        except Exception:
            return {
                "feedback_message": "오늘 하루도 고생하셨습니다. 달성률에 상관없이 노력한 자신을 칭찬해주세요."
            }


