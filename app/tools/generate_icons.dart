import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('🎨 开始生成留白 App 图标...');
  
  // 创建输出目录
  final outputDir = Directory('generated_icons');
  if (!outputDir.existsSync()) {
    outputDir.createSync(recursive: true);
  }
  
  // 生成主图标 (1024x1024)
  await generateIcon(
    size: 1024,
    outputPath: 'generated_icons/icon_1024x1024.png',
    isDark: false,
  );
  
  // 生成深色模式图标
  await generateIcon(
    size: 1024,
    outputPath: 'generated_icons/icon_dark_1024x1024.png',
    isDark: true,
  );
  
  // 生成 Android 图标
  final androidSizes = {
    'mdpi': 48,
    'hdpi': 72,
    'xhdpi': 96,
    'xxhdpi': 144,
    'xxxhdpi': 192,
  };
  
  for (final entry in androidSizes.entries) {
    await generateIcon(
      size: entry.value,
      outputPath: 'generated_icons/android/ic_launcher_${entry.key}.png',
      isDark: false,
    );
  }
  
  // 生成 iOS 图标
  final iosSizes = {
    'Icon-20x20@1x': 20,
    'Icon-20x20@2x': 40,
    'Icon-20x20@3x': 60,
    'Icon-29x29@1x': 29,
    'Icon-29x29@2x': 58,
    'Icon-29x29@3x': 87,
    'Icon-40x40@1x': 40,
    'Icon-40x40@2x': 80,
    'Icon-40x40@3x': 120,
    'Icon-60x60@2x': 120,
    'Icon-60x60@3x': 180,
    'Icon-76x76@1x': 76,
    'Icon-76x76@2x': 152,
    'Icon-83.5x83.5@2x': 167,
    'iTunesArtwork@2x': 1024,
  };
  
  for (final entry in iosSizes.entries) {
    await generateIcon(
      size: entry.value,
      outputPath: 'generated_icons/ios/${entry.key}.png',
      isDark: false,
    );
  }
  
  print('✅ 图标生成完成！');
  print('📁 输出目录: ${outputDir.absolute.path}');
}

Future<void> generateIcon({
  required int size,
  required String outputPath,
  required bool isDark,
}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  
  // 颜色定义
  final backgroundColor = isDark ? const Color(0xFF1A1A1A) : const Color(0xFFFFFFFF);
  final textColor = isDark ? const Color(0xFFFFFFFF) : const Color(0xFF1A1A1A);
  
  // 绘制背景
  final paint = Paint()..color = backgroundColor;
  canvas.drawRect(Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble()), paint);
  
  // 绘制文字 "留"
  final textStyle = ui.TextStyle(
    color: textColor,
    fontSize: size * 0.5,
    fontWeight: ui.FontWeight.w300,
    letterSpacing: size * 0.05,
  );
  
  final paragraphStyle = ui.ParagraphStyle(
    textAlign: TextAlign.center,
  );
  
  final paragraphBuilder = ui.ParagraphBuilder(paragraphStyle)
    ..pushStyle(textStyle)
    ..addText('留');
  
  final paragraph = paragraphBuilder.build()
    ..layout(ui.ParagraphConstraints(width: size.toDouble()));
  
  // 计算文字位置使其居中
  final textHeight = paragraph.height;
  final textWidth = paragraph.maxIntrinsicWidth;
  final x = (size - textWidth) / 2;
  final y = (size - textHeight) / 2;
  
  canvas.drawParagraph(paragraph, Offset(x, y));
  
  // 生成图片
  final picture = recorder.endRecording();
  final image = await picture.toImage(size, size);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  
  if (byteData != null) {
    final buffer = byteData.buffer.asUint8List();
    final file = File(outputPath);
    file.parent.createSync(recursive: true);
    await file.writeAsBytes(buffer);
    print('✓ 生成: $outputPath (${size}x$size)');
  }
  
  image.dispose();
}
