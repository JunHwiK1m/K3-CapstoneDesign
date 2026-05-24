# 능동형 AI 감정 케어 에이전트 (Active AI Emotional Care Agent)

본 모듈은 사용자의 일기 및 실시간 음성 대화를 분석하여 정서적 상태를 파악하고, 개인화된 위로와 맞춤형 솔루션을 제공하는 AI 시스템입니다.

## 🚀 주요 기능
- **실시간 음성 대화 (통화 모드)**: 마이크를 통해 AI와 직접 대화하며, AI가 따뜻한 목소리(TTS)로 실시간 공감을 건넵니다. (2.5초 침묵 감지 적용)
- **정밀 감정 분석**: 대화 종료 후 전체 맥락을 분석하여 기쁨, 슬픔, 스트레스 지수(0.0~1.0) 및 종합 소견을 도출합니다.
- **플랫폼 딥링크 연동**: 추천된 음악은 **Spotify**, 영화는 **Netflix** 검색 결과로 바로 연결되는 링크를 제공합니다.
- **UI 최적화 피드백**: 공간 효율을 위해 AI의 핵심 위로 메시지를 2줄 이내로 간결하게 생성합니다.

## 🔑 API 설정
- 본 프로젝트는 **OpenAI GPT-4o** 엔진을 사용합니다.
- **API 키 확인**: 팀 내부 보안 정책에 따라 **구글 드라이브 공유 문서** 내의 API 키 명단을 참조해 주세요.
- 설정 방법: `src/config/ai_config.py` 파일의 `self.api_key`에 직접 입력하거나, 환경 변수 `OPENAI_API_KEY`를 설정합니다.
- **설치 직후** `self.api_key`**는 비어있습니다.**

## 🛠 설치 방법 (Environment Setup)

### 1. 필수 도구 (Common)
- **FFmpeg**: 음성 분석 및 변환을 위해 필수적입니다. [다운로드 페이지](https://ffmpeg.org/download.html)에서 설치 후 반드시 시스템 PATH에 등록해야 합니다.

### 2. Windows 환경
윈도우 터미널(PowerShell/cmd)에서 아래 명령어를 순서대로 입력하세요.
```powershell
# 1. 필수 라이브러리 설치
pip install openai openai-whisper SpeechRecognition PyAudio pydub simpleaudio

# 2. PyAudio 설치 실패 시 (대안)
pip install pipwin
pipwin install pyaudio
```

### 3. Linux 환경
Ubuntu/Debian 기반 환경에서의 설치 예시입니다.
```bash
# 1. 시스템 의존성 설치
sudo apt update
sudo apt install -y ffmpeg portaudio19-dev libasound2-dev

# 2. 파이썬 라이브러리 설치
pip install openai openai-whisper SpeechRecognition PyAudio pydub
```

## 🧪 테스트 및 실행

### 인터랙티브 데모 실행
사용자 입력 방식(텍스트/음성)을 선택하여 전체 워크플로우를 테스트할 수 있습니다.
```bash
python demo.py
```
- **2번(실시간 대화 모드)** 선택 시 마이크를 통해 실제 AI와 통화가 가능합니다.
- "그만", "종료", "고마워" 등의 단어를 말하면 통화가 끝나고 종합 리포트가 출력됩니다.

### 단위 및 통합 테스트
전체 로직의 무결성을 검증합니다.
```bash
pytest tests/unit tests/integration
```

## 📂 프로젝트 구조
```text
capStone/
├── .specify/             # 프로젝트 명세 및 기획 문서
├── src/                  # 메인 소스 코드
│   ├── ai/               # AI 연동 계층 (EmotionAnalyzer, STTService, PromptFactory)
│   ├── config/           # 환경 변수 및 모델 설정 (AIConfig)
│   ├── models/           # DB 엔티티 정의 (db_entities.py)
│   ├── repository/       # 데이터 영속성 계층 (DAO)
│   └── service/          # 비즈니스 로직 및 통합 (Orchestrator, RecommendationService 등)
├── tests/                # 테스트 코드
│   ├── integration/      # 워크플로우 통합 테스트
│   └── unit/             # 개별 모듈 단위 테스트
├── demo.py               # 인터랙티브 멀티모달 테스트 스크립트
├── GEMINI.md             # 프로젝트 지침 및 에이전트 가이드
├── README.md             # 프로젝트 소개 및 실행 가이드
└── requirements.txt      # 파이썬 의존성 패키지 목록
```

## ⚠️ 백엔드 연동 시 주의사항
1.  **JSON 스키마 준수**: AI 응답은 항상 `src/models/db_entities.py`와 1:1 매핑되는 JSON 구조를 반환합니다. 키값(`joy_score`, `emotion_summary` 등)의 오타에 주의하십시오.
2.  **응답 지연 처리**: 음성 분석(Whisper)과 LLM 추론은 모델 크기에 따라 수 초의 시간이 소요될 수 있습니다. API 호출 시 비동기(Async) 처리나 로딩 인디케이터 구현을 권장합니다.
3.  **오디오 장치 점유**: `demo.py`와 같이 하드웨어에 직접 접근하는 경우, 다른 프로그램이 마이크나 스피커를 독점하고 있으면 충돌이 발생할 수 있습니다. 서버 환경에서는 파일 스트림 방식으로 연동하십시오.
4.  **제거 용이성**: 딥링크(Spotify/Netflix) 생성 로직은 `src/ai/prompt_factory.py` 내에 모듈화되어 있습니다. 정책 변경 시 해당 블록만 수정하여 쉽게 기능을 끄거나 켤 수 있습니다.
