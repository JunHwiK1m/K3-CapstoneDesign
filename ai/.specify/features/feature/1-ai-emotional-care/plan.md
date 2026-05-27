# 기술 설계 및 구현 계획: 능동형 AI 감정 케어 에이전트 (AI 분석 서버)

## 1. 기술 컨텍스트 (Technical Context)
- **주요 기술 스택:** OpenAI GPT-4o, FastAPI (REST API), Pydantic (Data Validation)
- **통신 대상:** Spring Boot Backend Server
- **아키텍처:** RESTful API 기반 비동기 분석 서버

## 2. 프로젝트 헌장 준수 확인 (Constitution Check)
- [x] **한국어 중심:** 모든 프롬프트, 분석 결과 및 문서는 한국어로 작성됨.
- [x] **TDD 원칙:** API 엔드포인트 및 분석 로직에 대한 철저한 테스트 수행 예정.
- [x] **보안 최우선:** API 키 환경 변수 관리 및 백엔드 데이터 규격 준수.

## 3. 구현 아키텍처 (API 기반)
### AI 분석 및 추천 파이프라인
1. **API 요청 수신 (FastAPI)**: Spring Boot 백엔드로부터 일기 내용 또는 Todo 데이터를 수신.
2. **데이터 검증 (Pydantic)**: 요청 데이터의 유효성 및 필수 필드 확인.
3. **감정 분석 및 요약 (GPT-4o)**: 텍스트 맥락을 분석하여 기쁨, 슬픔, 스트레스 수치 및 요약문 생성.
4. **맞춤형 콘텐츠 선정 (GPT-4o)**: 분석된 감정에 최적화된 Spotify 플레이리스트 ID 및 영화/음식 정보 선정.
5. **성취도 피드백 생성 (GPT-4o)**: Todo 달성 현황에 따른 감정 맞춤형 격려 메시지 생성.
6. **JSON 응답 반환**: 백엔드 스키마와 1:1 매핑된 최종 분석 결과를 JSON으로 반환.

## 4. 상세 설계 및 인터페이스
- **데이터 모델:** [spec.md](./spec.md)의 API 명세 참조.
- **플랫폼 딥링크:** Spotify 플레이리스트 ID를 기반으로 하여 앱 내에서 직접 이동 가능하도록 지원.

## 5. 구현 단계 (재설계)
### 0단계: 설계 및 리서치 (완료)
- [x] 기술적 불확실성 해소 및 의사결정 완료 ([research.md](./research.md))
- [x] 데이터 모델 및 인터페이스 정의 ([data-model.md](./data-model.md), [contracts/](./contracts/))
- [x] 퀵스타트 가이드 작성 ([quickstart.md](./quickstart.md))

### 1단계: API 서버 기초 구축
- [ ] FastAPI 기반 엔드포인트(`analyze-journal`, `todo-feedback`) 구조 설계 및 Mock 테스트.
- [ ] **관측성 및 보안 미들웨어 구현** (Correlation ID, JSON Logging, Rate Limiting).
- [ ] 프로젝트 헌장에 따른 각 기능별 **단위 테스트(TDD) 선행 작성**.
- [ ] **레이어드 아키텍처 적용**: `src/api` (라우팅) 및 `src/service` (비즈니스 로직) 분리.

### 2단계: 분석 엔진 고도화 및 추천 로직 변경
- [ ] **종합 추천 프롬프트 수정** (Spotify 플레이리스트 ID, 실시간 영화 ID 생성, 음식 카테고리 포함).
- [ ] **콘텐츠 ID 유효성 검증 로직**: 정규식을 통한 Spotify/영화 ID 형식 체크.
- [ ] **안정성 메커니즘 적용**: `tenacity` 기반의 지수적 백오프 재시도 로직 구현.

### 3단계: 통합 검증 및 배포 준비
- [ ] 백엔드 시나리오 기반 통합 테스트 수행.
- [ ] `demo.py`를 API 클라이언트 형태로 변경하여 최종 동작 확인.
- [ ] **레거시 정리**: 사용하지 않는 Phase 2 코드(STT, TTS 모듈 등) 완전 제거.
