# 留白 App - Flutter 环境安装脚本 (修复版)
# 安装路径: D:\Programs
# 运行方式: 右键选择"使用 PowerShell 运行" 或在 PowerShell 中运行: .\INSTALL_FLUTTER_FIXED.ps1

param(
    [string]$InstallPath = "D:\Programs"
)

# 错误处理 - 遇到错误继续执行
$ErrorActionPreference = "Continue"

# 防止窗口立即关闭的函数
function Wait-ForKey {
    Write-Host ""
    Write-Host "按 Enter 键退出..." -ForegroundColor Gray
    Read-Host
}

# 注册退出时等待
Register-EngineEvent PowerShell.Exiting -Action { Wait-ForKey } | Out-Null

try {
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  留白 App - Flutter 环境安装脚本" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""

    # 检查管理员权限
    Write-Host "[*] 检查管理员权限..." -ForegroundColor Yellow
    $isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $isAdmin) {
        Write-Host "    警告: 未以管理员身份运行" -ForegroundColor Yellow
        Write-Host "    建议: 右键 PowerShell 选择'以管理员身份运行'后重新执行脚本" -ForegroundColor Yellow
        Write-Host ""
        $continue = Read-Host "是否继续安装? (y/n)"
        if ($continue -ne 'y' -and $continue -ne 'Y') {
            exit 0
        }
    } else {
        Write-Host "    已以管理员身份运行" -ForegroundColor Green
    }

    # 创建安装目录
    Write-Host ""
    Write-Host "[1/6] 创建安装目录..." -ForegroundColor Green
    try {
        if (-not (Test-Path $InstallPath)) {
            New-Item -ItemType Directory -Path $InstallPath -Force | Out-Null
            Write-Host "      ✓ 已创建: $InstallPath" -ForegroundColor Green
        } else {
            Write-Host "      ✓ 目录已存在: $InstallPath" -ForegroundColor Gray
        }
    } catch {
        Write-Host "      ✗ 创建目录失败: $_" -ForegroundColor Red
        throw
    }

    # 下载 Flutter SDK
    Write-Host ""
    Write-Host "[2/6] 下载 Flutter SDK..." -ForegroundColor Green
    $FlutterVersion = "3.16.0"
    $FlutterZip = "flutter_windows_$FlutterVersion-stable.zip"
    $FlutterUrl = "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/$FlutterZip"
    $FlutterZipPath = Join-Path $InstallPath $FlutterZip

    if (Test-Path $FlutterZipPath) {
        $fileSize = (Get-Item $FlutterZipPath).Length / 1MB
        Write-Host "      ✓ 文件已存在 ($([math]::Round($fileSize, 2)) MB)，跳过下载" -ForegroundColor Gray
    } else {
        Write-Host "      正在下载 Flutter SDK $FlutterVersion..." -ForegroundColor Gray
        Write-Host "      文件大小约 700MB，请耐心等待..." -ForegroundColor Yellow
        try {
            # 使用 BITS 下载（更稳定）
            Import-Module BitsTransfer -ErrorAction SilentlyContinue
            if (Get-Command Start-BitsTransfer -ErrorAction SilentlyContinue) {
                Start-BitsTransfer -Source $FlutterUrl -Destination $FlutterZipPath -DisplayName "下载 Flutter SDK" -Description "请等待下载完成..."
            } else {
                # 备用下载方式
                $ProgressPreference = 'Continue'
                Invoke-WebRequest -Uri $FlutterUrl -OutFile $FlutterZipPath -UseBasicParsing -TimeoutSec 3600
            }
            $fileSize = (Get-Item $FlutterZipPath).Length / 1MB
            Write-Host "      ✓ 下载完成 ($([math]::Round($fileSize, 2)) MB)" -ForegroundColor Green
        } catch {
            Write-Host "      ✗ 下载失败: $_" -ForegroundColor Red
            Write-Host "      请手动下载: $FlutterUrl" -ForegroundColor Yellow
            Write-Host "      下载后放置到: $FlutterZipPath" -ForegroundColor Yellow
            throw
        }
    }

    # 解压 Flutter SDK
    Write-Host ""
    Write-Host "[3/6] 解压 Flutter SDK..." -ForegroundColor Green
    $FlutterPath = Join-Path $InstallPath "flutter"
    if (Test-Path $FlutterPath) {
        Write-Host "      ✓ Flutter 目录已存在，跳过解压" -ForegroundColor Gray
        Write-Host "      如需重新解压，请先删除: $FlutterPath" -ForegroundColor Yellow
    } else {
        Write-Host "      正在解压 (这可能需要几分钟)..." -ForegroundColor Gray
        try {
            Expand-Archive -Path $FlutterZipPath -DestinationPath $InstallPath -Force
            Write-Host "      ✓ 解压完成" -ForegroundColor Green
        } catch {
            Write-Host "      ✗ 解压失败: $_" -ForegroundColor Red
            throw
        }
    }

    # 配置环境变量
    Write-Host ""
    Write-Host "[4/6] 配置环境变量..." -ForegroundColor Green

    # 添加 Flutter 到 PATH
    $FlutterBin = Join-Path $FlutterPath "bin"
    $CurrentPath = [Environment]::GetEnvironmentVariable("Path", "User")

    if ($CurrentPath -notlike "*$FlutterBin*") {
        Write-Host "      添加 Flutter 到用户 PATH..." -ForegroundColor Gray
        try {
            [Environment]::SetEnvironmentVariable(
                "Path",
                "$CurrentPath;$FlutterBin",
                "User"
            )
            Write-Host "      ✓ 已添加 Flutter 到 PATH" -ForegroundColor Green
        } catch {
            Write-Host "      ✗ 设置 PATH 失败: $_" -ForegroundColor Red
            Write-Host "      请手动添加: $FlutterBin" -ForegroundColor Yellow
        }
    } else {
        Write-Host "      ✓ Flutter 已在 PATH 中" -ForegroundColor Gray
    }

    # 设置国内镜像
    Write-Host "      配置 Flutter 国内镜像..." -ForegroundColor Gray
    try {
        [Environment]::SetEnvironmentVariable("PUB_HOSTED_URL", "https://pub.flutter-io.cn", "User")
        [Environment]::SetEnvironmentVariable("FLUTTER_STORAGE_BASE_URL", "https://storage.flutter-io.cn", "User")
        Write-Host "      ✓ 已配置国内镜像" -ForegroundColor Green
    } catch {
        Write-Host "      ! 配置镜像失败: $_" -ForegroundColor Yellow
    }

    # 运行 Flutter Doctor
    Write-Host ""
    Write-Host "[5/6] 运行 Flutter Doctor..." -ForegroundColor Green
    $FlutterBat = Join-Path $FlutterBin "flutter.bat"
    if (Test-Path $FlutterBat) {
        try {
            Write-Host "      执行 flutter doctor..." -ForegroundColor Gray
            & $FlutterBat doctor
            Write-Host "      ✓ Flutter Doctor 完成" -ForegroundColor Green
        } catch {
            Write-Host "      ! Flutter Doctor 执行失败: $_" -ForegroundColor Yellow
            Write-Host "      安装完成后请手动运行 'flutter doctor'" -ForegroundColor Yellow
        }
    } else {
        Write-Host "      ! 未找到 flutter.bat，跳过" -ForegroundColor Yellow
    }

    # 准备 Android Studio
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
    Write-Host "常见问题:" -ForegroundColor Yellow
    Write-Host "  - 如果 'flutter' 命令找不到，请重启 PowerShell" -ForegroundColor Gray
    Write-Host "  - 如果需要卸载，直接删除 $FlutterPath" -ForegroundColor Gray

} catch {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Red
    Write-Host "  安装过程中出现错误" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Red
    Write-Host "错误信息: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "解决方案:" -ForegroundColor Yellow
    Write-Host "  1. 检查网络连接" -ForegroundColor White
    Write-Host "  2. 以管理员身份运行 PowerShell" -ForegroundColor White
    Write-Host "  3. 手动下载 Flutter SDK" -ForegroundColor White
} finally {
    # 确保窗口不会立即关闭
    Write-Host ""
    Wait-ForKey
}
