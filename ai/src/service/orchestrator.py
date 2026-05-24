from src.models.db_entities import Journal
from src.service.memo_processor import MemoProcessor
from src.ai.stt_service import AudioService
from src.ai.emotion_analyzer import EmotionAnalyzer
from src.service.recommendation_service import RecommendationService

class Orchestrator:
    """전체 AI 분석 프로세스를 제어하고 통합하는 오케스트레이터"""
    
    def __init__(self):
        self.memo_processor = MemoProcessor()
        self.audio_service = AudioService()
        self.emotion_analyzer = EmotionAnalyzer()
        self.recommendation_service = RecommendationService()
        
    def run_analysis(self, journal: Journal, categories: list = None) -> dict:
        """단일 저널 엔티티에 대해 전체 분석 파이프라인을 실행한다."""
        try:
            # 1. 전처리
            processed_data = self.memo_processor.process(journal)
            content = processed_data["content"]
            
            # 2. 음성 변환 (필요시)
            if processed_data["type"] in ["voice", "mixed"]:
                voice_text = self.audio_service.transcribe(processed_data["voice_url"])
                content = f"{content} {voice_text}".strip()
            
            # 3. 감정 분석
            emotion_result = self.emotion_analyzer.analyze(content)
            
            # 4. 추천 및 피드백 생성
            # TODO: 실제 DB에서 Todo 및 UserSettings 조회 로직 필요 (현재는 Mock/기본값 사용)
            todo_stats = {"total": 0, "completed": 0} 
            user_settings = {"advice_tone": "FRIENDLY"}
            
            recommendation_result = self.recommendation_service.get_recommendations(
                emotion_result, content, todo_stats, user_settings, categories
            )
            
            return {
                "journal_id": journal.journal_id,
                "status": "COMPLETED",
                "emotion": emotion_result,
                "recommendation": recommendation_result
            }
            
        except Exception as e:
            return {
                "journal_id": journal.journal_id,
                "status": "FAILED",
                "error": str(e),
                "emotion": self.emotion_analyzer._get_fallback_data(str(e)),
                "recommendation": self.recommendation_service._get_fallback_recommendations()
            }
