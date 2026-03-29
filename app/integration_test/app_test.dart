import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:liubai/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-End Tests', () {
    testWidgets('完整专注流程测试', (tester) async {
      // 1. 启动应用
      app.main();
      await tester.pumpAndSettle();

      // 验证启动页显示
      expect(find.text('留 白'), findsOneWidget);
      expect(find.text('给心灵一片空地'), findsOneWidget);

      // 等待启动页动画完成并跳转到首页
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // 2. 验证首页显示
      expect(find.text('留 白'), findsOneWidget);
      expect(find.text('选择场景'), findsOneWidget);

      // 3. 选择一个标签（如"学习"）
      final studyTag = find.text('学习');
      if (studyTag.evaluate().isNotEmpty) {
        await tester.tap(studyTag);
        await tester.pumpAndSettle();
      }

      // 4. 点击开始留白
      final startButton = find.text('开始留白');
      expect(startButton, findsOneWidget);
      await tester.tap(startButton);
      await tester.pumpAndSettle();

      // 5. 验证计时器正在运行
      expect(find.text('留白中...'), findsOneWidget);

      // 6. 等待几秒
      await tester.pump(const Duration(seconds: 2));

      // 7. 点击暂停
      final pauseButton = find.text('暂停');
      expect(pauseButton, findsOneWidget);
      await tester.tap(pauseButton);
      await tester.pumpAndSettle();

      // 8. 验证已暂停
      expect(find.text('已暂停'), findsOneWidget);

      // 9. 点击继续
      final resumeButton = find.text('继续');
      expect(resumeButton, findsOneWidget);
      await tester.tap(resumeButton);
      await tester.pumpAndSettle();

      // 10. 点击结束
      final stopButton = find.text('结束');
      expect(stopButton, findsOneWidget);
      await tester.tap(stopButton);
      await tester.pumpAndSettle();

      // 11. 验证回到首页
      expect(find.text('开始留白'), findsOneWidget);
    });

    testWidgets('标签管理测试', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // 1. 验证标签显示
      expect(find.text('学习'), findsOneWidget);
      expect(find.text('工作'), findsOneWidget);

      // 2. 点击添加标签
      final addButton = find.text('添加');
      if (addButton.evaluate().isNotEmpty) {
        await tester.tap(addButton);
        await tester.pumpAndSettle();

        // 3. 输入标签名称
        final textField = find.byType(TextField);
        if (textField.evaluate().isNotEmpty) {
          await tester.enterText(textField, '测试标签');
          await tester.pumpAndSettle();

          // 4. 点击添加按钮
          final confirmButton = find.text('添加');
          await tester.tap(confirmButton.last);
          await tester.pumpAndSettle();
        }
      }
    });

    testWidgets('页面导航测试', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // 1. 验证在首页
      expect(find.text('留 白'), findsOneWidget);

      // 2. 点击日志
      final logNav = find.text('日志');
      expect(logNav, findsOneWidget);
      await tester.tap(logNav);
      await tester.pumpAndSettle();

      // 3. 验证日志页
      expect(find.text('留白日志'), findsOneWidget);

      // 4. 返回首页
      final homeNav = find.text('留白');
      expect(homeNav, findsOneWidget);
      await tester.tap(homeNav);
      await tester.pumpAndSettle();

      // 5. 验证回到首页
      expect(find.text('留 白'), findsOneWidget);
    });

    testWidgets('设置页面测试', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // 1. 点击设置
      final settingsNav = find.text('设置');
      expect(settingsNav, findsOneWidget);
      await tester.tap(settingsNav);
      await tester.pumpAndSettle();

      // 2. 验证设置页
      expect(find.text('设置'), findsOneWidget);
      expect(find.text('留白设置'), findsOneWidget);
      expect(find.text('默认时长'), findsOneWidget);

      // 3. 点击默认时长
      final durationSetting = find.text('25分钟');
      if (durationSetting.evaluate().isNotEmpty) {
        await tester.tap(durationSetting);
        await tester.pumpAndSettle();

        // 4. 选择45分钟
        final fortyFiveMin = find.text('45分钟');
        if (fortyFiveMin.evaluate().isNotEmpty) {
          await tester.tap(fortyFiveMin);
          await tester.pumpAndSettle();
        }
      }
    });
  });
}
