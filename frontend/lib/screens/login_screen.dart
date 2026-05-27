import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'setup_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Spacer(),
              // App Logo
              Column(
                children: [
                  Icon(
                    Icons.auto_stories_rounded,
                    size: 100,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'AI Diary',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.primary,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '당신의 일상을 따뜻하게 기록하세요',
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Google Login Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    // 백엔드 OAuth2 리다이렉트 URL (에뮬레이터용 10.0.2.2, 실제 기기/웹의 경우 서버 주소로 변경 필요)
                    final Uri url = Uri.parse(
                      'http://10.0.2.2:8080/oauth2/authorization/google',
                    );
                    if (await canLaunchUrl(url)) {
                      await launchUrl(
                        url,
                        mode: LaunchMode.externalApplication,
                      );

                      // 성공적으로 URL을 띄운 후 다음 화면(초기 설정 화면)으로 넘어갑니다.
                      // (실제 프로덕션에서는 딥링크나 flutter_web_auth 패키지 등을 통해 토큰을 받아온 뒤 넘어가야 합니다.)
                      if (context.mounted) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SetupScreen(),
                          ),
                        );
                      }
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('구글 로그인 창을 열 수 없습니다.')),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.g_mobiledata, size: 32),
                  label: const Text(
                    'Google 계정으로 시작하기',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                      side: BorderSide(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.2),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
