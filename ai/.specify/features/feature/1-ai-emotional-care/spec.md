# 기능 명세: 능동형 AI 감정 케어 에이전트 (AI 분석 서버)

## 1. 개요
본 기능은 사용자의 일기 내용 및 서비스 활동 데이터를 분석하여 감정 지표를 도출하고, 맞춤형 케어 콘텐츠(음악 플레이리스트, 영화 등)와 성취도 피드백을 제공하는 AI 분석 서버를 구축하는 것입니다. 이 서버는 Spring Boot 백엔드와 REST API를 통해 통신하며, Flutter 앱 사용자의 정서적 안정을 지원합니다.

## Clarifications
### Session 2026-05-21
- Q: 데이터 식별 및 이력 관리 → A: 실시간으로 짧은 메모를 수시로 기록하고, 하루 끝에 통합 분석
- Q: 보안 및 개인정보 보호 → A: 백엔드 담당 영역으로 구현하며, 제공된 DB 스키마(Journals.content 암호화 등)를 준수함
- Q: 감정 수치 산출 기준 및 매핑 → A: 기쁨, 슬픔, 스트레스를 각각 독립적으로 분석하여 0.0000 ~ 1.0000 범위의 개별 점수 산출
- Q: 개인화 조언 말투 (Advice Tone) 연동 → A: 사용자가 설정한 advice_tone을 모든 응답에 엄격히 적용
- Q: 외부 서비스 딥링크/URL 생성 규칙 → A: AI는 키워드(제목, 가수명)만 반환하고, 실제 URL 생성은 백엔드 검색 API에 위임
- Q: 분석 실패 또는 데이터 부족 시의 동작 (Edge Case) → A: 기본값 기반의 범용 격려/공감 메시지와 추천 항목 출력
### Session 2026-05-24 (Update)
- Q: 응답 포맷 변경 → A: 모든 AI 응답은 JSON 형식을 사용하며, LLM의 JSON Mode를 활성화하여 응답한다. (OpenAI GPT-4o 활용)
- Q: 통합 JSON 응답 규격 → A: JSON의 Key는 DB 테이블의 컬럼명과 정확히 일치시킨다. (예: `joy_score`, `sadness_score`, `stress_level`, `content_text`, `feedback_message`, `external_link` 등)
- Q: 감정 수치 범위 확정 → A: 0.0000 ~ 1.0000 범위를 사용하며, CPU 환경을 고려하여 FP32 정밀도로 처리한다.
- Q: 신규 기능 추가 → A: 사용자의 Todo 달성률에 따른 '성취도 피드백' 기능을 추가한다.
### Session 2026-05-26 (Arch Update)
- **아키텍처 변경**: Flutter -> Spring Boot -> Python AI Server 구조로 변경됨.
- **STT/TTS 제거**: 음성 처리(STT/TTS)는 AI 서버의 범위에서 제외됨.
- **음악 추천 방식 변경**: 기존 `가수*#*곡명` 방식에서 `Spotify 플레이리스트 ID` 반환 방식으로 변경됨.
- Q: AI 서버 API 보안 및 인증 방식 → A: 인증 없음 (내부망/VPN 환경 전제)
- Q: Spotify 플레이리스트 ID 선정 방식 → A: 고정된 플레이리스트 ID Pool에서 무작위/조건부 선택
- Q: 플레이리스트 ID Pool 저장/관리 방식 → A: 코드 내 하드코딩된 상수(Constant) 또는 JSON 파일
- Q: 감정 상태별 플레이리스트 ID Pool 크기 → A: 감정 상태별 3~5개의 ID를 가진 소규모 Pool (MVP 적합)
- Q: API 응답 지연 시간(Latency) 목표 → A: 5.0초 이내 (LLM 분석 포함)
- Q: LLM 분석 실패 시 폴백(Fall-back) 전략 → A: 범용적인 격려 메시지와 기본 추천 리스트 제공
- Q: OpenAI API 호출 실패 시 재시도 전략 → A: 지수적 백오프(Exponential Backoff)를 포함한 자동 재시도 로직 적용
- Q: AI 서버 로깅(Logging) 전략 → A: JSON 기반 표준 로그 출력 (Timestamp, ID, Latency 포함)
- Q: FOOD 카테고리 추천 시 external_link 규격 → A: 미정 (현재 구상 중이므로 `null` 반환)
- Q: 시스템 간 요청 추적(Tracing) 방식 → A: 모든 로그 및 응답 헤더에 고유 요청 ID(Correlation ID) 포함
- Q: AI 서버 헬스체크(Health Check) 엔드포인트 필요 여부 → A: 불필요 (백엔드에서 직접 API 호출 성공 여부로 판단)
- Q: AI 서버 부하 조절 및 Rate Limiting 전략 → A: 분당 120회 제한 (120 RPM)
- Q: MOVIE 카테고리 콘텐츠 ID 생성 방식 → A: OpenAI GPT-4o가 실시간으로 유명한 영화의 ID를 직접 생성하여 반환
- Q: API ENUM 값 정의 (`persona_style`, `recent_emotion`) → A: `persona_style`: [BASIC, FRIENDLY, STRICT], `recent_emotion`: [JOY, SADNESS, STRESS, NEUTRAL]
- Q: 에러 발생 시 공통 JSON 응답 규격 → A: `{"status": "ERROR", "message": "에러 내용", "data": null}` (백엔드 공통 포맷 준수)
- Q: `voice_url` 필드 처리 방식 → A: 미정 (향후 확정 전까지 스키마 정의만 유지하고 로직상 무시)
- Q: MOVIE 카테고리 `content_text` 형식 → A: `[플랫폼] 영화: [제목]` 형식으로 고정
- Q: Rate Limiting 적용 범위 → A: 서버 인스턴스별 개별 적용 (In-memory 방식)

