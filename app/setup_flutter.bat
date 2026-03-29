@echo off
chcp 65001 >nul
echo ========================================
echo   Flutter 环境配置脚本
echo ========================================
echo.

REM 添加 Flutter 到用户 PATH
echo [1/3] 配置 PATH 环境变量...
setx PATH "%PATH%;D:\Programs\flutter\bin" >nul 2>&1
if %errorlevel% == 0 (
    echo       [OK] PATH 配置成功
) else (
    echo       [WARN] PATH 可能已存在或需要手动配置
)

REM 设置国内镜像
echo.
echo [2/3] 配置国内镜像...
setx PUB_HOSTED_URL "https://pub.flutter-io.cn" >nul 2>&1
setx FLUTTER_STORAGE_BASE_URL "https://storage.flutter-io.cn" >nul 2>&1
echo       [OK] 国内镜像配置成功

REM 验证
echo.
echo [3/3] 验证安装...
echo       请稍后...

REM 使用完整路径运行 flutter
call "D:\Programs\flutter\bin\flutter.bat" --version 2>nul
if %errorlevel% == 0 (
    echo.
    echo ========================================
    echo   [OK] Flutter 配置成功！
    echo ========================================
) else (
    echo.
    echo ========================================
    echo   [INFO] 配置已保存
    echo ========================================
    echo.
    echo 请完成以下步骤：
    echo   1. 关闭此窗口
    echo   2. 重新打开 PowerShell 或 CMD
    echo   3. 运行 flutter doctor 验证
)

echo.
echo 安装路径: D:\Programs\flutter
echo.
pause
