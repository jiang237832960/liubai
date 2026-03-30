# 留白 App 问题追踪

## 待排查问题

（暂无）

---

## 已修复问题记录

### 9. 统计问题：一天多次留白可能被统计为多天

**原因**：`getTotalStats` 中计算 `active_days` 使用的 SQLite `datetime` 函数带有 `localtime` 参数，该参数不是标准 SQLite 语法，导致跨平台兼容性问题

**修复**：将 `datetime((start_time / 1000), 'unixepoch', 'localtime')` 改为 `date(start_time / 1000, 'unixepoch')`，使用标准的 `date()` 函数获取日期

**相关文件**：`lib/data/database.dart` - `getTotalStats()` (行859)

**提交**：`新提交`

---

### 1. Android 应用名称显示为 "app"

**原因**：AndroidManifest.xml 中 `android:label="app"`

**修复**：改为 `android:label="留白"`

**提交**：`34f2ac8`

---

### 2. 首页无法选择标签和开始留白

**原因**：
- `get database` 方法没有正确缓存数据库连接
- 每次查询都重新初始化，导致并发问题

**修复**：
```dart
Future<Database> get database async {
  if (_database != null) return _database!;
  _database = await _initDB(_dbName);
  return _database!;
}
```

**提交**：`34f2ac8`

---

### 3. 设置页面一直转圈

**原因**：同问题2

**修复**：同问题2

**提交**：`34f2ac8`

---

### 4. 标签添加后没有实时更新

**原因**：`SceneTagSelector` 添加标签后没有通知父组件刷新

**修复**：添加 `onTagsChanged` callback，添加标签后调用

**相关文件**：`lib/presentation/widgets/scene_tag_selector.dart`

**提交**：`ffc3212`

---

### 5. 留白音没有对应音频文件

**原因**：内置音频引用不存在的资源文件

**修复**：
- 添加五种内置留白音音频文件到 `assets/audio/` 目录
- 雨声🌧️、森林🌲、咖啡厅☕、海浪🌊、篝火🔥
- 更新 `pubspec.yaml` 配置音频资源路径
- 使用 `just_audio` 的 `setAsset()` 直接播放内置音频

**相关文件**：
- `assets/audio/rain.mp3` - 雨声
- `assets/audio/forest.mp3` - 森林
- `assets/audio/cafe.mp3` - 咖啡厅
- `assets/audio/waves.mp3` - 海浪
- `assets/audio/fire.mp3` - 篝火
- `lib/services/audio_service.dart` - 更新内置音频配置
- `lib/presentation/audio_page.dart` - 简化播放逻辑
- `pubspec.yaml` - 添加 assets 配置

**提交**：`新提交`

---

### 6. 主题模式选择后没有实时更新

**原因**：`LiubaiApp` 是 StatelessWidget，主题变更后不会自动重建

**修复**：使用 Riverpod 创建 `ThemeProvider`，主题变更实时生效

**相关文件**：
- `lib/main.dart`
- `lib/providers/theme_provider.dart`

**提交**：`ffc3212`

---

### 7. SplashPage 跳转时机问题

**原因**：SplashPage 在数据库初始化完成前就跳转到 HomePage，导致数据库操作失败

**修复**：SplashPage 现在等待数据库初始化完成后再跳转

**相关文件**：`lib/presentation/splash_page.dart`

**提交**：`d32d456`

---

### 8. 预设标签无显示

**原因**：`SceneTag.presets` 中每个标签使用 `DateTime.now()` 作为 `createdAt`，导致时间戳不一致

**修复**：使用同一个 `createdAt` 时间戳

**相关文件**：`lib/data/models.dart`

**提交**：`d32d456`

---

## 代码审查修复记录

### P0 严重问题

| 问题 | 文件 | 状态 |
|------|------|------|
| validators.dart 重复验证逻辑 | lib/core/validators.dart | ✅ 已修复 |
| database.dart completedCount 计算错误 | lib/data/database.dart | ✅ 已修复 |

### P1 问题

| 问题 | 文件 | 状态 |
|------|------|------|
| home_page.dart 异常被吞没 | lib/presentation/home_page.dart | ✅ 已修复 |
| database.dart 数据库并发初始化 | lib/data/database.dart | ✅ 已修复 |
| audio_page.dart dispose 顺序错误 | lib/presentation/audio_page.dart | ✅ 已修复 |

### P2 问题

| 问题 | 文件 | 状态 |
|------|------|------|
| validateVolume 命名不当 | lib/core/validators.dart | ✅ 已修复 |
| 立即停止记录为1分钟 | lib/presentation/home_page.dart | ✅ 已修复 |
| audio_page.dart ID使用时间戳 | lib/presentation/audio_page.dart | ✅ 已修复 |
| database.dart SQLite日期函数兼容 | lib/data/database.dart | ✅ 已修复 |

### P3 问题

| 问题 | 文件 | 状态 |
|------|------|------|
| home_page.dart 代码重复 | lib/presentation/home_page.dart | ✅ 已修复 |
| theme.dart 移除不存在的字体 | lib/core/theme.dart | ✅ 已修复 |

---

## 构建配置更新

### Android 构建配置

- AGP: 7.3.0 → 8.2.0
- Gradle: 7.5 → 8.4
- Kotlin: 1.9.0 → 1.9.24
- compileSdk: 34 → 35
- NDK: 23.1.7779620 → 25.1.8937393
- 启用 coreLibraryDesugaring

**提交**：`8c2414c`
