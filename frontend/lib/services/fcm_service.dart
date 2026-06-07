import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';

// 백그라운드 메시지 핸들러는 최상위 함수여야 합니다.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("Handling a background message: ${message.messageId}");
}

class FcmService {
  static final FcmService _instance = FcmService._internal();
  factory FcmService() => _instance;
  FcmService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> init() async {
    // 백그라운드 핸들러 등록
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 알림 권한 요청
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    debugPrint('User granted permission: ${settings.authorizationStatus}');

    // 포그라운드 수신 리스너 등록
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Got a message whilst in the foreground!');
      debugPrint('Message data: ${message.data}');

      if (message.notification != null) {
        debugPrint(
          'Message also contained a notification: ${message.notification?.title}',
        );
      }
    });
  }

  /// 기기의 FCM 토큰을 가져와 백엔드 서버에 등록합니다.
  Future<void> uploadFcmToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      if (token == null) {
        debugPrint("FCM Token is null. Cannot upload.");
        return;
      }

      debugPrint("FCM Token: $token");

      final prefs = await SharedPreferences.getInstance();
      final String authToken = prefs.getString('auth_token') ?? '';

      if (authToken.isEmpty) {
        debugPrint("No auth token. Cannot upload FCM token.");
        return;
      }

      final response = await http.patch(
        Uri.parse(
          '${ApiConfig.baseUrl}/api/users/settings/fcm-token?token=$token',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        debugPrint("FCM Token uploaded successfully.");
      } else {
        debugPrint(
          "Failed to upload FCM token. Status code: ${response.statusCode}",
        );
      }
    } catch (e) {
      debugPrint("Error uploading FCM token: $e");
    }
  }
}
