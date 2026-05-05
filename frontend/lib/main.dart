import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const EmotionalDiaryApp());
}

class EmotionalDiaryApp extends StatelessWidget {
  const EmotionalDiaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Custom Color Palette
    const Color paperWhite = Color(0xFFFAF9F6);
    const Color warmBeige = Color(0xFFE8DECF);
    const Color textBrown = Color(0xFF5A4A3D);
    const Color softIvory = Color(0xFFFDFCF8);
    const Color highlightBeige = Color(0xFFD6C5B3);

    return MaterialApp(
      title: 'AI Diary',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
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
      ),
      home: const LoginScreen(),
    );
  }
}
