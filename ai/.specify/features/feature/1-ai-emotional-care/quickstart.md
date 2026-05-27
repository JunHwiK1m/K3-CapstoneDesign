# 퀵스타트 가이드: AI 분석 서버

## 1. 환경 설정
- **Python 버전:** 3.12.3 이상
- **API 키 설정:** `.env` 파일에 `OPENAI_API_KEY`를 설정합니다.
  ```env
  OPENAI_API_KEY=your_openai_api_key_here
  ```

## 2. 의존성 설치
```bash
pip install -r requirements.txt
# 추가 패키지 (개발 진행 중)
pip install fastapi uvicorn slowapi tenacity python-json-logger
```

## 3. 서버 실행
```bash
# uvicorn을 사용하여 서버 실행
uvicorn src.main:app --host 0.0.0.0 --port 8000 --reload
```

## 4. API 테스트
### 일기 분석 요청
```bash
curl -X POST "http://localhost:8000/analyze-journal" \
     -H "Content-Type: application/json" \
     -d '{
           "journal_id": 1,
           "content": "오늘 하루 정말 보람찼어!",
           "persona_style": "FRIENDLY"
         }'
```

### Todo 피드백 요청
```bash
curl -X POST "http://localhost:8000/todo-feedback" \
     -H "Content-Type: application/json" \
     -d '{
           "total_count": 5,
           "completed_count": 3,
           "completion_rate": 0.6,
           "persona_style": "FRIENDLY",
           "recent_emotion": "JOY"
         }'
```
