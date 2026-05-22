# Data Model: Leafy AI Mental Care Agent

이 문서는 Leafy 프로젝트의 데이터베이스 스키마와 엔티티 설계를 정의합니다.

## 1. ERD 개요
Leafy의 데이터 모델은 사용자(User)를 중심으로 일기(Journal), 분석 결과(Emotion), 추천 활동(Recommendation), 그리고 서비스 설정(UserSettings)이 유기적으로 연결된 구조입니다.

---

## 2. 테이블 상세 설계

### 2.1 Users (사용자 정보)
사용자의 기본 계정 정보와 로그인 제공자 정보를 관리합니다.

| Column | Type | Nullable | Comment |
| :--- | :--- | :--- | :--- |
| user_id | BIGINT (PK) | No | 사용자 고유 식별자 |
| email | VARCHAR(255) | No | 사용자 이메일 (Unique) |
| password_hash | VARCHAR(255) | Yes | 비밀번호 해시 (Local 로그인용) |
| provider | VARCHAR(20) | No | 로그인 제공자 (LOCAL, GOOGLE, NAVER, KAKAO) |
| provider_id | VARCHAR(255) | Yes | 소셜 로그인 제공자 고유 ID |
| name | VARCHAR(100) | No | 사용자 이름 |

---

### 2.2 User Settings (사용자 설정)
사용자의 개인화된 서비스 설정과 프로필 정보를 관리합니다.

| Column | Type | Nullable | Comment |
| :--- | :--- | :--- | :--- |
| setting_id | BIGINT (PK) | No | 설정 고유 식별자 |
| user_id | BIGINT (FK) | No | Users 테이블 참조 |
| diary_time | TIME | Yes | 일기 작성 권장 시간 |
| wake_up_time | TIME | Yes | 기상 시간 |
| usage_purpose | VARCHAR(50) | Yes | 서비스 사용 용도 (RECORDING, PLANNING, MENTAL_CARE, GOD_SAENG) |
| nickname | VARCHAR(100) | Yes | 사용자 닉네임 (서비스 내 표시용) |
| profile_image | VARCHAR(512) | Yes | 프로필 사진 URL |
| birth_date | DATE | Yes | 사용자의 생년월일 |
| advice_tone | VARCHAR(50) | Yes | AI 조언 말투 (DIRECT, FRIENDLY, EMPATHETIC) |
| music_style | VARCHAR(100) | Yes | 선호하는 음악 장르 |
| persona_style | VARCHAR(50) | Yes | 에이전트 페르소나 스타일 (BASIC, FRIENDLY) |
| is_ai_analysis_enabled | BOOLEAN | No | AI 분석 활성화 여부 (Default: True) |

---

### 2.3 Journals (일기 기록)
사용자가 작성한 일기 본문과 멀티모달 데이터 주소를 관리합니다.

| Column | Type | Nullable | Comment |
| :--- | :--- | :--- | :--- |
| journal_id | BIGINT (PK) | No | 일기 고유 식별자 |
| user_id | BIGINT (FK) | No | Users 테이블 참조 |
| content | TEXT | No | 일기 텍스트 본문 (AES-256 암호화 저장) |
| voice_url | VARCHAR(512) | Yes | 녹음된 음성 파일 URL |
| img_url | VARCHAR(512) | Yes | 첨부 이미지 URL (기록용) |
| analysis_status | VARCHAR(20) | No | 분석 상태 (PENDING, PROCESSING, COMPLETED, FAILED) |
| created_at | DATETIME | No | 일기 작성 일시 |

---

### 2.4 Emotions (감정 분석 결과)
일기 텍스트/음성을 분석하여 도출된 정량적 수치와 요약 정보를 저장합니다.

