# Data Model: Leafy

## Users
- `id` (Long, PK, Auto-increment)
- `email` (String, Unique)
- `password_hash` (String, Nullable for OAuth)
- `provider` (Enum: GOOGLE, NAVER, KAKAO)
- `provider_id` (String)
- `nickname` (String)
- `profile_img` (String)
- `role` (Enum: USER, ADMIN)
- `created_at` (LocalDateTime)

## UserSettings
- `id` (Long, PK)
- `user_id` (FK -> Users.id)
- `reminder_time` (LocalTime)
- `usage_purpose` (Enum: MENTAL_CARE, SIMPLE_DIARY)
- `persona_style` (Enum: BASIC, FRIENDLY)
- `birth_date` (LocalDate)

## Journals
- `id` (Long, PK)
- `user_id` (FK -> Users.id)
- `content` (Text, Encrypted)
- `voice_url` (String, Nullable)
- `img_url` (String, Nullable)
- `analysis_status` (Enum: PENDING, PROCESSING, COMPLETED, FAILED)
- `created_at` (LocalDateTime)

## Emotions
- `id` (Long, PK)
- `journal_id` (FK -> Journals.id)
- `joy_score` (BigDecimal)
- `sadness_score` (BigDecimal)
- `stress_level` (BigDecimal)
- `emotion_summary` (String)
- `analyzed_at` (LocalDateTime)

## Recommendations
- `id` (Long, PK)
- `journal_id` (FK -> Journals.id)
- `category` (Enum: MUSIC, FOOD, MOVIE, EXERCISE, BOOK)
- `content_text` (String)
- `external_link` (String) - Deep Link
- `fallback_url` (String) - Web URL
- `is_clicked` (Boolean)

## Todos
- `id` (Long, PK)
- `user_id` (FK -> Users.id)
- `task_name` (String)
- `is_completed` (Boolean)
- `due_date` (LocalDateTime)
- `completed_at` (LocalDateTime)

## Items
- `id` (Long, PK)
- `item_type` (Enum)
- `item_name` (String)
- `price` (Integer)
- `resource_url` (String)

## UserItems
- `id` (Long, PK)
- `user_id` (FK -> Users.id)
- `item_id` (FK -> Items.id)
- `is_equipped` (Boolean)
- `purchased_at` (LocalDateTime)
