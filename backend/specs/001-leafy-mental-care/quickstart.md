# Quickstart: Narae Development & Execution Guide

본 가이드는 Narae AI 멘탈케어 에이전트 시스템을 로컬 및 서버 환경에서 실행하기 위한 절차를 안내합니다.

## 1. Prerequisites (사전 요구사항)
- **Java**: JDK 21 이상
- **Database**: 
    - **Local**: H2 (In-memory, 별도 설치 불필요)
    - **Dev/Prod**: PostgreSQL 15+ (pgvector 확장 설치 권장)
- **Build Tool**: Gradle 8.x
- **External Services**: 
    - Google, Naver, Kakao OAuth2 API Key
    - FastAPI AI 서버 (감정 분석 및 추천 엔진)

## 2. Environment Variables (환경 변수 설정)
시스템 실행 전 다음 환경 변수들을 설정해야 합니다. (`application-local.yml`은 기본적으로 H2를 사용하므로 설정이 간소화됩니다.)

| Variable | Description | Example (PostgreSQL 사용 시) |
|----------|-------------|---------|
| `SPRING_PROFILES_ACTIVE` | 실행 프로파일 | `local`, `dev`, `prod` |
| `DATABASE_URL` | PostgreSQL 접속 주소 | `jdbc:postgresql://localhost:5432/narae` |
| `DATABASE_USERNAME` | DB 사용자명 | `postgres` |
| `DATABASE_PASSWORD` | DB 비밀번호 | `your_password` |
| `AI_SERVER_URL` | AI 서버(FastAPI) 주소 | `http://localhost:8000` |
| `JWT_SECRET` | JWT 서명용 비밀키 | `at-least-32-chars-long-secret-key` |
| `ENCRYPTION_KEY` | 일기 본문 암호화 키 (AES-256) | `32-char-encryption-key-for-aes-256` |

*참고: `local` 프로파일은 환경 변수 없이도 H2 인메모리 모드로 즉시 실행 가능합니다.*

### OAuth2 Client Settings
OAuth2 기능을 사용하려면 아래 설정을 `application.yml`에 추가하거나 환경 변수로 주입해야 합니다.
- `spring.security.oauth2.client.registration.google.client-id`
- `spring.security.oauth2.client.registration.google.client-secret`
- (Naver, Kakao 동일 방식 적용)

## 3. Setup Steps (실행 절차)

### Step 1: Database Setup (PostgreSQL 사용 시에만 해당)
```sql
CREATE DATABASE narae;
-- pgvector 확장이 필요한 경우 (고급 기능 사용 시)
CREATE EXTENSION IF NOT EXISTS vector;
```
*로컬 실행 시 H2를 사용하므로 이 단계는 건너뛰어도 됩니다.*

### Step 2: AI Server Execution
별도의 FastAPI 서버가 실행 중이어야 합니다. AI 서버의 엔드포인트(`/analyze/emotion`, `/recommend/action`)가 정상 동작하는지 확인하십시오.

### Step 3: Application Build & Run
```bash
# Repository 클론
git clone [repository_url]
cd K3-CapstoneDesign

# 프로젝트 빌드
./gradlew build -x test

# 애플리케이션 실행 (기본적으로 H2 사용)
./gradlew bootRun --args='--spring.profiles.active=local'
```

## 4. API Documentation (Swagger)
애플리케이션이 실행된 후 아래 주소에서 전체 API 명세를 확인할 수 있습니다.
- **URL**: `http://localhost:8080/swagger-ui.html`
- **H2 Console**: `http://localhost:8080/h2-console` (JDBC URL: `jdbc:h2:mem:narae`, ID: `sa`, PW: 없음)
- **인증**: 상단 `Authorize` 버튼을 클릭하고 JWT 토큰(`Bearer {token}`)을 입력하여 인증이 필요한 API를 테스트할 수 있습니다.

## 5. Testing (검증)
```bash
# 전체 테스트 실행
./gradlew test

# 특정 테스트 클래스 실행 (예: 암호화 유틸리티)
./gradlew test --tests com.narae.util.AESUtilTest
```

## 6. Key Features (주요 기능 작동 확인)
1. **Login**: `/api/auth/signup`으로 가입 후 `/api/auth/login`으로 토큰을 발급받습니다.
2. **Journal**: `POST /api/journals`로 일기를 작성하면 백엔드 로그에서 비동기 분석(`AsyncAnalysisService`)이 시작되는지 확인합니다.
3. **Action**: `GET /api/recommendations?journalId={id}`로 생성된 딥링크 추천 목록을 확인합니다.
4. **Security**: DB의 `journals` 테이블을 조회하여 `content`가 암호화되어 저장되었는지 확인합니다. (H2 콘솔 이용 가능)
