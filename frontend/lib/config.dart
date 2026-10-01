import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  // 배포된 스프링 부트 서버의 IP 주소로 변경하세요 (에뮬레이터 테스트용)
  // static const String baseUrl = 'http://10.0.2.2:8080';
  
  // AWS EC2에 배포된 백엔드의 퍼블릭 IP + nip.io를 이용한 HTTPS 연결 (안드로이드 실기기 및 에뮬레이터 겸용)
  static const String baseUrl = 'https://54.66.35.196.nip.io';
}

/// 스포티파이 SDK 환경 설정 클래스 (.env 연동)
class SpotifyConfig {
  // 스포티파이 개발자 대시보드에서 발급받은 클라이언트 ID
  static String get clientId => dotenv.env['SPOTIFY_CLIENT_ID'] ?? '';

  // 스포티파이 로그인 및 원격 제어 콜백 리다이렉트 URL
  static String get redirectUrl => dotenv.env['SPOTIFY_REDIRECT_URL'] ?? 'narae://spotify-callback';
}

