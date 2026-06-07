# Changelog

## [2026-06-03]
- **Changed**: 나의 기록 화면(`records_screen.dart`)의 달력에서 그날의 기분을 나타내는 마커를 기존 텍스트 이모지(🌱, ✨ 등)에서 사용자 지정 이미지(`m_happy.png`, `m_normal.png`, `m_sad.png`)로 변경함.
- **Added**: 홈 화면(`diary_home_page.dart`) 및 분석 결과 화면(`analysis_result_screen.dart`)에 표시되는 마스코트에 생동감을 주기 위해 제자리에서 통통 튀는 애니메이션 효과를 구현한 `BouncingMascot` 커스텀 위젯(`lib/widgets/bouncing_mascot.dart`)을 추가하고 기존 이미지에 적용함.
- **Removed**: 홈 화면(`diary_home_page.dart`) 상단에 노출되던 테스트용 '임시 토큰 입력' 텍스트 필드(UI)를 제거하여 화면을 더 깔끔하게 정리함.
- **Changed**: 홈 화면(`diary_home_page.dart`) 중앙의 일기 작성 플로팅 버튼(FAB)의 직관성을 위해, 아이콘 하단에 '일기 작성' 텍스트가 표시되도록 UI를 개선함.
- **Changed**: 홈 화면(`diary_home_page.dart`) 하단 내비게이션 바의 직관성을 높이기 위해, 기존 아이콘 버튼을 '프로필', '상점', '기록', '설정' 텍스트 라벨이 포함된 UI 컴포넌트(`_buildNavItem`)로 변경함.
- **Changed**: 스마트폰 기기에서 화면 하단 바(홈, 뒤로가기 버튼)가 보이지 않도록 `main.dart`에 `SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.top])`를 적용하여 상단 상태바만 표시되도록 수정함.
- **Changed**: 프론트엔드 홈 화면(`diary_home_page.dart`) 및 분석 결과 화면(`analysis_result_screen.dart`)의 대화 말풍선 옆 마스코트 아이콘(`Icon(Icons.pets)`)을 실제 마스코트 이미지(`assets/imgs/m1.png`)로 교체하고 `pubspec.yaml`에 에셋 경로를 추가함.
## [2026-06-02]
- **Added**: 구글 로그인 시 브라우저에서 앱으로 자동 복귀하는 딥링크(Deep Link) 구현. 백엔드(`/login-success`)가 `narae://` 커스텀 스킴으로 리다이렉트하도록 수정하고, 프론트엔드에 `flutter_web_auth_2`를 도입하여 토큰을 낚아채 자동 저장하는 흐름 구축.
- **Removed**: 딥링크 자동화에 따라 `SetupScreen`에 있던 '임시 토큰 입력' 텍스트 필드와 관련 UI 완전히 제거.
- **Added**: 프론트엔드와 백엔드 서버 통신 시 사용되는 로컬 IP 주소(`10.0.2.2`)를 하드코딩에서 분리하여 `lib/config.dart` 파일 하나에서 한 번에 관리할 수 있도록 리팩토링함. 스마트폰 실기기 테스트 편의성 향상.
- **Added**: 자동 로그인 로직 구현. `shared_preferences`를 도입하여 `SetupScreen`에서 얻은 로그인 토큰을 기기에 저장하고, `main.dart` 앱 실행 시 저장된 토큰이 있으면 바로 `DiaryHomePage`로 진입하도록 개선함. `SettingsScreen` 로그아웃 시 토큰 폐기 로직 추가.
- **Changed**: 프론트엔드 `SetupScreen`의 AI 말투(성격) 설정이 제대로 백엔드와 AI 서버에 전달될 수 있도록 백엔드의 `PersonaStyle` Enum 값에 `INFORMAL`, `FORMAL`, `STRICT`를 추가하고, 프론트엔드에서 각 한글 설정값('직설적', '친근한', '공감적', '기타')에 매핑되도록 코드를 수정함.

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
