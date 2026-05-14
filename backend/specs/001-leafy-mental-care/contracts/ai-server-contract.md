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

## 2. Action Recommendation
- **Endpoint**: `POST /recommend/action`
- **Request Body**:
```json
{
  "journal_id": 1,
  "joy_score": 0.95,
  "sadness_score": 0.01,
  "stress_level": 0.1
}
```
- **Response Body**:
```json
{
  "recommendations": [
    {
      "category": "MUSIC",
      "content_text": "Pharrell Williams - Happy",
      "external_link": "spotify:track:60SdxuWpCSTZHvCg9XmS81",
      "fallback_url": "https://open.spotify.com/track/60SdxuWpCSTZHvCg9XmS81"
    }
  ]
}
```
