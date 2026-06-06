class ApiConfig {
  // 실제 폰에서 테스트할 때는 이 값을 PC의 IPv4 주소(예: '192.168.0.23')로 변경하세요.
  // 에뮬레이터 환경이라면 '10.0.2.2'를 그대로 유지하시면 됩니다.
  static const String serverIp = '192.168.137.1.nip.io';

  static const String baseUrl = 'http://$serverIp:8080';
}
