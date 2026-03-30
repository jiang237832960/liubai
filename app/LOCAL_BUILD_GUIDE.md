# 留白 App - 本地打包指南

## 环境准备

### 1. Flutter SDK

```bash
# 下载稳定版 Flutter SDK
curl -fsSL https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.24.0-stable.tar.xz -o flutter.tar.xz
tar xf flutter.tar.xz
rm flutter.tar.xz

# 配置环境变量
export PATH="$PATH:/workspace/app/flutter/bin"

# 配置 git 安全目录
git config --global --add safe.directory /workspace/app/flutter
```

### 2. Java JDK

```bash
# Debian/Ubuntu 安装 OpenJDK 17
apt-get update
apt-get install -y openjdk-17-jdk-headless

# 验证安装
java -version
```

### 3. Android SDK

```bash
# 创建目录
mkdir -p /opt/android-sdk/cmdline-tools

# 下载 Android 命令行工具
cd /opt/android-sdk/cmdline-tools
curl -fsSL https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -o cmdline-tools.zip
unzip -q cmdline-tools.zip
mv cmdline-tools latest
rm cmdline-tools.zip

# 配置环境变量
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export ANDROID_HOME=/opt/android-sdk
export ANDROID_SDK_ROOT=/opt/android-sdk
export PATH="$PATH:$JAVA_HOME/bin:/opt/android-sdk/cmdline-tools/latest/bin:/opt/android-sdk/platform-tools"

# 接受许可协议
yes | sdkmanager --licenses

# 安装必要的 SDK 组件
sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0"
```

## 构建配置

### 配置 Flutter 使用 Android SDK

```bash
export PATH="$PATH:/workspace/app/flutter/bin"
flutter config --android-sdk /opt/android-sdk
flutter doctor --android-licenses
```

### 添加阿里云 Maven 镜像（加速构建）

编辑 `android/build.gradle`：

```groovy
allprojects {
    repositories {
        maven { url 'https://maven.aliyun.com/repository/google' }
        maven { url 'https://maven.aliyun.com/repository/central' }
        maven { url 'https://maven.aliyun.com/repository/public' }
        google()
        mavenCentral()
    }
}
```

编辑 `android/settings.gradle`：

```groovy
repositories {
    maven { url 'https://maven.aliyun.com/repository/google' }
    maven { url 'https://maven.aliyun.com/repository/central' }
    maven { url 'https://maven.aliyun.com/repository/public' }
    maven { url 'https://maven.aliyun.com/repository/gradle-plugin' }
    google()
    mavenCentral()
    gradlePluginPortal()
}
```

## 构建 APK

```bash
cd /workspace/app

# 清理并获取依赖
flutter clean
flutter pub get

# 构建发布版 APK
flutter build apk --release

# 输出路径
# build/app/outputs/flutter-apk/app-release.apk
```

## 完整构建脚本

```bash
#!/bin/bash
# build_apk.sh

set -e

export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export ANDROID_HOME=/opt/android-sdk
export ANDROID_SDK_ROOT=/opt/android-sdk
export PATH="$PATH:$JAVA_HOME/bin:/opt/android-sdk/cmdline-tools/latest/bin:/opt/android-sdk/platform-tools:/workspace/app/flutter/bin"

cd /workspace/app

echo "清理构建..."
flutter clean

echo "获取依赖..."
flutter pub get

echo "构建 APK..."
flutter build apk --release

echo "构建完成!"
ls -lh build/app/outputs/flutter-apk/app-release.apk
```

## 常见问题

### 1. 网络 TLS 错误

如果遇到 `The server may not support the client's requested TLS protocol versions` 错误，添加阿里云镜像即可解决。

### 2. Gradle 下载超时

配置镜像后重试，或增加 Gradle 超时时间：

```groovy
# gradle.properties
org.gradle.jvmargs=-Xmx2048m -Dfile.encoding=UTF-8
```

### 3. 权限问题

```bash
chmod +x /workspace/app/flutter/bin/flutter
chmod +x /opt/android-sdk/cmdline-tools/latest/bin/*
```

## 验证 APK

```bash
# 查看 APK 信息
ls -lh build/app/outputs/flutter-apk/app-release.apk

# 检查签名
apksigner verify -v build/app/outputs/flutter-apk/app-release.apk
```
