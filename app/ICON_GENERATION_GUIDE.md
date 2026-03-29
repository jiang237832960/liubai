# 留白 App 图标生成指南

## 📁 已创建的文件

在 `assets/images/` 目录下已创建以下 SVG 源文件：

| 文件 | 说明 |
|------|------|
| `icon_source.svg` | 浅色模式文字图标（"留"字） |
| `icon_source_dark.svg` | 深色模式文字图标 |
| `icon_geometric.svg` | 浅色模式几何图标（四个点） |
| `icon_geometric_dark.svg` | 深色模式几何图标 |

## 🛠️ 生成图标的方法

### 方法一：使用在线工具（推荐）

#### 1. 转换为 PNG
访问 [SVG to PNG](https://cloudconvert.com/svg-to-png) 或 [Convertio](https://convertio.co/svg-png/)

设置：
- 宽度：1024
- 高度：1024
- 输出格式：PNG

#### 2. 生成各平台图标

**Android & iOS 图标生成：**

访问 [Icon Kitchen](https://icon.kitchen/)

步骤：
1. 上传 `icon_source.svg` 或生成的 PNG
2. 选择平台：Android + iOS
3. 设置背景：透明（如需）或纯色
4. 下载生成的图标包

**或访问 [App Icon Generator](https://appicon.co/)**

步骤：
1. 上传 1024x1024 的 PNG 图标
2. 勾选需要的平台（Android + iOS）
3. 下载生成的图标包

### 方法二：使用 Figma（设计工具）

1. 访问 [Figma](https://figma.com)
2. 导入 SVG 文件
3. 安装插件 "App Icon Generator"
4. 一键导出各平台图标

### 方法三：使用命令行工具

如果你安装了 Node.js，可以使用 `svgexport`：

```bash
# 安装 svgexport
npm install -g svgexport

# 生成 1024x1024 PNG
svgexport assets/images/icon_source.svg generated_icons/icon_1024x1024.png 1024:1024

# 生成其他尺寸...
```

## 📂 图标放置位置

### Android 图标

将生成的图标复制到：

```
android/app/src/main/res/
├── mipmap-mdpi/
│   └── ic_launcher.png       (48x48)
├── mipmap-hdpi/
│   └── ic_launcher.png       (72x72)
├── mipmap-xhdpi/
│   └── ic_launcher.png       (96x96)
├── mipmap-xxhdpi/
│   └── ic_launcher.png       (144x144)
└── mipmap-xxxhdpi/
    └── ic_launcher.png       (192x192)
```

### iOS 图标

将生成的图标复制到：

```
ios/Runner/Assets.xcassets/AppIcon.appiconset/
├── Contents.json
├── Icon-20x20@1x.png         (20x20)
├── Icon-20x20@2x.png         (40x40)
├── Icon-20x20@3x.png         (60x60)
├── Icon-29x29@1x.png         (29x29)
├── Icon-29x29@2x.png         (58x58)
├── Icon-29x29@3x.png         (87x87)
├── Icon-40x40@1x.png         (40x40)
├── Icon-40x40@2x.png         (80x80)
├── Icon-40x40@3x.png         (120x120)
├── Icon-60x60@2x.png         (120x120)
├── Icon-60x60@3x.png         (180x180)
├── Icon-76x76@1x.png         (76x76)
├── Icon-76x76@2x.png         (152x152)
├── Icon-83.5x83.5@2x.png     (167x167)
└── iTunesArtwork@2x.png      (1024x1024)
```

## 📝 iOS Contents.json

创建 `ios/Runner/Assets.xcassets/AppIcon.appiconset/Contents.json`：

```json
{
  "images": [
    {
      "size": "20x20",
      "idiom": "iphone",
      "filename": "Icon-20x20@2x.png",
      "scale": "2x"
    },
    {
      "size": "20x20",
      "idiom": "iphone",
      "filename": "Icon-20x20@3x.png",
      "scale": "3x"
    },
    {
      "size": "29x29",
      "idiom": "iphone",
      "filename": "Icon-29x29@2x.png",
      "scale": "2x"
    },
    {
      "size": "29x29",
      "idiom": "iphone",
      "filename": "Icon-29x29@3x.png",
      "scale": "3x"
    },
    {
      "size": "40x40",
      "idiom": "iphone",
      "filename": "Icon-40x40@2x.png",
      "scale": "2x"
    },
    {
      "size": "40x40",
      "idiom": "iphone",
      "filename": "Icon-40x40@3x.png",
      "scale": "3x"
    },
    {
      "size": "60x60",
      "idiom": "iphone",
      "filename": "Icon-60x60@2x.png",
      "scale": "2x"
    },
    {
      "size": "60x60",
      "idiom": "iphone",
      "filename": "Icon-60x60@3x.png",
      "scale": "3x"
    },
    {
      "size": "20x20",
      "idiom": "ipad",
      "filename": "Icon-20x20@1x.png",
      "scale": "1x"
    },
    {
      "size": "20x20",
      "idiom": "ipad",
      "filename": "Icon-20x20@2x.png",
      "scale": "2x"
    },
    {
      "size": "29x29",
      "idiom": "ipad",
      "filename": "Icon-29x29@1x.png",
      "scale": "1x"
    },
    {
      "size": "29x29",
      "idiom": "ipad",
      "filename": "Icon-29x29@2x.png",
      "scale": "2x"
    },
    {
      "size": "40x40",
      "idiom": "ipad",
      "filename": "Icon-40x40@1x.png",
      "scale": "1x"
    },
    {
      "size": "40x40",
      "idiom": "ipad",
      "filename": "Icon-40x40@2x.png",
      "scale": "2x"
    },
    {
      "size": "76x76",
      "idiom": "ipad",
      "filename": "Icon-76x76@1x.png",
      "scale": "1x"
    },
    {
      "size": "76x76",
      "idiom": "ipad",
      "filename": "Icon-76x76@2x.png",
      "scale": "2x"
    },
    {
      "size": "83.5x83.5",
      "idiom": "ipad",
      "filename": "Icon-83.5x83.5@2x.png",
      "scale": "2x"
    },
    {
      "size": "1024x1024",
      "idiom": "ios-marketing",
      "filename": "iTunesArtwork@2x.png",
      "scale": "1x"
    }
  ],
  "info": {
    "version": 1,
    "author": "xcode"
  }
}
```

## 🎨 设计建议

### 推荐方案

**方案一：文字图标（推荐）**
- 使用 "留" 字作为图标主体
- 体现品牌核心 "留白" 理念
- 简洁有力，易于识别

**方案二：几何图标**
- 四个点代表留白的四个角
- 更加抽象，现代感强
- 适合极简主义设计

### 颜色规范

| 模式 | 背景 | 前景 |
|------|------|------|
| 浅色 | #FFFFFF | #1A1A1A |
| 深色 | #1A1A1A | #FFFFFF |

## ✅ 验证清单

- [ ] 已生成 1024x1024 主图标
- [ ] 已生成 Android 各尺寸图标 (48, 72, 96, 144, 192)
- [ ] 已生成 iOS 各尺寸图标
- [ ] Android 图标已放置到正确目录
- [ ] iOS 图标已放置到正确目录
- [ ] iOS Contents.json 已创建
- [ ] 已测试图标显示效果

## 🚀 下一步

图标配置完成后，可以：
1. 运行应用查看效果
2. 准备应用商店截图
3. 编写应用描述
4. 提交到应用商店
