# Render Deployment Guide for Leafy Backend 🌿

이 문서는 Render에 Leafy 백엔드 서버를 배포하기 위한 설정 및 환경 변수 가이드를 제공합니다.

## 1. 배포 설정 (Render Dashboard)

- **Service Type**: Web Service
- **Runtime**: Docker
- **Region**: 가까운 리전 (예: Singapore 또는 Oregon)
- **Branch**: `main` (또는 배포하고자 하는 브랜치)
- **Dockerfile Path**: `backend/Dockerfile`
- **Context Path**: `backend` (Render에서 `backend` 폴더를 루트로 인식하도록 설정해야 합니다. 만약 프로젝트 전체를 올린다면 루트에서 `backend/Dockerfile`을 참조하도록 설정하세요.)

## 2. 필수 환경 변수 (Environment Variables)

Render의 **Environment** 탭에서 아래 변수들을 추가하세요.

| 변수명 | 설명 | 예시 |
| :--- | :--- | :--- |
| `SPRING_PROFILES_ACTIVE` | 활성 프로파일 (운영 환경이므로 `prod`) | `prod` |
| `PROD_DB_URL` | PostgreSQL 연결 URL (JDBC 형식) | `jdbc:postgresql://<host>:<port>/<db>` |
| `PROD_DB_USERNAME` | 데이터베이스 사용자명 | `leafy_user` |
| `PROD_DB_PASSWORD` | 데이터베이스 비밀번호 | `your_password` |
| `JWT_SECRET` | JWT 서명용 비밀키 (최소 32자 이상 권장) | `your_long_and_secure_jwt_secret_key` |
| `ENCRYPTION_KEY` | 일기 본문 암호화용 AES 키 (16, 24, 32자) | `your-32-character-aes-key-here` |
| `PROD_AI_SERVER_URL` | 배포된 AI (FastAPI) 서버 URL | `https://leafy-ai.onrender.com` |
| `PROD_APP_BASE_URL` | 현재 백엔드 서버의 공개 URL | `https://leafy-backend.onrender.com` |
| `APP_OAUTH2_REDIRECT_URI` | 소셜 로그인 성공 후 리다이렉트될 프론트엔드 주소 | `https://leafy-web.onrender.com/login-success` |
| `GOOGLE_CLIENT_ID` | 구글 OAuth2 클라이언트 ID | `...apps.googleusercontent.com` |
| `GOOGLE_CLIENT_SECRET` | 구글 OAuth2 클라이언트 보안 비밀번호 | `...` |
| `NAVER_CLIENT_ID` | 네이버 OAuth2 클라이언트 ID | `...` |
| `NAVER_CLIENT_SECRET` | 네이버 OAuth2 클라이언트 보안 비밀번호 | `...` |
| `KAKAO_CLIENT_ID` | 카카오 OAuth2 클라이언트 ID | `...` |
| `KAKAO_CLIENT_SECRET` | 카카오 OAuth2 클라이언트 보안 비밀번호 | `...` |

## 3. Persistent Storage (선택 사항)

사용자가 업로드한 이미지와 음성 파일을 유지하려면 Render의 **Disk** 기능을 사용하는 것이 좋습니다.

- **Mount Path**: `/data/uploads`
- **Name**: `leafy-uploads`
- **Size**: 1GB (무료 티어 이상 필요)

**환경 변수 추가**:
- `PROD_STORAGE_PATH`: `/data/uploads/`

> **참고**: Disk를 사용하지 않으면 서버 재배포 시 업로드된 파일이 모두 삭제됩니다 (Demo 용도라면 무방합니다).

## 4. Health Check 설정

Render의 **Advanced** 설정에서 Health Check를 활성화할 수 있습니다.

- **Health Check Path**: `/health`

## 5. 포트 설정

백엔드는 `PORT` 환경 변수를 자동으로 인식하도록 설정되어 있습니다. Render가 동적으로 할당하는 포트로 서비스가 실행됩니다.
