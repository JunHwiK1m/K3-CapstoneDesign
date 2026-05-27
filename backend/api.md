# Leafy Backend API Documentation

이 문서는 Leafy 백엔드 서버에 구현된 모든 REST API 명세를 제공합니다.
모든 API 응답은 `CommonResponse<T>` 형식으로 래핑되어 반환됩니다 (단, `/health` 및 `/login-success` 제외).

## 응답 공통 포맷
```json
{
  "success": true,
  "message": "요청이 성공적으로 처리되었습니다.",
  "data": { ... } // 실제 데이터. 데이터가 없는 경우 null
}
```

---

## 1. Health Check (서버 상태)

### 1.1 서버 상태 확인
- **Endpoint**: `GET /health`
- **Description**: 서버가 정상적으로 작동 중인지 확인합니다.
- **Response Example**:
```json
{
  "message": "Leafy Backend Server is running",
  "status": "UP",
  "timestamp": 1716796800000
}
```

---

## 2. Authentication (인증)

### 2.1 회원가입
- **Endpoint**: `POST /api/auth/signup`
- **Request Body**:
```json
{
  "email": "user@example.com",
  "password": "password123",
  "name": "홍길동"
}
```
- **Response Data**: 생성된 사용자 ID (`Long`)

### 2.2 로그인
- **Endpoint**: `POST /api/auth/login`
- **Request Body**:
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```
- **Response Data**: 발급된 토큰 정보
```json
{
  "accessToken": "eyJhbG...",
  "email": "user@example.com"
}
```

### 2.3 소셜 로그인 성공 결과 확인
- **Endpoint**: `GET /login-success`
- **Query Parameter**: `token` (JWT 토큰)
- **Description**: OAuth2 로그인 성공 후 리다이렉트되어 토큰 정보를 보여줍니다.

---

## 3. Files (파일 업로드)

**주의**: 일기 작성 시 이미지나 음성 파일이 있다면, 본 API를 통해 먼저 업로드하여 URL을 획득해야 합니다.

### 3.1 단일 파일 업로드
- **Endpoint**: `POST /api/files/upload`
- **Request Body**: `MultipartFile` (Form-data key: `file`)
- **Response Data**: 업로드된 파일의 접근 URL (`String`)
- **Example Response Data**: `"http://localhost:8080/uploads/afea9c06...png"`

### 3.2 다중 파일 업로드
- **Endpoint**: `POST /api/files/upload-multiple`
- **Request Body**: `List<MultipartFile>` (Form-data key: `files`)
- **Response Data**: 업로드된 파일 URL 리스트 (`List<String>`)

---

## 4. Journals (일기)

### 4.1 일기 작성 (AI 분석 자동 트리거)
- **Endpoint**: `POST /api/journals`
- **Description**: 작성 즉시 AI 분석이 비동기로 시작됩니다.
- **Request Body**:
```json
{
  "content": "오늘 하루는 정말 보람찼다.",
  "voiceUrl": "http://localhost:8080/uploads/voice-123.mp3",
  "imageUrls": ["http://localhost:8080/uploads/img-1.jpg"]
}
```
- **Response Data**: 생성된 일기 ID (`Long`)

### 4.2 내 일기 목록 조회
- **Endpoint**: `GET /api/journals`
- **Response Data**: `List<JournalDetailResponse>`

### 4.3 일기 상세 조회
- **Endpoint**: `GET /api/journals/{journalId}`
- **Response Data**:
```json
{
  "id": 10,
  "content": "오늘 정말 행복한 하루였다!",
  "voiceUrl": "http://...",
  "imageUrls": ["http://..."],
  "analysisStatus": "COMPLETED",
  "emotionResult": {
    "joyScore": 0.8500,
    "sadnessScore": 0.0500,
    "stressLevel": 0.1000,
    "emotionSummary": "매우 긍정적인 상태입니다."
  },
  "createdAt": "2026-05-25T13:45:00"
}
```

---

## 5. Recommendations (추천)

### 5.1 일기별 추천 목록 조회
- **Endpoint**: `GET /api/recommendations`
- **Query Parameter**: `journalId`
- **Response Data**: `List<Recommendation>` (카테고리, 내용, 외부링크 등 포함)

### 5.2 추천 클릭 상태 업데이트
- **Endpoint**: `PATCH /api/recommendations/{recommendationId}/click`
- **Description**: 추천 항목의 딥링크 클릭 여부를 기록합니다.

---

## 6. Todos (할 일)

### 6.1 할 일 생성
- **Endpoint**: `POST /api/todos`
- **Request Body**: `{"taskName": "명상하기", "dueDate": "2026-05-15T21:00:00"}`
- **Response Data**: 생성된 Todo ID (`Long`)

### 6.2 내 할 일 목록 조회
- **Endpoint**: `GET /api/todos`

### 6.3 할 일 달성률 및 피드백 조회
- **Endpoint**: `GET /api/todos/stats`
- **Response Data**:
```json
{
  "totalCount": 5,
  "completedCount": 4,
  "completionRate": 0.8000,
  "feedbackMessage": "정말 대단해요! 꾸준히 해나가는 모습이 보기 좋습니다."
}
```

### 6.4 할 일 정보 수정
- **Endpoint**: `PUT /api/todos/{todoId}`
- **Request Body**: `{"taskName": "수정된 할 일", "dueDate": "..."}`

### 6.5 할 일 완료 처리
- **Endpoint**: `PATCH /api/todos/{todoId}/complete`

### 6.6 할 일 삭제
- **Endpoint**: `DELETE /api/todos/{todoId}`

---

## 7. User Settings (사용자 설정)

### 7.1 사용자 설정 조회
- **Endpoint**: `GET /api/users/settings`
- **Response Data**: `UserSettingsResponse` (닉네임, 알림 시간, 페르소나 스타일 등)

### 7.2 사용자 설정 수정
- **Endpoint**: `PATCH /api/users/settings`
- **Request Body**: `{"nickname": "새닉네임", "diaryTime": "22:00", ...}`

### 7.3 AI 분석 활성화 설정 수정
- **Endpoint**: `PUT /api/users/settings/ai-analysis`
- **Query Parameter**: `enabled` (boolean)

### 7.4 FCM 토큰 업데이트
- **Endpoint**: `PATCH /api/users/settings/fcm-token`
- **Query Parameter**: `token` (String)

---

## 8. Store & Items (상점 및 아이템)

### 8.1 전체 아이템 목록 조회
- **Endpoint**: `GET /api/items`
- **Response Data**: `List<Item>` (상점에서 판매 중인 아이템들)

### 8.2 내 아이템 목록 조회
- **Endpoint**: `GET /api/items/my`
- **Response Data**: `List<UserItemResponse>` (보유 아이템 및 장착 여부)

### 8.3 아이템 구매
- **Endpoint**: `POST /api/items/{itemId}/purchase`

### 8.4 아이템 장착
- **Endpoint**: `PATCH /api/items/user-items/{userItemId}/equip`
