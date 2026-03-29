# 留白 App - 闪退诊断与修复指南

## 🔍 常见闪退原因

### 1. 数据库问题（最常见）
- 数据库文件损坏
- 数据库版本不匹配
- 首次启动时数据库初始化失败

### 2. 权限问题
- 存储权限未授予
- 音频播放权限缺失
- 文件读取权限

### 3. 资源缺失
- 音频文件未正确打包
- 字体文件缺失
- 图标资源缺失

### 4. 代码异常
- 空指针异常
- 数组越界
- 异步操作异常

### 5. 内存问题
- 内存泄漏
- 大对象未释放
- 图片资源过大

---

## 📋 诊断步骤

### 步骤 1: 查看日志

```bash
# Android
adb logcat | grep flutter

# iOS (在 Xcode 中查看)
# Window > Devices and Simulators > View Device Logs
```

### 步骤 2: 检查关键日志标签

```bash
# 查看应用启动日志
adb logcat -s "Flutter" "AndroidRuntime" "System.err"

# 查看数据库相关日志
adb logcat -s "Database" "SQLite"

# 查看音频相关日志
adb logcat -s "Audio" "MediaPlayer"
```

### 步骤 3: 常见错误关键词

| 错误关键词 | 可能原因 | 解决方案 |
|-----------|----------|----------|
| `SQLiteException` | 数据库损坏 | 删除数据库重新创建 |
| `NullPointerException` | 空指针 | 检查空值处理 |
| `OutOfMemoryError` | 内存不足 | 优化内存使用 |
| `FileNotFoundException` | 文件缺失 | 检查资源文件 |
| `Permission denied` | 权限问题 | 申请运行时权限 |

---

## 🔧 修复方案

### 方案 1: 修复数据库闪退

修改 `lib/data/database.dart`，添加更健壮的错误处理：

```dart
/// 初始化数据库（带损坏检测和重建）
Future<Database> _initDB(String filePath) async {
  try {
    // 检查存储空间
    final hasSpace = await _checkStorageSpace();
    if (!hasSpace) {
      throw const DatabaseException(
        '存储空间不足，请清理空间后重试',
        code: 'DB_STORAGE_FULL',
      );
    }

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    final backupPath = join(dbPath, _dbBackupName);

    Logger.i('初始化数据库: $path', tag: _tag);

    // 尝试打开数据库
    try {
      final db = await openDatabase(
        path,
        version: 1,
        onCreate: _createDB,
        onOpen: (db) => Logger.i('数据库已打开', tag: _tag),
      );

      // 验证数据库完整性
      final isValid = await _verifyDatabaseIntegrity(path);
      if (isValid) {
        await _backupDatabase(path, backupPath);
        return db;
      } else {
        throw Exception('数据库完整性验证失败');
      }
    } catch (openError) {
      Logger.w('数据库打开失败，尝试恢复: $openError', tag: _tag);

      // 尝试从备份恢复
      final backupFile = File(backupPath);
      if (await backupFile.exists()) {
        try {
          await _deleteCorruptedDatabase(path);
          await backupFile.copy(path);
          Logger.i('从备份恢复数据库成功', tag: _tag);

          final db = await openDatabase(
            path,
            version: 1,
            onCreate: _createDB,
            onOpen: (db) => Logger.i('数据库已从备份恢复并打开', tag: _tag),
          );

          final isValid = await _verifyDatabaseIntegrity(path);
          if (isValid) {
            return db;
          }
        } catch (restoreError) {
          Logger.e('从备份恢复失败: $restoreError', tag: _tag);
        }
      }

      // 重新创建数据库
      Logger.w('删除损坏数据库并重新创建', tag: _tag);
      await _deleteCorruptedDatabase(path);

      final db = await openDatabase(
        path,
        version: 1,
        onCreate: _createDB,
        onOpen: (db) => Logger.i('数据库已重新创建', tag: _tag),
      );

      return db;
    }
  } on DatabaseException {
    rethrow;
  } catch (e, stackTrace) {
    Logger.e('数据库初始化失败', tag: _tag, error: e, stackTrace: stackTrace);
    throw DatabaseException(
      '数据库初始化失败: $e',
      code: 'DB_INIT_ERROR',
      originalError: e,
    );
  }
}
```

### 方案 2: 添加全局异常捕获

创建 `lib/core/error_handler.dart`：

```dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'logger.dart';

/// 全局错误处理
class ErrorHandler {
  static void initialize() {
    // 捕获 Flutter 框架异常
    FlutterError.onError = (FlutterErrorDetails details) {
      Logger.e(
        'Flutter 异常',
        error: details.exception,
        stackTrace: details.stack,
      );
      FlutterError.presentError(details);
    };

    // 捕获 Zone 异常
    runZonedGuarded(
      () {},
      (error, stack) {
        Logger.e(
          'Zone 异常',
          error: error,
          stackTrace: stack,
        );
      },
    );
  }

  /// 显示错误提示
  static void showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('出错了'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}
```

在 `main.dart` 中初始化：

```dart
void main() {
  ErrorHandler.initialize();
  runApp(const LiubaiApp());
}
```

### 方案 3: 修复音频闪退

修改 `lib/services/audio_service.dart`：

