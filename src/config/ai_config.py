import os
from dotenv import load_dotenv

# .env 파일 로드
load_dotenv()

class AIConfig:
    """AI 모델 및 API 연동 설정을 관리합니다."""
    
    def __init__(self):
        self.llm_model = "gpt-4o"
        self.stt_model = "Whisper"
        # .env 파일 혹은 시스템 환경 변수에서 키를 읽어옵니다.
        self.api_key = os.getenv("OPENAI_API_KEY", "")
        self.db_url = os.getenv("DATABASE_URL", "sqlite:///capstone.db")

    def get_prompt_guide(self):
        """감정 수치 산출을 위한 프롬프트 가이드를 반환합니다."""
        return (
            "기쁨, 슬픔, 스트레스 수치를 각각 0.0000 ~ 1.0000 범위 내에서 독립적으로 도출하십시오. "
            "0.0은 가장 낮음, 1.0은 가장 높음을 의미합니다."
        )

ai_config = AIConfig()
