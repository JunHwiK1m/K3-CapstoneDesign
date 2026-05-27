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

- **Backend**: Java 21, Spring Boot 3.5.x, Spring Data JPA, Spring Security, OAuth 2.0
- **Database**: PostgreSQL (Production/Dev), H2 (Local/Test)
- **AI Integration**: OpenFeign (FastAPI 연동, Timeout 120s)
- **Storage**: Local File System (./uploads/), PostgreSQL
- **Security**: JWT, AES-256 (일기 본문 암호화)
- **Documentation**: SpringDoc OpenAPI (Swagger)

---

## ⚙️ 실행 환경 설정

### 1. 사전 요구 사항
- **AI 서버 실행**: 본 서비스는 감정 분석을 위해 별도의 FastAPI 서버가 필요합니다. `http://localhost:8000`에서 서버가 실행 중이어야 합니다.

### 2. 환경 변수 설정 (`.env`)
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

### 3. 빌드 및 실행
```bash
./gradlew clean build
./gradlew bootRun
```

---

## 📂 파일 저장 및 관리
- **이미지 및 음성**: 사용자가 업로드한 파일은 서버 로컬의 `./uploads/` 디렉토리에 저장됩니다.
- **URL 반환**: 파일 업로드 시 `http://localhost:8080/uploads/{UUID}.ext` 형식의 URL이 반환되며, 이 URL을 일기 작성 API의 `imageUrls` 또는 `voiceUrl` 필드에 포함하여 전송해야 합니다.

---

## 📑 주요 API 명세

### 1. 응답 공통 규격
모든 API 응답은 아래의 공통 형식을 따릅니다.
```json
{
  "success": true,
  "message": "요청이 성공적으로 처리되었습니다.",
  "data": { ... } // 실제 반환 데이터 (객체 또는 리스트)
}
```

### 2. 인증 (Authentication)
| Method | Endpoint | Description | Response Data Example |
| :--- | :--- | :--- | :--- |
| POST | `/api/auth/signup` | 이메일 회원가입 | `1` (생성된 user_id) |
| POST | `/api/auth/login` | 일반 로그인 | `{"accessToken": "eyJ...", "email": "user@test.com"}` |
| GET | `/login-success` | 소셜 로그인 성공 (Redirect) | `{"token": "eyJ...", "message": "OAuth2 login successful"}` |

### 3. 일기 (Journal)
| Method | Endpoint | Description | Request/Response Example |
| :--- | :--- | :--- | :--- |
| POST | `/api/journals` | 일기 작성 (AI 분석 시작) | **REQ:** `{"content": "...", "voiceUrl": "...", "imageUrls": ["url1", "url2"]}`<br>**RES:** `10` (journal_id) |
| GET | `/api/journals` | 내 일기 목록 조회 | `[{"id": 10, "content": "...", "analysisStatus": "COMPLETED", ...}]` |
| GET | `/api/journals/{id}`| 일기 상세 조회 | 아래 **상세 응답 예시** 참고 |

#### 일기 상세 조회 응답 예시 (`GET /api/journals/{id}`)
```json
{
  "success": true,
  "message": "CommonResponse success",
  "data": {
    "id": 10,
    "content": "오늘 정말 행복한 하루였다!",
    "voiceUrl": "https://...",
    "imageUrls": ["https://url1.jpg", "https://url2.jpg"],
    "analysisStatus": "COMPLETED",
    "emotionResult": {
      "joyScore": 0.8500,
      "sadnessScore": 0.0500,
      "stressLevel": 0.1000,
      "emotionSummary": "매우 긍정적이고 활기찬 상태입니다."
    },
    "createdAt": "2026-05-25T13:45:00"
  }
}
```

### 4. 사용자 설정 (User Settings)
| Method | Endpoint | Description | Response Data Example |
| :--- | :--- | :--- | :--- |
| GET | `/api/users/settings` | 설정 조회 | `{"diaryTime": "21:00", "usagePurpose": "MENTAL_CARE", "nickname": "리피", "isConfigured": true}` |
| PATCH | `/api/users/settings` | 설정 수정 | `null` |
| PUT | `/api/users/settings/ai-analysis` | AI 분석 활성화 토글 | `null` (Query Param: `enabled=true/false`) |

### 5. 추천 (Recommendation)
| Method | Endpoint | Description | Response Data Example |
| :--- | :--- | :--- | :--- |
| GET | `/api/recommendations` | 일기별 맞춤 추천 조회 | `[{"id": 1, "category": "MUSIC", "contentText": "...", "externalLink": "spotify:..."}]` |
| PATCH | `/api/recommendations/{id}/click` | 추천 클릭 상태 업데이트 | `null` |

