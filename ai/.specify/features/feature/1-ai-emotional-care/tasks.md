# 작업 목록 (Tasks): 능동형 AI 감정 케어 에이전트 (AI 분석 서버)

## 구현 전략
- **REST API 서버 전환**: Spring Boot 백엔드와 연동되는 FastAPI 서버 구축.
- **감정 분석 및 성취도 피드백**: 텍스트 분석 기반의 정밀 지표 도출 및 맞춤형 위로 메시지 생성.
- **플레이리스트 추천 고도화**: 개별 곡이 아닌 Spotify 플레이리스트 ID 기반 추천 시스템 구축.

## Phase 1: 환경 구축 및 엔진 점검 (완료)
- [x] T001 OpenAI Python SDK 및 필수 라이브러리 설치
- [x] T002 LLM 엔진 변경 (GPT-4o) 및 `ai_config.py` 업데이트
- [x] **[NEW]** T003 FastAPI 및 API 서버 관련 의존성 추가 설치

## Phase 2: [LEGACY] 실시간 음성 분석 엔진 (사용 안 함)
- [x] T004 Whisper 기반 음성-텍스트 변환(STT) 최적화 (Legacy)
- [x] T005 OpenAI Audio 기반 음성 합성(TTS) 구현 (Legacy)
- [x] T006 실시간 대화용 페르소나 `chat` 메서드 (Legacy)

## Phase 3: [REVISED] API 엔드포인트 및 추천 로직
- [x] **[NEW]** T007 통합 추천(Spotify ID, 영화 ID, 음식) 프롬프트 및 로직 설계 (FOOD 링크 null 처리 포함)
- [x] T008 감정 지표(0.0~1.0) 산출 및 JSON 응답 모드 활성화
- [x] **[NEW]** T009 [TDD] 분석 및 추천 로직 단위 테스트 작성 (콘텐츠 ID 정규식 검증 포함)
- [x] **[NEW]** T010 FastAPI 기반 `/analyze-journal` 엔드포인트 구현 (Pydantic 연동)

## Phase 4: [REVISED] Todo 피드백 및 인프라 강화
- [x] **[NEW]** T011 [TDD] Todo 피드백 생성 로직 단위 테스트 작성
- [x] **[NEW]** T012 Todo 달성률 기반 격려 메시지 생성 로직 구현
- [x] **[NEW]** T013 FastAPI 기반 `/todo-feedback` 엔드포인트 구현
- [x] **[NEW]** T014 인프라 강화: Rate Limiting(Slowapi) 및 지수적 백오프(Tenacity) 구현
- [x] **[NEW]** T015 관측성 강화: JSON 로깅(민감 정보 마스킹 포함) 및 Correlation ID 미들웨어 구축
- [x] **[NEW]** T016 `Orchestrator` 리팩토링 (`src/api` 및 `src/service` 레이어 분리 아키텍처 적용)

## Phase 5: 데모 및 검증 (재구현)
- [x] **[NEW]** T017 API 서버 동작 확인을 위한 `demo_api.py` (Client Role) 구현
- [x] **[NEW]** T018 API 엔드포인트 통합 테스트 (Journal & Todo)
- [x] **[NEW]** T019 백엔드 요청 규격 준수 여부 최종 검증
- [x] **[NEW]** T020 API 응답 지연 시간(Latency) 측정 및 5초 이내 응답 여부 검증

## Final Phase: 마무리 (Polish)
- [x] **[NEW]** T021 전체 코드 린트 체크 및 Phase 2 레거시 코드(STT/TTS 등) 삭제
- [x] T022 프로젝트 문서화 (GEMINI.md, spec.md, plan.md 업데이트 완료)


