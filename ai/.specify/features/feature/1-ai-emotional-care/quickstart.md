# 빠른 시작 가이드 (Quickstart)

## 1. 개발 환경 설정
- Python 3.9+ 설치
- 필수 패키지 설치: `pip install qwen-sdk openai-whisper librosa`
- 백엔드 API 연동을 위한 환경 변수(`DATABASE_URL`, `LLM_API_KEY`) 설정

## 2. 감정 분석 실행 방법
1. `Journals` 테이블에 샘플 데이터(텍스트/음성 경로)를 입력합니다.
2. 분석 엔진을 실행합니다: `python src/analyzer.py --journal_id [ID]`
3. `Emotions` 및 `Recommendations` 테이블에 생성된 결과를 확인합니다.

## 3. 테스트 실행
- 단위 테스트 실행: `pytest tests/unit`
- 통합 테스트 실행: `pytest tests/integration`