### 6. 할 일 (Todo)
| Method | Endpoint | Description | Response Data Example |
| :--- | :--- | :--- | :--- |
| POST | `/api/todos` | 할 일 생성 | `5` (생성된 todo_id) |
| GET | `/api/todos` | 내 할 일 목록 조회 | `[{"id": 5, "taskName": "명상하기", "isCompleted": false}]` |
| GET | `/api/todos/stats` | 할 일 달성률 및 AI 피드백 조회 | 아래 **할 일 통계 응답 예시** 참고 |
| PUT | `/api/todos/{id}` | 할 일 수정 | `null` |
| PATCH | `/api/todos/{id}/complete` | 할 일 완료 처리 | `null` |
| DELETE | `/api/todos/{id}` | 할 일 삭제 | `null` |

#### 할 일 통계 응답 예시 (`GET /api/todos/stats`)
```json
{
  "success": true,
  "data": {
    "totalCount": 5,
    "completedCount": 1,
    "completionRate": 0.2000,
    "feedbackMessage": "오늘은 마음이 많이 울적해서 아무것도 하기 힘든 날이었을 거예요. 그래도 하나라도 해내신 당신이 정말 대견해요. 오늘은 이만 쉬어도 괜찮아요. 토닥토닥. 🌿"
  }
}
```

### 7. 상점 및 아이템 (Store & Item)
| Method | Endpoint | Description | Response Data Example |
| :--- | :--- | :--- | :--- |
| GET | `/api/items` | 전체 아이템 목록 조회 | `[{"id": 1, "itemName": "기본 페르소나", "price": 0, "itemType": "PERSONA"}]` |
| GET | `/api/items/my` | 내 아이템 목록 조회 | 아래 **내 아이템 응답 예시** 참고 |
| POST | `/api/items/{id}/purchase` | 아이템 구매 | `null` |
| PATCH | `/api/items/user-items/{id}/equip` | 아이템 장착 | `null` |

#### 내 아이템 목록 조회 응답 예시 (`GET /api/items/my`)
```json
{
  "success": true,
  "data": [
    {
      "userItemId": 1,
      "itemId": 100,
      "itemName": "치유의 숲 테마",
      "itemType": "THEME",
      "resourceUrl": "https://...",
      "isEquipped": true,
      "purchasedAt": "2026-05-25T10:00:00"
    }
  ]
}
```

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

## 🤖 AI 서버 연동 (Internal Communication)

백엔드와 AI 서버(FastAPI) 간의 통신 규격입니다. 이 API들은 백엔드 내부에서 비동기 또는 통계 조회 시 호출됩니다.

### 1. 일기 감정 분석 및 추천 통합 요청
사용자가 일기를 작성하면 백엔드는 비동기로 AI 서버에 분석을 요청합니다.

- **Endpoint:** `POST /analyze/full`
- **Request Body:**
```json
{
  "journal_id": 10,
  "content": "일기 원문 내용",
  "voice_url": "https://...",
  "persona_style": "FRIENDLY"
}
```
- **Response Body:**
```json
{
  "journal_id": 10,
  "joy_score": 0.8500,
  "sadness_score": 0.0500,
  "stress_level": 0.1000,
  "emotion_summary": "정말 멋진 하루를 보내셨네요!",
  "recommendations": [
    {
      "category": "MUSIC",
      "content_text": "신나는 음악",
      "external_link": "track_id_123"
    }
  ]
}
```

### 2. 할 일 성취도 피드백 요청
사용자가 할 일 통계를 조회할 때, 현재 상태를 기반으로 AI의 피드백을 요청합니다.

- **Endpoint:** `POST /analyze/todo`
- **Request Body:**
```json
{
  "total_count": 5,
  "completed_count": 1,
  "completion_rate": 0.2000,
  "persona_style": "FRIENDLY",
  "recent_emotion": "SADNESS"
}
```
- **Response Body:**
```json
{
  "feedback_message": "오늘은 마음이 많이 울적해서... 하나라도 해내신 당신이 정말 대견해요."
}
```

---

## 🔒 데이터 보안
- **일기 본문**: AES-256 알고리즘을 사용하여 데이터베이스 저장 시 암호화됩니다.
- **인증**: 모든 보호된 엔드포인트는 Bearer JWT 토큰을 요구합니다.
