# Changelog

## [2026-05-31]
- **Added**: `frontend/api_updated.md` 파일을 새로 생성하여 `backend/api.md` 기준 최신 API 명세를 업데이트함. (프로젝트 규칙 제약으로 인해 기존 `frontend/api.md` 원본은 보존됨)
- **Fixed**: `frontend/lib/screens/records_screen.dart`에서 일기 상세 조회 API 응답의 `emotion` 필드를 최신 API 명세에 맞게 `emotionResult`로 수정함.
- **Changed**: `frontend/lib/screens/store_screen.dart`를 수정하여 하드코딩된 아이템 목록 대신 상점 API(`GET /api/items`, `GET /api/items/my`, `POST /api/items/{itemId}/purchase`)를 연동하고 이미 보유 중인 아이템은 구매 버튼을 비활성화하도록 구현함.
- **Added**: `frontend/lib/screens/diary_home_page.dart` 상단의 마스코트 말풍선에 `GET /api/todos/stats` 응답으로 오는 `feedbackMessage`가 노출되도록 반영함.
- **Changed**: 일기 작성(`DiaryWriteScreen`), 분석 대기(`AnalysisLoadingScreen`), 분석 결과(`AnalysisResultScreen`) 화면 간의 API 파이프라인 연동. 이미지 멀티파트 업로드 로직 추가, 주기적 상태 폴링 로직 구현 및 감정 통계/추천 콘텐츠 데이터 동적 바인딩.
- **Fixed**: Spring Boot 백엔드의 `AiServerClient.java` 엔드포인트를 Python AI 서버 명세와 일치하도록 수정 (`/analyze/full` -> `/api/ai/journals`, `/analyze/todo` -> `/api/ai/todos/feedback`).
- **Fixed**: Spring Boot 백엔드 AI 통신 DTO (`EmotionAnalysisRequest`, `TodoAnalysisRequest`, `FullAnalysisResponse`, `TodoAnalysisResponse`)의 필드를 snake_case 매핑에서 Python API와 동일한 camelCase로 일치시켜 분석 결과가 저장되지 않고 무한 로딩되던 버그를 해결함. 앱의 분석 로딩 화면에서 예외 상황 시 무한 로딩에 빠지지 않도록 상태 예외 처리 추가.
- **Fixed**: `AsyncAnalysisService.java`에서 DB에 암호화되어 저장된 일기 내용을 AI 서버로 전송하기 전에 원문으로 복호화(`aesUtil.decrypt`)하도록 수정하여, AI가 암호문을 잘못 분석하는 버그를 해결함.
- **Fixed**: 백엔드 `Recommendation` 엔티티의 `journal` 필드에 `@JsonIgnore`를 추가하여, 결과 화면 진입 시 추천 목록을 조회(`GET /api/recommendations`)할 때 발생하던 무한 순환 참조(Lazy Proxy) 직렬화 에러(HTTP 500)를 해결함. 이를 통해 앱 결과 페이지에 음악, 영화, 음식 추천 UI가 정상적으로 표출되도록 복구함.
