class PromptFactory:
    """사용자 설정 및 상황에 맞는 AI 프롬프트를 생성하는 팩토리 클래스"""
    
    @staticmethod
    def create_recommendation_prompt(user_settings: dict, emotion_data: dict, diary_content: str, categories: list, todo_rate: float) -> str:
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
        
        # [관리 포인트] 외부 링크 생성 기능 (제거 시 아래 block을 삭제/주석 처리하거나 link_guide를 빈 문자열로 변경)
        # ---------------------------------------------------------
        link_instructions = []
        if "MUSIC" in categories:
            link_instructions.append("- MUSIC: Spotify 검색 링크 (예: https://open.spotify.com/search/가수명+곡명)")
        if "MOVIE" in categories:
            link_instructions.append("- MOVIE: Netflix 검색 링크 (예: https://www.netflix.com/search?q=영화제목)")
        
        link_guide = ""
        if link_instructions:
            link_guide = (
                "\n[링크 생성 지침]\n"
                "다음 형식에 맞춰 'external_link' 필드를 채워줘. (공백은 '+'로 치환)\n" +
                "\n".join(link_instructions) + "\n"
            )
        # ---------------------------------------------------------

        # 감정 상태에 따른 추천 가이드
        rec_guide = f"다음 카테고리에 대해 각각 하나씩 추천해줘: {category_list_str}. "
        if "MUSIC" in categories:
            rec_guide += "음악 추천 시 슬픔이나 스트레스가 높다면 마음을 위로하는 곡을, 기쁘다면 함께 즐길 수 있는 곡을 골라줘. "

        # JSON 예시 항목 동적 생성
        example_items = []
        for cat in categories:
            link_field = ", \"external_link\": \"결과 URL\"" if (cat in ["MUSIC", "MOVIE"] and link_guide) else ""
            if cat == "MUSIC":
                example_items.append(f"{{\"category\": \"MUSIC\", \"content_text\": \"가수*#*곡명\"{link_field}}}")
            else:
                example_items.append(f"{{\"category\": \"{cat}\", \"content_text\": \"추천 내용\"{link_field}}}")
        example_json = ",\n    ".join(example_items)

        return (
            f"당신은 사용자의 일기를 읽고 그 속의 깊은 감정을 보듬어주는 전문 심리 케어 에이전트입니다.\n"
            f"사용자의 오늘 이야기: \"{diary_content}\"\n"
            f"분석된 감정 수치: 기쁨 {joy}, 슬픔 {sad}, 스트레스 {stress}\n"
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
