# capStone 프로젝트 지침 (GEMINI.md)
## 📌 현재 진행 상황
- **기능 명칭:** 능동형 AI 감정 케어 에이전트 (AI 분석 서버)
- **현재 상태:** **최종 구현 완료 및 검증 통과 (GPT-4o 기반 유지)**
- **시스템 정보:** Linux + Python 3.12.3 + FastAPI 기반 API 서버
- **완료된 작업:**
  - [x] **안정성 확보**: Gemma-4 모델 연동 테스트 후, 안정성을 위해 기존 **GPT-4o** 모델 체제 유지
  - [x] **신규 기능**: Flutter 앱 직접 연동을 위한 `/api/ai/daily-message` (응원 메시지) 추가
  - [x] **API 구조**: 백엔드 연동용 `/api/ai/journals`, `/api/ai/todos/feedback` 통합 및 최적화
  - [x] **안정성**: 지수적 백오프, Rate Limiting, JSON 로깅 및 마스킹 적용 유지
  - [x] **문서화**: README.md 및 .specify 기술 명세서 최신화 완료

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
