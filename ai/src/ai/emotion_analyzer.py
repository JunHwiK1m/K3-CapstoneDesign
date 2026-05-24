import json
from openai import OpenAI
from src.config.ai_config import ai_config

class EmotionAnalyzer:
    """텍스트를 분석하여 감정 지표와 요약문을 산출하는 서비스"""
    
    def __init__(self):
        self.client = OpenAI(api_key=ai_config.api_key)
        
    def analyze(self, text: str) -> dict:
        """OpenAI 모델을 호출하여 감정을 분석한다."""
        prompt_guide = ai_config.get_prompt_guide()
        system_prompt = (
            f"당신은 유능한 감정 분석 에이전트입니다. 다음 지침에 따라 JSON 형식으로만 응답하십시오.\n"
            f"지침: {prompt_guide}\n"
            "응답 예시: {\"joy_score\": 0.5, \"sadness_score\": 0.2, \"stress_level\": 0.3, \"emotion_summary\": \"사용자의 상황을 2줄 이내로 요약한 문장\"}"
        )
        
        try:
            response = self.client.chat.completions.create(
                model=ai_config.llm_model,
                messages=[
                    {"role": "system", "content": system_prompt},
                    {"role": "user", "content": text}
                ],
                response_format={"type": "json_object"}
            )
            
            content = response.choices[0].message.content
            result = json.loads(content)
            
            # 오타 대응 (emtion_summary로 올 경우 교정)
            if "emtion_summary" in result and "emotion_summary" not in result:
                result["emotion_summary"] = result.pop("emtion_summary")
            elif "emotion_summary" not in result:
                result["emotion_summary"] = ""
                
            return result
            
        except Exception as e:
            return self._get_fallback_data(str(e))
            
    def chat(self, text: str) -> str:
        """실시간 대화용: 훨씬 짧고 편안하게 응답함"""
        try:
            response = self.client.chat.completions.create(
                model=ai_config.llm_model,
                messages=[
                    {"role": "system", "content": (
                        "당신은 편안한 친구 같은 심리 상담사입니다.\n"
                        "지침:\n"
                        "1. 무조건 1~2문장 이내로 짧게 대답하세요.\n"
                        "2. 매번 질문을 던져서 대화를 강요하지 마세요.\n"
                        "3. 사용자가 대화를 끝내려는 것 같으면(예: 수고해, 끝, 그래 등) '알겠어요, 편히 쉬세요'라고 인사하세요."
                    )},
                    {"role": "user", "content": text}
                ],
                max_tokens=100
            )
            return response.choices[0].message.content
        except Exception:
            return "그렇군요. 편하게 계속 말씀해 주세요."

    def _get_fallback_data(self, error_msg: str) -> dict:
        """분석 실패 시 반환할 기본 데이터"""
        return {
            "joy_score": 0.0,
            "sadness_score": 0.0,
            "stress_level": 0.0,
            "emotion_summary": f"기술적인 이유로 감정 분석을 완료하지 못했습니다. (사유: {error_msg})"
        }
