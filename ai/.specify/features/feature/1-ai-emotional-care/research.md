# 리서치 보고서: AI 분석 서버 고도화 (REST API 전환)

## 1. 개요
본 보고서는 AI 분석 서버를 REST API(FastAPI)로 전환하고, 감정 기반 추천 및 성취도 피드백 기능을 고도화하기 위한 기술적 의사결정을 포함합니다.

## 2. 주요 의사결정

### 2.1 Spotify 플레이리스트 ID 관리 방식
- **결정:** `src/config/spotify_playlists.json` 파일에 감정 카테고리별 ID Pool을 저장 및 관리.
- **근거:** 
  - 하드코딩보다 유연하며, 별도의 DB 구축 없이도 쉽게 업데이트 가능.
  - 백엔드(Spring Boot)에서 요구하는 "고정된 Pool에서 무작위/조건부 선택" 방식에 적합.
- **대안:** 코드 내 Constant 정의 (유지보수성 낮음), 외부 DB (MVP 단계에서 오버헤드).

### 2.2 부하 조절 및 Rate Limiting (120 RPM)
- **결정:** `slowapi` 라이브러리를 활용한 인메모리(In-memory) Rate Limiting 구현.
- **근거:** 
  - FastAPI와 연동이 간편함.
  - 분당 120회 요청 제한을 엔드포인트별 또는 IP별로 손쉽게 설정 가능.
- **대안:** 커스텀 미들웨어 작성 (구현 비용 발생).

### 2.3 요청 추적 (Correlation ID)
- **결정:** FastAPI 미들웨어를 통해 `X-Correlation-ID` 헤더를 처리하고, 모든 로그에 해당 ID를 포함.
- **근거:** 
  - Spring Boot 백엔드와의 통합 모니터링 및 트러블슈팅을 위해 필수적임.
- **대안:** 없음 (표준적인 관행).

### 2.4 OpenAI API 재시도 전략 (Exponential Backoff)
- **결정:** `tenacity` 라이브러리를 사용하여 지수적 백오프(Exponential Backoff)가 포함된 재시도 로직 구현.
- **근거:** 
  - 네트워크 불안정성이나 OpenAI API의 일시적 장애(Rate limit 등)에 안정적으로 대응 가능.
- **대안:** `requests`의 `HTTPAdapter` (OpenAI SDK와 혼용 시 복잡함).

### 2.5 JSON 로깅 (Structured Logging)
- **결정:** `python-json-logger`를 사용하여 표준 출력을 JSON 형식으로 전환.
- **근거:** 
  - CloudWatch나 ELK 스택 등 로그 분석 도구와 연동하기 용이함.
- **대안:** 기본 string 로깅 (파싱 어려움).

## 3. 기술 스택 업데이트 (추가 필요 패키지)
- `fastapi`, `uvicorn`: API 서버 구축
- `slowapi`: Rate Limiting
- `tenacity`: 재시도 로직
- `python-json-logger`: JSON 로깅
- `httpx`: (필요 시) 비동기 통신

## 4. 향후 과제 (Next Steps)
- `src/config/spotify_playlists.json` 기초 데이터 구성.
- FastAPI 프로젝트 구조 설정 및 미들웨어 구현.
