# API Contract: AI Server (FastAPI)

## 1. Emotion Analysis
- **Endpoint**: `POST /analyze/emotion`
- **Request Body**:
```json
{
  "journal_id": 1,
  "content": "오늘 기분이 너무 좋다!",
  "voice_url": "https://...",
  "persona_style": "FRIENDLY"
}
```
- **Response Body**:
```json
{
  "journal_id": 1,
  "joy_score": 0.95,
  "sadness_score": 0.01,
  "stress_level": 0.1,
  "emotion_summary": "매우 긍정적이고 활기찬 하루를 보내셨네요!"
}
```

## 3. Integrated Full Analysis (Recommended)
- **Endpoint**: `POST /analyze/full`
- **Description**: 감정 분석과 액션 추천을 한 번의 호출로 처리합니다.
- **Request Body**:
```json
{
  "journal_id": 1,
  "content": "오늘 기분이 너무 좋다!",
  "voice_url": "https://...",
  "persona_style": "FRIENDLY"
}
```
- **Response Body**:
```json
{
  "journal_id": 1,
  "joy_score": 0.9500,
  "sadness_score": 0.0100,
  "stress_level": 0.1000,
  "emotion_summary": "매우 긍정적이고 활기찬 하루를 보내셨네요!",
  "recommendations": [
    {
      "category": "MUSIC",
      "content_text": "Pharrell Williams - Happy",
      "external_link": "60SdxuWpCSTZHvCg9XmS81"
    },
    {
      "category": "MOVIE",
      "content_text": "어바웃 타임",
      "external_link": "70273658"
    }
  ]
}
```

## 4. External Link Formats (external_link)
AI 서버는 각 카테고리에 맞는 플랫폼의 고유 ID를 `external_link` 필드에 담아 보내야 합니다.

| Category | Platform | Format Example |
| :--- | :--- | :--- |
| **MUSIC** | Spotify | Track ID (e.g., `60SdxuWpCSTZHvCg9XmS81`) |
| **MOVIE** | Netflix | Title ID (e.g., `70273658`) |
| **FOOD** | Baemin | Restaurant/Content ID (e.g., `12345`) |
| **EXERCISE** | YouTube/DeepLink | Content ID or Path |
| **BOOK** | External Link | Content ID or Path |

---

## 5. Todo Success Feedback
- **Endpoint**: `POST /feedback/todo`
- **Description**: 사용자의 할 일 달성률과 최근 감정 상태를 바탕으로 맞춤형 격려 메시지를 생성합니다.
- **Request Body**:
```json
{
  "total_count": 10,
  "completed_count": 8,
  "completion_rate": 0.8000,
  "persona_style": "FRIENDLY",
  "recent_emotion": "SADNESS"
}
```
- **Response Body**:
```json
{
  "feedback_message": "오늘 마음이 많이 힘들었을 텐데도 8개나 해내셨네요! 정말 대단해요. 남은 일은 걱정 말고 오늘은 푹 쉬기로 해요. 리피가 곁에 있을게요. ✨"
}
```

### 💡 피드백 생성 가이드 (AI 서버)
1. **맥락 기반 공감**: `recent_emotion`이 부정적(SADNESS, STRESS 등)일 경우, 낮은 달성률에 대해서도 비난이 아닌 **정서적 지지와 휴식 권고** 위주의 메시지를 생성합니다.
2. **페르소나 반영**: `persona_style`이 `FRIENDLY`일 경우 친구처럼 친근한 반말/체체를, `BASIC`일 경우 정중하고 따뜻한 존댓말을 사용합니다.
3. **수치 해석**: 달성률이 높을 경우 사용자의 유능감을 고취시키고, 낮을 경우 원인을 감정과 연결하여 부드럽게 격려합니다.
