# 留白 App - Flutter 环境安装脚本
# 安装路径: D:\Programs
# 运行方式: 右键选择"使用 PowerShell 运行"

param(
    [string]$InstallPath = "D:\Programs"
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  留白 App - Flutter 环境安装脚本" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 检查管理员权限
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "警告: 建议以管理员身份运行此脚本" -ForegroundColor Yellow
    Write-Host ""
}

# 创建安装目录
Write-Host "[1/6] 创建安装目录..." -ForegroundColor Green
if (-not (Test-Path $InstallPath)) {
    New-Item -ItemType Directory -Path $InstallPath -Force | Out-Null
    Write-Host "      已创建: $InstallPath" -ForegroundColor Gray
} else {
    Write-Host "      目录已存在: $InstallPath" -ForegroundColor Gray
}

# 下载 Flutter SDK
Write-Host ""
Write-Host "[2/6] 下载 Flutter SDK..." -ForegroundColor Green
$FlutterVersion = "3.16.0"
$FlutterZip = "flutter_windows_$FlutterVersion-stable.zip"
$FlutterUrl = "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/$FlutterZip"
$FlutterZipPath = Join-Path $InstallPath $FlutterZip

if (Test-Path $FlutterZipPath) {
    Write-Host "      文件已存在，跳过下载" -ForegroundColor Gray
} else {
    Write-Host "      正在下载 Flutter SDK $FlutterVersion..." -ForegroundColor Gray
    try {
        Invoke-WebRequest -Uri $FlutterUrl -OutFile $FlutterZipPath -UseBasicParsing
        Write-Host "      下载完成" -ForegroundColor Gray
    } catch {
        Write-Host "      下载失败: $_" -ForegroundColor Red
        exit 1
    }
}

# 解压 Flutter SDK
Write-Host ""
Write-Host "[3/6] 解压 Flutter SDK..." -ForegroundColor Green
$FlutterPath = Join-Path $InstallPath "flutter"
if (Test-Path $FlutterPath) {
    Write-Host "      Flutter 已存在，跳过解压" -ForegroundColor Gray
} else {
    Write-Host "      正在解压..." -ForegroundColor Gray
    Expand-Archive -Path $FlutterZipPath -DestinationPath $InstallPath -Force
    Write-Host "      解压完成" -ForegroundColor Gray
}

# 配置环境变量
Write-Host ""
Write-Host "[4/6] 配置环境变量..." -ForegroundColor Green

# 添加 Flutter 到 PATH
$FlutterBin = Join-Path $FlutterPath "bin"
$CurrentPath = [Environment]::GetEnvironmentVariable("Path", "User")

if ($CurrentPath -notlike "*$FlutterBin*") {
    Write-Host "      添加 Flutter 到用户 PATH..." -ForegroundColor Gray
    [Environment]::SetEnvironmentVariable(
        "Path",
        "$CurrentPath;$FlutterBin",
        "User"
    )
    Write-Host "      已添加 Flutter 到 PATH" -ForegroundColor Gray
} else {
    Write-Host "      Flutter 已在 PATH 中" -ForegroundColor Gray
}

# 设置 PUB_HOSTED_URL (国内镜像，可选)
Write-Host "      配置 Flutter 镜像..." -ForegroundColor Gray
[Environment]::SetEnvironmentVariable("PUB_HOSTED_URL", "https://pub.flutter-io.cn", "User")
[Environment]::SetEnvironmentVariable("FLUTTER_STORAGE_BASE_URL", "https://storage.flutter-io.cn", "User")
Write-Host "      已配置国内镜像" -ForegroundColor Gray

# 运行 Flutter Doctor
Write-Host ""
Write-Host "[5/6] 运行 Flutter Doctor..." -ForegroundColor Green
& "$FlutterBin\flutter.bat" doctor

# 创建 Android Studio 下载快捷方式
Write-Host ""
Write-Host "[6/6] 准备 Android Studio 安装..." -ForegroundColor Green
$AndroidStudioUrl = "https://redirector.gvt1.com/edgedl/android/studio/install/2023.1.1.28/android-studio-2023.1.1.28-windows.exe"
Write-Host "      Android Studio 下载地址:" -ForegroundColor Gray
Write-Host "      $AndroidStudioUrl" -ForegroundColor Cyan
Write-Host ""
Write-Host "      请手动下载并安装 Android Studio" -ForegroundColor Yellow

# 完成
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Flutter SDK 安装完成!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "安装路径: $FlutterPath" -ForegroundColor White
Write-Host ""
Write-Host "下一步:" -ForegroundColor Yellow
Write-Host "  1. 重启终端或重新打开 PowerShell" -ForegroundColor White
Write-Host "  2. 运行 'flutter doctor' 检查环境" -ForegroundColor White
Write-Host "  3. 安装 Android Studio" -ForegroundColor White
Write-Host "  4. 配置 Android SDK" -ForegroundColor White
Write-Host ""
Write-Host "按任意键退出..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