```dart
/// 播放白噪音
Future<void> play(WhiteNoise noise) async {
  try {
    if (!_isInitialized) {
      await initialize();
    }

    Logger.i('开始播放: ${noise.name}', tag: _tag);

    // 停止当前播放
    await stop();

    // 设置音频源
    if (noise.isBuiltIn && noise.assetPath != null) {
      // 验证资源是否存在
      try {
        await _player.setAsset(noise.assetPath!);
      } catch (e) {
        Logger.e('音频资源不存在: ${noise.assetPath}', tag: _tag);
        throw AudioException(
          '音频资源不存在: ${noise.name}',
          code: 'AUDIO_RESOURCE_MISSING',
        );
      }
    } else if (noise.filePath != null) {
      // 验证文件是否存在
      final file = File(noise.filePath!);
      if (!await file.exists()) {
        Logger.e('音频文件不存在: ${noise.filePath}', tag: _tag);
        throw AudioException(
          '音频文件不存在: ${noise.name}',
          code: 'AUDIO_FILE_MISSING',
        );
      }
      await _player.setFilePath(noise.filePath!);
    } else {
      throw const AudioException(
        '无效的音频源',
        code: 'AUDIO_INVALID_SOURCE',
      );
    }

    // 设置音量
    await _player.setVolume(noise.volume);

    // 循环播放
    await _player.setLoopMode(LoopMode.all);

    // 开始播放
    await _player.play();

    // 更新状态
    _currentNoise = noise;
    noise.isPlaying = true;

    Logger.i('播放成功: ${noise.name}', tag: _tag);
  } catch (e, stackTrace) {
    Logger.e('播放失败: ${noise.name}', tag: _tag, error: e, stackTrace: stackTrace);
    throw AudioException(
      '播放失败: ${noise.name}',
      code: 'AUDIO_PLAY_ERROR',
      originalError: e,
    );
  }
}
```

### 方案 4: 修复权限问题

在 `android/app/src/main/AndroidManifest.xml` 中添加权限：

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- 存储权限 -->
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
    
    <!-- 音频权限 -->
    <uses-permission android:name="android.permission.RECORD_AUDIO"/>
    <uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS"/>
    
    <!-- 通知权限 -->
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE"/>
    
    <!-- 网络权限（用于更新检查） -->
    <uses-permission android:name="android.permission.INTERNET"/>
    
    <application
        ...>
        ...
    </application>
</manifest>
```

### 方案 5: 修复启动闪退

修改 `lib/main.dart`，添加启动保护：

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/error_handler.dart';
import 'core/theme.dart';
import 'presentation/splash_page.dart';

void main() {
  // 确保 Flutter 绑定初始化
  WidgetsFlutterBinding.ensureInitialized();
  
  // 设置首选屏幕方向
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // 初始化错误处理
  ErrorHandler.initialize();
  
  // 捕获启动异常
  runZonedGuarded(
    () {
      runApp(const LiubaiApp());
    },
    (error, stack) {
      Logger.e('应用启动失败', error: error, stackTrace: stack);
      // 可以在这里显示启动错误页面
    },
  );
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
      // 添加错误页面
      builder: (context, child) {
        ErrorWidget.builder = (FlutterErrorDetails details) {
          return Material(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text(
                    '出错了',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '请重启应用',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          );
        };
        return child!;
      },
    );
  }
}
```

---

## 🧹 清理数据重置应用

如果闪退无法解决，可以清理应用数据：

### Android
```bash
# 清除应用数据
adb shell pm clear com.liubai.app

# 或者手动：设置 > 应用 > 留白 > 存储 > 清除数据
```

### iOS
```bash
# 卸载并重新安装应用
# 或者：设置 > 通用 > iPhone 存储空间 > 留白 > 卸载 App
```

---

## 📊 调试模式

### 启用详细日志

在 `lib/core/logger.dart` 中设置：

```dart
void main() {
  // 设置日志级别为详细
  Logger.setMinLevel(LogLevel.verbose);
  
  runApp(const LiubaiApp());
}
```

### 使用 Flutter DevTools

```bash
# 启动 DevTools
flutter pub global activate devtools
flutter pub global run devtools

# 运行应用并连接
flutter run --observatory-port=9200
```

---

## 📝 闪退报告模板

如果问题仍然存在，请提供以下信息：

```
设备信息:
- 设备型号: [例如: Xiaomi 13]
- 系统版本: [例如: Android 13]
- 应用版本: [例如: 1.0.0]

闪退场景:
- 操作步骤: [详细描述]
- 发生频率: [每次/偶尔/仅一次]
- 是否可复现: [是/否]

日志信息:
- 错误日志: [粘贴 logcat 输出]
- 崩溃时间: [具体时间]

已尝试的解决方案:
- [列出已尝试的方法]
```

---

## ✅ 预防闪退的最佳实践

1. **空值检查**: 所有可空变量使用前检查
2. **异常捕获**: 关键操作添加 try-catch
3. **资源验证**: 使用资源前验证存在性
4. **权限检查**: 敏感操作前检查权限
5. **内存管理**: 及时释放大对象和监听器
6. **测试覆盖**: 充分测试边界条件
7. **灰度发布**: 先在小范围测试

---

## 🔗 相关文档

- [Flutter 调试文档](https://docs.flutter.dev/testing/debugging)
- [Android 崩溃分析](https://developer.android.com/studio/debug/am-logcat)
- [iOS 崩溃日志](https://developer.apple.com/documentation/xcode/diagnosing-issues-using-crash-reports)
