# 留白 App 图标配置指南

## 图标设计完成 ✅

### 设计规范
- **主元素**："留 白" 品牌名
- **字体**：思源黑体 Light
- **颜色**：墨黑 (#1A1A1A) 在纯白 (#FFFFFF) 背景上
- **风格**：极简、东方美学、大量留白

### 启动页实现 ✅
- 文件：`lib/presentation/splash_page.dart`
- 功能：淡入动画，2秒后自动跳转到首页
- 显示：品牌名 + Slogan

---

## Android 图标配置

### 步骤 1：生成图标

使用在线工具生成Android图标：
1. 访问 [Icon Kitchen](https://icon.kitchen/)
2. 上传主图标（1024x1024）
3. 选择背景色：#FFFFFF（纯白）
4. 下载Android图标包

### 步骤 2：放置图标文件

将生成的图标文件放入对应目录：

```
android/app/src/main/res/
├── mipmap-mdpi/
│   └── ic_launcher.png       # 48x48
├── mipmap-hdpi/
│   └── ic_launcher.png       # 72x72
├── mipmap-xhdpi/
│   └── ic_launcher.png       # 96x96
├── mipmap-xxhdpi/
│   └── ic_launcher.png       # 144x144
└── mipmap-xxxhdpi/
    └── ic_launcher.png       # 192x192
```

### 步骤 3：配置 AndroidManifest.xml

确保 `android/app/src/main/AndroidManifest.xml` 中已配置：

```xml
<application
    android:label="留白"
    android:icon="@mipmap/ic_launcher">
```

---

## iOS 图标配置

### 步骤 1：生成图标

使用在线工具生成iOS图标：
1. 访问 [App Icon Generator](https://appicon.co/)
2. 上传主图标（1024x1024）
3. 下载iOS图标包

### 步骤 2：放置图标文件

将生成的图标文件放入：

```
ios/Runner/Assets.xcassets/AppIcon.appiconset/
├── Contents.json
├── Icon-20x20@1x.png
├── Icon-20x20@2x.png
├── Icon-20x20@3x.png
├── Icon-29x29@1x.png
├── Icon-29x29@2x.png
├── Icon-29x29@3x.png
├── Icon-40x40@1x.png
├── Icon-40x40@2x.png
├── Icon-40x40@3x.png
├── Icon-60x60@2x.png
├── Icon-60x60@3x.png
├── Icon-76x76@1x.png
├── Icon-76x76@2x.png
├── Icon-83.5x83.5@2x.png
└── iTunesArtwork@2x.png
```

### 步骤 3：配置 Info.plist

确保 `ios/Runner/Info.plist` 中已配置：

```xml
<key>CFBundleDisplayName</key>
<string>留白</string>
```

---

## 启动图配置（可选）

### Android 启动图

1. 在 `android/app/src/main/res/drawable/` 创建 `launch_background.xml`：

```xml
<?xml version="1.0" encoding="utf-8"?>
<layer-list xmlns:android="http://schemas.android.com/apk/res/android">
    <item android:drawable="@android:color/white" />
    <item>
        <bitmap
            android:gravity="center"
            android:src="@mipmap/ic_launcher" />
    </item>
</layer-list>
```

2. 在 `android/app/src/main/res/values/styles.xml` 中配置：

```xml
<style name="LaunchTheme" parent="@android:style/Theme.Light.NoActionBar">
    <item name="android:windowBackground">@drawable/launch_background</item>
</style>
```

### iOS 启动图

1. 在 Xcode 中打开 `ios/Runner.xcworkspace`
2. 选择 `Runner` → `Assets.xcassets`
3. 添加 `LaunchImage` 图片集
4. 配置不同尺寸的启动图

---

## 图标生成工具推荐

### 在线工具
1. **Icon Kitchen** (推荐)
   - 网址：https://icon.kitchen/
   - 功能：同时生成Android和iOS图标
   - 特点：支持自适应图标

2. **App Icon Generator**
   - 网址：https://appicon.co/
   - 功能：生成iOS图标
   - 特点：简单易用

3. **Figma**
   - 网址：https://figma.com
   - 功能：专业设计工具
   - 特点：可自定义设计

### Flutter 工具
```bash
# 使用 flutter_launcher_icons 包
flutter pub add flutter_launcher_icons

# 配置 pubspec.yaml
flutter_icons:
  android: true
  ios: true
  image_path: "assets/images/icon.png"

# 生成图标
flutter pub run flutter_launcher_icons:main
```

---

## 设计资源

### 主图标设计稿
- 文件：`assets/images/icon_design.md`
- 包含：设计规范、尺寸要求、颜色值

### 颜色规范
- 背景色：#FFFFFF（纯白）
- 文字色：#1A1A1A（墨黑）
- 辅助色：#E5E5E5（淡墨灰）

### 字体规范
- 字体：思源黑体 Light
- 字号：48pt（图标）
- 字间距：16pt

---

## 注意事项

1. **图标尺寸**：确保所有尺寸都生成完整
2. **圆角处理**：iOS图标会自动添加圆角，不需要手动处理
3. **背景透明**：主图标使用透明背景，让系统处理圆角
4. **深色模式**：如需支持深色模式，需要准备深色版本图标
5. **测试验证**：在不同设备上测试图标显示效果

---

## 后续步骤

1. ✅ 设计图标规范
2. ✅ 实现启动页
3. ⬜ 生成图标文件（使用在线工具）
4. ⬜ 放置到对应目录
5. ⬜ 测试验证
6. ⬜ 准备应用商店截图

---

## 相关文件

- 设计规范：`assets/images/icon_design.md`
- 启动页：`lib/presentation/splash_page.dart`
- 主程序：`lib/main.dart`
- Android配置：`android/app/src/main/AndroidManifest.xml`
- iOS配置：`ios/Runner/Info.plist`
