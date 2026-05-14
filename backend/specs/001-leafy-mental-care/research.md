# Research: Leafy AI Mental Care Agent

## AI Server Integration (FastAPI + OpenFeign)
- **Decision**: Use `Spring Cloud OpenFeign` with a 60s read timeout.
- **Rationale**: Declarative REST client simplifies external calls. 60s is necessary for Gemma model inference latency.
- **Alternatives**: RestTemplate (deprecated), WebClient (reactive - not needed for this synchronous-style architecture).

## Security & OAuth2
- **Decision**: Spring Security + JWT. Support Google, Naver, Kakao.
- **Rationale**: Standard industry practice for social login and stateless session management.
- **Implementation**: Custom `OncePerRequestFilter` to validate JWT. `SecurityContextHolder` to store `userId`.

## Async Processing
- **Decision**: `@Async` with a custom `TaskExecutor`.
- **Rationale**: Journal analysis and STT are long-running tasks. We must return 201 Created to the user immediately and process analysis in the background.

## Deep Link & Fallback Logic
- **Decision**: Custom `DeepLinkBuilder` service.
- **Rationale**: Consistent scheme generation (`leafy://...`) with URL fallbacks ensures UX consistency regardless of app installation status.

## High Risk Detection (Time-Series)
- **Decision**: Service-layer logic querying the last 4 weeks of `EmotionResult`.
- **Rationale**: SQL aggregation on `joy_score`, `sadness_score`, and `stress_level` to identify trends. Use a system-wide threshold (Clarified in Spec).

## Sensitive Data Protection
- **Decision**: AES-256 for Journal content in DB, Logback masking for logs.
- **Rationale**: Diary content is highly sensitive. Logs must never expose raw PII.
