# Tasks: Narae AI Mental Care Agent

**Input**: Design documents from `specs/001-narae-mental-care/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, contracts/

**Tests**: JUnit 5 단위 테스트가 포함되었습니다. (사용자 요청 반영)

**Organization**: 각 사용자 스토리별로 독립적으로 구현 및 테스트할 수 있도록 그룹화되었습니다.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: 병렬 실행 가능 (서로 다른 파일, 의존성 없음)
- **[Story]**: 해당 작업이 속한 사용자 스토리 (예: US1, US2, US3)

## Path Conventions

- **Spring Boot**: `src/main/java/com/narae/`, `src/main/resources/`, `src/test/java/com/narae/`
- **Controller**: `src/main/java/com/narae/controller/`
- **Service**: `src/main/java/com/narae/service/`
- **Repository**: `src/main/java/com/narae/repository/`
- **DTO**: `src/main/java/com/narae/dto/`
- **Entity**: `src/main/java/com/narae/entity/`

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: 프로젝트 초기화 및 공통 모듈 설정

- [ ] T001 Spring Boot 3.5.x 및 Java 21 프로젝트 구조 생성
- [ ] T002 build.gradle 의존성 설정 (JPA, PostgreSQL, QueryDSL, OpenFeign, Swagger, Security, JWT)
- [ ] T003 [P] application.yml 환경별 설정 분리 (local, dev, prod)
- [ ] T004 [P] 프로젝트 공통 응답 규격 CommonResponse<T> 클래스 구현 in src/main/java/com/narae/common/CommonResponse.java
- [ ] T005 [P] @RestControllerAdvice 기반 GlobalExceptionHandler 및 커스텀 ErrorCode 정의 in src/main/java/com/narae/exception/
- [ ] T006 [P] QueryDSL 설정 및 JPAQueryFactory 빈 등록 in src/main/java/com/narae/config/QueryDslConfig.java

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: 인증 및 기본 인프라 구축 (모든 스토리의 선결 과제)

- [ ] T007 JWT 유틸리티 클래스 구현 (토큰 생성, 검증, 파싱) in src/main/java/com/narae/security/JwtTokenProvider.java
- [ ] T008 [P] SecurityConfig 설정 (인증 예외 경로 설정 및 JWT 필터 등록) in src/main/java/com/narae/config/SecurityConfig.java
- [ ] T009 [P] Users 기반 커스텀 UserDetailsService 및 UserDetails 구현 in src/main/java/com/narae/security/CustomUserDetailsService.java
- [ ] T010 feign.client.config 설정을 통한 타임아웃(60s) 및 로깅 설정 in src/main/java/com/narae/config/FeignConfig.java
- [ ] T011 FastAPI 통신용 AiServerClient 인터페이스 정의 in src/main/java/com/narae/client/AiServerClient.java
- [ ] T012 AI 서버 요청/응답용 DTO 설계 (@JsonProperty 적용) in src/main/java/com/narae/dto/ai/

**Checkpoint**: Foundation ready - 사용자 스토리 구현 시작 가능

---

## Phase 3: User Story 4 - OAuth Social Login (Priority: P1)

**Goal**: 구글, 네이버, 카카오 계정을 통한 간편 로그인 제공

- [ ] T013 [P] [US4] Users 엔티티 및 리포지토리 구현 (OAuth 필드 포함) in src/main/java/com/narae/entity/User.java
- [ ] T014 [P] [US4] OAuth2 로그인 성공 핸들러 및 사용자 정보 연동 로직 구현 in src/main/java/com/narae/security/OAuth2SuccessHandler.java
- [ ] T015 [US4] 소셜 로그인 API 엔드포인트 구현 (구글, 네이버, 카카오) in src/main/java/com/narae/controller/AuthController.java
- [ ] T016 [US4] 회원가입 및 로그인 비즈니스 로직 완성 (BCrypt 암호화 포함) in src/main/java/com/narae/service/AuthService.java

**Checkpoint**: 소셜 로그인 및 JWT 발급 기능 확인 가능

---

## Phase 4: User Story 1 - Multimodal Journaling (Priority: P1)

**Goal**: 텍스트, 음성, 이미지를 포함한 일기 작성 및 AI 분석 요청

- [ ] T017 [P] [US1] Journals 및 UserSettings 엔티티/리포지토리 구현 in src/main/java/com/narae/entity/
- [ ] T018 [P] [US1] Emotions 엔티티 및 리포지토리 구현 in src/main/java/com/narae/entity/Emotion.java
- [ ] T019 [P] [US1] 일기 저장 DTO 및 공통 Service 로직 구현 in src/main/java/com/narae/service/JournalService.java
- [ ] T020 [US1] @Async를 활용한 일기 저장 후 AI 서버 감정 분석 요청 비동기 서비스 구현 in src/main/java/com/narae/service/AsyncAnalysisService.java
- [ ] T021 [US1] 일기 작성 및 조회 API 구현 (Swagger 주석 포함) in src/main/java/com/narae/controller/JournalController.java
- [ ] T022 [US1] 감정 분석 결과 저장 및 상태(analysis_status) 업데이트 로직 검증

**Checkpoint**: 일기 작성 시 AI 서버와 비동기 연동되어 감정 데이터가 생성되는지 확인 가능

---

## Phase 5: User Story 2 - Personalized Action (Priority: P2)

**Goal**: 감정 분석 기반 맞춤형 추천 및 딥링크 제공

- [ ] T023 [P] [US2] Recommendations 엔티티 및 리포지토리 구현 in src/main/java/com/narae/entity/Recommendation.java
- [ ] T024 [P] [US2] Spotify/배민/Netflix 딥링크 및 Fallback URL 생성 빌더 구현 in src/main/java/com/narae/service/DeepLinkBuilder.java
- [ ] T025 [US2] 분석 결과 기반 추천 컨텐츠 비즈니스 로직 구현 in src/main/java/com/narae/service/RecommendationService.java
- [ ] T026 [US2] 추천 리스트 조회 및 클릭 상태(is_clicked) 업데이트 API 구현 in src/main/java/com/narae/controller/RecommendationController.java

**Checkpoint**: 일기 분석 후 생성된 추천 항목의 딥링크 동작 확인 가능

---

## Phase 6: User Story 3 - Reminder & High Risk (Priority: P3)

**Goal**: 능동형 리마인더 발송 및 고위험군 탐지

- [ ] T027 [P] [US3] Todos 엔티티 및 리포지토리 구현 (AI 우선순위 필드 포함) in src/main/java/com/narae/entity/Todo.java
- [ ] T028 [US3] 사용자의 마지막 활동 시간 추적 및 FCM 선제적 알림 스케줄러 구현 in src/main/java/com/narae/service/ReminderScheduler.java
- [ ] T029 [US3] 최근 4주 시계열 감정 데이터 분석 및 고위험군 탐지 로직 구현 in src/main/java/com/narae/service/RiskAnalysisService.java
- [ ] T030 [US3] 할 일 관리(조회/수정/완료) API 구현 in src/main/java/com/narae/controller/TodoController.java

**Checkpoint**: 24시간 미활동 시 알림 발송 및 고위험군 감지 플래그 확인 가능

---

## Phase 7: Polish & Documentation

**Purpose**: 시스템 마무리 및 품질 보증

- [ ] T031 [P] Items 및 UserItems 엔티티/리포지토리 구현 (상점 기능) in src/main/java/com/narae/entity/
- [ ] T032 [P] 장착 중인 페르소나 스타일에 따른 데이터 필터링 로직 고도화
- [ ] T033 [P] 핵심 로직(감정 분석, 딥링크 생성)에 대한 JUnit 5 단위 테스트 작성 in src/test/java/com/narae/
- [ ] T034 SpringDoc(Swagger) 전체 API 문서 최종 검토 및 최적화
- [ ] T035 일기 본문(content) AES-256 암호화 및 로그 마스킹 적용

---

## Dependencies & Execution Order

1. **Setup (Phase 1)** → **Foundational (Phase 2)**: 필수 선결 과제
2. **Foundational (Phase 2)** → **OAuth Login (Phase 3)**: 인증 시스템 필요
3. **OAuth Login (Phase 3)** → **Journaling (Phase 4)**: 사용자 정보 필요
4. **Journaling (Phase 4)** → **Personalized Action (Phase 5)**: 감정 데이터 필요
5. **Journaling (Phase 4)** → **Reminder & Risk (Phase 6)**: 활동 기록 필요

---

## Implementation Strategy

### MVP First (Phase 1-4)
1. 인프라와 인증 시스템을 먼저 구축합니다.
2. 구글 로그인을 통한 사용자 진입을 구현합니다.
3. 텍스트 일기 작성과 AI 감정 분석 피드백이라는 핵심 가치를 먼저 전달합니다 (US1).

### Incremental Delivery
- 추천 서비스(US2)와 고위험군 케어(US3)는 핵심 가치가 검증된 후 순차적으로 덧붙입니다.
- 상점 아이템(Items) 기능은 부가적인 재미 요소로 가장 마지막에 구현합니다.
