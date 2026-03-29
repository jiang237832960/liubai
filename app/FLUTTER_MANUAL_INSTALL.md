# Flutter 手动安装指南

如果 PowerShell 脚本闪退，请使用以下手动安装步骤。

---

## 📋 安装步骤

### 步骤 1: 创建安装目录

1. 打开文件资源管理器
2. 进入 `D:` 盘
3. 创建文件夹 `Programs`（如果不存在）

```
D:\Programs
```

---

### 步骤 2: 下载 Flutter SDK

**方式一：浏览器下载（推荐）**

1. 打开浏览器，访问：
   ```
   https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.16.0-stable.zip
   ```

2. 等待下载完成（约 700MB）

3. 将下载的 `flutter_windows_3.16.0-stable.zip` 移动到 `D:\Programs`

**方式二：使用 PowerShell 下载**

```powershell
# 打开 PowerShell，执行：
cd D:\Programs
Invoke-WebRequest -Uri "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.16.0-stable.zip" -OutFile "flutter_windows_3.16.0-stable.zip"
```

---

### 步骤 3: 解压 Flutter SDK

1. 右键点击 `flutter_windows_3.16.0-stable.zip`
2. 选择 "全部解压缩..."
3. 解压到 `D:\Programs`
4. 确保解压后路径为 `D:\Programs\flutter`

**或使用 PowerShell 解压：**

```powershell
cd D:\Programs
Expand-Archive -Path "flutter_windows_3.16.0-stable.zip" -DestinationPath "."
```

---

### 步骤 4: 配置环境变量

**方法一：图形界面（推荐）**

1. 按 `Win + R`，输入 `sysdm.cpl`，回车
2. 点击 "高级" 选项卡
3. 点击 "环境变量"
4. 在 "用户变量" 中找到 `Path`，双击编辑
5. 点击 "新建"，添加：
   ```
   D:\Programs\flutter\bin
   ```
6. 点击 "确定" 保存

**方法二：PowerShell 命令**

```powershell
# 添加 Flutter 到 PATH
[Environment]::SetEnvironmentVariable("Path", $env:Path + ";D:\Programs\flutter\bin", "User")

# 设置国内镜像（可选，加速下载）
[Environment]::SetEnvironmentVariable("PUB_HOSTED_URL", "https://pub.flutter-io.cn", "User")
[Environment]::SetEnvironmentVariable("FLUTTER_STORAGE_BASE_URL", "https://storage.flutter-io.cn", "User")
```

---

### 步骤 5: 验证安装

1. **重启 PowerShell**（必须！）

2. 运行以下命令验证：

```powershell
flutter --version
```

应该显示类似：
```
Flutter 3.16.0 • channel stable • https://github.com/flutter/flutter.git
Framework • revision ...
Engine • revision ...
Tools • Dart 3.2.0 • DevTools ...
```

3. 运行诊断：

```powershell
flutter doctor
```

---

### 步骤 6: 安装 Android Studio

1. 下载 Android Studio：
   ```
   https://redirector.gvt1.com/edgedl/android/studio/install/2023.1.1.28/android-studio-2023.1.1.28-windows.exe
   ```

2. 运行安装程序，按向导完成安装

3. 打开 Android Studio，安装 Flutter 插件：
   - File → Settings → Plugins
   - 搜索 "Flutter"
   - 点击 Install
   - 重启 Android Studio

4. 配置 Android SDK：
   - File → Settings → Appearance & Behavior → System Settings → Android SDK
   - 安装 Android SDK Platform 33 或更高版本
   - 安装 Android SDK Command-line Tools

---

### 步骤 7: 接受 Android 许可证

```powershell
flutter doctor --android-licenses
```

按提示输入 `y` 接受所有许可证。

---

### 步骤 8: 最终验证

```powershell
flutter doctor
```

所有项目应该显示绿色 ✓，除了：
- Android toolchain（需要 Android Studio）
- Chrome / Edge（可选，用于 Web 开发）
- Visual Studio（可选，用于 Windows 开发）

---

## 🛠️ 常见问题

### 问题 1: 'flutter' 不是内部或外部命令

**原因**: 环境变量未生效

**解决**:
1. 重启 PowerShell
2. 检查 PATH 是否正确设置：
   ```powershell
   $env:Path
   ```
3. 确保包含 `D:\Programs\flutter\bin`

---

### 问题 2: 下载速度慢

**解决**: 使用国内镜像

```powershell
[Environment]::SetEnvironmentVariable("PUB_HOSTED_URL", "https://pub.flutter-io.cn", "User")
[Environment]::SetEnvironmentVariable("FLUTTER_STORAGE_BASE_URL", "https://storage.flutter-io.cn", "User")
```

然后重启 PowerShell

---

### 问题 3: Android SDK 找不到

**解决**:

1. 打开 Android Studio
2. File → Settings → Appearance & Behavior → System Settings → Android SDK
3. 复制 "Android SDK Location" 路径
4. 设置环境变量：

```powershell
[Environment]::SetEnvironmentVariable("ANDROID_HOME", "C:\Users\你的用户名\AppData\Local\Android\Sdk", "User")
```

---

### 问题 4: 权限不足

**解决**: 以管理员身份运行 PowerShell

1. 右键点击 "PowerShell"
2. 选择 "以管理员身份运行"
3. 重新执行命令

---

## ✅ 验证清单

- [ ] Flutter SDK 下载完成
- [ ] 解压到 `D:\Programs\flutter`
- [ ] 环境变量 PATH 添加 `D:\Programs\flutter\bin`
- [ ] `flutter --version` 显示版本信息
- [ ] `flutter doctor` 运行成功
- [ ] Android Studio 安装完成
- [ ] Flutter 插件安装完成
- [ ] Android SDK 配置完成
- [ ] Android 许可证已接受

---

## 🚀 下一步

安装完成后，回到项目目录运行：

```powershell
cd "D:\Ai-depoy\projects\秒启专注\app"
flutter pub get
flutter test
flutter build apk
```

---

## 📞 需要帮助？

如果仍有问题，请提供：
1. `flutter doctor -v` 的完整输出
2. 错误截图或错误信息
3. Windows 版本
