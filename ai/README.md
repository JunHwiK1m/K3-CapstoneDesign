# Leafy AI Analysis Server (Python)

본 서버는 Leafy 서비스의 핵심 AI 엔진으로, 사용자의 일기 내용과 Todo 성취도를 분석하여 맞춤형 케어 콘텐츠를 제공합니다.

---

## 🔗 Backend Integration Guide (백엔드 연동 가이드)

백엔드(Spring Boot)에서 AI 서버를 호출할 때 사용하는 API 명세입니다.

### 1. 일기 감정 분석 및 추천
- **Endpoint:** `POST /api/ai/journals`
- **Description:** 사용자가 작성한 일기 내용을 분석하여 감정 점수(Joy, Sadness, Stress)와 추천 콘텐츠(Spotify, Movie, Food)를 반환합니다.
- **Request Body (JSON):**
  ```json
  {
    "journalId": 123,
    "content": "오늘 정말 행복한 하루였어!",
    "personaStyle": "FRIENDLY",
    "voiceUrl": null
  }
  ```
- **Response Body (JSON):**
  ```json
  {
    "journalId": 123,
    "joyScore": 0.85,
    "sadnessScore": 0.05,
    "stressLevel": 0.1,
    "emotionSummary": "정말 긍정적인 에너지가 느껴지는 하루네요!",
    "recommendations": [
      {
        "category": "MUSIC",
        "contentText": "Today's Top Hits",
        "externalLink": "37i9dQZF1DXcBWIGoYBM3M"
      },
      ...
    ]
  }
  ```

### 2. Todo 성취도 피드백 생성
- **Endpoint:** `POST /api/ai/todos/feedback`
- **Description:** 사용자의 할 일 달성률과 최근 감정을 조합하여 맞춤형 격려 메시지를 생성합니다.
- **Request Body (JSON):**
  ```json
  {
    "totalCount": 10,
    "completedCount": 8,
    "completionRate": 0.8,
    "personaStyle": "FRIENDLY",
    "recentEmotion": "STRESS"
  }
  ```
- **Parameter Values:**
  - `personaStyle`: `BASIC`, `FRIENDLY`, `STRICT`
  - `recentEmotion`: `JOY`, `SADNESS`, `STRESS`, `NEUTRAL`
- **Response Body (JSON):**

  ```json
  {
    "feedbackMessage": "스트레스가 많은 상황에서도 80%나 해내셨다니 정말 대단해요!"
  }
  ```

---

## 🛠️ 설치 및 실행

### 1. 환경 변수 설정
`.env` 파일에 OpenAI API 키를 입력합니다.
```env
OPENAI_API_KEY=your_openai_api_key_here
```

### 2. 패키지 설치 및 실행
```bash
# 가상환경 생성 및 접속
python3 -m venv .venv
source .venv/bin/activate

# 의존성 설치
pip install -r requirements.txt
pip install fastapi uvicorn slowapi tenacity python-json-logger pydantic httpx

# 서버 실행 (Port: 8000)
uvicorn src.main:app --host 0.0.0.0 --port 8000 --reload
```

## 🧪 검증 도구
- **Swagger Docs:** `http://localhost:8000/docs` (API 테스트 및 명세 확인)
- **데모 스크립트:** `.venv/bin/python demo_api.py` 실행
- **통합 테스트:** `pytest tests/integration/test_full_workflow.py`
