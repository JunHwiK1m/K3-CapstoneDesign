# RESTful API Specifications

이 문서는 프로젝트의 백엔드 API 명세서입니다. `backend/api.md`를 기반으로 작성되었으며 각 API의 응답 데이터 형식을 포함합니다.

## 1. 응답 공통 규격
모든 API 응답은 아래의 공통 형식을 따릅니다.
```json
{
  "success": true,
  "message": "요청이 성공적으로 처리되었습니다.",
  "data": { ... } // 실제 반환 데이터. 실패 시 null
}
```

## 2. 인증 (Authentication)
| Method | Endpoint | Description | Response Data Example |
| :--- | :--- | :--- | :--- |
| POST | `/api/auth/signup` | 이메일 회원가입 | `1` (생성된 user_id) |
| POST | `/api/auth/login` | 일반 로그인 | `{"accessToken": "eyJ...", "email": "test@test.com"}` |
| GET | `/login-success` | 소셜 로그인 성공 (Redirect) | (Redirect) |

## 3. 파일 업로드 (Files)
| Method | Endpoint | Description | Response Data Example |
| :--- | :--- | :--- | :--- |
| POST | `/api/files/upload` | 단일 파일 업로드 | `"http://localhost:8080/uploads/..."` |
| POST | `/api/files/upload-multiple` | 다중 파일 업로드 | `["http://localhost:8080/uploads/..."]` |

## 4. 사용자 설정 (User Settings)
| Method | Endpoint | Description | Response Data Example |
| :--- | :--- | :--- | :--- |
| GET | `/api/users/settings` | 설정 조회 | `{"diaryTime": "21:00", "usagePurpose": "MENTAL_CARE", "nickname": "리피", "musicStyles": ["Jazz"], "personaStyle": "BASIC", "isAiAnalysisEnabled": true, "isConfigured": true}` |
| PATCH | `/api/users/settings` | 설정 전체 수정 | `null` |
| PUT | `/api/users/settings/ai-analysis` | AI 분석 활성화 토글 | `null` (Query Param: `enabled=true/false`) |
| PATCH | `/api/users/settings/fcm-token` | FCM 토큰 업데이트 | `null` (Query Param: `token=...`) |

## 5. 일기 기록 (Journals)
| Method | Endpoint | Description | Response Data Example |
| :--- | :--- | :--- | :--- |
| POST | `/api/journals` | 일기 작성 (AI 분석 자동 시작) | `10` (생성된 journal_id) |
| GET | `/api/journals` | 내 일기 목록 조회 | `[{"id": 1, "content": "내용", "analysisStatus": "COMPLETED", "createdAt": "..."}]` |
| GET | `/api/journals/{id}`| 일기 상세 조회 | `{"id": 10, "content": "전체내용", "analysisStatus": "COMPLETED", "emotionResult": {"joyScore": 0.85, ...}}` |

## 6. 맞춤형 추천 (Recommendations)
| Method | Endpoint | Description | Response Data Example |
| :--- | :--- | :--- | :--- |
| GET | `/api/recommendations` | 일기별 추천 목록 조회 | `[{"id": 1, "category": "MUSIC", ...}]` (Query Param: `journalId=1`) |
| PATCH | `/api/recommendations/{id}/click` | 추천 클릭 상태 업데이트 | `null` |

## 7. 할 일 관리 (Todos)
| Method | Endpoint | Description | Response Data Example |
| :--- | :--- | :--- | :--- |
| POST | `/api/todos` | 할 일 생성 | `5` (생성된 todo_id) |
| GET | `/api/todos` | 내 할 일 목록 조회 | `[{"id": 1, "taskName": "명상", "isCompleted": false, "dueDate": "..."}]` |
| GET | `/api/todos/stats` | 할 일 달성률 통계 조회 | `{"totalCount": 5, "completedCount": 4, "completionRate": 0.8000, "feedbackMessage": "..."}` |
| PUT | `/api/todos/{id}` | 할 일 정보 수정 | `null` |
| PATCH | `/api/todos/{id}/complete` | 할 일 완료 처리 | `null` |
| DELETE | `/api/todos/{id}` | 할 일 삭제 | `null` |

## 8. 상점 및 아이템 (Store & Items)
| Method | Endpoint | Description | Response Data Example |
| :--- | :--- | :--- | :--- |
| GET | `/api/items` | 전체 아이템 목록 조회 | `[{"id": 1, "name": "...", ...}]` |
| GET | `/api/items/my` | 내 아이템 목록 조회 | `[{"userItemId": 1, "item": {...}, "isEquipped": true}]` |
| POST | `/api/items/{itemId}/purchase` | 아이템 구매 | `null` |
| PATCH | `/api/items/user-items/{userItemId}/equip`| 아이템 장착 | `null` |
