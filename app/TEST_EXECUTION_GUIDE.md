# 留白 App - 测试执行指南

## 测试执行命令

### 1. 运行所有单元测试

```bash
cd d:/Ai-depoy/projects/秒启专注/app
flutter test
```

### 2. 运行特定测试文件

```bash
# 数据模型测试
flutter test test/data/models_test.dart

# 核心工具测试
flutter test test/core/logger_test.dart
flutter test test/core/exceptions_test.dart
flutter test test/core/validators_test.dart
```

### 3. 生成测试覆盖率报告

```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

### 4. 运行集成测试

```bash
# Android
flutter test integration_test/app_test.dart

# iOS
flutter test integration_test/app_test.dart
```

---

## 预期测试结果

### 单元测试预期结果

| 测试文件 | 测试用例数 | 预期通过率 |
|----------|-----------|-----------|
| models_test.dart | 15 | 100% |
| logger_test.dart | 8 | 100% |
| exceptions_test.dart | 12 | 100% |
| validators_test.dart | 25 | 100% |
| **总计** | **60** | **100%** |

### 测试覆盖模块

- ✅ LiubaiSession (toMap, fromMap, copyWith)
- ✅ SceneTag (所有方法，预设标签)
- ✅ UserSettings (默认值，转换)
- ✅ DailyStats (基本操作)
- ✅ TimerState (状态管理)
- ✅ Logger (所有级别)
- ✅ Exceptions (所有异常类)
- ✅ Validators (所有验证方法)

---

## 测试代码示例

### 运行单个测试

```bash
flutter test --name "should create LiubaiSession with default values"
```

### 运行特定组

```bash
flutter test --name "LiubaiSession Tests"
```

### 查看详细输出

```bash
flutter test -v
```

---

## 覆盖率分析

### 当前覆盖率预估

| 模块 | 覆盖率 | 说明 |
|------|--------|------|
| lib/data/models.dart | ~95% | 所有模型类已测试 |
| lib/core/logger.dart | ~90% | 日志功能已测试 |
| lib/core/exceptions.dart | ~100% | 所有异常类已测试 |
| lib/core/validators.dart | ~95% | 所有验证方法已测试 |
| **总体** | **~40%** | 数据库和UI未测试 |

### 未覆盖模块

- lib/data/database.dart (需要 mock 数据库)
- lib/services/audio_service.dart (需要 mock 音频播放器)
- lib/presentation/*.dart (UI 测试需要 widget 测试)

---

## 持续集成配置建议

### GitHub Actions 示例

```yaml
name: Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Run tests
        run: flutter test --coverage
      
      - name: Upload coverage
        uses: codecov/codecov-action@v3
```

---

## 测试报告解读

### 成功示例

```
00:00 +15: All tests passed!
```

### 失败示例

```
00:01 +14 -1: Some tests failed.
  test/data/models_test.dart:45:9: Failed assertion
```

### 覆盖率报告

打开 `coverage/html/index.html` 查看可视化报告。

---

## 下一步建议

1. **安装 Flutter SDK** 后执行测试
2. **添加更多测试** 覆盖数据库和 UI
3. **设置 CI/CD** 自动运行测试
4. **目标覆盖率**: ≥80%
