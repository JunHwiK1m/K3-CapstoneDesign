import json
from openai import OpenAI
from tenacity import retry, stop_after_attempt, wait_exponential
from src.config.ai_config import ai_config
from src.ai.prompt_factory import PromptFactory

class EmotionAnalyzer:
    """텍스트를 분석하여 감정 지표와 요약문을 산출하는 서비스"""
    
    def __init__(self):
        self.client = OpenAI(api_key=ai_config.api_key)
        
    @retry(stop=stop_after_attempt(3), wait=wait_exponential(multiplier=1, min=2, max=10))
    def _call_openai(self, system_prompt: str, text: str) -> str:
        response = self.client.chat.completions.create(
            model=ai_config.llm_model,
            messages=[
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": text}
            ],
            response_format={"type": "json_object"}
        )
        return response.choices[0].message.content

    def analyze(self, text: str, persona_style: str = "FRIENDLY") -> dict:
        """OpenAI 모델을 호출하여 감정을 분석한다."""
        prompt_guide = ai_config.get_prompt_guide()
        tone_guide = PromptFactory.get_tone_guide(persona_style)
        
        system_prompt = (
            f"당신은 유능한 감정 분석 에이전트입니다. 다음 지침에 따라 JSON 형식으로만 응답하십시오.\n"
            f"지침: {prompt_guide}\n"
            f"말투 지침: emotion_summary 작성 시 다음을 따르세요: {tone_guide}\n"
            "응답 예시: {\"joy_score\": 0.5, \"sadness_score\": 0.2, \"stress_level\": 0.3, \"emotion_summary\": \"사용자의 상황을 2줄 이내로 요약한 문장\"}"
        )
        
        try:
            content = self._call_openai(system_prompt, text)
            result = json.loads(content)
            
            # 오타 대응 (emtion_summary로 올 경우 교정)
            if "emtion_summary" in result and "emotion_summary" not in result:
                result["emotion_summary"] = result.pop("emtion_summary")
            elif "emotion_summary" not in result:
                result["emotion_summary"] = ""
                
            return result
            
        except Exception as e:
            return self._get_fallback_data(str(e))

    def _get_fallback_data(self, error_msg: str) -> dict:
        """분석 실패 시 반환할 기본 데이터"""
        return {
            "joy_score": 0.0,
            "sadness_score": 0.0,
            "stress_level": 0.0,
            "emotion_summary": f"기술적인 이유로 감정 분석을 완료하지 못했습니다. (사유: {error_msg})"
        }