## 2. 사용자 시나리오 (API 기반)
1. **일기 분석**: 사용자가 Flutter 앱에서 일기를 작성하면, Spring Boot 백엔드가 AI 서버에 분석 요청을 보냅니다.
2. **감정 도출**: AI 서버는 텍스트를 분석하여 기쁨, 슬픔, 스트레스 수치와 요약문을 생성합니다.
3. **콘텐츠 추천**: 분석된 감정에 어울리는 음악 플레이리스트 ID와 영화 정보를 선정합니다.
4. **성취도 피드백**: 사용자의 Todo 달성 현황을 전달받아 현재 감정 상태에 맞는 격려 메시지를 생성합니다.
5. **결과 반환**: 모든 결과는 JSON 형태로 백엔드에 반환되어 사용자 앱에 표시됩니다.

## 3. 기능 요구사항
- [x] **종합 감정 분석**: 입력된 텍스트에서 기쁨, 슬픔, 스트레스 지수(0.0~1.0)를 도출해야 한다.
- [x] **플레이리스트 추천**: 감정 상태별로 정의된 고정 플레이리스트 ID Pool에서 적절한 ID를 선택하여 반환해야 한다.
- [x] **영화 콘텐츠 추천**: OpenAI GPT-4o의 실시간 생성을 통해 감정 맥락에 어울리는 유명 영화의 콘텐츠 ID를 직접 반환해야 하며, `content_text`는 `[플랫폼] 영화: [제목]` 형식을 준수해야 한다.
- [x] **Todo 피드백 생성**: 사용자의 현재 감정 상태(Recent Emotion)를 최우선으로 고려하고, Todo 달성률을 결합하여 개인화된 격려 메시지를 생성해야 한다.
- [x] **REST API 제공**: Spring Boot와 통신하기 위한 API 엔드포인트를 구현해야 한다.
- [x] **데이터 모델링 연동**: 산출된 JSON 결과를 실제 DB 모델 규격에 맞춰 반환해야 한다.

## 4. API 명세 (AI 서버)

### 4.1 일기 분석 (Journal Analysis)
- **Endpoint**: `POST /analyze-journal`
- **Request Body**:
  ```json
  {
    "journal_id": 10,
    "content": "오늘 프로젝트가 잘 마무리되어서 너무 기쁘다! 하지만 조금 피곤하네.",
    "voice_url": "https://storage.com/voice/sample.mp3",
    "persona_style": "FRIENDLY"
  }
  ```
