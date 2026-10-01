import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'services/fcm_service.dart';
import 'screens/diary_home_page.dart';

// 전역 테마 상태
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 환경 변수(.env) 로드 (스포티파이 SDK 키 등)
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint('.env 파일을 로드하는 중 오류 발생: $e');
  }

  await Firebase.initializeApp();
  await FcmService().init();
  FcmService().uploadFcmToken();

  // 폰 하단 소프트키(홈, 뒤로가기 버튼) 숨기기 (상단 상태바만 유지)
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: [SystemUiOverlay.top],
  );
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token');
  final savedTheme = prefs.getString('themeMode');
  if (savedTheme == 'dark') {
    themeNotifier.value = ThemeMode.dark;
  }

  runApp(EmotionalDiaryApp(initialToken: token));
}

class EmotionalDiaryApp extends StatelessWidget {
  final String? initialToken;

  const EmotionalDiaryApp({super.key, this.initialToken});

  @override
  Widget build(BuildContext context) {
    // Custom Color Palette
    const Color paperWhite = Color(0xFFFAF9F6);
    const Color warmBeige = Color(0xFFE8DECF);
    const Color textBrown = Color(0xFF5A4A3D);
    const Color softIvory = Color(0xFFFDFCF8);
    const Color highlightBeige = Color(0xFFD6C5B3);

    // Dark Color Palette
    const Color darkBackground = Color(0xFF1E1915);
    const Color darkSurface = Color(0xFF2A231D);
    const Color darkSurfaceContainer = Color(0xFF352C24);
    const Color darkText = Color(0xFFE8DECF);
    const Color darkHighlight = Color(0xFF5A4A3D);

    final lightTheme = ThemeData(
      useMaterial3: true,
      fontFamily: 'CustomFont1',
      colorScheme: ColorScheme.fromSeed(
        seedColor: warmBeige,
        brightness: Brightness.light,
        primary: textBrown,
        secondary: highlightBeige,
        surface: paperWhite,
        surfaceContainer: softIvory, // Replaces background
        onSurface: textBrown,
      ),
      scaffoldBackgroundColor: paperWhite,
      appBarTheme: const AppBarTheme(
        backgroundColor: paperWhite,
        foregroundColor: textBrown,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'CustomFont1',
          color: textBrown,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(color: textBrown, fontWeight: FontWeight.w600),
        bodyMedium: TextStyle(color: textBrown, height: 1.6),
        bodySmall: TextStyle(color: textBrown, height: 1.5),
      ),
      cardTheme: CardThemeData(
        color: softIvory,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: warmBeige.withOpacity(0.5), width: 1),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: warmBeige,
        foregroundColor: textBrown,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
    );

    final darkTheme = ThemeData(
      useMaterial3: true,
      fontFamily: 'CustomFont1',
      colorScheme: ColorScheme.fromSeed(
        seedColor: darkHighlight,
        brightness: Brightness.dark,
        primary: darkText,
        secondary: darkHighlight,
        surface: darkBackground,
        surfaceContainer: darkSurfaceContainer,
        onSurface: darkText,
      ),
      scaffoldBackgroundColor: darkBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBackground,
        foregroundColor: darkText,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'CustomFont1',
          color: darkText,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(color: darkText, fontWeight: FontWeight.w600),
        bodyMedium: TextStyle(color: darkText, height: 1.6),
        bodySmall: TextStyle(color: darkText, height: 1.5),
      ),
      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: darkHighlight.withOpacity(0.5), width: 1),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: darkSurfaceContainer,
        foregroundColor: darkText,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: darkSurfaceContainer,
        contentTextStyle: TextStyle(color: darkText),
        behavior: SnackBarBehavior.floating,
      ),
    );

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, child) {
        return MaterialApp(
          title: '나래',
          debugShowCheckedModeBanner: false,
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: currentMode,
          home: initialToken != null && initialToken!.isNotEmpty
              ? DiaryHomePage(initialToken: initialToken!)
              : const LoginScreen(),
        );
      },
    );
  }
}
