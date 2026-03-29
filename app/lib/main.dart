import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'presentation/splash_page.dart';

void main() {
  runApp(const LiubaiApp());
}

class LiubaiApp extends StatelessWidget {
  const LiubaiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '留白',
      debugShowCheckedModeBanner: false,
      theme: LiubaiTheme.lightTheme,
      darkTheme: LiubaiTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const SplashPage(),
    );
  }
}
