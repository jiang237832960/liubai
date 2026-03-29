import 'package:flutter/material.dart';

/// 留白品牌色彩系统
class LiubaiColors {
  // 主色调
  static const Color liubaiWhite = Color(0xFFFFFFFF);
  static const Color inkBlack = Color(0xFF1A1A1A);
  static const Color lightInkGray = Color(0xFFE5E5E5);
  
  // 辅助色
  static const Color xuanPaperYellow = Color(0xFFF5F0E8);
  static const Color pineSmokeGray = Color(0xFF8C8C8C);
  static const Color cinnabarRed = Color(0xFFC45C48);
  
  // 深色模式
  static const Color darkBackground = Color(0xFF1A1A1A);
  static const Color darkSurface = Color(0xFF2D2D2D);
}

/// 留白品牌字体系统
class LiubaiTypography {
  static const String fontFamily = 'NotoSansSC';
  
  // 大标题 - 品牌名
  static const TextStyle brand = TextStyle(
    fontFamily: fontFamily,
    fontSize: 48,
    fontWeight: FontWeight.w300,
    letterSpacing: 16,
    color: LiubaiColors.inkBlack,
  );
  
  // 计时器显示
  static const TextStyle timer = TextStyle(
    fontFamily: fontFamily,
    fontSize: 72,
    fontWeight: FontWeight.w200,
    letterSpacing: 4,
    color: LiubaiColors.inkBlack,
  );
  
  // 页面标题
  static const TextStyle h1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w400,
    color: LiubaiColors.inkBlack,
  );
  
  // 副标题
  static const TextStyle h2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w400,
    color: LiubaiColors.inkBlack,
  );
  
  // 正文
  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: LiubaiColors.inkBlack,
  );
  
  // 小字
  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: LiubaiColors.pineSmokeGray,
  );
  
  // 按钮文字
  static const TextStyle button = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 2,
    color: LiubaiColors.inkBlack,
  );
  
  // 深色模式样式
  static const TextStyle brandDark = TextStyle(
    fontFamily: fontFamily,
    fontSize: 48,
    fontWeight: FontWeight.w300,
    letterSpacing: 16,
    color: LiubaiColors.liubaiWhite,
  );
  
  static const TextStyle timerDark = TextStyle(
    fontFamily: fontFamily,
    fontSize: 72,
    fontWeight: FontWeight.w200,
    letterSpacing: 4,
    color: LiubaiColors.liubaiWhite,
  );
  
  static const TextStyle h1Dark = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w400,
    color: LiubaiColors.liubaiWhite,
  );
  
  static const TextStyle h2Dark = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w400,
    color: LiubaiColors.liubaiWhite,
  );
  
  static const TextStyle bodyDark = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: LiubaiColors.liubaiWhite,
  );
  
  static const TextStyle captionDark = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: LiubaiColors.pineSmokeGray,
  );
  
  static const TextStyle buttonDark = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 2,
    color: LiubaiColors.liubaiWhite,
  );
}

/// 留白品牌主题
class LiubaiTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: LiubaiColors.liubaiWhite,
      colorScheme: const ColorScheme.light(
        primary: LiubaiColors.inkBlack,
        onPrimary: LiubaiColors.liubaiWhite,
        secondary: LiubaiColors.lightInkGray,
        onSecondary: LiubaiColors.inkBlack,
        surface: LiubaiColors.liubaiWhite,
        onSurface: LiubaiColors.inkBlack,
        background: LiubaiColors.liubaiWhite,
        onBackground: LiubaiColors.inkBlack,
      ),
      fontFamily: LiubaiTypography.fontFamily,
      textTheme: const TextTheme(
        displayLarge: LiubaiTypography.timer,
        displayMedium: LiubaiTypography.brand,
        headlineLarge: LiubaiTypography.h1,
        headlineMedium: LiubaiTypography.h2,
        bodyLarge: LiubaiTypography.body,
        bodySmall: LiubaiTypography.caption,
        labelLarge: LiubaiTypography.button,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: LiubaiColors.liubaiWhite,
        foregroundColor: LiubaiColors.inkBlack,
        elevation: 0,
        centerTitle: true,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: LiubaiColors.liubaiWhite,
        selectedItemColor: LiubaiColors.inkBlack,
        unselectedItemColor: LiubaiColors.pineSmokeGray,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: LiubaiColors.inkBlack,
          foregroundColor: LiubaiColors.liubaiWhite,
          minimumSize: const Size(200, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          textStyle: LiubaiTypography.button,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: LiubaiColors.inkBlack,
          textStyle: LiubaiTypography.button,
        ),
      ),
      cardTheme: CardTheme(
        color: LiubaiColors.liubaiWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: LiubaiColors.lightInkGray),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: LiubaiColors.liubaiWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: LiubaiColors.lightInkGray),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: LiubaiColors.lightInkGray),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: LiubaiColors.inkBlack),
        ),
      ),
    );
  }
  
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: LiubaiColors.darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: LiubaiColors.liubaiWhite,
        onPrimary: LiubaiColors.inkBlack,
        secondary: LiubaiColors.darkSurface,
        onSecondary: LiubaiColors.liubaiWhite,
        surface: LiubaiColors.darkSurface,
        onSurface: LiubaiColors.liubaiWhite,
        background: LiubaiColors.darkBackground,
        onBackground: LiubaiColors.liubaiWhite,
      ),
      fontFamily: LiubaiTypography.fontFamily,
      textTheme: const TextTheme(
        displayLarge: LiubaiTypography.timerDark,
        displayMedium: LiubaiTypography.brandDark,
        headlineLarge: LiubaiTypography.h1Dark,
        headlineMedium: LiubaiTypography.h2Dark,
        bodyLarge: LiubaiTypography.bodyDark,
        bodySmall: LiubaiTypography.captionDark,
        labelLarge: LiubaiTypography.buttonDark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: LiubaiColors.darkBackground,
        foregroundColor: LiubaiColors.liubaiWhite,
        elevation: 0,
        centerTitle: true,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: LiubaiColors.darkBackground,
        selectedItemColor: LiubaiColors.liubaiWhite,
        unselectedItemColor: LiubaiColors.pineSmokeGray,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: LiubaiColors.liubaiWhite,
          foregroundColor: LiubaiColors.inkBlack,
          minimumSize: const Size(200, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          textStyle: LiubaiTypography.buttonDark,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: LiubaiColors.liubaiWhite,
          textStyle: LiubaiTypography.buttonDark,
        ),
      ),
      cardTheme: CardTheme(
        color: LiubaiColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: LiubaiColors.darkSurface),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: LiubaiColors.darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: LiubaiColors.darkSurface),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: LiubaiColors.darkSurface),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: LiubaiColors.liubaiWhite),
        ),
      ),
    );
  }
}
