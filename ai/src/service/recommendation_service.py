import json
import random
import os
from openai import OpenAI
from tenacity import retry, stop_after_attempt, wait_exponential
from src.config.ai_config import ai_config
from src.ai.prompt_factory import PromptFactory

class RecommendationService:
    """사용자 상태를 기반으로 추천 및 피드백을 생성하는 서비스"""
    
    def __init__(self):
        self.client = OpenAI(api_key=ai_config.api_key)
        self._load_playlists()
        
    def _load_playlists(self):
        """Spotify 플레이리스트 ID 및 이름 풀 로드"""
        config_path = os.path.join(os.path.dirname(os.path.dirname(__file__)), "config", "spotify_playlists.json")
        try:
            with open(config_path, "r", encoding="utf-8") as f:
                self.playlists = json.load(f)
        except Exception:
            # 기본값 설정
            self.playlists = {
                "JOY": [{"id": "37i9dQZF1DXcBWIGoYBM3M", "title": "Today's Top Hits"}],
                "SADNESS": [{"id": "37i9dQZF1DX7qK8ma5xcIG", "title": "Alone Again"}],
                "STRESS": [{"id": "37i9dQZF1DWUvQoIOFVCie", "title": "Chill Lofi Study Beats"}],
                "NEUTRAL": [{"id": "37i9dQZF1DWZq91oLsHZvy", "title": "Mood Booster"}]
            }

    def _determine_dominant_emotion(self, emotion_data: dict) -> str:
        """감정 지표를 바탕으로 지배적인 감정을 결정"""
        scores = {
            "JOY": emotion_data.get("joy_score", 0),
            "SADNESS": emotion_data.get("sadness_score", 0),
            "STRESS": emotion_data.get("stress_level", 0)
        }
        max_emotion = max(scores, key=scores.get)
        # 모든 수치가 너무 낮으면 중립으로 간주
        if scores[max_emotion] < 0.2:
            return "NEUTRAL"
        return max_emotion
        
    @retry(stop=stop_after_attempt(3), wait=wait_exponential(multiplier=1, min=2, max=10))
    def _call_openai(self, system_prompt: str) -> str:
        response = self.client.chat.completions.create(
            model=ai_config.llm_model,
            messages=[{"role": "user", "content": system_prompt}],
            response_format={"type": "json_object"},
            temperature=0.8
        )
        return response.choices[0].message.content
        
    def get_recommendations(self, emotion_data: dict, diary_content: str, todo_stats: dict, user_settings: dict, categories: list = None) -> dict:
        """감정 분석 결과와 일기 원문을 바탕으로 추천을 생성한다."""
        if categories is None:
            categories = ["MUSIC", "FOOD", "MOVIE"]
            
        total_todos = todo_stats.get("total", 0)
        completed_todos = todo_stats.get("completed", 0)
        todo_rate = (completed_todos / total_todos) if total_todos > 0 else 0.0
        
        dominant_emotion = self._determine_dominant_emotion(emotion_data)
        playlist_entry = random.choice(self.playlists.get(dominant_emotion, [{"id": "37i9dQZF1DXcBWIGoYBM3M", "title": "Today's Top Hits"}]))
        spotify_id = playlist_entry["id"]
        spotify_title = playlist_entry["title"]
        
        system_prompt = PromptFactory.create_recommendation_prompt(user_settings, emotion_data, diary_content, categories, todo_rate, spotify_id, spotify_title)
        
        try:
            content = self._call_openai(system_prompt)
            result = json.loads(content)
            
            return result
                
        except Exception:
            return self._get_fallback_recommendations(categories, spotify_id)
            
    def _get_fallback_recommendations(self, categories: list, spotify_id: str) -> dict:
        """생성 실패 시 반환할 기본 추천 데이터"""
        food_fallbacks = [
            {"text": "따뜻하고 부드러운 죽이나 스프", "link": "죽"},
            {"text": "기분 전환을 위한 달콤한 초콜릿 디저트", "link": "초콜릿"},
            {"text": "스트레스 해소에 좋은 매콤한 음식", "link": "매운음식"}
        ]
        movie_fallbacks = [
            {"text": "넷플릭스 영화: 어바웃 타임", "link": "70273658"},
            {"text": "넷플릭스 영화: 인턴", "link": "80023873"},
            {"text": "넷플릭스 영화: 리틀 포레스트", "link": "81013444"}
        ]
        
        selected_food = random.choice(food_fallbacks)
        selected_movie = random.choice(movie_fallbacks)

        fallbacks = {
            "MUSIC": {
                "category": "MUSIC", 
                "content_text": "마음을 달래주는 플레이리스트",
                "external_link": spotify_id
            },
            "FOOD": {
                "category": "FOOD", 
                "content_text": selected_food["text"],
                "external_link": selected_food["link"]
            },
            "MOVIE": {
                "category": "MOVIE", 
                "content_text": selected_movie["text"],
                "external_link": selected_movie["link"]
            }
        }
        
        recommendations = [fallbacks.get(cat, {"category": cat, "content_text": "추천 준비 중", "external_link": None}) for cat in categories]
        
        return {
            "recommendations": recommendations,
            "feedback_message": "오늘 하루도 고생 많으셨습니다. 내일은 더 좋은 일이 생길 거예요."
        }


