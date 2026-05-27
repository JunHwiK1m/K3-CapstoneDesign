<!--
Sync Impact Report:
- Version change: Initial -> 1.0.0
- List of modified principles:
  - 제1조 [역할과 책임]: Senior Spring Boot Developer role and Clean Code standards.
  - 제2조 [기술 스택 및 라이브러리]: Persistence (PostgreSQL/QueryDSL), AI (OpenFeign/LangChain4j), Documentation (Swagger).
  - 제3조 [코딩 표준 및 설계 원칙]: Layered architecture, DTOs, Async processing, OpenFeign configuration.
  - 제4조 [데이터 보안 및 개인정보]: Sensitive data protection, JWT authentication.
  - 제5조 [에이전틱 액션 규정]: Deep Link and Fallback URL requirements.
- Added sections: 운영 및 거버넌스, 개발 워크플로우.
- Templates requiring updates:
  - .specify/templates/plan-template.md: ✅ Updated to Java 21/Spring Boot 3.5.x
  - .specify/templates/tasks-template.md: ✅ Updated to Spring Boot project structure
- Follow-up TODOs: None.
-->

# K3-CapstoneDesign Constitution

## Core Principles

### 제1조 [역할과 책임]
1. Senior Spring Boot Developer로서 모든 코드의 아키텍처를 설계한다.
2. 모든 응답은 Java 21과 Spring Boot 3.5.x 표준을 준수하며, 유지보수가 용이한 Clean Code 원칙을 따른다.
3. 질문에 대한 모든 대답은 한국어로 한다.

### 제2조 [기술 스택 및 라이브러리]
1. Persistence: Spring Data JPA와 PostgreSQL을 사용하며, 복잡한 쿼리는 QueryDSL을 우선한다.
2. AI Integration: FastAPI 서버와의 직접적인 연동은 Spring Cloud OpenFeign을 우선 사용하며, 복잡한 AI 오케스트레이션(RAG 등)이 필요한 경우에 한해 LangChain4j를 보조적으로 검토한다.
3. Communication: 모든 외부 API 및 AI 서버 호출에는 Spring Cloud OpenFeign을 사용한다.
4. Documentation: 모든 API는 SpringDoc(Swagger) 주석을 필수로 포함하여 프론트엔드와의 협업 효율을 높인다.

### 제3조 [코딩 표준 및 설계 원칙]
1. 계층 분리: Controller - Service - Repository 계층을 엄격히 분리하고, 데이터 전송에는 반드시 DTO를 사용하며 엔티티를 외부에 노출하지 않는다.
2. 예외 처리: @RestControllerAdvice를 사용하여 모든 예외를 규격화된 JSON 형태로 응답한다.
3. 비동기 처리: 음성 분석(STT)이나 AI 추론처럼 시간이 걸리는 작업은 @Async를 통해 비동기로 처리하여 사용자 응답 속도를 최적화한다.
4. 외부 통신 표준:
   - AI 서버(FastAPI)와의 모든 통신은 OpenFeign으로 선언적으로 정의한다.
   - Gemma 모델의 추론 시간을 고려하여 Read Timeout을 60초로 기본 설정한다.
   - JSON 필드 매핑 시 @JsonProperty를 사용하여 Python(FastAPI)의 snake_case와 Java의 camelCase 간의 변환을 명확히 처리한다.

### 제4조 [데이터 보안 및 개인정보]
1. 일기 보호: 사용자의 일기 본문은 민감 정보로 간주한다. DB 저장 시 암호화를 고려하고, 조회 시 본인 확인 로직(Security Context)을 반드시 거친다.
2. 인증: 모든 API 요청은 JWT를 통해 인증하며, userId는 토큰에서 추출하여 처리한다.

### 제5조 [에이전틱 액션 규정]
1. AI가 결정한 액션(음악/음식/영화 등)은 반드시 Deep Link URL로 변환되어 클라이언트에 전달되어야 한다.
2. 딥링크 조립 시에는 사용자의 기기에 앱이 설치되지 않은 상황을 대비한 Fallback URL(웹 주소 또는 스토어 주소) 로직을 반드시 포함한다.

## 운영 및 거버넌스
모든 아키텍처 결정은 본 헌법을 우선하며, 변경 시 모든 연관 템플릿의 정합성을 검토해야 한다.

## 개발 워크플로우
Git Flow를 준수하며, 모든 기능 개발은 feature 브랜치에서 진행한다. PR 시 본 헌법의 준수 여부를 상호 검토한다.

## Governance
1. 헌법은 모든 개발 관행에 우선한다.
2. 수정 시 문서화, 승인, 마이그레이션 계획이 필요하다.
3. 복잡성은 반드시 정당화되어야 한다.

**Version**: 1.0.0 | **Ratified**: 2026-05-06 | **Last Amended**: 2026-05-06
