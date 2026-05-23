# Changelog

## [2026-05-20]
### Added / Changed
- `frontend/lib/screens/analysis_result_screen.dart` 파일 화면 구성 수정
  - 감정 분석 결과에서 '스트레스' 점수 표시 제거 (기쁨, 슬픔만 표시)
- `frontend/lib/screens/setup_screen.dart` 파일 설정 항목 추가
  - AI 일기 분석 및 맞춤 추천 서비스 동의 여부를 선택할 수 있는 체크박스 UI 추가

## [2026-05-15]
### Added / Changed
- `frontend/lib/screens/analysis_result_screen.dart` 파일 화면 구성 수정
  - 감정 분석 점수 표시를 '기쁨', '슬픔', '스트레스'로 변경
  - Spotify 추천 카드를 자동 재생 상태를 나타내는 UI로 변경
  - Netflix, 배달 앱 추천 카드를 앱으로 바로 이동 및 검색할 수 있는 버튼 형태의 UI로 변경

## [2026-05-13]
### Added / Changed
- `frontend/lib/screens/setup_screen.dart` 파일에 프로필 설정 항목들을 확장 및 추가
  - 프로필 이미지 선택기 추가 (현재 UI만 구현)
  - 닉네임, 생년월일 항목 유지
  - 평균 기상 시간 선택 기능 추가 (TimePicker 적용)
  - 일기 작성 시간 선택 기능 추가 (TimePicker 적용)
  - 일기 작성 용도 선택 항목 추가 (택 1: 기록용, 계획용, 멘탈관리용, 갓생용, 기타)
  - 조언 말투 설정 추가 (택 1: 직설적, 친근한, 공감적, 기타)
  - 좋아하는 음악 장르 다중 선택 기능 추가 (`FilterChip` 및 모두 선택/해제 기능 적용)
