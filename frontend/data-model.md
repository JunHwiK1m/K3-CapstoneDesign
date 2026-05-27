# Database Data Model

이 문서는 프로젝트의 백엔드 데이터베이스 구조를 정의합니다.

## 1. Users (사용자)
| Column | Type | Description |
| :--- | :--- | :--- |
| `user_id` | PK | [cite_start]시스템 내부 관리용 고유 번호 [cite: 1] |
| `email` | String | [cite_start]사용자 이메일 [cite: 1] |
| `password_hash` | String | [cite_start]일반 가입자 비밀번호 [cite: 1] |
| `provider` | String | [cite_start]가입 경로 (KAKAO, GOOGLE 등) [cite: 1] |
| `provider_id` | String | [cite_start]소셜 서비스에서 제공하는 고유 식별 번호 [cite: 1] |
| `name` | String | [cite_start]이름 [cite: 1] |
| `role` | String | [cite_start]권한 (ADMIN, GENERAL) [cite: 1] |

## 2. Journals (일기)
| Column | Type | Description |
| :--- | :--- | :--- |
| `journal_id` | PK | [cite_start]일기 고유 번호 [cite: 1] |
| `user_id` | FK | [cite_start]작성자(Users) 고유 번호 [cite: 1] |
| `content` | Text | [cite_start]암호화된 일기 본문 [cite: 1] |
| `voice_url` | String | [cite_start]음성 파일 경로 [cite: 1] |
| `img_url` | String | [cite_start]사용자가 업로드한 사진 경로 [cite: 1] |
| `analysis_status` | String | [cite_start]PENDING, PROCESSING, COMPLETED, FAILED 등 [cite: 1] |
| `created_at` | Timestamp | [cite_start]작성 일시 [cite: 1] |

## 3. Todos (할 일)
| Column | Type | Description |
| :--- | :--- | :--- |
| `todo_id` | PK | [cite_start]할 일 고유 번호 [cite: 1] |
| `user_id` | FK | [cite_start]대상자(Users) 고유 번호 [cite: 1] |
| `task_name` | String | [cite_start]할 일 내용 [cite: 1] |
| `is_completed` | Boolean | [cite_start]완료 여부 [cite: 1] |
| `due_date` | Date | [cite_start]목표 날짜 [cite: 1] |
| `completed_at` | Timestamp | [cite_start]실제 완료 시각 [cite: 1, 2] |
| `created_at` | Timestamp | [cite_start]작성 일시 [cite: 2] |

## 4. Emotions (감정 데이터)
| Column | Type | Description |
| :--- | :--- | :--- |
| `emotion_id` | PK | [cite_start]감정 데이터 고유 번호 [cite: 2] |
| `journal_id` | FK | [cite_start]연결된 일기(Journals) 고유 번호 [cite: 2] |
| `joy_score` | Float | [cite_start]긍정 수치 (-9.9999 ~ 9.9999) [cite: 2] |
| `sadness_score` | Float | [cite_start]부정 수치 (-9.9999 ~ 9.9999) [cite: 2] |
| `stress_level` | Float | [cite_start]스트레스 지수 (-9.9999 ~ 9.9999) [cite: 2] |
| `emotion_summary` | String | [cite_start]AI가 요약한 감정 맥락 [cite: 2] |
| `analyzed_at` | Timestamp | [cite_start]분석 완료 시각 [cite: 2] |

## 5. Recommendations (추천 데이터)
| Column | Type | Description |
| :--- | :--- | :--- |
| `rec_id` | PK | [cite_start]추천 데이터 고유 번호 [cite: 2] |
| `journal_id` | FK | [cite_start]연결된 일기(Journals) 고유 번호 [cite: 2] |
| `category` | String | [cite_start]MUSIC, FOOD, LIFESTYLE 등 [cite: 2] |
| `content_text` | String | [cite_start]AI의 제안 문구 [cite: 2] |
| `external_link` | String | [cite_start]스포티파이 url 또는 배달, 넷플릭스 앱 딥링크 [cite: 2] |
| `fallback_url` | String | [cite_start]웹 페이지 url (앱 미설치 사용자) [cite: 2] |
| `is_clicked` | Boolean | [cite_start]사용자가 실제로 해당 제안을 클릭했는지 여부 [cite: 2] |

## 6. UserSettings (사용자 설정)
| Column | Type | Description |
| :--- | :--- | :--- |
| `setting_id` | PK | [cite_start]설정 고유 번호 [cite: 2] |
| `user_id` | FK | [cite_start]대상 사용자(Users) 고유 번호 [cite: 2] |
| `usage_purpose` | String | [cite_start]사용 용도 [cite: 2, 3] |
| `diary_time` | Time | [cite_start]일기 작성 알림 시간 [cite: 2, 3] |
| `wake_up_time` | Time | [cite_start]기상 시간 [cite: 3] |
| `nickname` | String | [cite_start]사용자 닉네임 [cite: 3] |
| `profile_image` | String | [cite_start]프로필 이미지 경로 [cite: 2] |
| `persona_style` | String | [cite_start]조언 말투 설정 [cite: 2, 3] |
| `advice_tone` | String | [cite_start]조언 톤 [cite: 2] |
| `music_style` | String | [cite_start]선호 음악 스타일 [cite: 2] |
| `birth_date` | Date | [cite_start]사용자 생년월일 [cite: 2, 3] |
| `updated_at` | Timestamp | [cite_start]설정 최종 수정 일시 [cite: 2, 3] |

## 7. Items (아이템)
| Column | Type | Description |
| :--- | :--- | :--- |
| `item_id` | PK | [cite_start]아이템 고유 번호 [cite: 3] |
| `item_type` | String | [cite_start]아이템 종류 [cite: 3] |
| `item_name` | String | [cite_start]아이템 이름 [cite: 3] |
| `price` | Integer | [cite_start]판매 가격 [cite: 3] |
| `resource_url` | String | [cite_start]이미지나 테마 파일이 저장된 경로 [cite: 3] |
| `created_at` | Timestamp | [cite_start]등록 일시 [cite: 3] |

## 8. UserItems (사용자 소유 아이템)
| Column | Type | Description |
| :--- | :--- | :--- |
| `user_item_id` | PK | [cite_start]소유 정보 고유 번호 [cite: 3] |
| `user_id` | FK | [cite_start]구매한 사용자(Users) ID [cite: 3] |
| `item_id` | FK | [cite_start]구매한 아이템(Items) ID [cite: 3] |
| `is_equipped` | Boolean | [cite_start]현재 사용 중 인지 여부 [cite: 3] |
| `purchased_at` | Timestamp | [cite_start]구매 일시 [cite: 3] |