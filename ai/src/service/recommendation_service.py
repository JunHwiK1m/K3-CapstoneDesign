import json
from openai import OpenAI
from src.config.ai_config import ai_config
from src.ai.prompt_factory import PromptFactory

class RecommendationService:
    """사용자 상태를 기반으로 추천 및 피드백을 생성하는 서비스"""
    
    def __init__(self):
        self.client = OpenAI(api_key=ai_config.api_key)
        
    def get_recommendations(self, emotion_data: dict, diary_content: str, todo_stats: dict, user_settings: dict, categories: list = None) -> dict:
        """감정 분석 결과와 일기 원문을 바탕으로 추천을 생성한다."""
        if categories is None:
            categories = ["MUSIC", "FOOD"]
            
        total_todos = todo_stats.get("total", 0)
        completed_todos = todo_stats.get("completed", 0)
        todo_rate = (completed_todos / total_todos) if total_todos > 0 else 0.0
        
        system_prompt = PromptFactory.create_recommendation_prompt(user_settings, emotion_data, diary_content, categories, todo_rate)
        
        try:
            response = self.client.chat.completions.create(
                model=ai_config.llm_model,
                messages=[{"role": "user", "content": system_prompt}],
                response_format={"type": "json_object"}
            )
            
            content = response.choices[0].message.content
            return json.loads(content)
                
        except Exception:
            return self._get_fallback_recommendations(categories)
            
    def _get_fallback_recommendations(self, categories: list) -> dict:
        """생성 실패 시 반환할 기본 추천 데이터"""
        fallbacks = {
            "MUSIC": {
                "category": "MUSIC", 
                "content_text": "아이유*#*Love wins all",
                "external_link": "https://open.spotify.com/search/아이유+Love+wins+all"
            },
            "FOOD": {
                "category": "FOOD", 
                "content_text": "신선한 샐러드"
            },
            "MOVIE": {
                "category": "MOVIE", 
                "content_text": "어바웃 타임",
                "external_link": "https://www.netflix.com/search?q=어바웃타임"
            }
        }
        
        recommendations = [fallbacks.get(cat, {"category": cat, "content_text": "추천 준비 중"}) for cat in categories]
        
        return {
            "recommendations": recommendations,
            "feedback_message": "오늘 하루도 고생 많으셨습니다. 내일은 더 좋은 일이 생길 거예요."
        }
