# RESTful API Specifications

이 문서는 프로젝트의 백엔드 API 명세서입니다. `backend/api.md`를 기반으로 작성되었으며 각 API의 응답 데이터 형식을 포함합니다.

## 1. 응답 공통 규격
모든 API 응답은 아래의 공통 형식을 따릅니다.
```json
{
  "status": "SUCCESS",
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

## 3. 사용자 설정 (User Settings)
| Method | Endpoint | Description | Response Data Example |
| :--- | :--- | :--- | :--- |
| GET | `/api/users/settings` | 설정 조회 | `{"diaryTime": "21:00", "usagePurpose": "MENTAL_CARE", "nickname": "리피", "musicStyles": ["Jazz"], "personaStyle": "BASIC", "isAiAnalysisEnabled": true, "isConfigured": true}` |
| PATCH | `/api/users/settings` | 설정 전체 수정 | `null` |
| PUT | `/api/users/settings/ai-analysis` | AI 분석 활성화 토글 | `null` (Query Param: `enabled=true/false`) |

## 4. 일기 기록 (Journals)
| Method | Endpoint | Description | Response Data Example |
| :--- | :--- | :--- | :--- |
| POST | `/api/journals` | 일기 작성 (AI 분석 시작) | `10` (생성된 journal_id) |
| GET | `/api/journals` | 내 일기 목록 조회 | `[{"id": 1, "content": "내용", "analysisStatus": "COMPLETED", "createdAt": "..."}]` |
| GET | `/api/journals/{id}`| 일기 상세 조회 | `{"id": 1, "content": "전체내용", "analysisStatus": "COMPLETED", "emotion": {"joyScore": 0.8, "summary": "..."}}` |
| POST | `/api/journals/{id}/analyze`| 일기 분석 수동 재요청 | `null` |

## 5. 맞춤형 추천 (Recommendations)
| Method | Endpoint | Description | Response Data Example |
| :--- | :--- | :--- | :--- |
| GET | `/api/recommendations/journal/{journalId}` | 특정 일기의 추천 목록 조회 | `[{"id": 1, "category": "MUSIC", "contentText": "설명", "externalLink": "spotify:...", "fallbackUrl": "https...", "isClicked": false}]` |
| GET | `/api/recommendations` | 내 모든 추천 목록 조회 | `[{"id": 1, "category": "MUSIC", "contentText": "설명", "externalLink": "spotify:...", "fallbackUrl": "https...", "isClicked": false}]` |
| PATCH | `/api/recommendations/{id}/click` | 추천 클릭 상태 업데이트 | `null` |

## 6. 할 일 관리 (Todos)
| Method | Endpoint | Description | Response Data Example |
| :--- | :--- | :--- | :--- |
| POST | `/api/todos` | 할 일 생성 | `5` (생성된 todo_id) |
| GET | `/api/todos` | 내 할 일 목록 조회 | `[{"id": 1, "taskName": "명상", "isCompleted": false, "dueDate": "..."}]` |
| GET | `/api/todos/stats` | 할 일 달성률 통계 조회 | `{"totalCount": 10, "completedCount": 8, "completionRate": 0.8000}` |
| PUT | `/api/todos/{id}` | 할 일 정보 수정 | `null` |
| PATCH | `/api/todos/{id}/complete` | 할 일 완료 처리 | `null` |
| DELETE | `/api/todos/{id}` | 할 일 삭제 | `null` |

## 7. 상점 및 아이템 (Store & Items)
| Method | Endpoint | Description | Response Data Example |
| :--- | :--- | :--- | :--- |
| GET | `/api/items/active-persona` | 활성화된 페르소나 스타일 조회 | `{"personaStyle": "FRIENDLY_BOT"}` |