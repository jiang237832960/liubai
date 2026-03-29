import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme.dart';
import 'presentation/splash_page.dart';
import 'providers/theme_provider.dart';

void main() {
  runApp(const ProviderScope(child: LiubaiApp()));
}

class LiubaiApp extends ConsumerStatefulWidget {
  const LiubaiApp({super.key});

  @override
  ConsumerState<LiubaiApp> createState() => _LiubaiAppState();
}

class _LiubaiAppState extends ConsumerState<LiubaiApp> {
  @override
  void initState() {
    super.initState();
    ref.read(themeProvider.notifier).loadTheme();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    
    return MaterialApp(
      title: '留白',
      debugShowCheckedModeBanner: false,
      theme: LiubaiTheme.lightTheme,
      darkTheme: LiubaiTheme.darkTheme,
      themeMode: themeMode,
      home: const SplashPage(),
    );
  }
}