- **Response Body**:
  ```json
  {
    "journal_id": 1,
    "joy_score": 0.8500,
    "sadness_score": 0.0500,
    "stress_level": 0.2000,
    "emotion_summary": "오늘 정말 활기찬 하루를 보내셨네요! 긍정적인 에너지가 넘쳐납니다.",
    "recommendations": [
      {
        "category": "MUSIC",
        "content_text": "오늘의 텐션 업! 신나는 팝 플레이리스트",
        "external_link": "37i9dQZF1DXcBWIGoYBM3M"
      },
      {
        "category": "MOVIE",
        "content_text": "넷플릭스 영화: 어바웃 타임",
        "external_link": "70273658"
      }
    ]
  }
  ```

### 4.2 Todo 성취도 피드백 (Todo Feedback)
- **Endpoint**: `POST /todo-feedback`
- **Request Body**:
  ```json
  {
    "total_count": 5,
    "completed_count": 1,
    "completion_rate": 0.2000,
    "persona_style": "FRIENDLY",
    "recent_emotion": "SADNESS"
  }
  ```
- **Response Body**:
  ```json
  {
    "feedback_message": "오늘은 마음이 많이 울적해서 아무것도 하기 힘든 날이었을 거예요. 그래도 하나라도 해내신 당신이 정말 대견해요. 오늘은 이만 쉬어도 괜찮아요. 토닥토닥. 🌿"
  }
  ```

## 5. 성공 기준 (Success Criteria)
- [x] **API 응답성**: 모든 분석 요청에 대해 5초 이내에 JSON 응답을 완료해야 한다.
- [x] **안정성 확보**: OpenAI API 호출 실패 시 지수적 백오프 기반의 자동 재시도를 수행하여 일시적인 네트워크 오류에 대응해야 한다.
- [x] **관측성 강화**: 모든 API 요청 및 OpenAI 호출에 대해 JSON 형식의 표준 로그를 출력하고, 응답 헤더와 로그에 Correlation ID를 포함하여 모니터링 가능해야 한다.
- [x] **부하 조절**: 분당 120회 요청 제한(120 RPM)을 인메모리(In-memory) 방식으로 구현하여 서버 자원 및 OpenAI API 쿼터를 보호해야 한다.
- [x] **ID 정합성**: 추천된 Spotify ID(22자 Base62 형식) 및 영화 ID(숫자형 문자열)가 유효한 형식이어야 한다.
- [x] **스키마 정합성**: 모든 AI 생성 데이터가 백엔드 DB 스키마의 제약 조건(소수점 자리수 등)을 100% 준수해야 한다.

## 6. 데이터 엔티티
(기존 엔티티 구조 유지하되, 통신 규격에 집중)

## 7. 구현 환경 및 설정
- **언어:** Python 3.12.3
- **프레임워크:** FastAPI (권장)
- **설정 관리:** `src/config/ai_config.py`

## 8. 가정 및 제약 사항
- AI 서버는 외부 인터넷(OpenAI API)에 접근 가능해야 한다.
- 모든 요청 데이터는 백엔드에서 전처리가 완료된 상태로 전달됨을 가정한다.
- 음악 플레이리스트 ID는 Spotify에서 직접 가져온 ID를 사용한다.
- AI 서버와 Spring Boot 백엔드는 동일한 내부망 또는 VPN 내에 위치하여 별도의 외부 인증이 필요 없다고 가정한다.
- 분석 요청 본문(Content)은 최대 5,000자, 음성 URL 등 경로 정보는 최대 2,048자로 제한한다. (LLM 토큰 효율 및 안정성 고려)
- `persona_style`은 [BASIC, FRIENDLY, STRICT], `recent_emotion`은 [JOY, SADNESS, STRESS, NEUTRAL] 범위 내의 값만 허용한다.
- `voice_url` 필드는 향후 확정 시까지 플레이스홀더로 유지하며, 현재 로직에서는 데이터를 파싱만 하고 처리 로직에서는 제외한다.
- FOOD 카테고리 추천의 `external_link`는 현재 미정이므로 응답 시 `null`을 반환한다.
의 외부 인증이 필요 없다고 가정한다.
