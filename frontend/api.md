# RESTful API Specifications

이 문서는 프로젝트의 백엔드 API 명세서입니다.

## 1. 인증 (Authentication)
* [cite_start]**이메일 회원가입**: `POST /api/auth/signup` [cite: 3]
* [cite_start]**일반 로그인**: `POST /api/auth/login` [cite: 3]
* [cite_start]**소셜 로그인 성공**: `GET /api/auth/social/success` [cite: 3]

## 2. 일기 (Journal)
* [cite_start]**일기 작성**: `POST /api/journals` [cite: 4]
* [cite_start]**일기 목록 조회**: `GET /api/journals` [cite: 4]
* [cite_start]**일기 상세 조회**: `GET /api/journals/{journal_id}` [cite: 4]

## 3. 사용자 설정 (User Settings)
* [cite_start]**설정 조회**: `GET /api/users/settings` [cite: 4]
* [cite_start]**설정 수정**: `PATCH /api/users/settings` [cite: 4]

## 4. 추천 및 할 일 (Recommendation & Todo)
* [cite_start]**맞춤 추천 조회**: `GET /api/recommendations` [cite: 4]
* [cite_start]**할 일 목록 조회**: `GET /api/todos` [cite: 4]