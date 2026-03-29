# 留白 App - Android 构建指南

## 前置条件

### 1. 安装 Flutter SDK

```bash
# 下载 Flutter SDK
https://docs.flutter.dev/get-started/install/windows

# 配置环境变量
setx PATH "%PATH%;C:\flutter\bin"

# 验证安装
flutter doctor
```

### 2. 安装 Android Studio

```bash
# 下载 Android Studio
https://developer.android.com/studio

# 安装以下组件：
# - Android SDK
# - Android SDK Platform-Tools
# - Android SDK Build-Tools
# - Android Emulator (可选)
```

### 3. 配置 Android 环境

```bash
# 设置 ANDROID_HOME 环境变量
setx ANDROID_HOME "C:\Users\%USERNAME%\AppData\Local\Android\Sdk"

# 添加到 PATH
setx PATH "%PATH%;%ANDROID_HOME%\platform-tools"
```

---

## 添加 Android 平台支持

### 1. 创建 Android 项目

```bash
cd d:/Ai-depoy/projects/秒启专注/app

# 添加 Android 平台
flutter create --platforms=android .
```

### 2. 配置应用信息

编辑 `android/app/build.gradle`：

```gradle
android {
    namespace "com.liubai.app"
    compileSdkVersion 34
    
    defaultConfig {
        applicationId "com.liubai.app"
        minSdkVersion 21
        targetSdkVersion 34
        versionCode 1
        versionName "1.0.0"
    }
    
    buildTypes {
        release {
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
            
            // 签名配置（见下文）
            signingConfig signingConfigs.release
        }
    }
}
```

### 3. 配置应用名称

编辑 `android/app/src/main/AndroidManifest.xml`：

```xml
<application
    android:label="留白"
    android:name="${applicationName}"
    android:icon="@mipmap/ic_launcher">
    
    <activity
        android:name=".MainActivity"
        android:exported="true"
        android:launchMode="singleTop"
        android:theme="@style/LaunchTheme"
        android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
        android:hardwareAccelerated="true"
        android:windowSoftInputMode="adjustResize">
        
        <meta-data
            android:name="io.flutter.embedding.android.NormalTheme"
            android:resource="@style/NormalTheme" />
            
        <intent-filter>
            <action android:name="android.intent.action.MAIN"/>
            <category android:name="android.intent.category.LAUNCHER"/>
        </intent-filter>
    </activity>
    
    <meta-data
        android:name="flutterEmbedding"
        android:value="2" />
</application>
```

---

## 配置应用签名

### 1. 创建密钥库

```bash
# 生成签名密钥
keytool -genkey -v -keystore liubai-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias liubai

# 密钥信息：
# - 密钥库密码: 建议设置强密码
# - 别名: liubai
# - 有效期: 10000天
```

### 2. 配置签名信息

创建 `android/key.properties`：

```properties
storePassword=你的密钥库密码
keyPassword=你的密钥密码
keyAlias=liubai
storeFile=../liubai-key.jks
```

### 3. 配置 build.gradle

编辑 `android/app/build.gradle`，添加签名配置：

```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    // ...
    
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    
    buildTypes {
        release {
            signingConfig signingConfigs.release
            // ...
        }
    }
}
```

---

## 构建 APK

### 1. 构建发布版 APK

```bash
# 清理构建缓存
flutter clean

# 获取依赖
flutter pub get

# 构建发布版 APK
flutter build apk --release

# 输出路径：build/app/outputs/flutter-apk/app-release.apk
```

### 2. 构建 App Bundle (Google Play)

```bash
# 构建 AAB 格式（用于 Google Play）
flutter build appbundle --release

# 输出路径：build/app/outputs/bundle/release/app-release.aab
```

### 3. 构建分架构 APK（可选）

```bash
# 仅构建 ARM64
flutter build apk --release --target-platform=android-arm64

# 仅构建 ARM32
flutter build apk --release --target-platform=android-arm
```

---

## 验证 APK

### 1. 检查 APK 信息

```bash
# 使用 aapt 查看 APK 信息
aapt dump badging build/app/outputs/flutter-apk/app-release.apk

# 查看签名信息
apksigner verify -v build/app/outputs/flutter-apk/app-release.apk
```

### 2. 安装测试

```bash
# 连接设备后安装
flutter install

# 或直接安装 APK
adb install build/app/outputs/flutter-apk/app-release.apk
```

### 3. 启动应用

```bash
# 通过 Flutter 启动
flutter run --release

# 或手动启动
adb shell am start -n com.liubai.app/.MainActivity
```

---

## 优化 APK 大小

### 1. 启用代码压缩

编辑 `android/app/build.gradle`：

```gradle
buildTypes {
    release {
        minifyEnabled true
        shrinkResources true
        proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
    }
}
```

### 2. 创建 ProGuard 规则

创建 `android/app/proguard-rules.pro`：

```proguard
# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# SQLite
-keep class com.tencent.wcdb.** { *; }

# Audio
-keep class com.ryanheise.audioservice.** { *; }
```

### 3. 移除未使用资源

编辑 `android/app/build.gradle`：

```gradle
android {
    // ...
    
    packagingOptions {
        exclude 'META-INF/DUMMY.SF'
        exclude 'META-INF/DUMMY.RSA'
    }
}
```

---

## 常见问题

### 1. 构建失败：缺少 SDK

```bash
# 安装缺失的 SDK 组件
sdkmanager "platforms;android-34"
sdkmanager "build-tools;34.0.0"
```

### 2. 签名错误

```bash
# 检查密钥库
keytool -list -v -keystore liubai-key.jks

# 验证签名
apksigner sign --ks liubai-key.jks --ks-key-alias liubai app-release.apk
```

### 3. 安装失败：签名冲突

```bash
# 卸载旧版本
adb uninstall com.liubai.app

# 重新安装
adb install app-release.apk
```

---

## 发布前检查清单

- [ ] Flutter Doctor 检查通过
- [ ] 应用版本号已更新
- [ ] 应用图标已配置
- [ ] 应用名称已设置（中文：留白）
- [ ] 签名密钥已创建
- [ ] 发布版 APK 已构建
- [ ] APK 签名已验证
- [ ] 在真机上测试通过
- [ ] 应用大小已优化（目标 < 50MB）

---

## 文件清单

构建完成后，你将获得以下文件：

```
build/app/outputs/flutter-apk/
├── app-release.apk          # 通用 APK
├── app-arm64-v8a-release.apk    # ARM64
└── app-armeabi-v7a-release.apk  # ARM32

build/app/outputs/bundle/release/
└── app-release.aab          # Google Play 用
```

---

## 下一步

1. 执行上述步骤添加 Android 平台
2. 创建签名密钥
3. 构建发布版 APK
4. 在真机上测试
5. 准备应用商店素材
