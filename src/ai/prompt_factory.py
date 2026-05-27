class PromptFactory:
    """사용자 설정 및 상황에 맞는 AI 프롬프트를 생성하는 팩토리 클래스"""
    
    @staticmethod
    def create_recommendation_prompt(user_settings: dict, emotion_data: dict, diary_content: str, categories: list, todo_rate: float, spotify_id: str = None, spotify_title: str = None) -> str:
        """사용자의 일기 내용과 선택된 카테고리를 반영하는 프롬프트를 생성한다."""
        advice_tone = user_settings.get("advice_tone", "FRIENDLY")
        joy = emotion_data.get("joy_score", 0)
        sad = emotion_data.get("sadness_score", 0)
        stress = emotion_data.get("stress_level", 0)
        
        # 선택된 카테고리 설명 생성
        category_list_str = ", ".join(categories)
        
        tone_guide = {
            "INFORMAL": "친구처럼 친근하게 반말로 얘기해줘. '힘내' 같은 말보다는 일기 내용 중 공감 가는 부분을 콕 짚어서 말해줘.",
            "FORMAL": "따뜻하고 정중한 존댓말로 조언해줘. 사용자의 아픔을 충분히 이해하고 있다는 느낌을 주는 것이 중요해.",
            "FRIENDLY": "다정하고 따뜻하게 위로해줘. 사용자가 스스로를 한심하게 느끼지 않도록 자존감을 높여주는 말을 해줘.",
            "STRICT": "차분하고 객관적인 태도로 조언해줘. 현재 상황에서 작은 해결책부터 찾을 수 있게 도와줘."
        }
        
        guide = tone_guide.get(advice_tone, tone_guide["FRIENDLY"])
        
        link_instructions = []
        if "MUSIC" in categories:
            link_instructions.append(f"- MUSIC: content_text 필드는 반드시 '{spotify_title}' 로 작성하고, external_link 필드는 반드시 제공된 Spotify ID '{spotify_id}' 를 그대로 반환해줘. 제목을 임의로 수정하지 마.")
        if "MOVIE" in categories:
            link_instructions.append("- MOVIE: content_text는 '[플랫폼] 영화: [제목]' 형식으로 작성하고, external_link는 실제 해당 영화 플랫폼의 숫자형 ID(예: 70273658) 문자열만 반환해줘. 영문자 포함 불가.")
        if "FOOD" in categories:
            link_instructions.append("- FOOD: external_link 필드는 반드시 null 로 반환해줘.")
        
        link_guide = ""
        if link_instructions:
            link_guide = (
                "\n[링크 생성 지침]\n" +
                "\n".join(link_instructions) + "\n"
            )

        # 감정 상태에 따른 추천 가이드
        rec_guide = f"다음 카테고리에 대해 각각 하나씩 추천해줘: {category_list_str}. "
        if "MUSIC" in categories:
            rec_guide += f"음악은 반드시 제공된 '{spotify_title}'을(를) 추천해야 함. "

        # JSON 예시 항목 동적 생성
        example_items = []
        for cat in categories:
            if cat == "MUSIC":
                example_items.append(f"{{\"category\": \"MUSIC\", \"content_text\": \"{spotify_title or '플레이리스트 이름'}\", \"external_link\": \"{spotify_id or '37i9dQZF1DXcBWIGoYBM3M'}\"}}")
            elif cat == "MOVIE":
                example_items.append(f"{{\"category\": \"MOVIE\", \"content_text\": \"넷플릭스 영화: 어바웃 타임\", \"external_link\": \"70273658\"}}")
            elif cat == "FOOD":
                example_items.append(f"{{\"category\": \"FOOD\", \"content_text\": \"따뜻한 코코아\", \"external_link\": null}}")
            else:
                example_items.append(f"{{\"category\": \"{cat}\", \"content_text\": \"추천 내용\"}}")
        example_json = ",\n    ".join(example_items)

        return (
            f"당신은 사용자의 일기를 읽고 그 속의 깊은 감정을 보듬어주는 전문 심리 케어 에이전트입니다.\n"
            f"사용자의 오늘 이야기: \"{diary_content}\"\n"
            f"분석된 감정 수치: 기쁨 {joy}, 슬픔 {sad}, stress {stress}\n"
            f"말투 지침: {guide}\n"
            f"추천 지침: {rec_guide}"
            f"{link_guide}\n"
            "요구사항:\n"
            "1. feedback_message는 일기의 구체적인 내용을 반영하되, 반드시 **최대 2줄(줄바꿈 1회 이하)** 이내로 매우 간결하게 작성할 것.\n"
            f"2. {category_list_str} 카테고리에 대해 각각 1개씩 총 {len(categories)}개의 추천 항목을 생성할 것.\n"
            "3. 모든 응답은 반드시 아래 JSON 형식을 지킬 것.\n"
            "{\n"
            "  \"recommendations\": [\n"
            f"    {example_json}\n"
            "  ],\n"
            "  \"feedback_message\": \"구체적 맥락을 담은 2줄 이내의 위로\"\n"
            "}"
        )
