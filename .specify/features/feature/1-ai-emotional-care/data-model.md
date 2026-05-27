# 데이터 모델: 능동형 AI 감정 케어 에이전트

## 1. 개요
AI 분석 서버에서 사용하는 데이터 구조와 필드 정의입니다. Spring Boot 백엔드와의 REST API 통신 및 DB 스키마 규격(JSON 필드)을 준수합니다.

## 2. 엔티티 정의

### 2.1 JournalAnalysisRequest (일기 분석 요청)
- `journal_id` (Integer): 일기 고유 ID.
- `content` (String): 사용자가 작성한 일기 텍스트. (최대 5,000자)
- `voice_url` (String): (Optional) 음성 파일 경로. 현재는 무시됨.
- `persona_style` (Enum): AI 페르소나 스타일 (`BASIC`, `FRIENDLY`, `STRICT`).

### 2.2 JournalAnalysisResponse (일기 분석 결과)
- `journal_id` (Integer): 요청 시 받은 일기 ID.
- `joy_score` (Float): 기쁨 수치 (0.0000 ~ 1.0000).
- `sadness_score` (Float): 슬픔 수치 (0.0000 ~ 1.0000).
- `stress_level` (Float): 스트레스 수치 (0.0000 ~ 1.0000).
- `emotion_summary` (String): 감정 분석 요약문.
- `recommendations` (List[Recommendation]): 추천 콘텐츠 리스트.

### 2.3 Recommendation (추천 콘텐츠)
- `category` (Enum): 콘텐츠 카테고리 (`MUSIC`, `MOVIE`, `FOOD`).
- `content_text` (String): 콘텐츠 설명 또는 제목.
- `external_link` (String): Spotify 플레이리스트 ID, 영화 ID 또는 외부 링크.

### 2.4 TodoFeedbackRequest (성취도 피드백 요청)
- `total_count` (Integer): 전체 Todo 개수.
- `completed_count` (Integer): 완료된 Todo 개수.
- `completion_rate` (Float): 달성률 (0.0000 ~ 1.0000).
- `persona_style` (Enum): AI 페르소나 스타일.
- `recent_emotion` (Enum): 최근 감정 상태 (`JOY`, `SADNESS`, `STRESS`, `NEUTRAL`).

### 2.5 TodoFeedbackResponse (성취도 피드백 결과)
- `feedback_message` (String): 감정 및 성취도를 고려한 맞춤형 격려 메시지.

## 3. 공통 규격
- **수치 데이터:** 소수점 4자리까지 표현 (FP32 권장).
- **에러 응답:**
  ```json
  {
    "status": "ERROR",
    "message": "에러 내용",
    "data": null
  }
  ```
