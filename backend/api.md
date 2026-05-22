# Leafy Backend API Documentation

이 문서는 Leafy 백엔드 서버에 현재 구현된 모든 REST API의 명세를 제공합니다.
모든 API 응답은 `CommonResponse<T>` 형식으로 래핑되어 반환됩니다.

## 응답 공통 포맷
```json
{
  "status": "SUCCESS",
  "message": "요청이 성공적으로 처리되었습니다.",
  "data": { ... } // 실제 데이터. 실패 시 null
}
```

---

## 1. Authentication (인증)

### 1.1 일반 회원가입
- **Endpoint**: `POST /api/auth/signup`
- **Description**: 이메일과 비밀번호를 사용하여 새로운 계정을 생성합니다.
- **Request Body**: `{"email": "test@test.com", "password": "pass", "name": "사용자"}`
- **Response Data**: 생성된 사용자 ID (`Long`)

### 1.2 일반 로그인
- **Endpoint**: `POST /api/auth/login`
- **Description**: 이메일과 비밀번호로 로그인하여 JWT 토큰을 발급받습니다.
- **Request Body**: `{"email": "test@test.com", "password": "pass"}`
- **Response Data**: `{"accessToken": "eyJ...", "email": "test@test.com"}`

### 1.3 소셜 로그인 콜백 (내부용)
- **Endpoint**: `GET /login-success`
- **Description**: OAuth2 로그인 성공 후 토큰을 반환받는 임시 리다이렉트 URL입니다.

---

## 2. User Settings (사용자 설정)

### 2.1 사용자 설정 조회
- **Endpoint**: `GET /api/users/settings`
- **Description**: 현재 로그인한 사용자의 프로필 및 앱 설정을 조회합니다.
- **Response Data**: `{"diaryTime": "21:00", "usagePurpose": "MENTAL_CARE", "nickname": "리피", "musicStyles": ["Jazz"], "personaStyle": "BASIC", "isAiAnalysisEnabled": true, "isConfigured": true}`

### 2.2 사용자 설정 전체 수정
- **Endpoint**: `PATCH /api/users/settings`
- **Description**: 사용자의 설정 정보를 수정합니다.
- **Request Body**: `{"diaryTime": "21:00", "nickname": "새이름", "isAiAnalysisEnabled": true, ...}`
- **Response Data**: `null`

### 2.3 AI 분석 활성화 토글
- **Endpoint**: `PUT /api/users/settings/ai-analysis`
- **Description**: 일기 작성 시 AI 분석 기능의 켜고 끄기를 설정합니다.
- **Request Parameters**: `?enabled=true` (또는 `false`)
- **Response Data**: `null`

---

## 3. Journals (일기 기록)

### 3.1 일기 작성 (AI 분석 자동 트리거)
- **Endpoint**: `POST /api/journals`
- **Description**: 새로운 일기를 작성합니다. 작성 직후 AI 서버로 비동기 분석 요청이 전송됩니다.
- **Request Body**: `{"content": "오늘 일기 내용...", "voiceUrl": "...", "imgUrl": "..."}`
- **Response Data**: 생성된 일기 ID (`Long`)

### 3.2 내 일기 목록 조회
- **Endpoint**: `GET /api/journals`
- **Description**: 사용자가 작성한 모든 일기 목록을 최신순으로 조회합니다.
- **Response Data**: `[{"id": 1, "content": "내용", "analysisStatus": "COMPLETED", "createdAt": "..."}]`

### 3.3 일기 상세 조회
- **Endpoint**: `GET /api/journals/{id}`
- **Description**: 특정 일기의 전체 내용과 감정 분석 결과(있는 경우)를 조회합니다.
- **Response Data**: `{"id": 1, "content": "전체내용", "analysisStatus": "COMPLETED", "emotion": {"joyScore": 0.8, "summary": "..."}}`

### 3.4 일기 분석 수동 재요청
- **Endpoint**: `POST /api/journals/{id}/analyze`
- **Description**: 분석에 실패했거나 누락된 일기에 대해 AI 분석을 다시 요청합니다.
- **Response Data**: `null`

---

## 4. Recommendations (맞춤형 추천)

### 4.1 특정 일기의 추천 목록 조회
- **Endpoint**: `GET /api/recommendations/journal/{journalId}`
- **Description**: 특정 일기 분석 결과로 생성된 맞춤형 추천(음악, 영화 등) 목록을 조회합니다.
- **Response Data**: `[{"id": 1, "category": "MUSIC", "contentText": "설명", "externalLink": "spotify:...", "fallbackUrl": "https...", "isClicked": false}]`

### 4.2 내 모든 추천 목록 조회
- **Endpoint**: `GET /api/recommendations`
- **Description**: 사용자가 받은 전체 추천 목록을 최신순으로 조회합니다.
- **Response Data**: 위와 동일한 리스트 배열

### 4.3 추천 항목 클릭(확인) 처리
- **Endpoint**: `PATCH /api/recommendations/{id}/click`
- **Description**: 사용자가 특정 추천 항목(딥링크)을 클릭했음을 서버에 알립니다.
- **Response Data**: `null`

---

## 5. Todos (할 일 관리)

### 5.1 할 일 생성
- **Endpoint**: `POST /api/todos`
- **Description**: 새로운 할 일(태스크)을 등록합니다.
- **Request Body**: `{"taskName": "명상하기", "dueDate": "2026-05-15T00:00:00"}`
- **Response Data**: 생성된 Todo ID (`Long`)

### 5.2 내 할 일 목록 조회
- **Endpoint**: `GET /api/todos`
- **Description**: 사용자의 모든 할 일 목록을 기한이 가까운 순으로 조회합니다.
- **Response Data**: `[{"id": 1, "taskName": "명상", "isCompleted": false, "dueDate": "..."}]`

### 5.3 할 일 달성률 통계 조회
- **Endpoint**: `GET /api/todos/stats`
- **Description**: 사용자의 전체 할 일 대비 완료된 비율을 조회합니다. (AI 서버 피드백용으로 활용)
- **Response Data**: `{"totalCount": 10, "completedCount": 8, "completionRate": 0.8000}`

### 5.4 할 일 정보 수정
- **Endpoint**: `PUT /api/todos/{todoId}`
- **Description**: 할 일의 내용이나 마감일을 수정합니다.
- **Request Body**: `{"taskName": "수정된 명상", "dueDate": "..."}`
- **Response Data**: `null`

### 5.5 할 일 완료 처리
- **Endpoint**: `PATCH /api/todos/{todoId}/complete`
- **Description**: 특정 할 일을 완료 상태로 변경합니다.
- **Response Data**: `null`

### 5.6 할 일 삭제
- **Endpoint**: `DELETE /api/todos/{todoId}`
- **Description**: 특정 할 일을 삭제합니다.
- **Response Data**: `null`

---

## 6. Store & Items (상점 및 아이템)

### 6.1 활성화된 페르소나 스타일 조회
- **Endpoint**: `GET /api/items/active-persona`
- **Description**: 사용자가 현재 장착하고 있는 페르소나 아이템을 확인합니다. (없을 시 `BASIC` 반환)
- **Response Data**: `{"personaStyle": "FRIENDLY_BOT"}`