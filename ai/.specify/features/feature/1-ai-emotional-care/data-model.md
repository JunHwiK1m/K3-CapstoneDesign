# 데이터 모델 정의서 (Data Model)

## 1. 주요 테이블 구조 (Schema)

### Users (사용자)
- `user_id`: 시스템 내부 관리용 고유 번호 (PK)
- `email`: 사용자 이메일
- `password_hash`: 비밀번호 해시 (일반 가입자)
- `provider`: 가입 경로 (KAKAO, GOOGLE 등)
- `provider_id`: 소셜 서비스 고유 식별 번호
- `name`: 이름
- `role`: 권한 (ADMIN, GENERAL)

### Journals (일기/메모)
- `journal_id`: 고유 번호 (PK)
- `user_id`: 작성자 ID (FK)
- `content`: 암호화된 본문
- `voice_url`: 음성 파일 경로
- `img_url`: 사용자가 업로드한 사진 경로
- `analysis_status`: 분석 상태 (PENDING, PROCESSING, COMPLETED, FAILED)
- `created_at`: 작성 일시

### Todos (할 일)
- `todo_id`: 할 일 고유 번호 (PK)
- `user_id`: 사용자 ID (FK)
- `task_name`: 할 일 내용
- `is_completed`: 완료 여부
- `due_date`: 목표 날짜
- `completed_at`: 실제 완료 시각
- `created_at`: 작성 일시

### Emotions (감정 분석 결과)
- `emotion_id`: 고유 번호 (PK)
- `journal_id`: 관련 일기 ID (FK)
- `joy_score`: 긍정 수치 (-9.9999 ~ 9.9999, AI 응답은 0.0 ~ 1.0)
- `sadness_score`: 부정 수치 (-9.9999 ~ 9.9999, AI 응답은 0.0 ~ 1.0)
- `stress_level`: 스트레스 지수 (-9.9999 ~ 9.9999, AI 응답은 0.0 ~ 1.0)
- `emtion_summary`: AI 요약 맥락
- `analyzed_at`: 분석 완료 시각

### Recommendations (추천 솔루션)
- `rec_id`: 고유 번호 (PK)
- `journal_id`: 관련 일기 ID (FK)
- `category`: 종류 (MUSIC, FOOD, LIFESTYLE 등)
- `content_text`: 제안 문구 ("가수*#*곡명" 포함)
- `external_link`: 외부 서비스 링크
- `fallback_url`: 대체 웹 페이지 URL
- `is_clicked`: 클릭 여부

### UserSettings (개인화 설정)
- `setting_id`: 설정 고유 번호 (PK)
- `user_id`: 대상 사용자
- `usage_purpose`: 사용 용도
- `diary_time`: 일기 작성 알림 시간
- `profile_image`: 프로필 이미지
- `persona_style`: 조언 말투 설정
- `birth_date`: 생년월일
- `advice_tone`: 조언 톤
- `music_style`: 음악 스타일
- `wake_up_time`: 기상 시간
- `nickname`: 사용자 닉네임
- `updated_at`: 설정 최종 수정 일시

### Items (아이템)
- `item_id`: 고유 번호 (PK)
- `item_type`: 아이템 종류
- `item_name`: 아이템 이름
- `price`: 판매 가격
- `resource_url`: 이미지나 테마 경로
- `created_at`: 등록 일시

### UserItems (사용자 보유 아이템)
- `user_item_id`: 고유 번호 (PK)
- `user_id`: 사용자 ID
- `item_id`: 아이템 ID
- `is_equipped`: 장착 여부
- `purchased_at`: 구매 일시

## 2. 상태 전이 (State Transitions)
- `PENDING` -> `PROCESSING`: AI 분석 시작 시
- `PROCESSING` -> `COMPLETED`: 분석 및 추천 데이터 생성 완료 시
- `PROCESSING` -> `FAILED`: 오류 발생 시 (기본 메시지 폴백 처리)
