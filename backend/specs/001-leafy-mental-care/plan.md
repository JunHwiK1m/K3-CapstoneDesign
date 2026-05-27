# Implementation Plan: Leafy AI Mental Care Agent

**Branch**: `001-leafy-mental-care` | **Date**: 2026-05-06 | **Spec**: specs/001-leafy-mental-care/spec.md
**Input**: Feature specification and architecture roadmap.

## Summary
Leafy는 사용자의 일기(텍스트, 음성)를 분석하여 감정 데이터를 도출하고, 이에 기반한 맞춤형 라이프스타일 추천(음악, 음식 등)을 제공하는 AI 에이전트입니다. 본 프로젝트는 Java 21, Spring Boot 3.5.x, PostgreSQL을 기반으로 하며, FastAPI AI 서버와의 OpenFeign 연동을 핵심으로 합니다.

## Technical Context

**Language/Version**: [Java 21 / Spring Boot 3.5.x]  
**Primary Dependencies**: [Spring Data JPA, PostgreSQL, QueryDSL, Spring Cloud OpenFeign, LangChain4j, SpringDoc]  
**Storage**: [PostgreSQL (pgvector)]  
**Testing**: [JUnit 5, Mockito]  
**Target Platform**: [JVM / Linux]
**Project Type**: [Spring Boot Web Service]  
**Performance Goals**: [AI Inference Timeout: 60s]  
**Constraints**: [Clean Code, DTO-only exposure, @Async for AI tasks, JWT Security]  

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] Java 21 & Spring Boot 3.5.x 준수 여부
- [x] Layered Architecture (Controller-Service-Repository) 적용 여부
- [x] DTO 기반 데이터 전송 설계 여부
- [x] OpenFeign 기반 외부 통신 설계 여부
- [x] 비동기 처리(@Async) 설계 여부

## Project Structure

### Documentation (this feature)

```text
specs/001-leafy-mental-care/
├── plan.md              # 이 파일
├── research.md          # 기술 조사 및 결정 사항
├── data-model.md        # 데이터베이스 엔티티 설계
├── quickstart.md        # 개발 환경 설정 가이드
├── contracts/           # API 계약 (AI 서버 연동)
└── tasks.md             # 구현 작업 리스트
```

### Source Code (repository root)

```text
src/main/java/com/leafy/
├── controller/          # API 엔드포인트
├── service/            # 비즈니스 로직 및 비동기 작업
├── repository/         # JPA 및 QueryDSL 저장소
├── entity/             # JPA 엔티티
├── dto/                # 데이터 전송 객체
├── config/             # Security, Async, Feign 설정
├── exception/          # 전역 예외 처리
└── client/             # OpenFeign 클라이언트 (AiServerClient)
```

## Phase 0: Research (Completed)
- `research.md`에 기술 결정 사항 정리 완료.
- AI 서버 연동, 보안, 비동기 처리 전략 수립.

## Phase 1: Design (Completed)
- `data-model.md`에 ERD 기반 엔티티 설계 완료.
- `contracts/ai-server-contract.md`에 외부 인터페이스 정의 완료.
- `quickstart.md`에 개발 환경 가이드 작성 완료.

## Phase 2: Task Generation
- `/speckit.tasks` 명령어를 통해 실행 가능한 작업 리스트 생성 예정.
