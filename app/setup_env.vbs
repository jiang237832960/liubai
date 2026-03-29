' Flutter 环境变量配置脚本
' 使用 VBS 配置环境变量，绕过 PowerShell 问题

Option Explicit

Dim WshShell, userPath, flutterBin

Set WshShell = CreateObject("WScript.Shell")

' 获取当前用户 PATH
userPath = WshShell.Environment("User").Item("PATH")
flutterBin = "D:\Programs\flutter\bin"

' 检查是否已存在
If InStr(userPath, flutterBin) = 0 Then
    ' 添加 Flutter 到 PATH
    WshShell.Environment("User").Item("PATH") = userPath & ";" & flutterBin
    MsgBox "Flutter PATH 配置成功！" & vbCrLf & vbCrLf & "已添加: " & flutterBin, vbInformation, "配置成功"
Else
    MsgBox "Flutter PATH 已存在，无需重复配置。" & vbCrLf & vbCrLf & "路径: " & flutterBin, vbInformation, "配置信息"
End If

' 设置国内镜像
WshShell.Environment("User").Item("PUB_HOSTED_URL") = "https://pub.flutter-io.cn"
WshShell.Environment("User").Item("FLUTTER_STORAGE_BASE_URL") = "https://storage.flutter-io.cn"

MsgBox "国内镜像配置成功！" & vbCrLf & vbCrLf & _
       "PUB_HOSTED_URL: https://pub.flutter-io.cn" & vbCrLf & _
       "FLUTTER_STORAGE_BASE_URL: https://storage.flutter-io.cn" & vbCrLf & vbCrLf & _
       "请重新打开 PowerShell 或 CMD 后运行 flutter doctor", vbInformation, "配置完成"

Set WshShell = Nothing
