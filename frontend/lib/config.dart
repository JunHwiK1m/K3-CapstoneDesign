class ApiConfig {
  // 배포된 스프링 부트 서버의 IP 주소로 변경하세요 (에뮬레이터 테스트용)
  // static const String baseUrl = 'http://10.0.2.2:8080';
  
  // AWS EC2에 배포된 백엔드의 퍼블릭 IP + nip.io를 이용한 HTTPS 연결 (안드로이드 실기기 및 에뮬레이터 겸용)
  static const String baseUrl = 'https://54.66.35.196.nip.io';
}
