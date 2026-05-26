# capStone 프로젝트 지침 (GEMINI.md)
## 📌 현재 진행 상황
- **기능 명칭:** 능동형 AI 감정 케어 에이전트 (AI 분석 서버)
- **현재 상태:** **구현 완료 및 통합 테스트 통과 (REST API 서버)**
- **시스템 정보:** Linux + Python 3.12.3 + FastAPI 기반 API 서버
- **완료된 작업:**
  - [x] OpenAI GPT-4o 기반 감정 분석 및 추천 로직 고도화
  - [x] Spring Boot 백엔드 연동을 위한 REST API Endpoint (`/analyze-journal`, `/todo-feedback`) 구현
  - [x] Spotify 플레이리스트 ID Pool 기반 추천 로직 (실제 링크 일치화 완료)
  - [x] Todo 성취도 및 감정 상태 결합 피드백 엔진 구축
  - [x] 인프라 강화: Rate Limiting(120 RPM), Tenacity 재시도, JSON 로깅(마스킹 적용)
  - [x] TDD 실천: 모든 엔드포인트 및 로직에 대한 단위/통합 테스트 완료
  - [x] 레거시 정리: Phase 2 음성 처리(STT/TTS) 코드 완전 삭제

## 🤖 Gemini CLI 참조 지침
1. **최우선 참조 디렉토리:**
   - `./.specify/features/feature/1-ai-emotional-care/`
   - 위 디렉토리 내의 `spec.md`, `plan.md`, `tasks.md`가 최신 상태입니다.

2. **핵심 원칙 준수 결과:**
   - **한국어 사용:** 모든 프롬프트와 문서에 한국어 적용 완료.
   - **JSON 통신 규격:** Pydantic 모델을 통한 백엔드 규격 엄격 준수.
   - **플레이리스트 추천:** Spotify ID(22자 Base62) 규격 준수.
   - **보안:** 로그 내 민감 정보 마스킹 필터 적용.

---
*이 파일은 에이전트의 효율적인 컨텍스트 활용을 위해 작성되었습니다.*