| Column | Type | Nullable | Comment |
| :--- | :--- | :--- | :--- |
| emotion_id | BIGINT (PK) | No | 분석 결과 고유 식별자 |
| journal_id | BIGINT (FK) | No | Journals 테이블 참조 |
| joy_score | DECIMAL(5,4) | Yes | 기쁨 점수 (0.0000 ~ 1.0000) |
| sadness_score | DECIMAL(5,4) | Yes | 슬픔 점수 (0.0000 ~ 1.0000) |
| stress_level | DECIMAL(5,4) | Yes | 스트레스 지수 (0.0000 ~ 1.0000) |
| emotion_summary | TEXT | Yes | AI가 요약한 감정 분석 내용 |
| analyzed_at | DATETIME | No | 분석 완료 일시 |

---

### 2.5 Recommendations (맞춤형 추천)
분석된 감정에 따라 제공된 에이전틱 액션 정보를 관리합니다.

| Column | Type | Nullable | Comment |
| :--- | :--- | :--- | :--- |
| rec_id | BIGINT (PK) | No | 추천 항목 고유 식별자 |
| journal_id | BIGINT (FK) | No | Journals 테이블 참조 |
| category | VARCHAR(20) | No | 추천 카테고리 (MUSIC, FOOD, MOVIE 등) |
| content_text | TEXT | No | 추천 내용 설명 |
| external_link | VARCHAR(512) | No | 앱 딥링크 URL |
| fallback_url | VARCHAR(512) | No | 웹 페이지 URL (앱 미설치 대비) |
| is_clicked | BOOLEAN | No | 사용자의 실행 여부 확인용 |

---

### 2.6 Todos (할 일 목록)
사용자가 직접 등록하거나 AI가 추천한 활동 중 할 일로 등록된 항목을 관리합니다.

| Column | Type | Nullable | Comment |
| :--- | :--- | :--- | :--- |
| todo_id | BIGINT (PK) | No | 할 일 고유 식별자 |
| user_id | BIGINT (FK) | No | Users 테이블 참조 |
| task_name | VARCHAR(255) | No | 할 일 내용 |
| is_completed | BOOLEAN | No | 완료 여부 |
| due_date | DATETIME | Yes | 완료 예정 기한 |
| completed_at | DATETIME | Yes | 실제 완료 일시 |
| created_at | DATETIME | No | 생성 일시 |

---

### 2.7 Items (아이템 정보)
상점에서 판매하거나 사용자가 장착할 수 있는 아이템 정보를 관리합니다.

| Column | Type | Nullable | Comment |
| :--- | :--- | :--- | :--- |
| item_id | BIGINT (PK) | No | 아이템 고유 식별자 |
| item_type | VARCHAR(20) | No | 아이템 타입 (AVATAR, BACKGROUND 등) |
| item_name | VARCHAR(100) | No | 아이템 이름 |
| price | INTEGER | No | 아이템 가격 |
| resource_url | VARCHAR(512) | Yes | 아이템 이미지/리소스 URL |
| created_at | DATETIME | No | 생성 일시 |

---

### 2.8 User Items (사용자 보유 아이템)
사용자가 구매하거나 보유한 아이템 목록과 장착 여부를 관리합니다.

| Column | Type | Nullable | Comment |
| :--- | :--- | :--- | :--- |
| user_item_id | BIGINT (PK) | No | 보유 정보 고유 식별자 |
| user_id | BIGINT (FK) | No | Users 테이블 참조 |
| item_id | BIGINT (FK) | No | Items 테이블 참조 |
| is_equipped | BOOLEAN | No | 장착 여부 |
| purchased_at | DATETIME | No | 구매 일시 |

---

## 3. 데이터 보안 정책
- **일기 본문(content)**: 개인정보 보호를 위해 DB 저장 시 AES-256 알고리즘으로 암호화하여 저장하며, 애플리케이션 계층에서 복호화하여 사용합니다.
- **인증(Auth)**: 패스워드는 BCrypt 해시 함수를 사용하여 암호화하며, 세션 관리는 JWT(JSON Web Token)를 사용합니다.
