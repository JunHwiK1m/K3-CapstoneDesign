# Leafy: AI Mental Care Agent 🌿

Leafy는 사용자의 일기(텍스트 및 멀티모달 데이터)를 분석하여 감정 상태를 파악하고, 그에 맞는 맞춤형 활동을 추천해주는 AI 기반 멘탈케어 에이전트 시스템입니다.

---

## 🚀 주요 기능

- **멀티모달 저널링**: 텍스트, 음성, 이미지를 활용한 일기 작성 및 AI 기반 비동기 감정 분석.
- **맞춤형 에이전틱 액션**: 분석된 감정에 따라 음악, 음식, 영화 등의 활동 추천 및 관련 서비스 딥링크 제공.
- **개인화 설정**: 페르소나 스타일(기본/친구형), 리마인더 시간, 사용 목적 설정 가능.
- **지능형 리마인더**: 사용자가 설정한 시간에 맞춰 일기 작성을 독려하는 선제적 알림 발송.
- **고위험군 탐지**: 지속적인 부정 감정 감지 시 고위험군 분류 및 전문 기관 안내.
- **소셜 로그인**: 구글, 네이버, 카카오를 통한 간편 로그인 지원.

---

## 🛠 기술 스택

- **Backend**: Java 21, Spring Boot 3.4.x, Spring Data JPA, Spring Security, OAuth 2.0
- **Database**: PostgreSQL (Production/Dev), H2 (Local/Test)
- **AI Integration**: OpenFeign (FastAPI 연동)
- **Security**: JWT, AES-256 (일기 본문 암호화)
- **Documentation**: SpringDoc OpenAPI (Swagger)

---

## ⚙️ 실행 환경 설정

### 1. 환경 변수 설정 (`.env`)
프로젝트 루트 디렉토리에 `.env` 파일을 생성하고 아래 내용을 환경에 맞게 입력하세요.

```env
# Database (Dev/Prod)
DEV_DB_URL=jdbc:postgresql://localhost:5432/leafy
DEV_DB_USERNAME=postgres
DEV_DB_PASSWORD=your_password

# OAuth2 Credentials
GOOGLE_CLIENT_ID=your_id
GOOGLE_CLIENT_SECRET=your_secret
NAVER_CLIENT_ID=your_id
NAVER_CLIENT_SECRET=your_secret
KAKAO_CLIENT_ID=your_id
KAKAO_CLIENT_SECRET=your_secret

# Security
JWT_SECRET=your_super_secret_key_at_least_32_chars
ENCRYPTION_KEY=your_32_char_aes_key

# External AI Server
DEV_AI_SERVER_URL=http://localhost:8000
```

### 2. 빌드 및 실행
```bash
./gradlew clean build
./gradlew bootRun
```

---

## 📑 주요 API 명세

전체 API 명세는 서버 실행 후 `http://localhost:8080/swagger-ui.html`에서 확인 가능합니다.

### 1. 인증 (Authentication)
| Method | Endpoint | Description |
| :--- | :--- | :--- |
| POST | `/api/auth/signup` | 이메일 기반 회원가입 |
| POST | `/api/auth/login` | 이메일 기반 로그인 (JWT 발급) |

### 2. 일기 (Journal)
| Method | Endpoint | Description |
| :--- | :--- | :--- |
| POST | `/api/journals` | 일기 작성 (AI 분석 비동기 요청 포함) |
| GET | `/api/journals` | 사용자의 일기 목록 조회 |

### 3. 사용자 설정 (User Settings)
| Method | Endpoint | Description |
| :--- | :--- | :--- |
| GET | `/api/users/settings` | 현재 사용자의 리마인더 시간, 페르소나 등 조회 |
| PATCH | `/api/users/settings` | 사용자 설정값 수정 |

### 4. 추천 및 할 일 (Recommendation & Todo)
| Method | Endpoint | Description |
| :--- | :--- | :--- |
| GET | `/api/recommendations` | 감정 분석 기반 맞춤형 추천 목록 조회 |
| PATCH | `/api/recommendations/{id}/click` | 추천 항목 클릭 상태 업데이트 |
| GET | `/api/todos` | AI가 추천한 할 일 목록 조회 |
| PUT | `/api/todos/{id}` | 할 일 상태 수정 및 완료 처리 |

---

## 🔄 사용자 로그인 및 온보딩 워크플로우

사용자가 서비스를 처음 이용할 때 원활한 온보딩을 위해 다음과 같은 흐름으로 API를 활용할 수 있습니다.

1.  **로그인 수행**: OAuth2 또는 일반 로그인을 통해 JWT 토큰을 발급받습니다.
2.  **설정 상태 확인**: `GET /api/users/settings`를 호출하여 응답의 `isConfigured` 값을 확인합니다.
    *   `isConfigured: false`: 필수 설정(생년월일, 리마인더 시간)이 없는 상태입니다. **초기 설정 페이지**로 이동시킵니다.
    *   `isConfigured: true`: 이미 설정을 완료한 사용자입니다. **메인 페이지**로 이동시킵니다.
3.  **초기 설정 저장**: 설정 페이지에서 사용자가 값을 입력하면 `PATCH /api/users/settings`를 호출하여 정보를 저장합니다.
4.  **서비스 이용**: 설정이 완료되면 백엔드의 리마인더 스케줄러가 해당 시간에 맞춰 자동으로 작동하며, 사용자는 일기 작성 및 추천 기능을 이용할 수 있습니다.

---

## 🔒 데이터 보안
- **일기 본문**: AES-256 알고리즘을 사용하여 데이터베이스 저장 시 암호화됩니다.
- **인증**: 모든 보호된 엔드포인트는 Bearer JWT 토큰을 요구합니다.
